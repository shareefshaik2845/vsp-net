# VSP Nest Portal — Complete App Flow
## For Clients, Managers & Stakeholders (No Technical Jargon)

---

## 1. How a User Enters the System

```
Open App → Splash Logo → Login Screen → Enter Email & Password
                                               ↓
                                    System checks your Role
                                               ↓
                    ┌──────────────┬──────────────┬───┴───┬──────────────┐
                    ↓              ↓              ↓       ↓              ↓
              Super Admin      Admin         Staff   Accountant     Customer
```

**Every user sees a different dashboard based on their job.**

---

## 2. Customer Journey (The Guest)

```
                    ┌──────────────────────────────────────────┐
                    │           EXPLORE RESORTS                │
                    │  Browse all properties with photos,      │
                    │  prices, amenities. Filter by city or    │
                    │  category (Beach / Mountain / Luxury).   │
                    └──────────────────┬───────────────────────┘
                                       ↓
                    ┌──────────────────────────────────────────┐
                    │        SELECT DATES & BOOK               │
                    │  Pick check-in / check-out dates.        │
                    │  Enter guest count.                      │
                    │  Apply coupon code (e.g. "WELCOME20").   │
                    │  System shows live price:                │
                    │    • Nightly rates (weekday vs weekend)  │
                    │    • Extra guest charges                 │
                    │    • Cleaning fee                        │
                    │    • Coupon discount                     │
                    │    • Tax (18%)                           │
                    │    • Total amount                        │
                    │    • Advance deposit (30%)               │
                    └──────────────────┬───────────────────────┘
                                       ↓
                    ┌──────────────────────────────────────────┐
                    │        FILL DETAILS & PAY                │
                    │  Enter name, email, phone, requests.     │
                    │  Tap "Complete Payment".                 │
                    │  Booking is created immediately.         │
                    └──────────────────┬───────────────────────┘
                                       ↓
                    ┌──────────────────────────────────────────┐
                    │        MANAGE YOUR TRIPS                 │
                    │  View upcoming stays.                    │
                    │  Download invoices.                      │
                    │  Cancel a stay (if needed).              │
                    │  See past history.                       │
                    └──────────────────────────────────────────┘
```

**Also available:**
- **Saved** tab — bookmark resorts you like
- **Calendar** tab — see availability at a glance
- **Concierge** tab — request airport transfer, dining reservation, spa booking, or other services
  - Choose request type, describe what you need, pick preferred date/time
  - Optionally link to an active booking
  - Staff will be assigned and update you as your request progresses
  - Track status: Pending → In Progress → Completed
- **Profile** tab — edit your name/email/phone, change password

---

## 3. Admin Journey (The Resort Manager)

