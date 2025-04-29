import 'package:flutter/material.dart';

class NotificationPermissionDialog extends StatelessWidget {
  final VoidCallback onAllow;
  final VoidCallback onDeny;

  const NotificationPermissionDialog({
    Key? key,
    required this.onAllow,
    required this.onDeny,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Allow Notifications'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Allow AnxieEase to send you notifications?',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 12),
          Text(
            'Notifications help you stay informed about your anxiety levels and remind you to practice breathing exercises.',
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onDeny,
          child: const Text(
            "Don't Allow",
            style: TextStyle(color: Colors.grey),
          ),
        ),
        ElevatedButton(
          onPressed: onAllow,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2D9254), // Match app's green color
          ),
          child: const Text(
            'Allow',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class NotificationSettingsRedirectDialog extends StatelessWidget {
  final VoidCallback onOpenSettings;
  final VoidCallback onCancel;

  const NotificationSettingsRedirectDialog({
    Key? key,
    required this.onOpenSettings,
    required this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enable Notifications'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notifications are currently disabled',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Text(
            'To receive important updates about your anxiety levels and breathing exercise reminders, please enable notifications in your device settings.',
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: const Text('Not Now'),
        ),
        ElevatedButton(
          onPressed: onOpenSettings,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2D9254), // Match app's green color
          ),
          child: const Text(
            'Open Settings',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
