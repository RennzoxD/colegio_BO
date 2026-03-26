import 'package:flutter/material.dart';
import '../../services/me_service.dart';

class FeesScreen extends StatefulWidget {
  const FeesScreen({super.key});

  @override
  State<FeesScreen> createState() => _FeesScreenState();
}

class _FeesScreenState extends State<FeesScreen> {
  final _service = MeService();
  List _fees = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await _service.getMyFees();
    setState(() { _fees = data; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final pendiente = _fees.where((f) =>
        f['status'] == 'PENDING' || f['status'] == 'OVERDUE').length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Pagos'),
        backgroundColor: const Color(0xFFC62828),
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _fees.isEmpty
              ? const Center(child: Text('No hay registros de pago'))
              : Column(
                  children: [
                    if (pendiente > 0)
                      Container(
                        margin: const EdgeInsets.all(12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.red),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.warning, color: Colors.red),
                            const SizedBox(width: 8),
                            Text('Tienes $pendiente pago(s) pendiente(s)',
                              style: const TextStyle(color: Colors.red,
                                  fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: _fees.length,
                        itemBuilder: (ctx, i) {
                          final f = _fees[i];
                          final status = f['status'] ?? 'PENDING';
                          final color = switch (status) {
                            'PAID'    => Colors.green,
                            'PENDING' => Colors.orange,
                            'OVERDUE' => Colors.red,
                            _         => Colors.grey,
                          };
                          final amount = f['amount'] ?? f['pending_amount'] ?? 0;
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: color.withOpacity(0.15),
                                child: Icon(Icons.receipt,
                                    color: color),
                              ),
                              title: Text(f['concept'] ?? 'Concepto',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                              subtitle: Text(
                                  'Mes: ${f['month'] ?? '-'} • Vence: ${f['due_date'] ?? '-'}'),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('Bs. $amount',
                                    style: TextStyle(
                                        color: color,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15)),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: color.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(status,
                                      style: TextStyle(
                                          color: color, fontSize: 10,
                                          fontWeight: FontWeight.bold)),
                                  ),
                                ],
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