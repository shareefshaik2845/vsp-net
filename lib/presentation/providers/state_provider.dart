import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities.dart';
import '../../domain/repositories.dart';
import '../../domain/super_admin_repository.dart';
import '../../domain/customer_repository.dart';
import '../../domain/staff_repository.dart';
import '../../domain/accountant_repository.dart';
import '../../data/remote/http_resort_repository_impl.dart';
import '../../data/remote/http_super_admin_repository_impl.dart';
import '../../data/remote/http_customer_repository_impl.dart';
import '../../data/remote/http_customer_resort_adapter.dart';
import '../../data/remote/http_staff_repository_impl.dart';
import '../../data/remote/http_staff_resort_adapter.dart';
import '../../data/remote/http_accountant_repository_impl.dart';
import '../../data/remote/http_accountant_resort_adapter.dart';

final resortRepositoryProvider = Provider<IResortRepository>((ref) {
  final role = ref.watch(activeRoleProvider);
  switch (role) {
    case UserRole.customer:
      return HttpCustomerResortAdapter(ref.watch(customerRepositoryProvider));
    case UserRole.staff:
      return HttpStaffResortAdapter(ref.watch(staffRepositoryProvider));
    case UserRole.accountant:
      return HttpAccountantResortAdapter(ref.watch(accountantRepositoryProvider));
    default:
      return HttpResortRepositoryImpl();
  }
});

// Active Role Provider
final activeRoleProvider = StateProvider<UserRole>((ref) => UserRole.customer);

// Login Session State Provider
final isLoggedInProvider = StateProvider<bool>((ref) => false);

// Splash Screen Finished Provider
final isSplashFinishedProvider = StateProvider<bool>((ref) => false);

// Authenticated Role Provider (tracks the original logged-in role)
final authenticatedRoleProvider = StateProvider<UserRole?>((ref) => null);

// Active Tab Provider
final activeTabProvider = StateProvider<String>((ref) => 'villa');



final taxRateProvider = Provider<int>((ref) {
  final pricing = ref.watch(customerPricingProvider);
  return (pricing['taxRate'] as int?) ?? 18;
});

final depositRateProvider = Provider<int>((ref) {
  final pricing = ref.watch(customerPricingProvider);
  return (pricing['depositRate'] as int?) ?? 30;
});

// Bookings Notifier
class BookingsNotifier extends StateNotifier<List<Booking>> {
  final IResortRepository _repository;
  String? lastError;
  BookingsNotifier(this._repository) : super([]) {
    loadBookings();
  }

  Future<void> loadBookings() async {
    lastError = null;
    try {
      state = await _repository.fetchBookings();
    } catch (e) {
      lastError = 'Failed to load bookings';
      debugPrint('loadBookings error: $e');
      state = [];
    }
  }

  Future<void> addBooking(Booking booking) async {
    await _repository.addBooking(booking);
    state = [booking, ...state];
  }

  Future<void> cancelBooking(String bookingId, String reason, double refundPercent) async {
    final idx = state.indexWhere((b) => b.id == bookingId);
    if (idx != -1) {
      final b = state[idx];
      final refundVal = b.advancePaidAmount * (refundPercent / 100);
      final updated = b.copyWith(
        status: BookingStatus.cancelled,
        paymentStatus: PaymentStatus.pending,
        cancellationReason: reason,
        refundAmount: refundVal,
        balanceAmount: 0,
      );
      await _repository.updateBooking(updated);
      state = [
        for (final item in state)
          if (item.id == bookingId) updated else item
      ];
    }
  }

  Future<void> checkInBooking(String bookingId) async {
    final idx = state.indexWhere((b) => b.id == bookingId);
    if (idx != -1) {
      final updated = state[idx].copyWith(status: BookingStatus.checkedIn);
      await _repository.updateBooking(updated);
      state = [
        for (final item in state)
          if (item.id == bookingId) updated else item
      ];
    }
  }

  Future<void> checkOutBooking(String bookingId, double outstandingPaid) async {
    final idx = state.indexWhere((b) => b.id == bookingId);
    if (idx != -1) {
      final b = state[idx];
      final updated = b.copyWith(
        status: BookingStatus.checkedOut,
        paymentStatus: PaymentStatus.paid,
        advancePaidAmount: b.advancePaidAmount + outstandingPaid,
        balanceAmount: 0,
      );
      await _repository.updateBooking(updated);
      state = [
        for (final item in state)
          if (item.id == bookingId) updated else item
      ];
    }
  }

  Future<void> confirmPayment(String bookingId) async {
    final idx = state.indexWhere((b) => b.id == bookingId);
    if (idx != -1) {
      final b = state[idx];
      final updated = b.copyWith(
        status: BookingStatus.confirmed,
        paymentStatus: PaymentStatus.paid,
        advancePaidAmount: b.totalAmount,
        balanceAmount: 0,
      );
      await _repository.updateBooking(updated);
      state = [
        for (final item in state)
          if (item.id == bookingId) updated else item
      ];
    }
  }

  Future<void> processRefund(String bookingId) async {
    final idx = state.indexWhere((b) => b.id == bookingId);
    if (idx != -1) {
      final b = state[idx];
      final updated = b.copyWith(
        paymentStatus: PaymentStatus.refunded,
      );
      await _repository.updateBooking(updated);
      state = [
        for (final item in state)
          if (item.id == bookingId) updated else item
      ];
    }
  }
}

final bookingsProvider = StateNotifierProvider<BookingsNotifier, List<Booking>>((ref) {
  final repo = ref.watch(resortRepositoryProvider);
  return BookingsNotifier(repo);
});

// Calendar Blocks Notifier
class CalendarBlocksNotifier extends StateNotifier<List<CalendarBlock>> {
  final IResortRepository _repository;
  String? lastError;
  CalendarBlocksNotifier(this._repository) : super([]) {
    loadBlocks();
  }

