import 'package:flutter/material.dart';
import 'package:guardia_app/screens/users/user_list_screen.dart';
import 'package:provider/provider.dart';
import 'models/user_profile.dart';
import 'providers/auth_provider.dart';
import 'navigation/nav_keys.dart';
import 'screens/auth/login_screen.dart';
import 'screens/admin/home_admin_screen.dart';
import 'screens/client/home_client_screen.dart';

import 'screens/admin/admin_users_screen.dart';
import 'screens/admin/admin_zones_screen.dart';
import 'screens/admin/admin_incident_screen.dart'; // El panel intermedio que modificamos antes
import 'screens/admin/reports_screen.dart';
import 'screens/incidents/incident_list_screen.dart';  // La lista con Dismissible
import 'screens/incidents/incident_form_screen.dart';
import 'screens/incidents/incident_detail_screen.dart';

import 'screens/users/profile_screen.dart';
import 'screens/zones/zone_form_screen.dart';
import 'screens/zones/zone_list_screen.dart';
import 'screens/map_screen.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuchamos activamente al AuthProvider.
    // Cuando '_currentUserProfile' cambia, este build SE EJECUTA otra vez obligatoriamente.
    final authProvider = context.watch<AuthProvider>();
    final profile = authProvider.currentUserProfile;

    final Widget home = _resolveHome(authProvider, profile);

    return MaterialApp(
      navigatorKey: rootNavigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Guardián Comunitario',
      theme: ThemeData(
        primaryColor: Colors.blue[900], // Azul oscuro
        scaffoldBackgroundColor: Colors.white, // Fondo blanco
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black), // Texto negro
          bodyMedium: TextStyle(color: Colors.grey), // Texto gris
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[900], // Azul oscuro para botones
            foregroundColor: Colors.white, // Texto blanco en botones
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue[900], // Azul oscuro para la AppBar
          foregroundColor: Colors.white, // Texto blanco en la AppBar
        ),
      ),
      home: home,
      routes: {
        //'/users': (context) => const UsersScreen(),
        '/maps': (context) => const MapScreen(),
        '/reports': (context) => const ReportsScreen(),

        // Rutas del flujo de Incidentes que enlazamos previamente
        '/incidents': (context) => const AdminIncidentScreen(), // Panel secundario de incidentes
        '/incident-list': (context) => const IncidentListScreen(),
        '/incident-form': (context) => const IncidentFormScreen(),
        '/incident-detail': (context) => const IncidentDetailScreen(),
        '/user-list': (context) => const UserListScreen(),
        '/users':(context)=> const AdminUserScreen(),
        '/user-profile': (context) => const ProfileScreen(),
        '/zone-list': (context) => const ZoneListScreen(),
        '/zone-form': (context) => const ZoneFormScreen(), // Aquí podrías tener
        '/zones': (context) => const AdminZonesScreen()
      },
    );
  }

  Widget _resolveHome(AuthProvider authProvider, UserProfile? profile) {
    // 1. Si está cargando el estado inicial (arranque de la app)
    if (authProvider.isInitializing) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // 2. Si no hay perfil, directo al Login
    if (profile == null) {
      return const LoginScreen();
    }

    // 3. Normalizamos el rol limpiando espacios y pasándolo a minúsculas
    final stringRol = profile.role.toString().toLowerCase().trim();

    // Diagnóstico visual en consola para asegurar qué lee MainApp
    debugPrint("MainApp evaluando redirección para el rol normalizado: '$stringRol'");

    switch (stringRol) {
      case 'admin':
        return const HomeAdminScreen();
      case 'client':
      case 'cliente':
        return const HomeClientScreen();
      default:
        return Scaffold(
          body: Center(
            child: Text(
              'Error: El rol "$stringRol" no tiene una pantalla asignada.',
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
          ),
        );
    }
  }
}