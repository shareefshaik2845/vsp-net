import '../../domain/entities.dart';
import '../../domain/repositories.dart';
import '../../domain/customer_repository.dart';

class HttpCustomerResortAdapter implements IResortRepository {
  final ICustomerRepository _customerRepo;

  HttpCustomerResortAdapter(this._customerRepo);

  @override
  Future<PropertyDetails> fetchPropertyDetails() async {
    final props = await _customerRepo.fetchProperties();
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
  Future<List<Booking>> fetchBookings() => _customerRepo.fetchBookings();

  @override
  Future<void> addBooking(Booking booking) async {
    await _customerRepo.createBooking({
      'propertyId': booking.resortName,
      'startDate': booking.startDate,
      'endDate': booking.endDate,
      'guestsCount': booking.guestsCount,
      'guestName': booking.guestName,
      'guestEmail': booking.guestEmail,
      'guestPhone': booking.guestPhone,
      'housekeepingNotes': booking.housekeepingNotes,
      'baseAmount': booking.baseAmount,
      'extraGuestAmount': booking.extraGuestAmount,
      'cleaningAmount': booking.cleaningAmount,
      'discountAmount': booking.discountAmount,
      'taxAmount': booking.taxAmount,
      'totalAmount': booking.totalAmount,
      'advancePaidAmount': booking.advancePaidAmount,
      'balanceAmount': booking.balanceAmount,
      'source': booking.source.toJson(),
    });
  }

  @override
  Future<void> updateBooking(Booking booking) async {
    if (booking.status == BookingStatus.cancelled && booking.cancellationReason != null) {
      await _customerRepo.cancelBooking(booking.id, booking.cancellationReason!);
    }
  }

  @override
  Future<List<CalendarBlock>> fetchCalendarBlocks() => throw UnsupportedError('Customer: fetchCalendarBlocks not available');

  @override
  Future<void> addCalendarBlock(CalendarBlock block) => throw UnsupportedError('Customer: addCalendarBlock not available');

  @override
  Future<void> removeCalendarBlock(String id) => throw UnsupportedError('Customer: removeCalendarBlock not available');

  @override
  Future<List<Coupon>> fetchCoupons() => throw UnsupportedError('Customer: fetchCoupons not available');

  @override
  Future<Map<String, dynamic>> fetchCouponDetail(String id) => throw UnsupportedError('Customer: fetchCouponDetail not available');

  @override
  Future<void> addCoupon(Coupon coupon) => throw UnsupportedError('Customer: addCoupon not available');

  @override
  Future<void> updateCoupon(Coupon coupon) => throw UnsupportedError('Customer: updateCoupon not available');

  @override
  Future<void> deleteCoupon(String id) => throw UnsupportedError('Customer: deleteCoupon not available');

  @override
  Future<List<RoomStatus>> fetchRoomStatuses() => throw UnsupportedError('Customer: fetchRoomStatuses not available');

  @override
  Future<void> updateRoomStatus(RoomStatus status) => throw UnsupportedError('Customer: updateRoomStatus not available');

  @override
  Future<List<PricingSeasonRule>> fetchPricingRules() => throw UnsupportedError('Customer: fetchPricingRules not available');

  @override
  Future<void> addPricingRule(PricingSeasonRule rule) => throw UnsupportedError('Customer: addPricingRule not available');

  @override
  Future<void> updatePricingRule(PricingSeasonRule rule) => throw UnsupportedError('Customer: updatePricingRule not available');

  @override
  Future<void> deletePricingRule(String id) => throw UnsupportedError('Customer: deletePricingRule not available');

  @override
  Future<List<OtaSyncStatus>> fetchOtaSyncStatuses() => throw UnsupportedError('Customer: fetchOtaSyncStatuses not available');

  @override
  Future<void> updateOtaSyncStatus(OtaSyncStatus status) => throw UnsupportedError('Customer: updateOtaSyncStatus not available');

  @override
  Future<List<AppNotification>> fetchNotifications() => _customerRepo.fetchNotifications();

  @override
  Future<void> addNotification(AppNotification notification) async {
    // Notifications are server-generated; skip
  }

  @override
  Future<void> markNotificationAsRead(String id) => _customerRepo.markNotificationAsRead(id);

  @override
  Future<void> clearNotifications() {
    throw UnsupportedError('Customer: clearNotifications not available');
  }

  @override
  Future<Map<String, dynamic>> fetchAnalyticsKpis() => throw UnsupportedError('Customer: fetchAnalyticsKpis not available');
  @override
  Future<List<Map<String, dynamic>>> fetchAnalyticsSalesChart() => throw UnsupportedError('Customer: fetchAnalyticsSalesChart not available');
  @override
  Future<List<Map<String, dynamic>>> fetchAnalyticsMetricsInsights() => throw UnsupportedError('Customer: fetchAnalyticsMetricsInsights not available');
  @override
  Future<void> activateProperty(String id, bool active) => throw UnsupportedError('Customer: activateProperty not available');
  @override
  Future<Map<String, dynamic>> fetchBookingDetail(String id) => _customerRepo.fetchBookingDetail(id);
  @override
  Future<List<Map<String, dynamic>>> fetchBookingNotes(String bookingId) => throw UnsupportedError('Customer: fetchBookingNotes not available');
  @override
  Future<void> authorizePayment(String bookingId) async {
    await _customerRepo.initiatePayment({'bookingId': bookingId, 'paymentMethod': 'credit_card'});
  }
  @override
  Future<void> revokeBooking(String bookingId, {String? reason}) => throw UnsupportedError('Customer: revokeBooking not available');
  @override
  Future<Map<String, dynamic>> fetchBasePricing() => throw UnsupportedError('Customer: fetchBasePricing not available');
  @override
  Future<void> updateBasePricing(Map<String, dynamic> pricing) => throw UnsupportedError('Customer: updateBasePricing not available');
  @override
  Future<void> toggleSeasonalRule(String id) => throw UnsupportedError('Customer: toggleSeasonalRule not available');
  @override
  Future<void> toggleCoupon(String id) => throw UnsupportedError('Customer: toggleCoupon not available');
  @override
  Future<List<Map<String, dynamic>>> fetchPropertiesRaw() => throw UnsupportedError('Customer: fetchPropertiesRaw not available');
}
