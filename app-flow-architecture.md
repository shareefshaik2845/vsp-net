# VSP Nest — App Flow & Architecture Document

> **What happens where?** Every user action follows a consistent 4-step data flow:
> **Screen (UI)** → **Provider (State)** → **Repository (Data)** → **Backend (API/DB)** → **Response back to UI**

---

## Architecture Layers

```
┌──────────────────────────────────────────────┐
│  PRESENTATION LAYER (Flutter)                 │
│                                               │
│  Screens/Views  ──>  Providers/Notifiers      │
│  (admin_view.dart)   (state_provider.dart)    │
│         ▲                    │                │
│         │    Rebuilds UI     │  Calls method   │
│         └────────────────────┘                │
├──────────────────────────────────────────────┤
│  DOMAIN LAYER (Dart)                          │
│                                               │
│  Repository Interfaces        Entities        │
│  (repositories.dart)       (entities.dart)    │
│         ▲                        │            │
│         │                        │            │
├─────────┼────────────────────────┼────────────┤
│  DATA LAYER (Dart/API)           │            │
│  ┌──────────────────────────────┐│            │
│  │RepositoryImpl (Current Mock) ││            │
│  │  - In-memory lists           ││            │
│  │  - No API calls              ││            │
│  ├──────────────────────────────┤│            │
│  │RepositoryImpl (Future: HTTP) ││            │
│  │  - POST/GET to Spring Boot   ││            │
│  │  - Auth via JWT token        ││            │
│  └──────────────────────────────┘│            │
│         │                        │            │
├─────────┼────────────────────────┼────────────┤
│  BACKEND LAYER (Spring Boot)     │            │
│  ┌──────────────────────────────┐│            │
│  │ REST API Controllers         ││            │
│  │  - /api/v1/*                ││            │
│  │  - JWT Security Filter       ││            │
│  ├──────────────────────────────┤│            │
│  │ Service Layer                ││            │
│  │  - Business logic            ││            │
│  ├──────────────────────────────┤│            │
│  │ JPA Repositories             ││            │
│  │  - CRUD operations           ││            │
│  ├──────────────────────────────┤│            │
│  │ PostgreSQL Database          ││            │
│  │  - Tables: bookings, users,  ││            │
│  │    properties, coupons, etc. ││            │
│  └──────────────────────────────┘│            │
└──────────────────────────────────┘────────────┘
```

---

## Data Flow Pattern (All Features)

Every feature follows this exact pattern:

```
User taps button
    │
    ▼
Screen calls provider method
  e.g. ref.read(bookingsProvider.notifier).addBooking(...)
    │
    ▼
Provider/Notifier:
  1. Calls repository method
  2. Awaits response
  3. Updates state (triggers UI rebuild)
    │
    ▼
Repository Interface (domain/repositories.dart):
  abstract method signature only
    │
    ▼
Repository Impl (data/repositories_impl.dart):
  CURRENT:  In-memory list manipulation
  FUTURE:   HTTP client (Dio/Http) → Spring Boot API → PostgreSQL
    │
    ▼
Backend API (when migrated):
  Controller → Service → JPA Repository → PostgreSQL
    │
    ▼
Response returns → UI rebuilds via Riverpod state change
```

---

## Feature Flows (By Role)

---

### 1. SUPER ADMIN

#### 1.1 Authentication

```
Screen: login_screen.dart
  │
  User enters email + password, taps "Access Sanctuary Portal"
  │
  ▼
LoginScreen._handleLogin()
  │  ref.read(usersProvider.notifier).authenticate(email, password)
  │
  ▼
UserAccountsNotifier.authenticate()
  │  Hashes password → searches _users list → returns UserAccount or null
  │
  ▼
  ├── Success: Sets activeRoleProvider, authenticatedRoleProvider, isLoggedInProvider
  │            Navigator.pushReplacementNamed → '/super-admin'
  │
  └── Failure: Shows SnackBar "Invalid email or password"

FUTURE API: POST /api/v1/auth/login → Spring Boot AuthController → JWT token → Store in provider
```

#### 1.2 Dashboard KPIs

```
Screen: super_admin_view.dart (tab: 'dashboard')
  │  Auto-calculates on build:
  │    totalRevenue = bookings.sum(totalAmount)
  │    totalNights  = bookings.sum(nightsCount)
  │    pendingBalance = bookings.sum(balanceAmount)
  │
  Provider reads: bookingsProvider, resortsListProvider
  │
  Repository: ResortRepositoryImpl._bookings (in-memory list)
  │
  FUTURE API: GET /api/v1/super-admin/analytics/revenue
             GET /api/v1/super-admin/analytics/booking-sources
             GET /api/v1/super-admin/analytics/resort-revenue-table
```

