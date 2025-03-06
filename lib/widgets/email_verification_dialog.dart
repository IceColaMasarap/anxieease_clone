import 'package:flutter/material.dart';

class EmailVerificationDialog extends StatelessWidget {
  final String email;

  const EmailVerificationDialog({
    super.key,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.mark_email_read,
              size: 64,
              color: Color(0xFF2D9254), // Using your app's green color
            ),
            const SizedBox(height: 24),
            const Text(
              'Registration Successful',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Your account has been created with:\n$email',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'You can now proceed to login with your credentials.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                print('Go to Login button pressed');
                // Pop the dialog first
                Navigator.of(context).pop();
                // Then navigate to root route which should show login screen
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/',
                  (route) => false, // This removes all previous routes
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D9254),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Go to Login',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 