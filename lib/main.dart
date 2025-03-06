import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth.dart';
import 'providers/theme_provider.dart';
import 'providers/auth_provider.dart';
import 'services/supabase_service.dart';
import 'login.dart';
import 'reset_password.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';

// Import web dashboard main
import 'web_dashboard/web_main.dart' as web;
import 'web_dashboard/screens/auth/psychologist_login.dart';
import 'web_dashboard/screens/dashboard/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await SupabaseService().initialize();

  // If running on web, use the web dashboard components directly
  if (kIsWeb) {
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
        ],
        child: const WebDashboardApp(),
      ),
    );
    return;
  }

  // Otherwise, run the mobile app
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

// Web Dashboard App for web platform
class WebDashboardApp extends StatelessWidget {
  const WebDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, AuthProvider>(
      builder: (context, themeProvider, authProvider, child) {
        return MaterialApp(
          title: 'AnxieEase Psychologist Dashboard',
          theme: themeProvider.themeData,
          darkTheme: themeProvider.themeData,
          themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          debugShowCheckedModeBanner: false,
          home: authProvider.isPsychologist
              ? const DashboardScreen()
              : const PsychologistLoginScreen(),
        );
      },
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late AppLinks _appLinks;
  final _navigatorKey = GlobalKey<NavigatorState>();
  final _supabaseService = SupabaseService();

  @override
  void initState() {
    super.initState();
    _initAppLinks();
  }

  Future<void> _initAppLinks() async {
    _appLinks = AppLinks();

    // Check initial link if app was launched from dead state
    try {
      final uri = await _appLinks.getInitialAppLink();
      if (uri != null) {
        _handleAppLink(uri);
      }
    } catch (e) {
      print('Error getting initial app link: $e');
    }

    // Handle incoming links when app is in background or foreground
    _appLinks.uriLinkStream.listen((uri) {
      _handleAppLink(uri);
    }, onError: (err) {
      print('Error handling app links: $err');
    });
  }

  void _handleAppLink(Uri uri) {
    print('Handling deep link: $uri');
    print('URI path: ${uri.path}');
    print('URI query parameters: ${uri.queryParameters}');
    print('URI fragment: ${uri.fragment}');

    // Check for email verification
    if (uri.path == '/verify' || uri.path.contains('verify')) {
      print('Email verification path detected');
      String? token;
      String? email;
      
      // Check for token in query parameters
      if (uri.queryParameters.containsKey('token')) {
        token = uri.queryParameters['token'];
        print('Token parameter found: $token');
      }

      // Get email from parameters
      if (uri.queryParameters.containsKey('email')) {
        email = uri.queryParameters['email'];
        print('Email parameter found: $email');
      }
      
      // Check for type=signup_email in query parameters
      if (uri.queryParameters['type'] == 'signup_email') {
        print('Email verification link detected');

        // Update email verification status in database if email is available
        if (email != null) {
          _supabaseService.updateEmailVerificationStatus(email).then((_) {
            print('Updated email verification status for $email');
            // Navigate directly to login screen
            _navigatorKey.currentState?.pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const AuthScreen(
                  message: 'Email verified successfully! Please log in.',
                  showLogin: true,
                ),
              ),
              (route) => false,
            );
          }).catchError((e) {
            print('Error updating verification status: $e');
            // Still navigate to login even if update fails
            _navigatorKey.currentState?.pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const AuthScreen(
                  message: 'Please try logging in with your credentials.',
                  showLogin: true,
                ),
              ),
              (route) => false,
            );
          });
        } else {
          // If no email is available, still navigate to login
          _navigatorKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const AuthScreen(
                message: 'Please try logging in with your credentials.',
                showLogin: true,
              ),
            ),
            (route) => false,
          );
        }
        return;
      }
    }

    // Check for reset password path
    if (uri.path == '/reset-password') {
      print('Reset password path detected');
      
      String? token;
      String? email;
      
      // Check for code parameter (Supabase recovery flow)
      if (uri.queryParameters.containsKey('code')) {
        token = uri.queryParameters['code'];
        print('Code parameter found: $token');
      }
      
      // Check for token parameter (alternative approach)
      if (token == null && uri.queryParameters.containsKey('token')) {
        token = uri.queryParameters['token'];
        print('Token parameter found: $token');
      }
      
      // Check for token in fragment (another alternative)
      if (token == null && uri.fragment.isNotEmpty) {
        final fragmentParams = Uri.splitQueryString(uri.fragment);
        if (fragmentParams.containsKey('token')) {
          token = fragmentParams['token'];
          print('Token found in fragment: $token');
        }
      }
      
      // Extract email from query parameters
      if (uri.queryParameters.containsKey('email')) {
        email = uri.queryParameters['email'];
        print('Email parameter found: $email');
      }
      
      // If we have a token, navigate to reset password screen
      if (token != null) {
        print('Navigating to reset password screen with token');
        _navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => ResetPasswordScreen(token: token, email: email),
          ),
          (route) => false,
        );
      } else {
        print('No token found in reset password link');
        _navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => ResetPasswordScreen(
              errorMessage: 'Invalid reset password link. Please request a new one.',
            ),
          ),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, AuthProvider>(
      builder: (context, themeProvider, authProvider, child) {
        return MaterialApp(
          navigatorKey: _navigatorKey,
          debugShowCheckedModeBanner: false,
          initialRoute: '/',
          routes: {
            '/': (context) => AuthScreen(),
            '/reset-password': (context) => ResetPasswordScreen(),
          },
          onGenerateRoute: (settings) {
            // Handle dynamic routes
            if (settings.name != null && settings.name!.startsWith('/reset-password')) {
              // Extract token from route if present
              final uri = Uri.parse(settings.name!);
              String? token;
              String? email;
              
              // Check query parameters
              if (uri.queryParameters.containsKey('code')) {
                token = uri.queryParameters['code'];
                email = uri.queryParameters['email'];
              } else if (uri.queryParameters.containsKey('token')) {
                token = uri.queryParameters['token'];
                email = uri.queryParameters['email'];
              }
              
              return MaterialPageRoute(
                builder: (context) => ResetPasswordScreen(token: token, email: email),
              );
            }
            return null;
          },
          theme: themeProvider.themeData,
          darkTheme: themeProvider.themeData,
          themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
        );
      },
    );
  }
}
