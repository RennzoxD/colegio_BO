import 'package:flutter/material.dart';
import '../../services/parent_service.dart';

class ParentFeesScreen extends StatefulWidget {
  const ParentFeesScreen({super.key});

  @override
  State<ParentFeesScreen> createState() => _ParentFeesScreenState();
}

class _ParentFeesScreenState extends State<ParentFeesScreen> {
  final _service = ParentService();
  Map<String, dynamic>? _data;
  bool _loading = true;
  int _year = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final result = await _service.getFees(_year);
    setState(() {
      _loading = false;
      if (result['success']) _data = result['data'];
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = (_data?['items'] as List?) ?? [];
    final summary = _data?['summary'] as Map? ?? {};
    final pendiente = (summary['total_pendiente'] ?? 0).toDouble();
    final pagado    = (summary['total_pagado'] ?? 0).toDouble();
    final total     = (summary['total'] ?? 0).toDouble();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Estado de Cuenta'),
        backgroundColor: const Color(0xFFC62828),
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<int>(
            icon: const Icon(Icons.calendar_today),
            onSelected: (y) { setState(() => _year = y); _load(); },
            itemBuilder: (_) => [2024, 2025, 2026].map((y) =>
                PopupMenuItem(value: y, child: Text('$y'))).toList(),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(12),
              children: [
                // Resumen financiero
                Card(
                  color: const Color(0xFFC62828),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceAround,
                      children: [
                        _SummaryChip('Bs. ${total.toStringAsFixed(0)}',
                            'Total', Colors.white70),
                        _SummaryChip(
                            'Bs. ${pagado.toStringAsFixed(0)}',
                            'Pagado', Colors.green[200]!),
                        _SummaryChip(
                            'Bs. ${pendiente.toStringAsFixed(0)}',
                            'Pendiente', Colors.orange[200]!),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                if (items.isEmpty)
                  const Center(
                      child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('No hay cargos registrados'),
                  ))
                else
                  ...items.map((item) {
                    final estado = item['estado'] ?? 'pendiente';
                    final color = switch (estado) {
                      'pagado'    => Colors.green,
                      'parcial'   => Colors.blue,
                      'vencido'   => Colors.red,
                      'anulado'   => Colors.grey,
                      _           => Colors.orange,
                    };
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: color.withOpacity(0.15),
                          child: Icon(Icons.receipt, color: color),
                        ),
                        title: Text(item['concepto'] ?? 'Cargo',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600)),
                        subtitle: Text(
                          'Vence: ${item['vencimiento'] ?? '-'}  •  '
                          'Mes: ${item['month'] ?? '-'}'),
                        trailing: Column(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          crossAxisAlignment:
                              CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Bs. ${(item['monto'] ?? 0).toStringAsFixed(0)}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15)),
                            if ((item['saldo'] ?? 0) > 0)
                              Text(
                                'Saldo: Bs. ${(item['saldo'] ?? 0).toStringAsFixed(0)}',
                                style: TextStyle(
                                    color: color, fontSize: 11)),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.15),
                                borderRadius:
                                    BorderRadius.circular(6),
                              ),
                              child: Text(estado.toUpperCase(),
                                style: TextStyle(
                                    color: color,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
              ],
            ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const _SummaryChip(this.value, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
          style: TextStyle(color: color,
              fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label,
          style: TextStyle(color: color, fontSize: 12)),
      ],
    );
  }
}