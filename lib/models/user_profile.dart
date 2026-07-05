enum UserRole { admin, client }

class UserProfile {
  final String uid;
  final String name;
  final String email;
  final String role;
  final bool blocked; 
  final DateTime createdAt;

  UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.blocked,
    required this.createdAt
  });

  // Mapea el JSON que viene de la tabla pública 'profiles' de Supabase
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      uid: json['uid'] as String,
      name: json['name'] ?? 'Usuario',
      email: json['email'] as String,
      role: json['role'] ?? 'client',
      blocked: json['blocked'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
   Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,
      'blocked': blocked,
      'created_at': createdAt.toIso8601String(),
    };
   }
}