```
      ┌────────────────────────────────────────────────────────────┐
      │                   ANALYTICS BOARD                         │
      │  See revenue chart (6-week trend), occupancy %,           │
      │  booking sources, pending tasks at a glance.              │
      └──────────────────────┬─────────────────────────────────────┘
                             ↓
      ┌────────────────────────────────────────────────────────────┐
      │                   CALENDAR BLOCKING                       │
      │  Block dates when resort is unavailable (e.g. Christmas). │
      │  Customers immediately see these dates as blocked.        │
      └──────────────────────┬─────────────────────────────────────┘
                             ↓
      ┌────────────────────────────────────────────────────────────┐
      │                   BOOKING MATRIX                         │
      │  See all bookings: confirmed, checked-in, checked-out,   │
      │  cancelled. Update status as guests arrive/depart.       │
      └──────────────────────┬─────────────────────────────────────┘
                             ↓
      ┌────────────────────────────────────────────────────────────┐
      │                   TARIFFS / SEASONALITY                   │
      │  Set peak-season pricing (e.g. 1.5x for Dec-Jan).        │
      │  Set off-season discounts (e.g. 0.8x for monsoon).       │
      │  Customer price quotes automatically use these rules.     │
      └──────────────────────┬─────────────────────────────────────┘
                             ↓
      ┌────────────────────────────────────────────────────────────┐
      │                   COUPONS EDITOR                         │
      │  Create discount codes like "WELCOME20" or "FESTIVE10".  │
      │  Customers enter these at checkout to get discounts.      │
      └──────────────────────┬─────────────────────────────────────┘
                             ↓
      ┌────────────────────────────────────────────────────────────┐
      │                   OTA SYNERGY                            │
      │  Connect to Airbnb, Booking.com, Agoda.                  │
      │  Sync availability across all channels.                  │
      └──────────────────────┬─────────────────────────────────────┘
                             ↓
      ┌────────────────────────────────────────────────────────────┐
      │                   CONCIERGE DESK                         │
      │  See all guest concierge requests across the resort.     │
      │  Accept / Complete / Cancel requests.                    │
      │  Assign requests to specific staff members.              │
      │  Add staff notes for coordination.                       │
      │  Filter by status: All / Pending / In Progress / Completed│
      └──────────────────────┬─────────────────────────────────────┘
                             ↓
      ┌────────────────────────────────────────────────────────────┐
      │                   RESORT OPERATIONS                      │
      │  View the same screen as Staff — guest roster +          │
      │  housekeeping board.                                      │
      └────────────────────────────────────────────────────────────┘
```

---

## 4. Staff Journey (Housekeeping & Operations)

```
      ┌────────────────────────────────────────────────────────────┐
      │              GUEST TRANSIT MANIFEST                      │
      │  See who's arriving today (check-in).                    │
      │  See who's leaving today (check-out).                    │
      │  See currently lodged guests.                            │
      │  Tap "Check In" when a guest arrives.                    │
      │  Tap "Check Out" when a guest departs.                   │
      └──────────────────────┬─────────────────────────────────────┘
                             ↓
      ┌────────────────────────────────────────────────────────────┐
      │              HOUSEKEEPING STATUS BOARD                   │
      │  See each room: Clean / Being Cleaned / Dirty.           │
      │  Mark rooms as cleaned when done.                        │
      │  Add notes (e.g. "Deep clean requested - pet stayed").   │
      │  Admin sees these updates in real-time.                  │
      └──────────────────────┬─────────────────────────────────────┘
                             ↓
      ┌────────────────────────────────────────────────────────────┐
      │              CONCIERGE DESK                              │
      │  View concierge requests assigned to you.                │
      │  Accept a pending request to start working on it.        │
      │  Mark requests as Completed when done.                   │
      │  Add notes to communicate with admin.                    │
      │  Filter by status: All / Pending / In Progress / Completed│
      └────────────────────────────────────────────────────────────┘
```

---

## 5. Accountant Journey (Finance & Invoicing)

```
      ┌────────────────────────────────────────────────────────────┐
      │                    DASHBOARD KPIs                        │
      │  Revenue summary, booking financial overview.            │
      └──────────────────────┬─────────────────────────────────────┘
                             ↓
      ┌────────────────────────────────────────────────────────────┐
      │                    BOOKING LEDGER                        │
      │  All bookings with payment status.                       │
      │  Filter by: Paid / Partially Paid / Pending / Refunded.  │
      │  Tap any booking to see full invoice details.            │
      │  Download reports as PDF or Excel.                       │
      └──────────────────────┬─────────────────────────────────────┘
                             ↓
      ┌────────────────────────────────────────────────────────────┐
      │                    REFUNDS QUEUE                         │
      │  When a customer cancels, a refund entry appears here.   │
      │  Accountant clicks "Process Refund" to complete it.      │
      └──────────────────────┬─────────────────────────────────────┘
                             ↓
      ┌────────────────────────────────────────────────────────────┐
      │                    INVOICE EDITOR                        │
      │  View and edit invoice details for any booking.          │
      │  Update status, mark as paid, adjust amounts.            │
      └────────────────────────────────────────────────────────────┘
```

---

