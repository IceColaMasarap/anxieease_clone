import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/psychologist.dart';

class PsychologistService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  // Get psychologist profile
  Future<Psychologist?> getPsychologistProfile() async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) return null;

    final response = await _supabaseClient
        .from('psychologists')
        .select()
        .eq('id', user.id)
        .single();

    return response != null ? Psychologist.fromJson(response) : null;
  }

  // Update psychologist profile
  Future<void> updateProfile({
    String? fullName,
    int? age,
  }) async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    final updates = {
      if (fullName != null) 'full_name': fullName,
      if (age != null) 'age': age,
      'updated_at': DateTime.now().toIso8601String(),
    };

    await _supabaseClient
        .from('psychologists')
        .update(updates)
        .eq('id', user.id);
  }
} 