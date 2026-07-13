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
  testWidgets('App loads and shows VSP Nest Portal', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: VspNestApp()));
    expect(find.textContaining('VSP Nest'), findsAtLeastNWidgets(1));
    await tester.pump(const Duration(milliseconds: 2500));
    await tester.pump();
  });

  // ── Accountant repository unit tests ──

  test('MockAccountantRepository downloadLedgerPdf returns file path', () async {
    final repo = MockAccountantRepository();
    final path = await repo.downloadLedgerPdf('p1', '2026-01-01', '2026-01-31');
    expect(path, isNotEmpty);
    expect(path, endsWith('.pdf'));
  });

  test('MockAccountantRepository downloadLedgerExcel returns file path', () async {
    final repo = MockAccountantRepository();
    final path = await repo.downloadLedgerExcel('p1', '2026-01-01', '2026-01-31');
    expect(path, isNotEmpty);
    expect(path, endsWith('.xlsx'));
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

  test('MockStaffRepository fetchHousekeepingRooms returns empty list', () async {
    final repo = MockStaffRepository();
    final rooms = await repo.fetchHousekeepingRooms('1');
    expect(rooms, isEmpty);
  });

  test('MockStaffRepository updateHousekeepingStatus completes', () async {
    final repo = MockStaffRepository();
    await repo.updateHousekeepingStatus('r1', 'cleaning');
  });

  // ── MockResortRepository unit tests ──

  test('MockResortRepository fetchPropertyDetails returns a PropertyDetails', () async {
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
}
