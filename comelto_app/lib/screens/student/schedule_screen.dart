import 'package:flutter/material.dart';
import '../../services/me_service.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final _service = MeService();
  List _schedule = [];
  bool _loading = true;

  final _dias = ['Lunes','Martes','Miércoles','Jueves','Viernes'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await _service.getMySchedule();
    setState(() { _schedule = data; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, List> grouped = {};
    for (final s in _schedule) {
      final dia = s['dia'] ?? 'Otro';
      grouped.putIfAbsent(dia, () => []).add(s);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Horario'),
        backgroundColor: const Color(0xFF388E3C),
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _schedule.isEmpty
              ? const Center(child: Text('No hay horario registrado'))
              : ListView(
                  padding: const EdgeInsets.all(12),
                  children: _dias.where((d) => grouped.containsKey(d)).map((dia) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            decoration: const BoxDecoration(
                              color: Color(0xFF388E3C),
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(12)),
                            ),
                            child: Text(dia,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15)),
                          ),
                          ...grouped[dia]!.map((s) => ListTile(
                            dense: true,
                            leading: const Icon(Icons.access_time,
                                color: Color(0xFF388E3C)),
                            title: Text(s['materia'] ?? 'Materia',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600)),
                            subtitle: Text(s['docente'] ?? ''),
                            trailing: Text(
                              '${s['inicio'] ?? ''} - ${s['fin'] ?? ''}',
                              style: const TextStyle(fontSize: 12,
                                  color: Colors.grey)),
                          )),
                        ],
                      ),
                    );
                  }).toList(),
                ),
    );
  }
}