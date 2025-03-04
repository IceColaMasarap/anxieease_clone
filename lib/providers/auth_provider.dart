import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  UserModel? _currentUser;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _supabaseService.isAuthenticated;

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

  Future<void> signOut() async {
    try {
      _setLoading(true);
      await _supabaseService.signOut();
      _currentUser = null;
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
