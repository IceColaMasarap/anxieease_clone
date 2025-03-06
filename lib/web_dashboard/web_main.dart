import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../services/supabase_service.dart';
import 'screens/auth/psychologist_login.dart';
import 'screens/dashboard/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await SupabaseService().initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const WebDashboardApp(),
    ),
  );
}

class WebDashboardApp extends StatelessWidget {
  const WebDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, AuthProvider>(
      builder: (context, themeProvider, authProvider, child) {
        return MaterialApp(
          title: 'AnxieEase - Psychologist Portal',
          debugShowCheckedModeBanner: false,
          theme: themeProvider.themeData,
          darkTheme: themeProvider.themeData,
          themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: authProvider.isPsychologist
              ? const DashboardScreen()
              : const PsychologistLoginScreen(),
          builder: (context, child) {
            return Banner(
              message: "Psychologist Portal",
              location: BannerLocation.topEnd,
              color: Colors.green,
              child: child!,
            );
          },
        );
      },
    );
  }
} 