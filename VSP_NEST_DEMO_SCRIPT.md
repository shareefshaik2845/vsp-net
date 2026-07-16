# VSP Nest Portal — Complete Demo Walkthrough
## For Client / Operational Manager (Non-Technical)

---

## PART 1: LOGIN & AUTHENTICATION

---

### Screen: Splash Screen
**File:** `lib/presentation/screens/splash_screen.dart`

| Element | Details |
|---------|---------|
| **What user sees** | App logo "VSP Nest" brand with fade-in animation. Dark green background with gold accents. |
| **What happens** | After 2.5 seconds, system checks if user already has a saved session (token). |
| **If already logged in** | System calls `/api/auth/me` to verify session is still valid. If valid → directly enter the Portal. If expired → show Login screen. |
| **If new user** | Auto-navigate to Login screen. |

**Demo tip:** Start by clearing the app data so you enter the Login screen naturally.

---

### Screen: Login Screen
**File:** `lib/presentation/screens/login_screen.dart`

| Element | Details |
|---------|---------|
| **Title** | "Sanctuary Portal" |
| **Subtitle** | "Sign in to access the sanctuary portal." |
| **Form fields** | Email address field (`hint: "Enter email address"`) + Password field (`hint: "Enter password"`) |
| **Primary button** | "**Access Sanctuary Portal**" (golden button) |
| **Links** | "Forgot Password?" (left) · "Request a Live Demo" (right) |
| **Background** | Dark emerald gradient with subtle gold glow effects |
| **Brand header** | Logo + "VSP NEST" + tagline: "AUTHENTIC SANCTUARIES" |

**Login flow:**
1. User enters email + password
2. Taps "Access Sanctuary Portal"
3. System calls `POST /api/auth/login`
4. If success → system reads user's role from the response
5. Auto-routes to the correct dashboard for that role:
   - Super Admin → `/super-admin`
   - Admin → `/admin`
   - Staff → `/staff`
   - Accountant → `/accountant`
   - Customer → `/customer`
6. If failure → shows error message inline

**Data flow:** Login sets global `activeRole` + `authenticatedRole` providers. These drive what the Portal Shell shows next.

---

### Screen: First-Time Setup (Install)
**File:** `lib/presentation/screens/install_screen.dart`

| Element | Details |
|---------|---------|
| **Purpose** | One-time setup to create the first Super Admin account |
| **Form fields** | Name · Email · Password · Confirm Password |
| **Button** | "Set Up" |
| **Flow** | Calls `POST /api/auth/setup` → success → redirect to Login → Super Admin logs in |

**Demo tip:** Only needed for fresh installations. In demo, you can skip this and log in with a pre-created account.

---

## PART 2: PORTAL SHELL (Shared by All Roles)

**File:** `lib/presentation/screens/portal_shell_screen.dart`

| Element | Mobile | Desktop (≥1000px) |
|---------|--------|-------------------|
| **Navigation** | Bottom bar (Customer only: Explore, Saved, Trips, Profile) | Left sidebar (290px, green) |
| **Header** | Top bar with role name, notification bell, logout | N/A (sidebar covers it) |
| **Notifications** | Bell icon with unread count → dropdown panel | Same |
| **Role Switcher** | Super Admin can switch to preview any role | Same |

**What renders inside:** Based on `activeRole`:
- Customer → one of 5 sub-views depending on tab
- Admin → AdminView
- Staff → StaffView
- Accountant → AccountantView
- Super Admin → SuperAdminView

---

## PART 3: CUSTOMER MODULE (5 Views)

---

### View 1: Explore / Browse Resorts
**File:** `lib/presentation/screens/customer/customer_view.dart`

