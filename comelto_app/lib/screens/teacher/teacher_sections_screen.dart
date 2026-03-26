import 'package:flutter/material.dart';
import '../../services/teacher_me_service.dart';
import 'teacher_section_detail_screen.dart';

class TeacherSectionsScreen extends StatefulWidget {
  const TeacherSectionsScreen({super.key});

  @override
  State<TeacherSectionsScreen> createState() => _TeacherSectionsScreenState();
}

class _TeacherSectionsScreenState extends State<TeacherSectionsScreen> {
  final _service = TeacherMeService();
  List _sections = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    final result = await _service.getMySections();
    setState(() {
      _loading = false;
      if (result['success']) {
        _sections = result['sections'];
      } else {
        _error = result['message'];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Secciones'),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_error!,
                        style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 12),
                    ElevatedButton(
                        onPressed: _load,
                        child: const Text('Reintentar')),
                  ]))
              : _sections.isEmpty
                  ? const Center(
                      child: Text('No tienes secciones asignadas'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _sections.length,
                      itemBuilder: (ctx, i) {
                        final s = _sections[i];
                        final nivel = s['nivel'] ?? '';
                        final paralelo = s['paralelo'] ?? s['section_name'] ?? '';
                        final course = s['course'];
                        final courseName = course?['nombre'] ?? '';
                        final students = s['students_count'] ?? 0;
                        final assignments = s['assignments'] as List? ?? [];

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => Navigator.push(context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        TeacherSectionDetailScreen(
                                            section: s))),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF1976D2)
                                              .withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.class_,
                                            color: Color(0xFF1976D2)),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '$courseName $paralelo',
                                              style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight:
                                                      FontWeight.bold),
                                            ),
                                            Text(
                                              nivel.toUpperCase(),
                                              style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 13),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.blue[50],
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text('$students alumnos',
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF1976D2),
                                              fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                                  if (assignments.isNotEmpty) ...[
                                    const SizedBox(height: 10),
                                    const Divider(height: 1),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 4,
                                      children: assignments.map((a) {
                                        final sub = a['subject'];
                                        return Chip(
                                          label: Text(
                                            sub?['nombre'] ?? 'Materia',
                                            style: const TextStyle(
                                                fontSize: 11)),
                                          backgroundColor:
                                              Colors.green[50],
                                          side: BorderSide.none,
                                          padding: EdgeInsets.zero,
                                          visualDensity:
                                              VisualDensity.compact,
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}