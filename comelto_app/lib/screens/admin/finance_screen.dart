import 'package:flutter/material.dart';
import '../../services/admin_service.dart';

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key});

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen>
    with SingleTickerProviderStateMixin {
  final _service = AdminService();
  late TabController _tabs;
  int _year = DateTime.now().year;

  Map<String, dynamic>? _summary;
  List _overdue = [];
  bool _loadingSummary = true;
  bool _loadingOverdue = true;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _loadAll();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    _loadSummary();
    _loadOverdue();
  }

  Future<void> _loadSummary() async {
    setState(() => _loadingSummary = true);
    final res = await _service.getFinanceSummary(_year);
    setState(() {
      _loadingSummary = false;
      if (res['success']) _summary = res['data'];
    });
  }

  Future<void> _loadOverdue() async {
    setState(() => _loadingOverdue = true);
    final res = await _service.getOverdueCharges(_year);
    setState(() {
      _loadingOverdue = false;
      if (res['success']) {
        _overdue = res['data']['data'] ?? [];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finanzas'),
        backgroundColor: const Color(0xFF7B1FA2),
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
        ],
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(text: 'Resumen', icon: Icon(Icons.bar_chart)),
            Tab(text: 'Vencidos', icon: Icon(Icons.warning)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _buildSummary(),
          _buildOverdue(),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    if (_loadingSummary) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_summary == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('No se pudo cargar el resumen'),
            ElevatedButton(
                onPressed: _loadSummary,
                child: const Text('Reintentar')),
          ],
        ),
      );
    }

    final fin = _summary!['resumen_financiero'] as Map? ?? {};
    final estados = _summary!['resumen_estados'] as Map? ?? {};
    final total    = (fin['total_deuda'] ?? 0).toDouble();
    final pagado   = (fin['total_pagado'] ?? 0).toDouble();
    final pendiente = (fin['total_pendiente'] ?? 0).toDouble();
    final pct = (fin['porcentaje_recaudado'] ?? 0).toDouble();
    final cuentas = _summary!['cuentas'] as List? ?? [];

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        // Resumen general
        Card(
          color: const Color(0xFF7B1FA2),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text('Año $_year',
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceAround,
                  children: [
                    _FinChip(
                        'Bs. ${(total / 1000).toStringAsFixed(1)}K',
                        'Total', Colors.white70),
                    _FinChip(
                        'Bs. ${(pagado / 1000).toStringAsFixed(1)}K',
                        'Recaudado', Colors.green[200]!),
                    _FinChip(
                        'Bs. ${(pendiente / 1000).toStringAsFixed(1)}K',
                        'Pendiente', Colors.orange[200]!),
                  ],
                ),
                const SizedBox(height: 12),
                // Barra de progreso
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct / 100,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation(
                        Colors.greenAccent),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 4),
                Text('${pct.toStringAsFixed(1)}% recaudado',
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Estados
        Row(
          children: [
            Expanded(
              child: _EstadoCard(
                  '${estados['al_dia'] ?? 0}',
                  'Al día', Colors.green),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _EstadoCard(
                  '${estados['en_mora'] ?? 0}',
                  'En mora', Colors.red),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _EstadoCard(
                  '${estados['pendientes'] ?? 0}',
                  'Pendiente', Colors.orange),
            ),
          ],
        ),
        const SizedBox(height: 16),

        const Text('Detalle por estudiante',
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),

        ...cuentas.take(30).map((c) {
          final nombre = c['student_name'] ?? 'Estudiante';
          final saldo =
              (c['saldo_pendiente'] ?? 0).toDouble();
          final status = c['status'] ?? 'PENDIENTE';
          final color = status == 'AL_DIA'
              ? Colors.green
              : status == 'MORA'
                  ? Colors.red
                  : Colors.orange;

          return Card(
            margin: const EdgeInsets.only(bottom: 6),
            child: ListTile(
              dense: true,
              leading: CircleAvatar(
                backgroundColor: color.withOpacity(0.15),
                radius: 18,
                child: Icon(Icons.person,
                    color: color, size: 18),
              ),
              title: Text(nombre,
                style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13)),
              subtitle: Text(
                  c['section_name'] ?? c['nivel'] ?? ''),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Bs. ${saldo.toStringAsFixed(0)}',
                    style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold)),
                  Text(status,
                    style: TextStyle(
                        color: color, fontSize: 10)),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildOverdue() {
    if (_loadingOverdue) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_overdue.isEmpty) {
      return const Center(
          child: Text('🎉 No hay cargos vencidos'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _overdue.length,
      itemBuilder: (ctx, i) {
        final charge = _overdue[i];
        final account = charge['student_account'] as Map? ?? {};
        final student = account['student'] as Map? ?? {};
        final nombre =
            '${student['nombres'] ?? ''} ${student['apellidos'] ?? ''}'
                .trim();
        final monto = (charge['amount'] ?? 0).toDouble();
        final pagado =
            (charge['paid_amount'] ?? 0).toDouble();
        final saldo = monto - pagado;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFFFFEBEE),
              child: Icon(Icons.warning, color: Colors.red),
            ),
            title: Text(
              nombre.isNotEmpty ? nombre : 'Estudiante',
              style: const TextStyle(
                  fontWeight: FontWeight.w600)),
            subtitle: Text(
                '${charge['concept'] ?? 'Cargo'} • '
                'Vence: ${charge['due_date'] ?? '-'}'),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Bs. ${saldo.toStringAsFixed(0)}',
                  style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 14)),
                const Text('VENCIDO',
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 10,
                      fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FinChip extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const _FinChip(this.value, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
          style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 15)),
        Text(label, style: TextStyle(color: color, fontSize: 11)),
      ],
    );
  }
}

class _EstadoCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const _EstadoCard(this.value, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(value,
              style: TextStyle(
                  fontSize: 22,
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