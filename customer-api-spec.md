# VSP Nest — Customer API Spec (26 APIs)

Customer browses properties, saves favorites, books stays, views trips, manages profile, and checks availability.

> Default credentials: `ananya@rediff.com` / `customer123`

**Base URL:** `https://api.vspnest.com/api/v1/customer`
**Auth:** All endpoints require `Authorization: Bearer <token>` with customer role.

---

## 1. Auth (shared — same as all roles)

### POST /api/v1/auth/login

**Request:**
```json
{ "email": "ananya@rediff.com", "password": "customer123" }
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

### GET /api/v1/auth/me
### POST /api/v1/auth/refresh
### POST /api/v1/auth/logout

(Identical response structure to other roles — see `login-api.md` for full auth docs.)

---

## 2. Properties — Explore & Browse (Tab: Explore)

### GET /api/v1/customer/properties

List all active properties with pricing and amenities for browsing.

**Query params:** `?search=&state=&city=&category=beach|mountain|luxury`

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "PROP-001",
      "name": "Whispering Valleys Sanctuary",
      "tagline": "Escape to the lap of luxury amidst rolling hills",
      "description": "Nestled in the heart of the Western Ghats, this sanctuary offers panoramic valley views, a private infinity pool, and world-class amenities.",
      "location": "Coorg, Karnataka",
      "state": "Karnataka",
      "city": "Coorg",
      "category": "mountain",
      "basePriceWeekday": 15000.00,
      "basePriceWeekend": 22000.00,
      "extraGuestCharge": 2500.00,
      "cleaningFee": 1500.00,
      "image": "https://images.unsplash.com/photo-1580587771525-78b9dba3b914?w=1200",
      "gallery": [
        "https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=1200",
        "https://images.unsplash.com/photo-1540541338287-41700207dee6?w=1200",
        "https://images.unsplash.com/photo-1497366216548-37526070297c?w=1200"
      ],
      "amenities": [
        { "icon": "pool", "label": "Private Infinity Pool", "category": "premium" },
        { "icon": "restaurant", "label": "Personal Chef", "category": "dining" },
        { "icon": "spa", "label": "In-room Spa", "category": "wellness" },
        { "icon": "wifi", "label": "High-Speed WiFi", "category": "essential" }
      ],
      "rules": [
        "Check-in: 2:00 PM | Check-out: 11:00 AM",
        "No smoking inside the villa",
        "Pets allowed only with prior approval",
        "Maximum occupancy: 8 guests"
      ],
      "rating": 4.8,
      "totalReviews": 124,
      "isSaved": false
    },
    {
      "id": "PROP-002",
      "name": "Azure Sands Coastal Villa",
      "tagline": "Where the ocean meets luxury",
      "description": "A stunning beachfront villa with private access to pristine sands, infinity pool, and breathtaking sunsets.",
      "location": "Palolem, Goa",
      "state": "Goa",
      "city": "South Goa",
      "category": "beach",
      "basePriceWeekday": 18000.00,
      "basePriceWeekend": 26000.00,
      "extraGuestCharge": 3000.00,
      "cleaningFee": 2000.00,
      "image": "https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=1200",
      "gallery": [
        "https://images.unsplash.com/photo-1566073771259-6a8506099945?w=1200",
        "https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=1200",
        "https://images.unsplash.com/photo-1613490493576-7fde63acd811?w=1200"
      ],
      "amenities": [
        { "icon": "pool", "label": "Beachfront Infinity Pool", "category": "premium" },
        { "icon": "local_bar", "label": "Poolside Bar", "category": "dining" },
        { "icon": "spa", "label": "Ayurvedic Spa", "category": "wellness" }
      ],
      "rules": [
        "Check-in: 2:00 PM | Check-out: 11:00 AM",
        "No loud music after 10:00 PM",
        "Pets not allowed"
      ],
      "rating": 4.6,
      "totalReviews": 98,
      "isSaved": true
    },
    {
      "id": "PROP-003",
      "name": "Cloud-kissed Mountain Manor",
      "tagline": "A serene mountain escape above the clouds",
      "location": "Manali, Himachal Pradesh",
      "state": "Himachal Pradesh",
      "city": "Manali",
      "category": "mountain",
      "basePriceWeekday": 12000.00,
      "basePriceWeekend": 18000.00,
      "extraGuestCharge": 2000.00,
      "cleaningFee": 1500.00,
      "image": "https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?w=1200",
      "gallery": [
        "https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=1200",
        "https://images.unsplash.com/photo-1613490493576-7fde63acd811?w=1200"
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
      "rating": 4.7,
      "totalReviews": 76,
      "isSaved": false
    },
    {
      "id": "PROP-004",
      "name": "Forest Glade Wilderness Retreat",
      "tagline": "Immerse yourself in nature's embrace",
      "location": "Wayanad, Kerala",
      "state": "Kerala",
      "city": "Wayanad",
      "category": "luxury",
      "basePriceWeekday": 9000.00,
      "basePriceWeekend": 14000.00,
      "extraGuestCharge": 1500.00,
      "cleaningFee": 1000.00,
      "image": "https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=1200",
      "gallery": [
        "https://images.unsplash.com/photo-1613490493576-7fde63acd811?w=1200",
        "https://images.unsplash.com/photo-1497366216548-37526070297c?w=1200"
      ],
      "amenities": [
        { "icon": "forest", "label": "Private Forest Trail", "category": "premium" },
        { "icon": "bathtub", "label": "Open-air Bathtub", "category": "wellness" }
      ],
      "rules": [
        "Check-in: 1:00 PM | Check-out: 11:00 AM",
        "No smoking",
        "Eco-friendly guidelines apply"
      ],
      "rating": 4.5,
      "totalReviews": 52,
      "isSaved": false
    }
  ]
}
```

