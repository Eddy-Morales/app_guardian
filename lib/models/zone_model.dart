class ZoneModel {
  final String id;
  final String name;
  final String riskLevel;
  final int incidentCount;

  ZoneModel({
    required this.id,
    required this.name,
    required this.riskLevel,
    required this.incidentCount,
  });

  factory ZoneModel.fromMap(Map<String, dynamic> map) {
    return ZoneModel(
      id: map['id'],
      name: map['name'],
      riskLevel: map['risk_level'],
      incidentCount: map['incident_count'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'risk_level': riskLevel,
      'incident_count': incidentCount,
    };
  }
}