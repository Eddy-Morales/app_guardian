
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUserProfile;

    if (auth.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (user == null) {
      return const Center(child: Text("No hay sesión"));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Mi perfil")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Nombre: ${user.name}"),
            Text("Email: ${user.email}"),
            Text("Rol: ${user.role}"),
            Text("Estado: ${user.blocked ? "Bloqueado" : "Activo"}"),
          ],
        ),
      ),
    );
  }
}