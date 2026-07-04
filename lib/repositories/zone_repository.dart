import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/zone_model.dart';

class ZoneRepository {
  final SupabaseClient _supabase;

  ZoneRepository(this._supabase);

  // Leer todas las zonas
  Future<List<ZoneModel>> getZones() async {
    try {
      final List<dynamic> data = await _supabase.from('zones').select().order('name', ascending: true);
      return data.map((e) => ZoneModel.fromMap(e)).toList();
    } catch (e) {
      throw Exception('Error al obtener zonas: $e');
    }
  }

  // Crear una nueva zona
  Future<void> createZone(ZoneModel zone) async {
    try {
      await _supabase.from('zones').insert(zone.toMap());
    } catch (e) {
      throw Exception('Error al crear zona: $e');
    }
  }

  // Actualizar una zona existente
  Future<void> updateZone(String id, ZoneModel zone) async {
    try {
      await _supabase.from('zones').update(zone.toMap()).eq('id', id);
    } catch (e) {
      throw Exception('Error al actualizar zona: $e');
    }
  }

  // Eliminar una zona
  Future<void> deleteZone(String id) async {
    try {
      await _supabase.from('zones').delete().eq('id', id);
    } catch (e) {
      throw Exception('Error al eliminar zona: $e');
    }
  }
}