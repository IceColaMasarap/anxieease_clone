import 'package:flutter/foundation.dart';

/// A simple logger utility for AnxieEase app
class Logger {
  static const String _tag = 'AnxieEase';
  
  /// Log an info message
  static void info(String message) {
    if (kDebugMode) {
      print('[$_tag] INFO: $message');
    }
  }
  
  /// Log an error message
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      if (error != null) {
        print('[$_tag] ERROR: $message\nError: $error');
        if (stackTrace != null) {
          print('StackTrace: $stackTrace');
        }
      } else {
        print('[$_tag] ERROR: $message');
      }
    }
  }
  
  /// Log a warning message
  static void warning(String message) {
    if (kDebugMode) {
      print('[$_tag] WARNING: $message');
    }
  }
  
  /// Log a debug message
  static void debug(String message) {
    if (kDebugMode) {
      print('[$_tag] DEBUG: $message');
    }
  }
}
