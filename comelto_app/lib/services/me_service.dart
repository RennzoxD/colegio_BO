import 'package:dio/dio.dart';
import '../core/api/api_client.dart';
import '../core/api/api_constants.dart';

class MeService {
  final _dio = ApiClient().dio;

  Future<Map<String, dynamic>> getMyStudent() async {
    try {
      final res = await _dio.get(ApiConstants.meStudent);
      return {'success': true, 'data': res.data};
    } on DioException catch (e) {
      return {'success': false,
          'message': e.response?.data?['message'] ?? 'Error'};
    }
  }

  Future<List> getMyGrades() async {
    try {
      final res = await _dio.get('/me/grades');
      return res.data['data'] ?? [];
    } catch (_) { return []; }
  }

  Future<List> getMyAttendance() async {
    try {
      final res = await _dio.get(ApiConstants.meAttendance);
      return res.data['data'] ?? [];
    } catch (_) { return []; }
  }

  Future<List> getMySchedule() async {
    try {
      final res = await _dio.get(ApiConstants.meSchedule);
      return res.data['data'] ?? [];
    } catch (_) { return []; }
  }

  Future<List> getMyTasks() async {
    try {
      final res = await _dio.get(ApiConstants.meTasks);
      return res.data['data'] ?? res.data ?? [];
    } catch (_) { return []; }
  }

  Future<List> getMyFees() async {
    try {
      final res = await _dio.get(ApiConstants.meFees);
      return res.data['charges'] ?? res.data['data'] ?? [];
    } catch (_) { return []; }
  }

  Future<List> getMySubjects() async {
    try {
      final res = await _dio.get(ApiConstants.meSubjects);
      return res.data['data'] ?? [];
    } catch (_) { return []; }
  }
}