import 'package:vsp_resorts_portal/domain/entities.dart';
import 'package:vsp_resorts_portal/domain/accountant_repository.dart';
import 'package:vsp_resorts_portal/domain/staff_repository.dart';
import 'package:vsp_resorts_portal/domain/customer_repository.dart';
import 'package:vsp_resorts_portal/domain/repositories.dart';

class MockAccountantRepository implements IAccountantRepository {
  @override
  Future<List<Map<String, dynamic>>> fetchProperties() async => [
        {
          'id': '1',
          'name': 'Test Resort',
          'tagline': 'Test',
          'description': 'A test resort',
          'basePriceWeekday': 100,
          'basePriceWeekend': 150,
          'extraGuestCharge': 25,
          'cleaningFee': 50,
          'state': 'Test',
          'city': 'Test',
          'location': 'Test',
          'image': 'https://placehold.co/400',
          'gallery': [],
          'amenities': [],
          'rules': []
        }
      ];
  @override
  Future<void> activateProperty(String id) async {}
  @override
  Future<Map<String, dynamic>> fetchDashboardKpis(String propertyId) async =>
      {};
  @override
  Future<List<Map<String, dynamic>>> fetchRefunds(String propertyId) async =>
      [];
  @override
  Future<List<Booking>> fetchInvoices(
          {String? propertyId,
          String? paymentStatus,
          String? search,
          int page = 1,
          int pageSize = 20}) async =>
      [];
  @override
  Future<Map<String, dynamic>> fetchInvoiceDetail(String id) async => {};
  @override
  Future<Map<String, dynamic>> downloadLedgerPdf(
          String propertyId, String from, String to) async =>
      {'recordCount': 10, 'totalRevenue': '₹50000', 'format': 'pdf'};
  @override
  Future<Map<String, dynamic>> downloadLedgerExcel(
          String propertyId, String from, String to) async =>
      {'recordCount': 10, 'totalRevenue': '₹50000', 'format': 'xlsx'};
  @override
  Future<List<AppNotification>> fetchNotifications() async => [];
  @override
  Future<void> markNotificationAsRead(String id) async {}
  @override
  Future<void> markAllNotificationsAsRead() async {}
  @override
  Future<Map<String, dynamic>> fetchDashboard() async => {};
  @override
  Future<List<Map<String, dynamic>>> fetchAccountantBookings(
          {String? paymentStatus,
          String? refundStatus,
          String? search,
          int page = 1,
          int pageSize = 20}) async =>
      [];
  @override
  Future<Map<String, dynamic>> fetchAccountantBookingDetail(String id) async =>
      {};
  @override
  Future<void> updateInvoice(String id, Map<String, dynamic> data) async {}
  @override
  Future<String> exportReport(String format, String from, String to) async =>
      '';
  @override
  Future<Map<String, dynamic>> processRefund(String id) async => {};
}

class MockStaffRepository implements IStaffRepository {
  @override
  Future<List<Map<String, dynamic>>> fetchProperties() async => [
        {'id': '1', 'name': 'Test Resort'}
      ];
  @override
  Future<void> activateProperty(String id) async {}
  @override
  Future<Map<String, dynamic>> fetchRoster(
          String propertyId, String date) async =>
      {};
  @override
  Future<List<RoomStatus>> fetchHousekeepingRooms(String propertyId) async =>
      [];
  @override
  Future<void> updateHousekeepingStatus(String roomId, String status,
      {String? assignedStaff, String? notes}) async {}
  @override
  Future<List<AppNotification>> fetchNotifications() async => [];
  @override
  Future<void> markNotificationAsRead(String id) async {}
  @override
  Future<void> markAllNotificationsAsRead() async {}
  @override
  Future<Map<String, dynamic>> fetchDashboard() async => {};
  @override
  Future<List<Map<String, dynamic>>> fetchTasks(String propertyId,
          {String? status, String? date}) async =>
      [];
  @override
  Future<void> updateTask(String id, String status, {String? notes}) async {}
  @override
  Future<Map<String, dynamic>> fetchTaskSummary(String propertyId) async => {};
}

