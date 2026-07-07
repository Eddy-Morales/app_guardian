
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
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("No hay sesión")),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Mi perfil"),
        centerTitle: true,
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
        elevation: 2,
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [

            // Encabezado
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30),
              decoration: BoxDecoration(
                color: Colors.blue.shade900,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(35),
                  bottomRight: Radius.circular(35),
                ),
              ),
              child: Column(
                children: [

                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.blue.shade900,
                    ),
                  ),

                  const SizedBox(height: 15),

                  Text(
                    user.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    user.email,
                    style: TextStyle(
                      color: Colors.grey.shade300,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [

                      _infoTile(
                        Icons.badge,
                        "Nombre",
                        user.name,
                      ),

                      const Divider(),

                      _infoTile(
                        Icons.email,
                        "Correo",
                        user.email,
                      ),

                      const Divider(),

                      _infoTile(
                        Icons.admin_panel_settings,
                        "Rol",
                        user.role.toUpperCase(),
                      ),
                      const Divider(),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    auth.logout();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  icon: const Icon(Icons.logout),
                  label: const Text(
                    "Cerrar sesión",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  static Widget _infoTile(
    IconData icon,
    String titulo,
    String valor,
  ) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.blue.shade50,
        child: Icon(
          icon,
          color: Colors.blue.shade900,
        ),
      ),
      title: Text(
        titulo,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
      subtitle: Text(
        valor,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black87,
        ),
      ),
    );
  }
}