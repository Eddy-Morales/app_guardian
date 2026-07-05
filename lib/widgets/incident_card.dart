import 'package:flutter/material.dart';
import '../models/incident_model.dart';

class IncidentCard extends StatelessWidget {

  final IncidentModel incident;
  final Future<String?> Function() onDelete;

  const IncidentCard({
    super.key,
    required this.incident,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {

    return Dismissible(
      key: Key(incident.id),
      direction: DismissDirection.endToStart,

      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Confirmar'),
            content: const Text(
              '¿Deseas eliminar este incidente?'
            ),
            actions: [
              TextButton(
                onPressed: () =>
                    Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.pop(context, true),
                child: const Text(
                  'Eliminar',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );
      },

      onDismissed: (_) async {

        final error = await onDelete();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                error == null
                    ? 'Incidente eliminado'
                    : 'Error: $error',
              ),
            ),
          );
        }
      },

      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.all(20),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),

      child: Card(
        margin: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),

        child: ListTile(
          leading: incident.photoUrl != null
              ? CircleAvatar(
                  backgroundImage:
                      NetworkImage(incident.photoUrl!),
                )
              : CircleAvatar(
                  backgroundColor: Colors.grey.shade200,
                  child: const Icon(
                    Icons.warning,
                    color: Colors.orange,
                  ),
                ),

          title: Text(
            incident.category,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),

          subtitle: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [

              const SizedBox(height: 4),

              Text(
                incident.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 4),

              Text(
                '${incident.createdAt.day}/${incident.createdAt.month}/${incident.createdAt.year}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),

          trailing:
              const Icon(Icons.chevron_right),

          onTap: () {
            Navigator.pushNamed(
              context,
              '/incident-detail',
              arguments: incident,
            );
          },
        ),
      ),
    );
  }
}