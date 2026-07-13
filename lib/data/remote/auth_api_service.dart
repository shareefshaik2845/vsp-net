import 'package:dio/dio.dart';

import '../../core/api_client.dart';

/// User info as returned by the real backend's `/api/v1/auth/*` endpoints
/// (mirrors `AuthResponse.UserInfo` on the Spring Boot side).
class RemoteRolePermission {
  final String resource;
  final List<String> actions;

  RemoteRolePermission({required this.resource, required this.actions});

  factory RemoteRolePermission.fromJson(Map<String, dynamic> json) {
    final rawActions = json['actions'];
    final actions = (rawActions is List)
        ? rawActions.cast<String>()
        : <String>[];
    return RemoteRolePermission(
      resource: json['resource'] as String? ?? '',
      actions: actions,
    );
  }
}

class RemoteUserInfo {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String role;
  final String roleDisplayName;
  final String? profileImageUrl;
  final bool active;
  final List<RemoteRolePermission> permissions;

  RemoteUserInfo({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    required this.roleDisplayName,
    this.profileImageUrl,
    required this.active,
    required this.permissions,
  });

  factory RemoteUserInfo.fromJson(Map<String, dynamic> json) {
    final rawPermissions = json['permissions'];
    final permissions = (rawPermissions is List)
        ? rawPermissions
            .map((e) => RemoteRolePermission.fromJson(e as Map<String, dynamic>))
            .toList()
        : <RemoteRolePermission>[];
    return RemoteUserInfo(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      role: json['role'] as String? ?? 'CUSTOMER',
      roleDisplayName: json['roleDisplayName'] as String? ?? '',
      profileImageUrl: json['profileImageUrl'] as String?,
      active: json['active'] == true,
      permissions: permissions,
    );
  }
}

class RemoteAuthResult {
  final String accessToken;
  final String refreshToken;
  final RemoteUserInfo user;

  RemoteAuthResult({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory RemoteAuthResult.fromJson(Map<String, dynamic> json) {
    return RemoteAuthResult(
      accessToken: json['accessToken'] as String? ?? '',
      refreshToken: json['refreshToken'] as String? ?? '',
      user: RemoteUserInfo.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}

sealed class AuthResult<T> {
  const AuthResult();
}

class AuthSuccess<T> extends AuthResult<T> {
  final T data;
  const AuthSuccess(this.data);
}

class AuthFailure<T> extends AuthResult<T> {
  final String message;
  final int? statusCode;
  const AuthFailure(this.message, {this.statusCode});
}

/// Talks to the live backend's `/api/v1/auth/*` endpoints.
class AuthApiService {
  AuthApiService([ApiClient? client]) : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  Future<AuthResult<RemoteAuthResult>> login(String email, String password) async {
    try {
      final response = await _client.dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      final envelope = ApiEnvelope.fromResponse(response);
      if (!envelope.success || envelope.data == null) {
        return AuthFailure(
          envelope.error ?? envelope.message ?? 'Invalid credentials',
          statusCode: response.statusCode,
        );
      }
      final result = RemoteAuthResult.fromJson(envelope.data as Map<String, dynamic>);
      await _client.saveTokens(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );
      return AuthSuccess(result);
    } on DioException catch (e) {
      return AuthFailure(
        _errorMessage(e),
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return AuthFailure(_fallbackMessage(e));
    }
  }

  Future<AuthResult<RemoteUserInfo>> me() async {
    try {
      final response = await _client.dio.get('/auth/me');
      final envelope = ApiEnvelope.fromResponse(response);
      if (!envelope.success || envelope.data == null) {
        return AuthFailure(
          envelope.error ?? envelope.message ?? 'Session expired',
          statusCode: response.statusCode,
        );
      }
      return AuthSuccess(RemoteUserInfo.fromJson(envelope.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return AuthFailure(
        _errorMessage(e),
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return AuthFailure(_fallbackMessage(e));
    }
  }

  Future<AuthResult<RemoteAuthResult>> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String role = 'CUSTOMER',
  }) async {
    try {
      final response = await _client.dio.post('/auth/register', data: {
        'name': name,
        'email': email,
        'password': password,
        if (phone != null) 'phone': phone,
        'role': role,
      });
      final envelope = ApiEnvelope.fromResponse(response);
      if (!envelope.success || envelope.data == null) {
        return AuthFailure(
          envelope.error ?? envelope.message ?? 'Registration failed',
          statusCode: response.statusCode,
        );
      }
      final result = RemoteAuthResult.fromJson(envelope.data as Map<String, dynamic>);
      await _client.saveTokens(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );
      return AuthSuccess(result);
    } on DioException catch (e) {
      return AuthFailure(
        _errorMessage(e),
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return AuthFailure(_fallbackMessage(e));
    }
  }

  Future<AuthResult<RemoteAuthResult>> setup({
    required String name,
    required String email,
    required String password,
    String? recoveryEmail,
  }) async {
    try {
      final response = await _client.dio.post('/auth/setup', data: {
        'name': name,
        'email': email,
        'password': password,
        if (recoveryEmail != null) 'recoveryEmail': recoveryEmail,
      });
      final envelope = ApiEnvelope.fromResponse(response);
      if (!envelope.success || envelope.data == null) {
        return AuthFailure(
          envelope.error ?? envelope.message ?? 'Setup failed',
          statusCode: response.statusCode,
        );
      }
      final result = RemoteAuthResult.fromJson(envelope.data as Map<String, dynamic>);
      await _client.saveTokens(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );
      return AuthSuccess(result);
    } on DioException catch (e) {
      return AuthFailure(
        _errorMessage(e),
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return AuthFailure(_fallbackMessage(e));
    }
  }

  Future<AuthResult<RemoteAuthResult>> refreshToken() async {
    try {
      final storedRefresh = await _client.refreshToken;
      if (storedRefresh == null || storedRefresh.isEmpty) {
        return const AuthFailure('No refresh token available');
      }
      final response = await _client.dio.post('/auth/refresh', data: {
        'refreshToken': storedRefresh,
      });
      final envelope = ApiEnvelope.fromResponse(response);
      if (!envelope.success || envelope.data == null) {
        return AuthFailure(
          envelope.error ?? envelope.message ?? 'Token refresh failed',
          statusCode: response.statusCode,
        );
      }
      final result = RemoteAuthResult.fromJson(envelope.data as Map<String, dynamic>);
      await _client.saveTokens(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );
      return AuthSuccess(result);
    } on DioException catch (e) {
      return AuthFailure(
        _errorMessage(e),
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return AuthFailure(_fallbackMessage(e));
    }
  }

  String _errorMessage(DioException e) {
    if (e.response?.statusCode == 401) return 'Invalid email or password';
    if (e.response?.statusCode == 409) return 'Account already exists';
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Connection timed out. Please check your network.';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'Unable to reach server. Please check your connection.';
    }
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      return (data['error'] as String?) ??
          (data['message'] as String?) ??
          'Request failed';
    }
    return 'Request failed. Please try again.';
  }

  String _fallbackMessage(Object e) => 'An unexpected error occurred';

  Future<bool> forgotPassword(String email) async {
    try {
      await _client.dio.post('/auth/forgot-password', data: {
        'email': email,
      });
    } catch (_) {
    }
    return true;
  }

  Future<void> logout() async {
    try {
      await _client.dio.post('/auth/logout');
    } catch (_) {
      // best-effort; token is cleared locally regardless
    } finally {
      await _client.clearTokens();
    }
  }
}
