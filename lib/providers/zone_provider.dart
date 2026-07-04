import 'package:flutter/material.dart';
import '../models/zone_model.dart';
import '../repositories/zone_repository.dart';

class ZoneProvider extends ChangeNotifier {
  final ZoneRepository _zoneRepository;

  ZoneProvider(this._zoneRepository);

  List<ZoneModel> _zones = [];
  bool _isLoading = false;

  List<ZoneModel> get zones => _zones;
  bool get isLoading => _isLoading;

  // Cargar todas las zonas
  Future<void> loadZones() async {
    _setLoading(true);
    try {
      _zones = await _zoneRepository.getZones();
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Crear una zona
  Future<String?> addZone(ZoneModel zone) async {
    _setLoading(true);
    try {
      await _zoneRepository.createZone(zone);
      await loadZones(); // Refrescamos la lista para ver la nueva zona
      return null;
    } catch (e) {
      return e.toString().replaceAll('Exception: ', '');
    } finally {
      _setLoading(false);
    }
  }

  // Actualizar una zona
  Future<String?> editZone(String id, ZoneModel zone) async {
    _setLoading(true);
    try {
      await _zoneRepository.updateZone(id, zone);
      await loadZones(); 
      return null;
    } catch (e) {
      return e.toString().replaceAll('Exception: ', '');
    } finally {
      _setLoading(false);
    }
  }

  // Eliminar una zona
  Future<String?> removeZone(String id) async {
    _setLoading(true);
    try {
      await _zoneRepository.deleteZone(id);
      _zones.removeWhere((z) => z.id == id);
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