| Element | Details |
|---------|---------|
| **What it does** | Browse all available resorts with search and filters |
| **Filters** | State dropdown, City dropdown, Category (All / Beach / Mountain / Luxury) |
| **Search** | Free-text search by name, tagline, location, city, state |
| **Results** | Resort cards with: image, name, tagline, location, weekday price starting rate |
| **Tap a resort** | Opens detail panel with: full description, amenities list, gallery images, pricing rules |
| **Booking section** | Below details: Date picker (start/end), Guest count, Coupon code field with "Apply" button |
| **Price calculation** | Shows live quote: nights breakdown (weekday vs weekend), base amount, extra guest charges, cleaning fee, discount, tax (18%), total amount, required advance deposit (30%) |
| **Checkout flow** | Button "Proceed to Checkout" → Contact Details form (name, email, phone, special requests) → "Complete Payment" → Confirmation screen |

**Booking flow (detailed):**
1. User selects dates + number of guests
2. System calculates price using: base price × season multiplier (monsoon/peak) + extra guest charges + cleaning fee − coupon discount + 18% tax
3. User enters coupon code → validates via `POST /api/customer/coupons/validate`
4. User fills contact details → taps "Complete Payment"
5. System calls `POST /api/customer/bookings` to create booking
6. System calls `POST /api/customer/bookings/{id}/payment` with `paymentMethod: credit_card`
7. Booking appears in **Trips** tab immediately

**Data flows OUT:**
- Saved/Favorited → appears in **Saved** tab
- Booking created → appears in **Trips** tab
- Cancellation → reflects in Admin's booking matrix + Accountant's refund queue
- Coupon applied → validates against Admin-created coupons

---

### View 2: Calendar / Availability
**File:** `lib/presentation/screens/customer/calendar_view.dart`

| Element | Details |
|---------|---------|
| **What it shows** | Monthly calendar view for a selected property |
| **Data** | Available dates, booked dates, blocked dates |
| **Source** | `GET /api/customer/calendar/blocks` + `GET /api/customer/calendar/availability` |
| **Affected by** | Admin blocking dates ← changes reflected here |

---

### View 3: Saved / Wishlist
**File:** `lib/presentation/screens/customer/saved_view.dart`

| Element | Details |
|---------|---------|
| **Empty state** | Heart icon + "No Saved Resorts Yet" + hint "Tap the heart icon on a resort to save it to your wishlist." |
| **With data** | "Your Saved Sanctuaries" heading + list of favorited resort cards |
| **Source** | `savedPropertiesProvider` — toggled from Explore view (heart icon on resort cards or detail panel) |

---

### View 4: Trips / Dashboard
**File:** `lib/presentation/screens/customer/dashboard_view.dart`

| Element | Details |
|---------|---------|
| **Header** | "My Trips" + subtitle: "Track active check-ins, upcoming stays, download statements, and cancel reservations." |
| **Tabs** | "Upcoming Stays (N)" and "Past History (N)" |
| **Booking card** | Shows: status badge (CONFIRMED/CANCELLED/PENDING), booking ID, resort name, date range + nights, guest count, total amount paid |
| **Actions** | "**View Invoice**" button (opens modal with invoice details: subtotal, tax, discount, total, due date, paid date, status) |
| | "**Cancel Stay**" button (red — only for upcoming, non-cancelled bookings) |
| **Cancellation flow** | Opens bottom sheet → shows cancellation policy: "Cancel before 48 hours of check-in for a full 100% refund of your advance deposit. Inside 48 hours, a 30% retention fee applies." |
| | Shows: deposit paid, refund rate eligibility (100%), estimated refund |
| | User enters reason → taps "Request Cancel" |
| | System calls `POST /api/customer/bookings/{id}/cancel` |
| | Notification sent to Admin/Accountant |

**Data flows OUT:**
- Cancellation → Admin's booking matrix updates status → Accountant's refund queue gets a new entry
- Invoice view → pulls from `GET /api/customer/invoices`

---

### View 5: Profile
**File:** `lib/presentation/screens/customer/profile_view.dart`

