import 'package:flutter/material.dart';
import '../../services/parent_service.dart';

class ParentAttendanceScreen extends StatefulWidget {
  const ParentAttendanceScreen({super.key});

  @override
  State<ParentAttendanceScreen> createState() =>
      _ParentAttendanceScreenState();
}

class _ParentAttendanceScreenState
    extends State<ParentAttendanceScreen> {
  final _service = ParentService();
  List _records = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await _service.getAttendance();
    setState(() { _records = data; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final presente  = _records.where((r) => r['estado'] == 'presente').length;
    final ausente   = _records.where((r) => r['estado'] == 'ausente').length;
    final tardanza  = _records.where((r) => r['estado'] == 'tardanza').length;
    final total     = _records.length;
    final pct = total > 0
        ? (presente / total * 100).toStringAsFixed(1) : '0';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Asistencia'),
        backgroundColor: const Color(0xFF388E3C),
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _records.isEmpty
              ? const Center(child: Text('Sin registros de asistencia'))
              : Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.all(12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF388E3C),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceAround,
                        children: [
                          _Chip('$pct%', 'Asistencia', Colors.white),
                          _Chip('$presente', 'Presente',
                              Colors.green[100]!),
                          _Chip('$ausente', 'Ausente',
                              Colors.red[100]!),
                          _Chip('$tardanza', 'Tardanza',
                              Colors.yellow[100]!),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12),
                        itemCount: _records.length,
                        itemBuilder: (ctx, i) {
                          final r = _records[i];
                          final estado = r['estado'] ?? 'presente';
                          final color = switch (estado) {
                            'presente'    => Colors.green,
                            'ausente'     => Colors.red,
                            'tardanza'    => Colors.orange,
                            'justificado' => Colors.blue,
                            _             => Colors.grey,
                          };
                          return Card(
                            margin: const EdgeInsets.only(bottom: 6),
                            child: ListTile(
                              dense: true,
                              leading: CircleAvatar(
                                backgroundColor:
                                    color.withOpacity(0.15),
                                child: Icon(
                                  estado == 'presente'
                                      ? Icons.check_circle
                                      : estado == 'ausente'
                                          ? Icons.cancel
                                          : Icons.watch_later,
                                  color: color, size: 20),
                              ),
                              title: Text(r['fecha'] ?? '',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.15),
                                  borderRadius:
                                      BorderRadius.circular(8),
                                ),
                                child: Text(estado.toUpperCase(),
                                  style: TextStyle(
                                      color: color,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold)),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String value;
  final String label;
  final Color bg;
  const _Chip(this.value, this.label, this.bg);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: [
          Text(value, style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }
}