### GET /api/v1/customer/properties/{id}

Single property with full details (same structure as single item above).

### GET /api/v1/customer/pricing/tax-rate

**Response (200):**
```json
{
  "success": true,
  "data": {
    "taxRate": 18,
    "taxLabel": "GST",
    "currency": "INR"
  }
}
```

### GET /api/v1/customer/pricing/deposit-rate

**Response (200):**
```json
{
  "success": true,
  "data": {
    "depositRate": 30,
    "depositLabel": "Advance Deposit"
  }
}
```

### GET /api/v1/customer/pricing/seasonal-rules

**Query params:** `?propertyId=PROP-001`

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "RULE-001",
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
      "name": "Monsoon Retreat",
      "startDate": "07-01",
      "endDate": "08-31",
      "weekdayPrice": 12000.00,
      "weekendPrice": 18000.00,
      "multiplier": 0.8,
      "isActive": true
    }
  ]
}
```

---

## 3. Coupon Validation (Checkout Step 1)

### POST /api/v1/customer/coupons/validate

**Request:**
```json
{
  "code": "HAVEN10",
  "subtotal": 54000.00,
  "propertyId": "PROP-001"
}
```

**Response (200) — Valid:**
```json
{
  "success": true,
  "data": {
    "code": "HAVEN10",
    "type": "percentage",
    "value": 10,
    "discountAmount": 5400.00,
    "description": "10% off on bookings above ₹20,000",
    "isValid": true
  }
}
```

**Response (200) — Valid (fixed):**
```json
{
  "success": true,
  "data": {
    "code": "WELCOMEFIXED",
    "type": "fixed",
    "value": 5000,
    "discountAmount": 5000.00,
    "description": "₹5,000 off on bookings above ₹30,000",
    "isValid": true
  }
}
```

**Response (200) — Invalid / Expired:**
```json
{
  "success": true,
  "data": {
    "code": "EARLYBIRD",
    "isValid": false,
    "error": "Coupon has expired or is no longer active."
  }
}
```

**Response (200) — Min booking not met:**
```json
{
  "success": true,
  "data": {
    "code": "WELCOMEFIXED",
    "isValid": false,
    "error": "Minimum booking value of ₹30,000 required. Current subtotal: ₹15,000."
  }
}
```

---

## 4. Bookings — Create & Manage (Checkout + My Trips)

### POST /api/v1/customer/bookings

Create a new booking after successful payment.

**Request:**
```json
{
  "propertyId": "PROP-001",
  "startDate": "2026-07-25",
  "endDate": "2026-07-28",
  "guestsCount": 4,
  "guestName": "Ananya Sharma",
  "guestEmail": "ananya@rediff.com",
  "guestPhone": "+91 94432 12345",
  "couponCode": "HAVEN10",
  "housekeepingNotes": "Extra pillows and late check-out requested",
  "baseAmount": 57000.00,
  "extraGuestAmount": 5000.00,
  "cleaningAmount": 1500.00,
  "discountAmount": 5700.00,
  "taxAmount": 10404.00,
  "totalAmount": 68204.00,
  "advancePaidAmount": 20461.20,
  "balanceAmount": 47742.80,
  "source": "direct"
}
```

**Response (201):**
```json
{
  "success": true,
  "message": "Booking confirmed! Your reservation at Whispering Valleys Sanctuary is confirmed.",
  "data": {
    "id": "BKG-046",
    "propertyName": "Whispering Valleys Sanctuary",
    "guestName": "Ananya Sharma",
    "startDate": "2026-07-25",
    "endDate": "2026-07-28",
    "nightsCount": 3,
    "guestsCount": 4,
    "totalAmount": 68204.00,
    "advancePaidAmount": 20461.20,
    "status": "confirmed",
    "paymentStatus": "paid",
    "createdAt": "2026-07-04T15:00:00Z"
  }
}
```

### GET /api/v1/customer/bookings

Fetch all bookings for the logged-in customer.

**Query params:** `?status=upcoming|past&page=1&pageSize=20`

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "BKG-046",
      "propertyId": "PROP-001",
      "propertyName": "Whispering Valleys Sanctuary",
      "propertyImage": "https://images.unsplash.com/photo-1580587771525-78b9dba3b914?w=400",
      "guestName": "Ananya Sharma",
      "guestEmail": "ananya@rediff.com",
      "guestPhone": "+91 94432 12345",
      "startDate": "2026-07-25",
      "endDate": "2026-07-28",
      "nightsCount": 3,
      "guestsCount": 4,
      "source": "direct",
      "status": "confirmed",
      "paymentStatus": "paid",
      "totalAmount": 68204.00,
      "advancePaidAmount": 20461.20,
      "balanceAmount": 47742.80,
      "createdAt": "2026-07-04T15:00:00Z"
    },
    {
      "id": "BKG-044",
      "propertyId": "PROP-001",
      "propertyName": "Whispering Valleys Sanctuary",
      "guestName": "Ananya Sharma",
      "guestEmail": "ananya@rediff.com",
      "guestPhone": "+91 94432 12345",
      "startDate": "2026-06-10",
      "endDate": "2026-06-13",
      "nightsCount": 3,
      "guestsCount": 2,
      "source": "direct",
      "status": "checkedOut",
      "paymentStatus": "paid",
      "totalAmount": 45000.00,
      "advancePaidAmount": 45000.00,
      "balanceAmount": 0.00,
      "createdAt": "2026-06-01T10:00:00Z"
    },
    {
      "id": "BKG-045",
      "propertyId": "PROP-002",
      "propertyName": "Azure Sands Coastal Villa",
      "guestName": "Ananya Sharma",
      "guestEmail": "ananya@rediff.com",
      "guestPhone": "+91 94432 12345",
      "startDate": "2026-05-01",
      "endDate": "2026-05-04",
      "nightsCount": 3,
      "guestsCount": 4,
      "source": "airbnb",
      "status": "cancelled",
      "paymentStatus": "refunded",
      "totalAmount": 78000.00,
      "advancePaidAmount": 78000.00,
      "balanceAmount": 0.00,
      "cancellationReason": "Travel plan changed",
      "refundAmount": 78000.00,
      "createdAt": "2026-04-20T10:00:00Z"
    }
  ],
  "pagination": {
    "total": 3,
    "page": 1,
    "pageSize": 20,
    "totalPages": 1
  }
}
```

