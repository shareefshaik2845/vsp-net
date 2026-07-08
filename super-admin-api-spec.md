# VSP Nest — Super Admin API Spec (28 APIs)

> **Prerequisite:** Initialize via `POST /api/v1/auth/setup` (see [`login-api.md`](./login-api.md)).  
> Default credentials: `superadmin@vspnest.com` / `admin123`.

---

## 1. Auth (shared)

### POST /api/v1/auth/login

**Request:**
```json
{
  "email": "superadmin@vspnest.com",
  "password": "admin123"
}
```

**Response (200):**
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
        { "resource": "booking", "actions": ["create", "read", "update", "delete", "cancel", "approve"] },
        { "resource": "property", "actions": ["create", "read", "update", "delete"] },
        { "resource": "invoice", "actions": ["create", "read", "update", "delete", "approve", "refund"] },
        { "resource": "payment", "actions": ["create", "read", "update", "refund"] },
        { "resource": "user", "actions": ["create", "read", "update", "delete"] },
        { "resource": "pricing", "actions": ["create", "read", "update", "delete"] },
        { "resource": "housekeeping", "actions": ["create", "read", "update", "delete"] },
        { "resource": "concierge", "actions": ["create", "read", "update", "delete"] },
        { "resource": "coupon", "actions": ["create", "read", "update", "delete"] },
        { "resource": "ota", "actions": ["create", "read", "update", "delete"] },
        { "resource": "analytics", "actions": ["read"] },
        { "resource": "calendar", "actions": ["create", "read", "update", "delete"] },
        { "resource": "settings", "actions": ["create", "read", "update", "delete"] },
        { "resource": "notification", "actions": ["create", "read", "update", "delete"] },
        { "resource": "favorite", "actions": ["create", "read", "delete"] },
        { "resource": "audit", "actions": ["read"] },
        { "resource": "role", "actions": ["create", "read", "update", "delete"] },
        { "resource": "approval", "actions": ["read", "approve", "reject"] }
      ]
    }
  }
}
```

---

## 2. Dashboard / Analytics

### GET /api/v1/super-admin/analytics/revenue

**Headers:** `Authorization: Bearer <token>`

**Response (200):**
```json
{
  "success": true,
  "data": {
    "totalRevenue": 4850000.00,
    "averageDailyRate": 18500.00,
    "totalNights": 1240,
    "pendingBalance": 720000.00,
    "currency": "INR",
    "period": {
      "from": "2026-01-01",
      "to": "2026-12-31"
    }
  }
}
```

### GET /api/v1/super-admin/analytics/booking-sources

**Response (200):**
```json
{
  "success": true,
  "data": [
    { "source": "direct", "label": "Direct", "count": 85, "revenue": 2125000.00, "percentage": 43.8 },
    { "source": "airbnb", "label": "Airbnb", "count": 32, "revenue": 824000.00, "percentage": 17.0 },
    { "source": "bookingCom", "label": "Booking.com", "count": 28, "revenue": 706000.00, "percentage": 14.6 },
    { "source": "agoda", "label": "Agoda", "count": 18, "revenue": 458000.00, "percentage": 9.4 },
    { "source": "makemytrip", "label": "MakeMyTrip", "count": 22, "revenue": 556000.00, "percentage": 11.5 },
    { "source": "goibibo", "label": "Goibibo", "count": 8, "revenue": 186000.00, "percentage": 3.8 }
  ]
}
```

### GET /api/v1/super-admin/analytics/resort-revenue-table

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "propertyId": "PROP-001",
      "propertyName": "Whispering Valleys Sanctuary",
      "totalBookings": 48,
      "totalRevenue": 1820000.00,
      "occupancyRate": 72.5,
      "averageDailyRate": 19500.00
    },
    {
      "propertyId": "PROP-002",
      "propertyName": "Azure Sands Coastal Villa",
      "totalBookings": 42,
      "totalRevenue": 1560000.00,
      "occupancyRate": 68.3,
      "averageDailyRate": 21000.00
    },
    {
      "propertyId": "PROP-003",
      "propertyName": "Cloud-kissed Mountain Manor",
      "totalBookings": 35,
      "totalRevenue": 980000.00,
      "occupancyRate": 55.1,
      "averageDailyRate": 16500.00
    },
    {
      "propertyId": "PROP-004",
      "propertyName": "Forest Glade Wilderness Retreat",
      "totalBookings": 28,
      "totalRevenue": 490000.00,
      "occupancyRate": 42.8,
      "averageDailyRate": 14000.00
    }
  ]
}
```

