import 'package:dio/dio.dart';

import '../../core/api_client.dart';
import '../../domain/entities.dart';
import '../../domain/super_admin_repository.dart';

/// Real, HTTP-backed implementation of [ISuperAdminRepository] that talks to
/// the live Spring Boot backend's Super Admin API (`/api/v1/super-admin/**`).
class HttpSuperAdminRepositoryImpl implements ISuperAdminRepository {
  HttpSuperAdminRepositoryImpl([ApiClient? client])
      : _dio = (client ?? ApiClient.instance).dio;

  final Dio _dio;

  dynamic _unwrap(Response response) {
    final envelope = ApiEnvelope.fromResponse(response);
    if (!envelope.success) {
      throw ApiException(envelope.error ?? envelope.message ?? 'Request failed');
    }
    return envelope.data;
  }

  // ==================== Analytics ====================

  @override
  Future<Map<String, dynamic>> fetchAnalyticsRevenue() async {
    final response = await _dio.get('/super-admin/analytics/revenue');
    return _unwrap(response) as Map<String, dynamic>;
  }

  @override
  Future<List<Map<String, dynamic>>> fetchBookingSources() async {
    final response = await _dio.get('/super-admin/analytics/booking-sources');
    final data = _unwrap(response) as List<dynamic>;
    return data.cast<Map<String, dynamic>>();
  }

  @override
  Future<List<Map<String, dynamic>>> fetchResortRevenueTable() async {
    final response = await _dio.get('/super-admin/analytics/resort-revenue-table');
    final data = _unwrap(response) as List<dynamic>;
    return data.cast<Map<String, dynamic>>();
  }

  // ==================== Global Settings ====================

  @override
  Future<Map<String, dynamic>> fetchGlobalSettings() async {
    final response = await _dio.get('/super-admin/settings');
    return _unwrap(response) as Map<String, dynamic>;
  }

  @override
  Future<void> updateGlobalSettings(Map<String, dynamic> settings) async {
    await _dio.put('/super-admin/settings', data: settings);
  }

  @override
  Future<void> factoryReset() async {
    await _dio.post('/super-admin/system/factory-reset');
  }

  @override
  Future<Map<String, dynamic>> fetchSchema() async {
    final response = await _dio.get('/super-admin/system/schema');
    return _unwrap(response) as Map<String, dynamic>;
  }

  // ==================== Image Uploads ====================

