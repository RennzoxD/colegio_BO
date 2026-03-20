import 'package:dio/dio.dart';
import '../core/api/api_client.dart';
import '../core/api/api_constants.dart';
import '../core/storage/token_storage.dart';
import 'dart:convert';

class AuthService {
  final _dio = ApiClient().dio;

  /// Login con username/email y password
  Future<Map<String, dynamic>> login(String identifier, String password) async {
    try {
      final response = await _dio.post(ApiConstants.login, data: {
        'username': identifier,
        'password': password,
      });

      final data = response.data;

      if (data['success'] == true) {
        final token = data['token'];
        final user  = data['user'];

        await TokenStorage.saveToken(token);
        await TokenStorage.saveUser(jsonEncode(user));

        return {
          'success': true,
          'mustChangePassword': data['mustChangePassword'] ?? false,
          'user': user,
        };
      }

      return {'success': false, 'message': data['message'] ?? 'Error'};

    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Error de conexión';
      return {'success': false, 'message': msg};
    }
  }

  /// Login especial para padres (con código del estudiante)
  Future<Map<String, dynamic>> parentLookup(String studentCode) async {
    try {
      final response = await _dio.post(ApiConstants.parentLookup, data: {
        'student_code': studentCode,
      });

      final data = response.data;
      if (data['success'] == true) {
        await TokenStorage.saveToken(data['token']);
        await TokenStorage.saveUser(jsonEncode(data['user']));
        return {'success': true, 'user': data['user']};
      }

      return {'success': false, 'message': data['message']};
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Código no encontrado';
      return {'success': false, 'message': msg};
    }
  }

  Future<void> logout() async {
    try { await _dio.post(ApiConstants.logout); } catch (_) {}
    await TokenStorage.clearAll();
  }

  Future<Map<String, dynamic>?> getMe() async {
    try {
      final res = await _dio.get(ApiConstants.me);
      return res.data;
    } catch (_) { return null; }
  }

  Future<Map<String, dynamic>> changePassword(String password) async {
    try {
      final res = await _dio.post(ApiConstants.changePassword, data: {
        'password': password,
        'password_confirmation': password,
      });
      return res.data;
    } on DioException catch (e) {
      return {'success': false, 'message': e.response?.data?['message'] ?? 'Error'};
    }
  }
}