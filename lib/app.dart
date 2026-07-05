import 'package:flutter/material.dart';
import 'package:guardia_app/screens/users/user_list_screen.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/admin/home_admin_screen.dart';
import 'screens/client/home_client_screen.dart';

import 'screens/admin/admin_users_screen.dart';
import 'screens/admin/admin_zones_screen.dart';
import 'screens/admin/admin_incident_screen.dart'; // El panel intermedio que modificamos antes
import 'screens/incidents/incident_list_screen.dart';  // La lista con Dismissible
import 'screens/incidents/incident_form_screen.dart';
import 'screens/incidents/incident_detail_screen.dart';
import 'screens/users/profile_screen.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuchamos activamente al AuthProvider. 
    // Cuando '_currentUserProfile' cambia, este build SE EJECUTA otra vez obligatoriamente.
    final authProvider = context.watch<AuthProvider>();
    final profile = authProvider.currentUserProfile;

    // 1. Si está cargando el estado inicial, mostramos splash/loader
    if (authProvider.isLoading && profile == null) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    // 2. Si no hay perfil, directo al Login
    if (profile == null) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: LoginScreen(),
      );
    }

    // 3. Normalizamos el rol limpiando espacios y pasándolo a minúsculas
    final stringRol = profile.role.toString().toLowerCase().trim();

    // Diagnóstico visual en consola para asegurar qué lee MainApp
    debugPrint("MainApp evaluando redirección para el rol normalizado: '$stringRol'");

    Widget pantallaDestino;

    switch (stringRol) {
      case 'admin':
        pantallaDestino = const HomeAdminScreen();
        break;
      case 'client':
      case 'cliente':
        pantallaDestino = const HomeClientScreen();
        break;
      default:
        pantallaDestino = Scaffold(
          body: Center(
            child: Text(
              'Error: El rol "$stringRol" no tiene una pantalla asignada.',
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
          ),
        );
    }

    // Retornamos la app con la pantalla destino correspondiente
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Guardián Comunitario',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: pantallaDestino,
    routes: {
        //'/users': (context) => const UsersScreen(),
        //'/zones': (context) => const ZonesScreen(),
        //'/reports': (context) => const ReportsScreen(),
        
        // Rutas del flujo de Incidentes que enlazamos previamente
        '/incidents': (context) => const AdminIncidentScreen(), // Panel secundario de incidentes
        '/incident-list': (context) => const IncidentListScreen(),
        '/incident-form': (context) => const IncidentFormScreen(),
        '/incident-detail': (context) => const IncidentDetailScreen(),
        '/user-list': (context) => const UserListScreen(),
        '/users':(context)=> const AdminUserScreen(),
        '/user-profile': (context) => const ProfileScreen(),
        //'/zone-list': (context) => const ZonesListScreen(),
       // '/zone-form': (context) => const ZonesFormScreen(), // Aquí podrías tener
      },
    );
  }
}