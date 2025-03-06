import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class MetricsOverview extends StatefulWidget {
  final String patientId;

  const MetricsOverview({
    super.key,
    required this.patientId,
  });

  @override
  State<MetricsOverview> createState() => _MetricsOverviewState();
}

class _MetricsOverviewState extends State<MetricsOverview> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _metrics = [];
  List<Map<String, dynamic>> _moodLogs = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // TODO: Replace with real API calls
      _metrics = List.generate(
        10,
        (i) => {
          'attack_frequency': (i % 3 == 0 ? 2 : i % 2 == 0 ? 1 : 0), // 0-2 attacks per day
          'created_at': DateTime.now().subtract(Duration(days: i)).toIso8601String(),
        },
      );

      _moodLogs = List.generate(
        5,
        (i) => {
          'mood': ['happy', 'good', 'neutral', 'sad', 'anxious'][i],
          'notes': 'Sample mood log ${i + 1}',
          'created_at': DateTime.now().subtract(Duration(days: i)).toIso8601String(),
        },
      );
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Cards
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  title: 'Average Attacks',
                  value: _calculateAverageAttacks().toStringAsFixed(1),
                  subtitle: 'Per Day',
                  icon: Icons.warning_rounded,
                  iconColor: Colors.red,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  title: 'Total Attacks',
                  value: _calculateTotalAttacks().toString(),
                  subtitle: 'Last 7 Days',
                  icon: Icons.analytics_rounded,
                  iconColor: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  title: 'Mood Logs',
                  value: _moodLogs.length.toString(),
                  subtitle: 'Total Records',
                  icon: Icons.mood_rounded,
                  iconColor: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Attack Frequency Chart
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Attack Frequency Over Time',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 300,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(show: false),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                return Text(value.toInt().toString());
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final date = DateTime.now().subtract(
                                  Duration(days: (_metrics.length - 1 - value.toInt())),
                                );
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text('${date.month}/${date.day}'),
                                );
                              },
                              reservedSize: 30,
                            ),
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
                            spots: _getAttackSpots(),
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
                        minY: 0,
                        maxY: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Recent Mood Logs
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recent Mood Logs',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.refresh),
                        label: const Text('Refresh'),
                        onPressed: _loadData,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _moodLogs.length,
                    itemBuilder: (context, index) {
                      final log = _moodLogs[index];
                      return ListTile(
                        leading: Icon(
                          _getMoodIcon(log['mood']),
                          color: _getMoodColor(log['mood']),
                        ),
                        title: Text(log['mood']),
                        subtitle: Text(log['notes']),
                        trailing: Text(
                          _formatDate(log['created_at']),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _getAttackSpots() {
    return List.generate(_metrics.length, (index) {
      return FlSpot(
        index.toDouble(),
        _metrics[index]['attack_frequency'].toDouble(),
      );
    });
  }

  double _calculateAverageAttacks() {
    if (_metrics.isEmpty) return 0;
    final sum = _metrics.fold<int>(
      0,
      (sum, record) => sum + record['attack_frequency'] as int,
    );
    return sum / _metrics.length;
  }

  int _calculateTotalAttacks() {
    return _metrics
        .where((record) {
          final date = DateTime.parse(record['created_at']);
          return date.isAfter(DateTime.now().subtract(const Duration(days: 7)));
        })
        .fold<int>(
          0,
          (sum, record) => sum + record['attack_frequency'] as int,
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
      default:
        return Colors.grey;
    }
  }

  String _formatDate(String dateStr) {
    final date = DateTime.parse(dateStr);
    return '${date.month}/${date.day} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
} 