#### 1.3 Onboard New Resort

```
Screen: super_admin_view.dart → "Onboard New Resort" dialog
  │
  User fills: name, tagline, description, location, pricing, amenities, rules, images
  │
  ▼
SuperAdminView._handleOnboardResort()
  │  Creates PropertyDetails object
  │  ref.read(resortsListProvider.notifier).addResort(newResort)
  │
  ▼
ResortsNotifier.addResort()
  │  Appends to in-memory _resorts list
  │  ref.read(notificationsProvider.notifier).addNotification(...)
  │
  FUTURE API: POST /api/v1/super-admin/properties (multipart/form-data)
             image + gallery uploaded as files → stored on server → URLs returned
```

#### 1.4 User Management — Create User

```
Screen: super_admin_view.dart (tab: 'users') → "Create User" dialog
  │
  User fills: name, email, password, role, avatar
  │
  ▼
SuperAdminView._handleCreateUser()
  │  Validates unique email
  │  ref.read(usersProvider.notifier).addUser(name, email, password, role)
  │
  ▼
UserAccountsNotifier.addUser()
  │  PasswordService.hashPassword(password) → stores hash+salt
  │  Appends to in-memory _users list
  │
  FUTURE API: POST /api/v1/super-admin/users (multipart/form-data)
             avatar file uploaded → stored → URL saved
```

#### 1.5 User Management — List/Edit/Delete

```
Screen: super_admin_view.dart (tab: 'users')
  │
  Reads: ref.watch(usersProvider) → List<UserAccount>
  │
  Edit: PUT /api/v1/super-admin/users/{id}
  Delete: DELETE /api/v1/super-admin/users/{id}
  │
  Validation: Cannot delete last SuperAdmin (error code: LAST_SUPER_ADMIN)
```

#### 1.6 Approvals — Resolve

```
Screen: super_admin_view.dart → ApprovalPanel widget
  │
  Admin requested: cancel booking with refund >50%
  Super Admin taps "Approve" or "Reject"
  │
  ▼
ApprovalNotifier.resolveApproval(id, status, reason)
  │  Updates ApprovalRequest status → approved/rejected
  │  If approved: executes the underlying action (e.g., process refund)
  │  ref.read(notificationsProvider.notifier).addNotification(...)
  │
  FUTURE API: PUT /api/v1/super-admin/approvals/{id}/resolve
```

#### 1.7 Roles & Permissions — Edit

```
Screen: role_management_view.dart (embedded in Super Admin > Roles tab)
  │
  Super Admin selects role → edits permission checkboxes (C/R/U/D/A per resource)
  │
  ▼
RolesNotifier.updateRole(updatedRole)
  │  Replaces RoleDefinition in _roles list
  │  SuperAdmin role is locked (isSystem = true → cannot edit)
  │
  FUTURE API: PUT /api/v1/super-admin/roles/{id}
```

#### 1.8 Global Settings — Update

```
Screen: super_admin_view.dart (tab: 'dashboard') → Global System Constraints
  │
  User adjusts: taxRate slider, depositRate slider, multi-property toggle
  │
  ▼
  ref.read(taxRateProvider.notifier).state = newValue
  ref.read(depositRateProvider.notifier).state = newValue
  │
  These providers are consumed by ALL roles for quote calculations.
  │
  FUTURE API: PUT /api/v1/super-admin/settings
```

#### 1.9 Audit Logs

```
Screen: super_admin_view.dart → Schema Inspector / Audit view
  │
  Reads: ref.watch(auditLogProvider) → List<AuditLogEntry>
  │
  Every create/update/delete action across the app pushes:
    auditLogProvider.notifier).addEntry(userId, action, targetType, targetId, details)
  │
  FUTURE API: GET /api/v1/super-admin/audit-logs
```

#### 1.10 Factory Reset

```
Screen: super_admin_view.dart (tab: 'dashboard') → "Factory Reset" button
  │
  ▼
  Confirmation dialog → calls repo._resetToDefaults()
  Clears ALL in-memory lists, re-seeds defaults
  │
  FUTURE API: POST /api/v1/super-admin/system/factory-reset
  (DELETE FROM all tables → re-run seed migrations)
```

---

### 2. ADMIN

