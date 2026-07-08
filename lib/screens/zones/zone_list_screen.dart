import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/zone_provider.dart';
import 'zone_form_screen.dart';

class ZoneListScreen extends StatefulWidget {
  const ZoneListScreen({super.key});

  @override
  State<ZoneListScreen> createState() => _ZoneListScreenState();
}

class _ZoneListScreenState extends State<ZoneListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ZoneProvider>().loadZones();
    });
  }

  Color _riskColor(String risk) {
    switch (risk.toLowerCase()) {
      case 'alto':
        return Colors.red;
      case 'medio':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ZoneProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text("Zonas")),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ZoneFormScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: provider.zones.length,
              itemBuilder: (context, index) {
                final zone = provider.zones[index];

                return Card(
                  child: ListTile(
                    title: Text(zone.name),
                    subtitle: Text(
                      zone.centerLat != null
                          ? "Incidentes: ${zone.incidentCount} · "
                            "Radio: ${zone.radiusKm?.toStringAsFixed(1) ?? '-'} km"
                          : "Incidentes: ${zone.incidentCount} · Sin ubicación definida",
                    ),
                    leading: CircleAvatar(
                      backgroundColor: _riskColor(zone.riskLevel),
                      child: Text(
                        zone.riskLevel.isNotEmpty ? zone.riskLevel[0] : '?',
                      ),
                    ),
                    trailing: PopupMenuButton(
                      itemBuilder: (_) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text('Editar'),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Eliminar'),
                        ),
                      ],
                      onSelected: (value) async {
                        if (value == 'delete') {
                          await provider.removeZone(zone.id);
                        }

                        if (value == 'edit') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ZoneFormScreen(zone: zone),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}