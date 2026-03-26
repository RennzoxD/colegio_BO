import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../core/storage/token_storage.dart';
import 'dart:convert';

final authServiceProvider = Provider((ref) => AuthService());

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(ref.read(authServiceProvider)),
);

class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;
  final bool mustChangePassword;

  AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.mustChangePassword = false,
  });

  bool get isLoggedIn => user != null;

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? error,
    bool? mustChangePassword,
  }) {
    return AuthState(
      user:                user ?? this.user,
      isLoading:           isLoading ?? this.isLoading,
      error:               error,
      mustChangePassword:  mustChangePassword ?? this.mustChangePassword,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _service;

  AuthNotifier(this._service) : super(AuthState()) {
    _loadSavedUser();
  }

  Future<void> _loadSavedUser() async {
    final userJson = await TokenStorage.getUser();
    final token    = await TokenStorage.getToken();
    if (userJson != null && token != null) {
      final user = UserModel.fromJson(jsonDecode(userJson));
      state = state.copyWith(user: user);
    }
  }

  Future<bool> login(String identifier, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _service.login(identifier, password);

    if (result['success'] == true) {
      final user = UserModel.fromJson(result['user']);
      state = AuthState(
        user: user,
        mustChangePassword: result['mustChangePassword'] ?? false,
      );
      return true;
    }

    state = AuthState(error: result['message']);
    return false;
  }

  Future<bool> parentLookup(String code) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _service.parentLookup(code);

    if (result['success'] == true) {
      final user = UserModel.fromJson(result['user']);
      state = AuthState(user: user);
      return true;
    }

    state = AuthState(error: result['message']);
    return false;
  }

  Future<void> logout() async {
    await _service.logout();
    state = AuthState();
  }

  Future<bool> changePassword(String password) async {
    final result = await _service.changePassword(password);
    if (result['success'] == true) {
      // Actualizar estado: ya no debe cambiar contraseña
      if (state.user != null) {
        state = AuthState(
          user: state.user,
          mustChangePassword: false,
        );
      }
      return true;
    }
    state = state.copyWith(error: result['message']);
    return false;
  }
}