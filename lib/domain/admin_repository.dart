abstract class IAdminRepository {
  // ── Concierge ──
  Future<List<Map<String, dynamic>>> fetchConciergeRequests({String? status, String? type});
  Future<void> updateConciergeStatus(String id, String status);
  Future<void> assignConciergeStaff(String id, int staffId);
  Future<void> updateConciergeNotes(String id, String notes);
  Future<List<Map<String, dynamic>>> fetchStaffUsers();
}