#### 2.1 Analytics Board

```
Screen: admin_view.dart (tab: 'kpis')
  │
  Auto-computes from providers:
  │
  ┌─ KPI Cards ──────────────────────────────────┐
  │ Gross Valuation = sum(all bookings.totalAmount)       │
  │ Advance Collated = sum(all bookings.advancePaidAmount)│
  │ Occupancy Rate  = (bookedNights / totalNights) × 100  │
  │ Operational Stays = active bookings count             │
  └───────────────────────────────────────────────┘
  │
  Provider reads: bookingsProvider, calendarBlocksProvider,
  │               couponsProvider, otaSyncProvider
  │
  SalesChartPainter (CustomPainter) renders 6-week chart from hardcoded points
  │
  FUTURE API: GET /api/v1/admin/analytics/kpis
             GET /api/v1/admin/analytics/sales-chart
             GET /api/v1/admin/analytics/metrics-insights
```

#### 2.2 Property Switching

```
Screen: admin_view.dart → Header Ribbon → DropdownButton
  │
  User selects different property from dropdown
  │
  ▼
  ref.read(propertyProvider.notifier).updateProperty(newProperty)
  │  Entire AdminView rebuilds with new property's data
  │  Notifications: "Context Switched → Now managing {name}."
  │
  FUTURE API: GET /api/v1/admin/properties → PUT /api/v1/admin/properties/{id}/activate
```

#### 2.3 Calendar Blocking — Create Block

```
Screen: admin_view.dart (tab: 'blocks')
  │
  User picks: startDate, endDate, reason, notes → taps "Commit Date Isolation"
  │
  ▼
AdminView._handleCreateBlock()
  │
  ├── Validation:
  │   ├── Notes required
  │   ├── End date must be after start date
  │   ├── Overlap check against ALL bookings (non-cancelled)
  │   └── Overlap check against ALL existing blocks
  │
  ▼
  ref.read(calendarBlocksProvider.notifier).addBlock(newBlock)
  │  Appends CalendarBlock to in-memory list
  │  ref.read(notificationsProvider.notifier).addNotification(...)
  │
  FUTURE API: POST /api/v1/admin/calendar-blocks
  Backend: CalendarBlockController → OverlapDetectionService → JPA save
  DB: INSERT INTO calendar_blocks
```

#### 2.4 Calendar Blocking — Delete Block

```
Screen: admin_view.dart (tab: 'blocks') → Active Blocks list
  │
  User taps delete icon on a block
  │
  ▼
  ref.read(calendarBlocksProvider.notifier).removeBlock(id)
  │  Filters out block from in-memory list
  │  Notification: "Exclusion restored. Inventory unlocked."
  │
  FUTURE API: DELETE /api/v1/admin/calendar-blocks/{id}
  DB: DELETE FROM calendar_blocks WHERE id = ?
```

#### 2.5 Booking Matrix — Filter & Search

```
Screen: admin_view.dart (tab: 'orders')
  │
  User selects: source filter, status filter, search query
  │
  ▼
  _filterSource, _filterStatus, _filterQuery are local state variables
  │  filteredBookings = bookings.where(matchSource && matchStatus && matchQuery)
  │
  Renders: Desktop Table or Mobile List based on screen width
  │
  FUTURE API: GET /api/v1/admin/bookings?source=&status=&search=&page=&pageSize=
```

#### 2.6 Booking Matrix — Authorize Payment

```
Screen: admin_view.dart (tab: 'orders') → "Authorize Pay" button
  │
  Only visible when booking.status == pendingPayment
  │
  ▼
  ref.read(bookingsProvider.notifier).confirmPayment(bookingId)
  │  Changes: status → confirmed, paymentStatus → paid
  │           advancePaidAmount → totalAmount, balanceAmount → 0
  │  Notification: "Payment Authorized"
  │
  FUTURE API: POST /api/v1/admin/bookings/{id}/authorize-payment
  DB: UPDATE bookings SET status='confirmed', payment_status='paid', ...
```

#### 2.7 Booking Matrix — Revoke/Cancel

```
Screen: admin_view.dart (tab: 'orders') → "Revoke" button
  │
  Only visible when booking.status != cancelled
  │
  ▼
  ref.read(bookingsProvider.notifier).cancelBooking(id, reason, refundPercent: 100)
  │  Changes: status → cancelled, paymentStatus → pending
  │           refundAmount → advancePaidAmount, balanceAmount → 0
  │  Notification: "Reservation Revoked"
  │
  FUTURE API: POST /api/v1/admin/bookings/{id}/revoke
             { "reason": "...", "refundPercent": 100 }
  DB: UPDATE bookings SET status='cancelled', cancellation_reason=?, ...
```

