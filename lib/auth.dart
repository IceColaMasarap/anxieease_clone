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
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late bool isLogin;

  @override
  void initState() {
    super.initState();
    isLogin = widget.showLogin;
    
    // Show message if provided
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.message != null) {
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
    return isLogin
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
          );
  }
}
