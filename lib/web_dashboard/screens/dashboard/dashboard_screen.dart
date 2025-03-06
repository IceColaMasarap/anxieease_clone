import 'package:flutter/material.dart';
import '../../../services/psychologist_service.dart';
import '../../web_main.dart';  // Import for DEVELOPMENT_MODE
import 'widgets/patient_list.dart';
import 'widgets/metrics_overview.dart';
import 'widgets/patient_details.dart';
import 'widgets/analytics_view.dart';
import 'widgets/settings_view.dart';
import 'package:provider/provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../providers/auth_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _psychologistService = PsychologistService();
  Map<String, dynamic>? _psychologist;
  List<Map<String, dynamic>> _patients = [];
  String? _selectedPatientId;
  List<Map<String, dynamic>>? _selectedPatientMetrics;
  List<Map<String, dynamic>>? _selectedPatientMoodLogs;
  List<Map<String, dynamic>>? _selectedPatientNotes;
  bool _isLoading = true;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // Load real patient data here
      _patients = [
        {
          'id': '1',
          'full_name': 'John Doe',
          'email': 'john@example.com',
          'last_active': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
        },
        {
          'id': '2',
          'full_name': 'Jane Smith',
          'email': 'jane@example.com',
          'last_active': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        },
        // Add more sample patients as needed
      ];
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onNavigationItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
      if (index != 0) {
        _selectedPatientId = null;
      }
    });
  }

  void _onPatientSelected(String patientId) {
    setState(() => _selectedPatientId = patientId);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          // Navigation Rail
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onNavigationItemSelected,
            labelType: NavigationRailLabelType.selected,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: Text('Settings'),
              ),
            ],
          ),

          // Vertical Divider
          const VerticalDivider(thickness: 1, width: 1),

          // Main Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top App Bar
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Text(
                        _getPageTitle(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: _loadData,
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout),
                        onPressed: () {
                          context.read<AuthProvider>().signOut();
                        },
                      ),
                    ],
                  ),
                ),

                // Main Content Area
                Expanded(
                  child: Row(
                    children: [
                      if (_selectedIndex == 0) ...[
                        // Patient List
                        SizedBox(
                          width: 300,
                          child: PatientList(
                            patients: _patients,
                            selectedPatientId: _selectedPatientId,
                            onPatientSelected: _onPatientSelected,
                          ),
                        ),
                        const VerticalDivider(thickness: 1, width: 1),
                      ],

                      // Content Area
                      Expanded(
                        child: _selectedIndex == 0
                            ? _selectedPatientId != null
                                ? MetricsOverview(patientId: _selectedPatientId!)
                                : const Center(
                                    child: Text('Select a patient to view details'),
                                  )
                            : const SettingsView(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getPageTitle() {
    switch (_selectedIndex) {
      case 0:
        return _selectedPatientId != null ? 'Patient Details' : 'Dashboard';
      case 1:
        return 'Settings';
      default:
        return 'Dashboard';
    }
  }
} 