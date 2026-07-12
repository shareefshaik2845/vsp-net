import 'package:dio/dio.dart';

import '../../core/api_client.dart';
import '../../domain/entities.dart';
import '../../domain/repositories.dart';

class HttpResortRepositoryImpl implements IResortRepository {
  HttpResortRepositoryImpl([ApiClient? client])
      : _dio = (client ?? ApiClient.instance).dio;

  final Dio _dio;

  dynamic _unwrap(Response response) {
    final envelope = ApiEnvelope.fromResponse(response);
    if (!envelope.success) {
      throw ApiException(envelope.error ?? envelope.message ?? 'Request failed');
    }
    return envelope.data;
  }

  // ==================== Property (best-effort; not wired to any screen) ====================

  @override
  Future<PropertyDetails> fetchPropertyDetails() async {
    final response = await _dio.get('/admin/properties');
    final data = unwrapList(_unwrap(response));
    final map = (data.isNotEmpty ? data.first : {});
    return PropertyDetails(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      tagline: map['tagline'] as String? ?? '',
      description: '',
      location: map['location'] as String? ?? '',
      basePriceWeekday: 0,
      basePriceWeekend: 0,
      extraGuestCharge: 0,
      cleaningFee: 0,
      state: '',
      city: '',
      image: map['image'] as String? ?? '',
      gallery: [if (map['image'] != null) map['image'] as String],
      amenities: const [],
      rules: const [],
    );
  }

  // ==================== Bookings ====================

  static const _bookingStatusToBackend = {
    BookingStatus.confirmed: 'CONFIRMED',
    BookingStatus.pendingPayment: 'PENDING',
    BookingStatus.cancelled: 'CANCELLED',
    BookingStatus.checkedIn: 'CHECKED_IN',
    BookingStatus.checkedOut: 'CHECKED_OUT',
  };

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

  // Real Booking entity has no persisted payment-status column yet, so this
  // is an honest approximation derived from booking status.
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
      id: (json['id'] as String?) ?? '',
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
  Future<List<Booking>> fetchBookings() async {
    final response = await _dio.get('/admin/bookings');
    final data = unwrapList(_unwrap(response));
    return data.map((e) => _bookingFromJson(e)).toList();
  }

  @override
  Future<void> addBooking(Booking booking) async {
    await _dio.post('/admin/bookings', data: {
      'propertyId': '1',
      'guestName': booking.guestName,
      'guestEmail': booking.guestEmail,
      'guestPhone': booking.guestPhone,
      'checkInDate': booking.startDate,
      'checkOutDate': booking.endDate,
      'guestsCount': booking.guestsCount,
      'totalAmount': booking.totalAmount,
      'status': _bookingStatusToBackend[booking.status] ?? 'CONFIRMED',
      'specialRequests': booking.housekeepingNotes,
      'discountAmount': booking.discountAmount,
    });
  }

  @override
  Future<void> updateBooking(Booking booking) async {
    // The real Admin API only exposes a status-transition endpoint (no
    // generic full-booking PATCH), so only the status field is synced.
    final backendStatus = _bookingStatusToBackend[booking.status] ?? 'CONFIRMED';
    await _dio.put('/admin/bookings/${booking.id}/status', data: {
      'status': backendStatus,
      'reason': booking.cancellationReason,
    });
  }

  // ==================== Calendar Blocks ====================

  static const _defaultPropertyId = '1';

  static String _blockTypeToBackend(String reason) {
    switch (reason) {
      case 'maintenance':
        return 'MAINTENANCE';
      case 'ota_booked':
        return 'OTA_BOOKED';
      default:
        return 'BLOCKED';
    }
  }

  static String _blockTypeFromBackend(String? blockType) {
    switch (blockType) {
      case 'MAINTENANCE':
        return 'maintenance';
      case 'OTA_BOOKED':
        return 'ota_booked';
      default:
        return 'owner_stay';
    }
  }

  CalendarBlock _blockFromJson(Map<String, dynamic> json) {
    return CalendarBlock(
      id: (json['id'] as String?) ?? '',
      startDate: json['startDate'] as String? ?? '',
      endDate: json['endDate'] as String? ?? '',
      reason: _blockTypeFromBackend(json['blockType'] as String?),
      notes: json['reason'] as String?,
      blockedBy: json['propertyName'] as String? ?? '',
    );
  }

  @override
  Future<List<CalendarBlock>> fetchCalendarBlocks() async {
    final response = await _dio.get('/admin/calendar/blocks');
    final data = unwrapList(_unwrap(response));
    return data.map((e) => _blockFromJson(e)).toList();
  }

