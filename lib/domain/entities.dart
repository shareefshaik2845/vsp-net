enum UserRole {
  customer,
  admin,
  staff,
  accountant,
  superAdmin,
}

enum UserStatus { active, inactive, suspended }

enum CalendarDayStatus {
  available,
  booked,
  blocked,
  pending,
  ota,
}

enum BookingStatus {
  confirmed,
  pendingPayment,
  cancelled,
  checkedIn,
  checkedOut;

  String toJson() => name;
  static BookingStatus fromJson(String name) => BookingStatus.values
      .firstWhere((e) => e.name == name, orElse: () => BookingStatus.confirmed);
}

enum PaymentStatus {
  paid,
  partiallyPaid,
  pending,
  refunded;

  String toJson() => name;
  static PaymentStatus fromJson(String name) => PaymentStatus.values
      .firstWhere((e) => e.name == name, orElse: () => PaymentStatus.pending);
}

enum BookingSource {
  direct,
  airbnb,
  bookingCom,
  agoda,
  makemytrip,
  goibibo;

  String toJson() => name;
  static BookingSource fromJson(String name) => BookingSource.values
      .firstWhere((e) => e.name == name, orElse: () => BookingSource.direct);
}

class PropertyDetails {
  final String id;
  final String name;
  final String tagline;
  final String description;
  final String location;
  final double basePriceWeekday;
  final double basePriceWeekend;
  final double extraGuestCharge;
  final double cleaningFee;
  final List<Amenity> amenities;
  final List<String> rules;
  final String state;
  final String city;
  final String image;
  final List<String> gallery;

