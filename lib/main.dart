import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Configuracion inicial
// import 'config/theme.dart';
// import '/screens/auth/login_screen.dart';
// import '/screens/admin/home_admin_screen.dart';
import 'app.dart';

// Repositorios 
import 'repositories/auth_repository.dart';

// Providers
import 'providers/auth_provider.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Reemplaza con tus credenciales reales del panel de Supabase
  await Supabase.initialize(
    //url: 'https://ugaydigcsueblaeigwfx.supabase.co',
    //anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVnYXlkaWdjc3VlYmxhZWlnd2Z4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODMwMzA1OTEsImV4cCI6MjA5ODYwNjU5MX0.-H_Y4pKj52Sr83JyFTgaWwE-ibgWmeiTSiBBqzq_jho',
    url:'https://kyplcxebxzvtrcgkozwq.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imt5cGxjeGVieHp2dHJjZ2tvendxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzgxNzQyODksImV4cCI6MjA5Mzc1MDI4OX0.FXJheZU7GhIVdzoQbHv_R8FKW5Mapbf4c1sDQckiq8w',
  );

  runApp(
    MultiProvider(
      providers: [
        // Repositorios
        Provider<AuthRepository>(
          create: (_) => AuthRepository(Supabase.instance.client),
        ),
        // Providers
        ChangeNotifierProxyProvider<AuthRepository, AuthProvider>(
          create: (context) => AuthProvider(context.read<AuthRepository>()),
          update: (context, repository, previousAuthProvider){
          // Si ya existe uno previo, lo devolvemos; si no, creamos uno nuevo
          return previousAuthProvider ?? AuthProvider(repository);
          },
        ),
      ],
      child: const MainAppWrapper(),
    ),
  );
}
class MainAppWrapper extends StatefulWidget{
  const MainAppWrapper({super.key});

  @override
  State<MainAppWrapper> createState() => _MainAppWrapperState();
}

class _MainAppWrapperState extends State<MainAppWrapper>{
  @override
  void initState(){
    super.initState();
    // Revisa de inmediato si el usuario ya tenia la sesion abierta
    WidgetsBinding.instance.addPostFrameCallback((_){
      context.read<AuthProvider>().checkCurrentUser();
    });
  }
  @override
    Widget build(BuildContext context){
    return const MainApp();
  }
}
