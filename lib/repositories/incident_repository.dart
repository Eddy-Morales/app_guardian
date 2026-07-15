import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/incident_model.dart';
import 'dart:io';
class IncidentRepository {
  final SupabaseClient _supabase;

    // Constructor para inyección de dependencias
  IncidentRepository(this._supabase);


  // Obtener incidentes (Global para admin o filtrado para cliente)
  Future<List<IncidentModel>> getIncidents({String? userId, String? category, String? searchText}) async {
    try {
      var query = _supabase.from('incidents').select();
      
      // Si recibimos un userId, filtramos la consulta
      if (userId != null) {
        query = query.eq('user_id', userId);
      }

      // Si recibimos un category, filtramos la consulta
      if (category != null && category.isNotEmpty) {
        query = query.eq('category', category);
      }

      // Si recibimos un searchText, filtramos la consulta
      if (searchText != null && searchText.isNotEmpty) {
        query = query.or(
          'address.ilike.%$searchText%,description.ilike.%$searchText%',
        );
      }
      
      // Ordenamos para que los más recientes salgan primero
      final List<dynamic> data = await query.order('created_at', ascending: false);
      
      return data.map((e) => IncidentModel.fromMap(e)).toList();
    } catch (e) {
      throw Exception('Error al obtener incidentes: $e');
    }
  }

  // Crear un nuevo incidente
  Future<void> createIncident(
  IncidentModel incident,
  File? image,
) async {
  try {
    String? imageUrl;

    if (image != null) {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}.jpg';

      final path = 'incidents/$fileName';

      await _supabase.storage
          .from('incidents')
          .upload(path, image);

      imageUrl = _supabase.storage
          .from('incidents')
          .getPublicUrl(path);
    }

    final data = incident.toMap();

    data['photo_url'] = imageUrl;

    await _supabase
        .from('incidents')
        .insert(data);

  } catch (e) {
    throw Exception('Error al crear incidente: $e');
  }
}
  Future<void> updateIncident(
  IncidentModel incident,
  File? image,
) async {
  try {
    String? imageUrl = incident.photoUrl;

    if (image != null) {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}.jpg';

      final path = 'incidents/$fileName';

      await _supabase.storage
          .from('incidents')
          .upload(path, image);

      imageUrl = _supabase.storage
          .from('incidents')
          .getPublicUrl(path);
    }

    final data = incident.toMap();

    data['photo_url'] = imageUrl;

    await _supabase
        .from('incidents')
        .update(data)
        .eq('id', incident.id);

  } catch (e) {
    throw Exception('Error al actualizar incidente: $e');
  }
}

  // Eliminar un incidente (Admin o Propietario)
  Future<void> deleteIncident(String id) async {
    try {
      await _supabase.from('incidents').delete().eq('id', id);
    } catch (e) {
      throw Exception('Error al eliminar incidente: $e');
    }
  }
}