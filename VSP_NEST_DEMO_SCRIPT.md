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

### Demo Credentials

| Role | Email | Password |
|------|-------|----------|
| Super Admin | `superadmin@vspnest.com` | `Admin@123` |
| Admin | `admin@vspnest.com` | `Admin@123` |
| Staff | `staff@vspnest.com` | `Staff@123` |
| Accountant | `accountant@vspnest.com` | `Acc@123` |
| Customer | `rahul@email.com` | `Guest@123` |

---

### Step-by-Step Walkthrough

---

#### Step 1 — Super Admin: Systems Overview (2 min)

| Action | Expected Screen / Behavior | Validation |
|--------|---------------------------|------------|
| Open app → See Splash logo (2.5s) → Auto-navigate to Login | Dark emerald screen with "VSP NEST" gold logo | Brand animation plays once |
| Enter `superadmin@vspnest.com` / `Admin@123` → Tap "Access Sanctuary Portal" | Loading spinner → Redirects to Super Admin dashboard | URL/route changes to `/super-admin` |
| **Dashboard tab** (default): | 4 KPI cards visible: Total Revenue, Today's Collection, Occupancy %, Active Stays | Numbers should be populated (not zero) |
| Hover/click revenue chart | Tooltip shows weekly revenue (e.g., "Wk 2 (Jul): ₹85,000 INR") | Curve shows upward trend |
| **Users tab:** Click "User Management" | Table showing: `rahul@email.com` (Customer), `admin@vspnest.com` (Admin), `staff@vspnest.com` (Staff), `accountant@vspnest.com` (Accountant) | At least 5 rows visible |
| **Roles tab:** Click "Roles & Permissions" | Matrix grid showing each role with toggle switches per resource (bookings, calendar, coupons, etc.) | Admin has bookings/coupons/pricing enabled; Staff only has rooms |

**🎯 Demo talking point:** *"From this single console, you control every user, every permission, and see analytics across ALL your properties."*

---

#### Step 2 — Super Admin: Add a New Resort (1 min)

| Action | Expected Screen / Behavior | Validation |
|--------|---------------------------|------------|
| Click **Properties** tab → "Add Resort" button | Modal form opens with fields: Name, Tagline, Description, Location, State, City, Base Price (Weekday/Weekend), Extra Guest Charge, Cleaning Fee | Empty form ready |
| Fill fields: | | |
| Name: `Vista Valley Retreat` | Text field populated | |
| Tagline: `Premium Mountain Getaway` | Text field populated | |
| Location: `Manali, Himachal Pradesh` | Text field populated | |
| Description: `A luxury mountain resort with stunning valley views, infinity pool, and spa facilities. Perfect for family getaways and romantic escapes.` | Text area populated | |
| Base Price Weekday: `12000` | Number field | |
| Base Price Weekend: `15000` | Number field | |
| Extra Guest Charge: `2000` | Number field | |
| Cleaning Fee: `1500` | Number field | |
| Tap **Save** | Modal closes → New resort card appears in the properties list | Card shows "Vista Valley Retreat" with location and price |
| Tap **Role Switcher** (top of sidebar) → select **Customer** | Interface changes to Customer layout (5 bottom tabs) | Sidebar replaced by bottom nav |

**🎯 Demo talking point:** *"Properties you create here instantly become bookable by customers across all channels."*

---

#### Step 3 — Admin: Configure Seasons, Coupons & Calendar (2 min)

| Action | Expected Screen / Behavior | Validation |
|--------|---------------------------|------------|
| Tap Role Switcher → select **Admin** | Admin view loads with 7 tab ribbons: Analytics Board, Calendar Blocking, Booking Matrix, Tariffs, Coupons, OTA, Resort Operations | Header shows "Vista Valley Retreat Core Console" |
| Click **Tariffs / Seasonality** tab | Two-column layout: Base Tariffs (left) + Seasonal Rules (right) | Both cards visible |
| Base Tariffs — leave defaults visible | Shows: Weekday ₹12,000 / Weekend ₹15,000 / Extra Guest ₹2,000 / Cleaning ₹1,500 | Values match what Super Admin entered |
| **Seasonal Rules section** — Click "Add Rule" if available or note existing rules | List of season rules if any exist | If empty, point out rules can be added |
| Click **Coupons Editor** tab | Coupon form (left) + Coupon list (right) | |
| Enter Coupon Code: `WELCOME20` | Text field | |
| Select Type: `Percentage Discount` | Dropdown | |
| Value: `20` | Number field | |
| Expiry: Pick a date 90 days from now | Date picker | |
| Usage Limit: `100` | Number field | |
| Min Booking Value: `10000` | Number field | |
| Tap **"Add Coupon to Registry"** | Coupon appears in right-side list with "ACTIVE" badge | New row: `WELCOME20` • `20% off...` • `Usage: 0/100` |
| Click **Calendar Blocking** tab | Calendar block form (left) + Active blocks list (right) | |
| Block Start: Pick `Dec 24, 2026` | Date picker | |
| Block End: Pick `Dec 26, 2026` | Date picker | |
| Reason: Select `holiday` | Radio button selected | |
| Notes: `Christmas holiday — resort closed` | Text area | |
| Tap **"Commit Date Isolation"** | New block appears in Active Blocks list | Shows "2026-12-24 to 2026-12-26 • HOLIDAY" |

