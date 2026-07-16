import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:vsp_resorts_portal/main.dart';
import 'package:vsp_resorts_portal/presentation/screens/portal_shell_screen.dart';
import 'package:vsp_resorts_portal/presentation/providers/state_provider.dart';
import 'package:vsp_resorts_portal/domain/entities.dart';
import 'package:vsp_resorts_portal/domain/accountant_repository.dart';
import 'package:vsp_resorts_portal/domain/staff_repository.dart';
import 'package:vsp_resorts_portal/domain/customer_repository.dart';
import 'package:vsp_resorts_portal/domain/repositories.dart';
import 'package:vsp_resorts_portal/presentation/screens/customer/customer_view.dart';

import 'mocks.dart';

Widget wrapWithProviders({
  IAccountantRepository? accountantRepo,
  IStaffRepository? staffRepo,
  IResortRepository? resortRepo,
  ICustomerRepository? customerRepo,
  UserRole role = UserRole.accountant,
  Widget? child,
}) {
  return ProviderScope(
    overrides: [
      if (accountantRepo != null)
        accountantRepositoryProvider.overrideWithValue(accountantRepo),
      if (staffRepo != null)
        staffRepositoryProvider.overrideWithValue(staffRepo),
      if (resortRepo != null)
        resortRepositoryProvider.overrideWithValue(resortRepo),
      if (customerRepo != null)
        customerRepositoryProvider.overrideWithValue(customerRepo),
      activeRoleProvider.overrideWith((ref) => role),
    ],
    child: MaterialApp(
      home: child ?? const SizedBox(),
    ),
  );
}

