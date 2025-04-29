import 'package:app_settings/app_settings.dart';

class SettingsHelper {
  // Open app notification settings
  static Future<void> openNotificationSettings() async {
    await AppSettings.openAppSettings(type: AppSettingsType.notification);
  }
  
  // Open app location settings
  static Future<void> openLocationSettings() async {
    await AppSettings.openAppSettings(type: AppSettingsType.location);
  }
  
  // Open app settings
  static Future<void> openAppSettings() async {
    await AppSettings.openAppSettings();
  }
}