#### 2.8 Tariffs — Update Base Prices

```
Screen: admin_view.dart (tab: 'tariffs')
  │
  User edits: weekdayPrice, weekendPrice, extraGuestCharge, cleaningFee
  │
  ▼
  ref.read(propertyProvider.notifier).updateProperty(property.copyWith(...))
  │  Updates PropertyDetails in the active property provider
  │  All future quote calculations reflect new rates immediately
  │
  FUTURE API: PUT /api/v1/admin/pricing/base
  DB: UPDATE properties SET base_price_weekday=?, base_price_weekend=?, ...
```

#### 2.9 Tariffs — Toggle Seasonal Rule

```
Screen: admin_view.dart (tab: 'tariffs') → Switch toggle per rule
  │
  ▼
  ref.read(pricingRulesProvider.notifier).toggleRuleActive(ruleId)
  │  Flips isActive boolean on PricingSeasonRule
  │
  FUTURE API: PUT /api/v1/admin/pricing/seasonal-rules/{id}/toggle
```

#### 2.10 Coupons — Create

```
Screen: admin_view.dart (tab: 'coupons')
  │
  User fills: code, type (percentage/fixed), value, expiry, usageLimit, minBooking, description
  │
  ▼
AdminView._handleCreateCoupon()
  │  Validates code not empty
  │  Creates Coupon object
  │  ref.read(couponsProvider.notifier).addCoupon(newCoupon)
  │  Notification: "New Promotion Added"
  │
  FUTURE API: POST /api/v1/admin/coupons
  Backend: Check duplicate code → return 409 if exists
  DB: INSERT INTO coupons
```

#### 2.11 Coupons — Toggle Active

```
Screen: admin_view.dart (tab: 'coupons') → Switch toggle per coupon
  │
  ▼
  ref.read(couponsProvider.notifier).toggleCouponActive(couponId)
  │  Flips isActive boolean
  │
  FUTURE API: PUT /api/v1/admin/coupons/{id}/toggle
```

#### 2.12 OTA Sync — Toggle

```
Screen: admin_view.dart (tab: 'ota') → Toggle switch per channel
  │
  ▼
  ref.read(otaSyncProvider.notifier).toggleSync(channelId)
  │  Flips syncEnabled boolean
  │
  FUTURE API: POST /api/v1/admin/ota/{id}/toggle
```

#### 2.13 OTA Sync — Trigger Sync

```
Screen: admin_view.dart (tab: 'ota') → "Sync Now" button
  │
  Button disabled when syncEnabled == false
  │
  ▼
  ref.read(otaSyncProvider.notifier).triggerSyncSuccess(channelId)
  │  Sets status → 'success', updates lastSyncTime
  │  SnackBar: "Synchronized {channel} feeds."
  │
  FUTURE API: POST /api/v1/admin/ota/{id}/sync
  Backend: SyncService.triggerSync(channelId) → calls OTA provider API → updates status
```

#### 2.14 Resort Operations (Housekeeping)

```
Screen: admin_view.dart (tab: 'staff_ops') → Embeds StaffView(isEmbedded: true)
  │
  Same flow as Staff role (see section 5)
  │
  FUTURE API: GET /api/v1/admin/rooms/housekeeping
             PUT /api/v1/admin/rooms/housekeeping/{id}
```

---

### 3. CUSTOMER

#### 3.1 Browse Properties

```
Screen: customer_view.dart (tab: 'explore')
  │
  On load: ref.watch(resortsListProvider) → List<PropertyDetails>
  │
  Filters (local state, no API):
  ├── Search by text: name, tagline, location, city, state
  ├── Filter by State: unique states from resorts list
  ├── Filter by City: cities in selected state
  └── Category chips: All / Beach / Mountain / Luxury
  │
  Renders: Property card grid with image, name, tagline, pricing, amenities
  │
  FUTURE API: GET /api/v1/customer/properties?search=&state=&city=&category=
```

#### 3.2 View Property Detail

```
Screen: customer_view.dart → Tap on property card → Detail mode
  │
  Shows: hero image, gallery strip, description, pricing grid,
  │      amenities list, property rules
  │
  Gallery images tapped → full-screen hero swap
  │
  FUTURE API: GET /api/v1/customer/properties/{id}
```

