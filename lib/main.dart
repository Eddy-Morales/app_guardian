import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
// Pantalla para restablecer contraseña
import 'navigation/nav_keys.dart';
import 'screens/auth/reset_password_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Carga las variables de entorno desde el archivo .env (no versionado).
  await dotenv.load(fileName: '.env');

  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

  if (supabaseUrl == null || supabaseAnonKey == null) {
    throw Exception(
      'Faltan SUPABASE_URL o SUPABASE_ANON_KEY. '
      'Copia .env.example como .env y completa los valores.',
    );
  }

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
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
    // Escucha el evento de recuperación de contraseña disparado por
    // el deep link (guardianapp://reset-callback/) cuando el usuario
    // toca el enlace del correo.
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.passwordRecovery) {
        rootNavigatorKey.currentState?.push(
          MaterialPageRoute(builder: (_) => const ResetPasswordScreen()),
        );
      }
    });
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
