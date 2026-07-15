import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;

  // Inyección del repositorio
  AuthProvider(this._authRepository);

  UserProfile? _currentUserProfile;
  bool _isLoading = false;
  // Solo es true mientras se revisa si ya existía una sesión guardada,
  bool _isInitializing = true;

  UserProfile? get currentUserProfile => _currentUserProfile;
  bool get isLoading => _isLoading;
  bool get isInitializing => _isInitializing;

  // Verifica sesión existente
  Future<void> checkCurrentUser() async {
    _setLoading(true);

    final profile = await _authRepository.getUserProfile();

    if (profile != null && profile.blocked) {
      // El usuario tiene una sesión activa pero fue bloqueado
      // por un administrador: cerramos la sesión automáticamente.
      await _authRepository.signOut();
      _currentUserProfile = null;
    } else {
      _currentUserProfile = profile;
    }

    _isInitializing = false;
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
      return _friendlyAuthError(e);
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

      final profile = await _authRepository.getUserProfile();

      if (profile != null && profile.blocked) {
        // Credenciales correctas, pero la cuenta está bloqueada:
        // cerramos la sesión inmediatamente y no dejamos entrar.
        await _authRepository.signOut();
        _currentUserProfile = null;
        return 'Tu cuenta ha sido bloqueada. '
            'Contacta a un administrador para más información.';
      }

      if (profile == null) {
        await _authRepository.signOut();
        _currentUserProfile = null;
        return 'Correo o contraseña incorrectos.';
      }

      _currentUserProfile = profile;
      notifyListeners();

      return null;
    } catch (e) {
      return _friendlyAuthError(e);
    } finally {
      _setLoading(false);
    }
  }

  // Recuperar contraseña
  Future<String?> resetPassword(String email) async {
    _setLoading(true);
    try {
      await _authRepository.resetPasswordForEmail(email);
      return null;
    } catch (e) {
      return _friendlyAuthError(e);
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

  /// Convierte los mensajes técnicos de Supabase (normalmente en inglés)
  /// en mensajes cortos y en español para mostrarle al usuario.
  String _friendlyAuthError(Object e) {
    final raw = e.toString().toLowerCase();
    if (raw.contains('invalid login credentials') ||
        raw.contains('invalid_credentials')) {
      return 'Correo o contraseña incorrectos.';
    }
    if (raw.contains('email not confirmed')) {
      return 'Debes confirmar tu correo antes de iniciar sesión. '
          'Revisa tu bandeja de entrada.';
    }
    if (raw.contains('user already registered') ||
        raw.contains('already registered')) {
      return 'Ya existe una cuenta con ese correo.';
    }
    if (raw.contains('network') || raw.contains('socketexception')) {
      return 'No hay conexión a internet. Verifica tu red e intenta de nuevo.';
    }
    // Si no reconocemos el error, mostramos el mensaje original limpio.
    return e.toString().replaceAll('Exception: ', '');
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}