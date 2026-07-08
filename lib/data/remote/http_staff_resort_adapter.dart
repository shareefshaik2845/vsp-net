import '../../domain/entities.dart';
import '../../domain/repositories.dart';
import '../../domain/staff_repository.dart';

class HttpStaffResortAdapter implements IResortRepository {
  final IStaffRepository _staffRepo;

  HttpStaffResortAdapter(this._staffRepo);

  @override
  Future<PropertyDetails> fetchPropertyDetails() async {
    final props = await _staffRepo.fetchProperties();
    if (props.isEmpty) throw Exception('No properties found');
    final map = props.first;
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

  @override
  Future<List<Booking>> fetchBookings() async {
    final dashboard = await _staffRepo.fetchDashboard();
    final rosterData = (dashboard['roster'] as List<dynamic>?)
        ?? (dashboard['bookings'] as List<dynamic>?)
        ?? (dashboard['data'] as List<dynamic>?)
        ?? [];
    return rosterData.map((e) {
      final json = e as Map<String, dynamic>;
      final total = (json['totalAmount'] as num?)?.toDouble() ?? 0;
      final status = _parseBookingStatus(json['status'] as String?);
      return Booking(
        id: json['id'].toString(),
        resortName: json['propertyName'] as String? ?? '',
        guestName: json['guestName'] as String? ?? '',
        guestEmail: json['guestEmail'] as String? ?? '',
        guestPhone: json['guestPhone'] as String? ?? '',
        startDate: json['startDate'] as String? ?? json['checkInDate'] as String? ?? '',
        endDate: json['endDate'] as String? ?? json['checkOutDate'] as String? ?? '',
        guestsCount: json['guestsCount'] as int? ?? 1,
        nightsCount: _nightsBetween(json['startDate'] as String? ?? json['checkInDate'] as String? ?? '', json['endDate'] as String? ?? json['checkOutDate'] as String? ?? ''),
        source: _parseSource(json['source'] as String?),
        status: status,
        paymentStatus: _approximatePaymentStatus(status),
        baseAmount: total,
        extraGuestAmount: 0,
        cleaningAmount: 0,
        discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0,
        taxAmount: 0,
        totalAmount: total,
        advancePaidAmount: status == BookingStatus.pendingPayment ? 0 : total,
        balanceAmount: status == BookingStatus.pendingPayment ? total : 0,
        createdAt: json['createdAt'] as String? ?? DateTime.now().toIso8601String(),
        housekeepingNotes: json['notes'] as String? ?? json['specialRequests'] as String?,
      );
    }).toList();
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

  BookingStatus _parseBookingStatus(String? status) {
    switch (status?.toUpperCase()) {
      case 'CONFIRMED': return BookingStatus.confirmed;
      case 'PENDING': return BookingStatus.pendingPayment;
      case 'CANCELLED': return BookingStatus.cancelled;
      case 'CHECKED_IN': return BookingStatus.checkedIn;
      case 'CHECKED_OUT': return BookingStatus.checkedOut;
      default: return BookingStatus.pendingPayment;
    }
  }

  PaymentStatus _approximatePaymentStatus(BookingStatus status) {
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

  BookingSource _parseSource(String? source) {
    switch (source?.toLowerCase()) {
      case 'airbnb': return BookingSource.airbnb;
      case 'booking_com':
      case 'booking.com': return BookingSource.bookingCom;
      case 'agoda': return BookingSource.agoda;
      case 'makemytrip':
      case 'mmt': return BookingSource.makemytrip;
      case 'goibibo': return BookingSource.goibibo;
      default: return BookingSource.direct;
    }
  }

  @override
  Future<void> addBooking(Booking booking) {
    throw UnsupportedError('Staff: addBooking not available');
  }

  @override
  Future<void> updateBooking(Booking booking) {
    throw UnsupportedError('Staff: updateBooking not available');
  }

  @override
  Future<List<CalendarBlock>> fetchCalendarBlocks() {
    throw UnsupportedError('Staff: fetchCalendarBlocks not available');
  }

  @override
  Future<void> addCalendarBlock(CalendarBlock block) {
    throw UnsupportedError('Staff: addCalendarBlock not available');
  }

  @override
  Future<void> removeCalendarBlock(String id) {
    throw UnsupportedError('Staff: removeCalendarBlock not available');
  }

  @override
  Future<List<Coupon>> fetchCoupons() {
    throw UnsupportedError('Staff: fetchCoupons not available');
  }

  @override
  Future<Map<String, dynamic>> fetchCouponDetail(String id) {
    throw UnsupportedError('Staff: fetchCouponDetail not available');
  }

  @override
  Future<void> addCoupon(Coupon coupon) {
    throw UnsupportedError('Staff: addCoupon not available');
  }

  @override
  Future<void> updateCoupon(Coupon coupon) {
    throw UnsupportedError('Staff: updateCoupon not available');
  }

  @override
  Future<void> deleteCoupon(String id) {
    throw UnsupportedError('Staff: deleteCoupon not available');
  }

  @override
  Future<List<RoomStatus>> fetchRoomStatuses() async {
    final props = await _staffRepo.fetchProperties();
    final propertyId = props.isNotEmpty ? (props.first['id'] as String? ?? '1') : '1';
    return _staffRepo.fetchHousekeepingRooms(propertyId);
  }

  @override
  Future<void> updateRoomStatus(RoomStatus status) async {
    await _staffRepo.updateHousekeepingStatus(
      status.id,
      status.status.name,
      assignedStaff: status.assignedStaff,
      notes: status.notes,
    );
  }

  @override
  Future<List<PricingSeasonRule>> fetchPricingRules() {
    throw UnsupportedError('Staff: fetchPricingRules not available');
  }

  @override
  Future<void> addPricingRule(PricingSeasonRule rule) {
    throw UnsupportedError('Staff: addPricingRule not available');
  }

  @override
  Future<void> updatePricingRule(PricingSeasonRule rule) {
    throw UnsupportedError('Staff: updatePricingRule not available');
  }

  @override
  Future<void> deletePricingRule(String id) {
    throw UnsupportedError('Staff: deletePricingRule not available');
  }

  @override
  Future<List<OtaSyncStatus>> fetchOtaSyncStatuses() {
    throw UnsupportedError('Staff: fetchOtaSyncStatuses not available');
  }

  @override
  Future<void> updateOtaSyncStatus(OtaSyncStatus status) {
    throw UnsupportedError('Staff: updateOtaSyncStatus not available');
  }

  @override
  Future<List<AppNotification>> fetchNotifications() => _staffRepo.fetchNotifications();

  @override
  Future<void> addNotification(AppNotification notification) async {
    // Notifications are server-generated; skip
  }

  @override
  Future<void> markNotificationAsRead(String id) => _staffRepo.markNotificationAsRead(id);

  @override
  Future<void> clearNotifications() => _staffRepo.markAllNotificationsAsRead();

  @override
  Future<Map<String, dynamic>> fetchAnalyticsKpis() => throw UnsupportedError('Staff: fetchAnalyticsKpis not available');
  @override
  Future<List<Map<String, dynamic>>> fetchAnalyticsSalesChart() => throw UnsupportedError('Staff: fetchAnalyticsSalesChart not available');
  @override
  Future<List<Map<String, dynamic>>> fetchAnalyticsMetricsInsights() => throw UnsupportedError('Staff: fetchAnalyticsMetricsInsights not available');
  @override
  Future<void> activateProperty(String id, bool active) => _staffRepo.activateProperty(id);
  @override
  Future<Map<String, dynamic>> fetchBookingDetail(String id) => throw UnsupportedError('Staff: fetchBookingDetail not available');
  @override
  Future<List<Map<String, dynamic>>> fetchBookingNotes(String bookingId) => throw UnsupportedError('Staff: fetchBookingNotes not available');
  @override
  Future<void> authorizePayment(String bookingId) => throw UnsupportedError('Staff: authorizePayment not available');
  @override
  Future<void> revokeBooking(String bookingId, {String? reason}) => throw UnsupportedError('Staff: revokeBooking not available');
  @override
  Future<Map<String, dynamic>> fetchBasePricing() => throw UnsupportedError('Staff: fetchBasePricing not available');
  @override
  Future<void> updateBasePricing(Map<String, dynamic> pricing) => throw UnsupportedError('Staff: updateBasePricing not available');
  @override
  Future<void> toggleSeasonalRule(String id) => throw UnsupportedError('Staff: toggleSeasonalRule not available');
  @override
  Future<void> toggleCoupon(String id) => throw UnsupportedError('Staff: toggleCoupon not available');
  @override
  Future<List<Map<String, dynamic>>> fetchPropertiesRaw() => throw UnsupportedError('Staff: fetchPropertiesRaw not available');
}
