Steps to Go Live
==================
1. Start PostgreSQL & Create Database

# Connect to PostgreSQL and create the database
psql -U postgres -c "CREATE DATABASE vsp_nest;"

2. Run Flyway Migrations

cd D:\VSP\backend
mvn flyway:migrate

This creates all tables and applies schema migrations.

3. Start the Backend
mvn spring-boot:run
The API starts at http://localhost:8080.

On first startup:
- **Flyway V1–V4**: Create schema, seed 1 super admin user, 4 properties, roles, permissions, app settings, coupons, OTA configs, and initial transactional data.
- **Flyway V5–V9**: Seed comprehensive demo data across all roles — additional properties, users, bookings, payments, invoices, refunds, housekeeping tasks, rosters, notifications, concierge requests, approval requests, and audit logs.
- `DataSeeder` (Java CommandLineRunner) supplements by creating 4 additional role-specific users (admin, staff, accountant, customer) if not already present.

4. Verify APIs
# Test login (returns JWT + user profile + RBAC permissions)
curl -X POST http://localhost:8080/api/v1/auth/login `
  -H "Content-Type: application/json" `
  -d '{"email":"superadmin@vspnest.com","password":"admin123"}'

# Test authenticated endpoint
curl http://localhost:8080/api/v1/super-admin/dashboard `
  -H "Authorization: Bearer <token>"

5. Connect Flutter App
The Flutter app already connects via `ApiClient` at `http://localhost:8080/api/v1`.
Update the `API_BASE_URL` at build time if needed:
flutter run --dart-define=API_BASE_URL=http://localhost:8080

6. RBAC Permissions
Each role's permissions are stored in `role_definitions` and `role_permissions` tables.
Login response includes a `permissions` array: `[{resource, actions}, ...]`.
To modify permissions, use the Super Admin role management UI or seed new `RolePermission` rows.

7. Run Tests
mvn test