## 6. Super Admin Journey (The Owner / HQ)

```
      ┌────────────────────────────────────────────────────────────┐
      │                    GLOBAL DASHBOARD                      │
      │  Revenue across ALL properties.                          │
      │  Booking sources pie chart (Direct vs Airbnb vs OTA).    │
      │  Resort-wise revenue comparison table.                   │
      └──────────────────────┬─────────────────────────────────────┘
                             ↓
      ┌────────────────────────────────────────────────────────────┐
      │                    PROPERTIES MANAGEMENT                 │
      │  Add new resorts (name, location, photos, pricing).      │
      │  Edit or deactivate existing resorts.                    │
      │  Upload gallery images.                                  │
      │  This is the master data — every role sees these.        │
      └──────────────────────┬─────────────────────────────────────┘
                             ↓
      ┌────────────────────────────────────────────────────────────┐
      │                    USER MANAGEMENT                       │
      │  Create new users for any role.                          │
      │  Activate / deactivate accounts.                         │
      │  Delete users.                                           │
      └──────────────────────┬─────────────────────────────────────┘
                             ↓
      ┌────────────────────────────────────────────────────────────┐
      │                    ROLES & PERMISSIONS                   │
      │  See exactly what each role can access.                  │
      │  Edit permissions (e.g. allow Staff to see invoices).    │
      └──────────────────────┬─────────────────────────────────────┘
                             ↓
      ┌────────────────────────────────────────────────────────────┐
      │                    AUDIT LOGS                            │
      │  Complete log of every action in the system:             │
      │  who did what, when — for compliance & governance.       │
      └──────────────────────┬─────────────────────────────────────┘
                             ↓
      ┌────────────────────────────────────────────────────────────┐
      │                    NOTIFICATIONS                         │
      │  Broadcast messages to all users.                        │
      │  Everyone sees it in their notification bell.            │
      └──────────────────────┬─────────────────────────────────────┘
                             ↓
      ┌────────────────────────────────────────────────────────────┐
      │                    GLOBAL SETTINGS                       │
      │  System configuration, factory reset option.             │
      └────────────────────────────────────────────────────────────┘

**Super Admin has a "Role Switcher"** — can click any role name
to instantly see the app through that person's eyes.
```

---

## 7. How All Roles Connect (End-to-End Flows)

### A Complete Booking Lifecycle

```
CUSTOMER (Guest)        ADMIN (Manager)         STAFF (Ops)          ACCOUNTANT (Finance)
───────────────         ────────────────        ────────────          ────────────────────

BROWSE
Opens app, browses      Sets up properties,
resorts, views photos,  pricing rules,
amenities, availability seasonal tariffs,
                        coupon codes

BOOK
Selects dates, guests,  ── sees booking ──→   ── sees new ──────→   ── sees payment ──→
applies coupon, adds    in Booking Matrix      arrival on Guest      in Booking Ledger
special requests,                              Transit Manifest
taps "Pay"

PAY
Pays total amount       ── confirms ──→
Booking confirmed       payment (Authorize Pay)

────  GUEST ARRIVES  ────

CHECK-IN
Arrives at resort,                             ── Staff clicks
shows ID, gets keys                              "Check In" on
                                                 arrival manifest
                                                 Room marked occupied

STAY
Requests concierge      Sees new request,      Sees assigned
services (transport,    assigns to staff       request, accepts,
dining, spa, etc.)                             updates status,
                        ←── reviews ──────→    adds notes
                        staff notes

────  GUEST DEPARTS  ────

CHECK-OUT
Vacates room                                   ── Staff clicks
                                                 "Check Out"
── invoice finalized ──→                        Room marked vacant
                                                 Housekeeping triggered

────  POST-STAY  ────

REFUND (if cancelled)
Requests cancel                                                  Accountant sees
Reason: "Change of plans"                                        Refund entry
                        ←── refund ────────── ←── refund ──────  Clicks "Process
                          completed            completed           Refund"
── sees refund ──→
confirmed
```