**🎯 Demo talking point:** *"Tariffs control dynamic pricing, coupons drive direct bookings, and calendar blocking prevents double-booking during blackout dates."*

---

#### Step 4 — Customer: Browse, Book & Pay (3 min)

| Action | Expected Screen / Behavior | Validation |
|--------|---------------------------|------------|
| Role Switcher → select **Customer** | Customer view loads at **Explore** tab | Bottom nav shows: Explore, Saved, Trips, Profile |
| Search bar — type `Vista Valley` | Resort cards filter in real-time | Only "Vista Valley Retreat" shown |
| Tap **"Vista Valley Retreat"** card | Detail panel slides open with: full image, description, amenities list, gallery | All fields populated |
| Scroll to **Booking Section** | Date pickers + Guest count + Coupon field visible | |
| Check-in: Pick `Nov 15, 2026` | Date picker | |
| Check-out: Pick `Nov 18, 2026` (3 nights) | Date picker | |
| Guests: `2` | Number field | |
| Live quote updates automatically: | | |
| • Nightly breakdown (weekday vs weekend) | Text showing night counts | |
| • Base Amount: `₹39,000` (2 weekdays × ₹12K + 1 weekend × ₹15K) | Calculated value | |
| • Cleaning Fee: `₹1,500` | | |
| • Tax (18%): `₹7,290` | | |
| • **Total: `₹47,790`** | Prominent display | |
| Enter Coupon: `WELCOME20` → Tap **Apply** | Discount appears: `-₹7,800` (20% off base) | Total reduces to `₹39,990` |
| **Required Advance (30%): `₹11,997`** | Shows deposit amount | |
| Tap **"Proceed to Checkout"** | Contact form slides in: Name, Email, Phone, Special Requests | Pre-filled or empty |
| Name: `Rahul Sharma` | | |
| Email: `rahul@email.com` | | |
| Phone: `9876543210` | | |
| Special Requests: `Early check-in preferred, ground floor room` | | |
| Tap **"Complete Payment"** | Loading spinner → Success animation → Confirmation screen | Booking ID displayed (e.g., `B-1712345678901`) |

**🎯 Demo talking point:** *"The entire booking flow — from browsing to paid confirmation — takes under 30 seconds. Dynamic pricing, coupons, and tax all calculated instantly."*

---

#### Step 5 — Customer: View Trip & Cancel (1 min)

| Action | Expected Screen / Behavior | Validation |
|--------|---------------------------|------------|
| Tap **Trips** tab (bottom nav) | Dashboard shows "Upcoming Stays" tab active | Badge shows "(1)" count |
| Booking card visible with: | | |
| • Status badge: `CONFIRMED` (green) | | |
| • Resort: `Vista Valley Retreat` | | |
| • Dates: `2026-11-15 → 2026-11-18` | | |
| • Amount: `₹39,990` | | |
| Tap **"View Invoice"** | Modal shows: Subtotal, Discount, Tax, Total, Paid Amount, Balance, Status | All line items match checkout |
| Close invoice | | |
| Tap **"Cancel Stay"** (red button) | Bottom sheet slides up with: | |
| • Cancellation policy summary (48hrs = 100% refund) | | |
| • Estimated refund: `₹11,997` (full deposit) | | |
| • Reason field | | |
| Enter reason: `Change of travel plans` | | |
| Tap **"Request Cancel"** | Loading → Booking status changes to `CANCELLED` (red) | Cancelled badge visible |

**🎯 Demo talking point:** *"Cancellations flow automatically to the admin and accountant — no manual paperwork."*

---

#### Step 6 — Admin: See Cancellation in Booking Matrix (1 min)

| Action | Expected Screen / Behavior | Validation |
|--------|---------------------------|------------|
| Role Switcher → select **Admin** | Admin Console loads | |
| Click **Booking Matrix** tab | Table with all bookings and filter bar | |
| Find `Rahul Sharma` booking | Row shows: | |
| • Reference ID | | |
| • Guest: `Rahul Sharma` • `9876543210` • `rahul@email.com` | | |
| • Dates: `2026-11-15 to 2026-11-18` | | |
| • Channel: `DIRECT` | | |
| • Payment: `₹39,990` • `Paid: ₹11,997` • `REFUNDED` | | |
| • Status: `CANCELLED` (red badge) | | |
| Status change visible immediately | No refresh needed | |

