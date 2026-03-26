import 'package:flutter/material.dart';
import '../../services/teacher_me_service.dart';

class TeacherAttendanceTakeScreen extends StatefulWidget {
  final Map<String, dynamic> section;
  final List students;
  const TeacherAttendanceTakeScreen(
      {super.key, required this.section, required this.students});

  @override
  State<TeacherAttendanceTakeScreen> createState() =>
      _TeacherAttendanceTakeScreenState();
}

class _TeacherAttendanceTakeScreenState
    extends State<TeacherAttendanceTakeScreen> {
  final _service = TeacherMeService();
  final Map<int, String> _estados = {};
  bool _saving = false;
  DateTime _fecha = DateTime.now();

  final _opciones = ['presente', 'ausente', 'tardanza', 'justificado'];
  final _colores = {
    'presente':    Colors.green,
    'ausente':     Colors.red,
    'tardanza':    Colors.orange,
    'justificado': Colors.blue,
  };

  @override
  void initState() {
    super.initState();
    // Por defecto todos presentes
    for (final st in widget.students) {
      _estados[st['id']] = 'presente';
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final records = widget.students.map((st) => {
      'student_id': st['id'],
      'section_id': widget.section['id'],
      'fecha':      _fecha.toIso8601String().split('T')[0],
      'estado':     _estados[st['id']] ?? 'presente',
    }).toList();

    final result = await _service.submitAttendance(records);
    setState(() => _saving = false);

    if (result['success'] && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('✅ Asistencia guardada'),
          backgroundColor: Colors.green));
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(result['message'] ?? 'Error al guardar'),
          backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.section;
    final course = s['course'];
    final title =
        '${course?['nombre'] ?? ''} ${s['paralelo'] ?? ''}';

    // Conteo rápido
    final presentes =
        _estados.values.where((e) => e == 'presente').length;
    final ausentes =
        _estados.values.where((e) => e == 'ausente').length;

    return Scaffold(
      appBar: AppBar(
        title: Text('Asistencia - $title'),
        backgroundColor: const Color(0xFF388E3C),
        foregroundColor: Colors.white,
        actions: [
          _saving
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(width: 20, height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2)))
              : IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: _save,
                  tooltip: 'Guardar asistencia'),
        ],
      ),
      body: Column(
        children: [
          // Fecha y resumen
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.grey[100],
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 18),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _fecha,
                      firstDate: DateTime(2024),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() => _fecha = picked);
                    }
                  },
                  child: Text(
                    '${_fecha.day}/${_fecha.month}/${_fecha.year}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                const Spacer(),
                Text('✅ $presentes  ❌ $ausentes',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          // Lista de estudiantes
          Expanded(
            child: ListView.builder(
              itemCount: widget.students.length,
              itemBuilder: (ctx, i) {
                final st = widget.students[i];
                final id = st['id'] as int;
                final nombre =
                    '${st['nombres'] ?? ''} ${st['apellidos'] ?? ''}'.trim();
                final estado = _estados[id] ?? 'presente';
                final color = _colores[estado] ?? Colors.grey;

                return Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: color.withOpacity(0.15),
                          child: Text(
                            nombre.isNotEmpty
                                ? nombre[0].toUpperCase() : '?',
                            style: TextStyle(
                                color: color,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(nombre,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600)),
                        ),
                        // Botones de estado
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: _opciones.map((op) {
                            final c = _colores[op]!;
                            final selected = estado == op;
                            final icons = {
                              'presente':    Icons.check_circle,
                              'ausente':     Icons.cancel,
                              'tardanza':    Icons.watch_later,
                              'justificado': Icons.info,
                            };
                            return IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                  minWidth: 32, minHeight: 32),
                              icon: Icon(icons[op],
                                color: selected ? c
                                    : c.withOpacity(0.25),
                                size: 26),
                              onPressed: () =>
                                  setState(() => _estados[id] = op),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saving ? null : _save,
        backgroundColor: const Color(0xFF388E3C),
        icon: const Icon(Icons.save, color: Colors.white),
        label: const Text('Guardar',
            style: TextStyle(color: Colors.white)),
      ),
    );
  }
}