# VSP Nest — Staff API Spec (12 APIs)

Staff manages daily guest roster (arrivals, departures, active lodgers) and housekeeping room status.

> Default credentials: `housekeeping.staff@vspnest.com` / `staff123`

**Base URL:** `https://api.vspnest.com/api/v1/staff`
**Auth:** All endpoints require `Authorization: Bearer <token>` with staff role.

---

## 1. Auth (shared — same as all roles)

### POST /api/v1/auth/login

**Request:**
```json
{ "email": "housekeeping.staff@vspnest.com", "password": "staff123" }
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
      "id": 3,
      "name": "Rohit Verma",
      "email": "housekeeping.staff@vspnest.com",
      "phone": "+91 88776 65544",
      "role": "STAFF",
      "roleDisplayName": "Staff",
      "profileImageUrl": null,
      "active": true,
      "permissions": [
        { "resource": "housekeeping", "actions": ["read", "update"] },
        { "resource": "concierge", "actions": ["read", "update"] },
        { "resource": "booking", "actions": ["read"] },
        { "resource": "property", "actions": ["read"] },
        { "resource": "notification", "actions": ["read"] }
      ]
    }
  }
}
```

### GET /api/v1/auth/me
### POST /api/v1/auth/refresh
### POST /api/v1/auth/logout

(Identical response structure to other roles — see `login-api.md` for full auth docs.)

---

## 2. Properties (Header Ribbon — Property Selector)

### GET /api/v1/staff/properties

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "PROP-001",
      "name": "Whispering Valleys Sanctuary",
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
    }
  ]
}
```

### PUT /api/v1/staff/properties/{id}/activate

**Response (200):**
```json
{
  "success": true,
  "message": "Now managing Whispering Valleys Sanctuary.",
  "data": { "propertyId": "PROP-001", "activatedAt": "2026-07-04T06:30:00Z" }
}
```

---

## 3. Roster — Guest Transit (Tab: `roster`)

Returns today's arrivals, departures, and active in-house guests for the concierge desk.

### GET /api/v1/staff/roster

**Query params:** `?propertyId=PROP-001&date=2026-06-12`

**Response (200):**
```json
{
  "success": true,
  "data": {
    "date": "2026-06-12",
    "propertyId": "PROP-001",
    "propertyName": "Whispering Valleys Sanctuary",
    "arrivals": [
      {
        "id": "BKG-048",
        "guestName": "Amit Patel",
        "guestPhone": "+91 98765 43210",
        "guestsCount": 4,
        "startDate": "2026-06-12",
        "endDate": "2026-06-15",
        "nightsCount": 3,
        "source": "direct",
        "status": "confirmed",
        "housekeepingNotes": "Extra pillows and late check-out requested",
        "totalAmount": 68204.00
      }
    ],
    "departures": [
      {
        "id": "BKG-044",
        "guestName": "Ananya Sharma",
        "guestPhone": "+91 94432 12345",
        "totalAmount": 45000.00,
        "startDate": "2026-06-10",
        "endDate": "2026-06-12",
        "nightsCount": 2,
        "status": "checkedOut"
      }
    ],
    "activeLodgers": [
      {
        "id": "BKG-048",
        "guestName": "Amit Patel",
        "guestsCount": 4,
        "source": "direct",
        "startDate": "2026-06-12",
        "endDate": "2026-06-15"
      }
    ],
    "summary": {
      "arrivalsCount": 1,
      "departuresCount": 1,
      "activeLodgersCount": 1
    }
  }
}
```

---

## 4. Housekeeping — Room Status Board (Tab: `housekeeping`)

### GET /api/v1/staff/rooms/housekeeping

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
      "lastUpdated": "2026-07-04T06:00:00Z"
    },
    {
      "id": "RM-002",
      "propertyId": "PROP-001",
      "name": "Sunrise Terrace Room",
      "housekeepingStatus": "dirty",
      "assignedStaff": "Rohit Verma",
      "notes": "Deep clean requested - guest checked out with pets. Carpet shampooing needed.",
      "lastUpdated": "2026-07-04T07:30:00Z"
    },
    {
      "id": "RM-003",
      "propertyId": "PROP-001",
      "name": "Garden View Cottage",
      "housekeepingStatus": "cleaning",
      "assignedStaff": "Rohit Verma",
      "notes": "Towels laid, aromatherapy diffuser lit, private spa oils replenished.",
      "lastUpdated": "2026-07-04T08:15:00Z"
    },
    {
      "id": "RM-004",
      "propertyId": "PROP-001",
      "name": "Sunset Balcony Suite",
      "housekeepingStatus": "clean",
      "assignedStaff": "Staff Member",
      "notes": "All set for check-in. Mini-bar stocked, linens refreshed.",
      "lastUpdated": "2026-07-04T05:45:00Z"
    },
    {
      "id": "RM-005",
      "propertyId": "PROP-001",
      "name": "Poolside Cabana",
      "housekeepingStatus": "dirty",
      "assignedStaff": null,
      "notes": null,
      "lastUpdated": "2026-07-03T18:00:00Z"
    }
  ],
  "summary": {
    "total": 10,
    "clean": 4,
    "cleaning": 3,
    "dirty": 3,
    "pendingAction": 6
  }
}
```

### PUT /api/v1/staff/rooms/{id}/housekeeping

Update housekeeping status for a room.

**Request:**
```json
{
  "status": "cleaning",
  "assignedStaff": "Rohit Verma",
  "notes": "Towels laid, aromatherapy diffuser lit, private spa oils replenished."
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Updated condition logs for The Valley View Suite.",
  "data": {
    "id": "RM-001",
    "name": "The Valley View Suite",
    "housekeepingStatus": "cleaning",
    "assignedStaff": "Rohit Verma",
    "notes": "Towels laid, aromatherapy diffuser lit, private spa oils replenished.",
    "lastUpdated": "2026-07-04T09:00:00Z"
  }
}
```

---

## 5. Notifications

### GET /api/v1/staff/notifications

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "NOTIF-001",
      "title": "Room Verified Clean",
      "message": "The Valley View Suite marked completely sanitary and ready for immediate check-ins.",
      "type": "staff",
      "read": false,
      "timestamp": "2026-07-04T09:00:00Z"
    },
    {
      "id": "NOTIF-002",
      "title": "New Arrival",
      "message": "Amit Patel checking in today (4 guests, 3 nights).",
      "type": "staff",
      "read": false,
      "timestamp": "2026-07-04T06:00:00Z"
    }
  ],
  "unreadCount": 2
}
```

### PUT /api/v1/staff/notifications/{id}/read
### PUT /api/v1/staff/notifications/read-all

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
{ "success": false, "error": { "code": "NOT_FOUND", "message": "Room with ID RM-099 not found." } }
```

**422 Validation Error:**
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Validation failed.",
    "details": [
      { "field": "status", "message": "Status must be one of: clean, cleaning, dirty." }
    ]
  }
}
```
