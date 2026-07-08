# VSP Nest — Admin API Spec (26 APIs)

Admin manages a single property's day-to-day: analytics, calendar blocking, bookings, pricing, coupons, OTA sync, and housekeeping.

> Default credentials: `admin@vspnest.com` / `admin123`

**Base URL:** `https://api.vspnest.com/api/v1/admin`
**Auth:** All endpoints require `Authorization: Bearer <token>` with admin role.
**Image Upload:** Multipart/form-data used for any image fields.

---

## 1. Auth (shared — same as all roles)

### POST /api/v1/auth/login

**Request:**
```json
{ "email": "admin@vspnest.com", "password": "admin123" }
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
      "id": 2,
      "name": "Vikram Rathore",
      "email": "admin@vspnest.com",
      "phone": "+91 99887 76655",
      "role": "ADMIN",
      "roleDisplayName": "Admin",
      "profileImageUrl": null,
      "active": true,
      "permissions": [
        { "resource": "booking", "actions": ["create", "read", "update", "delete", "cancel"] },
        { "resource": "property", "actions": ["create", "read", "update"] },
        { "resource": "invoice", "actions": ["read", "approve"] },
        { "resource": "payment", "actions": ["read", "refund"] },
        { "resource": "user", "actions": ["read"] },
        { "resource": "pricing", "actions": ["create", "read", "update"] },
        { "resource": "housekeeping", "actions": ["read", "update"] },
        { "resource": "concierge", "actions": ["read", "update"] },
        { "resource": "coupon", "actions": ["create", "read", "update", "delete"] },
        { "resource": "ota", "actions": ["read", "update"] },
        { "resource": "analytics", "actions": ["read"] },
        { "resource": "calendar", "actions": ["create", "read", "update", "delete"] },
        { "resource": "settings", "actions": ["read", "update"] },
        { "resource": "notification", "actions": ["read"] },
        { "resource": "approval", "actions": ["read", "approve"] }
      ]
    }
  }
}
```

### GET /api/v1/auth/me

**Headers:** `Authorization: Bearer <token>`

**Response (200):** Same `user` object as login (without `accessToken`, `refreshToken`, `tokenType`).

### POST /api/v1/auth/refresh

**Request:** `{ "refreshToken": "eyJhbG..." }` → **Response (200):** Full `{accessToken, refreshToken, tokenType, user}` (same shape as login).

### POST /api/v1/auth/logout

**Response (200):** `{ "success": true }`

---

## 2. Properties (Header Ribbon — Property Selector)

Admin can switch between multiple properties via the dropdown in the header ribbon.

### GET /api/v1/admin/properties

