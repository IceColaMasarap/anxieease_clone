import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'homepage.dart';
import 'providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  final VoidCallback onSwitch;

  const RegisterScreen({super.key, required this.onSwitch});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  bool agreeToTerms = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  void _submit(BuildContext context) async {
    if (!agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the Terms & Privacy'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your full name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password must be at least 6 characters long'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      await authProvider.signUp(
        email: emailController.text.trim(),
        password: passwordController.text,
        fullName: nameController.text.trim(),
      );

      // Show success dialog
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Check Your Email'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your account has been created successfully. Please check your email for a verification link.',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                Text(
                  'Verification email sent to: ${emailController.text.trim()}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'After verifying your email, you can log in to your account.',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  widget.onSwitch(); // Switch to login screen
                },
                child: const Text('Go to Login'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      String errorMessage = e.toString();

      // Clean up the error message
      if (errorMessage.contains('Exception: ')) {
        errorMessage = errorMessage.replaceAll('Exception: ', '');
      }

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 320,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF00634A), Color(0xFF3EAD7A)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(50),
                      bottomRight: Radius.circular(50),
                    ),
                  ),
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Let's",
                          style: TextStyle(
                              fontSize: 37,
                              color: Colors.white,
                              fontWeight: FontWeight.w300,
                              letterSpacing: 3.0)),
                      Text("Create your",
                          style: TextStyle(
                              fontSize: 45,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 4.0)),
                      Text("Account",
                          style: TextStyle(
                              fontSize: 45,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 4.0)),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    children: [
                      _buildInputField(nameController, "Full Name"),
                      const SizedBox(height: 15),
                      _buildInputField(emailController, "Email"),
                      const SizedBox(height: 15),
                      _buildInputField(passwordController, "Password"),
                      const SizedBox(height: 15),
                      _buildInputField(
                          confirmPasswordController, "Confirm Password"),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Checkbox(
                            value: agreeToTerms,
                            onChanged: (bool? value) {
                              setState(() {
                                agreeToTerms = value ?? false;
                              });
                            },
                            activeColor: Colors.green,
                          ),
                          const Expanded(
                            child: Text(
                              "I agree to the Terms & Privacy",
                              style: TextStyle(color: Colors.black54),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: widget.onSwitch,
                        child: const Text(
                          "Already have an account? Sign in",
                          style: TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: authProvider.isLoading
                            ? null
                            : () => _submit(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3AA772),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 100, vertical: 15),
                          elevation: 3,
                        ),
                        child: authProvider.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                "Sign Up",
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (authProvider.isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String label,
      {bool obscureText = false}) {
    bool isPassword = label.toLowerCase().contains('password');
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword
            ? (label == "Password" ? _obscurePassword : _obscureConfirmPassword)
            : false,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF00634A)),
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    label == "Password"
                        ? (_obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility)
                        : (_obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility),
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      if (label == "Password") {
                        _obscurePassword = !_obscurePassword;
                      } else {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      }
                    });
                  },
                )
              : null,
        ),
      ),
    );
  }
}
