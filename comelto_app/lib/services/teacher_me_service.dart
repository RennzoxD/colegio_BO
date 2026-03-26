import 'package:dio/dio.dart';
import '../core/api/api_client.dart';

class TeacherMeService {
  final _dio = ApiClient().dio;

  // Secciones del docente
  Future<Map<String, dynamic>> getMySections({int? year}) async {
    try {
      final res = await _dio.get('/teachers/me/sections',
          queryParameters: {
            'year': year ?? DateTime.now().year,
            'per_page': 50,
          });
      final data = res.data;
      final List items = data['data'] ?? [];
      return {'success': true, 'sections': items};
    } on DioException catch (e) {
      return {'success': false,
          'message': e.response?.data?['message'] ?? 'Error'};
    }
  }

  // Estudiantes de una sección
  Future<List> getSectionStudents(int sectionId) async {
    try {
      final res = await _dio.get('/sections/$sectionId/students');
      return res.data['data'] ?? res.data ?? [];
    } catch (_) { return []; }
  }

  // Tareas del docente
  Future<Map<String, dynamic>> getMyHomeworks({
    int? year, int? sectionId}) async {
    try {
      final res = await _dio.get('/teacher/homeworks',
          queryParameters: {
            'year': year ?? DateTime.now().year,
            if (sectionId != null) 'section_id': sectionId,
          });
      final List items = res.data['data'] ?? [];
      return {'success': true, 'homeworks': items};
    } on DioException catch (e) {
      return {'success': false,
          'message': e.response?.data?['message'] ?? 'Error'};
    }
  }

  // Crear tarea
  Future<Map<String, dynamic>> createHomework(
      Map<String, dynamic> data) async {
    try {
      final res = await _dio.post('/teacher/homeworks', data: data);
      return {'success': true, 'data': res.data};
    } on DioException catch (e) {
      final errors = e.response?.data?['errors'];
      final msg = errors != null
          ? (errors as Map).values.first[0]
          : e.response?.data?['message'] ?? 'Error';
      return {'success': false, 'message': msg};
    }
  }

  // Cerrar tarea
  Future<bool> closeHomework(int id) async {
    try {
      await _dio.post('/teacher/homeworks/$id/close');
      return true;
    } catch (_) { return false; }
  }

  // Tomar asistencia (bulk)
  Future<Map<String, dynamic>> submitAttendance(
      List<Map<String, dynamic>> records) async {
    try {
      final res = await _dio.post('/attendance/bulk',
          data: {'attendance': records});
      return {'success': true, 'data': res.data};
    } on DioException catch (e) {
      return {'success': false,
          'message': e.response?.data?['message'] ?? 'Error'};
    }
  }

  // Ver asistencia de una sección
  Future<List> getSectionAttendance(int sectionId, String fecha) async {
    try {
      final res = await _dio.get('/attendance',
          queryParameters: {
            'section_id': sectionId,
            'fecha': fecha,
          });
      return res.data['data'] ?? res.data ?? [];
    } catch (_) { return []; }
  }
}