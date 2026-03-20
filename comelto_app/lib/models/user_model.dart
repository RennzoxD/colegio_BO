class UserModel {
  final int id;
  final String name;
  final String email;
  final String username;
  final String role;
  final List<String> abilities;
  final int? teacherId;
  final int? studentId;
  final bool mustChangePassword;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.username,
    required this.role,
    required this.abilities,
    this.teacherId,
    this.studentId,
    this.mustChangePassword = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id:                 json['id'],
      name:               json['name'] ?? '',
      email:              json['email'] ?? '',
      username:           json['username'] ?? '',
      role:               json['role'] ?? 'user',
      abilities:          List<String>.from(json['abilities'] ?? []),
      teacherId:          json['teacherId'],
      studentId:          json['studentId'],
      mustChangePassword: json['mustChangePassword'] ?? false,
    );
  }

  // Helpers de rol
  bool get isAdmin      => role == 'admin';
  bool get isTeacher    => role == 'teacher';
  bool get isStudent    => role == 'student';
  bool get isParent     => role == 'parent';
  bool get isDirector   => role == 'director_general' || role == 'director_academico';
  bool get isSecretaria => role == 'secretaria';
  bool get isFinanzas   => role == 'finanzas';
}