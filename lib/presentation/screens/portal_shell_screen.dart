import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/state_provider.dart';
import '../routing/route_names.dart';
import '../routing/app_router.dart';
import '../../core/snackbar_helper.dart';
import '../../core/theme.dart';
import '../../domain/entities.dart';
import '../widgets/vsp_nest_logo.dart';

// Screens imports
import 'customer/customer_view.dart';
import 'customer/saved_view.dart';
import 'customer/dashboard_view.dart';
import 'customer/profile_view.dart';
import 'admin/admin_view.dart';
import 'staff/staff_view.dart';
import 'accountant/accountant_view.dart';
import 'super_admin/super_admin_view.dart';

class ResortPortalShell extends ConsumerStatefulWidget {
  const ResortPortalShell({super.key});

  @override
  ConsumerState<ResortPortalShell> createState() => _ResortPortalShellState();
}

class _ResortPortalShellState extends ConsumerState<ResortPortalShell> {
  bool _isNotifOpen = false;

  @override
  Widget build(BuildContext context) {
    final activeRole = ref.watch(activeRoleProvider);
    final authenticatedRole = ref.watch(authenticatedRoleProvider);
    final activeTab = ref.watch(activeTabProvider);
    final notifications = ref.watch(notificationsProvider);
    final propertyAsync = ref.watch(propertyProvider);
    final unreadNotifs = notifications.where((n) => !n.read).toList();
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1000;
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double effectiveTopPadding = statusBarHeight > 0 ? statusBarHeight : 28.0;
    final double headerHeight = effectiveTopPadding + 68.0;

    Widget mainScaffold = Scaffold(
      backgroundColor: ResortTheme.stoneBg,
      bottomNavigationBar: (!isDesktop && activeRole == UserRole.customer)
          ? BottomNavigationBar(
              currentIndex: activeTab == 'profile'
                  ? 3
                  : activeTab == 'trips'
                      ? 2
                      : activeTab == 'saved'
                          ? 1
                          : 0,
              onTap: (index) {
                final tabs = ['explore', 'saved', 'trips', 'profile'];
                ref.read(activeTabProvider.notifier).state = tabs[index];
              },
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              selectedItemColor: ResortTheme.mossGreen,
              unselectedItemColor: Colors.grey,
              selectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 11),
              unselectedLabelStyle: GoogleFonts.inter(fontSize: 11),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.search),
                  label: 'Explore',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.favorite_border),
                  label: 'Saved',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.luggage_outlined),
                  label: 'Trips',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  label: 'Profile',
                ),
              ],
            )
          : null,
      floatingActionButton: (activeRole == UserRole.customer)
          ? FloatingActionButton(
              onPressed: () async {
                SnackbarHelper.info(context, 'Opening WhatsApp Concierge Support...');
                final Uri whatsappUrl = Uri.parse('whatsapp://send?phone=919876543210&text=Hello%20VSP%20Nest%20Concierge,%20I%20need%20assistance%20with%20my%20stay.');
                final Uri webUrl = Uri.parse('https://wa.me/919876543210?text=Hello%20VSP%20Nest%20Concierge,%20I%20need%20assistance%20with%20my%20stay.');
                try {
                  if (await canLaunchUrl(whatsappUrl)) {
                    await launchUrl(whatsappUrl);
                  } else {
                    await launchUrl(webUrl, mode: LaunchMode.externalApplication);
                  }
                } catch (e) {
                  try {
                    await launchUrl(webUrl, mode: LaunchMode.externalApplication);
                  } catch (e2) {
                    if (context.mounted) {
                      SnackbarHelper.error(context, 'Could not launch WhatsApp. Please make sure WhatsApp is installed.');
                    }
                  }
                }
              },
              backgroundColor: const Color(0xFF25D366),
              tooltip: 'Chat with Concierge',
              child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
            )
          : null,
      body: Stack(
        children: [
          Column(
            children: [
              if (!isDesktop) _buildMobileHeader(context, ref, activeRole, unreadNotifs, propertyAsync),
              Expanded(
                child: GestureDetector(
                  onTap: _isNotifOpen ? () => setState(() => _isNotifOpen = false) : null,
                  child: AbsorbPointer(
                    absorbing: _isNotifOpen,
                    child: _buildActiveViewport(activeRole, activeTab),
                  ),
                ),
              ),
            ],
          ),
          if (!isDesktop && _isNotifOpen)
            Positioned(
              top: headerHeight,
              right: 16,
              child: _buildNotificationDropdown(notifications, unreadNotifs),
            ),
        ],
      ),
    );

    if (!isDesktop) {
      return mainScaffold;
    }

    return Scaffold(
      body: Row(
        children: [
          // Desktop Sidebar with visual color "side color" matching the layout request
          Container(
            width: 290,
            color: ResortTheme.mossGreen,
            child: Column(
              children: [
                // Premium logo header
                const Padding(
                  padding: EdgeInsets.only(top: 36.0, bottom: 24.0, left: 24, right: 24),
                  child: VspNestBrandHeader(
                    isDarkBackground: true,
                  ),
                ),

                // Active Workspace indicator
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ACTIVE PERSPECTIVE',
                        style: GoogleFonts.spaceGrotesk(
                          color: ResortTheme.goldAccent.withValues(alpha: 0.8),
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: ResortTheme.goldAccent,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _getRoleLabel(activeRole),
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),



                const SizedBox(height: 20),

                // System simulation roles selector list
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    children: [
                      if (authenticatedRole == UserRole.superAdmin) ...[
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
                          child: Text(
                            'SIMULATE SYSTEM ROLES',
                            style: GoogleFonts.spaceGrotesk(
                              color: Colors.white38,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        _sidebarRoleItem(ref, 'Customer Space', UserRole.customer, Icons.hotel_outlined, activeRole),
                        _sidebarRoleItem(ref, 'Admin Desk', UserRole.admin, Icons.dashboard_customize_outlined, activeRole),
                        _sidebarRoleItem(ref, 'Staff Ops', UserRole.staff, Icons.cleaning_services_outlined, activeRole),
                        _sidebarRoleItem(ref, 'Accountant Ledger', UserRole.accountant, Icons.receipt_long_outlined, activeRole),
                        _sidebarRoleItem(ref, 'Super Admin Config', UserRole.superAdmin, Icons.admin_panel_settings_outlined, activeRole),
                      ],

                      if (activeRole == UserRole.customer) ...[
                        const Divider(color: Colors.white12, height: 24),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
                          child: Text(
                            'GUEST SUITE CHANNELS',
                            style: GoogleFonts.spaceGrotesk(
                              color: Colors.white38,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        _sidebarTabItem(ref, 'Villa Sanctuary Specs', 'villa', Icons.nature_people_outlined, activeTab),
                        _sidebarTabItem(ref, 'Interactive Calendar', 'calendar', Icons.calendar_today_outlined, activeTab),
                        _sidebarTabItem(ref, 'My Dashboard', 'dashboard', Icons.dashboard_customize_outlined, activeTab),
                        _sidebarTabItem(ref, 'Profile Management', 'profile', Icons.person_outline, activeTab),
                      ],
                      const Divider(color: Colors.white12, height: 24),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Material(
                          color: ResortTheme.mossGreen,
                          borderRadius: BorderRadius.circular(12),
                          clipBehavior: Clip.antiAlias,
                          child: ListTile(
                            leading: const Icon(Icons.logout_outlined, color: Colors.white60, size: 20),
                            title: Text(
                              'Logout Perspective', 
                              style: GoogleFonts.inter(
                                fontSize: 12.5, 
                                fontWeight: FontWeight.w500, 
                                color: Colors.white70,
                              ),
                            ),
                            onTap: () {
                              ref.read(isLoggedInProvider.notifier).state = false;
                              ref.read(authenticatedRoleProvider.notifier).state = null;
                              ref.read(activeRoleProvider.notifier).state = UserRole.customer;
                              Navigator.pushNamedAndRemoveUntil(context, RouteNames.login, (_) => false);
                            },
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            dense: true,
                            horizontalTitleGap: 8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Quick helpful instructions context
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                  ),
                  child: Text(
                    'Sandbox operates on a unified cross-platform Riverpod repository state. Change values in Admin and review updates across workspaces instantly.',
                    style: GoogleFonts.inter(fontSize: 10, color: Colors.white70, height: 1.4),
                  ),
                ),

                // Sidebar Footer
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Text(
                    'VSP Nest Portal • Clean Architecture v1.0\nFlutter Multiplatform Engine',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 8.5,
                      color: Colors.white24,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Main scaffold viewer taking remainder of widescreen
          Expanded(child: mainScaffold),
        ],
      ),
    );
  }

  String _getRoleLabel(UserRole role) {
    switch (role) {
      case UserRole.customer:
        return 'Customer Portal';
      case UserRole.admin:
        return 'Admin Desk';
      case UserRole.staff:
        return 'Housekeeping Staff';
      case UserRole.accountant:
        return 'Accountant Ledger';
      case UserRole.superAdmin:
        return 'Super Admin';
    }
  }

  Widget _sidebarRoleItem(WidgetRef ref, String title, UserRole role, IconData icon, UserRole activeRole) {
    final isSelected = activeRole == role;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2.0),
      decoration: isSelected
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: ResortTheme.goldAccent.withValues(alpha: 0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            )
          : null,
      child: Material(
        color: ResortTheme.mossGreen,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: Ink(
          decoration: isSelected
              ? const BoxDecoration(
                  gradient: ResortTheme.goldGradient,
                )
              : null,
          child: ListTile(
            leading: Icon(icon, color: isSelected ? ResortTheme.mossGreen : Colors.white60, size: 20),
            title: Text(
              title, 
              style: GoogleFonts.inter(
                fontSize: 12.5, 
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, 
                color: isSelected ? ResortTheme.mossGreen : Colors.white70,
              ),
            ),
            onTap: () {
              ref.read(activeRoleProvider.notifier).state = role;
              if (role == UserRole.customer) {
                ref.read(activeTabProvider.notifier).state = 'villa';
              }
              Navigator.pushReplacementNamed(context, AppRouter.routeForRole(role));
            },
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            dense: true,
            horizontalTitleGap: 8,
          ),
        ),
      ),
    );
  }

  Widget _sidebarTabItem(WidgetRef ref, String title, String tabId, IconData icon, String activeTab) {
    final isSelected = activeTab == tabId;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2.0),
      decoration: isSelected
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: ResortTheme.goldAccent.withValues(alpha: 0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            )
          : null,
      child: Material(
        color: ResortTheme.mossGreen,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: Ink(
          decoration: isSelected
              ? const BoxDecoration(
                  gradient: ResortTheme.goldGradient,
                )
              : null,
          child: ListTile(
            leading: Icon(icon, color: isSelected ? ResortTheme.mossGreen : Colors.white54, size: 18),
            title: Text(
              title, 
              style: GoogleFonts.inter(
                fontSize: 11.5, 
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, 
                color: isSelected ? ResortTheme.mossGreen : Colors.white70,
              ),
            ),
            onTap: () {
              ref.read(activeTabProvider.notifier).state = tabId;
            },
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            dense: true,
            horizontalTitleGap: 8,
          ),
        ),
      ),
    );
  }

  Widget _buildActiveViewport(UserRole role, String activeTab) {
    switch (role) {
      case UserRole.customer:
        switch (activeTab) {
          case 'explore':
          case 'villa': // legacy fallback
            return const CustomerView();
          case 'saved':
            return const SavedView();
          case 'trips':
          case 'dashboard':
            return const CustomerDashboardView();
          case 'profile':
            return const CustomerProfileView();
          default:
            return const CustomerView();
        }
      case UserRole.admin:
        return const AdminView();
      case UserRole.staff:
        return const StaffView();
      case UserRole.accountant:
        return const AccountantView();
      case UserRole.superAdmin:
        return const SuperAdminView();
    }
  }

  Widget _buildMobileHeader(
    BuildContext context,
    WidgetRef ref,
    UserRole activeRole,
    List<AppNotification> unreadNotifs,
    AsyncValue<PropertyDetails> propertyAsync,
  ) {
    final authenticatedRole = ref.watch(authenticatedRoleProvider);
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double effectiveTopPadding = statusBarHeight > 0 ? statusBarHeight : 28.0;

    return Column(
      children: [
        // Premium Styled Header with subtle shadow, border, and background color
        Container(
          decoration: BoxDecoration(
            color: ResortTheme.softCream,
            border: const Border(
              bottom: BorderSide(color: Color(0xFFE5E0D0), width: 1.0),
            ),
            boxShadow: [
              BoxShadow(
                color: ResortTheme.mossGreen.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: effectiveTopPadding + 14,
            bottom: 14,
          ),
          child: Row(
            children: [
              // Logo with a subtle shadow and circular border to make it pop
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: ResortTheme.goldAccent.withValues(alpha: 0.2),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: const VspNestLogo(size: 42, isDarkBackground: false),
              ),
              const SizedBox(width: 12),
              
              // Title & Luxury Badge
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'VSP Nest',
                          style: GoogleFonts.playfairDisplay(
                            color: ResortTheme.mossGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: ResortTheme.mossGreen,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: ResortTheme.goldAccent.withValues(alpha: 0.5), width: 1),
                          ),
                          child: Text(
                            'PORTAL',
                            style: GoogleFonts.spaceGrotesk(
                              color: ResortTheme.goldAccent,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              
              // Actions (Notification, Switch Role, and Logout as premium buttons)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        height: 32,
                        width: 32,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: ResortTheme.lightBone, width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(100),
                            onTap: () {
                              setState(() {
                                _isNotifOpen = !_isNotifOpen;
                              });
                            },
                            child: const Center(
                              child: Icon(
                                Icons.notifications_none_rounded, 
                                color: ResortTheme.mossGreen, 
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (unreadNotifs.isNotEmpty)
                        Positioned(
                          right: -1,
                          top: -1,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: Color(0xFFC62828),
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 14,
                              minHeight: 14,
                            ),
                            child: Center(
                              child: Text(
                                '${unreadNotifs.length}',
                                style: GoogleFonts.spaceGrotesk(
                                  color: Colors.white,
                                  fontSize: 7,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (authenticatedRole == UserRole.superAdmin) ...[
                    const SizedBox(width: 4),
                    Container(
                      height: 32,
                      width: 32,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: ResortTheme.lightBone, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          tooltipTheme: TooltipThemeData(
                            decoration: BoxDecoration(
                              color: ResortTheme.mossGreen,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            textStyle: GoogleFonts.inter(color: Colors.white, fontSize: 11),
                          ),
                        ),
                        child: PopupMenuButton<UserRole>(
                          icon: const Icon(Icons.swap_horiz_rounded, color: ResortTheme.mossGreen, size: 18),
                          tooltip: 'Switch Sandbox Role',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          onSelected: (role) {
                            ref.read(activeRoleProvider.notifier).state = role;
                            if (role == UserRole.customer) {
                              ref.read(activeTabProvider.notifier).state = 'villa';
                            }
                            Navigator.pushReplacementNamed(context, AppRouter.routeForRole(role));
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: UserRole.customer,
                              child: Row(
                                children: [
                                  const Icon(Icons.hotel_outlined, color: ResortTheme.mossGreen, size: 18),
                                  const SizedBox(width: 8),
                                  Text('Customer Space', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: UserRole.admin,
                              child: Row(
                                children: [
                                  const Icon(Icons.dashboard_customize_outlined, color: ResortTheme.mossGreen, size: 18),
                                  const SizedBox(width: 8),
                                  Text('Admin Desk', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: UserRole.staff,
                              child: Row(
                                children: [
                                  const Icon(Icons.cleaning_services_outlined, color: ResortTheme.mossGreen, size: 18),
                                  const SizedBox(width: 8),
                                  Text('Staff Ops', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: UserRole.accountant,
                              child: Row(
                                children: [
                                  const Icon(Icons.receipt_long_outlined, color: ResortTheme.mossGreen, size: 18),
                                  const SizedBox(width: 8),
                                  Text('Accountant Ledger', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: UserRole.superAdmin,
                              child: Row(
                                children: [
                                  const Icon(Icons.admin_panel_settings_outlined, color: ResortTheme.mossGreen, size: 18),
                                  const SizedBox(width: 8),
                                  Text('Super Admin Config', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(width: 4),
                  Container(
                    height: 32,
                    width: 32,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: ResortTheme.lightBone, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(100),
                        onTap: () {
                          ref.read(isLoggedInProvider.notifier).state = false;
                          ref.read(authenticatedRoleProvider.notifier).state = null;
                          ref.read(activeRoleProvider.notifier).state = UserRole.customer;
                          Navigator.pushNamedAndRemoveUntil(context, RouteNames.login, (_) => false);
                        },
                        child: const Center(
                          child: Icon(
                            Icons.logout_rounded, 
                            color: ResortTheme.mossGreen, 
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Deleted unused helper methods

  Widget _buildNotificationDropdown(List<AppNotification> notifications, List<AppNotification> unreadNotifs) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: 320,
          decoration: BoxDecoration(
            color: ResortTheme.softCream.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: ResortTheme.goldAccent.withValues(alpha: 0.25), width: 1.2),
            boxShadow: ResortTheme.premiumShadows,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Operational Logs &\nAlerts',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: ResortTheme.mossGreen,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Sandbox cross-role updates',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: ResortTheme.mossGreen.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (unreadNotifs.isNotEmpty)
                      TextButton(
                        onPressed: () {
                          ref.read(notificationsProvider.notifier).clearAll();
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Dismiss Admin\nAlerts',
                          textAlign: TextAlign.right,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: ResortTheme.mossGreen,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const Divider(height: 1, color: ResortTheme.lightBone),
              // List
              Container(
                color: Colors.white.withValues(alpha: 0.5),
                constraints: const BoxConstraints(maxHeight: 280),
                child: notifications.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text(
                          'No recent notifications. Trigger actions in other roles to populate.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: ResortTheme.charcoal.withValues(alpha: 0.6),
                          ),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: notifications.length,
                        separatorBuilder: (context, index) => const Divider(height: 1, color: ResortTheme.lightBone),
                        itemBuilder: (context, index) {
                          final notif = notifications[index];
                          return Material(
                            color: notif.read ? Colors.transparent : ResortTheme.goldAccent.withValues(alpha: 0.08),
                            child: InkWell(
                              onTap: () {
                                ref.read(notificationsProvider.notifier).markAsRead(notif.id);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  border: notif.read
                                      ? null
                                      : const Border(left: BorderSide(color: ResortTheme.goldAccent, width: 3)),
                                ),
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _getNotifIcon(notif.type),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  notif.title,
                                                  style: GoogleFonts.inter(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: ResortTheme.mossGreen,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                _formatTime(notif.timestamp),
                                                style: GoogleFonts.inter(
                                                  fontSize: 10,
                                                  color: ResortTheme.charcoal.withValues(alpha: 0.5),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            notif.message,
                                            style: GoogleFonts.inter(
                                              fontSize: 11,
                                              color: ResortTheme.charcoal.withValues(alpha: 0.7),
                                              height: 1.4,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              const Divider(height: 1, color: ResortTheme.lightBone),
              // Footer
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  'Notifications sync dynamically across role dashboards',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: ResortTheme.charcoal.withValues(alpha: 0.4),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getNotifIcon(String type) {
    IconData icon;
    Color color = Colors.purple.shade300;
    if (type == 'booking') {
      icon = Icons.calendar_today;
      color = Colors.blue.shade400;
    } else if (type == 'payment') {
      icon = Icons.credit_card;
      color = Colors.green.shade400;
    } else if (type == 'staff') {
      icon = Icons.cleaning_services;
      color = Colors.orange.shade400;
    } else if (type == 'ota') {
      icon = Icons.sync;
      color = Colors.teal.shade400;
    } else {
      icon = Icons.settings;
    }
    return Icon(icon, size: 18, color: color);
  }

  String _formatTime(String isoTime) {
    try {
      final dt = DateTime.parse(isoTime);
      final hrs = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final mins = dt.minute.toString().padLeft(2, '0');
      final ampm = dt.hour >= 12 ? 'PM' : 'AM';
      return '$hrs:$mins $ampm';
    } catch(e) {
      return '';
    }
  }

  // String _getResortMobileLabel(String resortName) {
  //   return resortName
  //       .replaceAll('VSP ', '')
  //       .replaceAll(' Sanctuary', '')
  //       .replaceAll(' Retreat', '')
  //       .replaceAll(' Villa', '')
  //       .replaceAll(' Manor', '');
  // }
  // 
  // void _showResortBottomSheet(BuildContext context, WidgetRef ref, String activeResortName) {
  //   showModalBottomSheet(
  //     context: context,
  //     backgroundColor: Colors.white,
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.only(
  //         topLeft: Radius.circular(24),
  //         topRight: Radius.circular(24),
  //       ),
  //     ),
  //     builder: (context) {
  //       return SafeArea(
  //         child: Padding(
  //           padding: const EdgeInsets.symmetric(vertical: 20.0),
  //           child: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Padding(
  //                 padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
  //                 child: Text(
  //                   'Select Resort Sanctuary',
  //                   style: GoogleFonts.playfairDisplay(
  //                     fontSize: 20,
  //                     fontWeight: FontWeight.bold,
  //                     color: ResortTheme.mossGreen,
  //                   ),
  //                 ),
  //               ),
  //               const Divider(color: ResortTheme.lightBone),
  //               ...ref.watch(resortsListProvider).map((resort) {
  //                 final isSelected = resort.name == activeResortName;
  //                 return ListTile(
  //                   leading: const Icon(Icons.holiday_village, color: ResortTheme.mossGreen),
  //                   title: Text(
  //                     resort.name,
  //                     style: GoogleFonts.inter(
  //                       fontSize: 14,
  //                       fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
  //                       color: isSelected ? ResortTheme.mossGreen : ResortTheme.charcoal,
  //                     ),
  //                   ),
  //                   trailing: isSelected ? const Icon(Icons.check_circle, color: ResortTheme.mossGreen) : null,
  //                   onTap: () {
  //                     ref.read(propertyProvider.notifier).updateProperty(resort);
  //                     Navigator.pop(context);
  //                   },
  //                 );
  //               }).toList(),
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }
}
