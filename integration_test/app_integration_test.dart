import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:integration_test/integration_test.dart';

import 'package:vsp_resorts_portal/main.dart';
import 'package:vsp_resorts_portal/presentation/screens/login_screen.dart';
import 'package:vsp_resorts_portal/presentation/screens/portal_shell_screen.dart';
import 'package:vsp_resorts_portal/presentation/screens/customer/customer_view.dart';
import 'package:vsp_resorts_portal/presentation/screens/customer/saved_view.dart';
import 'package:vsp_resorts_portal/presentation/screens/customer/dashboard_view.dart';
import 'package:vsp_resorts_portal/presentation/screens/customer/profile_view.dart';

import 'package:vsp_resorts_portal/presentation/screens/admin/admin_view.dart';
import 'package:vsp_resorts_portal/presentation/screens/staff/staff_view.dart';
import 'package:vsp_resorts_portal/presentation/screens/accountant/accountant_view.dart';
import 'package:vsp_resorts_portal/presentation/screens/super_admin/super_admin_view.dart';
import 'package:vsp_resorts_portal/presentation/providers/state_provider.dart';
import 'package:vsp_resorts_portal/presentation/routing/app_router.dart';
import 'package:vsp_resorts_portal/presentation/routing/route_names.dart';
import 'package:vsp_resorts_portal/domain/entities.dart';
import 'package:vsp_resorts_portal/domain/accountant_repository.dart';
import 'package:vsp_resorts_portal/domain/staff_repository.dart';
import 'package:vsp_resorts_portal/domain/customer_repository.dart';
import 'package:vsp_resorts_portal/domain/super_admin_repository.dart';
import 'package:vsp_resorts_portal/domain/repositories.dart';

import '../test/mocks.dart';

List<Override> allMockOverrides() => [
      accountantRepositoryProvider
          .overrideWithValue(MockAccountantRepository()),
      staffRepositoryProvider.overrideWithValue(MockStaffRepository()),
      customerRepositoryProvider.overrideWithValue(MockCustomerRepository()),
      superAdminRepositoryProvider
          .overrideWithValue(MockSuperAdminRepository()),
      resortRepositoryProvider.overrideWithValue(MockResortRepository()),
    ];

Widget wrapAppAsRole(
  UserRole role, {
  Widget? home,
  List<Override> additionalOverrides = const [],
}) {
  return ProviderScope(
    overrides: [
      isLoggedInProvider.overrideWith((ref) => true),
      authenticatedRoleProvider.overrideWith((ref) => role),
      activeRoleProvider.overrideWith((ref) => role),
      if (role == UserRole.customer)
        activeTabProvider.overrideWith((ref) => 'villa'),
      ...allMockOverrides(),
      ...additionalOverrides,
    ],
    child: MaterialApp(
      onGenerateRoute: AppRouter.generateRoute,
      home: home ?? const ResortPortalShell(),
    ),
  );
}