  Future<void> loadBlocks() async {
    lastError = null;
    try {
      state = await _repository.fetchCalendarBlocks();
    } catch (e) {
      lastError = 'Failed to load blocks';
      debugPrint('loadBlocks error: $e');
      state = [];
    }
  }

  Future<void> addBlock(CalendarBlock block) async {
    await _repository.addCalendarBlock(block);
    state = [...state, block];
  }

  Future<void> removeBlock(String id) async {
    await _repository.removeCalendarBlock(id);
    state = state.where((b) => b.id != id).toList();
  }
}

final calendarBlocksProvider = StateNotifierProvider<CalendarBlocksNotifier, List<CalendarBlock>>((ref) {
  final repo = ref.watch(resortRepositoryProvider);
  return CalendarBlocksNotifier(repo);
});

// Coupons Notifier
class CouponsNotifier extends StateNotifier<List<Coupon>> {
  final IResortRepository _repository;
  String? lastError;
  CouponsNotifier(this._repository) : super([]) {
    loadCoupons();
  }

  Future<void> loadCoupons() async {
    lastError = null;
    try {
      state = await _repository.fetchCoupons();
    } catch (e) {
      lastError = 'Failed to load coupons';
      debugPrint('loadCoupons error: $e');
      state = [];
    }
  }

  Future<void> addCoupon(Coupon coupon) async {
    await _repository.addCoupon(coupon);
    state = [...state, coupon];
  }

  Future<void> deleteCoupon(String id) async {
    await _repository.deleteCoupon(id);
    state = state.where((c) => c.id != id).toList();
  }

  Future<void> toggleCouponActive(String id) async {
    final idx = state.indexWhere((c) => c.id == id);
    if (idx != -1) {
      final updated = state[idx].copyWith(isActive: !state[idx].isActive);
      await _repository.updateCoupon(updated);
      state = [
        for (final item in state)
          if (item.id == id) updated else item
      ];
    }
  }
}

final couponsProvider = StateNotifierProvider<CouponsNotifier, List<Coupon>>((ref) {
  final repo = ref.watch(resortRepositoryProvider);
  return CouponsNotifier(repo);
});

// Rooms Status Notifier
class RoomsNotifier extends StateNotifier<List<RoomStatus>> {
  final IResortRepository _repository;
  String? lastError;
  RoomsNotifier(this._repository) : super([]) {
    loadRooms();
  }

  Future<void> loadRooms() async {
    lastError = null;
    try {
      state = await _repository.fetchRoomStatuses();
    } catch (e) {
      lastError = 'Failed to load rooms';
      debugPrint('loadRooms error: $e');
      state = [];
    }
  }

  Future<void> updateHousekeeping(String id, HousekeepingStatus status, {String? notes, String? staff}) async {
    final idx = state.indexWhere((r) => r.id == id);
    if (idx != -1) {
      final r = state[idx];
      final updated = r.copyWith(
        status: status,
        notes: notes ?? r.notes,
        assignedStaff: staff ?? r.assignedStaff,
        lastUpdated: DateTime.now().toIso8601String(),
      );
      await _repository.updateRoomStatus(updated);
      state = [
        for (final item in state)
          if (item.id == id) updated else item
      ];
    }
  }
}

final roomsProvider = StateNotifierProvider<RoomsNotifier, List<RoomStatus>>((ref) {
  final repo = ref.watch(resortRepositoryProvider);
  return RoomsNotifier(repo);
});

// Pricing Rules Notifier
class PricingRulesNotifier extends StateNotifier<List<PricingSeasonRule>> {
  final IResortRepository _repository;
  String? lastError;
  PricingRulesNotifier(this._repository) : super([]) {
    loadRules();
  }

  Future<void> loadRules() async {
    lastError = null;
    try {
      state = await _repository.fetchPricingRules();
    } catch (e) {
      lastError = 'Failed to load pricing rules';
      debugPrint('loadRules error: $e');
      state = [];
    }
  }

  Future<void> addRule(PricingSeasonRule rule) async {
    await _repository.addPricingRule(rule);
    state = [...state, rule];
  }

  Future<void> deleteRule(String id) async {
    await _repository.deletePricingRule(id);
    state = state.where((r) => r.id != id).toList();
  }

  Future<void> toggleRuleActive(String id) async {
    final idx = state.indexWhere((r) => r.id == id);
    if (idx != -1) {
      final updated = state[idx].copyWith(isActive: !state[idx].isActive);
      await _repository.updatePricingRule(updated);
      state = [
        for (final item in state)
          if (item.id == id) updated else item
      ];
    }
  }
}

final pricingRulesProvider = StateNotifierProvider<PricingRulesNotifier, List<PricingSeasonRule>>((ref) {
  final repo = ref.watch(resortRepositoryProvider);
  return PricingRulesNotifier(repo);
});

// OTA Notifier
class OtaChannelsNotifier extends StateNotifier<List<OtaSyncStatus>> {
  final IResortRepository _repository;
  String? lastError;
  OtaChannelsNotifier(this._repository) : super([]) {
    loadChannels();
  }

  Future<void> loadChannels() async {
    lastError = null;
    try {
      state = await _repository.fetchOtaSyncStatuses();
    } catch (e) {
      lastError = 'Failed to load OTA channels';
      debugPrint('loadChannels error: $e');
      state = [];
    }
  }

  Future<void> toggleSync(String id) async {
    final idx = state.indexWhere((o) => o.id == id);
    if (idx != -1) {
      final updated = state[idx].copyWith(syncEnabled: !state[idx].syncEnabled);
      await _repository.updateOtaSyncStatus(updated);
      state = [
        for (final item in state)
          if (item.id == id) updated else item
      ];
    }
  }

  Future<void> triggerSyncSuccess(String id) async {
    final idx = state.indexWhere((o) => o.id == id);
    if (idx != -1) {
      final updated = state[idx].copyWith(
        status: 'success',
        conflictsCount: 0,
        lastSyncTime: DateTime.now().toIso8601String(),
      );
      await _repository.updateOtaSyncStatus(updated);
      state = [
        for (final item in state)
          if (item.id == id) updated else item
      ];
    }
  }
}