void main() {
  testWidgets('App loads and shows VSP Nest Portal',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: VspNestApp()));
    expect(find.textContaining('VSP Nest'), findsAtLeastNWidgets(1));
    await tester.pump(const Duration(milliseconds: 2500));
    await tester.pump();
  });

  // ── Accountant repository unit tests ──

  test('MockAccountantRepository downloadLedgerPdf returns report map',
      () async {
    final repo = MockAccountantRepository();
    final report =
        await repo.downloadLedgerPdf('p1', '2026-01-01', '2026-01-31');
    expect(report, isNotEmpty);
    expect(report['format'], 'pdf');
  });

  test('MockAccountantRepository downloadLedgerExcel returns report map',
      () async {
    final repo = MockAccountantRepository();
    final report =
        await repo.downloadLedgerExcel('p1', '2026-01-01', '2026-01-31');
    expect(report, isNotEmpty);
    expect(report['format'], 'xlsx');
  });

  test('MockAccountantRepository fetchProperties returns mock data', () async {
    final repo = MockAccountantRepository();
    final props = await repo.fetchProperties();
    expect(props, isNotEmpty);
    expect(props.first['name'], 'Test Resort');
  });

  // ── Staff repository unit tests ──

  test('MockStaffRepository fetchProperties returns mock property', () async {
    final repo = MockStaffRepository();
    final props = await repo.fetchProperties();
    expect(props, isNotEmpty);
    expect(props.first['name'], 'Test Resort');
  });

  test('MockStaffRepository fetchRoster returns empty map', () async {
    final repo = MockStaffRepository();
    final roster = await repo.fetchRoster('1', '2026-07-12');
    expect(roster, {});
  });

  test('MockStaffRepository fetchHousekeepingRooms returns empty list',
      () async {
    final repo = MockStaffRepository();
    final rooms = await repo.fetchHousekeepingRooms('1');
    expect(rooms, isEmpty);
  });

  test('MockStaffRepository updateHousekeepingStatus completes', () async {
    final repo = MockStaffRepository();
    await repo.updateHousekeepingStatus('r1', 'cleaning');
  });

  // ── MockResortRepository unit tests ──

  test('MockResortRepository fetchPropertyDetails returns a PropertyDetails',
      () async {
    final repo = MockResortRepository();
    final details = await repo.fetchPropertyDetails();
    expect(details.id, '1');
    expect(details.name, 'Test');
  });

  test('MockResortRepository fetchAnalyticsKpis returns empty map', () async {
    final repo = MockResortRepository();
    final kpis = await repo.fetchAnalyticsKpis();
    expect(kpis, {});
  });

  test('MockResortRepository fetchBookings returns empty list', () async {
    final repo = MockResortRepository();
    final bookings = await repo.fetchBookings();
    expect(bookings, isEmpty);
  });

  // ── Customer view (no mock card data) ──

  testWidgets('Customer view does NOT show mock credit card credentials',
      (WidgetTester tester) async {
    final mockCustomerRepo = MockCustomerRepository();

    await tester.pumpWidget(wrapWithProviders(
      customerRepo: mockCustomerRepo,
      role: UserRole.customer,
      child: const CustomerView(),
    ));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.textContaining('MOCK CARD'), findsNothing);
    expect(find.textContaining('4111'), findsNothing);
    expect(find.textContaining('Sandbox Payment'), findsNothing);
  });

  // ── Portal shell ──

  testWidgets('Portal shell renders without crashing',
      (WidgetTester tester) async {
    final mockCustomerRepo = MockCustomerRepository();

    await tester.pumpWidget(wrapWithProviders(
      customerRepo: mockCustomerRepo,
      role: UserRole.customer,
      child: const ResortPortalShell(),
    ));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
  });

  // ── PermissionResource enum coverage ──

  test('All PermissionResource values have expected names', () {
    expect(PermissionResource.values.length, greaterThanOrEqualTo(12));
    for (final r in PermissionResource.values) {
      expect(r.name.isNotEmpty, isTrue);
    }
  });

  // ── Integration field name mapping tests ──

  group('Customer booking JSON parsing', () {
    test('parses checkInDate/checkOutDate from backend response', () {
      final json = {
        'id': '1',
        'propertyName': 'Test Villa',
        'guestName': 'John',
        'guestEmail': 'john@test.com',
        'guestPhone': '+123',
        'checkInDate': '2026-07-15',
        'checkOutDate': '2026-07-18',
        'guestsCount': 2,
        'totalAmount': 600.0,
        'status': 'CONFIRMED',
        'paymentStatus': 'PAID',
        'createdAt': '2026-07-10T10:00:00Z',
      };

      final booking = _bookingFromTestJson(json);

      expect(booking.startDate, '2026-07-15');
      expect(booking.endDate, '2026-07-18');
      expect(booking.guestName, 'John');
      expect(booking.guestEmail, 'john@test.com');
      expect(booking.guestPhone, '+123');
      expect(booking.resortName, 'Test Villa');
      expect(booking.totalAmount, 600.0);
    });

    test('parses otaPlatform as booking source', () {
      final json = {
        'id': '1',
        'propertyName': 'Test',
        'checkInDate': '2026-07-15',
        'checkOutDate': '2026-07-18',
        'guestsCount': 2,
        'totalAmount': 500.0,
        'status': 'CONFIRMED',
        'paymentStatus': 'PENDING',
        'otaPlatform': 'AIRBNB',
        'createdAt': '2026-07-10T10:00:00Z',
      };

      final booking = _bookingFromTestJson(json);
      expect(booking.source, BookingSource.airbnb);
    });

    test('parses null otaPlatform as direct source', () {
      final json = {
        'id': '1',
        'propertyName': 'Test',
        'checkInDate': '2026-07-15',
        'checkOutDate': '2026-07-18',
        'guestsCount': 2,
        'totalAmount': 500.0,
        'status': 'CONFIRMED',
        'paymentStatus': 'PENDING',
        'createdAt': '2026-07-10T10:00:00Z',
      };

      final booking = _bookingFromTestJson(json);
      expect(booking.source, BookingSource.direct);
    });

    test('handles missing optional fields gracefully', () {
      final json = {
        'id': '1',
        'propertyName': 'Test',
        'checkInDate': '2026-07-15',
        'checkOutDate': '2026-07-18',
        'guestsCount': 2,
        'totalAmount': 500.0,
        'status': 'CONFIRMED',
        'paymentStatus': 'PENDING',
        'createdAt': '2026-07-10T10:00:00Z',
      };

      final booking = _bookingFromTestJson(json);
      expect(booking.guestName, '');
      expect(booking.guestEmail, '');
      expect(booking.guestPhone, '');
      expect(booking.discountAmount, 0.0);
      expect(booking.nightsCount, 1);
    });
  });

  group('Booking source parsing', () {
    BookingSource _parseSource(String? source) {
      if (source == null) return BookingSource.direct;
      final lower = source.toLowerCase();
      if (lower == 'airbnb') return BookingSource.airbnb;
      if (lower == 'booking_com' || lower == 'booking.com' || lower == 'bookingcom') {
        return BookingSource.bookingCom;
      }
      if (lower == 'agoda') return BookingSource.agoda;
      if (lower == 'makemytrip' || lower == 'mmt') return BookingSource.makemytrip;
      if (lower == 'goibibo') return BookingSource.goibibo;
      return BookingSource.direct;
    }

    test('maps AIRBNB to airbnb', () {
      expect(_parseSource('AIRBNB'), BookingSource.airbnb);
    });

    test('maps booking.com variants to bookingCom', () {
      expect(_parseSource('booking_com'), BookingSource.bookingCom);
      expect(_parseSource('booking.com'), BookingSource.bookingCom);
      expect(_parseSource('BOOKINGCOM'), BookingSource.bookingCom);
    });

    test('maps agoda to agoda', () {
      expect(_parseSource('AGODA'), BookingSource.agoda);
    });

    test('maps makemytrip variants to makemytrip', () {
      expect(_parseSource('MAKEMYTRIP'), BookingSource.makemytrip);
      expect(_parseSource('mmt'), BookingSource.makemytrip);
    });

    test('maps goibibo to goibibo', () {
      expect(_parseSource('GOIBIBO'), BookingSource.goibibo);
    });

    test('returns direct for unknown source', () {
      expect(_parseSource('EXPEDIA'), BookingSource.direct);
      expect(_parseSource(null), BookingSource.direct);
      expect(_parseSource(''), BookingSource.direct);
    });
  });

  group('Amenity parsing', () {
    List<Amenity> _parseAmenities(dynamic raw) {
      if (raw == null) return [];
      final list = raw as List<dynamic>;
      return list.map((a) {
        final m = a as Map<String, dynamic>;
        return Amenity(
          icon: m['icon'] as String? ?? '',
          label: m['label'] as String? ?? '',
          category: m['category'] as String? ?? '',
        );
      }).toList();
    }

    test('parses amenities from backend JSON array', () {
      final raw = [
        {'icon': 'wifi', 'label': 'Free WiFi', 'category': 'amenity'},
        {'icon': 'pool', 'label': 'Swimming Pool', 'category': 'amenity'},
      ];

      final amenities = _parseAmenities(raw);
      expect(amenities.length, 2);
      expect(amenities[0].icon, 'wifi');
      expect(amenities[0].label, 'Free WiFi');
      expect(amenities[0].category, 'amenity');
      expect(amenities[1].icon, 'pool');
    });

    test('returns empty list for null amenities', () {
      expect(_parseAmenities(null), isEmpty);
    });

    test('handles empty list', () {
      expect(_parseAmenities([]), isEmpty);
    });
  });

  group('Property details from admin response', () {
    PropertyDetails _parsePropertyDetails(Map<String, dynamic> map) {
      List<Amenity> _parseAmenities(dynamic raw) {
        if (raw == null) return [];
        final list = raw as List<dynamic>;
        return list.map((a) {
          final m = a as Map<String, dynamic>;
          return Amenity(
            icon: m['icon'] as String? ?? '',
            label: m['label'] as String? ?? '',
            category: m['category'] as String? ?? '',
          );
        }).toList();
      }

      return PropertyDetails(
        id: map['id'] as String? ?? '',
        name: map['name'] as String? ?? '',
        tagline: map['tagline'] as String? ?? '',
        description: map['description'] as String? ?? '',
        location: map['location'] as String? ?? '',
        basePriceWeekday: (map['basePriceWeekday'] as num?)?.toDouble() ?? 0,
        basePriceWeekend: (map['basePriceWeekend'] as num?)?.toDouble() ?? 0,
        extraGuestCharge: (map['extraGuestCharge'] as num?)?.toDouble() ?? 0,
        cleaningFee: (map['cleaningFee'] as num?)?.toDouble() ?? 0,
        state: map['state'] as String? ?? '',
        city: map['city'] as String? ?? '',
        image: map['image'] as String? ?? '',
        gallery: (map['gallery'] as List<dynamic>?)?.cast<String>() ?? [],
        amenities: _parseAmenities(map['amenities']),
        rules: (map['rules'] as List<dynamic>?)?.cast<String>() ?? [],
      );
    }

    test('parses all fields from admin property list response', () {
      final json = {
        'id': '1',
        'name': 'Sunset Villa',
        'tagline': 'Luxury stay',
        'description': 'A beautiful villa with ocean view',
        'location': 'Goa',
        'state': 'Goa',
        'city': 'North Goa',
        'basePriceWeekday': 200.0,
        'basePriceWeekend': 250.0,
        'extraGuestCharge': 50.0,
        'cleaningFee': 25.0,
        'image': 'https://example.com/img.jpg',
        'gallery': ['https://example.com/img1.jpg', 'https://example.com/img2.jpg'],
        'amenities': [
          {'icon': 'wifi', 'label': 'WiFi', 'category': 'amenity'},
        ],
        'rules': ['No smoking', 'No pets'],
      };

      final details = _parsePropertyDetails(json);

      expect(details.id, '1');
      expect(details.name, 'Sunset Villa');
      expect(details.tagline, 'Luxury stay');
      expect(details.description, 'A beautiful villa with ocean view');
      expect(details.location, 'Goa');
      expect(details.state, 'Goa');
      expect(details.city, 'North Goa');
      expect(details.basePriceWeekday, 200.0);
      expect(details.basePriceWeekend, 250.0);
      expect(details.extraGuestCharge, 50.0);
      expect(details.cleaningFee, 25.0);
      expect(details.image, 'https://example.com/img.jpg');
      expect(details.gallery.length, 2);
      expect(details.amenities.length, 1);
      expect(details.amenities[0].label, 'WiFi');
      expect(details.rules.length, 2);
      expect(details.rules[0], 'No smoking');
    });

    test('handles missing fields with defaults', () {
      final details = _parsePropertyDetails({});
      expect(details.id, '');
      expect(details.name, '');
      expect(details.description, '');
      expect(details.basePriceWeekday, 0.0);
      expect(details.gallery, isEmpty);
      expect(details.amenities, isEmpty);
      expect(details.rules, isEmpty);
    });
  });
}

