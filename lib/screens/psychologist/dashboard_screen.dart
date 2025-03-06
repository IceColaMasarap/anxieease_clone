import 'package:flutter/material.dart';
import '../../services/psychologist_service.dart';
import '../../models/psychologist.dart';
import 'patient_details_screen.dart';

class PsychologistDashboard extends StatefulWidget {
  const PsychologistDashboard({super.key});

  @override
  State<PsychologistDashboard> createState() => _PsychologistDashboardState();
}

class _PsychologistDashboardState extends State<PsychologistDashboard> {
  final PsychologistService _psychologistService = PsychologistService();
  Psychologist? _psychologist;
  List<Map<String, dynamic>> _patients = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final psychologist = await _psychologistService.getPsychologistProfile();
      final patients = await _psychologistService.getPatients();
      
      if (mounted) {
        setState(() {
          _psychologist = psychologist;
          _patients = patients;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Psychologist Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: Column(
        children: [
          // Psychologist Info Card
          if (_psychologist != null)
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dr. ${_psychologist!.fullName}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'License: ${_psychologist!.licenseNumber}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      'Specialization: ${_psychologist!.specialization}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),

          // Patients List
          Expanded(
            child: _patients.isEmpty
                ? const Center(
                    child: Text('No patients assigned yet'),
                  )
                : ListView.builder(
                    itemCount: _patients.length,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      final patient = _patients[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: ListTile(
                          title: Text(patient['full_name'] ?? 'Unknown'),
                          subtitle: Text('Last activity: ${_formatDate(patient['last_active'])}'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PatientDetailsScreen(
                                  patientId: patient['id'],
                                  patientName: patient['full_name'],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'Never';
    final date = DateTime.parse(dateStr);
    return '${date.day}/${date.month}/${date.year}';
  }
} 