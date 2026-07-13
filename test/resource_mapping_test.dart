import 'package:flutter_test/flutter_test.dart';
import 'package:vsp_resorts_portal/domain/entities.dart';

/// Mirrors the mapping tables in http_super_admin_repository_impl.dart
const Map<String, String> _resourceToBackend = {
  'bookings': 'booking',
  'calendar': 'calendar',
  'coupons': 'coupon',
  'pricing': 'pricing',
  'rooms': 'rooms',
  'ota': 'ota',
  'notifications': 'notification',
  'properties': 'property',
  'users': 'user',
  'roles': 'role',
  'approvals': 'approval',
  'reports': 'analytics',
};

const Map<String, String> _backendToResource = {
  'booking': 'bookings',
  'calendar': 'calendar',
  'coupon': 'coupons',
  'pricing': 'pricing',
  'rooms': 'rooms',
  'ota': 'ota',
  'notification': 'notifications',
  'property': 'properties',
  'user': 'users',
  'role': 'roles',
  'approval': 'approvals',
  'analytics': 'reports',
};

String backendId(UserRole role) {
  switch (role) {
    case UserRole.superAdmin:
      return 'SUPER_ADMIN';
    case UserRole.admin:
      return 'ADMIN';
    case UserRole.staff:
      return 'STAFF';
    case UserRole.accountant:
      return 'ACCOUNTANT';
    case UserRole.customer:
      return 'CUSTOMER';
  }
}

void main() {
  group('Resource name mapping', () {
    test('every PermissionResource has a backend mapping', () {
      for (final resource in PermissionResource.values) {
        expect(_resourceToBackend.containsKey(resource.name), isTrue,
            reason: '${resource.name} is missing from _resourceToBackend');
      }
    });

    test('mapping is bidirectional', () {
      for (final entry in _resourceToBackend.entries) {
        expect(_backendToResource[entry.value], equals(entry.key),
            reason: '${entry.key} -> ${entry.value} -> ? is not bidirectional');
      }
    });

    test('backend mapping is surjective (all backend names have frontend names)', () {
      for (final entry in _backendToResource.entries) {
        expect(_resourceToBackend[entry.value], equals(entry.key),
            reason: '${entry.key} <- ${entry.value} reverse lookup failed');
      }
    });

    test('all backend names map to valid PermissionResource values', () {
      for (final frontendName in _backendToResource.values) {
        expect(PermissionResource.values.any((e) => e.name == frontendName), isTrue,
            reason: '$frontendName is not a valid PermissionResource');
      }
    });
  });

  group('Backend role ID mapping', () {
    test('maps UserRole.superAdmin to SUPER_ADMIN', () {
      expect(backendId(UserRole.superAdmin), equals('SUPER_ADMIN'));
    });

    test('maps UserRole.admin to ADMIN', () {
      expect(backendId(UserRole.admin), equals('ADMIN'));
    });

    test('maps UserRole.staff to STAFF', () {
      expect(backendId(UserRole.staff), equals('STAFF'));
    });

    test('maps UserRole.accountant to ACCOUNTANT', () {
      expect(backendId(UserRole.accountant), equals('ACCOUNTANT'));
    });

    test('maps UserRole.customer to CUSTOMER', () {
      expect(backendId(UserRole.customer), equals('CUSTOMER'));
    });

    test('all UserRole values map to a non-empty string', () {
      for (final role in UserRole.values) {
        expect(backendId(role).isNotEmpty, isTrue,
            reason: '${role.name} maps to empty string');
      }
    });
  });
}
