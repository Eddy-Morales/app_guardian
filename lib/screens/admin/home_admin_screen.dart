import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeAdminScreen extends StatefulWidget {
  const HomeAdminScreen({super.key});

  @override
  State<HomeAdminScreen> createState() => _HomeAdminScreenState();
}

class _HomeAdminScreenState extends State<HomeAdminScreen>{

  Future <void> _logout() async {
    await context.read<AuthProvider>().logout();
  }

  void _goToUsersScreen(){
    Navigator.pushNamed(context, '/users');
  }

  void _goToZonesScreen(){
    Navigator.pushNamed(context, '/zones');
  }

  void _goToReportsScreen(){
    Navigator.pushNamed(context, '/reports');
  }

  void _goToInsidentsScreen(){
    Navigator.pushNamed(context, '/incidents');
  }


  
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Administración'),
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
              title: 'Usuarios',
              subtitle: 'Gestionar usuarios del sistema',
              icon: Icons.person,
              onTap: _goToUsersScreen,
            ),
            _DashboardAction(
              title: 'Zonas',
              subtitle: 'Gestionar zonas de seguridad',
              icon: Icons.location_on,
              onTap: _goToZonesScreen,
            ),
            _DashboardAction(
              title: 'Reportes',
              subtitle: 'Visualizar reportes generados',
              icon: Icons.bar_chart,
              onTap: _goToReportsScreen,
            ),
            _DashboardAction(
              title: 'Incidentes',
              subtitle: 'Gestionar incidentes reportados',
              icon: Icons.error,
              onTap: _goToInsidentsScreen,
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