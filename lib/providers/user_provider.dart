import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import '../repositories/user_repository.dart';

class UserProvider extends ChangeNotifier {
  final UserRepository _userRepository;

  UserProvider(this._userRepository);

  List<UserProfile> _users = [];

  bool _isLoading = false;

  List<UserProfile> get users => _users;

  bool get isLoading => _isLoading;

  /// Cargar todos los usuarios
  Future<void> loadUsers() async {
    _setLoading(true);

    try {
      _users = await _userRepository.getUsers();
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// Obtener un usuario por su UID
  Future<UserProfile?> getUser(String uid) async {
    try {
      return await _userRepository.getUser(uid);
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  /// Actualizar el perfil
  Future<String?> updateProfile(
      UserProfile profile) async {
    _setLoading(true);

    try {
      await _userRepository.updateProfile(profile);

      await loadUsers();

      return null;
    } catch (e) {
      return e.toString().replaceAll(
          'Exception: ', '');
    } finally {
      _setLoading(false);
    }
  }

  /// Cambiar el rol del usuario
  Future<String?> updateRole(
    String uid,
    String role,
  ) async {
    _setLoading(true);

    try {
      await _userRepository.updateRole(
        uid,
        role,
      );

      await loadUsers();

      return null;
    } catch (e) {
      return e.toString().replaceAll(
          'Exception: ', '');
    } finally {
      _setLoading(false);
    }
  }

  /// Bloquear o desbloquear usuario
  Future<String?> updateBlocked(
    String uid,
    bool blocked,
  ) async {
    _setLoading(true);

    try {
      await _userRepository.updateBlocked(
        uid,
        blocked,
      );

      await loadUsers();

      return null;
    } catch (e) {
      return e.toString().replaceAll(
          'Exception: ', '');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}