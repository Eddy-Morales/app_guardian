import 'package:flutter/material.dart';
import '/models/incident_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/theme.dart';
import '../../utils/category_utils.dart';
import '../../widgets/comments_section.dart';


class IncidentDetailScreen extends StatelessWidget {

  const IncidentDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    

    final incident =
        ModalRoute.of(context)
            ?.settings
            .arguments as IncidentModel?;
    if (incident == null){
      return const Scaffold(
        body: Center(
          child: Text('Incidente no encontrado'),
        ),
      );
    }

    final currentUserId =
        Supabase.instance.client.auth.currentUser?.id;

    final canEdit =
        currentUserId == incident.userId;
    final color = CategoryUtils.colorOf(incident.category);

    

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Incidente: ${incident.category}',
        ),
      actions: canEdit
            ? [
                IconButton(
                  tooltip: 'Editar incidente',
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/incident-form',
                      arguments: incident,
                    );
                  },
                ),
              ]
            : null,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [

            // FOTO
            if (incident.photoUrl != null)
              ClipRRect(
                borderRadius:
                    BorderRadius.circular(12),
                child: Image.network(
                  incident.photoUrl!,
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                ),
              ),

            const SizedBox(height: 20),

            // CATEGORIA
            const Text(
              'Categoría',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.grey,
              ),
            ),

            Text(
              incident.category,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 20),

            // DESCRIPCION
            const Text(
              'Descripción',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.grey,
              ),
            ),

            Text(
              incident.description,
              style: const TextStyle(
                color: Colors.black, // Texto negro
              ),
            ),

            const SizedBox(height: 20),

            // FECHA
            const Text(
              'Fecha',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.grey,
              ),
            ),

            Text(
              '${incident.createdAt.day}/${incident.createdAt.month}/${incident.createdAt.year}',
              style: const TextStyle(
                color: Colors.black, // Texto negro
              ),
            ),

            const SizedBox(height: 20),

            // LATITUD
            const Text(
              'Latitud',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),

            Text(
              incident.lat.toString(),
              style: const TextStyle(
                color: Colors.black, // Texto negro
              ),              
            ),

            const SizedBox(height: 10),

            // LONGITUD
            const Text(
              'Longitud',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),

            Text(
              incident.lng.toString(),
              style: const TextStyle(
                color: Colors.black, // Texto negro
              ),
            ),

            const SizedBox(height: 10),
            const Text(
              'Direccion aproximada',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),

            Text(
              incident.address ?? 'No disponible',
              style: TextStyle(
                fontSize: 14,
                color: color, // Color asociado a la categoría
              ),
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 8),

            // Comentarios en tiempo real del incidente
            CommentsSection(incidentId: incident.id),

          ],
        ),
      ),
    );
  }
}