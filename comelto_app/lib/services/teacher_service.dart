import 'package:dio/dio.dart';
import '../core/api/api_client.dart';
import '../core/api/api_constants.dart';
import '../models/teacher_model.dart';

class TeacherService {
  final _dio = ApiClient().dio;

  Future<Map<String, dynamic>> getTeachers({String? q, bool? activo}) async {
    try {
      final response = await _dio.get(ApiConstants.teachers, queryParameters: {
        if (q != null && q.isNotEmpty) 'q': q,
        if (activo != null) 'activo': activo,
      });
      final List data = response.data['data'] ?? [];
      return {
        'success': true,
        'teachers': data.map((e) => TeacherModel.fromJson(e)).toList(),
      };
    } on DioException catch (e) {
      return {'success': false,
          'message': e.response?.data?['message'] ?? 'Error'};
    }
  }

  Future<Map<String, dynamic>> createTeacher(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(ApiConstants.teachers, data: data);
      return {'success': true, 'data': response.data};
    } on DioException catch (e) {
      final errors = e.response?.data?['errors'];
      final message = errors != null
          ? (errors as Map).values.first[0]
          : e.response?.data?['message'] ?? 'Error al crear docente';
      return {'success': false, 'message': message};
    }
  }

  Future<bool> deleteTeacher(int id) async {
    try {
      await _dio.delete('${ApiConstants.teachers}/$id');
      return true;
    } catch (_) { return false; }
  }
}