| Element | Details |
|---------|---------|
| **What user sees** | Avatar (name initials), Name, Email, Phone number |
| **Edit fields** | Name, Email, Phone |
| **Save** | "**Save Profile**" button → calls `PUT /api/customer/profile` |
| **Password change** | Current Password + New Password fields → "**Change Password**" button → calls `PUT /api/customer/profile/password` |
| **Source** | `GET /api/customer/profile` on load |

---

## PART 4: ADMIN MODULE (7 Sections)

**File:** `lib/presentation/screens/admin/admin_view.dart`

### Section 1: Analytics Board (kpis)
| Element | Details |
|---------|---------|
| **Tab label** | "Analytics Board" |
| **What it shows** | Revenue chart (6-week trend), occupancy stats, booking sources breakdown, active bookings count, pending tasks |
| **Source** | `GET /api/admin/dashboard` |

### Section 2: Calendar Blocking (blocks)
| Element | Details |
|---------|---------|
| **Tab label** | "Calendar Blocking" |
| **What it shows** | Monthly calendar with blocked dates highlighted |
| **Action** | Add/remove date blocks |
| **Source** | `GET /api/admin/calendar/blocks` · `POST /api/admin/calendar/blocks` · `DELETE /api/admin/calendar/blocks/{id}` |
| **Reflects to** | Customer's calendar view → they see blocked dates as unavailable |

### Section 3: Booking Matrix (orders)
| Element | Details |
|---------|---------|
| **Tab label** | "Booking Matrix" |
| **What it shows** | All bookings across the property with status, guest info, dates, payment status |
| **Actions** | Update status (confirm, check-in, check-out, cancel), authorize payment |
| **Source** | `GET /api/admin/bookings` · `PUT /api/admin/bookings/{id}/status` |
| **Reflects to** | Customer's Trips tab → status changes visible immediately |

### Section 4: Tariffs / Seasonality (tariffs)
| Element | Details |
|---------|---------|
| **Tab label** | "Tariffs / Seasonality" |
| **What it shows** | Seasonal pricing rules with date ranges and multipliers |
| **Actions** | Create, edit, delete pricing rules |
| **Source** | `GET /api/admin/pricing/rules` · `POST/PUT/DELETE` |
| **Reflects to** | Customer's price quote calculation → seasonal rates applied automatically |

### Section 5: Coupons Editor (coupons)
| Element | Details |
|---------|---------|
| **Tab label** | "Coupons Editor" |
| **What it shows** | List of coupons with code, discount, expiry |
| **Actions** | Create, edit, delete coupons |
| **Source** | `GET /api/admin/coupons` · `POST/PUT/DELETE` |
| **Reflects to** | Customer's checkout → coupon validation against these codes |

### Section 6: OTA Synergy (ota)
| Element | Details |
|---------|---------|
| **Tab label** | "OTA Synergy" |
| **What it shows** | OTA channel sync status (Airbnb, Booking.com, etc.) |
| **Action** | Trigger manual sync per channel |
| **Source** | `GET /api/admin/ota/channels` · `PUT /api/admin/ota/channels/{id}/sync` |

### Section 7: Resort Operations (staff_ops)
| Element | Details |
|---------|---------|
| **Tab label** | "Resort Operations" |
| **What it shows** | Embeds the Staff View (same UI as Staff module) |
| **Purpose** | Admin can see what Staff sees — guest roster + housekeeping board |

---

## PART 5: STAFF MODULE (2 Groups)

**File:** `lib/presentation/screens/staff/staff_view.dart`

### Group 1: Guest Transit Manifest (roster)
| Element | Details |
|---------|---------|
| **Toggle button** | "**Guest Transit manifest**" |
| **What it shows** | Arrivals today (check-in), Departures today (check-out), Currently lodged guests (active stays) |
| **Source** | `GET /api/staff/roster` (filtered from bookings data) |