---

## 3. Global Settings

### GET /api/v1/super-admin/settings

**Response (200):**
```json
{
  "success": true,
  "data": {
    "taxRate": 18,
    "depositRate": 30,
    "multiPropertyEnabled": true,
    "defaultCurrency": "INR",
    "timezone": "Asia/Kolkata",
    "cancellationPolicy": {
      "freeCancellationDays": 7,
      "penaltyPercentAfter": 50,
      "noShowPenaltyPercent": 100
    }
  }
}
```

### PUT /api/v1/super-admin/settings

**Request:**
```json
{
  "taxRate": 18,
  "depositRate": 30,
  "multiPropertyEnabled": true,
  "cancellationPolicy": {
    "freeCancellationDays": 7,
    "penaltyPercentAfter": 50,
    "noShowPenaltyPercent": 100
  }
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Global settings updated successfully",
  "data": { "taxRate": 18, "depositRate": 30, "multiPropertyEnabled": true }
}
```

### POST /api/v1/super-admin/system/factory-reset

**Headers:** `Authorization: Bearer <token>`

**Request:** (empty body)

**Response (200):**
```json
{
  "success": true,
  "message": "System has been reset to factory defaults. All data has been purged."
}
```

### GET /api/v1/super-admin/system/schema

**Response (200):**
```json
{
  "success": true,
  "data": {
    "tables": [
      { "name": "users", "rowCount": 12, "columns": ["id", "name", "email", "password_hash", "role", "status", "created_at", "last_login_at"] },
      { "name": "properties", "rowCount": 4, "columns": ["id", "name", "tagline", "description", "location", "base_price_weekday", "base_price_weekend", "state", "city", "created_at"] },
      { "name": "bookings", "rowCount": 45, "columns": ["id", "property_id", "guest_name", "guest_email", "start_date", "end_date", "status", "total_amount", "created_at"] },
      { "name": "calendar_blocks", "rowCount": 8, "columns": ["id", "property_id", "start_date", "end_date", "reason", "notes", "blocked_by"] },
      { "name": "coupons", "rowCount": 6, "columns": ["id", "code", "type", "value", "expiry_date", "usage_limit", "usage_count", "is_active"] },
      { "name": "pricing_rules", "rowCount": 3, "columns": ["id", "property_id", "name", "start_date", "end_date", "weekday_price", "weekend_price", "multiplier", "is_active"] },
      { "name": "ota_channels", "rowCount": 5, "columns": ["id", "channel_name", "last_sync_time", "status", "conflicts_count", "sync_enabled"] },
      { "name": "rooms", "rowCount": 10, "columns": ["id", "property_id", "name", "housekeeping_status", "assigned_staff", "notes", "last_updated"] },
      { "name": "approval_requests", "rowCount": 3, "columns": ["id", "resource_type", "resource_id", "action", "payload", "requested_by", "approved_by", "status", "created_at", "resolved_at"] },
      { "name": "audit_logs", "rowCount": 256, "columns": ["id", "user_id", "action", "target_type", "target_id", "details", "timestamp"] },
      { "name": "role_definitions", "rowCount": 5, "columns": ["id", "display_name", "description"] },
      { "name": "role_permissions", "rowCount": 60, "columns": ["id", "role_id", "resource", "actions"] }
    ]
  }
}
```

---

## 4. Multi-Property Management

> **Image Upload Convention:** All image fields (`image`, `gallery[]`) in POST/PUT use `multipart/form-data`.
> The backend stores files and returns URLs in the format:
> `https://api.vspnest.com/uploads/properties/{propertyId}/{filename}`
> For seed/initial data, the backend returns Unsplash CDN URLs.

### POST /api/v1/super-admin/properties/upload-image

Upload a single image and get back its URL (used before creating property, or standalone).

**Request:** `multipart/form-data`

| Field | Type | Description |
|-------|------|-------------|
| `file` | binary | Image file (max 5MB, jpg/png/webp) |

**Response (200):**
```json
{
  "success": true,
  "data": {
    "url": "https://api.vspnest.com/uploads/temp/ab3f2c91-sunset-pool.jpg",
    "filename": "ab3f2c91-sunset-pool.jpg",
    "size": 284156,
    "mimeType": "image/jpeg"
  }
}
```

### POST /api/v1/super-admin/properties/upload-gallery

Upload multiple gallery images.

