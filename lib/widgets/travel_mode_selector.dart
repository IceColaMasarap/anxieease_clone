import 'package:flutter/material.dart';

class TravelModeSelector extends StatelessWidget {
  final String selectedMode;
  final Function(String) onModeSelected;

  const TravelModeSelector({
    Key? key,
    required this.selectedMode,
    required this.onModeSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 16, top: 8, bottom: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Select Travel Mode',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          _buildModeOption(
            context,
            'driving',
            'Driving',
            Icons.directions_car,
            Colors.blue,
          ),
          _buildModeOption(
            context,
            'walking',
            'Walking',
            Icons.directions_walk,
            Colors.green,
          ),
          _buildModeOption(
            context,
            'bicycling',
            'Bicycling',
            Icons.directions_bike,
            Colors.orange,
          ),
          _buildModeOption(
            context,
            'transit',
            'Transit',
            Icons.directions_transit,
            Colors.purple,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildModeOption(
    BuildContext context,
    String mode,
    String title,
    IconData icon,
    Color color,
  ) {
    final isSelected = selectedMode == mode;

    return InkWell(
      onTap: () {
        onModeSelected(mode);
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : null,
          border: Border(
            left: BorderSide(
              color: isSelected ? color : Colors.transparent,
              width: 4,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? color : Colors.grey[600],
              size: 28,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? color : Colors.black87,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: color,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
