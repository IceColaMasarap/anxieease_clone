import 'package:flutter/material.dart';

class PatientDetails extends StatelessWidget {
  final String patientId;
  final Map<String, dynamic> patientData;

  const PatientDetails({
    super.key,
    required this.patientId,
    required this.patientData,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Patient Info Header
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  child: Text(
                    patientData['full_name']?.substring(0, 1).toUpperCase() ?? '?',
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patientData['full_name'] ?? 'Unknown',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Email: ${patientData['email'] ?? 'N/A'}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            const Center(
              child: Text(
                'Patient management features coming soon',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 