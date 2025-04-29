import 'package:flutter/material.dart';
import 'services/notification_service.dart';
import 'widgets/notification_permission_dialog.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Initialize notification service
    await _notificationService.initialize();

    // Wait for splash animation
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    // Check if we've already asked for notification permissions
    final permissionStatus =
        await _notificationService.getSavedPermissionStatus();

    if (permissionStatus == null) {
      // First time launch - show notification permission dialog
      _showNotificationPermissionDialog();
    } else if (permissionStatus == false) {
      // Permission was previously denied - check if it's still denied
      final currentStatus =
          await _notificationService.checkNotificationPermissions();
      if (!currentStatus) {
        // Still denied - show settings redirect dialog
        _showNotificationSettingsRedirectDialog();
      } else {
        // Permission is now granted - proceed to auth screen
        _navigateToAuthScreen();
      }
    } else {
      // Permission was previously granted - proceed to auth screen
      _navigateToAuthScreen();
    }
  }

  void _showNotificationPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => NotificationPermissionDialog(
        onAllow: () async {
          Navigator.of(context).pop();
          final granted =
              await _notificationService.requestNotificationPermissions();
          if (granted) {
            // Send a test notification to confirm it works
            await _notificationService.showTestNotification();
          }
          _navigateToAuthScreen();
        },
        onDeny: () {
          Navigator.of(context).pop();
          _navigateToAuthScreen();
        },
      ),
    );
  }

  void _showNotificationSettingsRedirectDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => NotificationSettingsRedirectDialog(
        onOpenSettings: () async {
          Navigator.of(context).pop();
          await _notificationService.openNotificationSettings();
          _navigateToAuthScreen();
        },
        onCancel: () {
          Navigator.of(context).pop();
          _navigateToAuthScreen();
        },
      ),
    );
  }

  void _navigateToAuthScreen() {
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2D9254), // Match login page dark green
              Color(0xFF00382A), // Match login page deep green
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/greenribbon.png',
                width: 120,
                height: 120,
              ),
              const SizedBox(height: 24),
              const Text(
                'AnxieEase',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