final otaSyncProvider = StateNotifierProvider<OtaChannelsNotifier, List<OtaSyncStatus>>((ref) {
  final repo = ref.watch(resortRepositoryProvider);
  return OtaChannelsNotifier(repo);
});

// Notifications Notifier
class NotificationsNotifier extends StateNotifier<List<AppNotification>> {
  final IResortRepository _repository;
  String? lastError;
  NotificationsNotifier(this._repository) : super([]) {
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    lastError = null;
    try {
      state = await _repository.fetchNotifications();
    } catch (e) {
      lastError = 'Failed to load notifications';
      debugPrint('loadNotifications error: $e');
      state = [];
    }
  }

  Future<void> addNotification(String title, String message, String type) async {
    final notif = AppNotification(
      id: 'NT-${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      message: message,
      timestamp: DateTime.now().toIso8601String(),
      type: type,
      read: false,
    );
    await _repository.addNotification(notif);
    state = [notif, ...state];
  }

  Future<void> markAsRead(String id) async {
    await _repository.markNotificationAsRead(id);
    state = [
      for (final item in state)
        if (item.id == id) item.copyWith(read: true) else item
    ];
  }

  Future<void> clearAll() async {
    await _repository.clearNotifications();
    state = [];
  }
}

final notificationsProvider = StateNotifierProvider<NotificationsNotifier, List<AppNotification>>((ref) {
  final repo = ref.watch(resortRepositoryProvider);
  return NotificationsNotifier(repo);
});



PropertyDetails _propertyFromJson(Map<String, dynamic> json) {
  return PropertyDetails(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    tagline: json['tagline'] as String? ?? '',
    description: json['description'] as String? ?? '',
    location: json['location'] as String? ?? '',
    basePriceWeekday: (json['basePriceWeekday'] as num?)?.toDouble() ?? 0,
    basePriceWeekend: (json['basePriceWeekend'] as num?)?.toDouble() ?? 0,
    extraGuestCharge: (json['extraGuestCharge'] as num?)?.toDouble() ?? 0,
    cleaningFee: (json['cleaningFee'] as num?)?.toDouble() ?? 0,
    amenities: (json['amenities'] as List<dynamic>?)?.map((a) {
      final m = a as Map<String, dynamic>;
      return Amenity(
        icon: m['icon'] as String? ?? '',
        label: m['label'] as String? ?? '',
        category: m['category'] as String? ?? '',
      );
    }).toList() ?? [],
    rules: (json['rules'] as List<dynamic>?)?.cast<String>() ?? [],
    state: json['state'] as String? ?? '',
    city: json['city'] as String? ?? '',
    image: json['image'] as String? ?? '',
    gallery: (json['gallery'] as List<dynamic>?)?.cast<String>() ?? [],
  );
}

class PropertyNotifier extends StateNotifier<AsyncValue<PropertyDetails>> {
  String? lastError;
  final Future<PropertyDetails> Function() _loadProperty;
  PropertyNotifier(this._loadProperty) : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    lastError = null;
    try {
      state = AsyncValue.data(await _loadProperty());
    } catch (e, stack) {
      lastError = 'Failed to load property details';
      state = AsyncValue.error(e, stack);
    }
  }

  void updateProperty(PropertyDetails updated) {
    state = AsyncValue.data(updated);
  }
}

final propertyProvider = StateNotifierProvider<PropertyNotifier, AsyncValue<PropertyDetails>>((ref) {
  final role = ref.watch(activeRoleProvider);
  switch (role) {
    case UserRole.admin:
      final repo = ref.watch(resortRepositoryProvider);
      return PropertyNotifier(() => repo.fetchPropertyDetails());
    case UserRole.superAdmin:
      final repo = ref.watch(superAdminRepositoryProvider);
      return PropertyNotifier(() async {
        final props = await repo.fetchProperties();
        if (props.isEmpty) throw Exception('No properties found');
        return _propertyFromJson(props.first);
      });
    case UserRole.staff:
      final repo = ref.watch(staffRepositoryProvider);
      return PropertyNotifier(() async {
        final props = await repo.fetchProperties();
        if (props.isEmpty) throw Exception('No properties found');
        return _propertyFromJson(props.first);
      });
    case UserRole.accountant:
      final repo = ref.watch(accountantRepositoryProvider);
      return PropertyNotifier(() async {
        final props = await repo.fetchProperties();
        if (props.isEmpty) throw Exception('No properties found');
        return _propertyFromJson(props.first);
      });
    case UserRole.customer:
      final repo = ref.watch(customerRepositoryProvider);
      return PropertyNotifier(() async {
        final props = await repo.fetchProperties();
        if (props.isEmpty) throw Exception('No properties found');
        return _propertyFromJson(props.first);
      });
  }
});

// Quote calculation utility model
class QuoteDetails {
  final int nightsCount;
  final int weekdayNights;
  final int weekendNights;
  final double baseAmount;
  final double extraGuestAmount;
  final double cleaningAmount;
  final double discountAmount;
  final double taxAmount;
  final double totalAmount;
  final double requiredAdvance;
  final String? seasonApplied;

  const QuoteDetails({
    required this.nightsCount,
    required this.weekdayNights,
    required this.weekendNights,
    required this.baseAmount,
    required this.extraGuestAmount,
    required this.cleaningAmount,
    required this.discountAmount,
    required this.taxAmount,
    required this.totalAmount,
    required this.requiredAdvance,
    this.seasonApplied,
  });
}

class ResortsNotifier extends StateNotifier<List<PropertyDetails>> {
  final Future<List<Map<String, dynamic>>> Function() _loadProperties;
  String? lastError;
  ResortsNotifier(this._loadProperties) : super([]) {
    _init();
  }

  Future<void> _init() async {
    lastError = null;
    try {
      final props = await _loadProperties();
      state = props.map((json) => _propertyFromJson(json)).toList();
    } catch (e) {
      lastError = 'Failed to load properties';
      debugPrint('ResortsNotifier._init error: $e');
    }
  }

