enum UserRole { admin, client }

class UserProfile {
  final String uid;
  final String name;
  final String email;
  final String role;

  UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
  });

  // Mapea el JSON que viene de la tabla pública 'profiles' de Supabase
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      uid: json['uid'] as String,
      name: json['name'] ?? 'Usuario',
      email: json['email'] as String,
      role: json['role'] ?? 'client',
    );
  }
}