**Request:** `multipart/form-data`

| Field | Type | Description |
|-------|------|-------------|
| `files[]` | binary[] | Up to 10 images (max 5MB each) |

**Response (200):**
```json
{
  "success": true,
  "data": [
    { "url": "https://api.vspnest.com/uploads/temp/ab3f2c91-pool.jpg", "filename": "ab3f2c91-pool.jpg" },
    { "url": "https://api.vspnest.com/uploads/temp/cd4e3a72-bedroom.jpg", "filename": "cd4e3a72-bedroom.jpg" },
    { "url": "https://api.vspnest.com/uploads/temp/ef5b4c83-garden.jpg", "filename": "ef5b4c83-garden.jpg" }
  ]
}
```

### GET /api/v1/super-admin/properties

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "PROP-001",
      "name": "Whispering Valleys Sanctuary",
      "tagline": "Escape to the lap of luxury amidst rolling hills",
      "description": "Nestled in the heart of the Western Ghats...",
      "location": "Coorg, Karnataka",
      "basePriceWeekday": 15000.00,
      "basePriceWeekend": 22000.00,
      "extraGuestCharge": 2500.00,
      "cleaningFee": 1500.00,
      "state": "Karnataka",
      "city": "Coorg",
      "image": "https://images.unsplash.com/photo-1580587771525-78b9dba3b914?w=1600",
      "gallery": [
        "https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=1600",
        "https://images.unsplash.com/photo-1540541338287-41700207dee6?w=1600"
      ],
      "amenities": [
        { "icon": "pool", "label": "Private Infinity Pool", "category": "premium" },
        { "icon": "restaurant", "label": "Personal Chef", "category": "dining" },
        { "icon": "spa", "label": "In-room Spa", "category": "wellness" }
      ],
      "rules": [
        "Check-in: 2:00 PM | Check-out: 11:00 AM",
        "No smoking inside the villa",
        "Pets allowed only with prior approval"
      ],
      "createdAt": "2026-01-15T10:00:00Z",
      "updatedAt": "2026-06-20T14:30:00Z",
      "isActive": true
    },
    {
      "id": "PROP-002",
      "name": "Azure Sands Coastal Villa",
      "tagline": "Where the ocean meets luxury",
      "description": "A stunning beachfront villa with private access to pristine sands...",
      "location": "Palolem, Goa",
      "basePriceWeekday": 18000.00,
      "basePriceWeekend": 26000.00,
      "extraGuestCharge": 3000.00,
      "cleaningFee": 2000.00,
      "state": "Goa",
      "city": "South Goa",
      "image": "https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=1600",
      "gallery": [
        "https://images.unsplash.com/photo-1566073771259-6a8506099945?w=1600",
        "https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=1600"
      ],
      "amenities": [
        { "icon": "pool", "label": "Infinity Edge Pool", "category": "premium" },
        { "icon": "local_bar", "label": "Beach Bar", "category": "dining" }
      ],
      "rules": [
        "Check-in: 2:00 PM | Check-out: 11:00 AM",
        "No smoking inside the villa",
        "Pets allowed only with prior approval"
      ],
      "createdAt": "2026-01-20T10:00:00Z",
      "updatedAt": "2026-06-18T14:30:00Z",
      "isActive": true
    },
    {
      "id": "PROP-003",
      "name": "Cloud-kissed Mountain Manor",
      "tagline": "A serene mountain escape above the clouds",
      "description": "Perched at 8,000 ft with panoramic Himalayan views...",
      "location": "Manali, Himachal Pradesh",
      "basePriceWeekday": 12000.00,
      "basePriceWeekend": 18000.00,
      "extraGuestCharge": 2000.00,
      "cleaningFee": 1500.00,
      "state": "Himachal Pradesh",
      "city": "Manali",
      "image": "https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?w=1600",
      "gallery": [
        "https://images.unsplash.com/photo-1497366216548-37526070297c?w=1600",
        "https://images.unsplash.com/photo-1613490493576-7fde63acd811?w=1600"
      ],
      "amenities": [
        { "icon": "fireplace", "label": "Stone Fireplace", "category": "premium" },
        { "icon": "ac_unit", "label": "Mountain-View Deck", "category": "premium" }
      ],
      "rules": [
        "Check-in: 1:00 PM | Check-out: 10:00 AM",
        "No smoking inside the manor",
        "Pets not allowed"
      ],
      "createdAt": "2026-02-01T10:00:00Z",
      "updatedAt": "2026-06-15T14:30:00Z",
      "isActive": true
    }
  ]
}
```

### POST /api/v1/super-admin/properties (Onboard New Resort)

**Content-Type:** `multipart/form-data`

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | yes | Resort name |
| `tagline` | string | yes | Short tagline |
| `description` | string | yes | Full description |
| `location` | string | yes | Location string |
| `state` | string | yes | State/region |
| `city` | string | yes | City |
| `basePriceWeekday` | number | yes | Weekday base price |
| `basePriceWeekend` | number | yes | Weekend base price |
| `extraGuestCharge` | number | yes | Per extra guest charge |
| `cleaningFee` | number | yes | Cleaning fee |
| `image` | file | yes | Primary cover image (jpg/png/webp, max 5MB) |
| `gallery` | file[] | no | Up to 10 additional images |
| `amenities` | string | yes | JSON string: `[{"icon":"pool","label":"...","category":"..."}]` |
| `rules` | string | yes | JSON string array: `["Rule 1","Rule 2"]` |

**Example cURL:**
```bash
curl -X POST https://api.vspnest.com/api/v1/super-admin/properties \
  -H "Authorization: Bearer <token>" \
  -F "name=Sunset Palm Beach Resort" \
  -F "tagline=Where the ocean meets tranquility" \
  -F "description=A serene beachfront resort with panoramic ocean views." \
  -F "location=Palolem Beach, Goa" \
  -F "state=Goa" \
  -F "city=South Goa" \
  -F "basePriceWeekday=18000" \
  -F "basePriceWeekend=25000" \
  -F "extraGuestCharge=3000" \
  -F "cleaningFee=2000" \
  -F "image=@./sunset-pool.jpg" \
  -F "gallery=@./sunset-bedroom.jpg" \
  -F "gallery=@./sunset-garden.jpg" \
  -F 'amenities=[{"icon":"pool","label":"Beachfront Infinity Pool","category":"premium"},{"icon":"wifi","label":"High-Speed WiFi","category":"essential"}]' \
  -F 'rules=["Check-in: 2:00 PM | Check-out: 11:00 AM","No loud music after 10:00 PM","Pets not allowed","Max occupancy: 8 guests"]'
