import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';

class UserRepository {
  final SupabaseClient _supabase;

  UserRepository(this._supabase);

  /// Obtener todos los usuarios
  Future<List<UserProfile>> getUsers() async {
    try {
      final List data = await _supabase
          .from('profiles')
          .select()
          .order('created_at', ascending: false);

      return data
          .map((e) => UserProfile.fromJson(e))
          .toList();
    } catch (e) {
      throw Exception(
        'Error al obtener usuarios: $e',
      );
    }
  }

  /// Cambiar rol
  Future<void> updateRole(
    String uid,
    String role,
  ) async {
    try {
      await _supabase
          .from('profiles')
          .update({
            'role': role,
          })
          .eq('uid', uid);
    } catch (e) {
      throw Exception(
        'Error al actualizar el rol: $e',
      );
    }
  }

  /// Bloquear / Desbloquear
  Future<void> updateBlocked(
    String uid,
    bool blocked,
  ) async {
    try {
      await _supabase
          .from('profiles')
          .update({
            'blocked': blocked,
          })
          .eq('uid', uid);
    } catch (e) {
      throw Exception(
        'Error al bloquear usuario: $e',
      );
    }
  }

  /// Obtener un usuario por id
  Future<UserProfile> getUser(
    String uid,
  ) async {
    try {
      final data = await _supabase
          .from('profiles')
          .select()
          .eq('uid', uid)
          .single();

      return UserProfile.fromJson(data);
    } catch (e) {
      throw Exception(
        'Error al obtener usuario: $e',
      );
    }
  }

  /// Actualizar datos básicos
  Future<void> updateProfile(
    UserProfile profile,
  ) async {
    try {
      await _supabase
          .from('profiles')
          .update({
            'name': profile.name,
            'email': profile.email,
          })
          .eq('uid', profile.uid);
    } catch (e) {
      throw Exception(
        'Error al actualizar perfil: $e',
      );
    }
  }
}