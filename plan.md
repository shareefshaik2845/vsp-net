## Plan: Add Super Admin Installation and User Management

TL;DR - Implement a local sandbox installation flow that creates the first Super Admin account, enables login against in-memory user accounts, and adds a Super Admin user-management panel for creating Admin, Staff, Accountant, and Customer accounts.

**Steps**
1. Add a `UserAccount` entity in `lib/domain/entities.dart` with fields for id, name, email, password, role, and createdAt.
2. In `lib/presentation/providers/state_provider.dart`, add a `UserAccountsNotifier` and `usersProvider` to hold the in-memory account list and methods for add/update/remove.
3. Add a provider `hasSuperAdminProvider` or a computed provider to determine whether the app has an existing Super Admin.
4. Create a new `InstallationScreen` under `lib/presentation/screens/install_screen.dart` that shows when no Super Admin exists. The screen should collect super admin name, email, and password, validate inputs, and create the first Super Admin account.
5. Update `lib/presentation/screens/portal_shell_screen.dart` so startup shows `InstallationScreen` before `LoginScreen` when `hasSuperAdminProvider` is false.
6. Update `lib/presentation/screens/login_screen.dart` to authenticate against `usersProvider` instead of inferring from email text. Add proper validation/error messages and allow logging in as created accounts.
7. Update the role selection UI in `LoginScreen` to include staff as a selectable option for completeness.
8. Extend `lib/presentation/screens/super_admin/super_admin_view.dart` with a user management panel: list existing users, show role badges, and add a dialog to create Admin, Staff, Accountant, or Customer users.
9. In `SuperAdminView`, add local methods for opening the create-user dialog, validating unique email, adding new users, and optionally showing a success notification using `notificationsProvider`.
10. Enhance the existing "Onboard New Resort" dialog in `SuperAdminView` by supporting:
    - primary cover image URL or upload field
    - multiple gallery image URLs or upload slots
    - resort description, tagline, and full location
    - city/state plus optional country
    - weekday/weekend base price, extra guest charge, and cleaning fee
    - elite amenities list (such as private pool, private chef, spa, home theatre, concierge service, high-speed WiFi)
    - rules and house policies (check-in/out times, smoking and pet policies, quiet hours, max occupancy)
    - ability to add amenities dynamically and preview uploaded images
11. Ensure the login flow sets `activeRoleProvider`, `authenticatedRoleProvider`, and `isLoggedInProvider` based on the authenticated `UserAccount`. For customers, optionally populate `mockProfileProvider` from the user account.

**Relevant files**
- `lib/domain/entities.dart` — add `UserAccount` model with role mapping.
- `lib/presentation/providers/state_provider.dart` — add `usersProvider`, `UserAccountsNotifier`, and install-state provider.
- `lib/presentation/screens/install_screen.dart` — new installation wizard screen.
- `lib/presentation/screens/portal_shell_screen.dart` — wire installation screen before login.
- `lib/presentation/screens/login_screen.dart` — replace role/email inference with real account auth.
- `lib/presentation/screens/super_admin/super_admin_view.dart` — add user management UI and create-user flows.

**Verification**
1. Start the app with no Super Admin account and verify the installation wizard appears instead of login.
2. Create the first Super Admin account and verify the app navigates to the login screen.
3. Log in as the created Super Admin with the entered credentials and verify the Super Admin dashboard loads.
4. From the Super Admin panel, create one account each for Admin, Staff, Accountant, and Customer.
5. Log out and log back in using each created account to verify credential matching and role activation.
6. Verify the system does not allow duplicate emails and shows validation feedback.

**Decisions**
- Migrated from in-memory to database-backed persistence via Spring Boot + PostgreSQL + Flyway migrations.
- Sandbox role-switching behavior replaced with real JWT-authenticated role-based access.
- Seed data provided via Flyway migrations V1–V9 covering all roles (Super Admin, Admin, Staff, Accountant, Customer).
- `DataSeeder` CommandLineRunner supplements migrations with role-specific users if missing.

**Further considerations**
1. Additional seed data can be added as new Flyway migrations (V10+).
2. A dedicated account-edit flow could be added to the Super Admin panel in a follow-up.

---

## Plan: RBAC + Permissions CRUD + Approvals

### Summary

Add a full permissions engine on top of the existing role system. Every action across all 5 roles becomes permission-gated. SuperAdmin gets a new UI to manage roles/permissions (CRUD). Actions that require sign-off (e.g., refunds, cancellations, pricing changes) enter an **approval workflow** where a designated approver must confirm before execution.

### New Entities (add to `domain/entities.dart`)

```dart
enum PermissionAction { create, read, update, delete, approve }

enum PermissionResource {
  bookings, calendar, coupons, pricing, rooms, ota,
  notifications, properties, users, roles, approvals, reports,
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
}

class RoleDefinition {
  final String id;
  final String displayName;
  final String description;
  final List<RolePermission> permissions;
}

class RolePermission {
  final PermissionResource resource;
  final List<PermissionAction> actions;
}
```