Returns list of properties assigned to this admin (read-only access).

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "PROP-001",
      "name": "Whispering Valleys Sanctuary",
      "tagline": "Escape to the lap of luxury amidst rolling hills",
      "location": "Coorg, Karnataka",
      "image": "https://images.unsplash.com/photo-1580587771525-78b9dba3b914?w=800",
      "isActive": true,
      "currentProperty": true
    },
    {
      "id": "PROP-002",
      "name": "Azure Sands Coastal Villa",
      "location": "Palolem, Goa",
      "image": "https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=800",
      "isActive": true,
      "currentProperty": false
    },
    {
      "id": "PROP-003",
      "name": "Cloud-kissed Mountain Manor",
      "location": "Manali, Himachal Pradesh",
      "image": "https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?w=800",
      "isActive": true,
      "currentProperty": false
    },
    {
      "id": "PROP-004",
      "name": "Forest Glade Wilderness Retreat",
      "location": "Wayanad, Kerala",
      "image": "https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=800",
      "isActive": true,
      "currentProperty": false
    }
  ]
}
```

### PUT /api/v1/admin/properties/{id}/activate

Switch the active property context.

**Response (200):**
```json
{
  "success": true,
  "message": "Now managing Whispering Valleys Sanctuary",
  "data": { "propertyId": "PROP-001", "activatedAt": "2026-07-04T10:00:00Z" }
}
```

---

## 3. Analytics Board (Tab 1: `kpis`)

KPI cards + sales chart + metric insights panel (all computed from bookings, blocks, coupons, OTA).

### GET /api/v1/admin/analytics/kpis

**Query params:** `?propertyId=PROP-001&from=2026-06-01&to=2026-07-31`

**Response (200):**
```json
{
  "success": true,
  "data": {
    "grossValuation": 4850000.00,
    "advanceCollected": 1620000.00,
    "occupancyRate": 72.5,
    "totalBookedNights": 1240,
    "totalNightsInScope": 61,
    "activeBookingsCount": 42,
    "cancelledBookingsCount": 3,
    "couponUsageCount": 15,
    "activeBlocksCount": 4,
    "currency": "INR"
  }
}
```

### GET /api/v1/admin/analytics/sales-chart

**Query params:** `?propertyId=PROP-001&range=6weeks`

**Response (200):**
```json
{
  "success": true,
  "data": {
    "labels": ["Wk 1 (Jun)", "Wk 2 (Jun)", "Wk 3 (Jun)", "Wk 4 (Jun)", "Wk 1 (Jul)", "Wk 2 (Jul)"],
    "values": [485000, 1697500, 2667500, 3880000, 4607500, 4850000],
    "peakWeek": 4,
    "peakValue": 1212500,
    "peakLabel": "Peak Week: ₹1,212,500 INR"
  }
}
```

### GET /api/v1/admin/analytics/metrics-insights

**Response (200):**
```json
{
  "success": true,
  "data": {
    "occupancyRate": 72.5,
    "couponsRedeemed": 15,
    "activeBlocks": 4,
    "otaChannels": {
      "total": 5,
      "synced": 4,
      "channels": [
        { "id": "OTA-001", "name": "Airbnb", "status": "success" },
        { "id": "OTA-002", "name": "Booking.com", "status": "success" },
        { "id": "OTA-003", "name": "Agoda", "status": "success" },
        { "id": "OTA-004", "name": "MakeMyTrip", "status": "success" },
        { "id": "OTA-005", "name": "Goibibo", "status": "error" }
      ]
    }
  }
}
```

---

## 4. Calendar Blocking (Tab 2: `blocks`)

Create and manage date blocks (maintenance, owner stay, private event, holiday) with overlap detection.

### GET /api/v1/admin/calendar-blocks

**Query params:** `?propertyId=PROP-001`

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "BLOCK-001",
      "propertyId": "PROP-001",
      "startDate": "2026-06-22",
      "endDate": "2026-06-24",
      "reason": "maintenance",
      "notes": "Annual pool filtration system upgrade. Villa will be inaccessible.",
      "blockedBy": "Vikram Rathore",
      "blockedById": "USR-ADM-001",
      "createdAt": "2026-06-20T14:00:00Z"
    },
    {
      "id": "BLOCK-002",
      "propertyId": "PROP-001",
      "startDate": "2026-07-10",
      "endDate": "2026-07-15",
      "reason": "owner_stay",
      "notes": "Owner's family vacation - entire property reserved.",
      "blockedBy": "Vikram Rathore",
      "blockedById": "USR-ADM-001",
      "createdAt": "2026-07-01T10:00:00Z"
    }
  ]
}
```

### POST /api/v1/admin/calendar-blocks

**Request:**
```json
{
  "propertyId": "PROP-001",
  "startDate": "2026-08-05",
  "endDate": "2026-08-07",
  "reason": "private_event",
  "notes": "Wedding event booking - resort bought out for private function."
}
```

**Validation rules:**
- End date cannot be before start date
- No overlap with existing bookings (non-cancelled)
- No overlap with existing calendar blocks

**Response (201):**
```json
{
  "success": true,
  "message": "Calendar date block placed successfully! Dynamic availability locked.",
  "data": {
    "id": "BLOCK-003",
    "startDate": "2026-08-05",
    "endDate": "2026-08-07",
    "reason": "private_event",
    "notes": "Wedding event booking - resort bought out for private function.",
    "blockedBy": "Vikram Rathore",
    "createdAt": "2026-07-04T11:00:00Z"
  }
}
```

**Error — Overlap conflict (409):**
```json
{
  "success": false,
  "error": {
    "code": "OVERLAP_CONFLICT",
    "message": "Overlap Alert: Booking BKG-042 (Rahul Singh) is already scheduled on these dates.",
    "conflictingResourceId": "BKG-042",
    "conflictingResourceType": "booking"
  }
}
```

### DELETE /api/v1/admin/calendar-blocks/{id}

