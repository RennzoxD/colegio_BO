import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../profile/profile_screen.dart';
import '../auth/role_router.dart';
import 'grades_screen.dart';
import 'schedule_screen.dart';
import 'attendance_screen.dart';
import 'tasks_screen.dart';
import 'subjects_screen.dart';

class StudentDashboard extends ConsumerWidget {
  const StudentDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    if (!auth.isLoggedIn) return const SizedBox.shrink();
    final user = auth.user!;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Mi Portal',
            style: TextStyle(
                color: Color(0xFF0D47A1),
                fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined,
                color: Color(0xFF0D47A1)),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(
                    builder: (_) => const ProfileScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.logout,
                color: Color(0xFF0D47A1)),
            onPressed: () => _confirmLogout(context, ref),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0D47A1),
                    Color(0xFF1565C0),
                    Color(0xFF1E88E5),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1565C0)
                        .withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        user.name.isNotEmpty
                            ? user.name[0].toUpperCase()
                            : 'E',
                        style: const TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text('Hola,',
                          style: TextStyle(
                              color: Colors.white
                                  .withOpacity(0.7),
                              fontSize: 13)),
                        Text(user.name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white
                                .withOpacity(0.2),
                            borderRadius:
                                BorderRadius.circular(12),
                          ),
                          child: const Text('Estudiante',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
                  // Fecha
                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.end,
                    children: [
                      Text(_getDayName(),
                        style: TextStyle(
                            color:
                                Colors.white.withOpacity(0.7),
                            fontSize: 12)),
                      Text(
                        '${DateTime.now().day}/${DateTime.now().month}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Acceso rápido — Ver mis notas
            GestureDetector(
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(
                      builder: (_) => const GradesScreen())),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: const Color(0xFF1565C0)
                          .withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1565C0),
                        borderRadius:
                            BorderRadius.circular(10),
                      ),
                      child: const Icon(
                          Icons.grade_rounded,
                          color: Colors.white,
                          size: 22),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text('Ver Mis Notas',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Color(0xFF0D47A1))),
                          Text(
                            'Consulta tus calificaciones',
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey)),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios,
                        size: 16,
                        color: Color(0xFF1565C0)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Text('Mi Información',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D47A1))),
            const SizedBox(height: 12),

            // Grid de módulos
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.15,
              children: [
                _StudentCard(
                  icon: Icons.grade_rounded,
                  label: 'Mis Notas',
                  subtitle: 'Ver calificaciones',
                  color: const Color(0xFF1565C0),
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(
                          builder: (_) =>
                              const GradesScreen())),
                ),
                _StudentCard(
                  icon: Icons.schedule_rounded,
                  label: 'Mi Horario',
                  subtitle: 'Clases del día',
                  color: const Color(0xFF2E7D32),
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(
                          builder: (_) =>
                              const ScheduleScreen())),
                ),
                _StudentCard(
                  icon: Icons.how_to_reg_rounded,
                  label: 'Asistencia',
                  subtitle: 'Mi registro',
                  color: const Color(0xFFE65100),
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(
                          builder: (_) =>
                              const AttendanceScreen())),
                ),
                _StudentCard(
                  icon: Icons.assignment_rounded,
                  label: 'Tareas',
                  subtitle: 'Pendientes',
                  color: const Color(0xFF6A1B9A),
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(
                          builder: (_) =>
                              const TasksScreen())),
                ),
                _StudentCard(
                  icon: Icons.menu_book_rounded,
                  label: 'Mis Materias',
                  subtitle: 'Ver materias',
                  color: const Color(0xFF00695C),
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(
                          builder: (_) =>
                              const SubjectsScreen())),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Motivación
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: Colors.grey.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Text('⭐',
                      style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '¡Sigue adelante! Cada día es una '
                      'nueva oportunidad para aprender.',
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDayName() {
    const days = [
      'Lunes', 'Martes', 'Miércoles',
      'Jueves', 'Viernes', 'Sábado', 'Domingo'
    ];
    return days[DateTime.now().weekday - 1];
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('¿Cerrar sesión?'),
        content:
            const Text('Se cerrará tu sesión actual.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (_) => const RoleRouter()),
                (_) => false,
              );
              await ref
                  .read(authProvider.notifier)
                  .logout();
            },
            child: const Text('Cerrar sesión',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ─── Card del estudiante ──────────────────────────────────────

class _StudentCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _StudentCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      shadowColor: color.withOpacity(0.2),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(label,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF0D47A1))),
                  const SizedBox(height: 2),
                  Text(subtitle,
                    style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500])),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}