### Group 2: Housekeeping Status Board (housekeeping)
| Element | Details |
|---------|---------|
| **Toggle button** | "**Housekeeping status board (N Pending)**" |
| **What it shows** | Room list with status: Clean / Cleaning / Dirty |
| **Actions** | Mark room as clean/dirty, assign staff, add notes |
| **Source** | `GET /api/staff/rooms/housekeeping` · `PUT /api/staff/rooms/{id}/housekeeping` |
| **Reflects to** | Admin's Resort Operations tab → same status visible |

**Data flow:**
- Admin changes room status → Staff sees it
- Staff marks cleaned → Admin dashboard pending count decreases

---

## PART 6: ACCOUNTANT MODULE (4 Sections)

**File:** `lib/presentation/screens/accountant/accountant_view.dart`

### Section 1: Dashboard KPIs
| Element | Details |
|---------|---------|
| **What it shows** | Revenue summary, booking financial KPIs |
| **Source** | `GET /api/accountant/dashboard/kpis` |

### Section 2: Booking Ledger
| Element | Details |
|---------|---------|
| **What it shows** | All bookings with financial data: payment status, amounts, dates |
| **Filters** | By payment status (paid/partially paid/pending/refunded) |
| **Source** | `GET /api/accountant/bookings` |
| **Tap a booking** | Shows detailed invoice with line items |

### Section 3: Refunds Queue
| Element | Details |
|---------|---------|
| **What it shows** | Pending refunds from cancelled bookings |
| **Action** | "**Process Refund**" button → marks refund as processed |
| **Source** | `GET /api/accountant/refunds` · `PUT /api/accountant/refunds/{id}/process` |
| **Reflects to** | Customer cancellation → new entry appears here |

### Section 4: Invoice Editor
| Element | Details |
|---------|---------|
| **What it shows** | Invoice details for a selected booking |
| **Action** | Update invoice fields (status, amounts) |
| **Source** | `GET /api/accountant/invoices/{id}` · `PUT /api/accountant/invoices/{id}` |
| **Export** | Ledger PDF/Excel download buttons |

---

## PART 7: SUPER ADMIN MODULE (7 Tabs)

**File:** `lib/presentation/screens/super_admin/super_admin_view.dart`

### Tab 1: Dashboard
| Element | Details |
|---------|---------|
| **Tab label** | "Dashboard" |
| **What it shows** | Global analytics across ALL properties: revenue trends, booking sources chart (Airbnb/Booking.com/Direct/Agoda/etc.), resort-wise revenue table |
| **Source** | `GET /api/super-admin/analytics/revenue` · `booking-sources` · `resort-revenue-table` |

### Tab 2: Properties Management
| Element | Details |
|---------|---------|
| **What it shows** | List of all properties/resorts with CRUD operations |
| **Actions** | Add new resort (name, tagline, description, location, pricing), edit, delete, upload cover image + gallery photos |
| **Source** | `GET/POST/PUT/DELETE /api/super-admin/properties` |
| **Reflects to** | EVERY role sees these properties — this is the master data source |

### Tab 3: User Management
| Element | Details |
|---------|---------|
| **Tab label** | "User Management" |
| **What it shows** | All users across the system with role, status, search/filter |
| **Actions** | Create user (name, email, password, role selection), edit, activate/deactivate, delete |
| **Roles available** | Super Admin, Admin, Staff, Accountant, Customer |
| **Source** | `GET/POST/PUT/DELETE /api/super-admin/users` |
| **Reflects to** | New users can log in immediately. Status change locks out users. |

### Tab 4: Roles & Permissions
| Element | Details |
|---------|---------|
| **Tab label** | "Roles & Permissions" |
| **What it shows** | RBAC matrix: each role's permissions per resource |
| **Actions** | Edit permissions, display name, description per role |
| **Source** | `GET/PUT /api/super-admin/roles` |
| **Reflects to** | Controls what each role can see/do across the entire app |