Future<void> pumpApp(WidgetTester tester, Widget widget) async {
  await tester.binding.setSurfaceSize(const Size(800, 600));
  await tester.pumpWidget(widget);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pump();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // ── 1. Login screen ──

  group('Login screen', () {
    testWidgets('renders branding and form elements',
        (WidgetTester tester) async {
      await pumpApp(
          tester, const ProviderScope(child: MaterialApp(home: LoginScreen())));
      expect(find.text('Sanctuary Portal'), findsOneWidget);
      expect(find.text('Access Sanctuary Portal'), findsOneWidget);
      expect(find.text('Forgot Password?'), findsOneWidget);
      expect(find.text('Request a Live Demo'), findsOneWidget);
    });

    testWidgets('shows validation snackbar on empty submit',
        (WidgetTester tester) async {
      await pumpApp(
          tester, const ProviderScope(child: MaterialApp(home: LoginScreen())));
      await tester.tap(find.text('Access Sanctuary Portal'));
      await tester.pump();
      expect(find.textContaining('enter an email'), findsOneWidget);
    });
  });

  // ── 2. Customer portal desktop sidebar (1265px actual window) ──

  group('Customer portal desktop sidebar', () {
    testWidgets('renders sidebar tab items', (WidgetTester tester) async {
      await pumpApp(tester, wrapAppAsRole(UserRole.customer));
      expect(find.text('Villa Sanctuary Specs'), findsOneWidget);
      expect(find.text('Interactive Calendar'), findsOneWidget);
      expect(find.text('My Dashboard'), findsOneWidget);
      expect(find.text('Profile Management'), findsOneWidget);
    });

    testWidgets('tapping My Dashboard shows My Trips',
        (WidgetTester tester) async {
      await pumpApp(tester, wrapAppAsRole(UserRole.customer));
      await tester.pumpAndSettle();
      await tester.tap(find.text('My Dashboard'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('My Trips'), findsOneWidget);
    });

    testWidgets('tapping Profile Management shows password section',
        (WidgetTester tester) async {
      await pumpApp(tester, wrapAppAsRole(UserRole.customer));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Profile Management'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.textContaining('Password'), findsAtLeastNWidgets(1));
    });
  });

  // ── 3. Customer resort interaction ──

  group('Customer resort interaction', () {
    testWidgets('search input field renders and accepts text',
        (WidgetTester tester) async {
      await pumpApp(tester, wrapAppAsRole(UserRole.customer));
      await tester.pumpAndSettle();
      final searchFields = find.byType(TextField);
      expect(searchFields, findsAtLeast(1));
    });

    testWidgets('resort card renders with mock data',
        (WidgetTester tester) async {
      await pumpApp(tester, wrapAppAsRole(UserRole.customer));
      await tester.pumpAndSettle();
      expect(find.text('Test Resort'), findsAtLeastNWidgets(1));
    });
  });

  // ── 4. Customer full sidebar navigation ──

  group('Customer full sidebar navigation', () {
    testWidgets('sidebar Interactive Calendar shows calendar view',
        (WidgetTester tester) async {
      await pumpApp(tester, wrapAppAsRole(UserRole.customer));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Interactive Calendar'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
      await tester.pump();
      expect(find.text('Valley Reservation Matrix'), findsOneWidget);
    });

    testWidgets(
        'sidebar Villa Specs shows resort cards after visiting calendar',
        (WidgetTester tester) async {
      await pumpApp(tester, wrapAppAsRole(UserRole.customer));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Interactive Calendar'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.tap(find.text('Villa Sanctuary Specs'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Test Resort'), findsAtLeastNWidgets(1));
    });
  });

  // ── 5. Super Admin desktop sidebar (1200px) ──

  group('Super Admin desktop sidebar', () {
    testWidgets('shows simulation role items', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      await tester.pumpWidget(wrapAppAsRole(UserRole.superAdmin));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('SIMULATE SYSTEM ROLES'), findsOneWidget);
      expect(find.text('Customer Space'), findsOneWidget);
      expect(find.text('Admin Desk'), findsOneWidget);
      expect(find.text('Staff Ops'), findsOneWidget);
      expect(find.text('Accountant Ledger'), findsOneWidget);
      expect(find.text('Super Admin Config'), findsOneWidget);
    });

    testWidgets('tapping role item updates activeRoleProvider',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 800));

      final container = ProviderContainer(
        overrides: [
          isLoggedInProvider.overrideWith((ref) => true),
          authenticatedRoleProvider.overrideWith((ref) => UserRole.superAdmin),
          activeRoleProvider.overrideWith((ref) => UserRole.superAdmin),
          ...allMockOverrides(),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            onGenerateRoute: AppRouter.generateRoute,
            home: const ResortPortalShell(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      await tester.tap(find.text('Admin Desk'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(container.read(activeRoleProvider), UserRole.admin);
    });
  });

  // ── 6. Admin functional flows ──

  group('Admin functional flows', () {
    testWidgets('renders all admin sub-tabs', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      await tester.pumpWidget(wrapAppAsRole(UserRole.admin));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Analytics Board'), findsOneWidget);
      expect(find.text('Calendar Blocking'), findsOneWidget);
      expect(find.text('Booking Matrix'), findsOneWidget);
      expect(find.text('Tariffs / Seasonality'), findsOneWidget);
      expect(find.text('Coupons Editor'), findsOneWidget);
      expect(find.text('OTA Synergy'), findsOneWidget);
      expect(find.text('Resort Operations'), findsOneWidget);
    });

    testWidgets('tapping Calendar Blocking shows block form fields',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      await tester.pumpWidget(wrapAppAsRole(UserRole.admin));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Calendar Blocking'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('BLOCK START DATE'), findsOneWidget);
      expect(find.text('BLOCK END DATE'), findsOneWidget);
      expect(find.text('Commit Date Isolation'), findsOneWidget);
    });

    testWidgets('tapping Booking Matrix shows booking table headers',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      await tester.pumpWidget(wrapAppAsRole(UserRole.admin));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Booking Matrix'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('REFERENCE ID'), findsOneWidget);
      expect(find.text('GUEST INFORMATION'), findsOneWidget);
      expect(find.text('DATES / NIGHTS'), findsOneWidget);
    });

    testWidgets('tapping Coupons Editor shows coupon form',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      await tester.pumpWidget(wrapAppAsRole(UserRole.admin));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Coupons Editor'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('COUPON CODE'), findsOneWidget);
      expect(find.text('VALUE AMOUNT'), findsOneWidget);
      expect(find.text('Add Coupon to Registry'), findsOneWidget);
    });
  });

  // ── 7. Staff functional flows ──

  group('Staff functional flows', () {
    testWidgets('renders staff view with roster tab showing empty sections',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      await tester.pumpWidget(wrapAppAsRole(UserRole.staff));
      await tester.pumpAndSettle();

      expect(find.text('Guest Transit manifest'), findsOneWidget);
      final todayStr = DateTime.now().toIso8601String().split('T').first;
      expect(find.textContaining('Today\'s Guest Arrivals'), findsOneWidget);
      expect(find.textContaining('Today\'s Key Departures'), findsOneWidget);
      expect(find.textContaining('Active In-house Guests'), findsOneWidget);
    });

    testWidgets('tapping Housekeeping tab shows housekeeping board',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      await tester.pumpWidget(wrapAppAsRole(UserRole.staff));
      await tester.pumpAndSettle();

      await tester.tap(find.textContaining('Housekeeping status board'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('In-Ground Suite Cleanings Board'), findsOneWidget);
    });
  });

  // ── 8. Accountant functional flows ──

  group('Accountant functional flows', () {
    testWidgets('renders KPI grid and invoice ledger',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      await tester.pumpWidget(wrapAppAsRole(UserRole.accountant));
      await tester.pumpAndSettle();

      expect(find.text('TOTAL BOOKED GROSS'), findsOneWidget);
      expect(find.text('TOTAL CASH COLLECTED'), findsOneWidget);
      expect(find.text('BALANCE ACCOUNT RECEIVABLE'), findsOneWidget);
      expect(find.text('REFUNDS QUEUE'), findsOneWidget);
      expect(find.text('Corporate Invoices Ledger'), findsOneWidget);
    });

    testWidgets('shows refund queue and export buttons',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      await tester.pumpWidget(wrapAppAsRole(UserRole.accountant));
      await tester.pumpAndSettle();

      expect(find.textContaining('Pending Refunds Queue'), findsOneWidget);
      expect(find.text('Export PDF Ledger'), findsOneWidget);
      expect(find.text('Export Excel'), findsOneWidget);
    });
  });

  // ── 9. Super Admin functional flows ──

  group('Super Admin functional flows', () {
    testWidgets('tab navigation switches between sections',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      await tester.pumpWidget(wrapAppAsRole(UserRole.superAdmin));
      await tester.pumpAndSettle();

      expect(find.text('Administrative Console'), findsOneWidget);
      expect(find.text('Financial Operations & Performance'), findsOneWidget);

      await tester.tap(find.text('User Management'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Create User'), findsOneWidget);

      await tester.tap(find.text('Roles & Permissions'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.textContaining('Roles'), findsAtLeastNWidgets(1));

      await tester.tap(find.text('Audit Logs'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('No audit logs recorded yet.'), findsOneWidget);

      await tester.tap(find.text('Notifications'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('System Notifications'), findsOneWidget);
    });

    testWidgets('tapping Create User opens dialog',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      await tester.pumpWidget(wrapAppAsRole(UserRole.superAdmin));
      await tester.pumpAndSettle();

      await tester.tap(find.text('User Management'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      await tester.tap(find.text('Create User'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Create User Account'), findsOneWidget);
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Role'), findsOneWidget);
    });

    testWidgets('dashboard renders all stat cards',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      await tester.pumpWidget(wrapAppAsRole(UserRole.superAdmin));
      await tester.pumpAndSettle();

      expect(find.text('TOTAL REVENUE'), findsOneWidget);
      expect(find.text('AVERAGE DAILY RATE'), findsOneWidget);
      expect(find.text('TOTAL NIGHTS'), findsOneWidget);
      expect(find.text('PENDING BALANCE'), findsOneWidget);
      expect(find.text('Global System Constraints'), findsOneWidget);
      expect(find.text('Database Overview'), findsOneWidget);
    });
  });

  // ── 10. Logout flow ──

  group('Logout flow', () {
    testWidgets('tapping Logout Perspective navigates to login',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      await tester.pumpWidget(wrapAppAsRole(UserRole.customer));
      await tester.pumpAndSettle();

      final logoutFinder = find.text('Logout Perspective');
      if (logoutFinder.evaluate().isEmpty) {
        await tester.scrollUntilVisible(logoutFinder, 100,
            scrollable: find.byType(Scrollable).first);
        await tester.pump();
      }
      await tester.tap(logoutFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Sanctuary Portal'), findsOneWidget);
    });
  });

  // ── 11. Individual screen rendering ──

  group('Screen rendering', () {
    testWidgets('CustomerView renders', (WidgetTester tester) async {
      await pumpApp(
          tester, wrapAppAsRole(UserRole.customer, home: const CustomerView()));
      expect(find.byType(CustomerView), findsOneWidget);
    });

    testWidgets('SavedView shows empty state message',
        (WidgetTester tester) async {
      await pumpApp(
          tester, wrapAppAsRole(UserRole.customer, home: const SavedView()));
      expect(find.text('No Saved Resorts Yet'), findsOneWidget);
    });

    testWidgets('CustomerDashboardView shows My Trips',
        (WidgetTester tester) async {
      await pumpApp(
          tester,
          wrapAppAsRole(UserRole.customer,
              home: const CustomerDashboardView()));
      expect(find.text('My Trips'), findsOneWidget);
    });

    testWidgets('CustomerProfileView renders password section',
        (WidgetTester tester) async {
      await pumpApp(tester,
          wrapAppAsRole(UserRole.customer, home: const CustomerProfileView()));
      expect(find.textContaining('Password'), findsAtLeastNWidgets(1));
    });

    testWidgets('StaffView renders', (WidgetTester tester) async {
      await pumpApp(
          tester, wrapAppAsRole(UserRole.staff, home: const StaffView()));
      expect(find.byType(StaffView), findsOneWidget);
    });
  });

  // ── 12. Repository integration ──

  group('Repository integration', () {
    test('MockAccountantRepository downloadLedgerPdf', () async {
      expect(await MockAccountantRepository().downloadLedgerPdf('1', '', ''),
          endsWith('.pdf'));
    });
    test('MockAccountantRepository downloadLedgerExcel', () async {
      expect(await MockAccountantRepository().downloadLedgerExcel('1', '', ''),
          endsWith('.xlsx'));
    });
    test('MockStaffRepository fetchProperties returns data', () async {
      expect(await MockStaffRepository().fetchProperties(), isNotEmpty);
    });
    test('MockCustomerRepository fetchProperties returns mock data', () async {
      expect(await MockCustomerRepository().fetchProperties(), isNotEmpty);
    });
    test('MockResortRepository fetchPropertyDetails returns PropertyDetails',
        () async {
      final d = await MockResortRepository().fetchPropertyDetails();
      expect(d.id, '1');
      expect(d.name, 'Test');
    });
  });
}

class MockSuperAdminRepository implements ISuperAdminRepository {
  @override
  Future<Map<String, dynamic>> fetchAnalyticsRevenue() async => {};
  @override
  Future<List<Map<String, dynamic>>> fetchBookingSources() async => [];
  @override
  Future<List<Map<String, dynamic>>> fetchResortRevenueTable() async => [];
  @override
  Future<Map<String, dynamic>> fetchGlobalSettings() async => {};
  @override
  Future<void> updateGlobalSettings(Map<String, dynamic> s) async {}
  @override
  Future<void> factoryReset({String? confirmationToken}) async {}
  @override
  Future<Map<String, dynamic>> fetchSchema() async => {};
  @override
  Future<List<Map<String, dynamic>>> fetchProperties() async => [];
  @override
  Future<Map<String, dynamic>> fetchPropertyDetail(String id) async => {};
  @override
  Future<void> createProperty(Map<String, dynamic> p) async {}
  @override
  Future<void> updateProperty(String id, Map<String, dynamic> p) async {}
  @override
  Future<void> deleteProperty(String id) async {}
  @override
  Future<Map<String, dynamic>> uploadImage(String filePath,
          {String? caption}) async =>
      {};
  @override
  Future<List<Map<String, dynamic>>> uploadGallery(
          List<String> filePaths) async =>
      [];
  @override
  Future<List<Map<String, dynamic>>> fetchUsers(
          {String? role,
          String? status,
          String? search,
          int page = 1,
          int pageSize = 20}) async =>
      [];
  @override
  Future<Map<String, dynamic>> fetchUserDetail(String id) async => {};
  @override
  Future<void> createUser(Map<String, dynamic> user) async {}
  @override
  Future<void> updateUser(String id, Map<String, dynamic> user) async {}
  @override
  Future<void> deleteUser(String id) async {}
  @override
  Future<List<Map<String, dynamic>>> fetchApprovals() async => [];
  @override
  Future<List<Map<String, dynamic>>> fetchPendingApprovals() async => [];
  @override
  Future<void> resolveApproval(String id, String status,
      {String? rejectionReason}) async {}
  @override
  Future<List<RoleDefinition>> fetchRoles() async => [];
  @override
  Future<RoleDefinition> fetchRoleDetail(String id) async => RoleDefinition(
      id: '1', displayName: 'Admin', description: '', permissions: []);
  @override
  Future<void> updateRole(RoleDefinition role) async {}
  @override
  Future<List<Map<String, dynamic>>> fetchAuditLogs(
          {String? userId,
          String? action,
          String? from,
          String? to,
          int? page,
          int? pageSize}) async =>
      [];
  @override
  Future<List<AppNotification>> fetchNotifications() async => [];
  @override
  Future<void> addNotification(AppNotification notification) async {}
  @override
  Future<void> markNotificationAsRead(String id) async {}
  @override
  Future<void> clearNotifications() async {}
  @override
  Future<List<Booking>> fetchAllBookings() async => [];
}
