import 'package:flutter/material.dart';
import '../models/incident_model.dart';
import '../repositories/incident_repository.dart';
import 'dart:io';

class IncidentProvider extends ChangeNotifier {
  final IncidentRepository _incidentRepository;

  IncidentProvider(this._incidentRepository);

  List<IncidentModel> _incidents = [];
  bool _isLoading = false;
  String? _errorMessage;
  // Filtros activos (se conservan para poder refrescar con "loadIncidents")
  String? _categoryFilter;
  String _searchText = '';

  List<IncidentModel> get incidents => _incidents;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get categoryFilter => _categoryFilter;
  String get searchText => _searchText;

  // Cargar incidentes (filtra por userId si se le pasa como parámetro)
  Future<void> loadIncidents({String? userId}) async {
    _setLoading(true);
    try {
      _incidents = await _incidentRepository.getIncidents(userId: userId, category: _categoryFilter, searchText: _searchText);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      debugPrint(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// Aplica un filtro por categoría ('' o null = sin filtro) y recarga.
  Future<void> filterByCategory(String? category, {String? userId}) async {
    _categoryFilter = (category == null || category.isEmpty) ? null : category;
    await loadIncidents(userId: userId);
  }
  /// Búsqueda de texto libre por título/descripción.
  Future<void> search(String text, {String? userId}) async {
    _searchText = text;
    await loadIncidents(userId: userId);
  }

  void clearFilters() {
    _categoryFilter = null;
    _searchText = '';
  }

  // Crear un incidente
  Future<String?> addIncident(IncidentModel incident, File? image) async {
    _setLoading(true);
    try {
      await _incidentRepository.createIncident(incident,image);
      await loadIncidents(); // Recargamos la lista para traer el incidente con su ID generado
      return null;
    } catch (e) {
      return e.toString().replaceAll('Exception: ', '');
    } finally {
      _setLoading(false);
    }
  }
  // Actualizar un incidente
  Future<String?> updateIncident(IncidentModel incident, File? image,) async {

    _setLoading(true);

    try {
      await _incidentRepository.updateIncident(incident,image);
      await loadIncidents();
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