class TeacherModel {
  final int id;
  final String nombres;
  final String apellidos;
  final String email;
  final String? telefono;
  final String? ci;
  final String? rdaNumero;
  final String rdaEstado;
  final String estado;
  final String usuario;

  TeacherModel({
    required this.id,
    required this.nombres,
    required this.apellidos,
    required this.email,
    this.telefono,
    this.ci,
    this.rdaNumero,
    required this.rdaEstado,
    required this.estado,
    required this.usuario,
  });

  String get nombreCompleto => '$nombres $apellidos';

  factory TeacherModel.fromJson(Map<String, dynamic> json) {
    return TeacherModel(
      id:        json['id'],
      nombres:   json['nombres'] ?? '',
      apellidos: json['apellidos'] ?? '',
      email:     json['email'] ?? '',
      telefono:  json['telefono'],
      ci:        json['ci'],
      rdaNumero: json['rda_numero'],
      rdaEstado: json['rda_estado'] ?? 'VIGENTE',
      estado:    json['estado'] ?? 'activo',
      usuario:   json['usuario'] ?? '',
    );
  }
}