  const PropertyDetails({
    this.id = '',
    required this.name,
    required this.tagline,
    required this.description,
    required this.location,
    required this.basePriceWeekday,
    required this.basePriceWeekend,
    required this.extraGuestCharge,
    required this.cleaningFee,
    required this.amenities,
    required this.rules,
    required this.state,
    required this.city,
    required this.image,
    required this.gallery,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PropertyDetails &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  PropertyDetails copyWith({
    String? id,
    String? name,
    String? tagline,
    String? description,
    String? location,
    double? basePriceWeekday,
    double? basePriceWeekend,
    double? extraGuestCharge,
    double? cleaningFee,
    List<Amenity>? amenities,
    List<String>? rules,
    String? state,
    String? city,
    String? image,
    List<String>? gallery,
  }) {
    return PropertyDetails(
      id: id ?? this.id,
      name: name ?? this.name,
      tagline: tagline ?? this.tagline,
      description: description ?? this.description,
      location: location ?? this.location,
      basePriceWeekday: basePriceWeekday ?? this.basePriceWeekday,
      basePriceWeekend: basePriceWeekend ?? this.basePriceWeekend,
      extraGuestCharge: extraGuestCharge ?? this.extraGuestCharge,
      cleaningFee: cleaningFee ?? this.cleaningFee,
      amenities: amenities ?? this.amenities,
      rules: rules ?? this.rules,
      state: state ?? this.state,
      city: city ?? this.city,
      image: image ?? this.image,
      gallery: gallery ?? this.gallery,
    );
  }
}

class Amenity {
  final String icon;
  final String label;
  final String category;

  const Amenity({
    required this.icon,
    required this.label,
    required this.category,
  });
}

class CalendarBlock {
  final String id;
  final String startDate; // YYYY-MM-DD
  final String endDate; // YYYY-MM-DD
  final String reason; // maintenance, owner_stay, private_event, holiday
  final String? notes;
  final String blockedBy;
  final String? propertyId;

  const CalendarBlock({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.reason,
    this.notes,
    required this.blockedBy,
    this.propertyId,
  });
}

class Coupon {
  final String id;
  final String code;
  final String type; // percentage, fixed
  final double value;
  final String expiryDate; // YYYY-MM-DD
  final int usageLimit;
  final int usageCount;
  final double minBookingValue;
  final String description;
  final bool isActive;

  const Coupon({
    required this.id,
    required this.code,
    required this.type,
    required this.value,
    required this.expiryDate,
    required this.usageLimit,
    required this.usageCount,
    required this.minBookingValue,
    required this.description,
    required this.isActive,
  });

  Coupon copyWith({
    String? id,
    String? code,
    String? type,
    double? value,
    String? expiryDate,
    int? usageLimit,
    int? usageCount,
    double? minBookingValue,
    String? description,
    bool? isActive,
  }) {
    return Coupon(
      id: id ?? this.id,
      code: code ?? this.code,
      type: type ?? this.type,
      value: value ?? this.value,
      expiryDate: expiryDate ?? this.expiryDate,
      usageLimit: usageLimit ?? this.usageLimit,
      usageCount: usageCount ?? this.usageCount,
      minBookingValue: minBookingValue ?? this.minBookingValue,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
    );
  }
}

class Booking {
  final String id;
  final String resortName;
  final String guestName;
  final String guestEmail;
  final String guestPhone;
  final String startDate; // YYYY-MM-DD
  final String endDate; // YYYY-MM-DD
  final int guestsCount;
  final int nightsCount;
  final BookingSource source;
  final BookingStatus status;
  final PaymentStatus paymentStatus;
  final double baseAmount;
  final double extraGuestAmount;
  final double cleaningAmount;
  final double discountAmount;
  final double taxAmount;
  final double totalAmount;
  final double advancePaidAmount;
  final double balanceAmount;
  final String? couponApplied;
  final String createdAt;
  final String? housekeepingNotes;
  final String? cancellationReason;
  final double? refundAmount;
  final String? propertyId;

  const Booking({
    required this.id,
    required this.resortName,
    required this.guestName,
    required this.guestEmail,
    required this.guestPhone,
    required this.startDate,
    required this.endDate,
    required this.guestsCount,
    required this.nightsCount,
    required this.source,
    required this.status,
    required this.paymentStatus,
    required this.baseAmount,
    required this.extraGuestAmount,
    required this.cleaningAmount,
    required this.discountAmount,
    required this.taxAmount,
    required this.totalAmount,
    required this.advancePaidAmount,
    required this.balanceAmount,
    this.couponApplied,
    required this.createdAt,
    this.housekeepingNotes,
    this.cancellationReason,
    this.refundAmount,
    this.propertyId,
  });

  Booking copyWith({
    String? id,
    String? resortName,
    String? guestName,
    String? guestEmail,
    String? guestPhone,
    String? startDate,
    String? endDate,
    int? guestsCount,
    int? nightsCount,
    BookingSource? source,
    BookingStatus? status,
    PaymentStatus? paymentStatus,
    double? baseAmount,
    double? extraGuestAmount,
    double? cleaningAmount,
    double? discountAmount,
    double? taxAmount,
    double? totalAmount,
    double? advancePaidAmount,
    double? balanceAmount,
    String? couponApplied,
    String? createdAt,
    String? housekeepingNotes,
    String? cancellationReason,
    double? refundAmount,
    String? propertyId,
  }) {
    return Booking(
      id: id ?? this.id,
      resortName: resortName ?? this.resortName,
      guestName: guestName ?? this.guestName,
      guestEmail: guestEmail ?? this.guestEmail,
      guestPhone: guestPhone ?? this.guestPhone,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      guestsCount: guestsCount ?? this.guestsCount,
      nightsCount: nightsCount ?? this.nightsCount,
      source: source ?? this.source,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      baseAmount: baseAmount ?? this.baseAmount,
      extraGuestAmount: extraGuestAmount ?? this.extraGuestAmount,
      cleaningAmount: cleaningAmount ?? this.cleaningAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      taxAmount: taxAmount ?? this.taxAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      advancePaidAmount: advancePaidAmount ?? this.advancePaidAmount,
      balanceAmount: balanceAmount ?? this.balanceAmount,
      couponApplied: couponApplied ?? this.couponApplied,
      createdAt: createdAt ?? this.createdAt,
      housekeepingNotes: housekeepingNotes ?? this.housekeepingNotes,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      refundAmount: refundAmount ?? this.refundAmount,
      propertyId: propertyId ?? this.propertyId,
    );
  }
}

class ReviewComment {
  final String name;
  final String date;
  final String content;
  final int rating;

  const ReviewComment({
    required this.name,
    required this.date,
    required this.content,
    required this.rating,
  });
}

class ReviewSummary {
  final double averageRating;
  final int totalReviews;
  final List<RatingBreakdown> ratingBreakdown;
  final List<ReviewComment> comments;

  const ReviewSummary({
    required this.averageRating,
    required this.totalReviews,
    required this.ratingBreakdown,
    required this.comments,
  });
}

class RatingBreakdown {
  final int stars;
  final int count;

  const RatingBreakdown({
    required this.stars,
    required this.count,
  });
}

enum HousekeepingStatus {
  clean,
  cleaning,
  dirty;

  String toJson() => name;
  static HousekeepingStatus fromJson(String name) =>
      HousekeepingStatus.values.firstWhere((e) => e.name == name,
          orElse: () => HousekeepingStatus.clean);
}

class RoomStatus {
  final String id;
  final String name;
  final HousekeepingStatus status;
  final String? assignedStaff;
  final String? notes;
  final String lastUpdated;

  const RoomStatus({
    required this.id,
    required this.name,
    required this.status,
    this.assignedStaff,
    this.notes,
    required this.lastUpdated,
  });

  RoomStatus copyWith({
    String? id,
    String? name,
    HousekeepingStatus? status,
    String? assignedStaff,
    String? notes,
    String? lastUpdated,
  }) {
    return RoomStatus(
      id: id ?? this.id,
      name: name ?? this.name,
      status: status ?? this.status,
      assignedStaff: assignedStaff ?? this.assignedStaff,
      notes: notes ?? this.notes,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class PricingSeasonRule {
  final String id;
  final String name;
  final String startDate; // MM-DD
  final String endDate; // MM-DD
  final double weekdayPrice;
  final double weekendPrice;
  final double multiplier;
  final bool isActive;
  final String? propertyId;

  const PricingSeasonRule({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.weekdayPrice,
    required this.weekendPrice,
    required this.multiplier,
    required this.isActive,
    this.propertyId,
  });

  PricingSeasonRule copyWith({
    String? id,
    String? name,
    String? startDate,
    String? endDate,
    double? weekdayPrice,
    double? weekendPrice,
    double? multiplier,
    bool? isActive,
    String? propertyId,
  }) {
    return PricingSeasonRule(
      id: id ?? this.id,
      name: name ?? this.name,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      weekdayPrice: weekdayPrice ?? this.weekdayPrice,
      weekendPrice: weekendPrice ?? this.weekendPrice,
      multiplier: multiplier ?? this.multiplier,
      isActive: isActive ?? this.isActive,
      propertyId: propertyId ?? this.propertyId,
    );
  }
}

class OtaSyncStatus {
  final String id;
  final String channelName;
  final String logo;
  final String lastSyncTime;
  final String status; // synchronizing, success, conflict, error
  final int conflictsCount;
  final bool syncEnabled;

  const OtaSyncStatus({
    required this.id,
    required this.channelName,
    required this.logo,
    required this.lastSyncTime,
    required this.status,
    required this.conflictsCount,
    required this.syncEnabled,
  });

  OtaSyncStatus copyWith({
    String? id,
    String? channelName,
    String? logo,
    String? lastSyncTime,
    String? status,
    int? conflictsCount,
    bool? syncEnabled,
  }) {
    return OtaSyncStatus(
      id: id ?? this.id,
      channelName: channelName ?? this.channelName,
      logo: logo ?? this.logo,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      status: status ?? this.status,
      conflictsCount: conflictsCount ?? this.conflictsCount,
      syncEnabled: syncEnabled ?? this.syncEnabled,
    );
  }
}

class AppNotification {
  final String id;
  final String title;
  final String message;
  final String timestamp;
  final String type; // booking, payment, staff, ota, system
  final bool read;

  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.type,
    required this.read,
  });

  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    String? timestamp,
    String? type,
    bool? read,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      read: read ?? this.read,
    );
  }
}

// ── User Account (for installation/login flow) ──

class UserAccount {
  final String id;
  final String name;
  final String email;
  final String passwordHash;
  final String? passwordSalt;
  final UserRole role;
  final UserStatus status;
  final String createdAt;
  final String? createdBy;
  final String? updatedAt;
  final String? updatedBy;
  final String? lastLoginAt;

