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
    } on AuthException catch (e) {
      throw Exception(_translateAuthError(e.message));
    } catch (e) {
      throw Exception('Ocurrió un error inesperado. Intenta de nuevo.');
    }
  }

  /// Traduce los mensajes de error de Supabase Auth (en inglés) a mensajes
  /// claros en español para el usuario final.
  String _translateAuthError(String message) {
    final msg = message.toLowerCase();

    if (msg.contains('invalid login credentials') ||
        msg.contains('invalid credentials') ||
        msg.contains('wrong password') ||
        msg.contains('invalid password')) {
      return 'Correo o contraseña incorrectos.';
    }

    if (msg.contains('user not found') ||
        msg.contains('no user found') ||
        msg.contains('email not found')) {
      return 'No existe ninguna cuenta con ese correo.';
    }

    if (msg.contains('email not confirmed')) {
      return 'Debes confirmar tu correo antes de iniciar sesión.';
    }

    if (msg.contains('too many requests') ||
        msg.contains('rate limit') ||
        msg.contains('over_email_send_rate_limit')) {
      return 'Demasiados intentos. Espera un momento e inténtalo de nuevo.';
    }

    if (msg.contains('network') || msg.contains('connection')) {
      return 'Sin conexión a internet. Verifica tu red e intenta de nuevo.';
    }

    // Si no reconocemos el error, devolvemos el original para no perder info.
    return message;
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