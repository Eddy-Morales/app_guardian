import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;

  // Inyección del repositorio
  AuthProvider(this._authRepository);

  UserProfile? _currentUserProfile;
  bool _isLoading = false;

  UserProfile? get currentUserProfile => _currentUserProfile;
  bool get isLoading => _isLoading;

  // Verifica sesión existente
  Future<void> checkCurrentUser() async {
    _setLoading(true);
    _currentUserProfile =
        await _authRepository.getUserProfile();
    _setLoading(false);
  }

  // Registro
  Future<String?> register({
    required String email,
    required String password,
    required String name,
  }) async {
    _setLoading(true);

    try {
      await _authRepository.signUp(
        email: email,
        password: password,
        name: name,
      );

      _currentUserProfile =
          await _authRepository.getUserProfile();
          notifyListeners();
      return null;
    } catch (e) {
      return e
          .toString()
          .replaceAll('Exception: ', '');
    } finally {
      _setLoading(false);
    }
  }

  // Login
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);

    try {
      await _authRepository.signIn(
        email: email,
        password: password,
      );

      _currentUserProfile =
          await _authRepository.getUserProfile();
          notifyListeners();

      return null;
    } catch (e) {
      return e
          .toString()
          .replaceAll('Exception: ', '');
    } finally {
      _setLoading(false);
    }
  }

  // Logout
  Future<void> logout() async {
    await _authRepository.signOut();
    _currentUserProfile = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}