  void addResort(PropertyDetails resort) {
    state = [...state, resort];
  }
}

final resortsListProvider = StateNotifierProvider<ResortsNotifier, List<PropertyDetails>>((ref) {
  final role = ref.watch(activeRoleProvider);
  switch (role) {
    case UserRole.admin:
      final repo = ref.watch(resortRepositoryProvider);
      return ResortsNotifier(() => repo.fetchPropertiesRaw());
    case UserRole.superAdmin:
      return ResortsNotifier(() => ref.watch(superAdminRepositoryProvider).fetchProperties());
    case UserRole.staff:
      return ResortsNotifier(() => ref.watch(staffRepositoryProvider).fetchProperties());
    case UserRole.accountant:
      return ResortsNotifier(() => ref.watch(accountantRepositoryProvider).fetchProperties());
    case UserRole.customer:
      return ResortsNotifier(() => ref.watch(customerRepositoryProvider).fetchProperties());
  }
});

class SavedPropertiesNotifier extends StateNotifier<List<PropertyDetails>> {
  final ICustomerRepository _remoteRepo;
  String? lastError;
  SavedPropertiesNotifier(this._remoteRepo) : super([]) {
    _loadRemote();
  }

  Future<void> _loadRemote() async {
    lastError = null;
    try {
      final favs = await _remoteRepo.fetchFavorites();
      state = favs.map((json) => PropertyDetails(
        id: json['id'] as String? ?? json['propertyId'] as String? ?? '',
        name: json['name'] as String? ?? '',
        tagline: json['tagline'] as String? ?? '',
        description: json['description'] as String? ?? '',
        location: json['location'] as String? ?? '',
        basePriceWeekday: (json['basePriceWeekday'] as num?)?.toDouble() ?? 0,
        basePriceWeekend: 0,
        extraGuestCharge: 0,
        cleaningFee: 0,
        amenities: [],
        rules: [],
        state: json['state'] as String? ?? '',
        city: json['city'] as String? ?? '',
        image: json['image'] as String? ?? '',
        gallery: [],
      )).toList();
    } catch (e) {
      lastError = 'Failed to load favorites';
      debugPrint('SavedPropertiesNotifier._loadRemote error: $e');
    }
  }

  void toggleSave(PropertyDetails property) {
    _remoteToggle(property);
  }

  Future<void> _remoteToggle(PropertyDetails property) async {
    lastError = null;
    try {
      if (state.any((p) => p.id == property.id)) {
        await _remoteRepo.removeFavorite(property.id);
        state = state.where((p) => p.id != property.id).toList();
      } else {
        await _remoteRepo.addFavorite(property.id);
        await _loadRemote();
      }
    } catch (e) {
      lastError = 'Failed to toggle favorite';
      debugPrint('SavedPropertiesNotifier._remoteToggle error: $e');
    }
  }

  bool isSaved(PropertyDetails property) {
    return state.any((p) => p.id == property.id || (p.id.isEmpty && p.name == property.name));
  }
}

final savedPropertiesProvider = StateNotifierProvider<SavedPropertiesNotifier, List<PropertyDetails>>((ref) {
  return SavedPropertiesNotifier(ref.watch(customerRepositoryProvider));
});



// ── Super Admin Repository Provider ──

final superAdminRepositoryProvider = Provider<ISuperAdminRepository>((ref) {
  return HttpSuperAdminRepositoryImpl();
});

// ── Super Admin Bookings (cross-property, from /super-admin/**) ──

class SuperAdminBookingsNotifier extends StateNotifier<List<Booking>> {
  final ISuperAdminRepository _repository;
  String? lastError;
  SuperAdminBookingsNotifier(this._repository) : super([]) {
    loadBookings();
  }

  Future<void> loadBookings() async {
    lastError = null;
    try {
      state = await _repository.fetchAllBookings();
    } catch (e) {
      lastError = 'Failed to load bookings';
      debugPrint('SuperAdminBookingsNotifier.loadBookings error: $e');
      state = [];
    }
  }
}

final superAdminBookingsProvider =
    StateNotifierProvider<SuperAdminBookingsNotifier, List<Booking>>((ref) {
  final repo = ref.watch(superAdminRepositoryProvider);
  return SuperAdminBookingsNotifier(repo);
});

// ── Super Admin Users (from /super-admin/users) ──

class SuperAdminUsersNotifier extends StateNotifier<List<UserAccount>> {
  final ISuperAdminRepository _repository;
  String? lastError;
  SuperAdminUsersNotifier(this._repository) : super([]) {
    loadUsers();
  }

  Future<void> loadUsers() async {
    lastError = null;
    try {
      final raw = await _repository.fetchUsers(pageSize: 9999);
      state = raw.map((json) => UserAccount(
        id: json['id']?.toString() ?? '',
        name: json['name'] as String? ?? '',
        email: json['email'] as String? ?? '',
        passwordHash: '',
        role: UserRole.values.firstWhere(
          (e) => e.name.toLowerCase() == (json['role'] as String? ?? '').toLowerCase(),
          orElse: () => UserRole.customer,
        ),
        status: json['status'] == 'inactive' ? UserStatus.inactive : UserStatus.active,
        createdAt: json['createdAt'] as String? ?? '',
        createdBy: json['createdBy'] as String?,
        lastLoginAt: json['lastLoginAt'] as String?,
      )).toList();
    } catch (e) {
      lastError = 'Failed to load users';
      debugPrint('SuperAdminUsersNotifier.loadUsers error: $e');
      state = [];
    }
  }
}

final superAdminUsersProvider =
    StateNotifierProvider<SuperAdminUsersNotifier, List<UserAccount>>((ref) {
  final repo = ref.watch(superAdminRepositoryProvider);
  return SuperAdminUsersNotifier(repo);
});

// ── Super Admin Roles ──

