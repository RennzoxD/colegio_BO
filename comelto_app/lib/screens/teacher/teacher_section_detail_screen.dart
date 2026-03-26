import 'package:flutter/material.dart';
import '../../services/teacher_me_service.dart';
import 'teacher_attendance_take_screen.dart';

class TeacherSectionDetailScreen extends StatefulWidget {
  final Map<String, dynamic> section;
  const TeacherSectionDetailScreen({super.key, required this.section});

  @override
  State<TeacherSectionDetailScreen> createState() =>
      _TeacherSectionDetailScreenState();
}

class _TeacherSectionDetailScreenState
    extends State<TeacherSectionDetailScreen> {
  final _service = TeacherMeService();
  List _students = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    final sectionId = widget.section['id'];
    final data = await _service.getSectionStudents(sectionId);
    setState(() { _students = data; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.section;
    final course = s['course'];
    final title =
        '${course?['nombre'] ?? ''} ${s['paralelo'] ?? s['section_name'] ?? ''}';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.how_to_reg),
            tooltip: 'Tomar asistencia',
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(
                    builder: (_) => TeacherAttendanceTakeScreen(
                        section: widget.section,
                        students: _students))),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _students.isEmpty
              ? const Center(child: Text('No hay estudiantes inscritos'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _students.length,
                  itemBuilder: (ctx, i) {
                    final st = _students[i];
                    final nombre =
                        '${st['nombres'] ?? ''} ${st['apellidos'] ?? ''}';
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            const Color(0xFF1976D2).withOpacity(0.15),
                        child: Text(
                          nombre.isNotEmpty
                              ? nombre[0].toUpperCase() : '?',
                          style: const TextStyle(
                              color: Color(0xFF1976D2),
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(nombre.trim(),
                          style: const TextStyle(
                              fontWeight: FontWeight.w600)),
                      subtitle: Text(st['codigo'] ?? ''),
                    );
                  },
                ),
    );
  }
}