import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class SupabaseService {
  static const String supabaseUrl = 'https://juyzndfjrnewimsuuuvs.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imp1eXpuZGZqcm5ld2ltc3V1dXZzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDEwOTkwMzksImV4cCI6MjA1NjY3NTAzOX0.T6KiRrjjW3qrw1p5XByTAh4Us-aLOaBf9jaW00nUP-s';

  late final SupabaseClient _supabaseClient;

  // Singleton pattern
  static final SupabaseService _instance = SupabaseService._internal();

  factory SupabaseService() {
    return _instance;
  }

  SupabaseService._internal();

  Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
    _supabaseClient = Supabase.instance.client;
  }

  // Authentication methods
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required Map<String, dynamic> userData,
  }) async {
    try {
      // Proceed with signup
      final AuthResponse response = await _supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': userData['full_name'],
          'email': email,
        },
      );

      if (response.user == null) {
        throw Exception('Registration failed. Please try again.');
      }

      // Don't try to create profile here - it will be created after email verification
      // through a Supabase Database Function trigger

      return response;
    } catch (e) {
      if (e.toString().contains('User already registered')) {
        throw Exception('Email already registered. Please login instead.');
      } else if (e.toString().contains('Invalid email')) {
        throw Exception('Please enter a valid email address.');
      } else if (e
          .toString()
          .contains('Password should be at least 6 characters')) {
        throw Exception('Password must be at least 6 characters long.');
      } else if (e.toString().contains('429')) {
        throw Exception('Please wait a moment before trying again.');
      }
      throw Exception('Registration failed. Please try again later.');
    }
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Login failed');
      }

      if (response.user!.emailConfirmedAt == null) {
        throw Exception('Please verify your email before logging in');
      }

      return response;
    } catch (e) {
      if (e.toString().contains('Invalid login credentials')) {
        throw Exception('Invalid email or password');
      }
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _supabaseClient.auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    try {
      print('Attempting to send reset password email to: $email');
      
      // Use different redirect URLs for web and mobile
      final redirectUrl = kIsWeb
          ? 'http://localhost:61375/reset-password?email=$email' // Include email in the redirect URL
          : 'anxiease://reset-password?email=$email'; // Include email in the redirect URL
      
      print('Using redirect URL: $redirectUrl');

      await _supabaseClient.auth.resetPasswordForEmail(
        email,
        redirectTo: redirectUrl,
      );
      
      print('Reset password email sent successfully');
    } catch (e) {
      print('Error sending reset password email: $e');
      if (e.toString().contains('rate limit')) {
        throw Exception('Please wait a moment before requesting another reset link');
      }
      throw Exception('Failed to send reset email: ${e.toString()}');
    }
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      await _supabaseClient.auth.updateUser(
        UserAttributes(
          password: newPassword,
        ),
      );
    } catch (e) {
      print('Error updating password: $e');
      throw Exception('Failed to update password: ${e.toString()}');
    }
  }

  Future<void> recoverPassword(String token, String newPassword, {String? email}) async {
    try {
      print('Attempting to recover password with token: $token');
      if (email != null) {
        print('Email provided for recovery: $email');
      }
      
      final client = Supabase.instance.client;
      
      // Verify the OTP with the recovery token and email if available
      if (email != null) {
        print('Using email + token verification approach');
        final response = await client.auth.verifyOTP(
          email: email,
          token: token,
          type: OtpType.recovery,
        );
        
        print('OTP verification response: ${response.session != null ? 'Session established' : 'No session'}');
        
        if (response.session == null) {
          throw Exception('Failed to establish a session with the recovery token. Please ensure the link is valid and not expired.');
        }
      } else {
        print('Using token-only verification approach');
        // Try token-only approach as fallback
        final response = await client.auth.verifyOTP(
          token: token,
          type: OtpType.recovery,
        );
        
        print('Token-only OTP verification response: ${response.session != null ? 'Session established' : 'No session'}');
        
        if (response.session == null) {
          throw Exception('Failed to establish a session with the recovery token. The link may be invalid or expired.');
        }
      }
      
      // Now update the password
      print('Updating password after successful verification');
      await client.auth.updateUser(
        UserAttributes(
          password: newPassword,
        ),
      );
      
      print('Password updated successfully after recovery');
    } catch (e) {
      print('Error recovering password: $e');
      throw Exception('Failed to recover password: ${e.toString()}');
    }
  }

  // Profile methods
  Future<Map<String, dynamic>?> getUserProfile() async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) return null;

    final response = await _supabaseClient
        .from('profiles')
        .select()
        .eq('id', user.id)
        .single();

    return response;
  }

  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _supabaseClient.from('profiles').update({
      ...data,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', user.id);
  }

  // Anxiety records methods
  Future<void> saveAnxietyRecord(Map<String, dynamic> record) async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _supabaseClient.from('anxiety_records').insert({
      'user_id': user.id,
      ...record,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getAnxietyRecords() async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final response = await _supabaseClient
        .from('anxiety_records')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  // Helper method to check if user is authenticated
  bool get isAuthenticated => _supabaseClient.auth.currentUser != null;

  // Get current user
  User? get currentUser => _supabaseClient.auth.currentUser;
}