  @override
  Future<Map<String, dynamic>> uploadImage(String filePath, {String? caption}) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
      if (caption != null) 'caption': caption,
    });
    final response = await _dio.post('/super-admin/properties/upload-image', data: formData);
    return _unwrap(response) as Map<String, dynamic>;
  }

  @override
  Future<List<Map<String, dynamic>>> uploadGallery(List<String> filePaths) async {
    final files = await Future.wait(filePaths.map((p) => MultipartFile.fromFile(p)));
    final formData = FormData.fromMap({
      'files': files,
    });
    final response = await _dio.post('/super-admin/properties/upload-gallery', data: formData);
    final data = _unwrap(response) as List<dynamic>;
    return data.cast<Map<String, dynamic>>();
  }

  // ==================== Multi-Property Management ====================

  @override
  Future<List<Map<String, dynamic>>> fetchProperties() async {
    final response = await _dio.get('/super-admin/properties');
    final data = _unwrap(response) as List<dynamic>;
    return data.cast<Map<String, dynamic>>();
  }

  @override
  Future<Map<String, dynamic>> fetchPropertyDetail(String id) async {
    final response = await _dio.get('/super-admin/properties/$id');
    return _unwrap(response) as Map<String, dynamic>;
  }

  @override
  Future<void> createProperty(Map<String, dynamic> property) async {
    final formData = FormData.fromMap(property);
    await _dio.post('/super-admin/properties', data: formData);
  }

  @override
  Future<void> updateProperty(String id, Map<String, dynamic> property) async {
    final formData = FormData.fromMap(property);
    await _dio.put('/super-admin/properties/$id', data: formData);
  }

  @override
  Future<void> deleteProperty(String id) async {
    await _dio.delete('/super-admin/properties/$id');
  }

  // ==================== User Management ====================

  @override
  Future<List<Map<String, dynamic>>> fetchUsers({
    String? role,
    String? status,
    String? search,
    int page = 1,
    int pageSize = 20,
  }) async {
    final params = <String, dynamic>{'page': page, 'pageSize': pageSize};
    if (role != null) params['role'] = role;
    if (status != null) params['status'] = status;
    if (search != null) params['search'] = search;
    final response = await _dio.get('/super-admin/users', queryParameters: params.isNotEmpty ? params : null);
    final data = _unwrap(response) as List<dynamic>;
    return data.cast<Map<String, dynamic>>();
  }

  @override
  Future<Map<String, dynamic>> fetchUserDetail(String id) async {
    final response = await _dio.get('/super-admin/users/$id');
    return _unwrap(response) as Map<String, dynamic>;
  }

  @override
  Future<void> createUser(Map<String, dynamic> user) async {
    final formData = FormData.fromMap(user);
    await _dio.post('/super-admin/users', data: formData);
  }

  @override
  Future<void> updateUser(String id, Map<String, dynamic> user) async {
    final formData = FormData.fromMap(user);
    await _dio.put('/super-admin/users/$id', data: formData);
  }

  @override
  Future<void> deleteUser(String id) async {
    await _dio.delete('/super-admin/users/$id');
  }

  // ==================== Approval Workflow ====================

  @override
  Future<List<Map<String, dynamic>>> fetchApprovals() async {
    final response = await _dio.get('/super-admin/approvals');
    final data = _unwrap(response) as List<dynamic>;
    return data.cast<Map<String, dynamic>>();
  }

  @override
  Future<List<Map<String, dynamic>>> fetchPendingApprovals() async {
    final response = await _dio.get('/super-admin/approvals/pending');
    final data = _unwrap(response) as List<dynamic>;
    return data.cast<Map<String, dynamic>>();
  }

  @override
  Future<void> resolveApproval(String id, String status, {String? rejectionReason}) async {
    await _dio.put('/super-admin/approvals/$id/resolve', data: {
      'status': status,
      if (rejectionReason != null) 'rejectionReason': rejectionReason,
    });
  }

  // ==================== RBAC ====================

  static RolePermission _rolePermissionFromJson(Map<String, dynamic> json) {
    final resourceStr = json['resource'] as String? ?? '';
    final actionsRaw = json['actions'] as List<dynamic>? ?? [];
    return RolePermission(
      resource: PermissionResource.values.firstWhere(
        (e) => e.name == resourceStr,
        orElse: () => PermissionResource.bookings,
      ),
      actions: actionsRaw
          .map((a) => PermissionAction.values.firstWhere(
                (e) => e.name == (a as String),
                orElse: () => PermissionAction.read,
              ))
          .toList(),
    );
  }

  static RoleDefinition _roleFromJson(Map<String, dynamic> json) {
    final perms = (json['permissions'] as List<dynamic>?)
            ?.map((p) => _rolePermissionFromJson(p as Map<String, dynamic>))
            .toList() ??
        [];
    return RoleDefinition(
      id: json['id'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      description: json['description'] as String? ?? '',
      permissions: perms,
    );
  }

  @override
  Future<List<RoleDefinition>> fetchRoles() async {
    final response = await _dio.get('/super-admin/roles');
    final data = _unwrap(response) as List<dynamic>;
    return data.map((e) => _roleFromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<RoleDefinition> fetchRoleDetail(String id) async {
    final response = await _dio.get('/super-admin/roles/$id');
    return _roleFromJson(_unwrap(response) as Map<String, dynamic>);
  }

  @override
  Future<void> updateRole(RoleDefinition role) async {
    await _dio.put('/super-admin/roles/${role.id}', data: {
      'displayName': role.displayName,
      'description': role.description,
      'permissions': role.permissions
          .map((p) => {
                'resource': p.resource.name,
                'actions': p.actions.map((a) => a.name).toList(),
              })
          .toList(),
    });
  }

  // ==================== Audit Logs ====================

  @override
  Future<List<Map<String, dynamic>>> fetchAuditLogs({
    String? userId,
    String? action,
    String? from,
    String? to,
    int? page,
    int? pageSize,
  }) async {
    final params = <String, dynamic>{};
    if (userId != null) params['userId'] = userId;
    if (action != null) params['action'] = action;
    if (from != null) params['from'] = from;
    if (to != null) params['to'] = to;
    if (page != null) params['page'] = page;
    if (pageSize != null) params['pageSize'] = pageSize;
    final response = await _dio.get('/super-admin/audit-logs',
        queryParameters: params.isNotEmpty ? params : null);
    final data = _unwrap(response) as List<dynamic>;
    return data.cast<Map<String, dynamic>>();
  }

  // ==================== Notifications ====================

  AppNotification _notificationFromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'].toString(),
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      timestamp: json['createdAt'] as String? ?? DateTime.now().toIso8601String(),
      type: (json['type'] as String? ?? 'system').toLowerCase(),
      read: json['isRead'] as bool? ?? false,
    );
  }

  @override
  Future<List<AppNotification>> fetchNotifications() async {
    final response = await _dio.get('/super-admin/notifications');
    final data = _unwrap(response) as List<dynamic>;
    return data.map((e) => _notificationFromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> addNotification(AppNotification notification) async {
    await _dio.post('/super-admin/notifications', data: {
      'title': notification.title,
      'message': notification.message,
      'type': notification.type.toUpperCase(),
      'referenceType': null,
      'referenceId': null,
    });
  }

  @override
  Future<void> markNotificationAsRead(String id) async {
    await _dio.put('/super-admin/notifications/$id/read');
  }

  @override
  Future<void> clearNotifications() async {
    final current = await fetchNotifications();
    for (final n in current) {
      try {
        await _dio.delete('/super-admin/notifications/${n.id}');
      } catch (_) {
        // best-effort; continue clearing the rest
      }
    }
  }

  // ==================== Bookings (cross-property) ====================

  static BookingStatus _bookingStatusFromBackend(String? status) {
    switch (status) {
      case 'CONFIRMED':
        return BookingStatus.confirmed;
      case 'PENDING':
        return BookingStatus.pendingPayment;
      case 'CANCELLED':
        return BookingStatus.cancelled;
      case 'CHECKED_IN':
        return BookingStatus.checkedIn;
      case 'CHECKED_OUT':
        return BookingStatus.checkedOut;
      case 'REFUNDED':
        return BookingStatus.cancelled;
      default:
        return BookingStatus.pendingPayment;
    }
  }

  static BookingSource _sourceFromOtaPlatform(String? platform) {
    switch (platform?.toLowerCase()) {
      case 'airbnb':
        return BookingSource.airbnb;
      case 'booking_com':
      case 'booking.com':
      case 'bookingcom':
        return BookingSource.bookingCom;
      case 'agoda':
        return BookingSource.agoda;
      case 'makemytrip':
      case 'mmt':
        return BookingSource.makemytrip;
      case 'goibibo':
        return BookingSource.goibibo;
      default:
        return BookingSource.direct;
    }
  }

  static PaymentStatus _approximatePaymentStatus(BookingStatus status) {
    switch (status) {
      case BookingStatus.confirmed:
      case BookingStatus.checkedIn:
      case BookingStatus.checkedOut:
        return PaymentStatus.paid;
      case BookingStatus.cancelled:
        return PaymentStatus.refunded;
      case BookingStatus.pendingPayment:
        return PaymentStatus.pending;
    }
  }

  int _nightsBetween(String start, String end) {
    try {
      final s = DateTime.parse(start);
      final e = DateTime.parse(end);
      return e.difference(s).inDays;
    } catch (_) {
      return 1;
    }
  }

  Booking _bookingFromJson(Map<String, dynamic> json) {
    final status = _bookingStatusFromBackend(json['status'] as String?);
    final total = (json['totalAmount'] as num?)?.toDouble() ?? 0;
    final discount = (json['discountAmount'] as num?)?.toDouble() ?? 0;
    return Booking(
      id: json['id'].toString(),
      resortName: json['propertyName'] as String? ?? '',
      guestName: json['guestName'] as String? ?? '',
      guestEmail: json['guestEmail'] as String? ?? '',
      guestPhone: json['guestPhone'] as String? ?? '',
      startDate: json['checkInDate'] as String? ?? '',
      endDate: json['checkOutDate'] as String? ?? '',
      guestsCount: json['guestsCount'] as int? ?? 1,
      nightsCount: _nightsBetween(
        json['checkInDate'] as String? ?? '',
        json['checkOutDate'] as String? ?? '',
      ),
      source: _sourceFromOtaPlatform(json['otaPlatform'] as String?),
      status: status,
      paymentStatus: _approximatePaymentStatus(status),
      baseAmount: total + discount,
      extraGuestAmount: 0,
      cleaningAmount: 0,
      discountAmount: discount,
      taxAmount: 0,
      totalAmount: total,
      advancePaidAmount: status == BookingStatus.pendingPayment ? 0 : total,
      balanceAmount: status == BookingStatus.pendingPayment ? total : 0,
      createdAt: json['createdAt'] as String? ?? DateTime.now().toIso8601String(),
      housekeepingNotes: json['specialRequests'] as String?,
    );
  }

  @override
  Future<List<Booking>> fetchAllBookings() async {
    final response = await _dio.get('/super-admin/bookings');
    final data = _unwrap(response) as List<dynamic>;
    return data.map((e) => _bookingFromJson(e as Map<String, dynamic>)).toList();
  }
}
