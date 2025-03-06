import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class SupabaseService {
  static const String supabaseUrl = 'https://gqsustjxzjzfntcsnvpk.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdxc3VzdGp4emp6Zm50Y3NudnBrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDEyMDg4NTgsImV4cCI6MjA1Njc4NDg1OH0.RCS_0fSVYnYVY2qr0Ow1__vBC4WRaVg_2SDatKREVHA';

  late final SupabaseClient _supabaseClient;
  bool _isInitialized = false;

  // Singleton pattern
  static final SupabaseService _instance = SupabaseService._internal();

  factory SupabaseService() {
    return _instance;
  }

  SupabaseService._internal();

  Future<void> initialize() async {
    if (_isInitialized) {
      print('Supabase is already initialized, skipping initialization');
      _supabaseClient = Supabase.instance.client;
      return;
    }
    
    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );
      _supabaseClient = Supabase.instance.client;
      _isInitialized = true;
      print('Supabase initialized successfully');
    } catch (e) {
      print('Error initializing Supabase: $e');
      rethrow;
    }
  }

  // Authentication methods
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required Map<String, dynamic> userData,
  }) async {
    try {
      print('Starting user registration process for: $email');

      // Set up redirect URL based on platform
      final redirectUrl = kIsWeb
          ? 'http://localhost:3000/verify' // For web
          : 'anxiease://verify'; // For mobile deep linking

      print('Using redirect URL for verification: $redirectUrl');

      // Proceed with signup in auth
      final AuthResponse response = await _supabaseClient.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: redirectUrl,
        data: {
          'full_name': userData['full_name'],
          'email': email,
          'role': 'patient', // Always set as patient for mobile app
        },
      );

      if (response.user == null) {
        throw Exception('Registration failed. Please try again.');
      }

      print('Auth user created successfully with ID: ${response.user!.id}');

      try {
        // Create user record in users table
        final timestamp = DateTime.now().toIso8601String();
        await _supabaseClient.from('users').upsert({
          'id': response.user!.id,
          'email': email,
          'password_hash': 'MANAGED_BY_SUPABASE_AUTH',
          'full_name': userData['full_name'],
          'role': 'patient',
          'created_at': timestamp,
          'updated_at': timestamp,
          'is_email_verified': false,
        });
        
        print('User record created successfully');
      } catch (e) {
        print('Error creating user record: $e');
        // Don't throw here, as the auth user is already created
        // Just log the error and continue
      }

      // Sign out after registration to ensure clean state
      await signOut();
      
      return response;
    } catch (e) {
      if (e.toString().contains('User already registered')) {
        throw Exception('Email already registered. Please login instead.');
      } else if (e.toString().contains('Invalid email')) {
        throw Exception('Please enter a valid email address.');
      } else if (e.toString().contains('Password should be at least 6 characters')) {
        throw Exception('Password must be at least 6 characters long.');
      } else if (e.toString().contains('429')) {
        throw Exception('Please wait a moment before trying again.');
      }
      print('Unexpected error during registration: ${e.toString()}');
      throw Exception('Registration failed. Please try again later.');
    }
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
    bool skipEmailVerification = false,
  }) async {
    try {
      // First verify this email exists in users table
      final user = await _supabaseClient
          .from('users')
          .select()
          .eq('email', email)
          .maybeSingle();

      if (user == null) {
        throw Exception('This account is not registered. Please sign up first.');
      }

      final response = await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Login failed');
      }

      // Check if email is verified
      if (!skipEmailVerification && response.user?.emailConfirmedAt == null) {
        throw Exception('Please verify your email before logging in. Check your inbox for the verification link.');
      }

      // Update email verification status only
      await _supabaseClient
          .from('users')
          .update({
            'updated_at': DateTime.now().toIso8601String(),
            'is_email_verified': response.user?.emailConfirmedAt != null,
          })
          .eq('id', response.user!.id);

      print('User email verification status: ${response.user?.emailConfirmedAt != null}');
      print('Updated user record with verification status');

      return response;
    } catch (e) {
      if (e.toString().contains('Invalid login credentials')) {
        throw Exception('Invalid email or password');
      }
      print('Error during sign in: ${e.toString()}');
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
          ? 'http://localhost:61375/reset-password' // For web development
          : 'anxiease://reset-password'; // For mobile deep linking
      
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

  Future<String> createPsychologistProfile({
    required String id,
    required String email,
    required String fullName,
    int? age,
  }) async {
    try {
      print('Creating psychologist profile for user ID: $id');
      
      // Create the psychologist record
      await _supabaseClient.from('psychologists').upsert({
        'id': id,
        'email': email,
        'full_name': fullName,
        'age': age,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'is_email_verified': false,
      });
      
      print('Psychologist profile created successfully');
      return id;
    } catch (e) {
      print('Error creating psychologist profile: $e');
      throw Exception('Failed to create psychologist profile: ${e.toString()}');
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
        .from('users')
        .select()
        .eq('id', user.id)
        .single();

    return response;
  }

  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _supabaseClient
        .from('users')
        .update({
          ...data,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', user.id);
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

  // Mood logs methods
  Future<void> saveMoodLog(Map<String, dynamic> log) async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _supabaseClient.from('mood_logs').insert({
      'user_id': user.id,
      ...log,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getMoodLogs() async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final response = await _supabaseClient
        .from('mood_logs')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  // Get psychologist profile
  Future<Map<String, dynamic>?> getPsychologistProfile([String? userId]) async {
    try {
      final user = userId ?? currentUser?.id;
      if (user == null) {
        print('getPsychologistProfile: No user ID available');
        return null;
      }

      print('Fetching psychologist profile for ID: $user');
      final response = await _supabaseClient
          .from('psychologists')
          .select()
          .eq('id', user)
          .single();
      
      print('Profile fetch response: $response');
      return response;
    } catch (e) {
      print('Error fetching psychologist profile: $e');
      return null;
    }
  }

  Future<AuthResponse> signUpPsychologist({
    required String email,
    required String password,
    required String fullName,
    int? age,
  }) async {
    try {
      print('Starting psychologist registration process for: $email');

      final existingPsychologist = await _supabaseClient
          .from('psychologists')
          .select()
          .eq('email', email)
          .maybeSingle();

      if (existingPsychologist != null) {
        throw Exception('Email already registered as a psychologist');
      }

      print('Creating auth user...');
      
      final AuthResponse response = await _supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'role': 'psychologist',
        },
      );

      if (response.user == null) {
        throw Exception('Registration failed. Please try again.');
      }

      print('Auth user created successfully with ID: ${response.user!.id}');

      try {
        print('Creating psychologist record...');
        final timestamp = DateTime.now().toIso8601String();
        
        await _supabaseClient.from('psychologists').insert({
          'id': response.user!.id,
          'email': email,
          'full_name': fullName,
          'age': age,
          'password_hash': 'MANAGED_BY_SUPABASE_AUTH',
          'created_at': timestamp,
          'updated_at': timestamp,
          'is_email_verified': false,
        });

        print('Psychologist record created successfully');
      } catch (profileError) {
        print('Error creating psychologist profile: $profileError');
        throw Exception('Failed to create psychologist profile. Please try again.');
      }

      await signOut();
      
      return response;
    } catch (e) {
      print('Error during psychologist registration: $e');
      if (e.toString().contains('User already registered')) {
        throw Exception('Email already registered. Please login instead.');
      }
      print('Unexpected error details: ${e.toString()}');
      rethrow;
    }
  }

  Future<AuthResponse> signInPsychologist({
    required String email,
    required String password,
  }) async {
    try {
      final psychologist = await _supabaseClient
          .from('psychologists')
          .select()
          .eq('email', email)
          .maybeSingle();

      if (psychologist == null) {
        throw Exception('This account is not registered as a psychologist');
      }

      final response = await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Login failed');
      }

      await _supabaseClient
          .from('psychologists')
          .update({
            'last_login': DateTime.now().toIso8601String(),
            'is_email_verified': true,
          })
          .eq('id', response.user!.id);

      return response;
    } catch (e) {
      if (e.toString().contains('Invalid login credentials')) {
        throw Exception('Invalid email or password');
      }
      rethrow;
    }
  }

  // Helper method to check if user is authenticated
  bool get isAuthenticated => _supabaseClient.auth.currentUser != null;

  // Get current user
  User? get currentUser => _supabaseClient.auth.currentUser;

  // Email verification methods
  Future<void> updateEmailVerificationStatus(String email) async {
    try {
      print('Updating email verification status for: $email');
      
      await _supabaseClient
          .from('users')
          .update({
            'is_email_verified': true,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('email', email);
      
      print('Email verification status updated successfully');
    } catch (e) {
      print('Error updating email verification status: $e');
      throw Exception('Failed to update email verification status');
    }
  }
}
