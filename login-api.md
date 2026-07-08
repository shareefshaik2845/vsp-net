# VSP Nest — Auth API Contract

## Default Credentials

| Role | Email | Password |
|------|-------|----------|
| Super Admin | `superadmin@vspnest.com` | `admin123` |
| Admin | `admin@vspnest.com` | `admin123` |
| Staff | `housekeeping.staff@vspnest.com` | `staff123` |
| Accountant | `accountant@vspnest.com` | `accountant123` |
| Customer | `ananya@rediff.com` | `customer123` |

---

## `POST /api/v1/auth/setup`

Initializes the system by creating the first Super Admin. Only works if no Super Admin exists yet.

### Request

**Endpoint:** `POST /api/v1/auth/setup`  
**Content-Type:** `application/json`

```json
{
  "name": "Super Admin",
  "email": "superadmin@vspnest.com",
  "password": "admin123",
  "phone": "+91 98765 43210"
}
```

### Success Response (201 Created)

```json
{
  "success": true,
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIs...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIs...",
    "tokenType": "Bearer",
    "user": {
      "id": 1,
      "name": "Super Admin",
      "email": "superadmin@vspnest.com",
      "phone": "+91 98765 43210",
      "role": "SUPER_ADMIN",
      "roleDisplayName": "Super Admin",
      "profileImageUrl": null,
      "active": true,
      "permissions": [
        { "resource": "booking", "actions": ["create","read","update","delete","cancel","approve"] },
        { "resource": "property", "actions": ["create","read","update","delete"] },
        { "resource": "invoice", "actions": ["create","read","update","delete","approve","refund"] },
        { "resource": "payment", "actions": ["create","read","update","refund"] },
        { "resource": "user", "actions": ["create","read","update","delete"] },
        { "resource": "pricing", "actions": ["create","read","update","delete"] },
        { "resource": "housekeeping", "actions": ["create","read","update","delete"] },
        { "resource": "concierge", "actions": ["create","read","update","delete"] },
        { "resource": "coupon", "actions": ["create","read","update","delete"] },
        { "resource": "ota", "actions": ["create","read","update","delete"] },
        { "resource": "analytics", "actions": ["read"] },
        { "resource": "calendar", "actions": ["create","read","update","delete"] },
        { "resource": "settings", "actions": ["create","read","update","delete"] },
        { "resource": "notification", "actions": ["create","read","update","delete"] },
        { "resource": "favorite", "actions": ["create","read","delete"] },
        { "resource": "audit", "actions": ["read"] },
        { "resource": "role", "actions": ["create","read","update","delete"] },
        { "resource": "approval", "actions": ["read","approve","reject"] }
      ]
    }
  },
  "message": "Super Admin created successfully. Please log in."
}
```

### Error Response (400 Bad Request)

```json
{
  "success": false,
  "error": "System already initialized. A Super Admin already exists."
}
```

---

## `POST /api/v1/auth/login`

Authenticates a user and returns JWT tokens with full user profile and RBAC permissions.

### Request

**Endpoint:** `POST /api/v1/auth/login`  
**Content-Type:** `application/json`

```json
{
  "email": "ananya@rediff.com",
  "password": "customer123"
}
```

### Success Response (200 OK)

```json
{
  "success": true,
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIs...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIs...",
    "tokenType": "Bearer",
    "user": {
      "id": 5,
      "name": "Ananya Sharma",
      "email": "ananya@rediff.com",
      "phone": "+91 94432 12345",
      "role": "CUSTOMER",
      "roleDisplayName": "Customer",
      "profileImageUrl": null,
      "active": true,
      "permissions": [
        { "resource": "booking", "actions": ["create", "read", "cancel"] },
        { "resource": "invoice", "actions": ["read"] },
        { "resource": "payment", "actions": ["read"] },
        { "resource": "property", "actions": ["read"] },
        { "resource": "favorite", "actions": ["create", "read", "delete"] },
        { "resource": "concierge", "actions": ["create", "read"] },
        { "resource": "notification", "actions": ["read", "update"] }
      ]
    }
  }
}
```

