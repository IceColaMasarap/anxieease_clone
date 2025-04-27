import 'package:flutter/material.dart';

class ClinicDetailsView extends StatelessWidget {
  final Map<String, dynamic> clinic;
  final Function() onGetDirections;
  final Function() onClose;
  final String? routeDistance;
  final String? routeDuration;
  final String travelMode;

  const ClinicDetailsView({
    Key? key,
    required this.clinic,
    required this.onGetDirections,
    required this.onClose,
    this.routeDistance,
    this.routeDuration,
    required this.travelMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isSample = clinic['isSample'] == true;
    final hasRoute = routeDistance != null && routeDuration != null;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle bar
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),

          // Clinic header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSample ? Colors.blue[50] : Colors.red[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isSample ? Icons.psychology : Icons.local_hospital,
                    color: isSample ? Colors.blue[700] : Colors.red[700],
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        clinic['name'],
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        clinic['vicinity'] ?? 'Address not available',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                      if (clinic['rating'] != null) ...[
                        const SizedBox(height: 8),
                        _buildRatingBar(context, clinic['rating']),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onClose,
                ),
              ],
            ),
          ),

          const Divider(),

          // Route info (if we have it)
          if (hasRoute)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    _getTravelModeIcon(),
                    color: primaryColor,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$routeDuration (${_formatTravelMode(travelMode)})',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: primaryColor,
                                  ),
                        ),
                        Text(
                          '$routeDistance • ${_estimateArrivalTime(routeDuration)}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Services / Types
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Services',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _getClinicServices().map((service) {
                    return Chip(
                      label: Text(service),
                      backgroundColor: Colors.grey[100],
                      labelStyle: const TextStyle(
                        fontSize: 12,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          // Hours
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hours',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      _getBusinessHours(),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '• Open now',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Contact
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Contact',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      _getPhoneNumber(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: primaryColor,
                          ),
                    ),
                  ],
                ),
                if (_getWebsite().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.language, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        _getWebsite(),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: primaryColor,
                            ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.phone),
                    label: const Text('Call'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primaryColor,
                      side: BorderSide(color: primaryColor),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onGetDirections,
                    icon: const Icon(Icons.directions),
                    label: const Text('Directions'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBar(BuildContext context, dynamic rating) {
    final double ratingValue =
        rating is int ? rating.toDouble() : (rating as double);
    return Row(
      children: [
        ...List.generate(5, (index) {
          return Icon(
            index < ratingValue.floor()
                ? Icons.star
                : (index < ratingValue ? Icons.star_half : Icons.star_border),
            color: Colors.amber,
            size: 16,
          );
        }),
        const SizedBox(width: 4),
        Text(
          ratingValue.toStringAsFixed(1),
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _formatTravelMode(String mode) {
    switch (mode.toLowerCase()) {
      case 'walking':
        return 'walking';
      case 'bicycling':
        return 'bicycling';
      case 'transit':
        return 'transit';
      case 'driving':
      default:
        return 'driving';
    }
  }

  IconData _getTravelModeIcon() {
    switch (travelMode.toLowerCase()) {
      case 'walking':
        return Icons.directions_walk;
      case 'bicycling':
        return Icons.directions_bike;
      case 'transit':
        return Icons.directions_transit;
      case 'driving':
      default:
        return Icons.directions_car;
    }
  }

  String _estimateArrivalTime(String? duration) {
    if (duration == null) return 'Unknown arrival time';

    final now = DateTime.now();
    // Parse duration string to extract minutes (simplistic approach)
    final durationText = duration.toString();
    int minutes = 0;

    // Try to extract minutes
    RegExp minutesRegex = RegExp(r'(\d+)\s*min');
    final minutesMatch = minutesRegex.firstMatch(durationText);
    if (minutesMatch != null && minutesMatch.groupCount >= 1) {
      minutes += int.tryParse(minutesMatch.group(1) ?? '0') ?? 0;
    }

    // Try to extract hours
    RegExp hoursRegex = RegExp(r'(\d+)\s*hour');
    final hoursMatch = hoursRegex.firstMatch(durationText);
    if (hoursMatch != null && hoursMatch.groupCount >= 1) {
      minutes += (int.tryParse(hoursMatch.group(1) ?? '0') ?? 0) * 60;
    }

    final arrivalTime = now.add(Duration(minutes: minutes));
    final hour = arrivalTime.hour;
    final minute = arrivalTime.minute;

    return 'Arrive by ${hour > 12 ? hour - 12 : hour}:${minute.toString().padLeft(2, '0')} ${hour >= 12 ? 'PM' : 'AM'}';
  }

  List<String> _getClinicServices() {
    // Use types from the API if available
    if (clinic['types'] != null) {
      final types = List<String>.from(clinic['types']);
      // Format the types for better display
      return types.map((type) {
        // Convert snake_case to Title Case
        return type.split('_').map((word) {
          if (word.isEmpty) return '';
          return word[0].toUpperCase() + word.substring(1);
        }).join(' ');
      }).toList();
    }

    // Default services if no types are provided
    return [
      'General Medicine',
      'Emergency Care',
      'Pharmacy',
      'Laboratory Services',
    ];
  }

  String _getBusinessHours() {
    // In a real app, this would come from the API
    return 'Mon-Fri 8 AM - 6 PM, Sat 9 AM - 2 PM';
  }

  String _getPhoneNumber() {
    // In a real app, this would come from the API
    return '+1 (555) 123-4567';
  }

  String _getWebsite() {
    // In a real app, this would come from the API
    final isSample = clinic['isSample'] == true;
    if (isSample) {
      return 'www.anxieease-clinic.example.com';
    }
    return '';
  }
}
