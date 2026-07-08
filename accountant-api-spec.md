# VSP Nest — Accountant API Spec (13 APIs)

Accountant manages invoices, payment tracking, and refund processing for one or more properties.

> Default credentials: `accountant@vspnest.com` / `accountant123`

**Base URL:** `https://api.vspnest.com/api/v1/accountant`
**Auth:** All endpoints require `Authorization: Bearer <token>` with accountant role.

---

## 1. Auth (shared — same as all roles)

### POST /api/v1/auth/login

**Request:**
```json
{ "email": "accountant@vspnest.com", "password": "accountant123" }
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
      "id": 4,
      "name": "Priya Mehta",
      "email": "accountant@vspnest.com",
      "phone": "+91 77665 54433",
      "role": "ACCOUNTANT",
      "roleDisplayName": "Accountant",
      "profileImageUrl": null,
      "active": true,
      "permissions": [
        { "resource": "invoice", "actions": ["read", "approve"] },
        { "resource": "payment", "actions": ["read", "refund"] },
        { "resource": "booking", "actions": ["read"] },
        { "resource": "audit", "actions": ["read"] },
        { "resource": "analytics", "actions": ["read"] },
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

### GET /api/v1/accountant/properties

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

### PUT /api/v1/accountant/properties/{id}/activate

**Response (200):**
```json
{
  "success": true,
  "message": "Now managing Whispering Valleys Sanctuary ledger.",
  "data": { "propertyId": "PROP-001", "activatedAt": "2026-07-04T09:00:00Z" }
}
```

---

## 3. Dashboard — Financial KPIs

### GET /api/v1/accountant/dashboard/kpis

**Query params:** `?propertyId=PROP-001`

**Response (200):**
```json
{
  "success": true,
  "data": {
    "totalBookedGross": 4850000.00,
    "totalCashCollected": 3120000.00,
    "balanceReceivable": 1730000.00,
    "pendingRefundsCount": 2,
    "currency": "INR",
    "propertyName": "Whispering Valleys Sanctuary"
  }
}
```

---

## 4. Refunds Queue

### GET /api/v1/accountant/refunds

**Query params:** `?propertyId=PROP-001`

List bookings that are cancelled but not yet refunded.

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "BKG-045",
      "propertyId": "PROP-002",
      "propertyName": "Azure Sands Coastal Villa",
      "guestName": "Ananya Sharma",
      "guestEmail": "ananya@rediff.com",
      "startDate": "2026-05-01",
      "endDate": "2026-05-04",
      "nightsCount": 3,
      "totalAmount": 78000.00,
      "advancePaidAmount": 78000.00,
      "refundAmount": 78000.00,
      "cancellationReason": "Travel plan changed",
      "cancelledAt": "2026-05-02T10:00:00Z",
      "status": "cancelled",
      "paymentStatus": "pending"
    },
    {
      "id": "BKG-047",
      "propertyId": "PROP-001",
      "propertyName": "Whispering Valleys Sanctuary",
      "guestName": "Ravi Kumar",
      "guestEmail": "ravi.kumar@gmail.com",
      "startDate": "2026-07-20",
      "endDate": "2026-07-22",
      "nightsCount": 2,
      "totalAmount": 44000.00,
      "advancePaidAmount": 13200.00,
      "refundAmount": 13200.00,
      "cancellationReason": "Medical emergency",
      "cancelledAt": "2026-07-18T14:00:00Z",
      "status": "cancelled",
      "paymentStatus": "pending"
    }
  ],
  "totalPendingRefunds": 2,
  "totalRefundObligation": 91200.00
}
```

### POST /api/v1/accountant/refunds/{id}/process

Process/clear a refund for a cancelled booking.

**Request:** (empty body)

**Response (200):**
```json
{
  "success": true,
  "message": "Processed refund obligation for BKG-045. ₹78,000 refunded to guest.",
  "data": {
    "bookingId": "BKG-045",
    "refundAmount": 78000.00,
    "paymentStatus": "refunded",
    "processedAt": "2026-07-04T10:00:00Z",
    "processedBy": "Priya Mehta"
  }
}
```

---

## 5. Invoices Ledger

### GET /api/v1/accountant/invoices

**Query params:** `?propertyId=PROP-001&paymentStatus=all&search=&page=1&pageSize=20`