### Error Responses

**401 Unauthorized — Invalid credentials**

```json
{
  "success": false,
  "error": "Invalid email or password"
}
```

**400 Bad Request — Account inactive**

```json
{
  "success": false,
  "error": "Account is deactivated"
}
```

**400 Bad Request — Validation failure**

```json
{
  "success": false,
  "error": "Validation failed",
  "data": {
    "email": "Invalid email format"
  }
}
```

### Field Reference

| Field | Type | Description |
|---|---|---|
| `accessToken` | string | JWT access token (1 hour expiry) |
| `refreshToken` | string | JWT refresh token (7 day expiry) |
| `tokenType` | string | Always `Bearer` |
| `user.id` | number | User's database primary key |
| `user.role` | string | One of: `CUSTOMER`, `ADMIN`, `STAFF`, `ACCOUNTANT`, `SUPER_ADMIN` |
| `user.permissions` | array | List of `{resource, actions}` objects from `role_definitions` table |
| `user.permissions[].resource` | string | Permission resource name (e.g. `booking`, `invoice`) |
| `user.permissions[].actions` | string[] | Allowed actions (e.g. `["create", "read"]`) |

### RBAC Permission Resources

| Resource | Description |
|---|---|
| `booking` | Booking operations |
| `property` | Property management |
| `invoice` | Invoice and billing |
| `payment` | Payment processing |
| `user` | User management |
| `pricing` | Pricing and seasonality |
| `housekeeping` | Room housekeeping status |
| `concierge` | Concierge requests |
| `coupon` | Coupon codes |
| `ota` | OTA channel sync |
| `analytics` | Analytics and reports |
| `calendar` | Calendar blocking |
| `settings` | System settings |
| `notification` | Notifications |
| `favorite` | Saved favorites |
| `audit` | Audit logs |
| `role` | Role/permission management |
| `approval` | Approval workflows |

### Permission Actions

| Action | Description |
|---|---|
| `create` | Can create new records |
| `read` | Can view records |
| `update` | Can modify existing records |
| `delete` | Can remove records |
| `approve` | Can approve requests |
| `reject` | Can reject requests |
| `cancel` | Can cancel bookings |
| `refund` | Can process refunds |

---

## `GET /api/v1/auth/me`

Returns the current user's profile and permissions based on the provided token.

**Headers:** `Authorization: Bearer <token>`

### Response (200 OK)

Same `user` object as the login response (without `accessToken`, `refreshToken`, `tokenType`).

---

## `POST /api/v1/auth/refresh`

Refresh an expiring token.

**Headers:** `Authorization: Bearer <token>`  
**Content-Type:** `application/json`

### Request

```json
{
  "refreshToken": "eyJhbGciOiJIUzI1NiIs..."
}
```

### Response (200 OK)

```json
{
  "success": true,
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIs...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIs...",
    "tokenType": "Bearer",
    "user": {
      "id": 5,
      "name": "Ananya Sharma",
      "email": "ananya@rediff.com",
      "phone": "+91 94432 12345",
      "role": "CUSTOMER",
      "roleDisplayName": "Customer",
      "profileImageUrl": null,
      "active": true,
      "permissions": [
        { "resource": "booking", "actions": ["create", "read", "cancel"] },
        { "resource": "invoice", "actions": ["read"] },
        { "resource": "payment", "actions": ["read"] },
        { "resource": "property", "actions": ["read"] },
        { "resource": "favorite", "actions": ["create", "read", "delete"] },
        { "resource": "concierge", "actions": ["create", "read"] },
        { "resource": "notification", "actions": ["read", "update"] }
      ]
    }
  }
}
```

---

## `POST /api/v1/auth/logout`

Logs out the current user and clears server-side state.

**Headers:** `Authorization: Bearer <token>`

### Response (200 OK)

```json
{
  "success": true
}
```
