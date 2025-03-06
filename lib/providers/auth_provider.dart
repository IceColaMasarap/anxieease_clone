import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../models/user_model.dart';
import '../models/psychologist.dart';

class AuthProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  UserModel? _currentUser;
  Psychologist? _currentPsychologist;
  bool _isLoading = false;

  AuthProvider() {
    _checkCurrentUser();
  }

  Future<void> _checkCurrentUser() async {
    if (_supabaseService.isAuthenticated) {
      _setLoading(true);
      try {
        final psychologistProfile = await _supabaseService.getPsychologistProfile();
        if (psychologistProfile != null) {
          _currentPsychologist = Psychologist.fromJson(psychologistProfile);
        } else {
          final userProfile = await _supabaseService.getUserProfile();
          if (userProfile != null) {
            _currentUser = UserModel.fromJson(userProfile);
          }
        }
      } finally {
        _setLoading(false);
      }
    } else {
      // Clear any existing state if not authenticated
      _currentUser = null;
      _currentPsychologist = null;
    }
    notifyListeners();
  }

  UserModel? get currentUser => _currentUser;
  Psychologist? get currentPsychologist => _currentPsychologist;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _supabaseService.isAuthenticated;
  bool get isPsychologist => _currentPsychologist != null;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    int? age,
    String? gender,
  }) async {
    try {
      _setLoading(true);

      final userData = {
        'full_name': fullName,
        'age': age,
        'gender': gender,
      };

      final response = await _supabaseService.signUp(
        email: email,
        password: password,
        userData: userData,
      );

      if (response.user != null) {
        final userProfile = await _supabaseService.getUserProfile();
        if (userProfile != null) {
          _currentUser = UserModel.fromJson(userProfile);
          notifyListeners();
        }
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _currentPsychologist = null;

      final response = await _supabaseService.signIn(
        email: email,
        password: password,
      );

      if (response.user != null) {
        final userProfile = await _supabaseService.getUserProfile();
        if (userProfile != null) {
          _currentUser = UserModel.fromJson(userProfile);
          notifyListeners();
        }
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signInAsPsychologist({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _currentUser = null;
      _currentPsychologist = null;

      final response = await _supabaseService.signInPsychologist(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Only get profile if sign in was successful (which means email is verified)
        final psychologistProfile = await _supabaseService.getPsychologistProfile();
        if (psychologistProfile != null) {
          _currentPsychologist = Psychologist.fromJson(psychologistProfile);
          notifyListeners();
        } else {
          await _supabaseService.signOut();
          throw Exception('Failed to retrieve psychologist profile');
        }
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<String> registerPsychologist({
    required String email,
    required String password,
    required String fullName,
    int? age,
  }) async {
    try {
      _setLoading(true);
      _currentUser = null;
      _currentPsychologist = null;
      
      print('Starting psychologist registration for: $email');

      await _supabaseService.signUpPsychologist(
        email: email,
        password: password,
        fullName: fullName,
        age: age,
      );

      // Return the email so we can show it in the verification dialog
      return email;
    } catch (e) {
      print('Error in registerPsychologist: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    try {
      _setLoading(true);
      await _supabaseService.signOut();
      _currentUser = null;
      _currentPsychologist = null;
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      _setLoading(true);
      await _supabaseService.resetPassword(email);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateProfile({
    String? fullName,
    int? age,
    String? gender,
  }) async {
    try {
      _setLoading(true);

      final updates = {
        if (fullName != null) 'full_name': fullName,
        if (age != null) 'age': age,
        if (gender != null) 'gender': gender,
      };

      await _supabaseService.updateUserProfile(updates);

      final userProfile = await _supabaseService.getUserProfile();
      if (userProfile != null) {
        _currentUser = UserModel.fromJson(userProfile);
        notifyListeners();
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadUserProfile() async {
    if (!isAuthenticated) return;

    try {
      _setLoading(true);
      final userProfile = await _supabaseService.getUserProfile();
      if (userProfile != null) {
        _currentUser = UserModel.fromJson(userProfile);
        notifyListeners();
      }
    } finally {
      _setLoading(false);
    }
  }
}
