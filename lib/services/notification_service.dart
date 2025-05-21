import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:app_settings/app_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String notificationPermissionKey =
      'notification_permission_status';
  static const String badgeCountKey = 'notification_badge_count';

  Future<void> initialize() async {
    // Initialize notification settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );

    // Initialize badge count from storage
    await _loadBadgeCount();
  }

  // Request notification permissions
  Future<bool> requestNotificationPermissions() async {
    // For Android 13+ (API level 33+), we need to use the permission_handler
    if (await Permission.notification.request().isGranted) {
      await _savePermissionStatus(true);
      return true;
    } else {
      await _savePermissionStatus(false);
      return false;
    }
  }

  // Check if notification permissions are granted
  Future<bool> checkNotificationPermissions() async {
    return await Permission.notification.isGranted;
  }

  // Open app notification settings
  Future<void> openNotificationSettings() async {
    await AppSettings.openAppSettings(type: AppSettingsType.notification);
  }

  // Save permission status
  Future<void> _savePermissionStatus(bool granted) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(notificationPermissionKey, granted);
  }

  // Get saved permission status from SharedPreferences
  Future<bool?> getSavedPermissionStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(notificationPermissionKey);
  }

  // Update badge count
  Future<void> updateBadgeCount(int count) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(badgeCountKey, count);

      // Update app icon badge number
      if (Platform.isIOS) {
        await flutterLocalNotificationsPlugin.initialize(
          InitializationSettings(
            android: const AndroidInitializationSettings('@mipmap/ic_launcher'),
            iOS: DarwinInitializationSettings(
              requestAlertPermission: false,
              requestBadgePermission: false,
              requestSoundPermission: false,
              onDidReceiveLocalNotification: null,
            ),
          ),
        );
      }

      debugPrint('Updated notification badge count to: $count');
    } catch (e) {
      debugPrint('Error updating badge count: $e');
    }
  }

  // Get current badge count
  Future<int> getBadgeCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(badgeCountKey) ?? 0;
  }

  // Load badge count from storage
  Future<void> _loadBadgeCount() async {
    final count = await getBadgeCount();
    await updateBadgeCount(count);
  }

  // Reset badge count
  Future<void> resetBadgeCount() async {
    await updateBadgeCount(0);
  }

  // Send a test notification
  Future<void> showTestNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'anxiease_channel',
      'AnxieEase Notifications',
      channelDescription: 'Notifications from AnxieEase app',
      importance: Importance.max,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails();

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      'AnxieEase',
      'Notifications are working correctly!',
      platformChannelSpecifics,
    );
  }
}
