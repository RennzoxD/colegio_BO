import 'package:flutter/material.dart';
import '../../services/teacher_me_service.dart';

class TeacherHomeworksScreen extends StatefulWidget {
  const TeacherHomeworksScreen({super.key});

  @override
  State<TeacherHomeworksScreen> createState() =>
      _TeacherHomeworksScreenState();
}

class _TeacherHomeworksScreenState
    extends State<TeacherHomeworksScreen> {
  final _service = TeacherMeService();
  List _homeworks = [];
  List _sections  = [];
  bool _loading   = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final hw  = await _service.getMyHomeworks();
    final sec = await _service.getMySections();
    setState(() {
      _loading   = false;
      _homeworks = hw['success'] ? hw['homeworks'] : [];
      _sections  = sec['success'] ? sec['sections'] : [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Tareas'),
        backgroundColor: const Color(0xFF7B1FA2),
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(context),
        backgroundColor: const Color(0xFF7B1FA2),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _homeworks.isEmpty
              ? const Center(child: Text('No hay tareas creadas'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _homeworks.length,
                  itemBuilder: (ctx, i) {
                    final hw = _homeworks[i];
                    final estado = hw['estado'] ?? 'ABIERTA';
                    final color = estado == 'ABIERTA'
                        ? Colors.green : Colors.grey;
                    final subject = hw['subject'];
                    final section = hw['section'];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              const Color(0xFF7B1FA2).withOpacity(0.1),
                          child: const Icon(Icons.assignment,
                              color: Color(0xFF7B1FA2)),
                        ),
                        title: Text(hw['titulo'] ?? 'Tarea',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          '${subject?['nombre'] ?? ''} • '
                          '${section?['paralelo'] ?? ''}\n'
                          'Entrega: ${hw['fecha_entrega'] ?? 'Sin fecha'}'),
                        isThreeLine: true,
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(estado,
                            style: TextStyle(
                                color: color,
                                fontSize: 11,
                                fontWeight: FontWeight.bold)),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    if (_sections.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('No tienes secciones asignadas')));
      return;
    }

    final titulo      = TextEditingController();
    final descripcion = TextEditingController();
    Map<String, dynamic>? selectedSection;
    Map<String, dynamic>? selectedSubject;
    List subjects = [];
    DateTime? fechaEntrega;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => AlertDialog(
          title: const Text('Nueva Tarea'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titulo,
                  decoration: const InputDecoration(
                      labelText: 'Título *')),
                TextField(controller: descripcion,
                  maxLines: 3,
                  decoration: const InputDecoration(
                      labelText: 'Descripción')),
                const SizedBox(height: 8),
                // Sección
                DropdownButtonFormField<Map<String, dynamic>>(
                  decoration: const InputDecoration(
                      labelText: 'Sección *'),
                  items: _sections.map((s) {
                    final c = s['course'];
                    return DropdownMenuItem<Map<String, dynamic>>(
                      value: Map<String, dynamic>.from(s),
                      child: Text(
                        '${c?['nombre'] ?? ''} ${s['paralelo'] ?? ''}'),
                    );
                  }).toList(),
                  onChanged: (v) {
                    setSt(() {
                      selectedSection = v;
                      subjects = (v?['assignments'] as List? ?? [])
                          .map((a) => a['subject'])
                          .whereType<Map>()
                          .toList();
                      selectedSubject = null;
                    });
                  },
                ),
                const SizedBox(height: 8),
                // Materia
                if (subjects.isNotEmpty)
                  DropdownButtonFormField<Map<String, dynamic>>(
                    decoration: const InputDecoration(
                        labelText: 'Materia *'),
                    items: subjects.map((sub) =>
                      DropdownMenuItem<Map<String, dynamic>>(
                        value: Map<String, dynamic>.from(sub),
                        child: Text(sub['nombre'] ?? ''),
                      )).toList(),
                    onChanged: (v) =>
                        setSt(() => selectedSubject = v),
                  ),
                const SizedBox(height: 8),
                // Fecha entrega
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(fechaEntrega == null
                    ? 'Fecha de entrega (opcional)'
                    : 'Entrega: ${fechaEntrega!.day}/${fechaEntrega!.month}/${fechaEntrega!.year}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final p = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now()
                          .add(const Duration(days: 7)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2030),
                    );
                    if (p != null) setSt(() => fechaEntrega = p);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                if (titulo.text.isEmpty ||
                    selectedSection == null ||
                    selectedSubject == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Completa título, sección y materia')));
                  return;
                }
                final result = await _service.createHomework({
                  'titulo':           titulo.text.trim(),
                  'descripcion':      descripcion.text.trim(),
                  'section_id':       selectedSection!['id'],
                  'subject_id':       selectedSubject!['id'],
                  'year':             DateTime.now().year,
                  'fecha_asignacion': DateTime.now()
                      .toIso8601String().split('T')[0],
                  if (fechaEntrega != null)
                    'fecha_entrega': fechaEntrega!
                        .toIso8601String().split('T')[0],
                });
                if (result['success'] && ctx.mounted) {
                  Navigator.pop(ctx);
                  await _load();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('✅ Tarea creada'),
                        backgroundColor: Colors.green));
                } else if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                      content: Text(result['message'] ?? 'Error'),
                      backgroundColor: Colors.red));
                }
              },
              child: const Text('Crear')),
          ],
        ),
      ),
    );
  }
}