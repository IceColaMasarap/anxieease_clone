import 'package:flutter/material.dart';

class PatientList extends StatelessWidget {
  final List<Map<String, dynamic>> patients;
  final String? selectedPatientId;
  final Function(String) onPatientSelected;

  const PatientList({
    super.key,
    required this.patients,
    required this.selectedPatientId,
    required this.onPatientSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header with search
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Patients',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search patients...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Patient count and filters
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${patients.length} Patients',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextButton.icon(
                icon: const Icon(Icons.filter_list, size: 20),
                label: const Text('Filter'),
                onPressed: () {},
              ),
            ],
          ),
        ),

        const Divider(height: 1),

        // Patient List
        Expanded(
          child: ListView.builder(
            itemCount: patients.length,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemBuilder: (context, index) {
              final patient = patients[index];
              final isSelected = patient['id'] == selectedPatientId;
              final lastActive = _formatDate(patient['last_active']);

              return Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).primaryColor.withOpacity(0.1)
                      : null,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  onTap: () => onPatientSelected(patient['id']),
                  selected: isSelected,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  leading: CircleAvatar(
                    backgroundColor: isSelected
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).primaryColor.withOpacity(0.2),
                    child: Text(
                      patient['full_name']?.substring(0, 1).toUpperCase() ?? '?',
                      style: TextStyle(
                        color: isSelected ? Colors.white : Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    patient['full_name'] ?? 'Unknown',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Last active: $lastActive',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).disabledColor,
                  ),
                ),
              );
            },
          ),
        ),

        // Add Patient Button
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add),
            label: const Text('Add Patient'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'Never';
    final date = DateTime.parse(dateStr);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    }
    return '${date.day}/${date.month}/${date.year}';
  }
} 