class SuperAdminRolesNotifier extends StateNotifier<List<RoleDefinition>> {
  final ISuperAdminRepository _repository;
  String? lastError;
  SuperAdminRolesNotifier(this._repository) : super([]) {
    loadRoles();
  }

  Future<void> loadRoles() async {
    lastError = null;
    try {
      state = await _repository.fetchRoles();
    } catch (e) {
      lastError = 'Failed to load roles';
      debugPrint('SuperAdminRolesNotifier.loadRoles error: $e');
      state = [];
    }
  }

  Future<void> updateRole(RoleDefinition role) async {
    await _repository.updateRole(role);
    state = [
      for (final r in state)
        if (r.id == role.id) role else r,
    ];
  }
}

final superAdminRolesProvider =
    StateNotifierProvider<SuperAdminRolesNotifier, List<RoleDefinition>>((ref) {
  final repo = ref.watch(superAdminRepositoryProvider);
  return SuperAdminRolesNotifier(repo);
});

// ── Super Admin Approvals ──

class SuperAdminApprovalsNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  final ISuperAdminRepository _repository;
  String? lastError;
  SuperAdminApprovalsNotifier(this._repository) : super([]) {
    loadApprovals();
  }

  Future<void> loadApprovals() async {
    lastError = null;
    try {
      state = await _repository.fetchApprovals();
    } catch (e) {
      lastError = 'Failed to load approvals';
      debugPrint('SuperAdminApprovalsNotifier.loadApprovals error: $e');
      state = [];
    }
  }

  Future<void> resolve(String id, String status, {String? reason}) async {
    await _repository.resolveApproval(id, status, rejectionReason: reason);
    state = [
      for (final a in state)
        if (a['id'] == id) {...a, 'status': status} else a,
    ];
  }
}

final superAdminApprovalsProvider =
    StateNotifierProvider<SuperAdminApprovalsNotifier, List<Map<String, dynamic>>>((ref) {
  final repo = ref.watch(superAdminRepositoryProvider);
  return SuperAdminApprovalsNotifier(repo);
});

// ── Super Admin Notifications ──

class SuperAdminNotificationsNotifier extends StateNotifier<List<AppNotification>> {
  final ISuperAdminRepository _repository;
  String? lastError;
  SuperAdminNotificationsNotifier(this._repository) : super([]) {
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    lastError = null;
    try {
      state = await _repository.fetchNotifications();
    } catch (e) {
      lastError = 'Failed to load notifications';
      debugPrint('SuperAdminNotificationsNotifier.loadNotifications error: $e');
      state = [];
    }
  }

  Future<void> addNotification(String title, String message, String type) async {
    final notif = AppNotification(
      id: 'SA-NT-${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      message: message,
      timestamp: DateTime.now().toIso8601String(),
      type: type,
      read: false,
    );
    await _repository.addNotification(notif);
    state = [notif, ...state];
  }

  Future<void> markAsRead(String id) async {
    await _repository.markNotificationAsRead(id);
    state = [
      for (final item in state)
        if (item.id == id) item.copyWith(read: true) else item
    ];
  }

  Future<void> clearAll() async {
    await _repository.clearNotifications();
    state = [];
  }
}

final superAdminNotificationsProvider =
    StateNotifierProvider<SuperAdminNotificationsNotifier, List<AppNotification>>((ref) {
  final repo = ref.watch(superAdminRepositoryProvider);
  return SuperAdminNotificationsNotifier(repo);
});

// ── Super Admin Global Settings ──

class SuperAdminSettingsNotifier extends StateNotifier<Map<String, dynamic>> {
  final ISuperAdminRepository _repository;
  String? lastError;
  SuperAdminSettingsNotifier(this._repository) : super({}) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    lastError = null;
    try {
      state = await _repository.fetchGlobalSettings();
    } catch (e) {
      lastError = 'Failed to load settings';
      debugPrint('SuperAdminSettingsNotifier.loadSettings error: $e');
      state = {};
    }
  }

  Future<void> updateSettings(Map<String, dynamic> settings) async {
    await _repository.updateGlobalSettings(settings);
    state = settings;
  }
}

final superAdminSettingsProvider =
    StateNotifierProvider<SuperAdminSettingsNotifier, Map<String, dynamic>>((ref) {
  final repo = ref.watch(superAdminRepositoryProvider);
  return SuperAdminSettingsNotifier(repo);
});

// ── Super Admin Analytics ──

class SuperAdminAnalyticsState {
  final Map<String, dynamic> revenue;
  final List<Map<String, dynamic>> bookingSources;
  final List<Map<String, dynamic>> resortRevenueTable;
  SuperAdminAnalyticsState({
    required this.revenue,
    required this.bookingSources,
    required this.resortRevenueTable,
  });
}

class SuperAdminAnalyticsNotifier extends StateNotifier<AsyncValue<SuperAdminAnalyticsState>> {
  String? lastError;
  final ISuperAdminRepository _repository;
  SuperAdminAnalyticsNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadAnalytics();
  }

  Future<void> loadAnalytics() async {
    lastError = null;
    try {
      final results = await Future.wait([
        _repository.fetchAnalyticsRevenue(),
        _repository.fetchBookingSources(),
        _repository.fetchResortRevenueTable(),
      ]);
      state = AsyncValue.data(SuperAdminAnalyticsState(
        revenue: results[0] as Map<String, dynamic>,
        bookingSources: results[1] as List<Map<String, dynamic>>,
        resortRevenueTable: results[2] as List<Map<String, dynamic>>,
      ));
    } catch (e, stack) {
      lastError = 'Failed to load analytics';
      state = AsyncValue.error(e, stack);
    }
  }
}

final superAdminAnalyticsProvider =
    StateNotifierProvider<SuperAdminAnalyticsNotifier, AsyncValue<SuperAdminAnalyticsState>>((ref) {
  final repo = ref.watch(superAdminRepositoryProvider);
  return SuperAdminAnalyticsNotifier(repo);
});

// ── Super Admin Schema ──

final superAdminSchemaProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repo = ref.watch(superAdminRepositoryProvider);
  final schema = await repo.fetchSchema();
  final tables = schema['tables'] as List<dynamic>? ?? [];
  return tables.cast<Map<String, dynamic>>();
});

// ── Super Admin Audit Logs ──

class SuperAdminAuditLogsNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  final ISuperAdminRepository _repository;
  String? lastError;
  SuperAdminAuditLogsNotifier(this._repository) : super([]) {
    loadAuditLogs();
  }

  Future<void> loadAuditLogs({String? userId, String? action, String? from, String? to, int? page, int? pageSize}) async {
    lastError = null;
    try {
      state = await _repository.fetchAuditLogs(userId: userId, action: action, from: from, to: to, page: page, pageSize: pageSize);
    } catch (e) {
      lastError = 'Failed to load audit logs';
      debugPrint('SuperAdminAuditLogsNotifier.loadAuditLogs error: $e');
      state = [];
    }
  }
}

final superAdminAuditLogsProvider =
    StateNotifierProvider<SuperAdminAuditLogsNotifier, List<Map<String, dynamic>>>((ref) {
  final repo = ref.watch(superAdminRepositoryProvider);
  return SuperAdminAuditLogsNotifier(repo);
});

// ── Role-Specific Repository Providers ──

final customerRepositoryProvider = Provider<ICustomerRepository>((ref) {
  return HttpCustomerRepositoryImpl();
});

final staffRepositoryProvider = Provider<IStaffRepository>((ref) {
  return HttpStaffRepositoryImpl();
});

final accountantRepositoryProvider = Provider<IAccountantRepository>((ref) {
  return HttpAccountantRepositoryImpl();
});

// ── Customer Notifiers ──

class CustomerBookingsNotifier extends StateNotifier<List<Booking>> {
  final ICustomerRepository _repository;
  CustomerBookingsNotifier(this._repository) : super([]) {
    loadBookings();
  }

  Future<void> loadBookings({String? status}) async {
    state = await _repository.fetchBookings(status: status);
  }

  Future<Map<String, dynamic>> createBooking(Map<String, dynamic> data) async {
    return await _repository.createBooking(data);
  }

  Future<Map<String, dynamic>> cancelBooking(String id, String reason) async {
    return await _repository.cancelBooking(id, reason);
  }
}

final customerBookingsProvider =
    StateNotifierProvider<CustomerBookingsNotifier, List<Booking>>((ref) {
  final repo = ref.watch(customerRepositoryProvider);
  return CustomerBookingsNotifier(repo);
});

class CustomerPropertiesNotifier extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  String? lastError;
  final ICustomerRepository _repository;
  CustomerPropertiesNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadProperties();
  }

  Future<void> loadProperties({String? search, String? propertyState, String? city, String? category}) async {
    lastError = null;
    try {
      final props = await _repository.fetchProperties(
        search: search, state: propertyState, city: city, category: category,
      );
      state = AsyncValue.data(props);
    } catch (e, stack) {
      lastError = 'Failed to load properties';
      state = AsyncValue.error(e, stack);
    }
  }
}

final customerPropertiesProvider =
    StateNotifierProvider<CustomerPropertiesNotifier, AsyncValue<List<Map<String, dynamic>>>>((ref) {
  final repo = ref.watch(customerRepositoryProvider);
  return CustomerPropertiesNotifier(repo);
});

class CustomerCouponsNotifier extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  String? lastError;
  final ICustomerRepository _repository;
  CustomerCouponsNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadCoupons();
  }

  Future<void> loadCoupons() async {
    lastError = null;
    try {
      final coupons = await _repository.fetchAvailableCoupons();
      state = AsyncValue.data(coupons);
    } catch (e, stack) {
      lastError = 'Failed to load coupons';
      state = AsyncValue.error(e, stack);
    }
  }
}

final customerCouponsProvider =
    StateNotifierProvider<CustomerCouponsNotifier, AsyncValue<List<Map<String, dynamic>>>>((ref) {
  final repo = ref.watch(customerRepositoryProvider);
  return CustomerCouponsNotifier(repo);
});

class CustomerFavoritesNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  final ICustomerRepository _repository;
  String? lastError;
  CustomerFavoritesNotifier(this._repository) : super([]) {
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    lastError = null;
    try {
      state = await _repository.fetchFavorites();
    } catch (e) {
      lastError = 'Failed to load favorites';
      debugPrint('CustomerFavoritesNotifier.loadFavorites error: $e');
      state = [];
    }
  }

  Future<void> toggle(String propertyId) async {
    final existing = state.where((f) => f['id'] == propertyId || f['propertyId'] == propertyId).toList();
    if (existing.isNotEmpty) {
      await _repository.removeFavorite(propertyId);
      state = state.where((f) => f['id'] != propertyId && f['propertyId'] != propertyId).toList();
    } else {
      await _repository.addFavorite(propertyId);
      await loadFavorites();
    }
  }

  bool isFavorite(String propertyId) {
    return state.any((f) => f['id'] == propertyId || f['propertyId'] == propertyId);
  }
}

final customerFavoritesProvider =
    StateNotifierProvider<CustomerFavoritesNotifier, List<Map<String, dynamic>>>((ref) {
  final repo = ref.watch(customerRepositoryProvider);
  return CustomerFavoritesNotifier(repo);
});

class CustomerProfileNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  String? lastError;
  final ICustomerRepository _repository;
  CustomerProfileNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadProfile();
  }

  void setProfile(Map<String, dynamic> data) {
    state = AsyncValue.data(data);
  }

  Future<void> loadProfile() async {
    lastError = null;
    try {
      state = AsyncValue.data(await _repository.fetchProfile());
    } catch (e, stack) {
      lastError = 'Failed to load profile';
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    lastError = null;
    try {
      final updated = await _repository.updateProfile(data);
      state = AsyncValue.data(updated);
    } catch (e, stack) {
      lastError = 'Failed to update profile';
      state = AsyncValue.error(e, stack);
    }
  }
}

