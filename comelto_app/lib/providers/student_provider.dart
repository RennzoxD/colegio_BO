import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/student_model.dart';
import '../services/student_service.dart';

final studentServiceProvider = Provider((ref) => StudentService());

final studentProvider = StateNotifierProvider<StudentNotifier, StudentState>(
  (ref) => StudentNotifier(ref.read(studentServiceProvider)),
);

class StudentState {
  final List<StudentModel> students;
  final bool isLoading;
  final String? error;
  final String searchQuery;
  final int currentPage;
  final int lastPage;

  StudentState({
    this.students  = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
    this.currentPage = 1,
    this.lastPage    = 1,
  });

  StudentState copyWith({
    List<StudentModel>? students,
    bool? isLoading,
    String? error,
    String? searchQuery,
    int? currentPage,
    int? lastPage,
  }) => StudentState(
    students:    students    ?? this.students,
    isLoading:   isLoading   ?? this.isLoading,
    error:       error,
    searchQuery: searchQuery ?? this.searchQuery,
    currentPage: currentPage ?? this.currentPage,
    lastPage:    lastPage    ?? this.lastPage,
  );
}

class StudentNotifier extends StateNotifier<StudentState> {
  final StudentService _service;
  StudentNotifier(this._service) : super(StudentState());

  Future<void> load({String? q, String? nivel}) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _service.getStudents(q: q, nivel: nivel);
    if (result['success']) {
      state = state.copyWith(
        isLoading: false,
        students:  result['students'],
        lastPage:  result['lastPage'],
        searchQuery: q ?? '',
      );
    } else {
      state = state.copyWith(isLoading: false, error: result['message']);
    }
  }

  Future<bool> create(Map<String, dynamic> data) async {
    final result = await _service.createStudent(data);
    if (result['success'] == true) {
      await load();
      return true;
    }
    state = state.copyWith(error: result['message']);
    return false;
  }

  Future<void> delete(int id) async {
    await _service.deleteStudent(id);
    await load();
  }
}