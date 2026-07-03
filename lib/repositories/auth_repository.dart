import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';
import '../services/supabase_service.dart';

class AuthRepository {
  final SupabaseClient _supabase = SupabaseService.client;

  // Registrar usuario mandando el nombre en los metadatos para el Trigger de SQL
  Future<AuthResponse> signUp({
    required String email, 
    required String password, 
    required String name,
  }) async {
    try {
      return await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'name': name}, 
      );
    } catch (e) {
      throw Exception('Error al registrar usuario: $e');
    }
  }

  // Iniciar sesión con email y contraseña
  Future<AuthResponse> signIn({required String email, required String password}) async {
    try {
      return await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Error al iniciar sesión: $e');
    }
  }

  // Consultar los datos de la tabla 'profiles' según el usuario autenticado
  Future<UserProfile?> getUserProfile() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      final data = await _supabase
          .from('profiles')
          .select()
          .eq('uid', user.id)
          .single();

      return UserProfile.fromMap(data);
    } catch (e) {
      return null;
    }
  }

  // Cerrar sesión activa
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}