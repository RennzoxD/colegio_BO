import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';

class StudentDashboard extends ConsumerWidget {
  const StudentDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Portal Estudiante'),
        backgroundColor: const Color(0xFFF57C00),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authProvider.notifier).logout(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hola, ${user.name}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: const [
                _DashCard(icon: Icons.grade,    label: 'Mis Notas',    color: Color(0xFF1976D2)),
                _DashCard(icon: Icons.schedule, label: 'Horario',      color: Color(0xFF388E3C)),
                _DashCard(icon: Icons.payment,  label: 'Mis Pagos',    color: Color(0xFF7B1FA2)),
                _DashCard(icon: Icons.task,     label: 'Tareas',       color: Color(0xFFF57C00)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DashCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _DashCard({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: color),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}