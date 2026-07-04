import 'package:flutter/material.dart';
import '../models/incident_model.dart';
import '../repositories/incident_repository.dart';

class IncidentProvider extends ChangeNotifier {
  final IncidentRepository _incidentRepository;

  IncidentProvider(this._incidentRepository);

  List<IncidentModel> _incidents = [];
  bool _isLoading = false;

  List<IncidentModel> get incidents => _incidents;
  bool get isLoading => _isLoading;

  // Cargar incidentes (filtra por userId si se le pasa como parámetro)
  Future<void> loadIncidents({String? userId}) async {
    _setLoading(true);
    try {
      _incidents = await _incidentRepository.getIncidents(userId: userId);
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Crear un incidente
  Future<String?> addIncident(IncidentModel incident) async {
    _setLoading(true);
    try {
      await _incidentRepository.createIncident(incident);
      await loadIncidents(); // Recargamos la lista para traer el incidente con su ID generado
      return null;
    } catch (e) {
      return e.toString().replaceAll('Exception: ', '');
    } finally {
      _setLoading(false);
    }
  }

  // Eliminar un incidente
  Future<String?> removeIncident(String id) async {
    _setLoading(true);
    try {
      await _incidentRepository.deleteIncident(id);
      _incidents.removeWhere((incident) => incident.id == id); // Actualizamos la lista local
      return null;
    } catch (e) {
      return e.toString().replaceAll('Exception: ', '');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}