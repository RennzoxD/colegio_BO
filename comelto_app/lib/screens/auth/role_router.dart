import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../admin/admin_dashboard.dart';
import '../teacher/teacher_dashboard.dart';
import '../student/student_dashboard.dart';
import '../parent/parent_dashboard.dart';

class RoleRouter extends ConsumerWidget {
  const RoleRouter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    if (user == null) return const SizedBox();

    switch (user.role) {
      case 'admin':
      case 'director_general':
      case 'director_academico':
      case 'superadmin':
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