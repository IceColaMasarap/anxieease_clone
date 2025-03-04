import 'package:flutter/material.dart';
import 'login.dart';
import 'register.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true; // Toggles between Login & Register

  @override
  Widget build(BuildContext context) {
    print('AuthScreen build - isLogin: $isLogin');
    return Scaffold(
      body: isLogin
          ? LoginScreen(onSwitch: () {
              print('Switching to Register Screen');
              setState(() {
                isLogin = false;
                print('State updated - isLogin is now: $isLogin');
              });
            })
          : RegisterScreen(onSwitch: () {
              print('Switching to Login Screen');
              setState(() {
                isLogin = true;
                print('State updated - isLogin is now: $isLogin');
              });
            }),
    );
  }
}
