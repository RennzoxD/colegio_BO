import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/teacher_model.dart';
import '../services/teacher_service.dart';

final teacherServiceProvider = Provider((ref) => TeacherService());

final teacherProvider =
    StateNotifierProvider<TeacherNotifier, TeacherState>(
  (ref) => TeacherNotifier(ref.read(teacherServiceProvider)),
);

class TeacherState {
  final List<TeacherModel> teachers;
  final bool isLoading;
  final String? error;

  TeacherState({
    this.teachers  = const [],
    this.isLoading = false,
    this.error,
  });

  TeacherState copyWith({
    List<TeacherModel>? teachers,
    bool? isLoading,
    String? error,
  }) => TeacherState(
    teachers:  teachers  ?? this.teachers,
    isLoading: isLoading ?? this.isLoading,
    error:     error,
  );
}

class TeacherNotifier extends StateNotifier<TeacherState> {
  final TeacherService _service;
  TeacherNotifier(this._service) : super(TeacherState());
  
  void clearError() {
    state = state.copyWith(error: null);
  }
  
  Future<void> load({String? q}) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _service.getTeachers(q: q);
    if (result['success']) {
      state = state.copyWith(
          isLoading: false, teachers: result['teachers']);
    } else {
      state = state.copyWith(isLoading: false, error: result['message']);
    }
  }

  Future<bool> create(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _service.createTeacher(data);
    if (result['success'] == true) {
      final listResult = await _service.getTeachers();
      if (listResult['success']) {
        state = state.copyWith(
          isLoading: false,
          teachers: listResult['teachers'],
        );
      }
      return true;
    }
    state = state.copyWith(isLoading: false, error: result['message']);
    return false;
  }

  Future<Map<String, dynamic>?> createAndReturn(
      Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _service.createTeacher(data);
    if (result['success'] == true) {
      final listResult = await _service.getTeachers();
      if (listResult['success']) {
        state = state.copyWith(
          isLoading: false,
          teachers: listResult['teachers'],
        );
      }
      return result['data'];
    }
    state = state.copyWith(isLoading: false, error: result['message']);
    return null;
  }

  Future<void> delete(int id) async {
    await _service.deleteTeacher(id);
    await load();
  }
}