Searchable, filterable list of all invoices (bookings).

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "BKG-042",
      "propertyId": "PROP-001",
      "propertyName": "Whispering Valleys Sanctuary",
      "guestName": "Rahul Singh",
      "guestEmail": "rahul.singh@gmail.com",
      "guestPhone": "+91 98765 43210",
      "startDate": "2026-07-15",
      "endDate": "2026-07-18",
      "nightsCount": 3,
      "guestsCount": 4,
      "source": "direct",
      "status": "confirmed",
      "paymentStatus": "paid",
      "totalAmount": 85550.00,
      "advancePaidAmount": 85550.00,
      "balanceAmount": 0.00,
      "baseAmount": 66000.00,
      "extraGuestAmount": 5000.00,
      "cleaningAmount": 1500.00,
      "discountAmount": 0.00,
      "taxAmount": 13050.00,
      "couponApplied": null,
      "createdAt": "2026-07-10T08:00:00Z"
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
      "nightsCount": 2,
      "guestsCount": 2,
      "source": "airbnb",
      "status": "confirmed",
      "paymentStatus": "partiallyPaid",
      "totalAmount": 53690.00,
      "advancePaidAmount": 16107.00,
      "balanceAmount": 37583.00,
      "baseAmount": 44000.00,
      "extraGuestAmount": 0.00,
      "cleaningAmount": 1500.00,
      "discountAmount": 0.00,
      "taxAmount": 8190.00,
      "couponApplied": null,
      "createdAt": "2026-07-12T14:00:00Z"
    },
    {
      "id": "BKG-046",
      "propertyId": "PROP-001",
      "propertyName": "Whispering Valleys Sanctuary",
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
      "baseAmount": 57000.00,
      "extraGuestAmount": 5000.00,
      "cleaningAmount": 1500.00,
      "discountAmount": 5700.00,
      "taxAmount": 10404.00,
      "couponApplied": "HAVEN10",
      "createdAt": "2026-07-04T15:00:00Z"
    }
  ],
  "pagination": {
    "total": 45,
    "page": 1,
    "pageSize": 20,
    "totalPages": 3
  },
  "summary": {
    "totalInvoiced": 4850000.00,
    "totalCollected": 3120000.00,
    "totalBalance": 1730000.00,
    "totalRefunded": 78000.00
  }
}
```

### GET /api/v1/accountant/invoices/{id}

Full invoice detail with billing breakdown (used in the invoice dialog).

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
    "source": "direct",
    "status": "confirmed",
    "paymentStatus": "paid",
    "breakdown": {
      "accommodation": 57000.00,
      "accommodationLabel": "Luxury Accommodation Nights (3 nights)",
      "extraGuestSurcharge": 5000.00,
      "extraGuestLabel": "Additional Guest Capacity rates",
      "cleaningFee": 1500.00,
      "cleaningLabel": "Sanitization Service Fee",
      "discount": -5700.00,
      "discountLabel": "CouponApplied: HAVEN10",
      "subtotal": 57800.00,
      "gst": 10404.00,
      "gstLabel": "GST @ 18%",
      "grandTotal": 68204.00,
      "advancePaid": 20461.20,
      "balanceDue": 47742.80
    },
    "createdAt": "2026-07-04T15:00:00Z"
  }
}
```

---

## 6. Reports / Export

### GET /api/v1/accountant/reports/ledger/pdf

**Query params:** `?propertyId=PROP-001&from=2026-01-01&to=2026-12-31`

Downloads a PDF file of the full financial ledger.

**Response (200):** Binary PDF download with `Content-Type: application/pdf` and `Content-Disposition: attachment; filename="ledger-PROP-001-2026.pdf"`.

### GET /api/v1/accountant/reports/ledger/excel

**Query params:** `?propertyId=PROP-001&from=2026-01-01&to=2026-12-31`

Downloads an Excel file of the full financial ledger.

**Response (200):** Binary XLSX download with `Content-Type: application/vnd.openxmlformats-officedocument.spreadsheetml.sheet` and `Content-Disposition: attachment; filename="ledger-PROP-001-2026.xlsx"`.

---

## 7. Notifications

### GET /api/v1/accountant/notifications

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "NOTIF-001",
      "title": "Refund Settled",
      "message": "Processed refund transaction for reference BKG-045.",
      "type": "payment",
      "read": false,
      "timestamp": "2026-07-04T10:00:00Z"
    },
    {
      "id": "NOTIF-002",
      "title": "Context Switched",
      "message": "Now managing Azure Sands Coastal Villa.",
      "type": "system",
      "read": true,
      "timestamp": "2026-07-04T09:00:00Z"
    }
  ],
  "unreadCount": 1
}
```

### PUT /api/v1/accountant/notifications/{id}/read
### PUT /api/v1/accountant/notifications/read-all

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
{ "success": false, "error": { "code": "NOT_FOUND", "message": "Invoice with ID BKG-999 not found." } }
```

**409 Conflict:**
```json
{
  "success": false,
  "error": {
    "code": "REFUND_ALREADY_PROCESSED",
    "message": "Refund for BKG-045 has already been processed."
  }
}
```
