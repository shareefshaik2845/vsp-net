import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme.dart';
import '../../core/snackbar_helper.dart';
import '../../domain/entities.dart';
import '../providers/state_provider.dart';
import '../routing/route_names.dart';
import '../routing/app_router.dart';
import '../widgets/vsp_nest_logo.dart';
import '../components/app_card.dart';
import '../components/app_dialog.dart';

import '../components/app_empty_state.dart';

import 'customer/customer_view.dart';
import 'customer/saved_view.dart';
import 'customer/dashboard_view.dart';
import 'customer/profile_view.dart';
import 'customer/calendar_view.dart';
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
    final unreadNotifs = notifications.where((n) => !n.read).toList();
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1000;
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double effectiveTopPadding =
        statusBarHeight > 0 ? statusBarHeight : 28.0;

    final mainScaffold = Scaffold(
      backgroundColor: AppColors.stoneBg,
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
                ref.read(activeTabProvider.notifier).state =
                    ['explore', 'saved', 'trips', 'profile'][index];
              },
              items: const [
                BottomNavigationBarItem(
                    icon: Icon(Icons.search), label: 'Explore'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.favorite_border), label: 'Saved'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.luggage_outlined), label: 'Trips'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline), label: 'Profile'),
              ],
            )
          : null,
      floatingActionButton: activeRole == UserRole.customer
          ? FloatingActionButton(
              onPressed: () => _openWhatsApp(),
              tooltip: 'Chat with Concierge',
              child: const Icon(Icons.chat_bubble_outline),
            )
          : null,
      body: Stack(
        children: [
          Column(
            children: [
              if (!isDesktop)
                _buildMobileHeader(context, ref, activeRole, authenticatedRole,
                    unreadNotifs, effectiveTopPadding),
              Expanded(
                child: GestureDetector(
                  onTap: _isNotifOpen
                      ? () => setState(() => _isNotifOpen = false)
                      : null,
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
              top: effectiveTopPadding + 68.0,
              right: 16,
              child:
                  _buildNotificationDropdown(notifications, unreadNotifs, ref),
            ),
        ],
      ),
    );

    if (!isDesktop) return mainScaffold;

    return Scaffold(
      body: Row(
        children: [
          _buildDesktopSidebar(ref, activeRole, authenticatedRole, activeTab),
          Expanded(child: mainScaffold),
        ],
      ),
    );
  }

  void _openWhatsApp() async {
    SnackbarHelper.info(context, 'Opening WhatsApp Concierge Support...');
    final uri = Uri.parse(
        'whatsapp://send?phone=919876543210&text=Hello%20VSP%20Nest%20Concierge,%20I%20need%20assistance%20with%20my%20stay.');
    final webUri = Uri.parse(
        'https://wa.me/919876543210?text=Hello%20VSP%20Nest%20Concierge,%20I%20need%20assistance%20with%20my%20stay.');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      try {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      } catch (_) {
        if (context.mounted)
          SnackbarHelper.error(context, 'Could not launch WhatsApp.');
      }
    }
  }

  // ── Desktop Sidebar ──

  Widget _buildDesktopSidebar(WidgetRef ref, UserRole activeRole,
      UserRole? authenticatedRole, String activeTab) {
    return Container(
      width: 290,
      color: AppColors.mossGreen,
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 36, bottom: 24, left: 24, right: 24),
            child: VspNestBrandHeader(isDarkBackground: true),
          ),
          AppCard.glass(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ACTIVE PERSPECTIVE',
                    style: AppTextStyles.labelSm.copyWith(
                        color: AppColors.goldAccent.withValues(alpha: 0.8))),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                            color: AppColors.goldAccent,
                            shape: BoxShape.circle)),
                    const SizedBox(width: AppSpacing.sm),
                    Text(_getRoleLabel(activeRole),
                        style: GoogleFonts.inter(
                            color: AppColors.white,
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                if (authenticatedRole != null &&
                    authenticatedRole != activeRole) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Icon(Icons.info_outline,
                          size: 10,
                          color: AppColors.goldAccent.withValues(alpha: 0.6)),
                      const SizedBox(width: AppSpacing.xs),
                      Text('Logged in as ${_getRoleLabel(authenticatedRole)}',
                          style: GoogleFonts.inter(
                              color:
                                  AppColors.goldAccent.withValues(alpha: 0.6),
                              fontSize: 9.5,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                if (authenticatedRole == UserRole.superAdmin) ...[
                  Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 8),
                    child: Text('SIMULATE SYSTEM ROLES',
                        style: AppTextStyles.labelSm
                            .copyWith(color: Colors.white38)),
                  ),
                  _sidebarRoleItem(ref, 'Customer Space', UserRole.customer,
                      Icons.hotel_outlined, activeRole, authenticatedRole),
                  _sidebarRoleItem(
                      ref,
                      'Admin Desk',
                      UserRole.admin,
                      Icons.dashboard_customize_outlined,
                      activeRole,
                      authenticatedRole),
                  _sidebarRoleItem(
                      ref,
                      'Staff Ops',
                      UserRole.staff,
                      Icons.cleaning_services_outlined,
                      activeRole,
                      authenticatedRole),
                  _sidebarRoleItem(
                      ref,
                      'Accountant Ledger',
                      UserRole.accountant,
                      Icons.receipt_long_outlined,
                      activeRole,
                      authenticatedRole),
                  _sidebarRoleItem(
                      ref,
                      'Super Admin Config',
                      UserRole.superAdmin,
                      Icons.admin_panel_settings_outlined,
                      activeRole,
                      authenticatedRole),
                ],
                if (activeRole == UserRole.customer) ...[
                  const Divider(color: Colors.white12, height: 24),
                  Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 8),
                    child: Text('GUEST SUITE CHANNELS',
                        style: AppTextStyles.labelSm
                            .copyWith(color: Colors.white38)),
                  ),
                  _sidebarTabItem(ref, 'Villa Sanctuary Specs', 'villa',
                      Icons.nature_people_outlined, activeTab),
                  _sidebarTabItem(ref, 'Interactive Calendar', 'calendar',
                      Icons.calendar_today_outlined, activeTab),
                  _sidebarTabItem(ref, 'My Dashboard', 'dashboard',
                      Icons.dashboard_customize_outlined, activeTab),
                  _sidebarTabItem(ref, 'Profile Management', 'profile',
                      Icons.person_outline, activeTab),
                ],
                const Divider(color: Colors.white12, height: 24),
                _sidebarLogoutItem(ref),
              ],
            ),
          ),
          _buildSidebarFooter(),
        ],
      ),
    );
  }

  void _switchRole(
      WidgetRef ref, UserRole role, UserRole? authenticatedRole) async {
    if (role == authenticatedRole) {
      ref.read(activeRoleProvider.notifier).state = role;
      if (role == UserRole.customer)
        ref.read(activeTabProvider.notifier).state = 'villa';
      if (context.mounted)
        Navigator.pushReplacementNamed(context, AppRouter.routeForRole(role));
      return;
    }
    final confirmed = await AppDialog.confirm(
      context: context,
      title: 'Switch Perspective',
      message:
          'Switching from ${_getRoleLabel(authenticatedRole ?? role)} to ${_getRoleLabel(role)}.\n\n'
          'This is a simulation. Server-side permissions are based on your JWT claims.',
      icon: Icons.swap_horiz_rounded,
      confirmLabel: 'Switch',
    );
    if (confirmed != true) return;
    ref.read(activeRoleProvider.notifier).state = role;
    if (role == UserRole.customer)
      ref.read(activeTabProvider.notifier).state = 'villa';
    if (context.mounted)
      Navigator.pushReplacementNamed(context, AppRouter.routeForRole(role));
  }

  Widget _sidebarRoleItem(WidgetRef ref, String title, UserRole role,
      IconData icon, UserRole activeRole, UserRole? authenticatedRole) {
    final isSelected = activeRole == role;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: isSelected
          ? BoxDecoration(
              borderRadius: AppRadius.mdBr, boxShadow: AppShadows.glowGold)
          : null,
      child: Material(
        color: AppColors.mossGreen,
        borderRadius: AppRadius.mdBr,
        clipBehavior: Clip.antiAlias,
        child: Ink(
          decoration: isSelected
              ? const BoxDecoration(gradient: AppGradients.gold)
              : null,
          child: ListTile(
            leading: Icon(icon,
                color: isSelected ? AppColors.mossGreen : Colors.white60,
                size: 20),
            title: Text(title,
                style: GoogleFonts.inter(
                    fontSize: 12.5,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? AppColors.mossGreen : Colors.white70)),
            onTap: () => _switchRole(ref, role, authenticatedRole),
            shape: RoundedRectangleBorder(borderRadius: AppRadius.mdBr),
            dense: true,
            horizontalTitleGap: 8,
          ),
        ),
      ),
    );
  }

  Widget _sidebarTabItem(WidgetRef ref, String title, String tabId,
      IconData icon, String activeTab) {
    final isSelected = activeTab == tabId;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: isSelected
          ? BoxDecoration(
              borderRadius: AppRadius.mdBr, boxShadow: AppShadows.glowGold)
          : null,
      child: Material(
        color: AppColors.mossGreen,
        borderRadius: AppRadius.mdBr,
        clipBehavior: Clip.antiAlias,
        child: Ink(
          decoration: isSelected
              ? const BoxDecoration(gradient: AppGradients.gold)
              : null,
          child: ListTile(
            leading: Icon(icon,
                color: isSelected ? AppColors.mossGreen : Colors.white54,
                size: 18),
            title: Text(title,
                style: GoogleFonts.inter(
                    fontSize: 11.5,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? AppColors.mossGreen : Colors.white70)),
            onTap: () => ref.read(activeTabProvider.notifier).state = tabId,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.mdBr),
            dense: true,
            horizontalTitleGap: 8,
          ),
        ),
      ),
    );
  }

  Widget _sidebarLogoutItem(WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: AppColors.mossGreen,
        borderRadius: AppRadius.mdBr,
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          leading: const Icon(Icons.logout_outlined,
              color: Colors.white60, size: 20),
          title: Text('Logout Perspective',
              style: GoogleFonts.inter(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70)),
          onTap: () {
            ref.read(isLoggedInProvider.notifier).state = false;
            ref.read(authenticatedRoleProvider.notifier).state = null;
            ref.read(activeRoleProvider.notifier).state = UserRole.customer;
            Navigator.pushNamedAndRemoveUntil(
                context, RouteNames.login, (_) => false);
          },
          shape: RoundedRectangleBorder(borderRadius: AppRadius.mdBr),
          dense: true,
          horizontalTitleGap: 8,
        ),
      ),
    );
  }

  Widget _buildSidebarFooter() {
    return Column(
      children: [
        AppCard.glass(
          padding: const EdgeInsets.all(12),
          child: Text(
            'Sandbox operates on a unified cross-platform Riverpod repository state. Change values in Admin and review updates across workspaces instantly.',
            style: GoogleFonts.inter(
                fontSize: 10, color: Colors.white70, height: 1.4),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Text(
            'VSP Nest Portal \u2022 Clean Architecture v1.0\nFlutter Multiplatform Engine',
            textAlign: TextAlign.center,
            style: AppTextStyles.labelSm
                .copyWith(fontSize: 8.5, color: Colors.white24),
          ),
        ),
      ],
    );
  }

  // ── Mobile Header ──

  Widget _buildMobileHeader(
    BuildContext context,
    WidgetRef ref,
    UserRole activeRole,
    UserRole? authenticatedRole,
    List<AppNotification> unreadNotifs,
    double effectiveTopPadding,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.softCream,
        border: const Border(
            bottom: BorderSide(color: AppColors.lightBone, width: 1)),
        boxShadow: [
          BoxShadow(
              color: AppColors.mossGreen.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      padding: EdgeInsets.only(
          left: 16, right: 16, top: effectiveTopPadding + 14, bottom: 14),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: AppColors.goldAccent.withValues(alpha: 0.2),
                    blurRadius: 6,
                    spreadRadius: 1)
              ],
            ),
            child: const VspNestLogo(size: 42, isDarkBackground: false),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              children: [
                Text('VSP Nest', style: AppTextStyles.titleMd),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.mossGreen,
                    borderRadius: AppRadius.xxxlBr,
                    border: Border.all(
                        color: AppColors.goldAccent.withValues(alpha: 0.5),
                        width: 1),
                  ),
                  child: Text('PORTAL',
                      style: AppTextStyles.labelSm
                          .copyWith(fontSize: 8, color: AppColors.goldAccent)),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _mobileIconButton(
                icon: Icons.notifications_none_rounded,
                badge:
                    unreadNotifs.isNotEmpty ? '${unreadNotifs.length}' : null,
                onTap: () => setState(() => _isNotifOpen = !_isNotifOpen),
              ),
              if (authenticatedRole == UserRole.superAdmin) ...[
                const SizedBox(width: 4),
                _mobileRoleSwitcher(ref, authenticatedRole!),
              ],
              const SizedBox(width: 4),
              _mobileIconButton(
                icon: Icons.logout_rounded,
                onTap: () {
                  ref.read(isLoggedInProvider.notifier).state = false;
                  ref.read(authenticatedRoleProvider.notifier).state = null;
                  ref.read(activeRoleProvider.notifier).state =
                      UserRole.customer;
                  Navigator.pushNamedAndRemoveUntil(
                      context, RouteNames.login, (_) => false);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _mobileIconButton(
      {required IconData icon, String? badge, required VoidCallback onTap}) {
    return Container(
      height: 32,
      width: 32,
      decoration: BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.lightBone, width: 1),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 2))
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onTap,
              child: Center(
                  child: Icon(icon, color: AppColors.mossGreen, size: 16)),
            ),
          ),
          if (badge != null)
            Positioned(
              right: -1,
              top: -1,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                    color: AppColors.error, shape: BoxShape.circle),
                constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                child: Center(
                  child: Text(badge,
                      style: AppTextStyles.labelSm
                          .copyWith(fontSize: 7, color: AppColors.white)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _mobileRoleSwitcher(WidgetRef ref, UserRole authenticatedRole) {
    return Container(
      height: 32,
      width: 32,
      decoration: BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.lightBone, width: 1),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 2))
        ],
      ),
      child: PopupMenuButton<UserRole>(
        icon: const Icon(Icons.swap_horiz_rounded,
            color: AppColors.mossGreen, size: 18),
        tooltip: 'Switch Sandbox Role',
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lgBr),
        onSelected: (role) => _switchRole(ref, role, authenticatedRole),
        itemBuilder: (context) => [
          _roleMenuItem(
              UserRole.customer, Icons.hotel_outlined, 'Customer Space'),
          _roleMenuItem(
              UserRole.admin, Icons.dashboard_customize_outlined, 'Admin Desk'),
          _roleMenuItem(
              UserRole.staff, Icons.cleaning_services_outlined, 'Staff Ops'),
          _roleMenuItem(UserRole.accountant, Icons.receipt_long_outlined,
              'Accountant Ledger'),
          _roleMenuItem(UserRole.superAdmin,
              Icons.admin_panel_settings_outlined, 'Super Admin Config'),
        ],
      ),
    );
  }

  PopupMenuItem<UserRole> _roleMenuItem(
      UserRole role, IconData icon, String label) {
    return PopupMenuItem(
      value: role,
      child: Row(
        children: [
          Icon(icon, color: AppColors.mossGreen, size: 18),
          const SizedBox(width: 8),
          Text(label,
              style:
                  GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // ── Active Viewport ──

  Widget _buildActiveViewport(UserRole role, String activeTab) {
    switch (role) {
      case UserRole.customer:
        switch (activeTab) {
          case 'explore':
          case 'villa':
            return const CustomerView();
          case 'calendar':
            return const ValleyCalendarView();
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

  // ── Notifications ──

  Widget _buildNotificationDropdown(List<AppNotification> notifications,
      List<AppNotification> unreadNotifs, WidgetRef ref) {
    return ClipRRect(
      borderRadius: AppRadius.xlBr,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: 320,
          decoration: BoxDecoration(
            color: AppColors.softCream.withValues(alpha: 0.92),
            borderRadius: AppRadius.xlBr,
            border: Border.all(
                color: AppColors.goldAccent.withValues(alpha: 0.25),
                width: 1.2),
            boxShadow: AppShadows.card,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Operational Logs &\nAlerts',
                            style:
                                AppTextStyles.titleSm.copyWith(fontSize: 16)),
                        const SizedBox(height: 4),
                        Text('Sandbox cross-role updates',
                            style: AppTextStyles.bodyXs),
                      ],
                    ),
                    if (unreadNotifs.isNotEmpty)
                      TextButton(
                        onPressed: () =>
                            ref.read(notificationsProvider.notifier).clearAll(),
                        style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                        child: Text('Dismiss Admin\nAlerts',
                            textAlign: TextAlign.right,
                            style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.mossGreen)),
                      ),
                  ],
                ),
              ),
              const Divider(),
              Container(
                color: AppColors.white.withValues(alpha: 0.5),
                constraints: const BoxConstraints(maxHeight: 280),
                child: notifications.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(24),
                        child: AppEmptyState(
                          icon: Icons.notifications_none_outlined,
                          title: 'No recent notifications',
                          subtitle:
                              'Trigger actions in other roles to populate.',
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: notifications.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, index) {
                          final notif = notifications[index];
                          return Material(
                            color: notif.read
                                ? Colors.transparent
                                : AppColors.goldAccent.withValues(alpha: 0.08),
                            child: InkWell(
                              onTap: () => ref
                                  .read(notificationsProvider.notifier)
                                  .markAsRead(notif.id),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: notif.read
                                      ? null
                                      : const Border(
                                          left: BorderSide(
                                              color: AppColors.goldAccent,
                                              width: 3)),
                                ),
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _getNotifIcon(notif.type),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                  child: Text(notif.title,
                                                      style: GoogleFonts.inter(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: AppColors
                                                              .mossGreen))),
                                              Text(_formatTime(notif.timestamp),
                                                  style: AppTextStyles.bodyXs),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(notif.message,
                                              style: GoogleFonts.inter(
                                                  fontSize: 11,
                                                  color: AppColors.charcoal
                                                      .withValues(alpha: 0.7),
                                                  height: 1.4)),
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
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                    'Notifications sync dynamically across role dashboards',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                        fontSize: 10,
                        color: AppColors.charcoal.withValues(alpha: 0.4))),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getNotifIcon(String type) {
    final (IconData icon, Color color) = switch (type) {
      'booking' => (Icons.calendar_today, Colors.blue.shade400),
      'payment' => (Icons.credit_card, Colors.green.shade400),
      'staff' => (Icons.cleaning_services, Colors.orange.shade400),
      'ota' => (Icons.sync, Colors.teal.shade400),
      _ => (Icons.settings, Colors.purple.shade300),
    };
    return Icon(icon, size: 18, color: color);
  }

  String _formatTime(String isoTime) {
    try {
      final dt = DateTime.parse(isoTime);
      final hrs = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      return '$hrs:${dt.minute.toString().padLeft(2, '0')} ${dt.hour >= 12 ? 'PM' : 'AM'}';
    } catch (_) {
      return '';
    }
  }

  String _getRoleLabel(UserRole role) {
    return switch (role) {
      UserRole.customer => 'Customer Portal',
      UserRole.admin => 'Admin Desk',
      UserRole.staff => 'Housekeeping Staff',
      UserRole.accountant => 'Accountant Ledger',
      UserRole.superAdmin => 'Super Admin',
    };
  }
}