final customerProfileProvider =
    StateNotifierProvider<CustomerProfileNotifier, AsyncValue<Map<String, dynamic>>>((ref) {
  final repo = ref.watch(customerRepositoryProvider);
  return CustomerProfileNotifier(repo);
});

class CustomerPricingNotifier extends StateNotifier<Map<String, dynamic>> {
  final ICustomerRepository _repository;
  String? lastError;
  CustomerPricingNotifier(this._repository) : super({'taxRate': 18, 'depositRate': 30}) {
    loadPricing();
  }

  Future<void> loadPricing() async {
    lastError = null;
    try {
      final tax = await _repository.fetchTaxRate();
      final deposit = await _repository.fetchDepositRate();
      state = {
        'taxRate': tax['data']?['taxRate'] ?? tax['taxRate'] ?? 18,
        'depositRate': deposit['data']?['depositRate'] ?? deposit['depositRate'] ?? 30,
      };
    } catch (e) {
      lastError = 'Failed to load pricing';
      debugPrint('CustomerPricingNotifier.loadPricing error: $e');
    }
  }
}

final customerPricingProvider =
    StateNotifierProvider<CustomerPricingNotifier, Map<String, dynamic>>((ref) {
  final repo = ref.watch(customerRepositoryProvider);
  return CustomerPricingNotifier(repo);
});

// ── Customer Stats ──

class CustomerStatsNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  String? lastError;
  final ICustomerRepository _repository;
  CustomerStatsNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadStats();
  }

  Future<void> loadStats() async {
    lastError = null;
    try {
      state = AsyncValue.data(await _repository.fetchStats());
    } catch (e, stack) {
      lastError = 'Failed to load stats';
      state = AsyncValue.error(e, stack);
    }
  }
}

final customerStatsProvider =
    StateNotifierProvider<CustomerStatsNotifier, AsyncValue<Map<String, dynamic>>>((ref) {
  final repo = ref.watch(customerRepositoryProvider);
  return CustomerStatsNotifier(repo);
});

// ── Customer Notifications ──

class CustomerNotificationsNotifier extends StateNotifier<List<AppNotification>> {
  final ICustomerRepository _repository;
  String? lastError;
  CustomerNotificationsNotifier(this._repository) : super([]) {
    load();
  }

  Future<void> load() async {
    lastError = null;
    try {
      state = await _repository.fetchNotifications();
    } catch (e) {
      lastError = 'Failed to load notifications';
      debugPrint('CustomerNotificationsNotifier.load error: $e');
      state = [];
    }
  }

  Future<void> markAsRead(String id) async {
    await _repository.markNotificationAsRead(id);
    state = [
      for (final n in state)
        if (n.id == id) n.copyWith(read: true) else n,
    ];
  }

  int get unreadCount => state.where((n) => !n.read).length;
}

final customerNotificationsProvider =
    StateNotifierProvider<CustomerNotificationsNotifier, List<AppNotification>>((ref) {
  final repo = ref.watch(customerRepositoryProvider);
  return CustomerNotificationsNotifier(repo);
});

// ── Customer Invoices ──

class CustomerInvoicesNotifier extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  String? lastError;
  final ICustomerRepository _repository;
  CustomerInvoicesNotifier(this._repository) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    lastError = null;
    try {
      state = AsyncValue.data(await _repository.fetchInvoices());
    } catch (e, stack) {
      lastError = 'Failed to load invoices';
      state = AsyncValue.error(e, stack);
    }
  }
}

final customerInvoicesProvider =
    StateNotifierProvider<CustomerInvoicesNotifier, AsyncValue<List<Map<String, dynamic>>>>((ref) {
  final repo = ref.watch(customerRepositoryProvider);
  return CustomerInvoicesNotifier(repo);
});

// ── Customer Concierge ──

class CustomerConciergeNotifier extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  String? lastError;
  final ICustomerRepository _repository;
  CustomerConciergeNotifier(this._repository) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    lastError = null;
    try {
      state = AsyncValue.data(await _repository.fetchConciergeRequests());
    } catch (e, stack) {
      lastError = 'Failed to load concierge requests';
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> createRequest(String type, String description) async {
    await _repository.sendConciergeMessage(description, type);
    await load();
  }
}

final customerConciergeProvider =
    StateNotifierProvider<CustomerConciergeNotifier, AsyncValue<List<Map<String, dynamic>>>>((ref) {
  final repo = ref.watch(customerRepositoryProvider);
  return CustomerConciergeNotifier(repo);
});

// ── Staff Notifiers ──

class StaffRosterNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  String? lastError;
  final IStaffRepository _repository;
  StaffRosterNotifier(this._repository) : super(const AsyncValue.loading());

  Future<void> loadRoster(String propertyId, String date) async {
    lastError = null;
    try {
      state = AsyncValue.data(await _repository.fetchRoster(propertyId, date));
    } catch (e, stack) {
      lastError = 'Failed to load roster';
      state = AsyncValue.error(e, stack);
    }
  }
}

final staffRosterProvider =
    StateNotifierProvider<StaffRosterNotifier, AsyncValue<Map<String, dynamic>>>((ref) {
  final repo = ref.watch(staffRepositoryProvider);
  return StaffRosterNotifier(repo);
});

class StaffRoomsNotifier extends StateNotifier<AsyncValue<List<RoomStatus>>> {
  String? lastError;
  final IStaffRepository _repository;
  StaffRoomsNotifier(this._repository) : super(const AsyncValue.loading());

