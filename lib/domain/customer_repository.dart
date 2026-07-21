import 'entities.dart';

abstract class ICustomerRepository {
  Future<List<Map<String, dynamic>>> fetchProperties(
      {String? search, String? state, String? city, String? category});
  Future<Map<String, dynamic>> fetchPropertyDetail(String id);
  Future<Map<String, dynamic>> fetchTaxRate();
  Future<Map<String, dynamic>> fetchDepositRate();
  Future<List<Map<String, dynamic>>> fetchSeasonalRules(String propertyId);
  Future<Map<String, dynamic>> validateCoupon(
      String code, double subtotal, String propertyId);
  Future<List<Map<String, dynamic>>> fetchAvailableCoupons();
  Future<List<Booking>> fetchBookings(
      {String? status, int page = 1, int pageSize = 20});
  Future<Map<String, dynamic>> fetchBookingDetail(String id);
  Future<Map<String, dynamic>> createBooking(Map<String, dynamic> booking);
  Future<Map<String, dynamic>> cancelBooking(String id, String reason);
  Future<Map<String, dynamic>> initiatePayment(Map<String, dynamic> payment);
  Future<List<Map<String, dynamic>>> fetchFavorites();
  Future<void> addFavorite(String propertyId);
  Future<void> removeFavorite(String propertyId);
  Future<Map<String, dynamic>> fetchProfile();
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> profile);
  Future<void> changePassword(String currentPassword, String newPassword);
  Future<Map<String, dynamic>> fetchStats();
  Future<List<Map<String, dynamic>>> fetchCalendarBlocks(
      String propertyId, String from, String to);
  Future<Map<String, dynamic>> fetchAvailability(
      String propertyId, String from, String to);
  Future<Map<String, dynamic>> fetchMonthlyCalendar(
      String propertyId, int month, int year);
  Future<Map<String, dynamic>> fetchPaymentForBooking(String bookingId);
  Future<List<Map<String, dynamic>>> fetchConciergeRequests();
  Future<List<Map<String, dynamic>>> fetchInvoices(
      {String? status, int page = 1, int pageSize = 20});
  Future<Map<String, dynamic>> fetchInvoiceDetail(String id);
  Future<List<AppNotification>> fetchNotifications();
  Future<void> markNotificationAsRead(String id);
  Future<void> markAllNotificationsRead();
  Future<void> sendConciergeMessage(
    String message,
    String source, {
    String? bookingId,
    String? preferredDateTime,
  });
}
