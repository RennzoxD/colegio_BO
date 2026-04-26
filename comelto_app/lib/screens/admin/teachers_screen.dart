import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/teacher_provider.dart';
import '../../models/teacher_model.dart';
import 'teacher_detail_screen.dart';

class TeachersScreen extends ConsumerStatefulWidget {
  const TeachersScreen({super.key});

  @override
  ConsumerState<TeachersScreen> createState() => _TeachersScreenState();
}

class _TeachersScreenState extends ConsumerState<TeachersScreen> {
  final _searchCtrl = TextEditingController();
  String? _estadoFiltro;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(teacherProvider.notifier).load());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(teacherProvider);
    final total = state.teachers.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: const Text('Docentes'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Actualizar',
            onPressed: () => ref
                .read(teacherProvider.notifier)
                .load(q: _searchCtrl.text),
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner
          Container(
            width: double.infinity,
            color: const Color(0xFF2E7D32),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.school_rounded,
                          color: Colors.white, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        state.isLoading
                            ? 'Cargando...'
                            : '$total docente${total == 1 ? '' : 's'}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                const Icon(Icons.info_outline,
                    color: Colors.white54, size: 14),
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
                      hintText: 'Buscar por nombre o CI...',
                      hintStyle: const TextStyle(fontSize: 13),
                      prefixIcon: const Icon(Icons.search,
                          color: Color(0xFF2E7D32), size: 20),
                      suffixIcon: _searchCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchCtrl.clear();
                                setState(() {});
                                ref
                                    .read(teacherProvider.notifier)
                                    .load();
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
                            const BorderSide(color: Color(0xFF2E7D32)),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF5F7FA),
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 0),
                    ),
                    onChanged: (v) {
                      setState(() {});
                      ref.read(teacherProvider.notifier).load(q: v);
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
                      value: _estadoFiltro,
                      hint: const Text('RDA',
                          style: TextStyle(fontSize: 13)),
                      icon: const Icon(Icons.keyboard_arrow_down,
                          size: 18),
                      items: const [
                        DropdownMenuItem(
                            value: null, child: Text('Todos')),
                        DropdownMenuItem(
                            value: 'VIGENTE',
                            child: Text('Vigente')),
                        DropdownMenuItem(
                            value: 'OBSERVADO',
                            child: Text('Observado')),
                        DropdownMenuItem(
                            value: 'VENCIDO',
                            child: Text('Vencido')),
                      ],
                      onChanged: (v) {
                        setState(() => _estadoFiltro = v);
                        // Nota: aplica filtro local si el provider lo soporta
                        ref
                            .read(teacherProvider.notifier)
                            .load(q: _searchCtrl.text);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Barra de resumen RDA
          if (!state.isLoading && state.teachers.isNotEmpty)
            _RdaSummaryBar(teachers: state.teachers),

          // Lista
          Expanded(
            child: state.isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFF2E7D32)))
                : state.error != null
                    ? _ErrorView(
                        message: state.error!,
                        color: const Color(0xFF2E7D32),
                        onRetry: () =>
                            ref.read(teacherProvider.notifier).load())
                    : state.teachers.isEmpty
                        ? _EmptyView(
                            hasFilter: _searchCtrl.text.isNotEmpty)
                        : ListView.builder(
                            padding: const EdgeInsets.only(
                                top: 8, bottom: 24),
                            itemCount: state.teachers.length,
                            itemBuilder: (ctx, i) =>
                                _TeacherTile(
                                    teacher: state.teachers[i]),
                          ),
          ),
        ],
      ),
    );
  }
}

// ─── Barra resumen RDA ──────────────────────────────────────────

class _RdaSummaryBar extends StatelessWidget {
  final List<TeacherModel> teachers;
  const _RdaSummaryBar({required this.teachers});

  @override
  Widget build(BuildContext context) {
    int vigente = 0, observado = 0, vencido = 0;
    for (final t in teachers) {
      switch (t.rdaEstado) {
        case 'VIGENTE':
          vigente++;
          break;
        case 'OBSERVADO':
          observado++;
          break;
        default:
          vencido++;
      }
    }
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      child: Row(
        children: [
          _RdaChip('Vigente', vigente, Colors.green),
          const SizedBox(width: 6),
          _RdaChip('Observado', observado, Colors.orange),
          const SizedBox(width: 6),
          _RdaChip('Vencido', vencido, Colors.red),
        ],
      ),
    );
  }
}

class _RdaChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _RdaChip(this.label, this.count, this.color);

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

// ─── Tile de docente ────────────────────────────────────────────

class _TeacherTile extends ConsumerWidget {
  final TeacherModel teacher;
  const _TeacherTile({required this.teacher});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rdaColor = switch (teacher.rdaEstado) {
      'VIGENTE' => Colors.green,
      'OBSERVADO' => Colors.orange,
      _ => Colors.red,
    };
    final estadoColor = switch (teacher.estado) {
      'activo' => Colors.green,
      'licencia' => Colors.blue,
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
                  TeacherDetailScreen(teacher: teacher))),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFF2E7D32),
                child: Text(
                  teacher.nombres.isNotEmpty
                      ? teacher.nombres[0].toUpperCase()
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
                      teacher.nombreCompleto,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: Color(0xFF1B5E20)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      teacher.email,
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey[500]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _MiniChip(
                          label: 'RDA: ${teacher.rdaEstado}',
                          color: rdaColor,
                        ),
                        const SizedBox(width: 4),
                        _MiniChip(
                          label: teacher.estado
                              .substring(0, 1)
                              .toUpperCase() +
                              teacher.estado.substring(1),
                          color: estadoColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Flecha
              Icon(Icons.chevron_right,
                  color: Colors.grey[400], size: 20),
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
            color: color.withOpacity(0.85),
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
                : 'No hay docentes registrados',
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final Color color;
  final VoidCallback onRetry;
  const _ErrorView(
      {required this.message, required this.color, required this.onRetry});

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
            style:
                ElevatedButton.styleFrom(backgroundColor: color),
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, color: Colors.white),
            label: const Text('Reintentar',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}