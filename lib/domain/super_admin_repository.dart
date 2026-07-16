import 'entities.dart';

/// Repository interface for Super Admin operations against
/// `/api/v1/super-admin/**`.
///
/// Covers analytics, global settings, multi-property CRUD, user management,
/// RBAC, approval workflow, audit logs, and system operations — everything
/// that is exclusive to the SUPER_ADMIN role.
abstract class ISuperAdminRepository {
  // ── Analytics ──
  Future<Map<String, dynamic>> fetchAnalyticsRevenue();
  Future<List<Map<String, dynamic>>> fetchBookingSources();
  Future<List<Map<String, dynamic>>> fetchResortRevenueTable();

  // ── Global Settings ──
  Future<Map<String, dynamic>> fetchGlobalSettings();
  Future<void> updateGlobalSettings(Map<String, dynamic> settings);
  Future<void> factoryReset({String? confirmationToken});
  Future<Map<String, dynamic>> fetchSchema();

  // ── Multi-Property Management ──
  Future<List<Map<String, dynamic>>> fetchProperties();
  Future<Map<String, dynamic>> fetchPropertyDetail(String id);
  Future<void> createProperty(Map<String, dynamic> property);
  Future<void> updateProperty(String id, Map<String, dynamic> property);
  Future<void> deleteProperty(String id);
  Future<Map<String, dynamic>> uploadImage(String filePath, {String? caption});
  Future<List<Map<String, dynamic>>> uploadGallery(List<String> filePaths);

  // ── User Management ──
  Future<List<Map<String, dynamic>>> fetchUsers(
      {String? role,
      String? status,
      String? search,
      int page = 1,
      int pageSize = 20});
  Future<Map<String, dynamic>> fetchUserDetail(String id);
  Future<void> createUser(Map<String, dynamic> user);
  Future<void> updateUser(String id, Map<String, dynamic> user);
  Future<void> deleteUser(String id);

  // ── Approval Workflow ──
  Future<List<Map<String, dynamic>>> fetchApprovals();
  Future<List<Map<String, dynamic>>> fetchPendingApprovals();
  Future<void> resolveApproval(String id, String status,
      {String? rejectionReason});

  // ── RBAC ──
  Future<List<RoleDefinition>> fetchRoles();
  Future<RoleDefinition> fetchRoleDetail(String id);
  Future<void> updateRole(RoleDefinition role);

  // ── Audit Logs ──
  Future<List<Map<String, dynamic>>> fetchAuditLogs(
      {String? userId,
      String? action,
      String? from,
      String? to,
      int? page,
      int? pageSize});

  // ── Super Admin Notifications ──
  Future<List<AppNotification>> fetchNotifications();
  Future<void> addNotification(AppNotification notification);
  Future<void> markNotificationAsRead(String id);
  Future<void> clearNotifications();

  // ── Bookings (cross-property) ──
  Future<List<Booking>> fetchAllBookings();
}