  @override
  Future<void> addCalendarBlock(CalendarBlock block) async {
    await _dio.post('/admin/calendar/blocks', data: {
      'propertyId': _defaultPropertyId,
      'startDate': block.startDate,
      'endDate': block.endDate,
      'reason': block.notes ?? block.reason,
      'blockType': _blockTypeToBackend(block.reason),
    });
  }

  @override
  Future<void> removeCalendarBlock(String id) async {
    await _dio.delete('/admin/calendar/blocks/$id');
  }

  // ==================== Coupons ====================

  Coupon _couponFromJson(Map<String, dynamic> json) {
    return Coupon(
      id: (json['id'] as String?) ?? '',
      code: json['code'] as String? ?? '',
      type: (json['discountType'] as String? ?? 'PERCENTAGE').toLowerCase(),
      value: (json['discountValue'] as num?)?.toDouble() ?? 0,
      expiryDate: (json['validUntil'] as String? ?? '').split('T').first,
      usageLimit: json['usageLimit'] as int? ?? 0,
      usageCount: json['usedCount'] as int? ?? 0,
      minBookingValue: (json['minBookingAmount'] as num?)?.toDouble() ?? 0,
      description: json['description'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  @override
  Future<List<Coupon>> fetchCoupons() async {
    final response = await _dio.get('/admin/coupons');
    final data = unwrapList(_unwrap(response));
    return data.map((e) => _couponFromJson(e)).toList();
  }

  @override
  Future<Map<String, dynamic>> fetchCouponDetail(String id) async {
    final response = await _dio.get('/admin/coupons/$id');
    return unwrapMap(_unwrap(response));
  }

  @override
  Future<void> addCoupon(Coupon coupon) async {
    await _dio.post('/admin/coupons', data: {
      'code': coupon.code,
      'description': coupon.description,
      'discountType': coupon.type.toUpperCase(),
      'discountValue': coupon.value,
      'minBookingAmount': coupon.minBookingValue,
      'usageLimit': coupon.usageLimit,
      'validFrom': DateTime.now().toIso8601String().split('T').first,
      'validUntil': coupon.expiryDate,
    });
  }

  @override
  Future<void> updateCoupon(Coupon coupon) async {
    try {
      await _dio.put('/admin/coupons/${coupon.id}', data: {
        'description': coupon.description,
        'discountType': coupon.type.toUpperCase(),
        'discountValue': coupon.value,
        'minBookingAmount': coupon.minBookingValue,
        'usageLimit': coupon.usageLimit,
        'isActive': coupon.isActive,
        'validUntil': coupon.expiryDate,
      });
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        await addCoupon(coupon);
      } else {
        rethrow;
      }
    }
  }

  @override
  Future<void> deleteCoupon(String id) async {
    await _dio.delete('/admin/coupons/$id');
  }

  // ==================== Room Statuses ====================

  @override
  Future<List<RoomStatus>> fetchRoomStatuses() async {
    final response = await _dio.get('/admin/rooms');
    final data = unwrapList(_unwrap(response));
    return data.map((e) => _roomFromJson(e)).toList();
  }

  @override
  Future<void> updateRoomStatus(RoomStatus status) async {
    await _dio.put('/admin/rooms/${status.id}/status', data: {
      'status': _roomStatusToBackend[status.status],
      'assignedStaff': status.assignedStaff,
      'notes': status.notes,
    });
  }

  RoomStatus _roomFromJson(Map<String, dynamic> json) {
    return RoomStatus(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      status: _roomStatusFromBackend(json['status'] as String?),
      assignedStaff: json['assignedStaff'] as String?,
      notes: json['notes'] as String?,
      lastUpdated: json['lastUpdated'] as String? ?? DateTime.now().toIso8601String(),
    );
  }

  static const _roomStatusToBackend = {
    HousekeepingStatus.clean: 'CLEAN',
    HousekeepingStatus.cleaning: 'CLEANING',
    HousekeepingStatus.dirty: 'DIRTY',
  };

  static HousekeepingStatus _roomStatusFromBackend(String? status) {
    switch (status?.toUpperCase()) {
      case 'CLEAN':
        return HousekeepingStatus.clean;
      case 'CLEANING':
        return HousekeepingStatus.cleaning;
      case 'DIRTY':
        return HousekeepingStatus.dirty;
      default:
        return HousekeepingStatus.clean;
    }
  }

  // ==================== Pricing Rules ====================

  PricingSeasonRule _ruleFromJson(Map<String, dynamic> json) {
    return PricingSeasonRule(
      id: (json['id'] as String?) ?? '',
      name: json['name'] as String? ?? '',
      startDate: json['startDate'] as String? ?? '',
      endDate: json['endDate'] as String? ?? '',
      weekdayPrice: (json['weekdayPrice'] as num?)?.toDouble() ?? 0,
      weekendPrice: (json['weekendPrice'] as num?)?.toDouble() ?? 0,
      multiplier: (json['multiplier'] as num?)?.toDouble() ?? 1.0,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  @override
  Future<List<PricingSeasonRule>> fetchPricingRules() async {
    final response = await _dio.get('/admin/pricing/rules');
    final data = unwrapList(_unwrap(response));
    return data.map((e) => _ruleFromJson(e)).toList();
  }

  @override
  Future<void> addPricingRule(PricingSeasonRule rule) async {
    await _dio.post('/admin/pricing/rules', data: {
      'propertyId': _defaultPropertyId,
      'name': rule.name,
      'startDate': rule.startDate,
      'endDate': rule.endDate,
      'weekdayPrice': rule.weekdayPrice,
      'weekendPrice': rule.weekendPrice,
      'multiplier': rule.multiplier,
      'isActive': rule.isActive,
    });
  }

  @override
  Future<void> updatePricingRule(PricingSeasonRule rule) async {
    final body = {
      'name': rule.name,
      'startDate': rule.startDate,
      'endDate': rule.endDate,
      'weekdayPrice': rule.weekdayPrice,
      'weekendPrice': rule.weekendPrice,
      'multiplier': rule.multiplier,
      'isActive': rule.isActive,
    };
    try {
      await _dio.put('/admin/pricing/rules/${rule.id}', data: body);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        await _dio.post('/admin/pricing/rules', data: {
          'propertyId': _defaultPropertyId,
          ...body,
        });
      } else {
        rethrow;
      }
    }
  }

  @override
  Future<void> deletePricingRule(String id) async {
    await _dio.delete('/admin/pricing/rules/$id');
  }

  // ==================== OTA Sync ====================

  static const Map<String, String> _platformLogo = {
    'Airbnb': 'Airbnb',
    'Booking.com': 'Booking',
    'Expedia': 'Expedia',
    'Agoda': 'Agoda',
    'Vrbo': 'Vrbo',
  };

  OtaSyncStatus _otaFromJson(Map<String, dynamic> json) {
    final platform = json['platform'] as String? ?? '';
    return OtaSyncStatus(
      id: (json['id'] as String?) ?? '',
      channelName: platform,
      logo: _platformLogo[platform] ?? platform,
      lastSyncTime: json['lastSyncAt'] as String? ?? '',
      status: (json['isConnected'] as bool? ?? false) ? 'success' : 'error',
      conflictsCount: json['conflictsCount'] as int? ?? 0,
      syncEnabled: json['syncEnabled'] as bool? ?? true,
    );
  }

  @override
  Future<List<OtaSyncStatus>> fetchOtaSyncStatuses() async {
    final response = await _dio.get('/admin/ota/channels');
    final data = unwrapList(_unwrap(response));
    return data.map((e) => _otaFromJson(e)).toList();
  }

  @override
  Future<void> updateOtaSyncStatus(OtaSyncStatus status) async {
    // Only "trigger sync" is a real backend capability; a bare
    // enable/disable toggle with no sync action has no server endpoint and
    // will not be persisted remotely.
    try {
      await _dio.put('/admin/ota/channels/${status.id}/sync');
    } on DioException {
      // SYNC_DISABLED or network error — swallow, UI already updated
      // optimistically by the caller.
    }
  }

  // ==================== Notifications ====================

  AppNotification _notificationFromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: (json['id'] as String?) ?? '',
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      timestamp: json['createdAt'] as String? ?? DateTime.now().toIso8601String(),
      type: (json['type'] as String? ?? 'system').toLowerCase(),
      read: json['isRead'] as bool? ?? false,
    );
  }

  @override
  Future<List<AppNotification>> fetchNotifications() async {
    final response = await _dio.get('/admin/notifications');
    final data = unwrapList(_unwrap(response));
    return data.map((e) => _notificationFromJson(e)).toList();
  }

  @override
  Future<void> addNotification(AppNotification notification) async {
    await _dio.post('/admin/notifications', data: {
      'title': notification.title,
      'message': notification.message,
      'type': notification.type.toUpperCase(),
      'referenceType': null,
      'referenceId': null,
    });
  }

  @override
  Future<void> markNotificationAsRead(String id) async {
    await _dio.put('/admin/notifications/read', data: {
      'notificationIds': [id],
    });
  }

  @override
  Future<void> clearNotifications() async {
    await _dio.put('/admin/notifications/read');
  }

  // ==================== Admin Analytics → maps to GET /admin/dashboard ====================

  @override
  Future<Map<String, dynamic>> fetchAnalyticsKpis() async {
    final response = await _dio.get('/admin/dashboard');
    return unwrapMap(_unwrap(response));
  }

  @override
  Future<List<Map<String, dynamic>>> fetchAnalyticsSalesChart() async {
    // Backend has no dedicated sales-chart endpoint; reuses dashboard data
    final response = await _dio.get('/admin/dashboard');
    final data = unwrapMap(_unwrap(response));
    return (data['salesChart'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
  }

  @override
  Future<List<Map<String, dynamic>>> fetchAnalyticsMetricsInsights() async {
    // Backend has no dedicated metrics-insights endpoint; reuses dashboard data
    final response = await _dio.get('/admin/dashboard');
    final data = unwrapMap(_unwrap(response));
    return (data['metricsInsights'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
  }

  // ==================== Raw Properties ====================

  @override
  Future<List<Map<String, dynamic>>> fetchPropertiesRaw() async {
    final response = await _dio.get('/admin/properties');
    final data = unwrapList(_unwrap(response));
    return data.cast<Map<String, dynamic>>();
  }

  // ==================== Admin Property Activation ====================

  @override
  Future<void> activateProperty(String id, bool active) async {
    await _dio.put('/admin/properties/$id/activate');
  }

  // ==================== Admin Booking Detail & Actions ====================

  @override
  Future<Map<String, dynamic>> fetchBookingDetail(String id) async {
    final response = await _dio.get('/admin/bookings/$id');
    return unwrapMap(_unwrap(response));
  }

  @override
  Future<List<Map<String, dynamic>>> fetchBookingNotes(String bookingId) async {
    return [];
  }

  @override
  Future<void> authorizePayment(String bookingId) async {
    await _dio.put('/admin/bookings/$bookingId/status', data: {
      'status': 'CONFIRMED',
    });
  }

  @override
  Future<void> revokeBooking(String bookingId, {String? reason}) async {
    await _dio.put('/admin/bookings/$bookingId/status', data: {
      'status': 'CANCELLED',
      'reason': reason,
    });
  }

  // ==================== Admin Base Pricing → maps to pricing rules ====================

  @override
  Future<Map<String, dynamic>> fetchBasePricing() async {
    final response = await _dio.get('/admin/pricing/rules');
    final data = unwrapList(_unwrap(response));
    if (data.isNotEmpty) {
      final rule = data.first;
      return {
        'basePriceWeekday': rule['weekdayPrice'] ?? 0,
        'basePriceWeekend': rule['weekendPrice'] ?? 0,
      };
    }
    return {'basePriceWeekday': 0, 'basePriceWeekend': 0};
  }

  @override
  Future<void> updateBasePricing(Map<String, dynamic> pricing) async {
    final response = await _dio.get('/admin/pricing/rules');
    final data = unwrapList(_unwrap(response));
    if (data.isEmpty) {
      await _dio.post('/admin/pricing/rules', data: {
        'name': 'Base Pricing',
        'weekdayPrice': pricing['basePriceWeekday'] ?? 0,
        'weekendPrice': pricing['basePriceWeekend'] ?? 0,
        'isActive': true,
      });
    } else {
      final rule = data.first;
      await _dio.put('/admin/pricing/rules/${rule['id']}', data: {
        'weekdayPrice': pricing['basePriceWeekday'],
        'weekendPrice': pricing['basePriceWeekend'],
      });
    }
  }

  // ==================== Admin Toggle Actions ====================

  @override
  Future<void> toggleSeasonalRule(String id) async {
    final response = await _dio.get('/admin/pricing/rules');
    final data = unwrapList(_unwrap(response));
    final rule = data.firstWhere(
      (r) => r['id'].toString() == id,
      orElse: () => throw Exception('Rule not found'),
    );
    await _dio.put('/admin/pricing/rules/$id', data: {
      'isActive': !(rule['isActive'] as bool? ?? true),
    });
  }

  @override
  Future<void> toggleCoupon(String id) async {
    final response = await _dio.get('/admin/coupons');
    final data = unwrapList(_unwrap(response));
    final coupon = data.firstWhere(
      (c) => c['id'].toString() == id,
      orElse: () => throw Exception('Coupon not found'),
    );
    await _dio.put('/admin/coupons/$id', data: {
      'isActive': !(coupon['isActive'] as bool? ?? true),
    });
  }
}