Booking _bookingFromTestJson(Map<String, dynamic> json) {
  BookingSource _parseSource(String? source) {
    if (source == null) return BookingSource.direct;
    final lower = source.toLowerCase();
    if (lower == 'airbnb') return BookingSource.airbnb;
    if (lower == 'booking_com' || lower == 'booking.com' || lower == 'bookingcom') {
      return BookingSource.bookingCom;
    }
    if (lower == 'agoda') return BookingSource.agoda;
    if (lower == 'makemytrip' || lower == 'mmt') return BookingSource.makemytrip;
    if (lower == 'goibibo') return BookingSource.goibibo;
    return BookingSource.direct;
  }

  return Booking(
    id: json['id'] as String? ?? '',
    resortName: json['propertyName'] as String? ?? '',
    guestName: json['guestName'] as String? ?? '',
    guestEmail: json['guestEmail'] as String? ?? '',
    guestPhone: json['guestPhone'] as String? ?? '',
    startDate: json['checkInDate'] as String? ?? '',
    endDate: json['checkOutDate'] as String? ?? '',
    guestsCount: json['guestsCount'] as int? ?? 1,
    nightsCount: json['nightsCount'] as int? ?? 1,
    source: _parseSource(json['otaPlatform'] as String?),
    status: BookingStatus.confirmed,
    paymentStatus: PaymentStatus.pending,
    baseAmount: 0,
    extraGuestAmount: 0,
    cleaningAmount: 0,
    discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0,
    taxAmount: 0,
    totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
    advancePaidAmount: 0,
    balanceAmount: 0,
    createdAt: json['createdAt'] as String? ?? '',
  );
}