#### 3.3 Checkout — Step 1: Booking Details

```
Screen: customer_view.dart → Select dates, guests, apply coupon, fill contact form
  │
  Date selection: checkIn + checkOut via DatePicker
  Guest count: +/- stepper (max 8)
  │
  ▼
  Quote calculation (client-side):
    nights = checkOut - checkIn
    isWeekend = day is Fri/Sat → use weekend price
    baseAmount = sum of nightly rates
    extraGuestAmount = max(0, guests - 2) × extraGuestCharge × nights
    cleaningFee = property.cleaningFee
    taxAmount = (baseAmount + extraGuest + cleaning - discount) × taxRate / 100
    totalAmount = base + extraGuest + cleaning - discount + tax
    advanceAmount = totalAmount × depositRate / 100
  │
  Coupon validation (currently mock, predefined codes):
    "WELCOMEFIXED" → ₹5000 off (min ₹30,000)
    "HAVEN10"     → 10% off (min ₹20,000)
    "EARLYBIRD"   → expired error
  │
  FUTURE API: POST /api/v1/customer/coupons/validate
             Backend: CouponService.validate(code, subtotal) → returns discountAmount or error
```

#### 3.4 Checkout — Step 2: Payment

```
Screen: customer_view.dart → Mock credit card → "Pay" button
  │
  Validates: guestName, guestEmail, guestPhone required
  │
  ▼
CustomerView._handleInitiatePayment()
  │  Creates Booking object with all computed values
  │  ref.read(bookingsProvider.notifier).addBooking(newBooking)
  │  ref.read(notificationsProvider.notifier).addNotification(...)
  │
  FUTURE FLOW:
    1. POST /api/v1/customer/payments/initiate → returns transactionId
    2. POST /api/v1/customer/bookings (with payment proof)
    3. Backend: PaymentService.process() → BookingService.create()
    DB: INSERT INTO bookings, INSERT INTO payments
```

#### 3.5 Checkout — Step 3: Confirmed

```
Screen: customer_view.dart → Shows booking ID, invoice summary, print button
  │
  Reads from: just-created booking in bookingsProvider
  │
  "Print Statement" → SnackBar stub (future: PDF generation)
  "Book Another" → resets to explorer mode
```

#### 3.6 My Trips — View Bookings

```
Screen: dashboard_view.dart (tab: 'trips')
  │
  Filters bookings by: mockProfileProvider['email']
  │
  Two tabs:
  ├── Upcoming Stays: status != cancelled && status != checkedOut
  └── Past History:   status == cancelled || status == checkedOut
  │
  Each card shows: status badge, booking ID, resort name, dates, amount
  │
  FUTURE API: GET /api/v1/customer/bookings?status=upcoming|past
```

#### 3.7 My Trips — View Invoice

```
Screen: dashboard_view.dart → "View Invoice" button per booking
  │
  ▼
Invoice Dialog with full breakdown:
  │  Accommodation, Extra Guest, Cleaning, Discount, GST, Grand Total, Advance Paid, Balance
  │
  FUTURE API: GET /api/v1/customer/bookings/{id} (includes invoice.breakdown)
```

#### 3.8 My Trips — Cancel Booking

```
Screen: dashboard_view.dart → "Cancel Stay" → Bottom Sheet
  │
  Shows: refund policy, refund estimate (100% of advance if 48h+ before check-in)
  User enters: reason for cancellation → taps "Request Cancel"
  │
  ▼
CustomerDashboardView._handleCancelBooking()
  │  ref.read(bookingsProvider.notifier).cancelBooking(id, reason, 100)
  │  Notification: "Trip Cancelled"
  │
  FUTURE API: POST /api/v1/customer/bookings/{id}/cancel
             { "reason": "..." }
  Backend: BookingService.cancel() → RefundService.calculate() → status='cancelled'
  DB: UPDATE bookings SET status='cancelled', ...
```

#### 3.9 Saved / Wishlist

```
Screen: saved_view.dart (tab: 'saved')
  │
  Reads: ref.watch(savedPropertiesProvider) → List<PropertyDetails>
  │
  Tap heart icon (in explore or saved view):
  │
  ├── Add:    ref.read(savedPropertiesProvider.notifier).toggleSave(property)
  └── Remove: same toggle
  │
  FUTURE API: GET  /api/v1/customer/favorites
             POST /api/v1/customer/favorites { "propertyId": "PROP-001" }
             DELETE /api/v1/customer/favorites/PROP-001
  DB: INSERT INTO saved_properties / DELETE FROM saved_properties
```

