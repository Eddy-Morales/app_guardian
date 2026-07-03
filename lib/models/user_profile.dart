enum UserRole { admin, client }

class UserProfile {
  final String uid;
  final String name;
  final String email;
  final UserRole role;

  UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
  });

  // Mapea el JSON que viene de la tabla pública 'profiles' de Supabase
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'] as String,
      name: map['name'] ?? 'Usuario',
      email: map['email'] as String,
      role: map['role'] == 'admin' ? UserRole.admin : UserRole.client,
    );
  }
}