  Future<void> loadRooms(String propertyId) async {
    lastError = null;
    try {
      state = AsyncValue.data(await _repository.fetchHousekeepingRooms(propertyId));
    } catch (e, stack) {
      lastError = 'Failed to load rooms';
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateStatus(String roomId, String status, {String? assignedStaff, String? notes}) async {
    await _repository.updateHousekeepingStatus(roomId, status, assignedStaff: assignedStaff, notes: notes);
    final current = state.valueOrNull;
    if (current != null) {
      final updated = current.map((r) {
        if (r.id == roomId) {
          return r.copyWith(
            status: HousekeepingStatus.values.firstWhere(
              (e) => e.name.toLowerCase() == status.toLowerCase(),
              orElse: () => HousekeepingStatus.clean,
            ),
            assignedStaff: assignedStaff ?? r.assignedStaff,
            notes: notes ?? r.notes,
            lastUpdated: DateTime.now().toIso8601String(),
          );
        }
        return r;
      }).toList();
      state = AsyncValue.data(updated);
    }
  }
}

final staffRoomsProvider =
    StateNotifierProvider<StaffRoomsNotifier, AsyncValue<List<RoomStatus>>>((ref) {
  final repo = ref.watch(staffRepositoryProvider);
  return StaffRoomsNotifier(repo);
});

// ── Accountant Notifiers ──

class AccountantInvoicesNotifier extends StateNotifier<AsyncValue<List<Booking>>> {
  String? lastError;
  final IAccountantRepository _repository;
  AccountantInvoicesNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadInvoices();
  }

  Future<void> loadInvoices({String? propertyId, String? paymentStatus, String? search}) async {
    lastError = null;
    try {
      state = AsyncValue.data(await _repository.fetchInvoices(
        propertyId: propertyId, paymentStatus: paymentStatus, search: search,
      ));
    } catch (e, stack) {
      lastError = 'Failed to load invoices';
      state = AsyncValue.error(e, stack);
    }
  }
}

final accountantInvoicesProvider =
    StateNotifierProvider<AccountantInvoicesNotifier, AsyncValue<List<Booking>>>((ref) {
  final repo = ref.watch(accountantRepositoryProvider);
  return AccountantInvoicesNotifier(repo);
});

class AccountantRefundsNotifier extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  String? lastError;
  final IAccountantRepository _repository;
  AccountantRefundsNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadRefunds('');
  }

  Future<void> loadRefunds(String propertyId) async {
    lastError = null;
    try {
      state = AsyncValue.data(await _repository.fetchRefunds(propertyId));
    } catch (e, stack) {
      lastError = 'Failed to load refunds';
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> processRefund(String id) async {
    await _repository.processRefund(id);
    final current = state.valueOrNull;
    if (current != null) {
      state = AsyncValue.data(current.where((r) => r['id'] != id).toList());
    }
  }
}

final accountantRefundsProvider =
    StateNotifierProvider<AccountantRefundsNotifier, AsyncValue<List<Map<String, dynamic>>>>((ref) {
  final repo = ref.watch(accountantRepositoryProvider);
  return AccountantRefundsNotifier(repo);
});

class AccountantKpisNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  String? lastError;
  final IAccountantRepository _repository;
  AccountantKpisNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadKpis('');
  }

  Future<void> loadKpis(String propertyId) async {
    lastError = null;
    try {
      state = AsyncValue.data(await _repository.fetchDashboardKpis(propertyId));
    } catch (e, stack) {
      lastError = 'Failed to load KPIs';
      state = AsyncValue.error(e, stack);
    }
  }
}

final accountantKpisProvider =
    StateNotifierProvider<AccountantKpisNotifier, AsyncValue<Map<String, dynamic>>>((ref) {
  final repo = ref.watch(accountantRepositoryProvider);
  return AccountantKpisNotifier(repo);
});

// ── Admin Dashboard ──

class AdminDashboardState {
  final Map<String, dynamic> raw;
  final int totalBookings;
  final int activeBookings;
  final int pendingCheckIns;
  final int pendingCheckOuts;
  final int todayCheckouts;
  final double revenueToday;
  final double revenueThisMonth;
  final double occupancyRate;
  final double averageRating;
  final int reviewsCount;
  final List<Map<String, dynamic>> upcomingEvents;
  final List<Map<String, dynamic>> recentActivity;

  AdminDashboardState._({
    required this.raw,
    required this.totalBookings,
    required this.activeBookings,
    required this.pendingCheckIns,
    required this.pendingCheckOuts,
    required this.todayCheckouts,
    required this.revenueToday,
    required this.revenueThisMonth,
    required this.occupancyRate,
    required this.averageRating,
    required this.reviewsCount,
    required this.upcomingEvents,
    required this.recentActivity,
  });

  factory AdminDashboardState.fromJson(Map<String, dynamic> json) {
    return AdminDashboardState._(
      raw: json,
      totalBookings: json['totalBookings'] as int? ?? 0,
      activeBookings: json['activeBookings'] as int? ?? 0,
      pendingCheckIns: json['pendingCheckIns'] as int? ?? 0,
      pendingCheckOuts: json['pendingCheckOuts'] as int? ?? 0,
      todayCheckouts: json['todayCheckouts'] as int? ?? 0,
      revenueToday: (json['revenueToday'] as num?)?.toDouble() ?? 0,
      revenueThisMonth: (json['revenueThisMonth'] as num?)?.toDouble() ?? 0,
      occupancyRate: (json['occupancyRate'] as num?)?.toDouble() ?? 0,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0,
      reviewsCount: json['reviewsCount'] as int? ?? 0,
      upcomingEvents: (json['upcomingEvents'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [],
      recentActivity: (json['recentActivity'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [],
    );
  }
}

class AdminDashboardNotifier extends StateNotifier<AsyncValue<AdminDashboardState>> {
  String? lastError;
  final IResortRepository _repository;
  AdminDashboardNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    lastError = null;
    try {
      final data = await _repository.fetchAnalyticsKpis();
      state = AsyncValue.data(AdminDashboardState.fromJson(data));
    } catch (e, stack) {
      lastError = 'Failed to load dashboard';
      state = AsyncValue.error(e, stack);
    }
  }
}

final adminDashboardProvider =
    StateNotifierProvider<AdminDashboardNotifier, AsyncValue<AdminDashboardState>>((ref) {
  final repo = ref.watch(resortRepositoryProvider);
  return AdminDashboardNotifier(repo);
});
