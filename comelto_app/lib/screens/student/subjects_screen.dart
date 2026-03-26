import 'package:flutter/material.dart';
import '../../services/me_service.dart';

class SubjectsScreen extends StatefulWidget {
  const SubjectsScreen({super.key});

  @override
  State<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen> {
  final _service = MeService();
  List _subjects = [];
  bool _loading  = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await _service.getMySubjects();
    setState(() { _subjects = data; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Materias'),
        backgroundColor: const Color(0xFF00796B),
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _subjects.isEmpty
              ? const Center(
                  child: Text('No hay materias registradas'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _subjects.length,
                  itemBuilder: (ctx, i) {
                    final s = _subjects[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(10)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF00796B)
                              .withOpacity(0.1),
                          child: const Icon(Icons.menu_book,
                              color: Color(0xFF00796B)),
                        ),
                        title: Text(
                          s['nombre'] ?? 'Materia',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600)),
                        subtitle: s['nivel'] != null
                            ? Text(s['nivel'])
                            : null,
                      ),
                    );
                  },
                ),
    );
  }
}