class CommentModel {
  final String id;
  final String incidentId;
  final String userId;
  final String message;
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.incidentId,
    required this.userId,
    required this.message,
    required this.createdAt,
  });

  factory CommentModel.fromMap(Map<String, dynamic> map) {
    return CommentModel(
      id: map['id'],
      incidentId: map['incident_id'],
      userId: map['user_id'],
      message: map['message'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'incident_id': incidentId,
      'user_id': userId,
      'message': message,
    };
  }
}