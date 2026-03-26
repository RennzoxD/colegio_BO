import 'package:flutter/material.dart';
import '../../services/parent_service.dart';

class ParentConductScreen extends StatefulWidget {
  const ParentConductScreen({super.key});

  @override
  State<ParentConductScreen> createState() =>
      _ParentConductScreenState();
}

class _ParentConductScreenState extends State<ParentConductScreen> {
  final _service = ParentService();
  List _records = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await _service.getConduct();
    setState(() { _records = data; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conducta'),
        backgroundColor: const Color(0xFFF57C00),
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _records.isEmpty
              ? const Center(
                  child: Text('Sin registros de conducta 🎉',
                    style: TextStyle(fontSize: 16)))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _records.length,
                  itemBuilder: (ctx, i) {
                    final r = _records[i];
                    final tipo = r['tipo'] ?? r['type'] ?? 'incidente';
                    final color = tipo == 'positivo' ||
                            tipo == 'positive'
                        ? Colors.green : Colors.orange;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: color.withOpacity(0.15),
                          child: Icon(
                            tipo == 'positivo' || tipo == 'positive'
                                ? Icons.thumb_up
                                : Icons.warning,
                            color: color),
                        ),
                        title: Text(
                          r['descripcion'] ?? r['description'] ??
                              'Incidente',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600)),
                        subtitle: Text(r['fecha'] ?? r['date'] ?? ''),
                        trailing: r['aprobado'] == true ||
                                r['approved'] == true
                            ? const Icon(Icons.check_circle,
                                color: Colors.green, size: 18)
                            : const Icon(Icons.pending,
                                color: Colors.orange, size: 18),
                      ),
                    );
                  },
                ),
    );
  }
}