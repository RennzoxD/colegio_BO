import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../auth/change_password_screen.dart';
import '../auth/role_router.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user!;

    final roleLabel = switch (user.role) {
      'admin'             => 'Administrador',
      'director_general'  => 'Director General',
      'director_academico'=> 'Director Académico',
      'teacher'           => 'Docente',
      'student'           => 'Estudiante',
      'parent'            => 'Padre / Tutor',
      'secretaria'        => 'Secretaria',
      'finanzas'          => 'Finanzas',
      'regente'           => 'Regente',
      _                   => user.role,
    };

    final roleColor = switch (user.role) {
      'admin' || 'director_general' => const Color(0xFF1565C0),
      'teacher'                     => const Color(0xFF388E3C),
      'student'                     => const Color(0xFFF57C00),
      'parent'                      => const Color(0xFF7B1FA2),
      _                             => Colors.grey,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: roleColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Avatar grande
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: roleColor,
                    child: Text(
                      user.name.isNotEmpty
                          ? user.name[0].toUpperCase() : 'U',
                      style: const TextStyle(
                          fontSize: 40,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(user.name,
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: roleColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(roleLabel,
                      style: TextStyle(
                          color: roleColor,
                          fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Info card
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text('Información de cuenta',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold)),
                    const Divider(),
                    _InfoRow(Icons.person, 'Nombre',
                        user.name),
                    _InfoRow(Icons.email, 'Email',
                        user.email.isNotEmpty
                            ? user.email : '—'),
                    _InfoRow(Icons.badge, 'Usuario',
                        user.username),
                    _InfoRow(Icons.security, 'Rol',
                        roleLabel),
                    if (user.teacherId != null)
                      _InfoRow(Icons.school, 'ID Docente',
                          '#${user.teacherId}'),
                    if (user.studentId != null)
                      _InfoRow(Icons.person_outline,
                          'ID Estudiante',
                          '#${user.studentId}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Permisos
            if (user.abilities.isNotEmpty) ...[
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text('Permisos',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold)),
                      const Divider(),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: user.abilities
                            .take(12)
                            .map((a) => Chip(
                              label: Text(a,
                                style: const TextStyle(
                                    fontSize: 11)),
                              backgroundColor:
                                  roleColor.withOpacity(0.1),
                              side: BorderSide.none,
                              padding: EdgeInsets.zero,
                              visualDensity:
                                  VisualDensity.compact,
                            ))
                            .toList(),
                      ),
                      if (user.abilities.length > 12)
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 6),
                          child: Text(
                            '+${user.abilities.length - 12} más',
                            style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12)),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Acciones
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.lock_reset,
                        color: Color(0xFF1565C0)),
                    title: const Text('Cambiar contraseña'),
                    trailing: const Icon(
                        Icons.chevron_right),
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(
                            builder: (_) =>
                                const ChangePasswordScreen())),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.logout,
                        color: Colors.red),
                    title: const Text('Cerrar sesión',
                      style: TextStyle(color: Colors.red)),
                    onTap: () => _confirmLogout(
                        context, ref),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Versión
            Text('Comelto Bolivia App v1.0.0',
              style: TextStyle(
                  color: Colors.grey[400], fontSize: 12)),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Cerrar sesión?'),
        content: const Text('Se cerrará tu sesión actual.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx); // Cerrar dialog
              // Primero navegar al RoleRouter, LUEGO hacer logout
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (_) => const RoleRouter()),
                (_) => false,
              );
              await ref.read(authProvider.notifier).logout();
            },
            child: const Text('Cerrar sesión',
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
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 10),
          SizedBox(width: 90,
            child: Text('$label:',
              style: TextStyle(
                  color: Colors.grey[600], fontSize: 14))),
          Expanded(
            child: Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14)),
          ),
        ],
      ),
    );
  }
}