import 'package:dio/dio.dart';

import '../../core/api_client.dart';
import '../../domain/entities.dart';
import '../../domain/accountant_repository.dart';

class HttpAccountantRepositoryImpl implements IAccountantRepository {
  HttpAccountantRepositoryImpl([ApiClient? client])
      : _dio = (client ?? ApiClient.instance).dio;

  final Dio _dio;

  dynamic _unwrap(Response response) {
    final envelope = ApiEnvelope.fromResponse(response);
    if (!envelope.success) {
      throw ApiException(envelope.error ?? envelope.message ?? 'Request failed');
    }
    return envelope.data;
  }

  List<Map<String, dynamic>> _asListMap(dynamic data) {
    if (data is List) return data.cast<Map<String, dynamic>>();
    throw ApiException('Expected a list, got ${data.runtimeType}');
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map) return Map<String, dynamic>.from(data);
    throw ApiException('Expected a map, got ${data.runtimeType}');
  }

  @override
  Future<List<Map<String, dynamic>>> fetchProperties() async {
    final response = await _dio.get('/accountant/properties');
    return _asListMap(_unwrap(response));
  }

  @override
  Future<void> activateProperty(String id) async {
    await _dio.put('/accountant/properties/$id/activate');
  }

  @override
  Future<Map<String, dynamic>> fetchDashboardKpis(String propertyId) async {
    final response = await _dio.get('/accountant/dashboard/kpis', queryParameters: {
      if (propertyId.isNotEmpty) 'propertyId': propertyId,
    });
    return _asMap(_unwrap(response));
  }

  @override
  Future<List<Map<String, dynamic>>> fetchRefunds(String propertyId) async {
    final response = await _dio.get('/accountant/refunds');
    return _asListMap(_unwrap(response));
  }

  @override
  Future<Map<String, dynamic>> processRefund(String id) async {
    final response = await _dio.put('/accountant/refunds/$id/process');
    return _asMap(_unwrap(response));
  }

  @override
  Future<List<Booking>> fetchInvoices({String? propertyId, String? paymentStatus, String? search, int page = 1, int pageSize = 20}) async {
    final params = <String, dynamic>{'page': page, 'pageSize': pageSize};
    if (paymentStatus != null) params['status'] = paymentStatus;
    if (search != null) params['search'] = search;
    final response = await _dio.get('/accountant/invoices', queryParameters: params);
    return _asListMap(_unwrap(response)).map((json) => _bookingFromJson(json)).toList();
  }

  Booking _bookingFromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as String? ?? '',
      resortName: json['propertyName'] as String? ?? '',
      guestName: json['guestName'] as String? ?? '',
      guestEmail: json['guestEmail'] as String? ?? '',
      guestPhone: json['guestPhone'] as String? ?? '',
      startDate: json['startDate'] as String? ?? '',
      endDate: json['endDate'] as String? ?? '',
      guestsCount: json['guestsCount'] as int? ?? 1,
      nightsCount: json['nightsCount'] as int? ?? 1,
      source: _parseSource(json['source'] as String?),
      status: _parseStatus(json['status'] as String?),
      paymentStatus: _parsePaymentStatus(json['paymentStatus'] as String?),
      baseAmount: (json['baseAmount'] as num?)?.toDouble() ?? 0,
      extraGuestAmount: (json['extraGuestAmount'] as num?)?.toDouble() ?? 0,
      cleaningAmount: (json['cleaningAmount'] as num?)?.toDouble() ?? 0,
      discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0,
      taxAmount: (json['taxAmount'] as num?)?.toDouble() ?? 0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
      advancePaidAmount: (json['advancePaidAmount'] as num?)?.toDouble() ?? 0,
      balanceAmount: (json['balanceAmount'] as num?)?.toDouble() ?? 0,
      couponApplied: json['couponApplied'] as String?,
      createdAt: json['createdAt'] as String? ?? '',
      housekeepingNotes: json['housekeepingNotes'] as String?,
      cancellationReason: json['cancellationReason'] as String?,
      refundAmount: (json['refundAmount'] as num?)?.toDouble(),
    );
  }

  BookingSource _parseSource(String? source) {
    if (source == null) return BookingSource.direct;
    return BookingSource.values.firstWhere(
      (e) => e.name.toLowerCase() == source.toLowerCase(),
      orElse: () => BookingSource.direct,
    );
  }

  BookingStatus _parseStatus(String? status) {
    if (status == null) return BookingStatus.confirmed;
    return BookingStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == status.toLowerCase(),
      orElse: () => BookingStatus.confirmed,
    );
  }

  PaymentStatus _parsePaymentStatus(String? status) {
    if (status == null) return PaymentStatus.pending;
    return PaymentStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == status.toLowerCase().replaceAll('_', ''),
      orElse: () => PaymentStatus.pending,
    );
  }

  @override
  Future<Map<String, dynamic>> fetchInvoiceDetail(String id) async {
    final response = await _dio.get('/accountant/invoices/$id');
    return unwrapMap(_unwrap(response));
  }

  @override
  Future<void> downloadLedgerPdf(String propertyId, String from, String to) async {
    await _dio.get('/accountant/reports/ledger/pdf', queryParameters: {
      'propertyId': propertyId,
      'from': from,
      'to': to,
    });
  }

  @override
  Future<void> downloadLedgerExcel(String propertyId, String from, String to) async {
    await _dio.get('/accountant/reports/ledger/excel', queryParameters: {
      'propertyId': propertyId,
      'from': from,
      'to': to,
    });
  }

  @override
  Future<List<AppNotification>> fetchNotifications() async {
    final response = await _dio.get('/accountant/notifications');
    return _asListMap(_unwrap(response)).map((json) => _notifFromJson(json)).toList();
  }

  AppNotification _notifFromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      timestamp: json['timestamp'] as String? ?? '',
      type: json['type'] as String? ?? 'system',
      read: json['read'] as bool? ?? false,
    );
  }

  @override
  Future<void> markNotificationAsRead(String id) async {
    // Backend has no per-id read endpoint; marks all as read instead
    await _dio.put('/accountant/notifications/read');
  }

  @override
  Future<void> markAllNotificationsAsRead() async {
    await _dio.put('/accountant/notifications/read');
  }

  @override
  Future<Map<String, dynamic>> fetchDashboard() async {
    final response = await _dio.get('/accountant/dashboard');
    return _asMap(_unwrap(response));
  }

  @override
  Future<List<Map<String, dynamic>>> fetchAccountantBookings({String? paymentStatus, String? refundStatus, String? search, int page = 1, int pageSize = 20}) async {
    final params = <String, dynamic>{'page': page, 'pageSize': pageSize};
    if (paymentStatus != null) params['paymentStatus'] = paymentStatus;
    if (refundStatus != null) params['refundStatus'] = refundStatus;
    if (search != null) params['search'] = search;
    final response = await _dio.get('/accountant/bookings', queryParameters: params);
    return _asListMap(_unwrap(response));
  }

  @override
  Future<Map<String, dynamic>> fetchAccountantBookingDetail(String id) async {
    final response = await _dio.get('/accountant/bookings/$id');
    return _asMap(_unwrap(response));
  }

  @override
  Future<void> updateInvoice(String id, Map<String, dynamic> data) async {
    await _dio.put('/accountant/invoices/$id', data: data);
  }

  @override
  Future<String> exportReport(String format, String from, String to) async {
    final response = await _dio.get('/accountant/export', queryParameters: {
      'format': format,
      'from': from,
      'to': to,
    });
    final result = _unwrap(response);
    if (result is String) return result;
    return response.data?.toString() ?? '';
  }
}
