import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/providers/incident_provider.dart';
import '/widgets/incident_card.dart';

class IncidentListScreen extends StatefulWidget {
  const IncidentListScreen({super.key});

  @override
  State<IncidentListScreen> createState() => _IncidentListScreenState();
}

class _IncidentListScreenState extends State<IncidentListScreen> {

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IncidentProvider>().loadIncidents();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<IncidentProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Incidentes'),
      ),
      body: _buildBody(provider),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            Navigator.pushNamed(context, '/incident-form'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(IncidentProvider provider) {

    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (provider.incidents.isEmpty) {
      return const Center(
        child: Text(
          'No hay incidentes reportados',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: provider.incidents.length,
      itemBuilder: (context, index) {

        final incident = provider.incidents[index];

        return IncidentCard(
          incident: incident,
          onDelete: () async {
            return await provider.removeIncident(incident.id);
          },
        );
      },
    );
  }
}