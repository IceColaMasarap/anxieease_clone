import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth.dart';
import 'providers/theme_provider.dart';
import 'providers/auth_provider.dart';
import 'services/supabase_service.dart';
import 'login.dart';
import 'reset_password.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';

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
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late AppLinks _appLinks;
  final _navigatorKey = GlobalKey<NavigatorState>();

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
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
        );
      },
    );
  }
}
