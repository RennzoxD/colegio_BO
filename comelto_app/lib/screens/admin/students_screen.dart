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
    ref.read(studentProvider.notifier).clearError();
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
              final result = await ref.read(studentProvider.notifier)
                  .createAndReturn({
                'nombres':      nombres.text.trim(),
                'apellidos':    apellidos.text.trim(),
                'nivel':        nivel,
                'curso':        curso.text.trim(),
                'paralelo':     paralelo.text.trim(),
                'email':        email.text.trim().isEmpty ? null : email.text.trim(),
                'anio_ingreso': anio,
                'mes_ingreso':  mes,
              });

              if (result != null && ctx.mounted) {
                Navigator.pop(ctx);
                // Mostrar credenciales
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Row(children: [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 8),
                      Text('Estudiante Creado'),
                    ]),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Credenciales de acceso:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        _CredentialRow(
                          icon: Icons.person,
                          label: 'Usuario',
                          value: result['user']?['username'] ?? '-'),
                        const SizedBox(height: 8),
                        _CredentialRow(
                          icon: Icons.lock,
                          label: 'Contraseña temporal',
                          value: result['password_temp'] ?? '-'),
                        const SizedBox(height: 8),
                        _CredentialRow(
                          icon: Icons.badge,
                          label: 'Código',
                          value: result['student']?['codigo'] ?? '-'),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.orange[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.orange)),
                          child: const Text(
                            '⚠️ Guarda estas credenciales.\nEl estudiante deberá cambiar su contraseña al primer ingreso.',
                            style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                    actions: [
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Entendido')),
                    ],
                  ),
                );
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
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => StudentDetailScreen(student: student))),
        leading: CircleAvatar(
          backgroundColor: color,
          child: Text(
            student.nombres.isNotEmpty ? student.nombres[0] : '?', // ✅ FIX
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          student.nombreCompleto,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${student.codigo} • ${student.nivel} '
          '${student.curso}-${student.paralelo}',
        ),
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
                  color: student.activo
                      ? Colors.green[800]
                      : Colors.red[800],
                  fontSize: 12,
                ),
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
        content: Text(
          'Se eliminará a ${student.nombreCompleto}. '
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              ref.read(studentProvider.notifier).delete(student.id);
              Navigator.pop(ctx);
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

////////////////////////////////////////////////////////
/// ✅ AHORA SÍ: FUERA DE TODAS LAS CLASES
////////////////////////////////////////////////////////

class _CredentialRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _CredentialRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF1565C0)),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}