```

**Response (201):**
```json
{
  "success": true,
  "message": "Resort 'Sunset Palm Beach Resort' has been onboarded successfully",
  "data": {
    "id": "PROP-005",
    "name": "Sunset Palm Beach Resort",
    "image": "https://api.vspnest.com/uploads/properties/PROP-005/ab3f2c91-sunset-pool.jpg",
    "gallery": [
      "https://api.vspnest.com/uploads/properties/PROP-005/cd4e3a72-sunset-bedroom.jpg",
      "https://api.vspnest.com/uploads/properties/PROP-005/ef5b4c83-sunset-garden.jpg"
    ],
    "createdAt": "2026-07-04T10:30:00Z"
  }
}
```

### GET /api/v1/super-admin/properties/{id}

**Request:** `/api/v1/super-admin/properties/PROP-001`

**Response (200):** (same structure as single item in GET /properties)

### PUT /api/v1/super-admin/properties/{id}

**Content-Type:** `multipart/form-data`

| Field | Type | Description |
|-------|------|-------------|
| `name` | string | Resort name (partial update) |
| `tagline` | string | Short tagline |
| `description` | string | Full description |
| `location` | string | Location string |
| `state` | string | State/region |
| `city` | string | City |
| `basePriceWeekday` | number | Weekday base price |
| `basePriceWeekend` | number | Weekend base price |
| `extraGuestCharge` | number | Per extra guest charge |
| `cleaningFee` | number | Cleaning fee |
| `image` | file | New primary cover image (replaces existing) |
| `gallery` | file[] | Additional gallery images (appended) |
| `galleryUrlsToRemove` | string | JSON array of URLs to remove from gallery |
| `amenities` | string | JSON string of full amenities array (replaces all) |
| `rules` | string | JSON string array (replaces all) |

**Example cURL:**
```bash
curl -X PUT https://api.vspnest.com/api/v1/super-admin/properties/PROP-001 \
  -H "Authorization: Bearer <token>" \
  -F "basePriceWeekday=16000" \
  -F "basePriceWeekend=24000" \
  -F "tagline=Updated tagline for the season" \
  -F "image=@./new-cover.jpg" \
  -F 'amenities=[{"icon":"pool","label":"Private Infinity Pool","category":"premium"},{"icon":"restaurant","label":"Personal Chef","category":"dining"},{"icon":"spa","label":"In-room Spa","category":"wellness"},{"icon":"home_theater","label":"Home Theatre","category":"entertainment"}]'
