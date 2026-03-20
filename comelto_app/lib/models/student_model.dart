class StudentModel {
  final int id;
  final String nombres;
  final String apellidos;
  final String codigo;
  final String nivel;
  final String curso;
  final String paralelo;
  final String? email;
  final String? ci;
  final String? telefono;
  final bool activo;

  StudentModel({
    required this.id,
    required this.nombres,
    required this.apellidos,
    required this.codigo,
    required this.nivel,
    required this.curso,
    required this.paralelo,
    this.email,
    this.ci,
    this.telefono,
    required this.activo,
  });

  String get nombreCompleto => '$nombres $apellidos';

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id:        json['id'],
      nombres:   json['nombres'] ?? '',
      apellidos: json['apellidos'] ?? '',
      codigo:    json['codigo'] ?? '',
      nivel:     json['nivel'] ?? '',
      curso:     json['curso'] ?? '',
      paralelo:  json['paralelo'] ?? '',
      email:     json['email'],
      ci:        json['ci'],
      telefono:  json['telefono'],
      activo:    json['activo'] ?? true,
    );
  }
}