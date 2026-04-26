import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/student_provider.dart';
import '../../models/student_model.dart';
import 'student_detail_screen.dart';

class StudentsScreen extends ConsumerStatefulWidget {
  const StudentsScreen({super.key});

  @override
  ConsumerState<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends ConsumerState<StudentsScreen> {
  final _searchCtrl = TextEditingController();
  String? _nivelFiltro;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(studentProvider.notifier).load());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(studentProvider);
    final total = state.students.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: const Text('Estudiantes'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Actualizar',
            onPressed: () => ref
                .read(studentProvider.notifier)
                .load(q: _searchCtrl.text, nivel: _nivelFiltro),
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner informativo
          Container(
            width: double.infinity,
            color: const Color(0xFF1565C0),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.people_alt_rounded,
                          color: Colors.white, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        state.isLoading
                            ? 'Cargando...'
                            : '$total estudiante${total == 1 ? '' : 's'}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                const Icon(Icons.info_outline, color: Colors.white54, size: 14),
                const SizedBox(width: 4),
                const Text(
                  'Gestión desde la web',
                  style: TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ],
            ),
          ),

          // Barra de búsqueda y filtro
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: InputDecoration(
                      hintText: 'Buscar por nombre o código...',
                      hintStyle: const TextStyle(fontSize: 13),
                      prefixIcon: const Icon(Icons.search,
                          color: Color(0xFF1565C0), size: 20),
                      suffixIcon: _searchCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchCtrl.clear();
                                ref
                                    .read(studentProvider.notifier)
                                    .load(nivel: _nivelFiltro);
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: Color(0xFF1565C0)),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF5F7FA),
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 0),
                    ),
                    onChanged: (v) {
                      setState(() {});
                      ref
                          .read(studentProvider.notifier)
                          .load(q: v, nivel: _nivelFiltro);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F7FA),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String?>(
                      value: _nivelFiltro,
                      hint: const Text('Nivel',
                          style: TextStyle(fontSize: 13)),
                      icon: const Icon(Icons.keyboard_arrow_down,
                          size: 18),
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
                        ref
                            .read(studentProvider.notifier)
                            .load(q: _searchCtrl.text, nivel: v);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Chips de nivel rápido
          if (!state.isLoading && state.students.isNotEmpty)
            _LevelSummaryBar(students: state.students),

          // Lista
          Expanded(
            child: state.isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFF1565C0)))
                : state.error != null
                    ? _ErrorView(
                        message: state.error!,
                        onRetry: () => ref
                            .read(studentProvider.notifier)
                            .load())
                    : state.students.isEmpty
                        ? _EmptyView(hasFilter: _searchCtrl.text.isNotEmpty || _nivelFiltro != null)
                        : ListView.builder(
                            padding: const EdgeInsets.only(
                                top: 8, bottom: 80),
                            itemCount: state.students.length,
                            itemBuilder: (ctx, i) => _StudentTile(
                                student: state.students[i]),
                          ),
          ),
        ],
      ),
    );
  }
}

// ─── Barra de resumen por nivel ────────────────────────────────

class _LevelSummaryBar extends StatelessWidget {
  final List<StudentModel> students;
  const _LevelSummaryBar({required this.students});

  @override
  Widget build(BuildContext context) {
    final counts = <String, int>{
      'inicial': 0,
      'primaria': 0,
      'secundaria': 0,
    };
    for (final s in students) {
      counts[s.nivel] = (counts[s.nivel] ?? 0) + 1;
    }

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      child: Row(
        children: [
          _LevelChip('Inicial', counts['inicial']!, Colors.orange),
          const SizedBox(width: 6),
          _LevelChip('Primaria', counts['primaria']!, Colors.blue),
          const SizedBox(width: 6),
          _LevelChip(
              'Secundaria', counts['secundaria']!, Colors.green),
        ],
      ),
    );
  }
}

class _LevelChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _LevelChip(this.label, this.count, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        '$label: $count',
        style: TextStyle(
            color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}

// ─── Tile de estudiante ─────────────────────────────────────────

class _StudentTile extends ConsumerWidget {
  final StudentModel student;
  const _StudentTile({required this.student});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = switch (student.nivel) {
      'inicial' => Colors.orange,
      'primaria' => Colors.blue,
      'secundaria' => Colors.green,
      _ => Colors.grey,
    };

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      elevation: 1,
      shadowColor: Colors.black12,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) =>
                  StudentDetailScreen(student: student))),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 24,
                backgroundColor: color,
                child: Text(
                  student.nombres.isNotEmpty
                      ? student.nombres[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
              ),
              const SizedBox(width: 12),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.nombreCompleto,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: Color(0xFF1A237E)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      student.codigo,
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey[500]),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _MiniChip(
                          label: student.nivel.substring(0, 1).toUpperCase() +
                              student.nivel.substring(1),
                          color: color,
                        ),
                        const SizedBox(width: 4),
                        _MiniChip(
                          label:
                              '${student.curso} - ${student.paralelo}',
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Estado + flecha
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: student.activo
                          ? Colors.green[50]
                          : Colors.red[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      student.activo ? 'Activo' : 'Inactivo',
                      style: TextStyle(
                        color: student.activo
                            ? Colors.green[700]
                            : Colors.red[700],
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Icon(Icons.chevron_right,
                      color: Colors.grey[400], size: 20),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  final String label;
  final Color color;
  const _MiniChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
            fontSize: 10,
            color: color.withOpacity(0.8),
            fontWeight: FontWeight.w600),
      ),
    );
  }
}

// ─── Vistas auxiliares ──────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  final bool hasFilter;
  const _EmptyView({required this.hasFilter});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_rounded,
              size: 56, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text(
            hasFilter
                ? 'No se encontraron resultados'
                : 'No hay estudiantes registrados',
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
          if (hasFilter) ...[
            const SizedBox(height: 6),
            Text(
              'Intenta con otro criterio de búsqueda',
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 12),
          Text(message,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}