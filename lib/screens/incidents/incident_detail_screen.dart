import 'package:flutter/material.dart';
import '/models/incident_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

    

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Incidente: ${incident.category}',
        ),
      ),
      floatingActionButton: canEdit
          ? FloatingActionButton(
            child: const Icon(Icons.edit),
            onPressed:(){
              Navigator.pushNamed(
                context,
                '/incident-form',
                arguments: incident,
              );
            }
          )
        : null,

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
              ),
            ),

            Text(
              incident.category,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 20),

            // DESCRIPCION
            const Text(
              'Descripción',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),

            Text(
              incident.description,
            ),

            const SizedBox(height: 20),

            // FECHA
            const Text(
              'Fecha',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),

            Text(
              '${incident.createdAt.day}/${incident.createdAt.month}/${incident.createdAt.year}',
            ),

            const SizedBox(height: 20),

            // LATITUD
            const Text(
              'Latitud',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            Text(
              incident.lat.toString(),
            ),

            const SizedBox(height: 10),

            // LONGITUD
            const Text(
              'Longitud',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            Text(
              incident.lng.toString(),
            ),
          ],
        ),
      ),
    );
  }
}