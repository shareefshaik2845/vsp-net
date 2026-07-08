import 'entities.dart';

abstract class IAccountantRepository {
  Future<List<Map<String, dynamic>>> fetchProperties();
  Future<void> activateProperty(String id);
  Future<Map<String, dynamic>> fetchDashboardKpis(String propertyId);
  Future<List<Map<String, dynamic>>> fetchRefunds(String propertyId);
  Future<Map<String, dynamic>> processRefund(String id);
  Future<List<Booking>> fetchInvoices({String? propertyId, String? paymentStatus, String? search, int page = 1, int pageSize = 20});
  Future<Map<String, dynamic>> fetchInvoiceDetail(String id);
  Future<void> downloadLedgerPdf(String propertyId, String from, String to);
  Future<void> downloadLedgerExcel(String propertyId, String from, String to);
  Future<List<AppNotification>> fetchNotifications();
  Future<void> markNotificationAsRead(String id);
  Future<void> markAllNotificationsAsRead();

  // ── Accountant Dashboard & Bookings ──
  Future<Map<String, dynamic>> fetchDashboard();
  Future<List<Map<String, dynamic>>> fetchAccountantBookings({String? paymentStatus, String? refundStatus, String? search, int page = 1, int pageSize = 20});
  Future<Map<String, dynamic>> fetchAccountantBookingDetail(String id);

  // ── Accountant Invoice Update ──
  Future<void> updateInvoice(String id, Map<String, dynamic> data);

  // ── Accountant Export ──
  Future<String> exportReport(String format, String from, String to);
}
