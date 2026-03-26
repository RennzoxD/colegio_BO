import 'package:dio/dio.dart';
import '../core/api/api_client.dart';

class ReportService {
  final _dio = ApiClient().dio;

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

  Future<Map<String, dynamic>> getStudentStats() async {
    try {
      final res = await _dio.get('/students',
          queryParameters: {'per_page': 1});
      return {'success': true, 'total': res.data['total'] ?? 0};
    } catch (_) { return {'success': false, 'total': 0}; }
  }

  Future<Map<String, dynamic>> getTeacherStats() async {
    try {
      final res = await _dio.get('/teachers',
          queryParameters: {'per_page': 1});
      return {'success': true, 'total': res.data['total'] ?? 0};
    } catch (_) { return {'success': false, 'total': 0}; }
  }

  Future<Map<String, dynamic>> getSectionStats(int year) async {
    try {
      final res = await _dio.get('/sections',
          queryParameters: {'year': year, 'per_page': 1});
      return {'success': true, 'total': res.data['total'] ?? 0};
    } catch (_) { return {'success': false, 'total': 0}; }
  }

  Future<Map<String, dynamic>> getActaStats(int year) async {
    try {
      final res = await _dio.get('/actas',
          queryParameters: {'year': year, 'per_page': 1});
      return {'success': true,
          'total': res.data['total'] ?? 0,
          'data': res.data};
    } catch (_) { return {'success': false, 'total': 0}; }
  }

  Future<List> getOverdueCharges(int year) async {
    try {
      final res = await _dio.get('/finance/charges/overdue',
          queryParameters: {'year': year, 'per_page': 10});
      return res.data['data'] ?? [];
    } catch (_) { return []; }
  }
}