class IncidentModel {
  final String id;
  final String userId;
  final String category;
  final String description;
  final double lat;
  final double lng;
  final String? photoUrl;
  final DateTime createdAt;

  IncidentModel({
    required this.id,
    required this.userId,
    required this.category,
    required this.description,
    required this.lat,
    required this.lng,
    this.photoUrl,
    required this.createdAt,
  });

  factory IncidentModel.fromMap(Map<String, dynamic> map) {
    return IncidentModel(
      id: map['id'] ?? '',
      userId: map['user_id'] ?? '',
      category: map['category'] ?? '',
      description: map['description'] ?? '',
      lat: (map['lat'] as num).toDouble(),
      lng: (map['lng'] as num).toDouble(),
      photoUrl: map['photo_url'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'category': category,
      'description': description,
      'lat': lat,
      'lng': lng,
      'photo_url': photoUrl,
    };
  }
}