#### 3.10 Profile — View & Edit

```
Screen: profile_view.dart (tab: 'profile')
  │
  Reads: ref.watch(mockProfileProvider) → name, email, phone
  Stats computed: bookingsProvider filtered by email
  │
  Edit mode: toggle → user edits fields → "Save Changes"
  │
  ▼
  ref.read(mockProfileProvider.notifier).state = { name, email, phone }
  ref.read(notificationsProvider.notifier).addNotification(...)
  │
  FUTURE API: GET /api/v1/customer/profile
             PUT /api/v1/customer/profile (multipart for avatar)
             GET /api/v1/customer/stats
  DB: UPDATE users SET name=?, email=?, phone=?, avatar=? WHERE id=?
```

#### 3.11 Calendar — Availability

```
Screen: calendar_view.dart (tab: 'calendar')
  │
  Reads: bookingsProvider + calendarBlocksProvider
  │
  Computes day-by-day matrix:
  ├── Booked → if booking overlaps this date
  ├── Blocked → if calendar block overlaps this date
  ├── Pending → if booking with pendingPayment overlaps
  ├── OTA → if booking.source is OTA channel
  └── Available → everything else
  │
  Tap day cell → dialog with booking details or block reason
  │
  FUTURE API: GET /api/v1/customer/calendar/availability?propertyId=&from=&to=
  Backend: CalendarService.getAvailability() → merges bookings + blocks → day array
```

#### 3.12 WhatsApp Concierge

```
Screen: portal_shell_screen.dart → Green FAB (customer only)
  │
  ▼
  Tries: whatsapp://send?phone=919876543210&text=...
  Falls back to: https://wa.me/919876543210?text=...
  │
  FUTURE API: POST /api/v1/customer/concierge/message
             (logs the inquiry for tracking)
```

---

### 4. ACCOUNTANT

#### 4.1 Dashboard KPIs

```
Screen: accountant_view.dart
  │
  Auto-computes from bookingsProvider:
  │
  ├── Total Booked Gross     = sum(bookings.totalAmount)
  ├── Total Cash Collected   = sum(bookings.advancePaidAmount)
  ├── Balance Receivable     = sum(bookings.balanceAmount)
  └── Refunds Queue Count    = bookings where cancelled AND not refunded
  │
  API: GET /api/v1/accountant/dashboard/kpis?propertyId=PROP-001
```

#### 4.2 Refunds Queue — Process Refund

```
Screen: accountant_view.dart → Pending Refunds Queue section
  │
  Each refund card shows: guestName, bookingId, stay period, refundAmount, reason
  │
  User taps "Clear & Process Refund"
  │
  ▼
  ref.read(bookingsProvider.notifier).processRefund(bookingId)
  │  Changes: paymentStatus → refunded
  │  Notification: "Refund Settled"
  │  #B91C1C (red) button with white text
  │
  FUTURE API: POST /api/v1/accountant/refunds/{id}/process
  DB: UPDATE bookings SET payment_status='refunded' WHERE id=?
```

#### 4.3 Invoices Ledger — Filter & View

```
Screen: accountant_view.dart → Corporate Invoices Ledger section
  │
  Filter: paymentStatus dropdown (All/Paid/Partially/Refunded/Pending)
  Search: by guest name or booking ID
  │
  Renders: Desktop table (6 columns) or Mobile cards
  │
  Tap "View paper" → Invoice dialog with full billing breakdown
  │
  FUTURE API: GET /api/v1/accountant/invoices?paymentStatus=&search=&page=
             GET /api/v1/accountant/invoices/{id}
```

#### 4.4 Export Ledger

```
Screen: accountant_view.dart → Export PDF / Export Excel buttons
  │
  ▼
  SnackBar + Notification: "Ledger exported in {format} format."
  │
  FUTURE API: GET /api/v1/accountant/reports/ledger/pdf
             GET /api/v1/accountant/reports/ledger/excel
  Backend: ReportService.generatePdf(propertyId, from, to) → byte[] → download
```

---

### 5. STAFF

#### 5.1 Roster — Today's View

```
Screen: staff_view.dart (tab: 'roster')
  │
  Auto-computes from bookingsProvider:
  │
  ├── Arrivals Today:    bookings where startDate == today (non-cancelled)
  ├── Departures Today:   bookings where endDate == today (non-cancelled)
  └── Active Lodgers:     bookings where today is between startDate and endDate
  │
  Each arrival shows: guest name, phone, guest count, stay end date, prep notes
  Each departure shows: guest name, total amount, check-in period, cleaning triggered
  │
  FUTURE API: GET /api/v1/staff/roster?propertyId=&date=
  Backend: RosterService.getDailyRoster() → 3 filtered lists from bookings
```