### Concierge Service Flow

```
[GUEST]                               [ADMIN]                         [STAFF]
───────                                ─────                         ──────

Opens Concierge tab                                                    
Selects request type, description,                                    
preferred date/time                                                    
Optionally links to a booking                                         
Taps "Submit"                                                         
                                    Sees new request in               
                                    Concierge Desk tab                
                                    Assigns to available staff  ──→  Sees request in
                                                                      "My Concierge Requests"
                                                                      Taps "Accept"
                                                                      Updates status to "In Progress"
                                    Sees status change               
                                    Can add notes for staff   ←──   Staff adds update notes

                                    Completes request         ←──   Staff marks "Completed"

Guest sees status badges on dashboard:
  🟡 Pending → 🔵 In Progress → 🟢 Completed
```

### How Pricing Rules Flow

```
[ADMIN]                               [GUEST]
────────                               ──────
Creates season rule:
"Monsoon Discount: June-Sep, 20% off"
                                    Browse resort
                                    Select dates in June
                                    Price quote shows:
                                    "Monsoon Discount applied"
                                    Base ₹12,000 → ₹9,600/night
```

### How Coupons Flow

```
[ADMIN]                               [GUEST]
────────                               ──────
Creates coupon "WELCOME20"
(20% off for new guests)
                                    Enter coupon code
                                    System validates it
                                    Price drops by 20%
                                    Guest sees the saving
```

### How Notifications Flow

```
[SUPER ADMIN / ADMIN]                  [ALL USERS]
─────────────────────                  ───────────
Create notification:
"New monsoon packages available!"
                                    Bell icon shows red badge
                                    Tap to read notification
                                    Mark as read
```

### How OTA (Airbnb / Booking.com) Flow Works

```
[ADMIN]                               [CUSTOMERS]
────────                               ──────────
Syncs with Airbnb/Booking.com
Sets availability across channels    Bookings from OTA channels
Shows revenue breakdown:             appear in system automatically
"Direct 60% | Airbnb 25% | B.com 15%"
```

---

## 8. Features Summary by Role

| Role | What They Can Do |
|------|-----------------|
| **Customer** (Guest) | Browse resorts, search/filter, view pricing, book, pay, cancel, view invoices, save favorites, manage profile |
| **Admin** (Resort Manager) | View analytics, block calendar dates, manage bookings (check-in/check-out), set seasonal pricing, create coupons, sync OTA channels, manage concierge requests (assign staff, update status, add notes), oversee staff ops |
| **Staff** (Housekeeping) | View guest arrivals/departures, check guests in/out, manage room cleaning status, add notes, view & manage assigned concierge requests (accept, complete, add notes) |
| **Accountant** (Finance) | View revenue KPIs, booking ledger with filters, process refunds, edit invoices, export reports |
| **Super Admin** (Owner/HQ) | Global dashboard across all properties, manage properties & users, set roles & permissions, view audit logs, broadcast notifications, system settings — can switch to any role to preview |

---

## 9. Quick Stats for Demos

| What | Where to See It |
|------|----------------|
| How many bookings today? | Admin → Booking Matrix |
| Which resorts earn the most? | Super Admin → Dashboard |
| Is a room ready for check-in? | Staff → Housekeeping Board |
| How many refunds pending? | Accountant → Refunds Queue |
| Who changed the pricing last? | Super Admin → Audit Logs |
| Did my coupon code work? | Customer → Checkout price quote |
| Are we blocked for Christmas? | Admin → Calendar Blocking |
| What's our OTA channel revenue? | Admin → OTA Synergy |
| How to check in a guest? | Staff → Guest Transit Manifest → Check In |
| How to check out a guest? | Staff → Guest Transit Manifest → Check Out |
| How to request concierge service? | Customer → Concierge Tab → New Request |
| How to assign staff to a request? | Admin → Concierge Desk → Assign Staff |
| What concierge requests are assigned to me? | Staff → Concierge Desk |
