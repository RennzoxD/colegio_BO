import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/student_provider.dart';
import '../../models/student_model.dart';

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
  Widget build(BuildContext context) {
    final state = ref.watch(studentProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Estudiantes'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(context),
        backgroundColor: const Color(0xFF1565C0),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          // Barra de búsqueda y filtro
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: InputDecoration(
                      hintText: 'Buscar por nombre o código...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                    onChanged: (v) => ref.read(studentProvider.notifier)
                        .load(q: v, nivel: _nivelFiltro),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String?>(
                  value: _nivelFiltro,
                  hint: const Text('Nivel'),
                  items: const [
                    DropdownMenuItem(value: null,         child: Text('Todos')),
                    DropdownMenuItem(value: 'inicial',    child: Text('Inicial')),
                    DropdownMenuItem(value: 'primaria',   child: Text('Primaria')),
                    DropdownMenuItem(value: 'secundaria', child: Text('Secundaria')),
                  ],
                  onChanged: (v) {
                    setState(() => _nivelFiltro = v);
                    ref.read(studentProvider.notifier)
                        .load(q: _searchCtrl.text, nivel: v);
                  },
                ),
              ],
            ),
          ),

          // Lista
          Expanded(
            child: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : state.error != null
                ? Center(child: Text(state.error!,
                    style: const TextStyle(color: Colors.red)))
                : state.students.isEmpty
                  ? const Center(child: Text('No hay estudiantes'))
                  : ListView.builder(
                      itemCount: state.students.length,
                      itemBuilder: (ctx, i) =>
                          _StudentTile(student: state.students[i]),
                    ),
          ),
        ],
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    final nombres   = TextEditingController();
    final apellidos = TextEditingController();
    final curso     = TextEditingController();
    final paralelo  = TextEditingController();
    final email     = TextEditingController();
    String nivel    = 'primaria';
    final anio      = DateTime.now().year.toString();
    final mes       = DateTime.now().month.toString().padLeft(2, '0');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nuevo Estudiante'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nombres,
                decoration: const InputDecoration(labelText: 'Nombres *')),
              TextField(controller: apellidos,
                decoration: const InputDecoration(labelText: 'Apellidos *')),
              const SizedBox(height: 8),
              StatefulBuilder(
                builder: (ctx, setSt) => DropdownButtonFormField<String>(
                  value: nivel,
                  decoration: const InputDecoration(labelText: 'Nivel'),
                  items: const [
                    DropdownMenuItem(value: 'inicial',    child: Text('Inicial')),
                    DropdownMenuItem(value: 'primaria',   child: Text('Primaria')),
                    DropdownMenuItem(value: 'secundaria', child: Text('Secundaria')),
                  ],
                  onChanged: (v) => setSt(() => nivel = v!),
                ),
              ),
              TextField(controller: curso,
                decoration: const InputDecoration(labelText: 'Curso *')),
              TextField(controller: paralelo,
                decoration: const InputDecoration(labelText: 'Paralelo *')),
              TextField(controller: email,
                decoration: const InputDecoration(labelText: 'Email (opcional)')),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              if (nombres.text.isEmpty || apellidos.text.isEmpty ||
                  curso.text.isEmpty  || paralelo.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Completa los campos obligatorios')));
                return;
              }
              final ok = await ref.read(studentProvider.notifier).create({
                'nombres':      nombres.text.trim(),
                'apellidos':    apellidos.text.trim(),
                'nivel':        nivel,
                'curso':        curso.text.trim(),
                'paralelo':     paralelo.text.trim(),
                'email':        email.text.trim().isEmpty ? null : email.text.trim(),
                'anio_ingreso': anio,
                'mes_ingreso':  mes,
              });
              if (ok && ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✅ Estudiante creado'),
                    backgroundColor: Colors.green));
              }
            },
            child: const Text('Crear')),
        ],
      ),
    );
  }
}

class _StudentTile extends ConsumerWidget {
  final StudentModel student;
  const _StudentTile({required this.student});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = switch (student.nivel) {
      'inicial'    => Colors.orange,
      'primaria'   => Colors.blue,
      'secundaria' => Colors.green,
      _            => Colors.grey,
    };

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Text(student.nombres[0],
            style: const TextStyle(color: Colors.white,
                fontWeight: FontWeight.bold)),
        ),
        title: Text(student.nombreCompleto,
          style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('${student.codigo} • ${student.nivel} '
            '${student.curso}-${student.paralelo}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: student.activo ? Colors.green[100] : Colors.red[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                student.activo ? 'Activo' : 'Inactivo',
                style: TextStyle(
                  color: student.activo ? Colors.green[800] : Colors.red[800],
                  fontSize: 12),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _confirmDelete(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar estudiante?'),
        content: Text('Se eliminará a ${student.nombreCompleto}. '
            'Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              ref.read(studentProvider.notifier).delete(student.id);
              Navigator.pop(ctx);
            },
            child: const Text('Eliminar',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}