### Tab 5: Audit Logs
| Element | Details |
|---------|---------|
| **Tab label** | "Audit Logs" |
| **What it shows** | Chronological log of all user actions with filters (user ID, action type, date range) |
| **Source** | `GET /api/super-admin/audit-logs` |

### Tab 6: Notifications
| Element | Details |
|---------|---------|
| **Tab label** | "Notifications" |
| **What it shows** | System-wide notifications list |
| **Actions** | Create and broadcast notification, mark as read |
| **Source** | `GET/POST/PUT/DELETE /api/super-admin/notifications` |
| **Reflects to** | All users see these in their notification bell dropdown |

### Tab 7: Global Settings
| Element | Details |
|---------|---------|
| **What it shows** | System settings, database schema viewer, factory reset |
| **Source** | `GET/PUT /api/super-admin/settings` · `POST /api/super-admin/system/factory-reset` |

---

## PART 8: COMPLETE END-TO-END DEMO SCRIPT (15 Minutes)

### Flow to demonstrate:

```
Step 1 — Super Admin: Systems Overview (2 min)
  Login as superadmin@vspnest.com
  → Dashboard: Show revenue trends, booking sources (Pie chart: Direct 60%, 
     Airbnb 25%, Booking.com 15%)
  → Users: Show all registered users
  → Roles: Show permission matrix

Step 2 — Super Admin: Add a New Resort (1 min)
  → Properties → "Add Resort"
  → Fill: Name "Vista Valley Resort", Tagline "Premium Mountain Getaway",
     Location "Manali, Himachal Pradesh", Base price ₹12,000
  → Upload cover photo + gallery
  → Save → Resort appears in Explore for all Customers

Step 3 — Switch to Admin (1 min)
  Super Admin uses role switcher → select "Admin"
  → Properties → Select "Vista Valley Resort"
  → Tariffs → Add seasonal rule: "Monsoon Discount" (June-Sep, 0.8x multiplier)
  → Coupons → Create "WELCOME20" (20% off)
  → Calendar → Block Dec 24-26 (Christmas unavailable)

Step 4 — Switch to Customer: Browse & Book (3 min)
  → Explore tab → See "Vista Valley Resort" in list
  → Tap → See details, amenities, gallery
  → Select dates (Nov 15-18, 3 nights)
  → Price calculation shows: 2 weekday + 1 weekend night, 
     base ₹36,000 + cleaning ₹1,500 + tax = ₹44,250
  → Enter coupon "WELCOME20" → Apply → ₹7,200 off
  → Fill contact details → "Complete Payment"
  → Confirmation screen → Booking ID displayed

Step 5 — Customer: View Trip & Cancel (1 min)
  → Trips tab → See the new booking with "CONFIRMED" status
  → "View Invoice" → Shows invoice breakdown
  → "Cancel Stay" → Enter reason → "Request Cancel"
  → Status changes to "CANCELLED"

Step 6 — Switch to Admin: See the Cancellation (1 min)
  → Booking Matrix → Booking shows "CANCELLED" status
  → Resort Operations → Room availability updated

Step 7 — Switch to Accountant: Process Refund (1 min)
  → Refunds Queue → See new pending refund
  → "Process Refund" → Mark as processed

Step 8 — Switch to Staff: Daily Ops (1 min)
  → Guest Transit → See today's arrivals/departures
  → Housekeeping → Mark rooms as clean/dirty

Step 9 — Super Admin: Audit Trail (1 min)
  → Audit Logs → Show all actions performed in this demo
     (user created, resort added, booking made, booking cancelled, 
      refund processed)
  → Notifications → Broadcast a system message

Step 10 — Q&A (2 min)
```

---

## PART 9: KEY DATA FLOW DIAGRAMS

