import 'package:dio/dio.dart';
import '../core/api/api_client.dart';

class ParentService {
  final _dio = ApiClient().dio;

  Future<Map<String, dynamic>> getChild() async {
    try {
      final res = await _dio.get('/parent/child');
      return {'success': true, 'data': res.data};
    } on DioException catch (e) {
      return {'success': false,
          'message': e.response?.data?['message'] ?? 'Error'};
    }
  }

  Future<Map<String, dynamic>> getGrades(int year) async {
    try {
      final res = await _dio.get('/parent/grades',
          queryParameters: {'year': year});
      return {'success': true, 'data': res.data};
    } on DioException catch (e) {
      return {'success': false,
          'message': e.response?.data?['message'] ?? 'Error'};
    }
  }

  Future<Map<String, dynamic>> getFees(int year) async {
    try {
      final res = await _dio.get('/parent/fees',
          queryParameters: {'year': year});
      return {'success': true, 'data': res.data};
    } on DioException catch (e) {
      // 404 significa sin cuenta — no es error crítico
      if (e.response?.statusCode == 404) {
        return {'success': true, 'data': e.response?.data};
      }
      return {'success': false,
          'message': e.response?.data?['message'] ?? 'Error'};
    }
  }

  Future<List> getAttendance() async {
    try {
      final res = await _dio.get('/parent/attendance');
      return res.data['data'] ?? res.data ?? [];
    } catch (_) { return []; }
  }

  Future<List> getConduct() async {
    try {
      final res = await _dio.get('/parent/conduct');
      return res.data['data'] ?? res.data ?? [];
    } catch (_) { return []; }
  }
}