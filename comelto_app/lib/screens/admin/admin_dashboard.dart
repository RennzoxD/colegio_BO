import 'students_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';

class AdminDashboard extends ConsumerWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel Administrativo'),
        backgroundColor: const Color(0xFF1565C0),
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
            Text('Bienvenido, ${user.name}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text('Rol: ${user.role}',
              style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: const [
                  _DashCard(icon: Icons.people, label: 'Estudiantes', color: Color(0xFF1976D2)),
                  _DashCard(icon: Icons.school, label: 'Docentes',    color: Color(0xFF388E3C)),
                  _DashCard(icon: Icons.class_,  label: 'Secciones',  color: Color(0xFFF57C00)),
                  _DashCard(icon: Icons.payment, label: 'Finanzas',   color: Color(0xFF7B1FA2)),
                  _DashCard(icon: Icons.assignment, label: 'Actas',   color: Color(0xFFC62828)),
                  _DashCard(icon: Icons.bar_chart, label: 'Reportes', color: Color(0xFF00796B)),
                ],
              ),
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
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Solo para Estudiantes por ahora
          if (label == 'Estudiantes') {
            Navigator.push(context,
              MaterialPageRoute(builder: (_) => const StudentsScreen()));
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}