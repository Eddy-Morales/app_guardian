import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';
import 'providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Reemplaza con tus credenciales reales del panel de Supabase
  await Supabase.initialize(
    url: 'https://ugaydigcsueblaeigwfx.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVnYXlkaWdjc3VlYmxhZWlnd2Z4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODMwMzA1OTEsImV4cCI6MjA5ODYwNjU5MX0.-H_Y4pKj52Sr83JyFTgaWwE-ibgWmeiTSiBBqzq_jho',
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          // Al instanciarse, inmediatamente busca si el usuario dejó una sesión abierta
          create: (_) => AuthProvider()..checkCurrentUser(),
        ),
      ],
      child: const MainApp(),
    ),
  );
}