import 'package:flutter/material.dart';
import '../../services/me_service.dart';

class GradesScreen extends StatefulWidget {
  const GradesScreen({super.key});

  @override
  State<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends State<GradesScreen> {
  final _service = MeService();
  List _grades = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await _service.getMyGrades();
    setState(() { _grades = data; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    // Agrupar por materia
    final Map<String, List> grouped = {};
    for (final g in _grades) {
      final key = g['subject_nombre'] ?? 'Sin materia';
      grouped.putIfAbsent(key, () => []).add(g);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Notas'),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _grades.isEmpty
              ? const Center(child: Text('No hay notas registradas'))
              : ListView(
                  padding: const EdgeInsets.all(12),
                  children: grouped.entries.map((entry) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ExpansionTile(
                        title: Text(entry.key,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15)),
                        children: entry.value.map((g) {
                          final valor = g['valor'] ?? g['valor_qual'] ?? '-';
                          final color = _gradeColor(g['valor']);
                          return ListTile(
                            dense: true,
                            title: Text(g['evaluacion'] ?? 'Evaluación'),
                            subtitle: Text(
                                'Trimestre: ${g['term'] ?? '-'} • Peso: ${g['peso'] ?? '-'}%'),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text('$valor',
                                style: TextStyle(
                                    color: color,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16)),
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  }).toList(),
                ),
    );
  }

  Color _gradeColor(dynamic valor) {
    if (valor == null) return Colors.grey;
    final v = double.tryParse(valor.toString()) ?? 0;
    if (v >= 51) return Colors.green;
    if (v >= 36) return Colors.orange;
    return Colors.red;
  }
}