**Response (200):**
```json
{
  "success": true,
  "message": "Exclusion restored. Inventory unlocked from 2026-06-22 to 2026-06-24.",
  "data": { "id": "BLOCK-001", "removedAt": "2026-07-04T11:30:00Z" }
}
```

---

## 5. Booking Matrix (Tab 3: `orders`)

Filterable table of bookings with source/status/search filters and actions (authorize payment, revoke, view notes).

### GET /api/v1/admin/bookings

**Query params:** `?propertyId=PROP-001&source=all&status=all&search=&page=1&pageSize=20`

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "BKG-042",
      "propertyId": "PROP-001",
      "propertyName": "Whispering Valleys Sanctuary",
      "resortName": "Whispering Valleys Sanctuary",
      "guestName": "Rahul Singh",
      "guestEmail": "rahul.singh@gmail.com",
      "guestPhone": "+91 98765 43210",
      "startDate": "2026-07-15",
      "endDate": "2026-07-18",
      "guestsCount": 4,
      "nightsCount": 3,
      "source": "direct",
      "status": "confirmed",
      "paymentStatus": "paid",
      "baseAmount": 66000.00,
      "extraGuestAmount": 5000.00,
      "cleaningAmount": 1500.00,
      "discountAmount": 0.00,
      "taxAmount": 13050.00,
      "totalAmount": 85550.00,
      "advancePaidAmount": 85550.00,
      "balanceAmount": 0.00,
      "couponApplied": null,
      "createdAt": "2026-07-10T08:00:00Z",
      "housekeepingNotes": null,
      "cancellationReason": null,
      "refundAmount": null
    },
    {
      "id": "BKG-043",
      "propertyId": "PROP-001",
      "propertyName": "Whispering Valleys Sanctuary",
      "guestName": "Priya Sharma",
      "guestEmail": "priya.sharma@yahoo.com",
      "guestPhone": "+91 87654 32109",
      "startDate": "2026-07-20",
      "endDate": "2026-07-22",
      "guestsCount": 2,
      "nightsCount": 2,
      "source": "airbnb",
      "status": "pendingPayment",
      "paymentStatus": "pending",
      "baseAmount": 44000.00,
      "extraGuestAmount": 0.00,
      "cleaningAmount": 1500.00,
      "discountAmount": 0.00,
      "taxAmount": 8190.00,
      "totalAmount": 53690.00,
      "advancePaidAmount": 16107.00,
      "balanceAmount": 37583.00,
      "couponApplied": null,
      "createdAt": "2026-07-12T14:00:00Z",
      "housekeepingNotes": "Guest requested extra pillows and late check-out",
      "cancellationReason": null,
      "refundAmount": null
    }
  ],
  "pagination": {
    "total": 45,
    "page": 1,
    "pageSize": 20,
    "totalPages": 3
  }
}
```

### GET /api/v1/admin/bookings/{id}

**Response (200):** Single booking object (same structure as array item above).

### PUT /api/v1/admin/bookings/{id}/status

Update booking status to authorize payment or revoke/cancel.

**Request (authorize payment — set status to CONFIRMED):**
```json
{
  "status": "CONFIRMED"
}
```

**Request (revoke/cancel booking — set status to CANCELLED):**
```json
{
  "status": "CANCELLED",
  "reason": "Guest requested cancellation due to travel change"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Booking BKG-043 status updated to CONFIRMED",
  "data": {
    "id": "BKG-043",
    "status": "CONFIRMED",
    "updatedAt": "2026-07-04T12:00:00Z"
  }
}
```

### GET /api/v1/admin/bookings/{id}/notes

Retrieve housekeeping/guest notes for a booking.

**Response (200):**
```json
{
  "success": true,
  "data": {
    "bookingId": "BKG-043",
    "housekeepingNotes": "Guest requested extra pillows and late check-out",
    "guestSpecialRequests": null,
    "lastUpdatedBy": "USR-STAFF-001",
    "lastUpdatedAt": "2026-07-12T16:00:00Z"
  }
}
```

---

## 6. Tariffs & Seasonality (Tab 4: `tariffs`)

Edit base prices (weekday, weekend) and manage seasonal pricing rules. Base pricing is stored as the first active pricing rule; the frontend reads/updates it via the pricing rules endpoints.

### GET /api/v1/admin/pricing/base

Delegates to `GET /api/v1/admin/pricing/rules` and returns the first rule's weekday/weekend prices.

**Query params:** `?propertyId=PROP-001`

**Response (200):**
```json
{
  "success": true,
  "data": {
    "basePriceWeekday": 15000.00,
    "basePriceWeekend": 22000.00
  }
}
```

### PUT /api/v1/admin/pricing/rules/{id}

Update the first pricing rule (used as base pricing). If no rules exist, creates one via `POST /api/v1/admin/pricing/rules`.

**Request:**
```json
{
  "weekdayPrice": 16000.00,
  "weekendPrice": 24000.00
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Pricing rule RULE-001 updated successfully",
  "data": {
    "id": "RULE-001",
    "name": "Peak Summer Escape",
    "weekdayPrice": 16000.00,
    "weekendPrice": 24000.00,
    "isActive": true
  }
}
```

### GET /api/v1/admin/pricing/seasonal-rules

**Query params:** `?propertyId=PROP-001`

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "RULE-001",
      "propertyId": "PROP-001",
      "name": "Peak Summer Escape",
      "startDate": "04-01",
      "endDate": "06-15",
      "weekdayPrice": 18000.00,
      "weekendPrice": 26000.00,
      "multiplier": 1.2,
      "isActive": true
    },
    {
      "id": "RULE-002",
      "propertyId": "PROP-001",
      "name": "Monsoon Retreat",
      "startDate": "07-01",
      "endDate": "08-31",
      "weekdayPrice": 12000.00,
      "weekendPrice": 18000.00,
      "multiplier": 0.8,
      "isActive": true
    },
    {
      "id": "RULE-003",
      "propertyId": "PROP-001",
      "name": "Festive Season Premium",
      "startDate": "12-15",
      "endDate": "01-15",
      "weekdayPrice": 25000.00,
      "weekendPrice": 35000.00,
      "multiplier": 1.6,
      "isActive": false
    }
  ]
}
```

