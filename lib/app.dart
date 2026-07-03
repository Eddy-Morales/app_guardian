import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'models/user_profile.dart';
import 'screens/login_screen.dart';
import 'screens/home_admin_screen.dart';
import 'screens/home_client_screen.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Guardián Comunitario',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: _getHomeRoot(authProvider),
    );
  }

  Widget _getHomeRoot(AuthProvider authProvider) {
    // Si está cargando la sesión persistida, muestra un indicador de carga pantalla completa
    if (authProvider.isLoading && authProvider.currentUserProfile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final profile = authProvider.currentUserProfile;

    if (profile == null) {
      return const LoginScreen();
    }

    // Redirección reactiva por roles
    switch (profile.role) {
      case UserRole.admin:
        return const HomeAdminScreen();
      case UserRole.client:
        return const HomeClientScreen();
    }
  }
}