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
      id: json['id'].toString(),
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
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      user: RemoteUserInfo.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}

/// Talks to the live backend's `/api/v1/auth/*` endpoints.
class AuthApiService {
  AuthApiService([ApiClient? client]) : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  /// Logs in against the real backend and persists the JWT access/refresh
  /// tokens in secure storage on success. Returns `null` on invalid
  /// credentials or any network/server error (caller decides whether to
  /// fall back to the local sandbox mock login).
  Future<RemoteAuthResult?> login(String email, String password) async {
    try {
      final response = await _client.dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      final envelope = ApiEnvelope.fromResponse(response);
      if (!envelope.success || envelope.data == null) return null;

      final result = RemoteAuthResult.fromJson(envelope.data as Map<String, dynamic>);
      await _client.saveTokens(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );
      return result;
    } on DioException catch (_) {
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<RemoteUserInfo?> me() async {
    try {
      final response = await _client.dio.get('/auth/me');
      final envelope = ApiEnvelope.fromResponse(response);
      if (!envelope.success || envelope.data == null) return null;
      return RemoteUserInfo.fromJson(envelope.data as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  /// Registers a new user account via `POST /auth/register`.
  /// Returns the new [RemoteAuthResult] with JWT tokens, or `null` on failure.
  Future<RemoteAuthResult?> register({
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
      if (!envelope.success || envelope.data == null) return null;

      final result = RemoteAuthResult.fromJson(envelope.data as Map<String, dynamic>);
      await _client.saveTokens(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );
      return result;
    } on DioException catch (_) {
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Performs first-time super admin setup via `POST /auth/setup`.
  /// Only succeeds if no super admin exists yet.
  /// Returns the new [RemoteAuthResult] with JWT tokens, or `null` on failure.
  Future<RemoteAuthResult?> setup({
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
      if (!envelope.success || envelope.data == null) return null;

      final result = RemoteAuthResult.fromJson(envelope.data as Map<String, dynamic>);
      await _client.saveTokens(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );
      return result;
    } on DioException catch (_) {
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Refreshes the access token using the stored refresh token.
  /// Returns the new [RemoteAuthResult] with fresh tokens, or `null` on failure.
  Future<RemoteAuthResult?> refreshToken() async {
    try {
      final refreshToken = await _client.refreshToken;
      if (refreshToken == null || refreshToken.isEmpty) return null;

      final response = await _client.dio.post('/auth/refresh', data: {
        'refreshToken': refreshToken,
      });
      final envelope = ApiEnvelope.fromResponse(response);
      if (!envelope.success || envelope.data == null) return null;

      final result = RemoteAuthResult.fromJson(envelope.data as Map<String, dynamic>);
      await _client.saveTokens(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );
      return result;
    } on DioException catch (_) {
      return null;
    } catch (_) {
      return null;
    }
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
