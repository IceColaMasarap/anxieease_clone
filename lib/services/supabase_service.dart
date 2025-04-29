import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../utils/logger.dart';

class SupabaseService {
  static const String supabaseUrl = 'https://gqsustjxzjzfntcsnvpk.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdxc3VzdGp4emp6Zm50Y3NudnBrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDEyMDg4NTgsImV4cCI6MjA1Njc4NDg1OH0.RCS_0fSVYnYVY2qr0Ow1__vBC4WRaVg_2SDatKREVHA';

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
      const redirectUrl = kIsWeb
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
      } else if (e
          .toString()
          .contains('Password should be at least 6 characters')) {
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
        throw Exception(
            'This account is not registered. Please sign up first.');
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
        throw Exception(
            'Please verify your email before logging in. Check your inbox for the verification link.');
      }

      // Update email verification status only
      await _supabaseClient.from('users').update({
        'updated_at': DateTime.now().toIso8601String(),
        'is_email_verified': response.user?.emailConfirmedAt != null,
      }).eq('id', response.user!.id);

      Logger.info(
          'User email verification status: ${response.user?.emailConfirmedAt != null}');
      Logger.info('Updated user record with verification status');

      return response;
    } catch (e) {
      if (e.toString().contains('Invalid login credentials')) {
        Logger.error('Invalid login credentials', e);
        throw Exception('Invalid email or password');
      }
      Logger.error('Error during sign in', e);
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
      const redirectUrl = kIsWeb
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
        throw Exception(
            'Please wait a moment before requesting another reset link');
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

  // Get user profile
  Future<Map<String, dynamic>?> getUserProfile([String? userId]) async {
    final currentUser = _supabaseClient.auth.currentUser;
    if (currentUser == null) {
      print('getUserProfile: No user ID available');
      return null;
    }

    final user = userId ?? currentUser.id;
    print('Fetching user profile for ID: $user');

    try {
      final response = await _supabaseClient
          .from('users')
          .select()
          .eq('id', user)
          .maybeSingle();
      return response;
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }

  Future<void> recoverPassword(String token, String newPassword,
      {String? email}) async {
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

        print(
            'OTP verification response: ${response.session != null ? 'Session established' : 'No session'}');

        if (response.session == null) {
          throw Exception(
              'Failed to establish a session with the recovery token. Please ensure the link is valid and not expired.');
        }
      } else {
        print('Using token-only verification approach');
        // Try token-only approach as fallback
        final response = await client.auth.verifyOTP(
          token: token,
          type: OtpType.recovery,
        );

        print(
            'Token-only OTP verification response: ${response.session != null ? 'Session established' : 'No session'}');

        if (response.session == null) {
          throw Exception(
              'Failed to establish a session with the recovery token. The link may be invalid or expired.');
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
  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _supabaseClient.from('users').update({
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

  // Helper method to check if user is authenticated
  bool get isAuthenticated => _supabaseClient.auth.currentUser != null;

  // Get current user
  User? get currentUser => _supabaseClient.auth.currentUser;

  // Email verification methods
  Future<void> updateEmailVerificationStatus(String email) async {
    try {
      print('Updating email verification status for: $email');

      await _supabaseClient.from('users').update({
        'is_email_verified': true,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('email', email);

      print('Email verification status updated successfully');
    } catch (e) {
      print('Error updating email verification status: $e');
      throw Exception('Failed to update email verification status');
    }
  }

  // Psychologist methods
  Future<Map<String, dynamic>?> getAssignedPsychologist() async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      // Return hardcoded psychologist data for demonstration
      return {
        'id': 'psy-001',
        'name': 'Dr. Sarah Johnson',
        'specialization': 'Clinical Psychologist, Anxiety Specialist',
        'contact_email': 'sarah.johnson@anxiease.com',
        'contact_phone': '(555) 123-4567',
        'biography':
            'Dr. Sarah Johnson is a licensed clinical psychologist with over 15 years of experience specializing in anxiety disorders, panic attacks, and stress management. She completed her Ph.D. at Stanford University and has published numerous research papers on cognitive behavioral therapy techniques for anxiety management. Dr. Johnson takes a holistic approach to mental health, combining evidence-based therapeutic techniques with mindfulness practices to help patients develop effective coping strategies for their anxiety.',
        'image_url': null,
      };

      // Original implementation (commented out)
      /*
      // First get the user's assigned psychologist ID
      final userProfile = await getUserProfile();
      if (userProfile == null ||
          userProfile['assigned_psychologist_id'] == null) {
        return null;
      }

      final psychologistId = userProfile['assigned_psychologist_id'];

      // Then get the psychologist details
      final response = await _supabaseClient
          .from('psychologists')
          .select()
          .eq('id', psychologistId)
          .maybeSingle();

      return response;
      */
    } catch (e) {
      Logger.error('Error fetching assigned psychologist', e);
      return null;
    }
  }

  // Appointment methods
  Future<List<Map<String, dynamic>>> getAppointments() async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      // Return hardcoded appointment data for demonstration
      final now = DateTime.now();

      return [
        // Past appointments (only 2)
        {
          'id': 'apt-001',
          'psychologist_id': 'psy-001',
          'user_id': user.id,
          'appointment_date': DateTime(now.year, now.month, now.day - 30, 10, 0)
              .toIso8601String(),
          'reason': 'Initial consultation and anxiety assessment',
          'status': 'completed',
          'created_at':
              DateTime(now.year, now.month, now.day - 35).toIso8601String(),
        },
        {
          'id': 'apt-002',
          'psychologist_id': 'psy-001',
          'user_id': user.id,
          'appointment_date': DateTime(now.year, now.month, now.day - 7, 11, 0)
              .toIso8601String(),
          'reason': 'Discuss progress with breathing exercises',
          'status': 'cancelled',
          'created_at':
              DateTime(now.year, now.month, now.day - 10).toIso8601String(),
        },

        // Appointment requests with different statuses
        {
          'id': 'apt-003',
          'psychologist_id': 'psy-001',
          'user_id': user.id,
          'appointment_date': DateTime(now.year, now.month, now.day + 3, 14, 30)
              .toIso8601String(),
          'reason': 'Follow-up session to discuss coping strategies',
          'status': 'pending',
          'created_at':
              DateTime(now.year, now.month, now.day - 1).toIso8601String(),
        },
        {
          'id': 'apt-004',
          'psychologist_id': 'psy-001',
          'user_id': user.id,
          'appointment_date': DateTime(now.year, now.month, now.day + 5, 9, 30)
              .toIso8601String(),
          'reason': 'Urgent session to discuss recent panic attack',
          'status': 'accepted',
          'created_at':
              DateTime(now.year, now.month, now.day - 2).toIso8601String(),
          'response_message':
              'I can see you on this date. Please arrive 10 minutes early to complete intake forms.',
        },
        {
          'id': 'apt-005',
          'psychologist_id': 'psy-001',
          'user_id': user.id,
          'appointment_date': DateTime(now.year, now.month, now.day + 2, 11, 0)
              .toIso8601String(),
          'reason': 'Discussion about sleep issues',
          'status': 'denied',
          'created_at':
              DateTime(now.year, now.month, now.day - 3).toIso8601String(),
          'response_message':
              'I\'m unavailable at this time. Please try scheduling for the following week or contact my assistant for urgent matters.',
        },
      ];

      // Original implementation (commented out)
      /*
      final response = await _supabaseClient
          .from('appointments')
          .select()
          .eq('user_id', user.id)
          .order('appointment_date', ascending: false);

      return List<Map<String, dynamic>>.from(response);
      */
    } catch (e) {
      Logger.error('Error fetching appointments', e);
      return [];
    }
  }

  Future<String> requestAppointment(
      Map<String, dynamic> appointmentData) async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      // For demonstration, just return a success without actually saving to database

      // Log the appointment data for debugging
      Logger.info('New appointment request: ${appointmentData.toString()}');

      // Return a mock appointment ID
      return 'apt-${DateTime.now().millisecondsSinceEpoch}';

      // Original implementation (commented out)
      /*
      final response = await _supabaseClient.from('appointments').insert({
        'user_id': user.id,
        ...appointmentData,
        'status': 'pending',
        'created_at': timestamp,
      }).select();

      if (response.isEmpty) {
        throw Exception('Failed to create appointment');
      }

      return response[0]['id'];
      */
    } catch (e) {
      Logger.error('Error requesting appointment', e);
      throw Exception('Failed to request appointment: ${e.toString()}');
    }
  }
}
