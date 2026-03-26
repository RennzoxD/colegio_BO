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

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(teacherProvider.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(teacherProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Docentes'),
        backgroundColor: const Color(0xFF388E3C),
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(context),
        backgroundColor: const Color(0xFF388E3C),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Buscar por nombre o RDA...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (v) =>
                  ref.read(teacherProvider.notifier).load(q: v),
            ),
          ),
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.error != null
                    ? Center(child: Text(state.error!,
                        style: const TextStyle(color: Colors.red)))
                    : state.teachers.isEmpty
                        ? const Center(child: Text('No hay docentes'))
                        : ListView.builder(
                            itemCount: state.teachers.length,
                            itemBuilder: (ctx, i) =>
                                _TeacherTile(teacher: state.teachers[i]),
                          ),
          ),
        ],
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    ref.read(teacherProvider.notifier).clearError();
    final nombres    = TextEditingController();
    final apellidos  = TextEditingController();
    final email      = TextEditingController();
    final telefono   = TextEditingController();
    final ci         = TextEditingController();
    final rdaNumero  = TextEditingController();
    String rdaEstado = 'VIGENTE';
    String estado    = 'activo';
    final anio       = DateTime.now().year.toString();
    final mes        = DateTime.now().month.toString().padLeft(2, '0');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nuevo Docente'),
        content: SingleChildScrollView(
          child: StatefulBuilder(
            builder: (ctx, setSt) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nombres,
                    decoration:
                        const InputDecoration(labelText: 'Nombres *')),
                TextField(controller: apellidos,
                    decoration:
                        const InputDecoration(labelText: 'Apellidos *')),
                TextField(controller: email,
                    decoration:
                        const InputDecoration(labelText: 'Email *'),
                    keyboardType: TextInputType.emailAddress),
                TextField(controller: telefono,
                    decoration:
                        const InputDecoration(labelText: 'Teléfono')),
                TextField(controller: ci,
                    decoration: const InputDecoration(labelText: 'CI *')),
                TextField(controller: rdaNumero,
                    decoration:
                        const InputDecoration(labelText: 'RDA Número *')),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: rdaEstado,
                  decoration:
                      const InputDecoration(labelText: 'Estado RDA'),
                  items: const [
                    DropdownMenuItem(
                        value: 'VIGENTE', child: Text('Vigente')),
                    DropdownMenuItem(
                        value: 'OBSERVADO', child: Text('Observado')),
                    DropdownMenuItem(
                        value: 'VENCIDO', child: Text('Vencido')),
                  ],
                  onChanged: (v) => setSt(() => rdaEstado = v!),
                ),
                DropdownButtonFormField<String>(
                  value: estado,
                  decoration: const InputDecoration(labelText: 'Estado'),
                  items: const [
                    DropdownMenuItem(
                        value: 'activo', child: Text('Activo')),
                    DropdownMenuItem(
                        value: 'licencia', child: Text('Licencia')),
                    DropdownMenuItem(
                        value: 'inactivo', child: Text('Inactivo')),
                  ],
                  onChanged: (v) => setSt(() => estado = v!),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              if (nombres.text.isEmpty || apellidos.text.isEmpty ||
                  email.text.isEmpty  || ci.text.isEmpty ||
                  rdaNumero.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Completa los campos obligatorios')));
                return;
              }

              final result = await ref.read(teacherProvider.notifier)
                  .createAndReturn({
                'nombres':      nombres.text.trim(),
                'apellidos':    apellidos.text.trim(),
                'email':        email.text.trim(),
                'telefono':     telefono.text.trim(),
                'ci':           ci.text.trim(),
                'rda_numero':   rdaNumero.text.trim(),
                'rda_estado':   rdaEstado,
                'estado':       estado,
                'anio_ingreso': anio,
                'mes_ingreso':  mes,
              });

              if (result != null && ctx.mounted) {
                Navigator.pop(ctx);
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Row(children: [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 8),
                      Text('Docente Creado'),
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
                          icon: Icons.email,
                          label: 'Email',
                          value: result['teacher']?['email'] ?? '-'),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.orange[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.orange)),
                          child: const Text(
                            '⚠️ Guarda estas credenciales.\nEl docente deberá cambiar su contraseña al primer ingreso.',
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
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(
                    ref.read(teacherProvider).error ?? 'Error al crear'),
                  backgroundColor: Colors.red));
              }
            },
            child: const Text('Crear')),
        ],
      ),
    );
  }
}

class _TeacherTile extends ConsumerWidget {
  final TeacherModel teacher;
  const _TeacherTile({required this.teacher});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = switch (teacher.rdaEstado) {
      'VIGENTE'   => Colors.green,
      'OBSERVADO' => Colors.orange,
      _           => Colors.red,
    };

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TeacherDetailScreen(teacher: teacher))),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF388E3C),
          child: Text(teacher.nombres[0],
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        title: Text(teacher.nombreCompleto,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('${teacher.email} • CI: ${teacher.ci ?? "-"}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(teacher.rdaEstado,
                  style: TextStyle(color: color, fontSize: 11,
                      fontWeight: FontWeight.bold)),
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
        title: const Text('¿Eliminar docente?'),
        content: Text(
            'Se eliminará a ${teacher.nombreCompleto}. Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              ref.read(teacherProvider.notifier).delete(teacher.id);
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

class _CredentialRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _CredentialRow({
      required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF388E3C)),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                style: const TextStyle(fontSize: 11, color: Colors.grey)),
              Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
        ],
      ),
    );
  }
}