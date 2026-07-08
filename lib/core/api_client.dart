import 'package:dio/dio.dart';

import 'app_config.dart';
import 'token_storage.dart';

/// Thin wrapper around a shared [Dio] instance that:
///  - points at the live backend's `/api/v1` base path
///  - automatically attaches the JWT access token (if present) to every
///    request via an `Authorization: Bearer <token>` header
///  - persists the access/refresh tokens in secure storage across app
///    restarts
///
/// This is intentionally a small, dependency-free singleton so any repo
/// implementation (auth, resort, user, ...) can share one configured client.
class ApiClient {
  ApiClient._internal()
      : dio = Dio(BaseOptions(
          baseUrl: AppConfig.apiV1,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          headers: {'Content-Type': 'application/json'},
        )),
        _storage = TokenStorage.create() {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: _accessTokenKey);
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ));
  }

  static final ApiClient instance = ApiClient._internal();

  final Dio dio;
  final TokenStorage _storage;

  static const String _accessTokenKey = 'vsp_access_token';
  static const String _refreshTokenKey = 'vsp_refresh_token';

  Future<void> saveTokens({required String accessToken, String? refreshToken}) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    if (refreshToken != null) {
      await _storage.write(key: _refreshTokenKey, value: refreshToken);
    }
  }

  Future<String?> get accessToken => _storage.read(key: _accessTokenKey);
  Future<String?> get refreshToken => _storage.read(key: _refreshTokenKey);

  Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }
}

/// Standard `ApiResponse<T>` envelope shape returned by every backend
/// endpoint: `{ success, data, error, message, pagination }`.
class ApiEnvelope {
  final bool success;
  final dynamic data;
  final String? error;
  final String? message;

  ApiEnvelope({required this.success, this.data, this.error, this.message});

  factory ApiEnvelope.fromResponse(Response response) {
    final body = response.data;
    if (body is Map<String, dynamic>) {
      return ApiEnvelope(
        success: body['success'] == true,
        data: body['data'],
        error: body['error'] as String?,
        message: body['message'] as String?,
      );
    }
    return ApiEnvelope(success: true, data: body);
  }
}

/// Thrown when a backend call fails (non-2xx, or `success: false`).
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

extension DioErrorMapping on DioException {
  ApiException toApiException() {
    final data = response?.data;
    String msg = message ?? 'Network error';
    if (data is Map<String, dynamic>) {
      msg = (data['error'] as String?) ?? (data['message'] as String?) ?? msg;
    }
    return ApiException(msg, statusCode: response?.statusCode);
  }
}
