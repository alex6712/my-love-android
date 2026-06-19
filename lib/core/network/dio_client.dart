import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/api.dart';
import '../storage/secure_storage.dart';

final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient(ref.read(secureStorageProvider));
});

class DioClient {
  final Dio _dio;
  final SecureStorage _storage;

  DioClient(this._storage)
      : _dio = Dio(BaseOptions(
          baseUrl: ApiConfig.apiUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          sendTimeout: const Duration(seconds: 15),
        )) {
    _dio.interceptors.add(AuthInterceptor(_storage, _dio));
  }

  Dio get dio => _dio;
}

class AuthInterceptor extends Interceptor {
  final SecureStorage _storage;
  final Dio _dio;
  bool _isRefreshing = false;
  final List<({RequestOptions options, ErrorInterceptorHandler handler})> _failedQueue = [];

  AuthInterceptor(this._storage, this._dio);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _storage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    options.headers['Content-Type'] ??= 'application/json';
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      if (!_isRefreshing) {
        _isRefreshing = true;
        try {
          final response = await _dio.post(
            '/auth/refresh',
            options: Options(extra: {'noAuth': true}),
          );
          if (response.statusCode == 200) {
            final newToken = response.data['access_token'] as String;
            await _storage.saveAccessToken(newToken);

            err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
            for (final item in _failedQueue) {
              item.options.headers['Authorization'] = 'Bearer $newToken';
              _dio.fetch(item.options).then(
                (r) => item.handler.resolve(r),
                onError: (e) => item.handler.reject(e as DioException),
              );
            }
            _failedQueue.clear();

            final retryResponse = await _dio.fetch(err.requestOptions);
            handler.resolve(retryResponse);
            return;
          }
        } catch (_) {
          await _storage.deleteAccessToken();
        } finally {
          _isRefreshing = false;
        }
      } else {
        _failedQueue.add((options: err.requestOptions, handler: handler));
        return;
      }
    }
    handler.next(err);
  }
}
