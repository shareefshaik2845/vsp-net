import 'package:dio/dio.dart';

import 'app_config.dart';
import 'token_storage.dart';

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
      onError: (error, handler) async {
        if (error.response?.statusCode == 401 && !_isRefreshing) {
          _isRefreshing = true;
          try {
            final refreshToken = await _storage.read(key: _refreshTokenKey);
            if (refreshToken != null && refreshToken.isNotEmpty) {
              final refreshResponse = await dio.post('/auth/refresh', data: {
                'refreshToken': refreshToken,
              });
              final body = refreshResponse.data;
              if (body is Map<String, dynamic> && body['success'] == true) {
                final data = body['data'] as Map<String, dynamic>;
                final newAccessToken = data['accessToken'] as String;
                final newRefreshToken = data['refreshToken'] as String?;
                await saveTokens(
                  accessToken: newAccessToken,
                  refreshToken: newRefreshToken,
                );
                error.requestOptions.headers['Authorization'] =
                    'Bearer $newAccessToken';
                final retryResponse = await dio.fetch(error.requestOptions);
                return handler.resolve(retryResponse);
              }
            }
          } catch (_) {
          } finally {
            _isRefreshing = false;
          }
          await clearTokens();
        }
        handler.next(error);
      },
    ));
  }

  bool _isRefreshing = false;

  static final ApiClient instance = ApiClient._internal();

  final Dio dio;
  final TokenStorage _storage;

  static const String _accessTokenKey = 'vsp_access_token';
  static const String _refreshTokenKey = 'vsp_refresh_token';

  Future<void> saveTokens(
      {required String accessToken, String? refreshToken}) async {
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

List<Map<String, dynamic>> unwrapList(dynamic data) {
  if (data is List) return data.cast<Map<String, dynamic>>();
  throw ApiException('Expected a list, got ${data.runtimeType}');
}

Map<String, dynamic> unwrapMap(dynamic data) {
  if (data is Map) return Map<String, dynamic>.from(data);
  throw ApiException('Expected a map, got ${data.runtimeType}');
}

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
