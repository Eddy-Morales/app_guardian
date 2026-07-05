import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';


class AdminZonesScreen extends StatefulWidget {
  const AdminZonesScreen({super.key});

  @override
  State<AdminZonesScreen> createState() => _AdminZonesScreenState();
}

class _AdminZonesScreenState extends State<AdminZonesScreen>{

  Future <void> _logout() async {
    await context.read<AuthProvider>().logout();
  }

  void _goToZonesListScreen(){
    Navigator.pushNamed(context, '/zone-list');
  }

  void _goToZonesFormScreen(){
    Navigator.pushNamed(context, '/zone-form');
  }


  
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Administración de Zonas'),
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
              title: 'Lista de Zonas',
              subtitle: 'Gestionar y visualizar zonas registradas',
              icon: Icons.map,
              onTap: _goToZonesListScreen,
            ),
            _DashboardAction(
              title: 'Formulario de Zona',
              subtitle: 'Ver y Editar zonas',
              icon: Icons.person,
              onTap: _goToZonesFormScreen,
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