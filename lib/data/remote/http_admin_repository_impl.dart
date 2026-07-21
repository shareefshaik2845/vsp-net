import 'package:dio/dio.dart';

import '../../core/api_client.dart';
import '../../domain/admin_repository.dart';

class HttpAdminRepositoryImpl implements IAdminRepository {
  HttpAdminRepositoryImpl([ApiClient? client])
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
  Future<List<Map<String, dynamic>>> fetchConciergeRequests({String? status, String? type}) async {
    final params = <String, dynamic>{};
    if (status != null) params['status'] = status;
    if (type != null) params['type'] = type;
    final response = await _dio.get('/admin/concierge',
        queryParameters: params.isNotEmpty ? params : null);
    final data = unwrapList(_unwrap(response));
    return data.cast<Map<String, dynamic>>();
  }

  @override
  Future<void> updateConciergeStatus(String id, String status) async {
    await _dio.put('/admin/concierge/$id/status', data: {'status': status});
  }

  @override
  Future<void> assignConciergeStaff(String id, int staffId) async {
    await _dio.put('/admin/concierge/$id/assign', data: {'staffId': staffId});
  }

  @override
  Future<void> updateConciergeNotes(String id, String notes) async {
    await _dio.put('/admin/concierge/$id/notes', data: {'notes': notes});
  }

  @override
  Future<List<Map<String, dynamic>>> fetchStaffUsers() async {
    final response = await _dio.get('/admin/staff');
    final data = unwrapList(_unwrap(response));
    return data.cast<Map<String, dynamic>>();
  }
}
