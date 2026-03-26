import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/teacher_model.dart';
import '../../providers/teacher_provider.dart';

class TeacherDetailScreen extends ConsumerWidget {
  final TeacherModel teacher;
  const TeacherDetailScreen({super.key, required this.teacher});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rdaColor = switch (teacher.rdaEstado) {
      'VIGENTE'   => Colors.green,
      'OBSERVADO' => Colors.orange,
      _           => Colors.red,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(teacher.nombreCompleto),
        backgroundColor: const Color(0xFF388E3C),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: const Color(0xFF388E3C),
                    child: Text(
                      teacher.nombres[0].toUpperCase(),
                      style: const TextStyle(fontSize: 36,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(teacher.nombreCompleto,
                    style: const TextStyle(fontSize: 22,
                        fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: rdaColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('RDA: ${teacher.rdaEstado}',
                      style: TextStyle(color: rdaColor,
                          fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Información del docente',
                      style: TextStyle(fontSize: 16,
                          fontWeight: FontWeight.bold)),
                    const Divider(),
                    _InfoRow(Icons.email,       'Email',    teacher.email),
                    _InfoRow(Icons.credit_card, 'CI',       teacher.ci ?? '-'),
                    _InfoRow(Icons.numbers,     'RDA',      teacher.rdaNumero ?? '-'),
                    _InfoRow(Icons.verified,    'Estado RDA', teacher.rdaEstado),
                    _InfoRow(Icons.work,        'Estado',   teacher.estado),
                    _InfoRow(Icons.person,      'Usuario',  teacher.usuario),
                    if (teacher.telefono != null)
                      _InfoRow(Icons.phone, 'Teléfono', teacher.telefono!),
                  ],
                ),
              ),
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
        content: Text('Se eliminará a ${teacher.nombreCompleto}.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              ref.read(teacherProvider.notifier).delete(teacher.id);
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Eliminar',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 10),
          Text('$label: ',
            style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          Expanded(
            child: Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 14)),
          ),
        ],
      ),
    );
  }
}