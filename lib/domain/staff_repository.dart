import 'entities.dart';

abstract class IStaffRepository {
  Future<List<Map<String, dynamic>>> fetchProperties();
  Future<void> activateProperty(String id);
  Future<Map<String, dynamic>> fetchRoster(String propertyId, String date);
  Future<List<RoomStatus>> fetchHousekeepingRooms(String propertyId);
  Future<void> updateHousekeepingStatus(String roomId, String status,
      {String? assignedStaff, String? notes});
  Future<List<AppNotification>> fetchNotifications();
  Future<void> markNotificationAsRead(String id);
  Future<void> markAllNotificationsAsRead();

  // ── Staff Dashboard & Tasks ──
  Future<Map<String, dynamic>> fetchDashboard();
  Future<List<Map<String, dynamic>>> fetchTasks(String propertyId,
      {String? status, String? date});
  Future<void> updateTask(String id, String status, {String? notes});
  Future<Map<String, dynamic>> fetchTaskSummary(String propertyId);
}
