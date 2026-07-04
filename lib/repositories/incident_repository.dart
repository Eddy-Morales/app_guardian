import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/incident_model.dart';


class IncidentRepository {
  final SupabaseClient _supabase;

    // Constructor para inyección de dependencias
  IncidentRepository(this._supabase);


  // Obtener incidentes (Global para admin o filtrado para cliente)
  Future<List<IncidentModel>> getIncidents({String? userId}) async {
    try {
      var query = _supabase.from('incidents').select();
      
      // Si recibimos un userId, filtramos la consulta
      if (userId != null) {
        query = query.eq('user_id', userId);
      }
      
      // Ordenamos para que los más recientes salgan primero
      final List<dynamic> data = await query.order('created_at', ascending: false);
      
      return data.map((e) => IncidentModel.fromMap(e)).toList();
    } catch (e) {
      throw Exception('Error al obtener incidentes: $e');
    }
  }

  // Crear un nuevo incidente
  Future<void> createIncident(IncidentModel incident) async {
    try {
      await _supabase.from('incidents').insert(incident.toMap());
    } catch (e) {
      throw Exception('Error al crear incidente: $e');
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