### Booking Lifecycle:
```
[Customer Explore] → Select Resort → Choose Dates → Apply Coupon
       ↓
  [Customer Checkout] → Fill Details → Pay → Booking Created
       ↓
  [Admin Booking Matrix] → Confirm Booking → Mark Check-in
       ↓
  [Staff Guest Transit] → See arrival → Prepare Room
       ↓
  [Staff Housekeeping] → Mark Room Clean
       ↓
  [Admin Dashboard] → Occupancy metrics update
       ↓
  [Accountant Ledger] → Invoice generated → Payment tracked
```

### Cancellation Lifecycle:
```
[Customer Trips] → Request Cancel (with reason)
       ↓
  [Admin Booking Matrix] → Status changes to CANCELLED
       ↓
  [Accountant Refunds Queue] → New pending refund entry
       ↓
  [Accountant] → Process Refund → Refund marked complete
       ↓
  [Customer] → Sees refund status in booking history
```

### Notification Flow:
```
[Super Admin / Admin] → Create Notification
       ↓
  [All Users' Bell Icon] → Unread badge increments
       ↓
  [User] → Taps bell → Reads notification → Marks as read
```

### Pricing Rule Flow:
```
[Admin Tariffs] → Create/Edit seasonal pricing rule
       ↓
  [Customer Explore] → Price quote auto-uses the rule multiplier
       ↓
  Quote shows "Monsoon Discount applied" with adjusted pricing
```

### Coupon Flow:
```
[Admin Coupons] → Create coupon code (e.g., "WELCOME20")
       ↓
  [Customer Explore] → Enters coupon code → Validates
       ↓
  Quote updates with discount → User sees savings
```

---

## PART 10: KEY METRICS FOR MANAGER'S ATTENTION

| Metric | Where to See | Business Meaning |
|--------|-------------|-----------------|
| Booking count per resort | Super Admin Dashboard, Admin Analytics | Occupancy health |
| Revenue by source | Super Admin Dashboard (booking-sources) | Which channels drive bookings (Direct vs OTA) |
| Seasonal pricing rules | Admin Tariffs | Peak/off-peak revenue optimization |
| Pending housekeeping | Staff Housekeeping board | Room turnaround efficiency |
| Refund queue | Accountant Refunds | Outstanding financial obligations |
| Audit logs | Super Admin Audit Logs | Compliance & governance trail |
| Active users per role | Super Admin Users | System adoption |
| Coupon usage | Admin Coupons | Marketing effectiveness |

---

## FILES REFERENCED (For Technical Team)

| Screen | File Path | Lines |
|--------|-----------|-------|
| Splash | `lib/presentation/screens/splash_screen.dart` | 15-42 |
| Login | `lib/presentation/screens/login_screen.dart` | 35-280 |
| Install | `lib/presentation/screens/install_screen.dart` | 12-80 |
| Portal Shell | `lib/presentation/screens/portal_shell_screen.dart` | 28-661 |
| Customer - Explore | `lib/presentation/screens/customer/customer_view.dart` | 9-3195 |
| Customer - Trips | `lib/presentation/screens/customer/dashboard_view.dart` | 9-1091 |
| Customer - Saved | `lib/presentation/screens/customer/saved_view.dart` | 7-174 |
| Customer - Calendar | `lib/presentation/screens/customer/calendar_view.dart` | Full |
| Customer - Profile | `lib/presentation/screens/customer/profile_view.dart` | Full |
| Admin | `lib/presentation/screens/admin/admin_view.dart` | 19-3405 |
| Staff | `lib/presentation/screens/staff/staff_view.dart` | 18-1197 |
| Accountant | `lib/presentation/screens/accountant/accountant_view.dart` | 16-1659 |
| Super Admin | `lib/presentation/screens/super_admin/super_admin_view.dart` | 25-2941 |
| API Routes | `lib/presentation/routing/app_router.dart` | 10-55 |
| Route Names | `lib/presentation/routing/route_names.dart` | 1-13 |
| State Providers | `lib/presentation/providers/state_provider.dart` | 1-530+ |
