import 'package:dio/dio.dart';
import '../core/api/api_client.dart';
import '../core/api/api_constants.dart';
import '../models/student_model.dart';

class StudentService {
  final _dio = ApiClient().dio;

  Future<Map<String, dynamic>> getStudents({
    String? q,
    String? nivel,
    String? curso,
    String? paralelo,
    int page = 1,
  }) async {
    try {
      final response = await _dio.get(ApiConstants.students, queryParameters: {
        if (q != null && q.isNotEmpty) 'q': q,
        if (nivel != null) 'nivel': nivel,
        if (curso != null) 'curso': curso,
        if (paralelo != null) 'paralelo': paralelo,
        'page': page,
      });

      final data = response.data;
      final List students = data['data'] ?? [];

      return {
        'success': true,
        'students': students.map((e) => StudentModel.fromJson(e)).toList(),
        'total':    data['total'] ?? 0,
        'lastPage': data['last_page'] ?? 1,
      };
    } on DioException catch (e) {
      return {'success': false, 'message': e.response?.data?['message'] ?? 'Error'};
    }
  }

  Future<Map<String, dynamic>> createStudent(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(ApiConstants.students, data: data);
      return {'success': true, 'data': response.data};
    } on DioException catch (e) {
      final errors = e.response?.data?['errors'];
      final message = errors != null
          ? (errors as Map).values.first[0]
          : e.response?.data?['message'] ?? 'Error al crear estudiante';
      return {'success': false, 'message': message};
    }
  }

  Future<bool> deleteStudent(int id) async {
    try {
      await _dio.delete('${ApiConstants.students}/$id');
      return true;
    } catch (_) { return false; }
  }
}