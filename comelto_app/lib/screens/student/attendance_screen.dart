import 'package:flutter/material.dart';
import '../../services/me_service.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final _service = MeService();
  List _records = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await _service.getMyAttendance();
    setState(() { _records = data; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final presente  = _records.where((r) => r['estado'] == 'presente').length;
    final ausente   = _records.where((r) => r['estado'] == 'ausente').length;
    final tardanza  = _records.where((r) => r['estado'] == 'tardanza').length;
    final total     = _records.length;
    final pct = total > 0 ? (presente / total * 100).toStringAsFixed(1) : '0';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Asistencia'),
        backgroundColor: const Color(0xFFF57C00),
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _records.isEmpty
              ? const Center(child: Text('No hay registros de asistencia'))
              : Column(
                  children: [
                    // Resumen
                    Container(
                      margin: const EdgeInsets.all(12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF57C00),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _StatChip('$pct%', 'Asistencia', Colors.white),
                          _StatChip('$presente', 'Presente', Colors.green[100]!),
                          _StatChip('$ausente',  'Ausente',  Colors.red[100]!),
                          _StatChip('$tardanza', 'Tardanza', Colors.yellow[100]!),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: _records.length,
                        itemBuilder: (ctx, i) {
                          final r = _records[i];
                          final estado = r['estado'] ?? 'presente';
                          final color = switch (estado) {
                            'presente' => Colors.green,
                            'ausente'  => Colors.red,
                            'tardanza' => Colors.orange,
                            _          => Colors.grey,
                          };
                          return Card(
                            margin: const EdgeInsets.only(bottom: 6),
                            child: ListTile(
                              dense: true,
                              leading: CircleAvatar(
                                backgroundColor: color.withOpacity(0.15),
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
                              subtitle: r['observacion'] != null
                                  ? Text(r['observacion'])
                                  : null,
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
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

class _StatChip extends StatelessWidget {
  final String value;
  final String label;
  final Color bg;
  const _StatChip(this.value, this.label, this.bg);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          Text(value,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }
}