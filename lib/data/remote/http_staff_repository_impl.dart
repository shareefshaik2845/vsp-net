import 'package:dio/dio.dart';

import '../../core/api_client.dart';
import '../../domain/entities.dart';
import '../../domain/staff_repository.dart';

class HttpStaffRepositoryImpl implements IStaffRepository {
  HttpStaffRepositoryImpl([ApiClient? client])
      : _dio = (client ?? ApiClient.instance).dio;

  final Dio _dio;

  dynamic _unwrap(Response response) {
    final envelope = ApiEnvelope.fromResponse(response);
    if (!envelope.success) {
      throw ApiException(
          envelope.error ?? envelope.message ?? 'Request failed');
    }
    return envelope.data;
  }

  @override
  Future<List<Map<String, dynamic>>> fetchProperties() async {
    final response = await _dio.get('/staff/properties');
    final data = unwrapList(_unwrap(response));
    return data.cast<Map<String, dynamic>>();
  }

  @override
  Future<void> activateProperty(String id) async {
    await _dio.put('/staff/properties/$id/activate');
  }

  @override
  Future<Map<String, dynamic>> fetchRoster(
      String propertyId, String date) async {
    final response = await _dio.get('/staff/roster', queryParameters: {
      'date': date,
    });
    return unwrapMap(_unwrap(response));
  }

  @override
  Future<List<RoomStatus>> fetchHousekeepingRooms(String propertyId) async {
    final response =
        await _dio.get('/staff/rooms/housekeeping', queryParameters: {
      'propertyId': propertyId,
    });
    final data = unwrapList(_unwrap(response));
    return data.map((json) => _roomFromJson(json)).toList();
  }

  RoomStatus _roomFromJson(Map<String, dynamic> json) {
    return RoomStatus(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      status: _parseHousekeepingStatus(json['housekeepingStatus'] as String?),
      assignedStaff: json['assignedStaff'] as String?,
      notes: json['notes'] as String?,
      lastUpdated: json['lastUpdated'] as String? ?? '',
    );
  }

  HousekeepingStatus _parseHousekeepingStatus(String? status) {
    if (status == null) return HousekeepingStatus.clean;
    return HousekeepingStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == status.toLowerCase(),
      orElse: () => HousekeepingStatus.clean,
    );
  }

  @override
  Future<void> updateHousekeepingStatus(String roomId, String status,
      {String? assignedStaff, String? notes}) async {
    final body = <String, dynamic>{'status': status};
    if (assignedStaff != null) body['assignedStaff'] = assignedStaff;
    if (notes != null) body['notes'] = notes;
    await _dio.put('/staff/rooms/$roomId/housekeeping', data: body);
  }

  @override
  Future<List<AppNotification>> fetchNotifications() async {
    final response = await _dio.get('/staff/notifications');
    final data = unwrapList(_unwrap(response));
    return data.map((json) => _notifFromJson(json)).toList();
  }

  AppNotification _notifFromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      timestamp: json['createdAt'] as String? ?? '',
      type: json['type'] as String? ?? 'system',
      read: json['isRead'] as bool? ?? false,
    );
  }

  @override
  Future<void> markNotificationAsRead(String id) async {
    // Backend has no per-id read endpoint; marks all as read instead
    await _dio.put('/staff/notifications/read');
  }

  @override
  Future<void> markAllNotificationsAsRead() async {
    await _dio.put('/staff/notifications/read');
  }

  @override
  Future<Map<String, dynamic>> fetchDashboard() async {
    final response = await _dio.get('/staff/dashboard');
    return unwrapMap(_unwrap(response));
  }

  @override
  Future<List<Map<String, dynamic>>> fetchTasks(String propertyId,
      {String? status, String? date}) async {
    final params = <String, dynamic>{'propertyId': propertyId};
    if (status != null) params['status'] = status;
    if (date != null) params['date'] = date;
    final response = await _dio.get('/staff/tasks', queryParameters: params);
    final data = unwrapList(_unwrap(response));
    return data.cast<Map<String, dynamic>>();
  }

  @override
  Future<void> updateTask(String id, String status, {String? notes}) async {
    await _dio.put('/staff/tasks/$id', data: {
      'status': status,
      if (notes != null) 'notes': notes,
    });
  }

  @override
  Future<Map<String, dynamic>> fetchTaskSummary(String propertyId) async {
    final response = await _dio.get('/staff/tasks/summary', queryParameters: {
      'propertyId': propertyId,
    });
    return unwrapMap(_unwrap(response));
  }

  // ── Concierge ──

  @override
  Future<List<Map<String, dynamic>>> fetchAssignedConciergeRequests({String? status}) async {
    final params = <String, dynamic>{};
    if (status != null) params['status'] = status;
    final response = await _dio.get('/staff/concierge', queryParameters: params.isNotEmpty ? params : null);
    final data = unwrapList(_unwrap(response));
    return data.cast<Map<String, dynamic>>();
  }

  @override
  Future<void> updateConciergeStatus(String id, String status) async {
    await _dio.put('/staff/concierge/$id/status', data: {'status': status});
  }

  @override
  Future<void> updateConciergeNotes(String id, String notes) async {
    await _dio.put('/staff/concierge/$id/notes', data: {'notes': notes});
  }
}