**🎯 Demo talking point:** *"The booking matrix is the admin's command center — all reservations, cancellations, and payments visible in one place."*

---

#### Step 7 — Accountant: Process Refund (1 min)

| Action | Expected Screen / Behavior | Validation |
|--------|---------------------------|------------|
| Role Switcher → select **Accountant** | Accountant view loads with: Dashboard KPIs, Booking Ledger, Refunds Queue, Invoice Editor tabs | |
| Click **Refunds Queue** tab | List showing pending refunds | |
| Find `Rahul Sharma — Vista Valley Retreat` entry | Shows: Booking ID, Guest Name, Amount: `₹11,997`, Status: `PENDING` | |
| Tap **"Process Refund"** | Loading → Row disappears from pending list | Refund processed |
| Click **Booking Ledger** tab | Find the same booking → Payment Status shows `REFUNDED` | |

**🎯 Demo talking point:** *"Accountant gets an automated refund request the moment a customer cancels. One click processes it."*

---

#### Step 8 — Staff: Daily Operations (1 min)

| Action | Expected Screen / Behavior | Validation |
|--------|---------------------------|------------|
| Role Switcher → select **Staff** | Staff view loads with two toggle groups | |
| Click **"Guest Transit Manifest"** toggle | Shows three sections: | |
| • Arrivals Today (check-in) — if any guests checking in | List of names | |
| • Departures Today (check-out) | List of names | |
| • Currently Lodged — active checked-in guests | List of names | |
| Click **"Housekeeping Status Board"** toggle | Room grid showing: Room name, Status (Clean/Dirty/Cleaning), Assigned Staff, Notes | |
| Find a room → Tap status to toggle | Status cycles: Dirty → Cleaning → Clean | Visual indicator changes color |
| Add notes: `Deep clean requested — VIP guest` | Notes field | |
| Assign staff: Select from dropdown | Staff name assigned to room | |

**🎯 Demo talking point:** *"Housekeeping status is real-time — admin sees the same board in their Resort Operations tab."*

---

#### Step 9 — Super Admin: Audit Trail & Notifications (1 min)

| Action | Expected Screen / Behavior | Validation |
|--------|---------------------------|------------|
| Role Switcher → select **Super Admin** | Super Admin dashboard loads | |
| Click **Audit Logs** tab | Chronological table of all actions performed in this demo | |
| Filter by Action: `create` | Shows: Resort created, Booking made, Coupon created | |
| Filter by Action: `cancel` | Shows booking cancellation entry | |
| Filter by Action: `update` | Shows status changes, refund processing | |
| Click **Notifications** tab | Notification list | |
| Tap **"Broadcast Notification"** button | Form opens | |
| Title: `Monsoon Package Launch!` | | |
| Message: `New monsoon season discounts are now live — up to 30% off on all bookings through September.` | | |
| Tap **Send** | Notification appears in list | All users will see it in their bell icon |

**🎯 Demo talking point:** *"Every single action in the system is logged for compliance. You can always see who did what and when."*

---

#### Step 10 — Key Integrations Walkthrough (1 min)

| Action | Expected Screen / Behavior | Validation |
|--------|---------------------------|------------|
| Stay as Super Admin → Click **Dashboard** | Analytics page | |
| **Booking Sources pie chart** | Shows distribution: Direct Web, Airbnb, Booking.com, Agoda, MakeMyTrip, Goibibo | Color-coded segments |
| **Resort Revenue Table** | Comparison table: each resort with total revenue, booking count, occupancy % | Vista Valley row shows latest data |
| Super Admin → Role Switcher → browse each role briefly | Quick visual tour of all dashboards | Each role sees different UI |

**🎯 Demo talking point:** *"This is the full lifecycle — from Super Admin creating a resort, to Admin setting prices, to Customer booking and cancelling, to Accountant processing the refund, to Staff managing housekeeping, and finally Super Admin auditing everything. All connected."*

---

### Flow Diagram

```
SUPER ADMIN ──→ Creates Resort ──→ Properties Hub
     │                                    │
     │  Role Switcher                     │
     ├──→ ADMIN ──→ Sets tariffs, coupons, calendar blocks
     │                  │
     │        ┌─────────┴──────────┐
     │        ▼                    ▼
     │   CUSTOMER              BOOKING MATRIX
     │   Browses → Books        (Admin sees it)
     │   Pays → Cancels              │
     │        │                      ▼
     │        ▼              CANCELLED status
     │   CUSTOMER               │
     │   Sees refund            ▼
     │                    ACCOUNTANT
     │                    Processes refund
     │                         │
     │                         ▼
     │                    STAFF
     │                    Housekeeping updates
     │                         │
     └─────────────────────────┘
                         │
                         ▼
                   AUDIT LOGS
              (Super Admin reviews all)
```

---

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