```

**Response (200):**
```json
{
  "success": true,
  "message": "Property PROP-001 updated successfully",
  "data": {
    "id": "PROP-001",
    "name": "Whispering Valleys Sanctuary",
    "image": "https://api.vspnest.com/uploads/properties/PROP-001/new-cover.jpg",
    "updatedAt": "2026-07-04T11:00:00Z"
  }
}
```

### DELETE /api/v1/super-admin/properties/{id}

**Request:** `/api/v1/super-admin/properties/PROP-005`

**Response (200):**
```json
{
  "success": true,
  "message": "Property PROP-005 has been permanently deleted. All associated images have been removed from storage."
}
```

---

## 5. User Management

### GET /api/v1/super-admin/users

**Query params:** `?role=admin&status=active&search=ananya`

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "USR-SA-001",
      "name": "Super Admin",
      "email": "superadmin@vspnest.com",
      "role": "superAdmin",
      "roleLabel": "Super Administrator",
      "status": "active",
      "phone": "+91 98765 43210",
      "avatar": null,
      "createdAt": "2026-01-01T00:00:00Z",
      "lastLoginAt": "2026-07-03T08:12:00Z",
      "createdBy": null
    },
    {
      "id": "USR-ADM-001",
      "name": "Vikram Rathore",
      "email": "admin@vspnest.com",
      "role": "admin",
      "roleLabel": "Administrator",
      "status": "active",
      "phone": "+91 99887 76655",
      "avatar": null,
      "createdAt": "2026-01-15T10:00:00Z",
      "lastLoginAt": "2026-07-02T09:30:00Z",
      "createdBy": "USR-SA-001"
    },
    {
      "id": "USR-STAFF-001",
      "name": "Rohit Verma",
      "email": "housekeeping.staff@vspnest.com",
      "role": "staff",
      "roleLabel": "Staff",
      "status": "active",
      "createdAt": "2026-02-01T10:00:00Z",
      "createdBy": "USR-SA-001"
    },
    {
      "id": "USR-ACC-001",
      "name": "Priya Mehta",
      "email": "accountant@vspnest.com",
      "role": "accountant",
      "roleLabel": "Accountant",
      "status": "active",
      "createdAt": "2026-02-01T10:00:00Z",
      "createdBy": "USR-SA-001"
    },
    {
      "id": "USR-CUST-001",
      "name": "Ananya Sharma",
      "email": "ananya@rediff.com",
      "role": "customer",
      "roleLabel": "Customer Suite",
      "status": "active",
      "createdAt": "2026-03-10T14:00:00Z",
      "createdBy": "USR-SA-001"
    }
  ],
  "pagination": {
    "total": 12,
    "page": 1,
    "pageSize": 20,
    "totalPages": 1
  }
}
```

### POST /api/v1/super-admin/users

**Content-Type:** `multipart/form-data`

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | yes | Full name |
| `email` | string | yes | Email address |
| `password` | string | yes | Password (min 6 chars) |
| `phone` | string | no | Phone number |
| `role` | string | yes | One of: `superAdmin`, `admin`, `staff`, `accountant`, `customer` |
| `status` | string | no | `active` (default) or `inactive` |
| `avatar` | file | no | Profile avatar image (jpg/png, max 2MB) |

**Example cURL:**
```bash
curl -X POST https://api.vspnest.com/api/v1/super-admin/users \
  -H "Authorization: Bearer <token>" \
  -F "name=Kavya Nair" \
  -F "email=kavya@vspnest.com" \
  -F "password=securePass123" \
  -F "phone=+91 88776 65544" \
  -F "role=admin" \
  -F "status=active" \
  -F "avatar=@./kavya-profile.jpg"
```

**Response (201):**
```json
{
  "success": true,
  "message": "User 'Kavya Nair' created successfully as Administrator",
  "data": {
    "id": "USR-ADM-002",
    "name": "Kavya Nair",
    "email": "kavya@vspnest.com",
    "role": "admin",
    "status": "active",
    "createdAt": "2026-07-04T12:00:00Z",
    "createdBy": "USR-SA-001"
  }
}
```

