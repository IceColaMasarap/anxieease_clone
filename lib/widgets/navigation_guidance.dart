import 'package:flutter/material.dart';

class NavigationGuidance extends StatefulWidget {
  final Map<String, dynamic>? routeData;
  final VoidCallback onClose;
  final VoidCallback onChangeRoute;
  final String destination;
  final String travelMode;
  final double distance;
  final String duration;

  const NavigationGuidance({
    Key? key,
    required this.routeData,
    required this.onClose,
    required this.onChangeRoute,
    required this.destination,
    required this.travelMode,
    required this.distance,
    required this.duration,
  }) : super(key: key);

  @override
  State<NavigationGuidance> createState() => _NavigationGuidanceState();
}

class _NavigationGuidanceState extends State<NavigationGuidance>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  int _currentStepIndex = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _steps {
    // In a real app, these would come from the directions API
    if (widget.routeData == null ||
        widget.routeData!['routes'] == null ||
        widget.routeData!['routes'].isEmpty) {
      return [];
    }

    try {
      final legs = widget.routeData!['routes'][0]['legs'] as List;
      if (legs.isEmpty) return [];

      final steps = legs[0]['steps'] as List;
      // Map html_instructions to instruction for compatibility
      return steps.map((step) {
        final mapStep = Map<String, dynamic>.from(step);
        mapStep['instruction'] = mapStep['html_instructions'] ?? '';
        return mapStep;
      }).toList();
    } catch (e) {
      print('Error parsing steps: $e');
      return [];
    }
  }

  // For demo purposes if we don't have real steps
  List<Map<String, dynamic>> get _demoSteps {
    return [
      {
        'instruction': 'Head north on Main St',
        'distance': {'text': '0.2 km', 'value': 200},
        'duration': {'text': '1 min', 'value': 60},
        'maneuver': 'straight'
      },
      {
        'instruction': 'Turn right onto Oak Ave',
        'distance': {'text': '0.5 km', 'value': 500},
        'duration': {'text': '2 min', 'value': 120},
        'maneuver': 'turn-right'
      },
      {
        'instruction': 'Turn left onto Maple Blvd',
        'distance': {'text': '1.8 km', 'value': 1800},
        'duration': {'text': '4 min', 'value': 240},
        'maneuver': 'turn-left'
      },
      {
        'instruction': 'Continue onto Pine St',
        'distance': {'text': '0.7 km', 'value': 700},
        'duration': {'text': '2 min', 'value': 120},
        'maneuver': 'straight'
      },
      {
        'instruction': 'Your destination will be on the right',
        'distance': {'text': '50 m', 'value': 50},
        'duration': {'text': '1 min', 'value': 60},
        'maneuver': 'arrive'
      }
    ];
  }

  IconData _getManeuverIcon(String? maneuver) {
    if (maneuver == null) return Icons.arrow_upward;

    switch (maneuver) {
      case 'turn-right':
        return Icons.turn_right;
      case 'turn-left':
        return Icons.turn_left;
      case 'roundabout-right':
        return Icons.roundabout_right;
      case 'roundabout-left':
        return Icons.roundabout_left;
      case 'uturn-right':
      case 'uturn-left':
        return Icons.u_turn_right;
      case 'arrive':
        return Icons.location_on;
      case 'straight':
      default:
        return Icons.arrow_upward;
    }
  }

  void _nextStep() {
    final steps = _steps.isEmpty ? _demoSteps : _steps;
    if (_currentStepIndex < steps.length - 1) {
      setState(() {
        _currentStepIndex++;
      });
      _animationController.reset();
      _animationController.forward();
    }
  }

  void _previousStep() {
    if (_currentStepIndex > 0) {
      setState(() {
        _currentStepIndex--;
      });
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final steps = _steps.isEmpty ? _demoSteps : _steps;
    final currentStep = steps.isNotEmpty && _currentStepIndex < steps.length
        ? steps[_currentStepIndex]
        : null;

    final nextStep = (_currentStepIndex + 1 < steps.length)
        ? steps[_currentStepIndex + 1]
        : null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top navigation bar
            Container(
              color: Colors.teal[700],
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: widget.onClose,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_upward,
                          color: Colors.white, size: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'toward',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.destination,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 18,
                    child: Icon(Icons.mic, color: Colors.teal[700], size: 20),
                  ),
                ],
              ),
            ),

            // Current step instruction
            if (currentStep != null)
              Container(
                color: Colors.teal[800],
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    SizedBox(
                      width: 42,
                      child: Column(
                        children: [
                          FadeTransition(
                            opacity: _animationController,
                            child: Icon(
                              _getManeuverIcon(currentStep['maneuver']),
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            currentStep['distance']['text'],
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: FadeTransition(
                        opacity: _animationController,
                        child: Text(
                          currentStep['instruction'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Next step preview
            if (nextStep != null)
              Container(
                color: Colors.teal[600],
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    const Icon(Icons.subdirectory_arrow_right,
                        color: Colors.white, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Then ${nextStep['instruction']}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Text(
                      nextStep['distance']['text'],
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

            // Navigation buttons
            Container(
              color: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Close button
                  GestureDetector(
                    onTap: widget.onClose,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close,
                          color: Colors.white, size: 24),
                    ),
                  ),

                  // Speed indicator (simulated)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      '-- km/h',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),

                  // Navigation info
                  Column(
                    children: [
                      Text(
                        widget.duration,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '${widget.distance.toStringAsFixed(1)} km',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            ' • ${_formatArrivalTime()}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Audio button
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.volume_up,
                        color: Colors.white, size: 24),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatArrivalTime() {
    final now = DateTime.now();
    // Parse duration string to extract minutes
    // This is a simplification, in a real app you'd parse properly
    final durationMinutes = int.tryParse(
          widget.duration.replaceAll(RegExp(r'[^0-9]'), ''),
        ) ??
        0;

    final arrivalTime = now.add(Duration(minutes: durationMinutes));
    return '${_formatHour(arrivalTime.hour)}:${_formatMinute(arrivalTime.minute)}';
  }

  String _formatHour(int hour) {
    return hour.toString().padLeft(2, '0');
  }

  String _formatMinute(int minute) {
    return minute.toString().padLeft(2, '0');
  }
}
