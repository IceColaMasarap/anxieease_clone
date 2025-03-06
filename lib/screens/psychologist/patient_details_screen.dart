import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/psychologist_service.dart';
import 'patient_analytics_screen.dart';

class PatientDetailsScreen extends StatefulWidget {
  final String patientId;
  final String patientName;

  const PatientDetailsScreen({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  State<PatientDetailsScreen> createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends State<PatientDetailsScreen> {
  final PsychologistService _psychologistService = PsychologistService();
  final TextEditingController _noteController = TextEditingController();
  
  List<Map<String, dynamic>> _metrics = [];
  List<Map<String, dynamic>> _moodLogs = [];
  List<Map<String, dynamic>> _notes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPatientData();
  }

  Future<void> _loadPatientData() async {
    setState(() => _isLoading = true);
    try {
      final metrics = await _psychologistService.getPatientMetrics(widget.patientId);
      final moodLogs = await _psychologistService.getPatientMoodLogs(widget.patientId);
      final notes = await _psychologistService.getPatientNotes(widget.patientId);

      if (mounted) {
        setState(() {
          _metrics = metrics;
          _moodLogs = moodLogs;
          _notes = notes;
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

  Future<void> _addNote() async {
    if (_noteController.text.trim().isEmpty) return;

    try {
      await _psychologistService.addPatientNote(
        patientId: widget.patientId,
        note: _noteController.text.trim(),
        category: 'General',
      );
      _noteController.clear();
      await _loadPatientData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding note: ${e.toString()}')),
        );
      }
    }
  }

  void _navigateToAnalytics() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PatientAnalyticsScreen(
          patientId: widget.patientId,
          patientName: widget.patientName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.patientName),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics),
            tooltip: 'View Analytics',
            onPressed: _navigateToAnalytics,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPatientData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Analytics Button
                  Card(
                    child: InkWell(
                      onTap: _navigateToAnalytics,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(
                              Icons.analytics,
                              size: 32,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'View Detailed Analytics',
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  Text(
                                    'See trends, patterns, and detailed statistics',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: Theme.of(context).primaryColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Anxiety Metrics Chart
                  _buildMetricsCard(),
                  const SizedBox(height: 24),

                  // Mood Logs
                  _buildMoodLogsCard(),
                  const SizedBox(height: 24),

                  // Notes Section
                  _buildNotesSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildMetricsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Anxiety Levels',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: _metrics.isEmpty
                  ? const Center(child: Text('No anxiety records yet'))
                  : LineChart(
                      LineChartData(
                        gridData: FlGridData(show: false),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: _metrics
                                .map((metric) => FlSpot(
                                      _metrics.indexOf(metric).toDouble(),
                                      (metric['anxiety_level'] as num).toDouble(),
                                    ))
                                .toList(),
                            isCurved: true,
                            color: Theme.of(context).primaryColor,
                            barWidth: 3,
                            dotData: FlDotData(show: false),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodLogsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mood Logs',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _moodLogs.isEmpty
                ? const Center(child: Text('No mood logs yet'))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _moodLogs.length,
                    itemBuilder: (context, index) {
                      final log = _moodLogs[index];
                      return ListTile(
                        title: Text(log['mood'] ?? 'Unknown'),
                        subtitle: Text(_formatDate(log['created_at'])),
                        trailing: Text('Intensity: ${log['intensity']}'),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notes',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                hintText: 'Add a note...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _addNote,
                ),
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            _notes.isEmpty
                ? const Center(child: Text('No notes yet'))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _notes.length,
                    itemBuilder: (context, index) {
                      final note = _notes[index];
                      return ListTile(
                        title: Text(note['note']),
                        subtitle: Text(_formatDate(note['created_at'])),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'Unknown';
    final date = DateTime.parse(dateStr);
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }
} 