### GET /api/v1/customer/bookings/{id}

Full booking details including invoice breakdown.

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": "BKG-046",
    "propertyId": "PROP-001",
    "propertyName": "Whispering Valleys Sanctuary",
    "propertyLocation": "Coorg, Karnataka",
    "guestName": "Ananya Sharma",
    "guestPhone": "+91 94432 12345",
    "guestEmail": "ananya@rediff.com",
    "startDate": "2026-07-25",
    "endDate": "2026-07-28",
    "nightsCount": 3,
    "guestsCount": 4,
    "source": "direct",
    "status": "confirmed",
    "paymentStatus": "paid",
    "invoice": {
      "accommodation": 57000.00,
      "extraGuestSurcharge": 5000.00,
      "cleaningFee": 1500.00,
      "discount": -5700.00,
      "couponApplied": "HAVEN10",
      "subtotal": 57800.00,
      "gst": 10404.00,
      "grandTotal": 68204.00,
      "advancePaid": 20461.20,
      "balanceDue": 47742.80
    },
    "createdAt": "2026-07-04T15:00:00Z"
  }
}
```

### POST /api/v1/customer/bookings/{id}/cancel

Cancel a booking and request refund.

**Request:**
```json
{
  "reason": "Medical emergency - unable to travel"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Your booking BKG-046 has been cancelled. Full refund of ₹20,461 will be processed within 5-7 business days.",
  "data": {
    "bookingId": "BKG-046",
    "status": "cancelled",
    "refundAmount": 20461.20,
    "refundPercent": 100,
    "cancelledAt": "2026-07-04T16:00:00Z"
  }
}
```

---

## 5. Payment (Checkout Step 2)

### POST /api/v1/customer/payments/initiate

Initiate payment for a booking (called before POST /bookings in the current flow).

**Request:**
```json
{
  "propertyId": "PROP-001",
  "totalAmount": 68204.00,
  "advanceAmount": 20461.20,
  "paymentMethod": "credit_card",
  "cardLastFour": "4242"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Payment successful! ₹20,461 paid as advance deposit.",
  "data": {
    "transactionId": "TXN-78901",
    "amount": 20461.20,
    "paymentMethod": "credit_card",
    "status": "completed",
    "paidAt": "2026-07-04T15:00:00Z"
  }
}
```

---

## 6. Favorites / Wishlist (Tab: Saved)

### GET /api/v1/customer/favorites

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "PROP-002",
      "name": "Azure Sands Coastal Villa",
      "tagline": "Where the ocean meets luxury",
      "location": "Palolem, Goa",
      "city": "South Goa",
      "image": "https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=800",
      "basePriceWeekday": 18000.00,
      "rating": 4.6,
      "savedAt": "2026-07-01T12:00:00Z"
    }
  ]
}
```

