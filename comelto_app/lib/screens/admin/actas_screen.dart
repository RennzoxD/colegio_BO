import 'package:flutter/material.dart';
import '../../services/admin_service.dart';

class ActasScreen extends StatefulWidget {
  const ActasScreen({super.key});

  @override
  State<ActasScreen> createState() => _ActasScreenState();
}

class _ActasScreenState extends State<ActasScreen> {
  final _service = AdminService();
  List _actas = [];
  bool _loading = true;
  String? _nivelFiltro;
  String? _termFiltro;
  int _year = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final res = await _service.getActas(
        year: _year,
        nivel: _nivelFiltro,
        term: _termFiltro);
    setState(() {
      _loading = false;
      _actas = res['success'] ? res['actas'] : [];
    });
  }

  Color _statusColor(String? status) => switch (status) {
    'PUBLISHED' => Colors.green,
    'LOCKED'    => Colors.blue,
    'DRAFT'     => Colors.orange,
    _           => Colors.grey,
  };

  IconData _statusIcon(String? status) => switch (status) {
    'PUBLISHED' => Icons.check_circle,
    'LOCKED'    => Icons.lock,
    'DRAFT'     => Icons.edit,
    _           => Icons.help,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Actas'),
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
      body: Column(
        children: [
          // Filtros
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String?>(
                    value: _nivelFiltro,
                    decoration: const InputDecoration(
                        labelText: 'Nivel',
                        isDense: true,
                        border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(
                          value: null, child: Text('Todos')),
                      DropdownMenuItem(
                          value: 'inicial',
                          child: Text('Inicial')),
                      DropdownMenuItem(
                          value: 'primaria',
                          child: Text('Primaria')),
                      DropdownMenuItem(
                          value: 'secundaria',
                          child: Text('Secundaria')),
                    ],
                    onChanged: (v) {
                      setState(() => _nivelFiltro = v);
                      _load();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String?>(
                    value: _termFiltro,
                    decoration: const InputDecoration(
                        labelText: 'Trimestre',
                        isDense: true,
                        border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(
                          value: null, child: Text('Todos')),
                      DropdownMenuItem(
                          value: 'T1', child: Text('T1')),
                      DropdownMenuItem(
                          value: 'T2', child: Text('T2')),
                      DropdownMenuItem(
                          value: 'T3', child: Text('T3')),
                    ],
                    onChanged: (v) {
                      setState(() => _termFiltro = v);
                      _load();
                    },
                  ),
                ),
              ],
            ),
          ),

          // Stats rápidos
          if (!_loading)
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 4),
              child: Row(
                children: [
                  _QuickStat('${_actas.length}',
                      'Total', Colors.grey),
                  const SizedBox(width: 8),
                  _QuickStat(
                    '${_actas.where((a) => a['status'] == 'PUBLISHED').length}',
                    'Publicadas', Colors.green),
                  const SizedBox(width: 8),
                  _QuickStat(
                    '${_actas.where((a) => a['status'] == 'DRAFT').length}',
                    'Borrador', Colors.orange),
                ],
              ),
            ),

          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator())
                : _actas.isEmpty
                    ? const Center(
                        child: Text('No hay actas'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _actas.length,
                        itemBuilder: (ctx, i) {
                          final a = _actas[i];
                          final status =
                              a['status'] ?? 'DRAFT';
                          final color =
                              _statusColor(status);
                          final icon = _statusIcon(status);

                          return Card(
                            margin: const EdgeInsets.only(
                                bottom: 8),
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                        10)),
                            child: InkWell(
                              borderRadius:
                                  BorderRadius.circular(10),
                              onTap: () =>
                                  _showActaDetail(
                                      context, a),
                              child: Padding(
                                padding:
                                    const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor:
                                          color.withOpacity(
                                              0.15),
                                      child: Icon(icon,
                                          color: color,
                                          size: 20),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment
                                                .start,
                                        children: [
                                          Text(
                                            a['materia_nombre'] ??
                                                'Materia',
                                            style: const TextStyle(
                                                fontWeight:
                                                    FontWeight
                                                        .bold,
                                                fontSize: 14)),
                                          Text(
                                            '${a['docente_nombre'] ?? ''} • '
                                            '${(a['nivel'] ?? '').toUpperCase()} '
                                            'Grado ${a['grado'] ?? ''} ${a['seccion'] ?? ''}',
                                            style: TextStyle(
                                                color: Colors
                                                    .grey[600],
                                                fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment
                                              .end,
                                      children: [
                                        Container(
                                          padding:
                                              const EdgeInsets
                                                  .symmetric(
                                                  horizontal: 8,
                                                  vertical: 3),
                                          decoration:
                                              BoxDecoration(
                                            color:
                                                color.withOpacity(
                                                    0.15),
                                            borderRadius:
                                                BorderRadius
                                                    .circular(8),
                                          ),
                                          child: Text(status,
                                            style: TextStyle(
                                                color: color,
                                                fontSize: 11,
                                                fontWeight:
                                                    FontWeight
                                                        .bold)),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          a['term'] ?? '',
                                          style: TextStyle(
                                              color: Colors
                                                  .grey[500],
                                              fontSize: 12)),
                                      ],
                                    ),
                                  ],
                                ),
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

  void _showActaDetail(
      BuildContext context, Map<String, dynamic> acta) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(acta['materia_nombre'] ?? 'Acta',
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Docente: ${acta['docente_nombre'] ?? '-'}',
              style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 12),
            const Divider(),
            _DetailRow('Nivel',
                (acta['nivel'] ?? '').toUpperCase()),
            _DetailRow('Grado',
                '${acta['grado'] ?? ''} ${acta['seccion'] ?? ''}'),
            _DetailRow('Trimestre', acta['term'] ?? '-'),
            _DetailRow('Año', '${acta['year'] ?? '-'}'),
            _DetailRow('Estado', acta['status'] ?? '-'),
            if (acta['published_at'] != null)
              _DetailRow('Publicada',
                  acta['published_at'].toString().split('T')[0]),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 100,
              child: Text(label,
                style: TextStyle(color: Colors.grey[600]))),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _QuickStat extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const _QuickStat(this.value, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text('$value $label',
        style: TextStyle(
            color: color, fontWeight: FontWeight.bold)),
    );
  }
}