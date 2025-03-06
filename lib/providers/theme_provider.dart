import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;
  static const String _themeKey = 'isDarkMode';

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadThemeFromPrefs();
  }

  Future<void> _loadThemeFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_themeKey) ?? false;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, _isDarkMode);
    notifyListeners();
  }

  ThemeData get themeData {
    return _isDarkMode ? _darkTheme : _lightTheme;
  }

  static final ThemeData _lightTheme = ThemeData(
    useMaterial3: true,
    primaryColor: const Color(0xFF3AA772),
    scaffoldBackgroundColor: Colors.grey[50],
    colorScheme: ColorScheme.light(
      primary: const Color(0xFF3AA772),
      secondary: const Color(0xFF2D9254),
      surface: Colors.white,
      background: Colors.grey[50]!,
      error: const Color(0xFFFF6B6B),
    ),
    cardColor: Colors.white,
    dividerColor: Colors.grey[200],
    unselectedWidgetColor: Colors.grey[600],
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.grey[800],
      elevation: 0,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: const Color(0xFF3AA772),
      unselectedItemColor: Colors.grey[600],
    ),
    textTheme: TextTheme(
      titleLarge: TextStyle(color: Colors.grey[800]),
      bodyLarge: TextStyle(color: Colors.grey[800]),
      bodyMedium: TextStyle(color: Colors.grey[600]),
    ),
    brightness: Brightness.light,
  );

  static final ThemeData _darkTheme = ThemeData(
    useMaterial3: true,
    primaryColor: const Color(0xFF3AA772),
    scaffoldBackgroundColor: const Color(0xFF121212),
    colorScheme: ColorScheme.dark(
      primary: const Color(0xFF3AA772),
      secondary: const Color(0xFF2D9254),
      surface: const Color(0xFF1E1E1E),
      background: const Color(0xFF121212),
      error: const Color(0xFFFF6B6B),
    ),
    cardColor: const Color(0xFF1E1E1E),
    dividerColor: Colors.grey[800],
    unselectedWidgetColor: Colors.grey[400],
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1E1E1E),
      selectedItemColor: Color(0xFF3AA772),
      unselectedItemColor: Colors.grey,
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(color: Colors.white),
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white70),
    ),
    brightness: Brightness.dark,
  );
}