**Validation Error (422):**
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Validation failed.",
    "details": [
      { "field": "email", "message": "A user with this email already exists." },
      { "field": "password", "message": "Password must be at least 6 characters." }
    ]
  }
}
```

### GET /api/v1/super-admin/users/{id}

**Request:** `/api/v1/super-admin/users/USR-ADM-001`

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": "USR-ADM-001",
    "name": "Vikram Rathore",
    "email": "admin@vspnest.com",
    "phone": "+91 99887 76655",
    "role": "admin",
    "roleLabel": "Administrator",
    "status": "active",
    "avatar": null,
    "createdAt": "2026-01-15T10:00:00Z",
    "updatedAt": "2026-06-28T16:00:00Z",
    "lastLoginAt": "2026-07-02T09:30:00Z",
    "createdBy": "USR-SA-001",
    "updatedBy": "USR-SA-001",
    "auditLog": [
      { "action": "login", "timestamp": "2026-07-02T09:30:00Z" },
      { "action": "update", "target": "pricing", "timestamp": "2026-07-01T14:00:00Z" },
      { "action": "create", "target": "booking", "timestamp": "2026-06-30T11:00:00Z" }
    ]
  }
}
```

### PUT /api/v1/super-admin/users/{id}

**Content-Type:** `multipart/form-data`

| Field | Type | Description |
|-------|------|-------------|
| `name` | string | Full name |
| `phone` | string | Phone number |
| `status` | string | `active` or `inactive` |
| `role` | string | One of: `superAdmin`, `admin`, `staff`, `accountant`, `customer` |
| `avatar` | file | New profile avatar (replaces existing) |

**Example cURL:**
```bash
curl -X PUT https://api.vspnest.com/api/v1/super-admin/users/USR-ADM-002 \
  -H "Authorization: Bearer <token>" \
  -F "name=Kavya Nair Menon" \
  -F "phone=+91 99887 65544" \
  -F "status=active" \
  -F "role=admin" \
  -F "avatar=@./new-avatar.jpg"
```

**Response (200):**
```json
{
  "success": true,
  "message": "User USR-ADM-002 updated successfully",
  "data": {
    "id": "USR-ADM-002",
    "name": "Kavya Nair Menon",
    "avatar": "https://api.vspnest.com/uploads/avatars/USR-ADM-002/new-avatar.jpg",
    "updatedAt": "2026-07-04T12:30:00Z"
  }
}
```

### DELETE /api/v1/super-admin/users/{id}

**Request:** `/api/v1/super-admin/users/USR-ADM-002`

**Response (200):**
```json
{
  "success": true,
  "message": "User USR-ADM-002 (Kavya Nair Menon) has been deactivated and archived"
}
```

**Error — Cannot delete last Super Admin (400):**
```json
{
  "success": false,
  "error": {
    "code": "LAST_SUPER_ADMIN",
    "message": "Cannot delete the last remaining Super Admin account."
  }
}
```

---

## 6. Approval Workflow

### GET /api/v1/super-admin/approvals

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "APPR-001",
      "resourceType": "booking",
      "resourceId": "BKG-042",
      "action": "cancel_refund",
      "payload": {
        "bookingId": "BKG-042",
        "refundAmount": 35000.00,
        "refundPercent": 65,
        "reason": "Guest medical emergency",
        "requestedBy": "USR-ADM-001"
      },
      "requestedBy": "USR-ADM-001",
      "requestedByName": "Vikram Rathore",
      "approvedBy": null,
      "status": "pending",
      "createdAt": "2026-07-03T18:30:00Z",
      "resolvedAt": null,
      "rejectionReason": null
    },
    {
      "id": "APPR-002",
      "resourceType": "coupon",
      "resourceId": "CPN-006",
      "action": "delete",
      "payload": {
        "couponCode": "FESTIVE50",
        "reason": "Campaign ended",
        "requestedBy": "USR-ADM-001"
      },
      "requestedBy": "USR-ADM-001",
      "requestedByName": "Vikram Rathore",
      "approvedBy": "USR-SA-001",
      "approvedByName": "Super Admin",
      "status": "approved",
      "createdAt": "2026-07-02T10:00:00Z",
      "resolvedAt": "2026-07-02T14:00:00Z",
      "rejectionReason": null
    },
    {
      "id": "APPR-003",
      "resourceType": "pricing",
      "resourceId": "RULE-003",
      "action": "update",
      "payload": {
        "ruleName": "Peak Winter Season",
        "priceDeltaPercent": 35,
        "reason": "High demand forecast",
        "requestedBy": "USR-ADM-001"
      },
      "requestedBy": "USR-ADM-001",
      "requestedByName": "Vikram Rathore",
      "approvedBy": "USR-SA-001",
      "approvedByName": "Super Admin",
      "status": "rejected",
      "createdAt": "2026-07-01T09:00:00Z",
      "resolvedAt": "2026-07-01T16:00:00Z",
      "rejectionReason": "35% delta exceeds policy; resubmit with max 20%"
    }
  ]
}
```

### GET /api/v1/super-admin/approvals/pending

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "APPR-001",
      "resourceType": "booking",
      "resourceId": "BKG-042",
      "action": "cancel_refund",
      "payload": {
        "bookingId": "BKG-042",
        "guestName": "Rahul Singh",
        "refundAmount": 35000.00,
        "refundPercent": 65,
        "reason": "Guest medical emergency"
      },
      "requestedBy": "USR-ADM-001",
      "requestedByName": "Vikram Rathore",
      "status": "pending",
      "createdAt": "2026-07-03T18:30:00Z"
    }
  ],
  "totalPending": 1
}
```

