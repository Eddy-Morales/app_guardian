class ZoneModel {
  final String id;
  final String name;
  final String riskLevel;
  final int incidentCount;
  final double? centerLat;
  final double? centerLng;
  final double? radiusKm;

  ZoneModel({
    required this.id,
    required this.name,
    required this.riskLevel,
    required this.incidentCount,
    this.centerLat,
    this.centerLng,
    this.radiusKm,
  });

  factory ZoneModel.fromMap(Map<String, dynamic> map) {
    return ZoneModel(
      id: map['id'],
      name: map['name'],
      riskLevel: map['risk_level'],
      incidentCount: map['incident_count'] ?? 0,
      centerLat: (map['center_lat'] as num?)?.toDouble(),
      centerLng: (map['center_lng'] as num?)?.toDouble(),
      radiusKm: (map['radius_km'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'risk_level': riskLevel,
      'incident_count': incidentCount,
      'center_lat': centerLat,
      'center_lng': centerLng,
      'radius_km': radiusKm,
    };
  }
}