  const UserAccount({
    required this.id,
    required this.name,
    required this.email,
    required this.passwordHash,
    this.passwordSalt,
    required this.role,
    this.status = UserStatus.active,
    required this.createdAt,
    this.createdBy,
    this.updatedAt,
    this.updatedBy,
    this.lastLoginAt,
  });

  UserAccount copyWith({
    String? id,
    String? name,
    String? email,
    String? passwordHash,
    String? passwordSalt,
    UserRole? role,
    UserStatus? status,
    String? createdAt,
    String? createdBy,
    String? updatedAt,
    String? updatedBy,
    String? lastLoginAt,
  }) {
    return UserAccount(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      passwordSalt: passwordSalt ?? this.passwordSalt,
      role: role ?? this.role,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}

// ── Installation Record (one-time setup) ──

class InstallationRecord {
  final bool isComplete;
  final String? superAdminId;
  final String setupToken;
  final String? completedAt;
  final String? recoveryEmail;
  final String? recoveryCodeHash;

  const InstallationRecord({
    required this.isComplete,
    this.superAdminId,
    required this.setupToken,
    this.completedAt,
    this.recoveryEmail,
    this.recoveryCodeHash,
  });

  InstallationRecord copyWith({
    bool? isComplete,
    String? superAdminId,
    String? setupToken,
    String? completedAt,
    String? recoveryEmail,
    String? recoveryCodeHash,
  }) {
    return InstallationRecord(
      isComplete: isComplete ?? this.isComplete,
      superAdminId: superAdminId ?? this.superAdminId,
      setupToken: setupToken ?? this.setupToken,
      completedAt: completedAt ?? this.completedAt,
      recoveryEmail: recoveryEmail ?? this.recoveryEmail,
      recoveryCodeHash: recoveryCodeHash ?? this.recoveryCodeHash,
    );
  }
}

// ── Audit Log Entry ──

class AuditLogEntry {
  final String id;
  final String userId;
  final String action; // create, update, delete, login, etc.
  final String? targetType; // 'user', 'booking', 'role', etc.
  final String? targetId;
  final String? details;
  final String timestamp;

  const AuditLogEntry({
    required this.id,
    required this.userId,
    required this.action,
    this.targetType,
    this.targetId,
    this.details,
    required this.timestamp,
  });
}

// ── RBAC / Permissions ──

enum PermissionAction { create, read, update, delete, approve }

enum PermissionResource {
  bookings,
  calendar,
  coupons,
  pricing,
  rooms,
  ota,
  notifications,
  properties,
  users,
  roles,
  approvals,
  reports,
}

enum ApprovalStatus { pending, approved, rejected }

class ApprovalRequest {
  final String id;
  final String resourceType;
  final String resourceId;
  final String action;
  final Map<String, dynamic> payload;
  final String requestedBy;
  final String? approvedBy;
  final ApprovalStatus status;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final String? rejectionReason;

  const ApprovalRequest({
    required this.id,
    required this.resourceType,
    required this.resourceId,
    required this.action,
    required this.payload,
    required this.requestedBy,
    this.approvedBy,
    required this.status,
    required this.createdAt,
    this.resolvedAt,
    this.rejectionReason,
  });

  ApprovalRequest copyWith({
    String? id,
    String? resourceType,
    String? resourceId,
    String? action,
    Map<String, dynamic>? payload,
    String? requestedBy,
    String? approvedBy,
    ApprovalStatus? status,
    DateTime? createdAt,
    DateTime? resolvedAt,
    String? rejectionReason,
  }) {
    return ApprovalRequest(
      id: id ?? this.id,
      resourceType: resourceType ?? this.resourceType,
      resourceId: resourceId ?? this.resourceId,
      action: action ?? this.action,
      payload: payload ?? this.payload,
      requestedBy: requestedBy ?? this.requestedBy,
      approvedBy: approvedBy ?? this.approvedBy,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }
}

class RolePermission {
  final PermissionResource resource;
  final List<PermissionAction> actions;

  const RolePermission({
    required this.resource,
    required this.actions,
  });
}

class RoleDefinition {
  final String id;
  final String displayName;
  final String description;
  final List<RolePermission> permissions;

  const RoleDefinition({
    required this.id,
    required this.displayName,
    required this.description,
    required this.permissions,
  });
}
