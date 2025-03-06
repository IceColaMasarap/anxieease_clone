import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/psychologist_service.dart';
import '../../models/mood_log.dart';

class PatientAnalyticsScreen extends StatefulWidget {
  final String patientId;
  final String patientName;

  const PatientAnalyticsScreen({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  State<PatientAnalyticsScreen> createState() => _PatientAnalyticsScreenState();
}

class _PatientAnalyticsScreenState extends State<PatientAnalyticsScreen> with SingleTickerProviderStateMixin {
  final PsychologistService _psychologistService = PsychologistService();
  late TabController _tabController;
  
  List<Map<String, dynamic>> _anxietyRecords = [];
  List<Map<String, dynamic>> _moodLogs = [];
  Map<String, dynamic>? _statistics;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadPatientData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPatientData() async {
    setState(() => _isLoading = true);
    try {
      final anxietyRecords = await _psychologistService.getPatientMetrics(widget.patientId);
      final moodLogs = await _psychologistService.getPatientMoodLogs(widget.patientId);
      final statistics = await _psychologistService.getPatientStatistics(widget.patientId);

      if (mounted) {
        setState(() {
          _anxietyRecords = anxietyRecords;
          _moodLogs = moodLogs;
          _statistics = statistics;
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
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.patientName} - Analytics'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Anxiety Records'),
            Tab(text: 'Mood Logs'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPatientData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildAnxietyRecordsTab(),
                _buildMoodLogsTab(),
              ],
            ),
    );
  }

  Widget _buildOverviewTab() {
    if (_statistics == null) {
      return const Center(child: Text('No statistics available'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Cards
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  title: 'Anxiety Records',
                  value: _statistics!['anxiety_count'].toString(),
                  subtitle: 'Total',
                  icon: Icons.warning_rounded,
                  iconColor: Colors.red,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  title: 'Mood Logs',
                  value: _statistics!['mood_count'].toString(),
                  subtitle: 'Total',
                  icon: Icons.mood_rounded,
                  iconColor: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  title: 'Avg Anxiety',
                  value: (_statistics!['average_anxiety_level'] as double).toStringAsFixed(1),
                  subtitle: 'Level (1-10)',
                  icon: Icons.analytics_rounded,
                  iconColor: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  title: 'Most Frequent',
                  value: _statistics!['most_frequent_mood'] ?? 'N/A',
                  subtitle: 'Mood',
                  icon: Icons.favorite_rounded,
                  iconColor: Colors.pink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Weekly Activity
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Weekly Activity',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              _statistics!['recent_anxiety_count'].toString(),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text('Anxiety Records'),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              _statistics!['recent_mood_count'].toString(),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text('Mood Logs'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Mood Distribution
          if (_statistics!['mood_frequency'] != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Mood Distribution',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: _buildMoodDistributionChart(),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAnxietyRecordsTab() {
    if (_anxietyRecords.isEmpty) {
      return const Center(child: Text('No anxiety records available'));
    }

    return Column(
      children: [
        // Anxiety Level Chart
        Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Anxiety Levels Over Time',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: LineChart(
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
                          spots: _anxietyRecords
                              .asMap()
                              .entries
                              .map((entry) => FlSpot(
                                    entry.key.toDouble(),
                                    (entry.value['anxiety_level'] as num).toDouble(),
                                  ))
                              .toList(),
                          isCurved: true,
                          color: Colors.red,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            color: Colors.red.withOpacity(0.1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Anxiety Records List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _anxietyRecords.length,
            itemBuilder: (context, index) {
              final record = _anxietyRecords[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text('Anxiety Level: ${record['anxiety_level']}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_formatDate(record['created_at'])),
                      if (record['triggers'] != null)
                        Text('Triggers: ${record['triggers']}'),
                      if (record['symptoms'] != null)
                        Text('Symptoms: ${record['symptoms']}'),
                    ],
                  ),
                  isThreeLine: true,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMoodLogsTab() {
    if (_moodLogs.isEmpty) {
      return const Center(child: Text('No mood logs available'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _moodLogs.length,
      itemBuilder: (context, index) {
        final log = _moodLogs[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Icon(
              _getMoodIcon(log['mood']),
              color: _getMoodColor(log['mood']),
              size: 32,
            ),
            title: Text(log['mood']),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_formatDate(log['created_at'])),
                if (log['notes'] != null) Text(log['notes']),
                if (log['tags'] != null)
                  Wrap(
                    spacing: 4,
                    children: (log['tags'] as List)
                        .map((tag) => Chip(
                              label: Text(tag),
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                            ))
                        .toList(),
                  ),
              ],
            ),
            trailing: Text('Intensity: ${log['intensity']}'),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodDistributionChart() {
    final moodFrequency = Map<String, int>.from(_statistics!['mood_frequency']);
    final entries = moodFrequency.entries.toList();
    
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: entries.isEmpty ? 1 : entries.map((e) => e.value).reduce((a, b) => a > b ? a : b).toDouble() * 1.2,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value < 0 || value >= entries.length) return const Text('');
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    entries[value.toInt()].key,
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
            ),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: entries.asMap().entries.map((entry) {
          final index = entry.key;
          final mood = entry.value.key;
          final count = entry.value.value;
          
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: count.toDouble(),
                color: _getMoodColor(mood),
                width: 20,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  IconData _getMoodIcon(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
        return Icons.sentiment_very_satisfied;
      case 'good':
        return Icons.sentiment_satisfied;
      case 'neutral':
        return Icons.sentiment_neutral;
      case 'sad':
        return Icons.sentiment_dissatisfied;
      case 'anxious':
        return Icons.sentiment_very_dissatisfied;
      case 'fearful':
        return Icons.sentiment_very_dissatisfied;
      case 'excited':
        return Icons.mood;
      case 'angry':
        return Icons.mood_bad;
      case 'calm':
        return Icons.sentiment_satisfied;
      case 'pain':
        return Icons.healing;
      case 'boredom':
        return Icons.sentiment_neutral;
      case 'awe':
        return Icons.star;
      case 'confused':
        return Icons.psychology;
      case 'relief':
        return Icons.spa;
      case 'satisfied':
        return Icons.thumb_up;
      default:
        return Icons.mood;
    }
  }

  Color _getMoodColor(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
        return Colors.green;
      case 'good':
        return Colors.lightGreen;
      case 'neutral':
        return Colors.amber;
      case 'sad':
        return Colors.orange;
      case 'anxious':
        return Colors.red;
      case 'fearful':
        return Colors.deepPurple;
      case 'excited':
        return Colors.blue;
      case 'angry':
        return Colors.deepOrange;
      case 'calm':
        return Colors.teal;
      case 'pain':
        return Colors.red[900]!;
      case 'boredom':
        return Colors.grey;
      case 'awe':
        return Colors.indigo;
      case 'confused':
        return Colors.brown;
      case 'relief':
        return Colors.lightBlue;
      case 'satisfied':
        return Colors.green[700]!;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(String dateStr) {
    final date = DateTime.parse(dateStr);
    return '${date.month}/${date.day}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
} 