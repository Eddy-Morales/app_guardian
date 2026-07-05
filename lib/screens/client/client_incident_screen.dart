import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';


class ClientIncidentScreen extends StatefulWidget {
  const ClientIncidentScreen({super.key});

  @override
  State<ClientIncidentScreen> createState() => _ClientIncidentScreenState();
}

class _ClientIncidentScreenState extends State<ClientIncidentScreen>{

  Future <void> _logout() async {
    await context.read<AuthProvider>().logout();
  }

  void _goToIncidentListScreen(){
    Navigator.pushNamed(context, '/incident-list');
  }

  void _goToIncidentFormScreen(){
    Navigator.pushNamed(context, '/incident-form');
  }


  
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Incidentes'),
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
              title: 'Lista de Incidentes',
              subtitle: 'Gestionar y visualizar incidentes reportados',
              icon: Icons.assignment,
              onTap: _goToIncidentListScreen,
            ),
            _DashboardAction(
              title: 'Formulario de Incidente',
              subtitle: 'Crear nuevo incidente',
              icon: Icons.add,
              onTap: _goToIncidentFormScreen,
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