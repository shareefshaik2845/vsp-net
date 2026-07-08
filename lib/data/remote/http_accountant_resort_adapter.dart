import '../../domain/entities.dart';
import '../../domain/repositories.dart';
import '../../domain/accountant_repository.dart';

class HttpAccountantResortAdapter implements IResortRepository {
  final IAccountantRepository _accountantRepo;

  HttpAccountantResortAdapter(this._accountantRepo);

  @override
  Future<PropertyDetails> fetchPropertyDetails() async {
    final props = await _accountantRepo.fetchProperties();
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
  Future<List<Booking>> fetchBookings() => _accountantRepo.fetchInvoices();

  @override
  Future<void> addBooking(Booking booking) {
    throw UnsupportedError('Accountant: addBooking not available');
  }

  @override
  Future<void> updateBooking(Booking booking) async {
    if (booking.paymentStatus == PaymentStatus.refunded) {
      await _accountantRepo.processRefund(booking.id);
    }
  }

  @override
  Future<List<CalendarBlock>> fetchCalendarBlocks() {
    throw UnsupportedError('Accountant: fetchCalendarBlocks not available');
  }

  @override
  Future<void> addCalendarBlock(CalendarBlock block) {
    throw UnsupportedError('Accountant: addCalendarBlock not available');
  }

  @override
  Future<void> removeCalendarBlock(String id) {
    throw UnsupportedError('Accountant: removeCalendarBlock not available');
  }

  @override
  Future<List<Coupon>> fetchCoupons() {
    throw UnsupportedError('Accountant: fetchCoupons not available');
  }

  @override
  Future<Map<String, dynamic>> fetchCouponDetail(String id) {
    throw UnsupportedError('Accountant: fetchCouponDetail not available');
  }

  @override
  Future<void> addCoupon(Coupon coupon) {
    throw UnsupportedError('Accountant: addCoupon not available');
  }

  @override
  Future<void> updateCoupon(Coupon coupon) {
    throw UnsupportedError('Accountant: updateCoupon not available');
  }

  @override
  Future<void> deleteCoupon(String id) {
    throw UnsupportedError('Accountant: deleteCoupon not available');
  }

  @override
  Future<List<RoomStatus>> fetchRoomStatuses() {
    throw UnsupportedError('Accountant: fetchRoomStatuses not available');
  }

  @override
  Future<void> updateRoomStatus(RoomStatus status) {
    throw UnsupportedError('Accountant: updateRoomStatus not available');
  }

  @override
  Future<List<PricingSeasonRule>> fetchPricingRules() {
    throw UnsupportedError('Accountant: fetchPricingRules not available');
  }

  @override
  Future<void> addPricingRule(PricingSeasonRule rule) {
    throw UnsupportedError('Accountant: addPricingRule not available');
  }

  @override
  Future<void> updatePricingRule(PricingSeasonRule rule) {
    throw UnsupportedError('Accountant: updatePricingRule not available');
  }

  @override
  Future<void> deletePricingRule(String id) {
    throw UnsupportedError('Accountant: deletePricingRule not available');
  }

  @override
  Future<List<OtaSyncStatus>> fetchOtaSyncStatuses() {
    throw UnsupportedError('Accountant: fetchOtaSyncStatuses not available');
  }

  @override
  Future<void> updateOtaSyncStatus(OtaSyncStatus status) {
    throw UnsupportedError('Accountant: updateOtaSyncStatus not available');
  }

  @override
  Future<List<AppNotification>> fetchNotifications() => _accountantRepo.fetchNotifications();

  @override
  Future<void> addNotification(AppNotification notification) async {
    // Notifications are server-generated; skip
  }

  @override
  Future<void> markNotificationAsRead(String id) => _accountantRepo.markNotificationAsRead(id);

  @override
  Future<void> clearNotifications() => _accountantRepo.markAllNotificationsAsRead();

  @override
  Future<Map<String, dynamic>> fetchAnalyticsKpis() => _accountantRepo.fetchDashboardKpis('1');
  @override
  Future<List<Map<String, dynamic>>> fetchAnalyticsSalesChart() => throw UnsupportedError('Accountant: fetchAnalyticsSalesChart not available');
  @override
  Future<List<Map<String, dynamic>>> fetchAnalyticsMetricsInsights() => throw UnsupportedError('Accountant: fetchAnalyticsMetricsInsights not available');
  @override
  Future<void> activateProperty(String id, bool active) => _accountantRepo.activateProperty(id);
  @override
  Future<Map<String, dynamic>> fetchBookingDetail(String id) => _accountantRepo.fetchInvoiceDetail(id);
  @override
  Future<List<Map<String, dynamic>>> fetchBookingNotes(String bookingId) => throw UnsupportedError('Accountant: fetchBookingNotes not available');
  @override
  Future<void> authorizePayment(String bookingId) => throw UnsupportedError('Accountant: authorizePayment not available');
  @override
  Future<void> revokeBooking(String bookingId, {String? reason}) => throw UnsupportedError('Accountant: revokeBooking not available');
  @override
  Future<Map<String, dynamic>> fetchBasePricing() => throw UnsupportedError('Accountant: fetchBasePricing not available');
  @override
  Future<void> updateBasePricing(Map<String, dynamic> pricing) => throw UnsupportedError('Accountant: updateBasePricing not available');
  @override
  Future<void> toggleSeasonalRule(String id) => throw UnsupportedError('Accountant: toggleSeasonalRule not available');
  @override
  Future<void> toggleCoupon(String id) => throw UnsupportedError('Accountant: toggleCoupon not available');
  @override
  Future<List<Map<String, dynamic>>> fetchPropertiesRaw() => throw UnsupportedError('Accountant: fetchPropertiesRaw not available');
}
