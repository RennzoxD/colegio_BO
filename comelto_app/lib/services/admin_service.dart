import 'package:dio/dio.dart';
import '../core/api/api_client.dart';

class AdminService {
  final _dio = ApiClient().dio;

  // ==================== SECCIONES ====================
  Future<Map<String, dynamic>> getSections({
    int? year, String? nivel}) async {
    try {
      final res = await _dio.get('/sections', queryParameters: {
        'year': year ?? DateTime.now().year,
        if (nivel != null) 'nivel': nivel,
        'per_page': 50,
      });
      final List items = res.data['data'] ?? [];
      return {'success': true, 'sections': items,
          'total': res.data['total'] ?? 0};
    } on DioException catch (e) {
      return {'success': false,
          'message': e.response?.data?['message'] ?? 'Error'};
    }
  }

  Future<List> getCourses() async {
    try {
      final res = await _dio.get('/courses');
      return res.data['data'] ?? res.data ?? [];
    } catch (_) { return []; }
  }

  Future<Map<String, dynamic>> createSection(
      Map<String, dynamic> data) async {
    try {
      final res = await _dio.post('/sections', data: data);
      return {'success': true, 'data': res.data};
    } on DioException catch (e) {
      final errors = e.response?.data?['errors'];
      final msg = errors != null
          ? (errors as Map).values.first[0]
          : e.response?.data?['message'] ?? 'Error';
      return {'success': false, 'message': msg};
    }
  }

  Future<List> getSectionStudents(int sectionId) async {
    try {
      final res = await _dio.get('/sections/$sectionId/students');
      return res.data['estudiantes'] ?? res.data['data'] ?? [];
    } catch (_) { return []; }
  }

  // ==================== FINANZAS ====================
  Future<Map<String, dynamic>> getFinanceSummary(int year) async {
    try {
      final res = await _dio.get('/finance/reports/summary',
          queryParameters: {'year': year});
      return {'success': true, 'data': res.data};
    } on DioException catch (e) {
      return {'success': false,
          'message': e.response?.data?['message'] ?? 'Error'};
    }
  }

  Future<Map<String, dynamic>> getStudentLedger(
      int studentId, int year) async {
    try {
      final res = await _dio.get('/fees/$studentId',
          queryParameters: {'year': year});
      return {'success': true, 'data': res.data};
    } on DioException catch (e) {
      return {'success': false,
          'message': e.response?.data?['message'] ?? 'Error'};
    }
  }

  Future<Map<String, dynamic>> getOverdueCharges(int year) async {
    try {
      final res = await _dio.get('/finance/charges/overdue',
          queryParameters: {'year': year, 'per_page': 50});
      return {'success': true, 'data': res.data};
    } on DioException catch (e) {
      return {'success': false,
          'message': e.response?.data?['message'] ?? 'Error'};
    }
  }

  // ==================== ACTAS ====================
  Future<Map<String, dynamic>> getActas({
    int? year, String? nivel, String? term}) async {
    try {
      final res = await _dio.get('/actas', queryParameters: {
        if (year != null) 'year': year,
        if (nivel != null) 'nivel': nivel,
        if (term != null) 'term': term,
        'per_page': 50,
      });
      final List items = res.data['data'] ?? [];
      return {'success': true, 'actas': items};
    } on DioException catch (e) {
      return {'success': false,
          'message': e.response?.data?['message'] ?? 'Error'};
    }
  }

  Future<Map<String, dynamic>> getActaDetail(int id) async {
    try {
      final res = await _dio.get('/actas/$id');
      return {'success': true, 'data': res.data};
    } on DioException catch (e) {
      return {'success': false,
          'message': e.response?.data?['message'] ?? 'Error'};
    }
  }
}