import 'entities.dart';

abstract class IResortRepository {
  Future<PropertyDetails> fetchPropertyDetails();
  Future<List<Booking>> fetchBookings();
  Future<Map<String, dynamic>> addBooking(Booking booking);
  Future<void> updateBooking(Booking booking);
  
  Future<List<CalendarBlock>> fetchCalendarBlocks();
  Future<void> addCalendarBlock(CalendarBlock block);
  Future<void> removeCalendarBlock(String id);
  
  Future<List<Coupon>> fetchCoupons();
  Future<Map<String, dynamic>> fetchCouponDetail(String id);
  Future<void> addCoupon(Coupon coupon);
  Future<void> updateCoupon(Coupon coupon);
  Future<void> deleteCoupon(String id);
  
  Future<List<RoomStatus>> fetchRoomStatuses();
  Future<void> updateRoomStatus(RoomStatus status);
  
  Future<List<PricingSeasonRule>> fetchPricingRules();
  Future<void> addPricingRule(PricingSeasonRule rule);
  Future<void> updatePricingRule(PricingSeasonRule rule);
  Future<void> deletePricingRule(String id);
  
  Future<List<OtaSyncStatus>> fetchOtaSyncStatuses();
  Future<void> updateOtaSyncStatus(OtaSyncStatus status);
  
  Future<List<AppNotification>> fetchNotifications();
  Future<void> addNotification(AppNotification notification);
  Future<void> markNotificationAsRead(String id);
  Future<void> clearNotifications();
  
  // ── Admin Analytics ──
  Future<Map<String, dynamic>> fetchAnalyticsKpis();
  Future<List<Map<String, dynamic>>> fetchAnalyticsSalesChart();
  Future<List<Map<String, dynamic>>> fetchAnalyticsMetricsInsights();
  
  // ── Admin Property ──
  Future<void> activateProperty(String id, bool active);
  
  // ── Admin Booking Detail ──
  Future<Map<String, dynamic>> fetchBookingDetail(String id);
  Future<List<Map<String, dynamic>>> fetchBookingNotes(String bookingId);
  Future<void> authorizePayment(String bookingId);
  Future<void> revokeBooking(String bookingId, {String? reason});
  
  // ── Admin Base Pricing ──
  Future<Map<String, dynamic>> fetchBasePricing();
  Future<void> updateBasePricing(Map<String, dynamic> pricing);
  
  // ── Admin Toggle ──
  Future<void> toggleSeasonalRule(String id);
  Future<void> toggleCoupon(String id);

  // ── Raw Properties (for admin property selector) ──
  Future<List<Map<String, dynamic>>> fetchPropertiesRaw();
}
