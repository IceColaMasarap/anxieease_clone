import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class MetricsScreen extends StatefulWidget {
  const MetricsScreen({super.key});

  @override
  State<MetricsScreen> createState() => _MetricsScreenState();
}

class _MetricsScreenState extends State<MetricsScreen> {
  String selectedPeriod = 'Daily'; // Default selected period
  final List<String> periods = ['Daily', 'Weekly', 'Monthly'];

  // Sample data for different time periods
  final Map<String, List<FlSpot>> heartRateData = {
    'Daily': [
      FlSpot(0, 70.0), FlSpot(4, 75.0), FlSpot(8, 82.0),
      FlSpot(12, 82.0), FlSpot(16, 75.0), FlSpot(20, 70.0),
    ],
    'Weekly': [
      FlSpot(0, 72.0), FlSpot(1, 75.0), FlSpot(2, 80.0),
      FlSpot(3, 85.0), FlSpot(4, 82.0), FlSpot(5, 78.0),
      FlSpot(6, 75.0),
    ],
    'Monthly': [
      FlSpot(0, 73.0), FlSpot(5, 75.0), FlSpot(10, 78.0),
      FlSpot(15, 82.0), FlSpot(20, 80.0), FlSpot(25, 76.0),
      FlSpot(30, 74.0),
    ],
  };

  final Map<String, List<FlSpot>> temperatureData = {
    'Daily': [
      FlSpot(0, 36.5), FlSpot(4, 36.7), FlSpot(8, 36.9),
      FlSpot(12, 36.9), FlSpot(16, 36.7), FlSpot(20, 36.5),
    ],
    'Weekly': [
      FlSpot(0, 36.6), FlSpot(1, 36.7), FlSpot(2, 36.9),
      FlSpot(3, 37.0), FlSpot(4, 36.8), FlSpot(5, 36.7),
      FlSpot(6, 36.6),
    ],
    'Monthly': [
      FlSpot(0, 36.5), FlSpot(5, 36.7), FlSpot(10, 36.8),
      FlSpot(15, 37.0), FlSpot(20, 36.9), FlSpot(25, 36.7),
      FlSpot(30, 36.6),
    ],
  };

  // Labels for different time periods
  final Map<String, List<String>> timeLabels = {
    'Daily': ['12am', '4am', '8am', '12pm', '4pm', '8pm'],
    'Weekly': ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
    'Monthly': ['1', '5', '10', '15', '20', '25', '30'],
  };

  Map<String, dynamic> getChartProperties(String period) {
    switch (period) {
      case 'Daily':
        return {
          'minX': 0.0,
          'maxX': 22.0,
          'interval': 4.0,
        };
      case 'Weekly':
        return {
          'minX': 0.0,
          'maxX': 6.0,
          'interval': 1.0,
        };
      case 'Monthly':
        return {
          'minX': 0.0,
          'maxX': 30.0,
          'interval': 5.0,
        };
    }
    return {
      'minX': 0.0,
      'maxX': 6.0,
      'interval': 1.0,
    };
  }

  @override
  Widget build(BuildContext context) {
    final chartProps = getChartProperties(selectedPeriod);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Health Metrics',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Track your health data',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // Time period selector
            Container(
              height: 40,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: periods.map((period) {
                  final isSelected = period == selectedPeriod;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedPeriod = period;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF3AA772) : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            period,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.grey[600],
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 16),

            // Metrics Cards
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildMetricCard(
                    title: 'Heart Rate',
                    value: heartRateData[selectedPeriod]!.last.y,
                    data: heartRateData[selectedPeriod]!,
                    color: const Color(0xFFFF6B6B),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                    ),
                    unit: 'bpm',
                    minY: 60,
                    maxY: 100,
                    chartProps: chartProps,
                  ),
                  const SizedBox(height: 16),
                  _buildMetricCard(
                    title: 'Temperature',
                    value: temperatureData[selectedPeriod]!.last.y,
                    data: temperatureData[selectedPeriod]!,
                    color: const Color(0xFFFFA726),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFA726), Color(0xFFFFCC80)],
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                    ),
                    unit: '°C',
                    minY: 36,
                    maxY: 38,
                    chartProps: chartProps,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required double value,
    required List<FlSpot> data,
    required Color color,
    required Gradient gradient,
    required String unit,
    required double minY,
    required double maxY,
    required Map<String, dynamic> chartProps,
  }) {
    // Calculate statistics
    double average = data.map((spot) => spot.y).reduce((a, b) => a + b) / data.length;
    double maxValue = data.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
    double minValue = data.map((spot) => spot.y).reduce((a, b) => a < b ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C3E50),
                ),
              ),
              Text(
                'Avg: ${average.toStringAsFixed(1)} $unit',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey[200],
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: title == 'Temperature' ? 0.5 : 10,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Text(
                            value.toStringAsFixed(1),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: chartProps['interval'],
                      getTitlesWidget: (value, meta) {
                        final index = (value / chartProps['interval']).round();
                        final labels = timeLabels[selectedPeriod]!;
                        if (index >= 0 && index < labels.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              labels[index],
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: chartProps['minX'],
                maxX: chartProps['maxX'],
                minY: minY,
                maxY: maxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: data,
                    isCurved: true,
                    gradient: gradient,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: Colors.white,
                          strokeWidth: 2,
                          strokeColor: color,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          color.withOpacity(0.2),
                          color.withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Avg', average.toStringAsFixed(1), unit, color),
              _buildStatItem('Max', maxValue.toStringAsFixed(1), unit, color),
              _buildStatItem('Min', minValue.toStringAsFixed(1), unit, color),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, String unit, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$value $unit',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
