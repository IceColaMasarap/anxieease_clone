import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:psychologist_app/providers/auth_provider.dart';
import 'package:psychologist_app/widgets/email_verification_dialog.dart';

class RegisterScreen extends StatefulWidget {
  // ... (existing code)
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // ... (existing code)

  @override
  Widget build(BuildContext context) {
    // ... (existing code)
  }

  Future<void> _handleRegistration() async {
    try {
      final email = await context.read<AuthProvider>().registerPsychologist(
        email: emailController.text,
        password: passwordController.text,
        fullName: fullNameController.text,
        age: int.tryParse(ageController.text),
      );

      if (!mounted) return;

      // Show the verification dialog
      await showDialog(
        context: context,
        barrierDismissible: false, // User must use the button to close
        builder: (context) => EmailVerificationDialog(email: email),
      );
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
} 