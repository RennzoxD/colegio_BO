import 'package:flutter/material.dart';
import '../../services/parent_service.dart';

class ParentGradesScreen extends StatefulWidget {
  const ParentGradesScreen({super.key});

  @override
  State<ParentGradesScreen> createState() => _ParentGradesScreenState();
}

class _ParentGradesScreenState extends State<ParentGradesScreen> {
  final _service = ParentService();
  Map<String, dynamic>? _data;
  bool _loading = true;
  String? _error;
  int _year = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    final result = await _service.getGrades(_year);
    setState(() {
      _loading = false;
      if (result['success']) {
        _data = result['data'];
      } else {
        _error = result['message'];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final rows = (_data?['rows'] as List?) ?? [];
    final student = _data?['student'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notas'),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        actions: [
          // Selector de año
          PopupMenuButton<int>(
            icon: const Icon(Icons.calendar_today),
            onSelected: (y) {
              setState(() => _year = y);
              _load();
            },
            itemBuilder: (_) => [2024, 2025, 2026].map((y) =>
                PopupMenuItem(value: y, child: Text('$y'))).toList(),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!,
                  style: const TextStyle(color: Colors.red)))
              : rows.isEmpty
                  ? const Center(
                      child: Text('No hay notas registradas'))
                  : ListView(
                      padding: const EdgeInsets.all(12),
                      children: [
                        if (student != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              '${student['nombres']} ${student['apellidos']} — Año $_year',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15)),
                          ),
                        // Tabla de notas
                        Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columnSpacing: 16,
                              columns: const [
                                DataColumn(label: Text('Materia',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('T1')),
                                DataColumn(label: Text('T2')),
                                DataColumn(label: Text('T3')),
                                DataColumn(label: Text('PA')),
                                DataColumn(label: Text('Estado')),
                              ],
                              rows: rows.map((r) {
                                final estado = r['estado'] ?? '-';
                                final color = estado == 'APROBADO'
                                    ? Colors.green
                                    : estado == 'REPROBADO'
                                        ? Colors.red
                                        : Colors.orange;
                                return DataRow(cells: [
                                  DataCell(Text(
                                    r['materia_nombre'] ?? '-',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600))),
                                  DataCell(Text('${r['t1'] ?? '-'}')),
                                  DataCell(Text('${r['t2'] ?? '-'}')),
                                  DataCell(Text('${r['t3'] ?? '-'}')),
                                  DataCell(Text('${r['pa'] ?? '-'}')),
                                  DataCell(Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: color.withOpacity(0.15),
                                      borderRadius:
                                          BorderRadius.circular(8),
                                    ),
                                    child: Text(estado,
                                      style: TextStyle(
                                          color: color,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold)),
                                  )),
                                ]);
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
    );
  }
}