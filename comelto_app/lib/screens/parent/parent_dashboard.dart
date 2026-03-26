import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../services/parent_service.dart';
import '../profile/profile_screen.dart';
import '../auth/role_router.dart';
import 'parent_grades_screen.dart';
import 'parent_fees_screen.dart';
import 'parent_attendance_screen.dart';
import 'parent_conduct_screen.dart';

class ParentDashboard extends ConsumerStatefulWidget {
  const ParentDashboard({super.key});

  @override
  ConsumerState<ParentDashboard> createState() =>
      _ParentDashboardState();
}

class _ParentDashboardState
    extends ConsumerState<ParentDashboard> {
  final _service = ParentService();
  Map<String, dynamic>? _student;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadChild();
  }

  Future<void> _loadChild() async {
    final result = await _service.getChild();
    setState(() {
      _loading = false;
      if (result['success']) {
        _student = result['data']?['student'];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    if (!auth.isLoggedIn) return const SizedBox.shrink();
    final user = auth.user!;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F0FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Portal Padres',
            style: TextStyle(
                color: Color(0xFF4A148C),
                fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined,
                color: Color(0xFF4A148C)),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(
                    builder: (_) => const ProfileScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.logout,
                color: Color(0xFF4A148C)),
            onPressed: () => _confirmLogout(context),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding:
                  const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  // Header padre
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF4A148C),
                          Color(0xFF6A1B9A),
                          Color(0xFF7B1FA2),
                        ],
                      ),
                      borderRadius:
                          BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6A1B9A)
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
                            color:
                                Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              user.name.isNotEmpty
                                  ? user.name[0].toUpperCase()
                                  : 'P',
                              style: const TextStyle(
                                  fontSize: 24,
                                  color: Colors.white,
                                  fontWeight:
                                      FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text('Bienvenido/a,',
                                style: TextStyle(
                                    color: Colors.white
                                        .withOpacity(0.7),
                                    fontSize: 13)),
                              Text(user.name,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight:
                                        FontWeight.bold),
                                maxLines: 1,
                                overflow:
                                    TextOverflow.ellipsis),
                              const SizedBox(height: 4),
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.white
                                      .withOpacity(0.2),
                                  borderRadius:
                                      BorderRadius.circular(
                                          12),
                                ),
                                child: const Text(
                                    'Padre / Tutor',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12)),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.end,
                          children: [
                            Text(_getDayName(),
                              style: TextStyle(
                                  color: Colors.white
                                      .withOpacity(0.7),
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
                  const SizedBox(height: 16),

                  // Card del estudiante
                  if (_student != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(16),
                        border: Border.all(
                            color: const Color(0xFF7B1FA2)
                                .withOpacity(0.2)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey
                                .withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: const Color(0xFF7B1FA2)
                                  .withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                                Icons.person_rounded,
                                color: Color(0xFF7B1FA2),
                                size: 28),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${_student!['nombres'] ?? ''} ${_student!['apellidos'] ?? ''}',
                                  style: const TextStyle(
                                      fontWeight:
                                          FontWeight.bold,
                                      fontSize: 16,
                                      color:
                                          Color(0xFF4A148C)),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${(_student!['nivel'] ?? '').toUpperCase()} • ${_student!['curso'] ?? ''} ${_student!['paralelo'] ?? ''}',
                                  style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 13)),
                                const SizedBox(height: 2),
                                Text(
                                  'Código: ${_student!['codigo'] ?? ''}',
                                  style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 12)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.green
                                  .withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 18),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 20),

                  const Text('Seguimiento Escolar',
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4A148C))),
                  const SizedBox(height: 12),

                  // Grid módulos
                  GridView.count(
                    shrinkWrap: true,
                    physics:
                        const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.15,
                    children: [
                      _ParentCard(
                        icon: Icons.grade_rounded,
                        label: 'Notas',
                        subtitle: 'Ver calificaciones',
                        color: const Color(0xFF1565C0),
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    const ParentGradesScreen())),
                      ),
                      _ParentCard(
                        icon: Icons.how_to_reg_rounded,
                        label: 'Asistencia',
                        subtitle: 'Registro de clases',
                        color: const Color(0xFF2E7D32),
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    const ParentAttendanceScreen())),
                      ),
                      _ParentCard(
                        icon: Icons.account_balance_wallet_rounded,
                        label: 'Pagos',
                        subtitle: 'Estado de cuenta',
                        color: const Color(0xFFB71C1C),
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    const ParentFeesScreen())),
                      ),
                      _ParentCard(
                        icon: Icons.gavel_rounded,
                        label: 'Conducta',
                        subtitle: 'Comportamiento',
                        color: const Color(0xFFE65100),
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    const ParentConductScreen())),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Mensaje
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(14),
                      border: Border.all(
                          color:
                              Colors.grey.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        const Text('💜',
                            style:
                                TextStyle(fontSize: 20)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Tu participación es clave '
                            'en el éxito escolar de tu hijo/a.',
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

  void _confirmLogout(BuildContext context) {
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

// ─── Card del padre ───────────────────────────────────────────

class _ParentCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ParentCard({
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
                        color: Color(0xFF4A148C))),
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