### POST /api/v1/admin/pricing/seasonal-rules

**Request:**
```json
{
  "propertyId": "PROP-001",
  "name": "Autumn Leaf Special",
  "startDate": "09-15",
  "endDate": "11-30",
  "weekdayPrice": 16000.00,
  "weekendPrice": 22000.00,
  "multiplier": 1.1,
  "isActive": true
}
```

**Response (201):**
```json
{
  "success": true,
  "message": "Seasonal pricing rule 'Autumn Leaf Special' created.",
  "data": {
    "id": "RULE-004",
    "name": "Autumn Leaf Special",
    "startDate": "09-15",
    "endDate": "11-30"
  }
}
```

### PUT /api/v1/admin/pricing/seasonal-rules/{id}/toggle

Toggle a seasonal rule active/inactive.

**Request:**
```json
{ "isActive": false }
```

**Response (200):**
```json
{
  "success": true,
  "message": "Seasonal rule 'Festive Season Premium' has been deactivated.",
  "data": { "id": "RULE-003", "isActive": false }
}
```

---

## 7. Coupons Editor (Tab 5: `coupons`)

Create and manage promotional coupon codes.

### GET /api/v1/admin/coupons

**Query params:** `?propertyId=PROP-001`

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "CPN-001",
      "propertyId": "PROP-001",
      "code": "MONSOON20",
      "type": "percentage",
      "value": 20,
      "expiryDate": "2026-10-31",
      "usageLimit": 50,
      "usageCount": 12,
      "minBookingValue": 25000.00,
      "description": "20% off on bookings above ₹25,000",
      "isActive": true,
      "createdAt": "2026-06-01T10:00:00Z"
    },
    {
      "id": "CPN-002",
      "propertyId": "PROP-001",
      "code": "FLAT5000",
      "type": "fixed",
      "value": 5000,
      "expiryDate": "2026-09-30",
      "usageLimit": 25,
      "usageCount": 3,
      "minBookingValue": 50000.00,
      "description": "₹5,000 off on bookings above ₹50,000",
      "isActive": true,
      "createdAt": "2026-06-15T10:00:00Z"
    },
    {
      "id": "CPN-003",
      "propertyId": "PROP-001",
      "code": "WELCOME10",
      "type": "percentage",
      "value": 10,
      "expiryDate": "2026-12-31",
      "usageLimit": 100,
      "usageCount": 0,
      "minBookingValue": 15000.00,
      "description": "10% off for first-time guests",
      "isActive": false,
      "createdAt": "2026-07-01T10:00:00Z"
    }
  ]
}
```

### POST /api/v1/admin/coupons

**Request:**
```json
{
  "propertyId": "PROP-001",
  "code": "FESTIVE50",
  "type": "percentage",
  "value": 15,
  "expiryDate": "2026-11-30",
  "usageLimit": 40,
  "minBookingValue": 30000.00,
  "description": "15% off festive season bookings"
}
```

**Response (201):**
```json
{
  "success": true,
  "message": "Coupon FESTIVE50 added to registry successfully!",
  "data": {
    "id": "CPN-004",
    "code": "FESTIVE50",
    "type": "percentage",
    "value": 15,
    "isActive": true,
    "usageCount": 0,
    "createdAt": "2026-07-04T14:00:00Z"
  }
}
```

**Error — Duplicate code (409):**
```json
{
  "success": false,
  "error": {
    "code": "DUPLICATE_COUPON_CODE",
    "message": "Coupon code 'FESTIVE50' already exists. Please use a different code."
  }
}
```

### PUT /api/v1/admin/coupons/{id}/toggle

Enable/disable a coupon.

**Request:**
```json
{ "isActive": true }
```

**Response (200):**
```json
{
  "success": true,
  "message": "Coupon WELCOME10 has been activated.",
  "data": { "id": "CPN-003", "code": "WELCOME10", "isActive": true }
}
```

---

## 8. OTA Synergy (Tab 6: `ota`)

Manage OTA channel connections, sync status, toggle sync, and trigger manual sync.

### GET /api/v1/admin/ota

**Query params:** `?propertyId=PROP-001`

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "OTA-001",
      "propertyId": "PROP-001",
      "channelName": "Airbnb",
      "logo": "https://images.unsplash.com/photo-1566073771259-6a8506099945?w=100",
      "lastSyncTime": "2026-07-04T08:00:00Z",
      "status": "success",
      "conflictsCount": 0,
      "syncEnabled": true
    },
    {
      "id": "OTA-002",
      "propertyId": "PROP-001",
      "channelName": "Booking.com",
      "logo": "https://images.unsplash.com/photo-1566073771259-6a8506099945?w=100",
      "lastSyncTime": "2026-07-04T08:00:00Z",
      "status": "success",
      "conflictsCount": 0,
      "syncEnabled": true
    },
    {
      "id": "OTA-003",
      "propertyId": "PROP-001",
      "channelName": "Agoda",
      "logo": "https://images.unsplash.com/photo-1566073771259-6a8506099945?w=100",
      "lastSyncTime": "2026-07-04T07:30:00Z",
      "status": "success",
      "conflictsCount": 0,
      "syncEnabled": true
    },
    {
      "id": "OTA-004",
      "propertyId": "PROP-001",
      "channelName": "MakeMyTrip",
      "logo": "https://images.unsplash.com/photo-1566073771259-6a8506099945?w=100",
      "lastSyncTime": "2026-07-04T06:00:00Z",
      "status": "success",
      "conflictsCount": 1,
      "syncEnabled": true
    },
    {
      "id": "OTA-005",
      "propertyId": "PROP-001",
      "channelName": "Goibibo",
      "logo": "https://images.unsplash.com/photo-1566073771259-6a8506099945?w=100",
      "lastSyncTime": "2026-07-03T22:00:00Z",
      "status": "error",
      "conflictsCount": 3,
      "syncEnabled": false
    }
  ]
}
```

