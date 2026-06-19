import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_error.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/storage/secure_storage.dart';
import '../models/user.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? error;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.error,
  });

  AuthState copyWith({AuthStatus? status, User? user, String? error}) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error,
    );
  }

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.unknown;
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Dio _dio;
  final SecureStorage _storage;

  AuthNotifier(this._dio, this._storage) : super(const AuthState()) {
    _initSession();
  }

  Future<void> _initSession() async {
    final token = await _storage.getAccessToken();
    if (token == null) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return;
    }
    try {
      final response = await _dio.get('/users/me');
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: User.fromJson(response.data['user']),
      );
    } catch (_) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> login(String username, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'username': username, 'password': password},
        options: Options(
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          extra: {'noAuth': true},
        ),
      );
      final token = response.data['access_token'] as String;
      await _storage.saveAccessToken(token);

      final userResponse = await _dio.get('/users/me');
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: User.fromJson(userResponse.data['user']),
      );
    } on DioException catch (e) {
      final detail = e.response?.data?['detail'] as String?;
      final code = e.response?.data?['code'] as String?;
      throw ApiError(code ?? 'UNKNOWN', detail ?? 'Ошибка соединения');
    }
  }

  Future<void> register(String username, String password) async {
    try {
      await _dio.post(
        '/auth/register',
        data: {'username': username, 'password': password},
        options: Options(extra: {'noAuth': true}),
      );
    } on DioException catch (e) {
      final detail = e.response?.data?['detail'] as String?;
      final code = e.response?.data?['code'] as String?;
      throw ApiError(code ?? 'UNKNOWN', detail ?? 'Ошибка соединения');
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
    } catch (_) {}
    await _storage.deleteAccessToken();
    state = state.copyWith(status: AuthStatus.unauthenticated, user: null);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final dio = ref.read(dioClientProvider).dio;
  final storage = ref.read(secureStorageProvider);
  return AuthNotifier(dio, storage);
});
