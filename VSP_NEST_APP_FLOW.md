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
      └──────────────────────┬─────────────────────────────────────┘
                             ↓
      ┌────────────────────────────────────────────────────────────┐
      │              HOUSEKEEPING STATUS BOARD                   │
      │  See each room: Clean / Being Cleaned / Dirty.           │
      │  Mark rooms as cleaned when done.                        │
      │  Add notes (e.g. "Deep clean requested - pet stayed").   │
      │  Admin sees these updates in real-time.                  │
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
[GUEST]                                [SYSTEM]                        [STAFF / ADMIN / ACCOUNTANT]
────────                                ──────                        ────────────────────────────

Browse resorts on Explore  ──────→  Pulls property data from
                                    Super Admin's master list

Select dates & book        ──────→  Calculates price using
                                    Admin's tariff/season rules
                                    Applies coupon if entered   ←── Admin created this coupon

Pay & confirm              ──────→  Booking created                    Admin sees it in Booking Matrix
                                    Payment recorded                   Accountant sees in Ledger

Arrive at resort                    Status: CHECKED_IN          ──→   Staff sees in Guest Transit
                                                                      Housekeeping prepares room

Check out                          Status: CHECKED_OUT         ──→   Invoice finalized
                                                                      Accountant tracks payment

─────────────────────────────────────────────────────────────────────────────────────────────────

[GUEST] Cancels                     Booking → CANCELLED        ──→   Accountant sees Refund Queue
                                    Refund entry created              Processes refund
                                                                      Guest sees updated status
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
| **Admin** (Resort Manager) | View analytics, block calendar dates, manage bookings, set seasonal pricing, create coupons, sync OTA channels, oversee staff ops |
| **Staff** (Housekeeping) | View guest arrivals/departures, manage room cleaning status, add notes |
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
