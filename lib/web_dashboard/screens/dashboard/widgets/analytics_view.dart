import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsView extends StatelessWidget {
  const AnalyticsView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overview Cards
          Row(
            children: [
              _buildOverviewCard(
                context,
                'Total Patients',
                '24',
                Icons.people,
                Colors.blue,
                '+3 this month',
              ),
              const SizedBox(width: 16),
              _buildOverviewCard(
                context,
                'Average Sessions',
                '12.5',
                Icons.calendar_month,
                Colors.green,
                'Per patient/month',
              ),
              const SizedBox(width: 16),
              _buildOverviewCard(
                context,
                'Anxiety Reduction',
                '42%',
                Icons.trending_down,
                Colors.orange,
                'Average improvement',
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Charts Section
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Patient Growth Chart
              Expanded(
                flex: 2,
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Patient Growth',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 300,
                          child: LineChart(
                            LineChartData(
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                              ),
                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 40,
                                  ),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
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
                                  spots: List.generate(
                                    6,
                                    (i) => FlSpot(i.toDouble(), (i * 4 + 10).toDouble()),
                                  ),
                                  isCurved: true,
                                  color: Theme.of(context).primaryColor,
                                  barWidth: 3,
                                  dotData: FlDotData(show: true),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    color: Theme.of(context).primaryColor.withOpacity(0.1),
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
              ),
              const SizedBox(width: 16),
              // Statistics Cards
              Expanded(
                child: Column(
                  children: [
                    _buildStatCard(
                      context,
                      'Most Common Issues',
                      Column(
                        children: [
                          _buildProgressBar(context, 'Anxiety', 0.8, Colors.red),
                          const SizedBox(height: 12),
                          _buildProgressBar(context, 'Depression', 0.6, Colors.blue),
                          const SizedBox(height: 12),
                          _buildProgressBar(context, 'Stress', 0.5, Colors.orange),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildStatCard(
                      context,
                      'Session Distribution',
                      Column(
                        children: [
                          _buildProgressBar(context, 'Online', 0.7, Colors.green),
                          const SizedBox(height: 12),
                          _buildProgressBar(context, 'In-Person', 0.3, Colors.purple),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Expanded(
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    Widget content,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).dividerColor,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(
    BuildContext context,
    String label,
    double value,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text('${(value * 100).toInt()}%'),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: value,
          backgroundColor: color.withOpacity(0.1),
          valueColor: AlwaysStoppedAnimation<Color>(color),
          borderRadius: BorderRadius.circular(4),
          minHeight: 8,
        ),
      ],
    );
  }
} 