class MockCustomerRepository implements ICustomerRepository {
  @override
  Future<List<Map<String, dynamic>>> fetchProperties(
          {String? search,
          String? state,
          String? city,
          String? category}) async =>
      [
        {
          'id': '1',
          'name': 'Test Resort',
          'tagline': 'Test',
          'description': 'A test resort',
          'basePriceWeekday': 100,
          'basePriceWeekend': 150,
          'extraGuestCharge': 25,
          'cleaningFee': 50,
          'state': 'Test',
          'city': 'Test',
          'location': 'Test',
          'image': 'https://placehold.co/400',
          'gallery': [],
          'amenities': [],
          'rules': []
        }
      ];
  @override
  Future<Map<String, dynamic>> fetchPropertyDetail(String id) async => {};
  @override
  Future<Map<String, dynamic>> fetchTaxRate() async => {};
  @override
  Future<Map<String, dynamic>> fetchDepositRate() async => {};
  @override
  Future<List<Map<String, dynamic>>> fetchSeasonalRules(
          String propertyId) async =>
      [];
  @override
  Future<Map<String, dynamic>> validateCoupon(
          String code, double subtotal, String propertyId) async =>
      {};
  @override
  Future<List<Map<String, dynamic>>> fetchAvailableCoupons() async => [];
  @override
  Future<List<Booking>> fetchBookings(
          {String? status, int page = 1, int pageSize = 20}) async =>
      [];
  @override
  Future<Map<String, dynamic>> fetchBookingDetail(String id) async => {};
  @override
  Future<Map<String, dynamic>> createBooking(
          Map<String, dynamic> booking) async =>
      {};
  @override
  Future<Map<String, dynamic>> cancelBooking(String id, String reason) async =>
      {};
  @override
  Future<Map<String, dynamic>> initiatePayment(
          Map<String, dynamic> payment) async =>
      {};
  @override
  Future<Map<String, dynamic>> fetchPaymentForBooking(String bookingId) async =>
      {};
  @override
  Future<List<Map<String, dynamic>>> fetchFavorites() async => [];
  @override
  Future<void> addFavorite(String propertyId) async {}
  @override
  Future<void> removeFavorite(String propertyId) async {}
  @override
  Future<Map<String, dynamic>> fetchProfile() async => {};
  @override
  Future<Map<String, dynamic>> updateProfile(
          Map<String, dynamic> profile) async =>
      {};
  @override
  Future<void> changePassword(
      String currentPassword, String newPassword) async {}
  @override
  Future<Map<String, dynamic>> fetchStats() async => {};
  @override
  Future<List<Map<String, dynamic>>> fetchCalendarBlocks(
          String propertyId, String from, String to) async =>
      [];
  @override
  Future<Map<String, dynamic>> fetchAvailability(
          String propertyId, String from, String to) async =>
      {};
  @override
  Future<Map<String, dynamic>> fetchMonthlyCalendar(
          String propertyId, int month, int year) async =>
      {};
  @override
  Future<List<Map<String, dynamic>>> fetchConciergeRequests() async => [];
  @override
  Future<List<Map<String, dynamic>>> fetchInvoices(
          {String? status, int page = 1, int pageSize = 20}) async =>
      [];
  @override
  Future<Map<String, dynamic>> fetchInvoiceDetail(String id) async => {};
  @override
  Future<List<AppNotification>> fetchNotifications() async => [];
  @override
  Future<void> markNotificationAsRead(String id) async {}
  @override
  Future<void> sendConciergeMessage(String message, String source) async {}
}

class MockResortRepository implements IResortRepository {
  @override
  Future<PropertyDetails> fetchPropertyDetails() async => PropertyDetails(
      id: '1',
      name: 'Test',
      tagline: '',
      description: '',
      location: '',
      basePriceWeekday: 0,
      basePriceWeekend: 0,
      extraGuestCharge: 0,
      cleaningFee: 0,
      state: '',
      city: '',
      image: '',
      gallery: [],
      amenities: [],
      rules: []);
  @override
  Future<List<Booking>> fetchBookings() async => [];
  @override
  Future<Map<String, dynamic>> addBooking(Booking booking) async => {};
  @override
  Future<void> updateBooking(Booking booking) async {}
  @override
  Future<List<CalendarBlock>> fetchCalendarBlocks() async => [];
  @override
  Future<void> addCalendarBlock(CalendarBlock block) async {}
  @override
  Future<void> removeCalendarBlock(String id) async {}
  @override
  Future<List<Coupon>> fetchCoupons() async => [];
  @override
  Future<Map<String, dynamic>> fetchCouponDetail(String id) async => {};
  @override
  Future<void> addCoupon(Coupon coupon) async {}
  @override
  Future<void> updateCoupon(Coupon coupon) async {}
  @override
  Future<void> deleteCoupon(String id) async {}
  @override
  Future<List<RoomStatus>> fetchRoomStatuses() async => [];
  @override
  Future<void> updateRoomStatus(RoomStatus status) async {}
  @override
  Future<List<PricingSeasonRule>> fetchPricingRules() async => [];
  @override
  Future<void> addPricingRule(PricingSeasonRule rule) async {}
  @override
  Future<void> updatePricingRule(PricingSeasonRule rule) async {}
  @override
  Future<void> deletePricingRule(String id) async {}
  @override
  Future<List<OtaSyncStatus>> fetchOtaSyncStatuses() async => [];
  @override
  Future<void> updateOtaSyncStatus(OtaSyncStatus status) async {}
  @override
  Future<List<AppNotification>> fetchNotifications() async => [];
  @override
  Future<void> addNotification(AppNotification notification) async {}
  @override
  Future<void> markNotificationAsRead(String id) async {}
  @override
  Future<void> clearNotifications() async {}
  @override
  Future<Map<String, dynamic>> fetchAnalyticsKpis() async => {};
  @override
  Future<List<Map<String, dynamic>>> fetchAnalyticsSalesChart() async => [];
  @override
  Future<List<Map<String, dynamic>>> fetchAnalyticsMetricsInsights() async =>
      [];
  @override
  Future<void> activateProperty(String id, bool active) async {}
  @override
  Future<Map<String, dynamic>> fetchBookingDetail(String id) async => {};
  @override
  Future<List<Map<String, dynamic>>> fetchBookingNotes(
          String bookingId) async =>
      [];
  @override
  Future<void> authorizePayment(String bookingId) async {}
  @override
  Future<void> revokeBooking(String bookingId, {String? reason}) async {}
  @override
  Future<Map<String, dynamic>> fetchBasePricing() async => {};
  @override
  Future<void> updateBasePricing(Map<String, dynamic> pricing) async {}
  @override
  Future<void> toggleSeasonalRule(String id) async {}
  @override
  Future<void> toggleCoupon(String id) async {}
  @override
  Future<List<Map<String, dynamic>>> fetchPropertiesRaw() async => [];
}
