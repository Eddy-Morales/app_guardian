import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';

class AuthRepository {
  final SupabaseClient _supabase;

  // Inyección de dependencia
  AuthRepository(this._supabase);

  // Registrar usuario
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

  // Iniciar sesión
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Error al iniciar sesión: $e');
    }
  }

  // Obtener perfil
  Future<UserProfile?> getUserProfile() async {
    try {
      final user = _supabase.auth.currentUser;

      if (user == null) return null;

      final data = await _supabase
          .from('profiles')
          .select()
          .eq('uid', user.id)
          .single();

      return UserProfile.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }


  // Recuperar contraseña: Supabase envía un correo con un enlace mágico
  // que permite al usuario definir una nueva contraseña.
  Future<void> resetPasswordForEmail(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: 'guardianapp://reset-callback/',
      );
    } catch (e) {
      throw Exception('Error al enviar el correo de recuperación: $e');
    }
  }
}