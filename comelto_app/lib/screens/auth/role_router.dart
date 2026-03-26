import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import '../admin/admin_dashboard.dart';
import '../teacher/teacher_dashboard.dart';
import '../student/student_dashboard.dart';
import '../parent/parent_dashboard.dart';
import '../auth/change_password_screen.dart';

class RoleRouter extends ConsumerWidget {
  const RoleRouter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

    // Si no hay usuario → ir a login
    if (!auth.isLoggedIn) {
      return const LoginScreen();
    }
    if (auth.mustChangePassword) {
      return const ChangePasswordScreen(isForced: true);
    }

    final user = auth.user!;
    switch (user.role) {
      case 'admin':
      case 'director_general':
      case 'director_academico':
      case 'superadmin':
      case 'secretaria':
      case 'finanzas':
      case 'regente':
        return const AdminDashboard();
      case 'teacher':
        return const TeacherDashboard();
      case 'student':
        return const StudentDashboard();
      case 'parent':
        return const ParentDashboard();
      default:
        return const AdminDashboard();
    }
  }
}