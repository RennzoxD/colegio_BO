import 'package:flutter/material.dart';
import '../../services/report_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final _service = ReportService();
  int _year = DateTime.now().year;
  bool _loading = true;

  // Stats
  int _totalStudents = 0;
  int _totalTeachers = 0;
  int _totalSections = 0;
  int _totalActas    = 0;

  // Finance
  double _totalDebt     = 0;
  double _totalPaid     = 0;
  double _totalPending  = 0;
  double _pctRecaudado  = 0;
  int _enMora     = 0;
  int _alDia      = 0;
  List _overdue   = [];

  // Actas por estado
  int _actasDraft     = 0;
  int _actasPublished = 0;
  int _actasLocked    = 0;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() => _loading = true);

    final results = await Future.wait([
      _service.getStudentStats(),
      _service.getTeacherStats(),
      _service.getSectionStats(_year),
      _service.getActaStats(_year),
      _service.getFinanceSummary(_year),
      _service.getOverdueCharges(_year),
    ]);

    final students  = results[0] as Map;
    final teachers  = results[1] as Map;
    final sections  = results[2] as Map;
    final actas     = results[3] as Map;
    final finance   = results[4] as Map;
    final overdue   = results[5] as List;

    final fin = finance['success'] == true
        ? (finance['data']?['resumen_financiero'] as Map? ?? {})
        : {};
    final estados = finance['success'] == true
        ? (finance['data']?['resumen_estados'] as Map? ?? {})
        : {};

    // Actas por estado
    final actaData = actas['data'];
    int draft = 0, published = 0, locked = 0;
    if (actaData != null) {
      final list = actaData['data'] as List? ?? [];
      for (final a in list) {
        switch (a['status']) {
          case 'DRAFT':     draft++; break;
          case 'PUBLISHED': published++; break;
          case 'LOCKED':    locked++; break;
        }
      }
    }

    setState(() {
      _loading        = false;
      _totalStudents  = students['total'] ?? 0;
      _totalTeachers  = teachers['total'] ?? 0;
      _totalSections  = sections['total'] ?? 0;
      _totalActas     = actas['total'] ?? 0;
      _totalDebt      = (fin['total_deuda'] ?? 0).toDouble();
      _totalPaid      = (fin['total_pagado'] ?? 0).toDouble();
      _totalPending   = (fin['total_pendiente'] ?? 0).toDouble();
      _pctRecaudado   = (fin['porcentaje_recaudado'] ?? 0).toDouble();
      _enMora         = estados['en_mora'] ?? 0;
      _alDia          = estados['al_dia'] ?? 0;
      _overdue        = overdue;
      _actasDraft     = draft;
      _actasPublished = published;
      _actasLocked    = locked;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes'),
        backgroundColor: const Color(0xFF00796B),
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<int>(
            icon: const Icon(Icons.calendar_today),
            onSelected: (y) {
              setState(() => _year = y);
              _loadAll();
            },
            itemBuilder: (_) => [2024, 2025, 2026].map((y) =>
                PopupMenuItem(value: y, child: Text('$y'))).toList(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAll,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadAll,
              child: ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  // Header año
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00796B).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.bar_chart,
                            color: Color(0xFF00796B)),
                        const SizedBox(width: 8),
                        Text('Resumen General — Año $_year',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Color(0xFF00796B))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Stats institucionales
                  const _SectionTitle('📊 Institución'),
                  const SizedBox(height: 8),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.8,
                    children: [
                      _StatCard('$_totalStudents', 'Estudiantes',
                          Icons.people, Colors.blue),
                      _StatCard('$_totalTeachers', 'Docentes',
                          Icons.school, Colors.green),
                      _StatCard('$_totalSections', 'Secciones',
                          Icons.class_, Colors.orange),
                      _StatCard('$_totalActas', 'Actas',
                          Icons.assignment, Colors.red),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Actas por estado
                  const _SectionTitle('📝 Estado de Actas'),
                  const SizedBox(height: 8),
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _ActaBar('Publicadas', _actasPublished,
                              _totalActas, Colors.green),
                          const SizedBox(height: 8),
                          _ActaBar('Bloqueadas', _actasLocked,
                              _totalActas, Colors.blue),
                          const SizedBox(height: 8),
                          _ActaBar('Borrador', _actasDraft,
                              _totalActas, Colors.orange),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Finanzas
                  const _SectionTitle('💰 Finanzas'),
                  const SizedBox(height: 8),
                  Card(
                    color: const Color(0xFF00796B),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceAround,
                            children: [
                              _FinStat(
                                'Bs. ${(_totalDebt / 1000).toStringAsFixed(1)}K',
                                'Total', Colors.white70),
                              _FinStat(
                                'Bs. ${(_totalPaid / 1000).toStringAsFixed(1)}K',
                                'Recaudado', Colors.greenAccent),
                              _FinStat(
                                'Bs. ${(_totalPending / 1000).toStringAsFixed(1)}K',
                                'Pendiente', Colors.orangeAccent),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: _totalDebt > 0
                                  ? _pctRecaudado / 100 : 0,
                              backgroundColor: Colors.white24,
                              valueColor:
                                  const AlwaysStoppedAnimation(
                                      Colors.greenAccent),
                              minHeight: 10,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${_pctRecaudado.toStringAsFixed(1)}% recaudado',
                            style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _MiniCard(
                          '$_alDia', 'Al día',
                          Colors.green)),
                      const SizedBox(width: 8),
                      Expanded(child: _MiniCard(
                          '$_enMora', 'En mora',
                          Colors.red)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Vencidos recientes
                  if (_overdue.isNotEmpty) ...[
                    const _SectionTitle('⚠️ Pagos Vencidos Recientes'),
                    const SizedBox(height: 8),
                    ..._overdue.take(5).map((charge) {
                      final account =
                          charge['student_account'] as Map? ?? {};
                      final student =
                          account['student'] as Map? ?? {};
                      final nombre =
                          '${student['nombres'] ?? ''} ${student['apellidos'] ?? ''}'
                              .trim();
                      final monto =
                          (charge['amount'] ?? 0).toDouble();
                      final pagado =
                          (charge['paid_amount'] ?? 0).toDouble();
                      final saldo = monto - pagado;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 6),
                        child: ListTile(
                          dense: true,
                          leading: const Icon(Icons.warning,
                              color: Colors.red),
                          title: Text(
                            nombre.isNotEmpty
                                ? nombre : 'Estudiante',
                            style: const TextStyle(
                                fontWeight: FontWeight.w600)),
                          subtitle: Text(
                              charge['concept'] ?? 'Cargo'),
                          trailing: Text(
                            'Bs. ${saldo.toStringAsFixed(0)}',
                            style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold)),
                        ),
                      );
                    }),
                  ],
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}

// ─── Widgets auxiliares ───────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(title,
      style: const TextStyle(
          fontSize: 16, fontWeight: FontWeight.bold));
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  const _StatCard(this.value, this.label, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(value,
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: color)),
                Text(label,
                  style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600])),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActaBar extends StatelessWidget {
  final String label;
  final int value;
  final int total;
  final Color color;
  const _ActaBar(this.label, this.value, this.total, this.color);

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? value / total : 0.0;
    return Row(
      children: [
        SizedBox(width: 90,
            child: Text(label,
              style: const TextStyle(fontSize: 13))),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 8,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text('$value',
          style: TextStyle(
              color: color, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _FinStat extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const _FinStat(this.value, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
          style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 15)),
        Text(label,
          style: TextStyle(color: color, fontSize: 11)),
      ],
    );
  }
}

class _MiniCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const _MiniCard(this.value, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(value,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color)),
            Text(label,
              style: TextStyle(
                  fontSize: 12, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }
}