### POST /api/v1/customer/favorites

**Request:**
```json
{
  "propertyId": "PROP-001"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Whispering Valleys Sanctuary has been added to your saved resorts.",
  "data": { "propertyId": "PROP-001", "savedAt": "2026-07-04T17:00:00Z" }
}
```

### DELETE /api/v1/customer/favorites/{propertyId}

**Response (200):**
```json
{
  "success": true,
  "message": "Azure Sands Coastal Villa removed from your saved resorts."
}
```

---

## 7. Profile (Tab: Profile)

### GET /api/v1/customer/profile

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": "USR-CUST-001",
    "name": "Ananya Sharma",
    "email": "ananya@rediff.com",
    "phone": "+91 94432 12345",
    "avatar": "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400",
    "memberSince": "2026-03-10T14:00:00Z",
    "membershipTier": "Direct Sanctuary Guest"
  }
}
```

### PUT /api/v1/customer/profile

**Content-Type:** `multipart/form-data`

| Field | Type | Description |
|-------|------|-------------|
| `name` | string | Full name |
| `email` | string | Email address |
| `phone` | string | Phone number |
| `avatar` | file | New profile image (jpg/png, max 2MB) |

**Example cURL:**
```bash
curl -X PUT https://api.vspnest.com/api/v1/customer/profile \
  -H "Authorization: Bearer <token>" \
  -F "name=Ananya Sharma" \
  -F "email=ananya@rediff.com" \
  -F "phone=+91 94432 12345" \
  -F "avatar=@./profile.jpg"