#### 5.2 Housekeeping — View All Rooms

```
Screen: staff_view.dart (tab: 'housekeeping')
  │
  Reads: ref.watch(roomsProvider) → List<RoomStatus>
  │
  Grid/List view based on screen width (4 cols desktop, 2 tablet, 1 mobile)
  │
  Each room card shows: name, status badge (clean/cleaning/dirty), notes, assigned staff, last updated
  │
  FUTURE API: GET /api/v1/staff/rooms/housekeeping?propertyId=
  Backend: RoomService.getHousekeepingStatuses()
```

#### 5.3 Housekeeping — Update Room Status

```
Screen: staff_view.dart → Tap "Adjust status" → Dialog
  │
  User selects: status (clean/cleaning/dirty), assigned staff, notes
  │
  ▼
  ref.read(roomsProvider.notifier).updateHousekeeping(id, status, notes:, staff:)
  │  Updates RoomStatus in-memory
  │  If status == clean: Notification "Room Verified Clean"
  │  SnackBar: "Updated condition logs for {room.name}."
  │
  Status color coding:
  ├── clean:    Emerald (#D1FAE5 / #065F46)
  ├── cleaning: Amber  (#FEF3C7 / #92400E)
  └── dirty:    Red    (#FEE2E2 / #991B1B)
  │
  FUTURE API: PUT /api/v1/staff/rooms/{id}/housekeeping
             { "status": "cleaning", "assignedStaff": "Rohit Verma", "notes": "..." }
  DB: UPDATE rooms SET housekeeping_status=?, assigned_staff=?, notes=?, last_updated=NOW()
```

---

## Cross-Cutting Features

### Notifications (All Roles)

```
Any action → ref.read(notificationsProvider.notifier).addNotification(title, message, type)
  │
  Types: 'booking', 'payment', 'staff', 'ota', 'system'
  │
  Portal shell header shows unread count badge
  Notification dropdown panel (desktop) or bell icon (mobile)
  │
  Tap notification → markAsRead(id)
  │
  FUTURE API: GET /api/v1/{role}/notifications
             PUT /api/v1/{role}/notifications/{id}/read
             PUT /api/v1/{role}/notifications/read-all
  DB: INSERT INTO notifications / UPDATE notifications SET read=true
```

### Property Switching (Admin, Accountant, Staff)

```
Header ribbon → DropdownButton of properties
  │
  ref.read(propertyProvider.notifier).updateProperty(newProperty)
  │  Entire view rebuilds with new property context
  │  Notification: "Context Switched"
  │
  FUTURE API: GET /api/v1/{role}/properties
             PUT /api/v1/{role}/properties/{id}/activate
```

### Quote Calculation Flow

```
Customer selects dates + guests → screen calls _calculateQuote()
  │
  Inputs: PropertyDetails, PricingSeasonRule[], taxRate, depositRate, coupon
  │
  Calculation:
    for each night:
      isWeekend → use weekend price (else weekday)
      if seasonal rule active + dates overlap → use rule's price/multiplier
    baseAmount = sum of nightly rates
    extraGuestAmount = max(0, guests - 2) × extraGuestCharge × nights
    cleaningFee = property.cleaningFee
    discount = coupon value (percentage or fixed)
    taxAmount = (base + extraGuest + cleaning - discount) × taxRate / 100
    totalAmount = base + extraGuest + cleaning - discount + tax
    advanceAmount = totalAmount × depositRate / 100
    balanceAmount = totalAmount - advanceAmount
  │
  Providers consumed: propertyProvider, pricingRulesProvider, taxRateProvider, depositRateProvider
  │
  FUTURE: All pricing logic moves to backend.
         POST /api/v1/customer/pricing/calculate
         { propertyId, startDate, endDate, guestsCount, couponCode }
         → { baseAmount, extraGuestAmount, discountAmount, taxAmount, totalAmount, advanceAmount }
```

---

## Database Table Relationships

