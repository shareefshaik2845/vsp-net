import 'package:dio/dio.dart';

import '../../core/api_client.dart';
import '../../domain/entities.dart';
import '../../domain/customer_repository.dart';

class HttpCustomerRepositoryImpl implements ICustomerRepository {
  HttpCustomerRepositoryImpl([ApiClient? client])
      : _dio = (client ?? ApiClient.instance).dio;

  final Dio _dio;

  dynamic _unwrap(Response response) {
    final envelope = ApiEnvelope.fromResponse(response);
    if (!envelope.success) {
      throw ApiException(envelope.error ?? envelope.message ?? 'Request failed');
    }
    return envelope.data;
  }

  @override
  Future<List<Map<String, dynamic>>> fetchProperties({String? search, String? state, String? city, String? category}) async {
    final params = <String, dynamic>{};
    if (search != null) params['search'] = search;
    if (state != null) params['state'] = state;
    if (city != null) params['city'] = city;
    if (category != null) params['category'] = category;
    final response = await _dio.get('/customer/properties', queryParameters: params.isNotEmpty ? params : null);
    final data = _unwrap(response) as List<dynamic>;
    return data.cast<Map<String, dynamic>>();
  }

  @override
  Future<Map<String, dynamic>> fetchPropertyDetail(String id) async {
    final response = await _dio.get('/customer/properties/$id');
    return _unwrap(response) as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> fetchTaxRate() async {
    final response = await _dio.get('/customer/pricing/tax-rate');
    return _unwrap(response) as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> fetchDepositRate() async {
    final response = await _dio.get('/customer/pricing/deposit-rate');
    return _unwrap(response) as Map<String, dynamic>;
  }

  @override
  Future<List<Map<String, dynamic>>> fetchSeasonalRules(String propertyId) async {
    final response = await _dio.get('/customer/pricing/seasonal-rules', queryParameters: {'propertyId': propertyId});
    final data = _unwrap(response) as List<dynamic>;
    return data.cast<Map<String, dynamic>>();
  }

  @override
  Future<Map<String, dynamic>> validateCoupon(String code, double subtotal, String propertyId) async {
    final response = await _dio.post('/customer/coupons/validate', data: {
      'code': code,
      'subtotal': subtotal,
      'propertyId': propertyId,
    });
    return _unwrap(response) as Map<String, dynamic>;
  }

  @override
  Future<List<Map<String, dynamic>>> fetchAvailableCoupons() async {
    final response = await _dio.get('/customer/coupons');
    final data = _unwrap(response) as List<dynamic>;
    return data.cast<Map<String, dynamic>>();
  }

  @override
  Future<List<Booking>> fetchBookings({String? status, int page = 1, int pageSize = 20}) async {
    final params = <String, dynamic>{'page': page, 'pageSize': pageSize};
    if (status != null) params['status'] = status;
    final response = await _dio.get('/customer/bookings', queryParameters: params);
    final data = _unwrap(response) as List<dynamic>;
    return data.map((json) => _bookingFromJson(json as Map<String, dynamic>)).toList();
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
  Future<Map<String, dynamic>> fetchBookingDetail(String id) async {
    final response = await _dio.get('/customer/bookings/$id');
    return _unwrap(response) as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> createBooking(Map<String, dynamic> booking) async {
    final response = await _dio.post('/customer/bookings', data: booking);
    return _unwrap(response) as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> cancelBooking(String id, String reason) async {
    final response = await _dio.post('/customer/bookings/$id/cancel', data: {'reason': reason});
    return _unwrap(response) as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> initiatePayment(Map<String, dynamic> payment) async {
    final bookingId = payment['bookingId'] as String? ?? '';
    final paymentMethod = payment['paymentMethod'] as String? ?? 'credit_card';
    final response = await _dio.post('/customer/bookings/$bookingId/payment',
        queryParameters: {'paymentMethod': paymentMethod});
    return _unwrap(response) as Map<String, dynamic>;
  }

  @override
  Future<List<Map<String, dynamic>>> fetchFavorites() async {
    final response = await _dio.get('/customer/favorites');
    final data = _unwrap(response) as List<dynamic>;
    return data.cast<Map<String, dynamic>>();
  }

  @override
  Future<void> addFavorite(String propertyId) async {
    await _dio.post('/customer/favorites/$propertyId');
  }

  @override
  Future<void> removeFavorite(String propertyId) async {
    await _dio.delete('/customer/favorites/$propertyId');
  }

  @override
  Future<Map<String, dynamic>> fetchProfile() async {
    final response = await _dio.get('/customer/profile');
    return _unwrap(response) as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> profile) async {
    final response = await _dio.put('/customer/profile', data: profile);
    return _unwrap(response) as Map<String, dynamic>;
  }

  @override
  Future<void> changePassword(String currentPassword, String newPassword) async {
    await _dio.put('/customer/profile/password', data: {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });
  }

  @override
  Future<Map<String, dynamic>> fetchStats() async {
    final response = await _dio.get('/customer/stats');
    return _unwrap(response) as Map<String, dynamic>;
  }

  @override
  Future<List<Map<String, dynamic>>> fetchCalendarBlocks(String propertyId, String from, String to) async {
    final response = await _dio.get('/customer/calendar/blocks', queryParameters: {
      'propertyId': propertyId,
      'from': from,
      'to': to,
    });
    final data = _unwrap(response) as List<dynamic>;
    return data.cast<Map<String, dynamic>>();
  }

  @override
  Future<Map<String, dynamic>> fetchAvailability(String propertyId, String from, String to) async {
    final response = await _dio.get('/customer/calendar/availability', queryParameters: {
      'propertyId': propertyId,
      'from': from,
      'to': to,
    });
    return _unwrap(response) as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> fetchMonthlyCalendar(String propertyId, int month, int year) async {
    final response = await _dio.get('/customer/calendar', queryParameters: {
      'propertyId': propertyId,
      'month': month,
      'year': year,
    });
    return _unwrap(response) as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> fetchPaymentForBooking(String bookingId) async {
    final response = await _dio.get('/customer/bookings/$bookingId/payment');
    return _unwrap(response) as Map<String, dynamic>;
  }

  @override
  Future<List<Map<String, dynamic>>> fetchConciergeRequests() async {
    final response = await _dio.get('/customer/concierge');
    final data = _unwrap(response) as List<dynamic>;
    return data.cast<Map<String, dynamic>>();
  }

  @override
  Future<List<AppNotification>> fetchNotifications() async {
    final response = await _dio.get('/customer/notifications');
    final data = _unwrap(response) as List<dynamic>;
    return data.map((json) => _notifFromJson(json as Map<String, dynamic>)).toList();
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
    await _dio.put('/customer/notifications/read');
  }

  @override
  Future<List<Map<String, dynamic>>> fetchInvoices({String? status, int page = 1, int pageSize = 20}) async {
    final params = <String, dynamic>{'page': page, 'pageSize': pageSize};
    if (status != null) params['status'] = status;
    final response = await _dio.get('/customer/invoices', queryParameters: params);
    final data = _unwrap(response) as List<dynamic>;
    return data.cast<Map<String, dynamic>>();
  }

  @override
  Future<Map<String, dynamic>> fetchInvoiceDetail(String id) async {
    final response = await _dio.get('/customer/invoices/$id');
    return _unwrap(response) as Map<String, dynamic>;
  }

  @override
  Future<void> sendConciergeMessage(String message, String source) async {
    await _dio.post('/customer/concierge', data: {
      'requestType': source.toUpperCase(),
      'description': message,
    });
  }
}
