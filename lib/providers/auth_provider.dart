import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();
  
  UserProfile? _currentUserProfile;
  bool _isLoading = false;

  UserProfile? get currentUserProfile => _currentUserProfile;
  bool get isLoading => _isLoading;

  // Verifica si hay un token activo guardado en el dispositivo al abrir la app
  Future<void> checkCurrentUser() async {
    _setLoading(true);
    _currentUserProfile = await _authRepository.getUserProfile();
    _setLoading(false);
  }

  // Acción de registro
  Future<String?> register({
    required String email, 
    required String password, 
    required String name,
  }) async {
    _setLoading(true);
    try {
      await _authRepository.signUp(email: email, password: password, name: name);
      // Como no requiere confirmación de correo, cargamos el perfil inmediatamente
      _currentUserProfile = await _authRepository.getUserProfile();
      return null; // Éxito (sin errores)
    } catch (e) {
      return e.toString().replaceAll('Exception: ', '');
    } finally {
      _setLoading(false);
    }
  }

  // Acción de login
  Future<String?> login({required String email, required String password}) async {
    _setLoading(true);
    try {
      await _authRepository.signIn(email: email, password: password);
      _currentUserProfile = await _authRepository.getUserProfile();
      return null; // Éxito
    } catch (e) {
      return e.toString().replaceAll('Exception: ', '');
    } finally {
      _setLoading(false);
    }
  }

  // Acción de logout
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