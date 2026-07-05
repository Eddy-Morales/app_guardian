import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';


class AdminUserScreen extends StatefulWidget {
  const AdminUserScreen({super.key});

  @override
  State<AdminUserScreen> createState() => _AdminUserScreenState();
}

class _AdminUserScreenState extends State<AdminUserScreen>{

  Future <void> _logout() async {
    await context.read<AuthProvider>().logout();
  }

  void _goToUserListScreen(){
    Navigator.pushNamed(context, '/user-list');
  }

  void _goToUserProfileScreen(){
    Navigator.pushNamed(context, '/user-profile');
  }


  
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Administración de Incidentes'),
        actions:[
          IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: Center(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children:[
            const SizedBox(height: 16),
            _DashboardAction(
              title: 'Lista de Usuarios',
              subtitle: 'Gestionar y visualizar usuarios registrados',
              icon: Icons.people,
              onTap: _goToUserListScreen,
            ),
            _DashboardAction(
              title: 'Perfil del Usuario',
              subtitle: 'Ver y Editar perfil del usuario',
              icon: Icons.person,
              onTap: _goToUserProfileScreen,
            ),
          ]
        )
      )
    );
  }
}

class _DashboardAction extends StatelessWidget {
  const _DashboardAction({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
    @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}