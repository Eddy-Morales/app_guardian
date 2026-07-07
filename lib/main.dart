import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';

// Repositorios
import 'repositories/auth_repository.dart';
import 'repositories/incident_repository.dart';
import 'repositories/user_repository.dart';
import 'repositories/zone_repository.dart';
import 'repositories/comment_repository.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/incident_provider.dart';
import 'providers/user_provider.dart';
import 'providers/zone_provider.dart';
import 'providers/comment_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Reemplaza con tus credenciales reales del panel de Supabase
  await Supabase.initialize(
    //url: 'https://ugaydigcsueblaeigwfx.supabase.co',
    //anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVnYXlkaWdjc3VlYmxhZWlnd2Z4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODMwMzA1OTEsImV4cCI6MjA5ODYwNjU5MX0.-H_Y4pKj52Sr83JyFTgaWwE-ibgWmeiTSiBBqzq_jho',
    // url: 'https://kyplcxebxzvtrcgkozwq.supabase.co',
    // anonKey:
    //     'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imt5cGxjeGVieHp2dHJjZ2tvendxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzgxNzQyODksImV4cCI6MjA5Mzc1MDI4OX0.FXJheZU7GhIVdzoQbHv_R8FKW5Mapbf4c1sDQckiq8w',
    url: 'https://haubjiclkskymrpuuqph.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhhdWJqaWNsa3NreW1ycHV1cXBoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg3NzgxMTcsImV4cCI6MjA5NDM1NDExN30.A8CqXytC6X3pjn7eSoqf6vGtpoTqSXPxb_9i5GtywUk'
  );

  runApp(
    MultiProvider(
      providers: [
        // Repositorios
        Provider<AuthRepository>(
          create: (_) => AuthRepository(Supabase.instance.client),
        ),
        Provider<IncidentRepository>(
          create: (_) => IncidentRepository(Supabase.instance.client),
        ),
        Provider<UserRepository>(
          create: (_) => UserRepository(Supabase.instance.client),
        ),
        Provider<ZoneRepository>(
          create: (_) => ZoneRepository(Supabase.instance.client),
        ),
        Provider<CommentRepository>(
          create: (_) => CommentRepository(Supabase.instance.client),
        ),
        // Providers
        ChangeNotifierProxyProvider<AuthRepository, AuthProvider>(
          create: (context) => AuthProvider(context.read<AuthRepository>()),
          update: (context, repository, previousAuthProvider) {
            // Si ya existe uno previo, lo devolvemos; si no, creamos uno nuevo
            return previousAuthProvider ?? AuthProvider(repository);
          },
        ),
        ChangeNotifierProvider<IncidentProvider>(
          create: (context) =>
              IncidentProvider(context.read<IncidentRepository>()),
        ),
        ChangeNotifierProvider<UserProvider>(
          create: (context) => UserProvider(context.read<UserRepository>()),
        ),
        ChangeNotifierProvider<ZoneProvider>(
          create: (context) => ZoneProvider(context.read<ZoneRepository>()),
        ),
        ChangeNotifierProvider<CommentProvider>(
          create: (context) =>
              CommentProvider(context.read<CommentRepository>()),
        ),
      ],
      child: const MainAppWrapper(),
    ),
  );
}

class MainAppWrapper extends StatefulWidget {
  const MainAppWrapper({super.key});

  @override
  State<MainAppWrapper> createState() => _MainAppWrapperState();
}

class _MainAppWrapperState extends State<MainAppWrapper> {
  @override
  void initState() {
    super.initState();
    // Revisa de inmediato si el usuario ya tenia la sesion abierta
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().checkCurrentUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    return const MainApp();
  }
}