### Data Layer

**New: `domain/permission_repository.dart`**
```dart
abstract class IPermissionRepository {
  List<RoleDefinition> getRoles();
  void updateRole(RoleDefinition role);
  void addApprovalRequest(ApprovalRequest req);
  List<ApprovalRequest> getPendingRequests(String approverRole);
  void resolveApproval(String id, ApprovalStatus status, {String? reason});
}
```

**Extend `data/repositories_impl.dart`** — in-memory `_roles` + `_approvalRequests` lists, implement interface.

### Default Permission Matrix

| Resource | SuperAdmin | Admin | Staff | Accountant | Customer |
|---|---|---|---|---|---|
| booking | CRUD+CAp | CRUDeC | R | R | CRc |
| property | CRUD | CRU | R | — | R |
| invoice | CRUD+ApRf | R+Ap | — | R+Ap | R |
| payment | CRU+Rf | R+Rf | — | R+Rf | R |
| user | CRUD | R | — | — | — |
| pricing | CRUD | CRU | — | — | — |
| housekeeping | CRUD | RU | RU | — | — |
| concierge | CRUD | RU | RU | — | CR |
| coupon | CRUD | CRUD | — | — | — |
| ota | CRUD | RU | — | — | — |
| analytics | R | R | — | R | — |
| calendar | CRUD | CRUD | — | — | — |
| settings | CRUD | RU | — | — | — |
| notification | CRUD | R | R | R | RU |
| favorite | CRD | — | — | — | CRD |
| audit | R | — | — | R | — |
| role | CRUD | — | — | — | — |
| approval | R+ApRj | R+Ap | — | — | — |

**Legend:** C=create, R=read, U=update, D=delete, Ap=approve, Rj=reject, Rf=refund, c=cancel

### State/Provider

**New: `presentation/providers/permission_provider.dart`**
```dart
final rolesProvider = NotifierProvider<RolesNotifier, List<RoleDefinition>>(...);
final approvalProvider = NotifierProvider<ApprovalNotifier, List<ApprovalRequest>>(...);

final canPerformProvider = Provider.family<bool, (PermissionResource, PermissionAction)>(
  (ref, pair) { /* lookup */ },
);
```

### Approval Workflow

| Action | Requires Approval From |
|---|---|
| Cancel booking + refund >50% | Admin or SuperAdmin |
| Delete a coupon | SuperAdmin |
| Change pricing rule >20% delta | SuperAdmin |
| Delete calendar block (check-in within 7 days) | Admin |

**Flow:** User triggers action → permission check → if action needs `approve`, create `ApprovalRequest` instead → approver sees pending requests → approves/rejects → notification sent → on approval, action executes.

### UI Changes

| File | Change |
|---|---|
| `super_admin/role_management_view.dart` | **[NEW]** CRUD table: roles × resources, checkboxes for C/R/U/D/A |
| `widgets/permission_guard.dart` | **[NEW]** Conditional child renderer by permission |
| `widgets/approval_panel.dart` | **[NEW]** Reusable approval list with Accept/Reject |
| `portal_shell_screen.dart` | **[MODIFY]** Pending approval badge in header |
| `super_admin_view.dart` | **[MODIFY]** Add role management tab |
| `admin_view.dart` | **[MODIFY]** Add approvals tab, gate actions |
| `accountant_view.dart` | **[MODIFY]** Gate refunds behind approval |
| `staff_view.dart` | **[MODIFY]** Gate housekeeping changes |
| `customer_view.dart`, `profile_view.dart` | **[MODIFY]** Gate cancellations, profile edits |

### Implementation Order

| Step | What | Files |
|---|---|---|
| 1 | Add Permission/Approval entities + enums | `domain/entities.dart` |
| 2 | Add `IPermissionRepository` | `domain/repositories.dart` |
| 3 | Implement repo with defaults | `data/repositories_impl.dart` |
| 4 | Create permission providers | `presentation/providers/permission_provider.dart` |
| 5 | Add approval provider | `presentation/providers/state_provider.dart` |
| 6 | Create guard + approval widgets | `presentation/widgets/permission_guard.dart`, `approval_panel.dart` |
| 7 | Create role management screen | `presentation/screens/super_admin/role_management_view.dart` |
| 8-13 | Modify each role view to use permission gating + approvals | All 6 screen files |

### Key Decisions

- Staff excluded from sidebar simulation (current behavior preserved).
- Approval queue persisted in `approval_requests` table via Flyway migrations + backend API.
- Widget-level permission gating via `PermissionGuard` wrapper.
- Role CRUD is SuperAdmin-only.
- ~1,000 lines total (~600 new, ~400 modifications).