### POST /api/v1/admin/ota/{id}/toggle

Enable/disable sync for an OTA channel.

**Response (200):**
```json
{
  "success": true,
  "message": "Goibibo sync has been enabled.",
  "data": { "id": "OTA-005", "channelName": "Goibibo", "syncEnabled": true }
}
```

### POST /api/v1/admin/ota/{id}/sync

Trigger an immediate sync for a channel.

**Request:** (empty body)

**Response (200):**
```json
{
  "success": true,
  "message": "Sync triggered for Airbnb. Feeds synchronized successfully.",
  "data": {
    "id": "OTA-001",
    "channelName": "Airbnb",
    "status": "success",
    "lastSyncTime": "2026-07-04T14:30:00Z"
  }
}
```

**Error — Sync disabled (400):**
```json
{
  "success": false,
  "error": {
    "code": "SYNC_DISABLED",
    "message": "Cannot sync Goibibo. Sync is currently disabled. Enable it first."
  }
}
```

---

## 9. Resort Operations (Tab 7: `staff_ops`)

Embeds housekeeping room status management (shared with StaffView). This uses the same endpoints as the Staff role.

### GET /api/v1/admin/rooms/housekeeping

**Query params:** `?propertyId=PROP-001`

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "RM-001",
      "propertyId": "PROP-001",
      "name": "The Valley View Suite",
      "housekeepingStatus": "clean",
      "assignedStaff": null,
      "notes": null,
      "lastUpdated": "2026-07-04T09:00:00Z"
    },
    {
      "id": "RM-002",
      "propertyId": "PROP-001",
      "name": "Sunrise Terrace Room",
      "housekeepingStatus": "dirty",
      "assignedStaff": "Rohit Verma",
      "notes": "Deep clean requested - guest checked out with pets",
      "lastUpdated": "2026-07-04T11:00:00Z"
    },
    {
      "id": "RM-003",
      "propertyId": "PROP-001",
      "name": "Garden View Cottage",
      "housekeepingStatus": "cleaning",
      "assignedStaff": "Rohit Verma",
      "notes": null,
      "lastUpdated": "2026-07-04T13:30:00Z"
    }
  ]
}
```

### PUT /api/v1/admin/rooms/housekeeping/{id}

Update housekeeping status for a room.

**Request:**
```json
{
  "status": "cleaning",
  "assignedStaff": "Rohit Verma",
  "notes": "Guest requested extra towels and fresh linens"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Housekeeping status for The Valley View Suite updated to cleaning.",
  "data": {
    "id": "RM-001",
    "name": "The Valley View Suite",
    "housekeepingStatus": "cleaning",
    "assignedStaff": "Rohit Verma",
    "lastUpdated": "2026-07-04T14:00:00Z"
  }
}
```

---

## 10. Notifications

Admin operations generate notifications automatically. Endpoint for fetching/reading notifications visible in the portal shell header.

### GET /api/v1/admin/notifications

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "NOTIF-001",
      "title": "Payment Authorized",
      "message": "Authorized check-in payment of ₹53,690 for Priya Sharma.",
      "type": "payment",
      "read": false,
      "timestamp": "2026-07-04T12:00:00Z"
    },
    {
      "id": "NOTIF-002",
      "title": "Calendar Dates Isolated",
      "message": "Blocked dates 2026-08-05 to 2026-08-07 due to private_event.",
      "type": "system",
      "read": false,
      "timestamp": "2026-07-04T11:00:00Z"
    },
    {
      "id": "NOTIF-003",
      "title": "Reservation Revoked",
      "message": "Cancelled booking BKG-043 and scheduled full refund.",
      "type": "system",
      "read": true,
      "timestamp": "2026-07-04T12:15:00Z"
    }
  ],
  "unreadCount": 2
}
```