### PUT /api/v1/super-admin/approvals/{id}/resolve

**Request:** `/api/v1/super-admin/approvals/APPR-001/resolve`
```json
{
  "status": "approved",
  "rejectionReason": null
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Approval request APPR-001 has been approved. Refund of INR 35,000 for booking BKG-042 will be processed.",
  "data": {
    "id": "APPR-001",
    "status": "approved",
    "resolvedAt": "2026-07-04T13:00:00Z",
    "approvedBy": "USR-SA-001"
  }
}
```

---

## 7. Roles & Permissions (RBAC)

### GET /api/v1/super-admin/roles

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "ROLE-SUPER_ADMIN",
      "displayName": "Super Administrator",
      "description": "Full system access including RBAC, users, and all properties",
      "isSystem": true,
      "permissions": [
        { "resource": "bookings", "actions": ["create", "read", "update", "delete", "approve"] },
        { "resource": "calendar", "actions": ["create", "read", "update", "delete"] },
        { "resource": "coupons", "actions": ["create", "read", "update", "delete"] },
        { "resource": "pricing", "actions": ["create", "read", "update", "delete"] },
        { "resource": "rooms", "actions": ["create", "read", "update", "delete"] },
        { "resource": "ota", "actions": ["create", "read", "update", "delete"] },
        { "resource": "notifications", "actions": ["create", "read", "update", "delete"] },
        { "resource": "properties", "actions": ["create", "read", "update", "delete"] },
        { "resource": "users", "actions": ["create", "read", "update", "delete"] },
        { "resource": "roles", "actions": ["create", "read", "update", "delete"] },
        { "resource": "approvals", "actions": ["approve"] },
        { "resource": "reports", "actions": ["read"] }
      ]
    },
    {
      "id": "ROLE-ADMIN",
      "displayName": "Administrator",
      "description": "Manage bookings, pricing, coupons, OTA, and property operations",
      "isSystem": false,
      "permissions": [
        { "resource": "bookings", "actions": ["create", "read", "update", "delete", "approve"] },
        { "resource": "calendar", "actions": ["create", "read", "update", "delete"] },
        { "resource": "coupons", "actions": ["create", "read", "update", "delete"] },
        { "resource": "pricing", "actions": ["create", "read", "update", "delete"] },
        { "resource": "rooms", "actions": ["update"] },
        { "resource": "ota", "actions": ["create", "read", "update"] },
        { "resource": "notifications", "actions": ["create", "read", "update", "delete"] },
        { "resource": "properties", "actions": ["read"] },
        { "resource": "users", "actions": [] },
        { "resource": "roles", "actions": [] },
        { "resource": "approvals", "actions": ["approve"] },
        { "resource": "reports", "actions": ["read"] }
      ]
    },
    {
      "id": "ROLE-STAFF",
      "displayName": "Staff",
      "description": "Housekeeping and room operations",
      "isSystem": false,
      "permissions": [
        { "resource": "bookings", "actions": ["read"] },
        { "resource": "rooms", "actions": ["read", "update"] },
        { "resource": "notifications", "actions": ["read"] }
      ]
    },
    {
      "id": "ROLE-ACCOUNTANT",
      "displayName": "Accountant",
      "description": "Financial operations, refunds, and reports",
      "isSystem": false,
      "permissions": [
        { "resource": "bookings", "actions": ["read"] },
        { "resource": "notifications", "actions": ["read"] },
        { "resource": "approvals", "actions": [] },
        { "resource": "reports", "actions": ["read"] }
      ]
    },
    {
      "id": "ROLE-CUSTOMER",
      "displayName": "Customer Suite",
      "description": "Book stays, view invoices, request cancellations",
      "isSystem": false,
      "permissions": [
        { "resource": "bookings", "actions": ["create", "read"] },
        { "resource": "calendar", "actions": ["read"] },
        { "resource": "coupons", "actions": ["read"] },
        { "resource": "pricing", "actions": ["read"] },
        { "resource": "properties", "actions": ["read"] },
        { "resource": "notifications", "actions": ["read"] },
        { "resource": "reports", "actions": ["read"] }
      ]
    }
  ]
}
```

### GET /api/v1/super-admin/roles/{id}

**Request:** `/api/v1/super-admin/roles/ROLE-ADMIN`

**Response (200):** (single role object from above array)

### PUT /api/v1/super-admin/roles/{id}

**Request:** `/api/v1/super-admin/roles/ROLE-STAFF`
```json
{
  "displayName": "Staff (Housekeeping)",
  "description": "Housekeeping, room operations, and limited booking view",
  "permissions": [
    { "resource": "bookings", "actions": ["read"] },
    { "resource": "rooms", "actions": ["read", "update"] },
    { "resource": "notifications", "actions": ["read"] },
    { "resource": "calendar", "actions": ["read"] }
  ]
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Role ROLE-STAFF updated successfully",
  "data": {
    "id": "ROLE-STAFF",
    "displayName": "Staff (Housekeeping)",
    "updatedAt": "2026-07-04T14:00:00Z",
    "updatedBy": "USR-SA-001"
  }
}
```

**Error — Cannot edit system role (403):**
```json
{
  "success": false,
  "error": {
    "code": "SYSTEM_ROLE_LOCKED",
    "message": "Super Administrator role is a system role and cannot be modified."
  }
}
```

---

## 8. Audit Logs

### GET /api/v1/super-admin/audit-logs

**Query params:** `?userId=USR-ADM-001&action=update&from=2026-07-01&to=2026-07-04&page=1&pageSize=20`

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "AUD-001",
      "userId": "USR-SA-001",
      "userName": "Super Admin",
      "userRole": "superAdmin",
      "action": "create",
      "targetType": "user",
      "targetId": "USR-ADM-002",
      "details": "Created admin user 'Kavya Nair' (kavya@vspnest.com)",
      "timestamp": "2026-07-04T12:00:00Z"
    },
    {
      "id": "AUD-002",
      "userId": "USR-SA-001",
      "userName": "Super Admin",
      "userRole": "superAdmin",
      "action": "login",
      "targetType": "session",
      "targetId": "SES-ABC789",
      "details": "Successful login from IP 203.0.113.42",
      "timestamp": "2026-07-04T08:00:00Z"
    },
    {
      "id": "AUD-003",
      "userId": "USR-ADM-001",
      "userName": "Vikram Rathore",
      "userRole": "admin",
      "action": "update",
      "targetType": "booking",
      "targetId": "BKG-042",
      "details": "Initiated cancellation/refund request for INR 35,000",
      "timestamp": "2026-07-03T18:30:00Z"
    },
    {
      "id": "AUD-004",
      "userId": "USR-SA-001",
      "userName": "Super Admin",
      "userRole": "superAdmin",
      "action": "approve",
      "targetType": "approval",
      "targetId": "APPR-001",
      "details": "Approved refund request for booking BKG-042",
      "timestamp": "2026-07-04T13:00:00Z"
    }
  ],
  "pagination": {
    "total": 256,
    "page": 1,
    "pageSize": 20,
    "totalPages": 13
  }
}
```

---

## Error Response Format (all APIs)

**401 Unauthorized:**
```json
{
  "success": false,
  "error": { "code": "AUTH_TOKEN_EXPIRED", "message": "Access token has expired. Please refresh." }
}
```

**403 Forbidden:**
```json
{
  "success": false,
  "error": { "code": "FORBIDDEN", "message": "Insufficient permissions for this action." }
}
```

**404 Not Found:**
```json
{
  "success": false,
  "error": { "code": "NOT_FOUND", "message": "Resource with ID PROP-099 not found." }
}
```

**500 Server Error:**
```json
{
  "success": false,
  "error": { "code": "INTERNAL_ERROR", "message": "An unexpected error occurred. Please try again." }
}
```