```
users ──1:N──> bookings
  │              │
  │              ├──> properties (via property_id)
  │              └──> coupons (via coupon_applied)
  │
  └──1:1──> user_profile
  │
  └──1:N──> notifications (via user_id)

properties ──1:N──> calendar_blocks
     │              │
     ├──1:N──> bookings
     ├──1:N──> pricing_rules
     ├──1:N──> rooms
     ├──1:N──> coupons
     ├──1:N──> ota_channels
     └──1:N──> property_images

role_definitions ──1:N──> role_permissions
     │
     └──1:N──> users (via role)

approval_requests
  ├── requested_by ──> users
  └── approved_by  ──> users

audit_logs ──N:1──> users

saved_properties
  ├── user_id ──> users
  └── property_id ──> properties
```

---

## Request Lifecycle Summary

```
┌─────────────────────────────────────────────────────────┐
│                    MOBILE APP (Flutter)                  │
│                                                         │
│  User Action → Screen calls Provider method             │
│                     ↓                                   │
│  Provider/Notifier → Repository interface method         │
│                     ↓                                   │
│  Repository Impl → HTTP Client (Dio)                     │
│                     ↓                                   │
│  POST/GET/DELETE to https://api.vspnest.com/api/v1/...  │
│  Headers: { Authorization: Bearer <jwt> }               │
└─────────────────────────────────────────────────────────┘
                           │
                           ↓
┌─────────────────────────────────────────────────────────┐
│              SPRING BOOT BACKEND                         │
│                                                         │
│  JwtAuthFilter ──> validate token                        │
│       ↓                                                  │
│  RestController ──> @PreAuthorize(role/permission)       │
│       ↓                                                  │
│  ServiceLayer ──> business logic, validation             │
│       ↓                                                  │
│  JpaRepository ──> SQL query                             │
│       ↓                                                  │
│  PostgreSQL ──> execute + return result                  │
└─────────────────────────────────────────────────────────┘
                           │
                           ↓
┌─────────────────────────────────────────────────────────┐
│                    RESPONSE                              │
│                                                         │
│  JSON { success: true, data: {...} }                    │
│  or                                                     │
│  JSON { success: false, error: { code, message } }      │
│                                                         │
│  Provider receives response → updates state             │
│  Riverpod triggers UI rebuild                           │
│  User sees updated data                                 │
└─────────────────────────────────────────────────────────┘
```

---

## State Management Diagram (Riverpod)

```
                    ┌─────────────────┐
                    │  User Action    │
                    └────────┬────────┘
                             │
                             ▼
              ┌───────────────────────────┐
              │    Screen (Widget)        │
              │  ref.read(provider).method │
              └────────────┬──────────────┘
                           │
              ┌────────────▼──────────────┐
              │  StateNotifier<Provider>   │
              │  1. Call repository        │
              │  2. Mutate state           │
              │  3. state = newList        │
              └────────────┬──────────────┘
                           │
              ┌────────────▼──────────────┐
              │  Riverpod Rebuilds         │
              │  All widgets watching      │
              │  this provider re-render   │
              └────────────┬──────────────┘
                           │
              ┌────────────▼──────────────┐
              │  Screen Rebuilds           │
              │  Shows updated data        │
              └───────────────────────────┘

Provider Dependency Chain:

  propertyProvider
       │
       ├── bookingsProvider ──> dashboard_view (customer trips)
       │         │                  admin_view (kpis, matrix)
       │         │                  accountant_view (ledger, refunds)
       │         │                  staff_view (roster)
       │         │
       ├── calendarBlocksProvider ──> admin_view (blocks tab)
       │         │                      customer calendar_view
       │         │
       ├── couponsProvider ──> admin_view (coupons tab)
       │         │              customer_view (checkout validation)
       │         │
       ├── pricingRulesProvider ──> admin_view (tariffs tab)
       │         │                    customer_view (quote calc)
       │         │
       ├── roomsProvider ──> staff_view (housekeeping tab)
       │         │            admin_view (staff_ops tab)
       │         │
       ├── otaSyncProvider ──> admin_view (ota tab)
       │
       ├── resortsListProvider ──> super_admin_view (dashboard)
       │         │                    admin_view (property selector)
       │         │                    customer_view (explore)
       │         │
       ├── usersProvider ──> login_screen (auth)
       │         │            super_admin_view (user management)
       │         │
       ├── notificationsProvider ──> portal_shell (bell icon + dropdown)
       │
       ├── taxRateProvider ──> customer_view (quote calc)
       │                        admin_view (settings)
       │
       ├── depositRateProvider ──> customer_view (quote calc)
       │                           admin_view (settings)
       │
       └── savedPropertiesProvider ──> customer saved_view
```
