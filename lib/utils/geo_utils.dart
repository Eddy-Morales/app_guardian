import 'dart:math';
import '../models/zone_model.dart';

/// Utilidad para cálculos geográficos simples (sin depender de
/// PostGIS ni de ninguna librería externa).
class GeoUtils {
  GeoUtils._();

  static const double _earthRadiusKm = 6371;

  /// Distancia en kilómetros entre dos coordenadas (fórmula de Haversine).
  static double distanceKm(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    final dLat = _degToRad(lat2 - lat1);
    final dLng = _degToRad(lng2 - lng1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(lat1)) *
            cos(_degToRad(lat2)) *
            sin(dLng / 2) *
            sin(dLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return _earthRadiusKm * c;
  }

  static double _degToRad(double deg) => deg * (pi / 180);

  /// Entre las zonas con centro configurado, retorna la más cercana
  /// cuyo radio de cobertura efectivamente contiene el punto
  /// (lat, lng). Si el punto no cae dentro de ninguna, retorna null
  /// (el incidente queda sin zona asignada).
  static ZoneModel? findZoneFor(
    double lat,
    double lng,
    List<ZoneModel> zones,
  ) {
    ZoneModel? closest;
    double closestDistance = double.infinity;

    for (final zone in zones) {
      if (zone.centerLat == null || zone.centerLng == null) continue;

      final radius = zone.radiusKm ?? 1.0;
      final distance =
          distanceKm(lat, lng, zone.centerLat!, zone.centerLng!);

      if (distance <= radius && distance < closestDistance) {
        closest = zone;
        closestDistance = distance;
      }
    }
    return closest;
  }
}