```

**Response (200):**
```json
{
  "success": true,
  "message": "Profile updated successfully.",
  "data": {
    "name": "Ananya Sharma",
    "email": "ananya@rediff.com",
    "phone": "+91 94432 12345",
    "avatar": "https://api.vspnest.com/uploads/avatars/USR-CUST-001/profile.jpg",
    "updatedAt": "2026-07-04T18:00:00Z"
  }
}
```

### GET /api/v1/customer/stats

**Response (200):**
```json
{
  "success": true,
  "data": {
    "totalBookings": 3,
    "activeStays": 1,
    "totalSpent": 113204.00,
    "currency": "INR"
  }
}
```

---

## 8. Calendar — Availability (Tab: Interactive Calendar)

### GET /api/v1/customer/calendar/blocks

**Query params:** `?propertyId=PROP-001&from=2026-06-01&to=2026-07-31`

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "BLOCK-001",
      "startDate": "2026-06-22",
      "endDate": "2026-06-24",
      "reason": "maintenance",
      "notes": "Annual pool filtration system upgrade."
    },
    {
      "id": "BLOCK-002",
      "startDate": "2026-07-10",
      "endDate": "2026-07-15",
      "reason": "owner_stay",
      "notes": "Owner's family vacation."
    }
  ]
}
```

### GET /api/v1/customer/calendar/availability

**Query params:** `?propertyId=PROP-001&from=2026-06-01&to=2026-07-31`

Returns a day-by-day availability matrix computed from bookings + blocks.

**Response (200):**
```json
{
  "success": true,
  "data": {
    "propertyId": "PROP-001",
    "from": "2026-06-01",
    "to": "2026-07-31",
    "days": [
      { "date": "2026-06-01", "status": "available" },
      { "date": "2026-06-02", "status": "available" },
      { "date": "2026-06-10", "status": "booked", "bookingId": "BKG-044", "guestName": "Ananya Sharma" },
      { "date": "2026-06-11", "status": "booked", "bookingId": "BKG-044" },
      { "date": "2026-06-22", "status": "blocked", "reason": "maintenance" },
      { "date": "2026-06-23", "status": "blocked", "reason": "maintenance" },
      { "date": "2026-07-10", "status": "blocked", "reason": "owner_stay" },
      { "date": "2026-07-15", "status": "available" },
      { "date": "2026-07-25", "status": "booked", "bookingId": "BKG-046", "guestName": "Ananya Sharma" }
    ]
  }
}
```

**Status values:** `available`, `booked`, `blocked`, `pending`, `ota`

---

## 9. Notifications

### GET /api/v1/customer/notifications

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "NOTIF-001",
      "title": "Booking Confirmed",
      "message": "Your stay at Whispering Valleys Sanctuary (Jul 25-28) is confirmed!",
      "type": "booking",
      "read": false,
      "timestamp": "2026-07-04T15:00:00Z"
    },
    {
      "id": "NOTIF-002",
      "title": "Payment Received",
      "message": "Your advance payment of ₹20,461 has been received.",
      "type": "payment",
      "read": false,
      "timestamp": "2026-07-04T15:00:00Z"
    },
    {
      "id": "NOTIF-003",
      "title": "Booking Cancelled",
      "message": "Your booking BKG-045 has been cancelled. Refund initiated.",
      "type": "booking",
      "read": true,
      "timestamp": "2026-06-01T10:00:00Z"
    }
  ],
  "unreadCount": 2
}
```

### PUT /api/v1/customer/notifications/{id}/read

**Response (200):**
```json
{ "success": true, "data": { "id": "NOTIF-001", "read": true } }
```

---

## 10. Concierge (WhatsApp FAB)

### POST /api/v1/customer/concierge/message

Send a message to the concierge team (archived for support tracking).

**Request:**
```json
{
  "message": "I need help with my booking BKG-046. Can I check in early?",
  "source": "whatsapp_fab"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Your message has been sent to the concierge team. They will respond shortly.",
  "data": {
    "ticketId": "TKT-001",
    "receivedAt": "2026-07-04T18:30:00Z",
    "whatsappUrl": "https://wa.me/919876543210?text=I%20need%20help%20with%20my%20booking%20BKG-046"
  }
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
{ "success": false, "error": { "code": "NOT_FOUND", "message": "Property with ID PROP-099 not found." } }
```

**422 Validation Error:**
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Validation failed.",
    "details": [
      { "field": "startDate", "message": "Check-in date is required." },
      { "field": "endDate", "message": "Check-out date must be after check-in." },
      { "field": "guestsCount", "message": "At least 1 guest is required." }
    ]
  }
}
```

**409 Conflict:**
```json
{
  "success": false,
  "error": {
    "code": "DATES_UNAVAILABLE",
    "message": "Selected dates are not available. The property is booked or blocked during this period."
  }
}
```