### PUT /api/v1/admin/notifications/read

Mark one or all notifications as read. Send `notificationIds` array for specific notifications; omit or send empty array to mark all as read.

**Request (mark specific):**
```json
{
  "notificationIds": ["NOTIF-001"]
}
```

**Request (mark all):**
```json
{
  "notificationIds": []
}
```
Or send no body to mark all as read.

**Response (200):**
```json
{
  "success": true,
  "message": "Notifications marked as read."
}
```

---

## Error Response Format (all APIs)

**401 Unauthorized:**
```json
{ "success": false, "error": { "code": "AUTH_TOKEN_EXPIRED", "message": "Access token has expired. Please refresh." } }
```

**403 Forbidden:**
```json
{ "success": false, "error": { "code": "FORBIDDEN", "message": "Insufficient permissions for this action." } }
```

**404 Not Found:**
```json
{ "success": false, "error": { "code": "NOT_FOUND", "message": "Resource with ID BKG-999 not found." } }
```

**409 Conflict:**
```json
{ "success": false, "error": { "code": "OVERLAP_CONFLICT", "message": "Overlap with existing booking.", "conflictingResourceId": "BKG-042" } }
```

**422 Validation Error:**
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Validation failed.",
    "details": [
      { "field": "startDate", "message": "Start date is required." },
      { "field": "endDate", "message": "End date must be after start date." }
    ]
  }
}
```
