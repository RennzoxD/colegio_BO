import 'package:flutter/material.dart';
import '../../models/student_model.dart';
import '../../providers/student_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StudentDetailScreen extends ConsumerWidget {
  final StudentModel student;
  const StudentDetailScreen({super.key, required this.student});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(student.nombreCompleto),
        backgroundColor: const Color(0xFF1565C0),
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
            // Avatar y nombre
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: _nivelColor(student.nivel),
                    child: Text(
                      student.nombres[0].toUpperCase(),
                      style: const TextStyle(fontSize: 36,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(student.nombreCompleto,
                    style: const TextStyle(fontSize: 22,
                        fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: _nivelColor(student.nivel).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${student.nivel.toUpperCase()} • ${student.curso} ${student.paralelo}',
                      style: TextStyle(
                          color: _nivelColor(student.nivel),
                          fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Info card
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Información del estudiante',
                      style: TextStyle(fontSize: 16,
                          fontWeight: FontWeight.bold)),
                    const Divider(),
                    _InfoRow(Icons.badge, 'Código', student.codigo),
                    _InfoRow(Icons.school, 'Nivel', student.nivel),
                    _InfoRow(Icons.class_, 'Curso',
                        '${student.curso} - ${student.paralelo}'),
                    if (student.email != null)
                      _InfoRow(Icons.email, 'Email', student.email!),
                    if (student.ci != null)
                      _InfoRow(Icons.credit_card, 'CI', student.ci!),
                    if (student.telefono != null)
                      _InfoRow(Icons.phone, 'Teléfono', student.telefono!),
                    _InfoRow(
                      student.activo ? Icons.check_circle : Icons.cancel,
                      'Estado',
                      student.activo ? 'Activo' : 'Inactivo',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _nivelColor(String nivel) => switch (nivel) {
    'inicial'    => Colors.orange,
    'primaria'   => Colors.blue,
    'secundaria' => Colors.green,
    _            => Colors.grey,
  };

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar estudiante?'),
        content: Text('Se eliminará a ${student.nombreCompleto}.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              ref.read(studentProvider.notifier).delete(student.id);
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
                  fontWeight: FontWeight.w600, fontSize: 14)),
          ),
        ],
      ),
    );
  }
}