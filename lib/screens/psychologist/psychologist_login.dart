import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'dashboard_screen.dart';

class PsychologistLoginScreen extends StatefulWidget {
  final VoidCallback onSwitchToPatient;

  const PsychologistLoginScreen({
    super.key,
    required this.onSwitchToPatient,
  });

  @override
  State<PsychologistLoginScreen> createState() => _PsychologistLoginScreenState();
}

class _PsychologistLoginScreenState extends State<PsychologistLoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both email and password'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      await authProvider.signInAsPsychologist(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (!mounted) return;
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PsychologistDashboard()),
      );
    } catch (e) {
      if (!mounted) return;
      
      String errorMessage;
      if (e.toString().contains('Invalid login credentials')) {
        errorMessage = 'Incorrect email or password. Please try again.';
      } else if (e.toString().contains('not a psychologist')) {
        errorMessage = 'This account is not registered as a psychologist.';
      } else if (e.toString().contains('verify your email')) {
        errorMessage = 'Please verify your email before logging in.';
      } else {
        errorMessage = 'Login failed. Please try again.';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          duration: const Duration(seconds: 4),
          backgroundColor: Colors.red,
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
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2D9254), Color(0xFF00382A)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  
                  Container(
                    height: 130,
                    width: 130,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset(
                        'assets/images/greenribbon.png',
                        height: 80,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                  
                  const Text(
                    'Psychologist Portal',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                  
                  const SizedBox(height: 10),
                  
                  Text(
                    'Sign in to access your dashboard',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.8),
                      letterSpacing: 0.5,
                    ),
                  ),

                  const SizedBox(height: 48),

                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Email',
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  TextField(
                    controller: passwordController,
                    obscureText: _obscurePassword,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Password',
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                      prefixIcon: Icon(
                        Icons.lock_outline,
                        color: Colors.white.withOpacity(0.7),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: Colors.white.withOpacity(0.7),
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: authProvider.isLoading ? null : () => _submit(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF3AA772),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: authProvider.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Color(0xFF3AA772),
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Log In',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  TextButton(
                    onPressed: widget.onSwitchToPatient,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      "Patient Login",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 