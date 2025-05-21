import 'package:flutter/material.dart';
import 'login.dart';
import 'register.dart';

class AuthScreen extends StatefulWidget {
  final String? message;
  final bool showLogin;

  const AuthScreen({
    super.key,
    this.message,
    this.showLogin = true,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late bool isLogin;

  @override
  void initState() {
    super.initState();
    isLogin = widget.showLogin;

    // Show message if provided
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.message != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.message!),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // WillPopScope intercepts the back button press
    return WillPopScope(
      onWillPop: () async {
        // If we're in the registration screen
        if (!isLogin) {
          // Switch to login screen instead of exiting the app
          setState(() {
            isLogin = true;
          });
          return false; // Prevent default back button behavior
        }
        // In login screen, allow normal back button behavior
        return true;
      },
      child: isLogin
          ? LoginScreen(
              onSwitch: () {
                setState(() {
                  isLogin = false;
                });
              },
            )
          : RegisterScreen(
              onSwitch: () {
                setState(() {
                  isLogin = true;
                });
              },
            ),
    );
  }
}
