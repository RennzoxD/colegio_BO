import 'package:flutter/material.dart';
import '../../services/teacher_me_service.dart';
import 'teacher_attendance_take_screen.dart';

class TeacherAttendanceScreen extends StatefulWidget {
  const TeacherAttendanceScreen({super.key});

  @override
  State<TeacherAttendanceScreen> createState() =>
      _TeacherAttendanceScreenState();
}

class _TeacherAttendanceScreenState
    extends State<TeacherAttendanceScreen> {
  final _service = TeacherMeService();
  List _sections = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await _service.getMySections();
    setState(() {
      _loading = false;
      if (result['success']) _sections = result['sections'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tomar Asistencia'),
        backgroundColor: const Color(0xFF388E3C),
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _sections.isEmpty
              ? const Center(
                  child: Text('No tienes secciones asignadas'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _sections.length,
                  itemBuilder: (ctx, i) {
                    final s = _sections[i];
                    final course = s['course'];
                    final title =
                        '${course?['nombre'] ?? ''} ${s['paralelo'] ?? ''}';
                    final students = s['students_count'] ?? 0;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFF388E3C),
                          child: Icon(Icons.class_,
                              color: Colors.white),
                        ),
                        title: Text(title,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold)),
                        subtitle: Text('$students estudiantes'),
                        trailing: ElevatedButton.icon(
                          onPressed: () async {
                            final studs = await _service
                                .getSectionStudents(s['id']);
                            if (context.mounted) {
                              Navigator.push(context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          TeacherAttendanceTakeScreen(
                                              section: s,
                                              students: studs)));
                            }
                          },
                          icon: const Icon(Icons.how_to_reg,
                              size: 16),
                          label: const Text('Tomar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xFF388E3C),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}