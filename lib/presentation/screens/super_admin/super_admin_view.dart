import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';

import '../../providers/state_provider.dart';
import '../../../core/theme.dart';
import '../../../core/snackbar_helper.dart';
import '../../../domain/entities.dart';
import '../../widgets/approval_panel.dart';
import 'role_management_view.dart';

class SuperAdminView extends ConsumerStatefulWidget {
  const SuperAdminView({super.key});

  @override
  ConsumerState<SuperAdminView> createState() => _SuperAdminViewState();
}

class _SuperAdminViewState extends ConsumerState<SuperAdminView> {
  String _activeAdminTab = 'dashboard';

  void _handlePropertyToggle(PropertyDetails resort) {
    ref.read(propertyProvider.notifier).updateProperty(resort);
    _notify(
      'Property Modified',
      'Super Admin loaded "${resort.name}" configurations.',
      'system',
    );
  }

  void _notify(String title, String message, String type) {
    (ref.read(superAdminNotificationsProvider.notifier))
        .addNotification(title, message, type);
  }

  @override
  Widget build(BuildContext context) {
    final bookings = ref.watch(superAdminBookingsProvider);
    final propertyAsync = ref.watch(propertyProvider);
    final activeResort = propertyAsync.valueOrNull;

    return Scaffold(
      body: Column(
        children: [
          // Dashboard Header Banner (always visible, compact)
          _buildHeaderBanner(bookings.length, activeResort),
          // Tab bar
          _buildTabBar(),
          // Tab content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: _buildActiveTabContent(bookings, activeResort),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderBanner(int bookingCount, PropertyDetails? activeResort) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [ResortTheme.mossGreen, Color(0xFF181F15)],
        ),
        border: const Border(
            bottom: BorderSide(color: ResortTheme.goldAccent, width: 0.5)),
        boxShadow: [
          BoxShadow(
            color: ResortTheme.mossGreen.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.admin_panel_settings_rounded,
              color: ResortTheme.goldAccent, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Administrative Console',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'SUPER ADMIN ROLE PANEL',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 8,
                    color: ResortTheme.goldAccent,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: const Color(0xFF4CAF50), width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFF4CAF50),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'System Active',
                    style: GoogleFonts.spaceGrotesk(
                      color: const Color(0xFF81C784),
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    final tabs = [
      {
        'id': 'dashboard',
        'label': 'Dashboard',
        'icon': Icons.dashboard_rounded
      },
      {
        'id': 'users',
        'label': 'User Management',
        'icon': Icons.people_outline_rounded
      },
      {
        'id': 'roles',
        'label': 'Roles & Permissions',
        'icon': Icons.admin_panel_settings_outlined
      },
      {
        'id': 'auditLogs',
        'label': 'Audit Logs',
        'icon': Icons.history_rounded
      },
      {
        'id': 'notifications',
        'label': 'Notifications',
        'icon': Icons.notifications_outlined
      },
    ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: tabs.map((tab) {
            final isSelected = _activeAdminTab == tab['id'];
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InkWell(
                onTap: () =>
                    setState(() => _activeAdminTab = tab['id'] as String),
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: isSelected ? ResortTheme.goldGradient : null,
                    color: isSelected
                        ? null
                        : ResortTheme.stoneBg.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                                color: ResortTheme.goldAccent
                                    .withValues(alpha: 0.15),
                                blurRadius: 6,
                                offset: const Offset(0, 3))
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        tab['icon'] as IconData,
                        size: 16,
                        color: isSelected
                            ? const Color(0xFF2C3627)
                            : ResortTheme.charcoal.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        tab['label'] as String,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? const Color(0xFF2C3627)
                              : ResortTheme.charcoal.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildActiveTabContent(
      List<Booking> bookings, PropertyDetails? activeResort) {
    switch (_activeAdminTab) {
      case 'users':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserManagement(),
            const SizedBox(height: 32),
            ApprovalPanel(
              remoteApprovals: ref.watch(superAdminApprovalsProvider),
              onResolve: (id, status, {reason}) {
                ref
                    .read(superAdminApprovalsProvider.notifier)
                    .resolve(id, status, reason: reason);
              },
            ),
          ],
        );
      case 'roles':
        final roles = ref.watch(superAdminRolesProvider);
        return RoleManagementView(
          remoteRoles: roles,
          onRemoteSave: (role) {
            ref.read(superAdminRolesProvider.notifier).updateRole(role);
          },
        );
      case 'auditLogs':
        return _buildAuditLogsView();
      case 'notifications':
        return _buildNotificationsView();
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFinancialSection(),
            const SizedBox(height: 32),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 800) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildGlobalConstraints()),
                      const SizedBox(width: 32),
                      Expanded(child: _buildDatabaseAdmin()),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      _buildGlobalConstraints(),
                      const SizedBox(height: 32),
                      _buildDatabaseAdmin(),
                    ],
                  );
                }
              },
            ),
          ],
        );
    }
  }

  UserAccount _userFromJson(Map<String, dynamic> json) {
    final roleStr = (json['role'] as String? ?? '').toLowerCase();
    return UserAccount(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      passwordHash: '',
      role: UserRole.values.firstWhere(
        (e) => e.name.toLowerCase() == roleStr,
        orElse: () => UserRole.customer,
      ),
      status: json['status'] == 'inactive'
          ? UserStatus.inactive
          : UserStatus.active,
      createdAt: json['createdAt'] as String? ?? '',
      createdBy: json['createdBy'] as String?,
      lastLoginAt: json['lastLoginAt'] as String?,
    );
  }

  Widget _buildUserManagement() {
    final List<UserAccount> users = ref
        .watch(superAdminUsersProvider)
        .map((m) => _userFromJson(m))
        .toList();
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: ResortTheme.lightBone),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.people_outline_rounded,
                  color: ResortTheme.mossGreen, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'User Management',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ResortTheme.charcoal,
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showCreateUserDialog(context),
                icon: const Icon(Icons.person_add_alt_1,
                    color: ResortTheme.mossGreen, size: 16),
                label: Text(
                  'Create User',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: ResortTheme.mossGreen,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ResortTheme.goldAccent,
                  foregroundColor: ResortTheme.mossGreen,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  elevation: 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: ResortTheme.lightBone),
          const SizedBox(height: 16),
          if (users.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'No users created yet. Click "Create User" to add one.',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: ResortTheme.charcoal.withValues(alpha: 0.5),
                  ),
                ),
              ),
            )
          else
            ...users.map((user) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: user.role == UserRole.superAdmin
                        ? ResortTheme.goldAccent.withValues(alpha: 0.08)
                        : ResortTheme.softCream,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: user.role == UserRole.superAdmin
                          ? ResortTheme.goldAccent.withValues(alpha: 0.3)
                          : ResortTheme.lightBone,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _roleColor(user.role).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(_roleIcon(user.role),
                            size: 18, color: _roleColor(user.role)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: ResortTheme.charcoal,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              user.email,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color:
                                    ResortTheme.charcoal.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      _roleBadge(user.role),
                      const SizedBox(width: 8),
                      _buildUserActionButtons(user),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  IconData _roleIcon(UserRole role) {
    switch (role) {
      case UserRole.customer:
        return Icons.hotel_outlined;
      case UserRole.admin:
        return Icons.dashboard_customize_outlined;
      case UserRole.staff:
        return Icons.cleaning_services_outlined;
      case UserRole.accountant:
        return Icons.receipt_long_outlined;
      case UserRole.superAdmin:
        return Icons.admin_panel_settings_outlined;
    }
  }

  Color _roleColor(UserRole role) {
    switch (role) {
      case UserRole.customer:
        return Colors.blue;
      case UserRole.admin:
        return Colors.orange;
      case UserRole.staff:
        return Colors.teal;
      case UserRole.accountant:
        return Colors.purple;
      case UserRole.superAdmin:
        return const Color(0xFFC53030);
    }
  }

  Widget _roleBadge(UserRole role) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _roleColor(role).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: _roleColor(role).withValues(alpha: 0.3)),
      ),
      child: Text(
        role.name,
        style: GoogleFonts.spaceGrotesk(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: _roleColor(role),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildUserActionButtons(UserAccount user) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 28,
          child: IconButton(
            icon: const Icon(Icons.edit_outlined, size: 14),
            color: ResortTheme.charcoal.withValues(alpha: 0.5),
            tooltip: 'Edit User',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            onPressed: () => _showEditUserDialog(context, user),
          ),
        ),
        const SizedBox(width: 2),
        SizedBox(
          height: 28,
          child: IconButton(
            icon: const Icon(Icons.delete_outline, size: 14),
            color: Colors.red.withValues(alpha: 0.6),
            tooltip: 'Deactivate User',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            onPressed: () => _showDeleteUserConfirm(context, user),
          ),
        ),
      ],
    );
  }

  void _showEditUserDialog(BuildContext context, UserAccount user) {
    final nameController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.email);
    final passwordController = TextEditingController();
    UserRole selectedRole = user.role;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.edit_outlined,
                  color: ResortTheme.mossGreen, size: 22),
              const SizedBox(width: 8),
              Text(
                'Edit User',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ResortTheme.charcoal,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  style: GoogleFonts.inter(fontSize: 13),
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: const Icon(Icons.person_outline, size: 18),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailController,
                  style: GoogleFonts.inter(fontSize: 13),
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    prefixIcon: const Icon(Icons.email_outlined, size: 18),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  style: GoogleFonts.inter(fontSize: 13),
                  decoration: InputDecoration(
                    labelText: 'New Password (leave blank to keep current)',
                    prefixIcon: const Icon(Icons.lock_outline, size: 18),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<UserRole>(
                  initialValue: selectedRole,
                  decoration: InputDecoration(
                    labelText: 'Role',
                    prefixIcon: const Icon(Icons.badge_outlined, size: 18),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  items: UserRole.values
                      .map((role) => DropdownMenuItem(
                            value: role,
                            child: Text(role.name,
                                style: GoogleFonts.inter(fontSize: 13)),
                          ))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setDialogState(() => selectedRole = val);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child:
                  Text('Cancel', style: GoogleFonts.inter(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ResortTheme.mossGreen,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                final name = nameController.text.trim();
                final email = emailController.text.trim().toLowerCase();
                final password = passwordController.text;

                if (name.isEmpty || email.isEmpty) {
                  SnackbarHelper.warning(
                      context, 'Please fill in all required fields');
                  return;
                }

                try {
                  final data = <String, dynamic>{
                    'name': name,
                    'email': email,
                    'role': selectedRole.name,
                  };
                  if (password.isNotEmpty) data['password'] = password;
                  await ref
                      .read(superAdminRepositoryProvider)
                      .updateUser(user.id, data);
                  await ref.read(superAdminUsersProvider.notifier).loadUsers();
                } catch (e) {
                  if (context.mounted) {
                    SnackbarHelper.error(
                        context, 'Could not update user. Please try again.');
                  }
                  return;
                }

                _notify('User Updated', '$name has been updated.', 'system');
                Navigator.of(ctx).pop();
              },
              child: Text('Save',
                  style: GoogleFonts.inter(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteUserConfirm(BuildContext context, UserAccount user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded,
                color: Colors.red, size: 22),
            const SizedBox(width: 8),
            Text(
              'Deactivate User',
              style: GoogleFonts.playfairDisplay(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ResortTheme.charcoal,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to deactivate "${user.name}" (${user.email})?\n\n'
          'They will no longer be able to log in. This action can be reversed.',
          style: GoogleFonts.inter(fontSize: 13, color: ResortTheme.charcoal),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel', style: GoogleFonts.inter(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              try {
                await ref
                    .read(superAdminRepositoryProvider)
                    .deleteUser(user.id);
                await ref.read(superAdminUsersProvider.notifier).loadUsers();
              } catch (e) {
                if (context.mounted) {
                  SnackbarHelper.error(
                      context, 'Could not deactivate user. Please try again.');
                }
                Navigator.of(ctx).pop();
                return;
              }
              _notify('User Deactivated', '${user.name} has been deactivated.',
                  'system');
              Navigator.of(ctx).pop();
            },
            child: Text('Deactivate',
                style: GoogleFonts.inter(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showCreateUserDialog(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    UserRole selectedRole = UserRole.admin;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.person_add_alt_1,
                  color: ResortTheme.mossGreen, size: 22),
              const SizedBox(width: 8),
              Text(
                'Create User Account',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ResortTheme.charcoal,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  style: GoogleFonts.inter(fontSize: 13),
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: const Icon(Icons.person_outline, size: 18),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailController,
                  style: GoogleFonts.inter(fontSize: 13),
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    prefixIcon: const Icon(Icons.email_outlined, size: 18),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  style: GoogleFonts.inter(fontSize: 13),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline, size: 18),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<UserRole>(
                  initialValue: selectedRole,
                  decoration: InputDecoration(
                    labelText: 'Role',
                    prefixIcon: const Icon(Icons.badge_outlined, size: 18),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  items: UserRole.values
                      .map((role) => DropdownMenuItem(
                            value: role,
                            child: Text(role.name,
                                style: GoogleFonts.inter(fontSize: 13)),
                          ))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setDialogState(() => selectedRole = val);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child:
                  Text('Cancel', style: GoogleFonts.inter(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ResortTheme.mossGreen,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                final name = nameController.text.trim();
                final email = emailController.text.trim().toLowerCase();
                final password = passwordController.text;

                if (name.isEmpty || email.isEmpty || password.isEmpty) {
                  SnackbarHelper.warning(
                      context, 'Please fill in all required fields');
                  return;
                }
                if (password.length < 6) {
                  SnackbarHelper.warning(
                      context, 'Password must be at least 6 characters');
                  return;
                }

                try {
                  await ref.read(superAdminRepositoryProvider).createUser({
                    'name': name,
                    'email': email,
                    'password': password,
                    'role': selectedRole.name,
                  });
                  await ref.read(superAdminUsersProvider.notifier).loadUsers();
                } catch (e) {
                  if (context.mounted) {
                    SnackbarHelper.error(
                        context, 'Could not create user. Please try again.');
                  }
                  return;
                }

                _notify(
                  'User Created',
                  '${selectedRole.name} account "$name" was created successfully.',
                  'system',
                );

                Navigator.of(ctx).pop();
              },
              child: Text(
                'Create',
                style: GoogleFonts.inter(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlobalConstraints() {
    final propertyAsync = ref.watch(propertyProvider);
    final activeResort = propertyAsync.valueOrNull;
    final settingsAsync = ref.watch(superAdminSettingsProvider);
    final settings = settingsAsync;
    final apiTaxRate = settings['taxRate'] is int ? settings['taxRate'] as int : ref.watch(taxRateProvider);
    final apiDepositRate = settings['depositRate'] is int ? settings['depositRate'] as int : ref.watch(depositRateProvider);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: ResortTheme.lightBone),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tune_rounded,
                  color: ResortTheme.mossGreen, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Global System Constraints',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ResortTheme.charcoal,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: ResortTheme.lightBone),
          const SizedBox(height: 16),
          Text(
            'MULTI-PROPERTY CLUSTER TOGGLES',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: ResortTheme.charcoal.withValues(alpha: 0.5),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Click a property to load its configuration, or onboard a new resort.',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: ResortTheme.charcoal.withValues(alpha: 0.4),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 32,
                child: ElevatedButton.icon(
                  onPressed: () => _showAddResortDialog(context),
                  icon: const Icon(Icons.add_home_work_rounded,
                      size: 14, color: ResortTheme.mossGreen),
                  label: Text(
                    'Onboard New Resort',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: ResortTheme.mossGreen,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ResortTheme.goldAccent,
                    foregroundColor: ResortTheme.mossGreen,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(builder: (context, constraints) {
            final double itemWidth = constraints.maxWidth > 500
                ? (constraints.maxWidth - 12) / 2
                : constraints.maxWidth;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: ref.watch(resortsListProvider).map((resort) {
                return SizedBox(
                  width: itemWidth,
                  height: 85,
                  child: _buildPropertyToggleButton(
                    resort: resort,
                    activeResort: activeResort,
                  ),
                );
              }).toList(),
            );
          }),
          const SizedBox(height: 24),
          const Divider(color: ResortTheme.lightBone),
          const SizedBox(height: 16),
          LayoutBuilder(builder: (context, constraints) {
            final double itemWidth = constraints.maxWidth > 500
                ? (constraints.maxWidth - 16) / 2
                : constraints.maxWidth;
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                SizedBox(
                  width: itemWidth,
                    child: _buildInputConfig(
                      label: 'LUXURY GST RATE',
                      value: apiTaxRate,
                      hint: 'Applied as tax rule multiplier.',
                      min: 5,
                      max: 28,
                      onChanged: (val) {
                        ref.read(taxRateProvider.notifier).state = val;
                        ref.read(superAdminSettingsProvider.notifier).updateSettings({...settings, 'taxRate': val});
                      },
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: _buildInputConfig(
                      label: 'MINIMUM ADVANCE DEPOSIT',
                      value: apiDepositRate,
                      hint: 'Lowest deposit factor to block dates.',
                      min: 10,
                      max: 100,
                      onChanged: (val) {
                        ref.read(depositRateProvider.notifier).state = val;
                        ref.read(superAdminSettingsProvider.notifier).updateSettings({...settings, 'depositRate': val});
                      },
                    ),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPropertyToggleButton(
      {required PropertyDetails resort,
      required PropertyDetails? activeResort}) {
    bool isActive = activeResort?.name == resort.name;
    return GestureDetector(
      onTap: () => _handlePropertyToggle(resort),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? ResortTheme.mossGreen : ResortTheme.softCream,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? ResortTheme.goldAccent : ResortTheme.lightBone,
            width: isActive ? 1.5 : 1.0,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: ResortTheme.mossGreen.withValues(alpha: 0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    resort.name,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isActive ? Colors.white : ResortTheme.charcoal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isActive)
                  const Icon(
                    Icons.check_circle_rounded,
                    color: ResortTheme.goldAccent,
                    size: 14,
                  )
                else
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: ResortTheme.lightBone, width: 1.5),
                    ),
                  ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${resort.city}, ${resort.state}',
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    color: isActive
                        ? Colors.white.withValues(alpha: 0.7)
                        : ResortTheme.charcoal.withValues(alpha: 0.5),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Base: ₹${resort.basePriceWeekday.toInt()}/night',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 10,
                    color: isActive
                        ? ResortTheme.goldAccent
                        : ResortTheme.mossGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputConfig({
    required String label,
    required int value,
    required String hint,
    required int min,
    required int max,
    required Function(int) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ResortTheme.softCream,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ResortTheme.lightBone),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: ResortTheme.charcoal.withValues(alpha: 0.5),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: ResortTheme.lightBone),
                ),
                child: IconButton(
                  constraints:
                      const BoxConstraints.tightFor(width: 36, height: 36),
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.remove,
                      size: 16, color: ResortTheme.mossGreen),
                  onPressed: value > min ? () => onChanged(value - 1) : null,
                ),
              ),
              Text(
                '$value%',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: ResortTheme.mossGreen,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: ResortTheme.lightBone),
                ),
                child: IconButton(
                  constraints:
                      const BoxConstraints.tightFor(width: 36, height: 36),
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.add,
                      size: 16, color: ResortTheme.mossGreen),
                  onPressed: value < max ? () => onChanged(value + 1) : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: ResortTheme.mossGreen,
              inactiveTrackColor: ResortTheme.lightBone,
              thumbColor: ResortTheme.goldAccent,
              overlayColor: ResortTheme.goldAccent.withValues(alpha: 0.2),
              valueIndicatorColor: ResortTheme.mossGreen,
              trackHeight: 3.0,
              valueIndicatorTextStyle:
                  GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 10),
            ),
            child: Slider(
              value: value.toDouble(),
              min: min.toDouble(),
              max: max.toDouble(),
              divisions: max - min,
              label: '$value%',
              onChanged: (val) => onChanged(val.round()),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            hint,
            style: GoogleFonts.inter(
              fontSize: 9,
              color: ResortTheme.charcoal.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatabaseAdmin() {
    final schemaAsync = ref.watch(superAdminSchemaProvider);
    final schemaData = schemaAsync.valueOrNull ?? [];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: ResortTheme.lightBone),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.storage_rounded,
                  color: ResortTheme.mossGreen, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Database Overview',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ResortTheme.charcoal,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: ResortTheme.lightBone),
          const SizedBox(height: 16),
          Text(
            'SCHEMA OVERVIEW',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: ResortTheme.charcoal.withValues(alpha: 0.5),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: ResortTheme.softCream,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: ResortTheme.lightBone),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Table(
                columnWidths: const {
                  0: FlexColumnWidth(2.5),
                  1: FlexColumnWidth(1.5),
                },
                children: [
                  if (schemaData.isEmpty)
                    _buildInspectorRow(
                      keyName: 'Loading schema...',
                      valueDesc: '',
                      isHeader: false,
                      isLast: true,
                    )
                  else
                    ...schemaData.asMap().entries.map((entry) {
                      final table = entry.value;
                      final isLast = entry.key == schemaData.length - 1;
                      return _buildInspectorRow(
                        keyName: table['name'] as String? ?? 'unknown',
                        valueDesc: '${table['rowCount'] ?? 0} rows',
                        isHeader: false,
                        isLast: isLast,
                      );
                    }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  TableRow _buildInspectorRow({
    required String keyName,
    required String valueDesc,
    bool isHeader = false,
    bool isLast = false,
  }) {
    return TableRow(
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(color: ResortTheme.lightBone, width: 1)),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              const Icon(Icons.key_rounded,
                  size: 14, color: ResortTheme.goldAccent),
              const SizedBox(width: 8),
              Text(
                keyName,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: ResortTheme.charcoal,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            valueDesc,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: ResortTheme.mossGreen,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildDialogField({
    required TextEditingController controller,
    required String label,
    required String hint,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: GoogleFonts.spaceGrotesk(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: ResortTheme.charcoal.withValues(alpha: 0.5),
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.inter(
                  fontSize: 12,
                  color: ResortTheme.charcoal.withValues(alpha: 0.35)),
              prefixIcon: icon != null
                  ? Icon(icon,
                      size: 16,
                      color: ResortTheme.charcoal.withValues(alpha: 0.5))
                  : null,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              filled: true,
              fillColor: ResortTheme.softCream,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: ResortTheme.lightBone),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: ResortTheme.lightBone),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: ResortTheme.mossGreen, width: 1.5),
              ),
            ),
            style: GoogleFonts.inter(fontSize: 13, color: ResortTheme.charcoal),
          ),
        ],
      ),
    );
  }

  void _showAddResortDialog(BuildContext context) {
    final nameController = TextEditingController();
    final taglineController = TextEditingController();
    final descController = TextEditingController();
    final locationController = TextEditingController();
    final cityController = TextEditingController();
    final stateController = TextEditingController();
    final basePriceController = TextEditingController();
    final weekendPriceController = TextEditingController();
    final extraGuestController = TextEditingController();
    final cleaningFeeController = TextEditingController();
    final picker = ImagePicker();
    XFile? pickedCoverImage;
    final List<XFile> pickedGalleryImages = [];
    final List<Amenity> customAmenities = [];
    final List<String> customRules = [];
    final amenityLabelController = TextEditingController();
    final ruleController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              title: Row(
                children: [
                  const Icon(Icons.add_home_work_rounded,
                      color: ResortTheme.mossGreen, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Onboard New Resort',
                    style: GoogleFonts.playfairDisplay(
                      fontWeight: FontWeight.bold,
                      color: ResortTheme.mossGreen,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 500,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 8),

                      // Core info
                      _buildDialogField(
                          controller: nameController,
                          label: 'Resort Name',
                          hint: 'e.g. Whispering Pines Villa',
                          icon: Icons.hotel_rounded),
                      _buildDialogField(
                          controller: taglineController,
                          label: 'Tagline',
                          hint: 'e.g. A Scenic Ridge Retreat',
                          icon: Icons.tag_rounded),

                      // Description
                      _buildMultilineField(
                          controller: descController,
                          label: 'Description',
                          hint: 'Describe the resort experience...',
                          icon: Icons.description_outlined),

                      // Cover Image
                      Text('COVER IMAGE',
                          style: GoogleFonts.spaceGrotesk(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color:
                                  ResortTheme.charcoal.withValues(alpha: 0.5),
                              letterSpacing: 1.0)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          OutlinedButton.icon(
                            icon: const Icon(Icons.image_outlined, size: 18),
                            label: Text('Pick Cover Image',
                                style: GoogleFonts.inter(fontSize: 12)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: ResortTheme.mossGreen,
                              side: const BorderSide(
                                  color: ResortTheme.mossGreen),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () async {
                              final xFile = await picker.pickImage(
                                  source: ImageSource.gallery);
                              if (xFile != null) {
                                setDialogState(() => pickedCoverImage = xFile);
                              }
                            },
                          ),
                          if (pickedCoverImage != null) ...[
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              onPressed: () =>
                                  setDialogState(() => pickedCoverImage = null),
                            ),
                          ],
                        ],
                      ),
                      if (pickedCoverImage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(File(pickedCoverImage!.path),
                                height: 120,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const SizedBox()),
                          ),
                        ),

                      // Gallery
                      const Divider(color: ResortTheme.lightBone),
                      Text('GALLERY IMAGES',
                          style: GoogleFonts.spaceGrotesk(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color:
                                  ResortTheme.charcoal.withValues(alpha: 0.5),
                              letterSpacing: 1.0)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          OutlinedButton.icon(
                            icon: const Icon(Icons.collections_outlined,
                                size: 18),
                            label: Text('Pick Gallery Images',
                                style: GoogleFonts.inter(fontSize: 12)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: ResortTheme.mossGreen,
                              side: const BorderSide(
                                  color: ResortTheme.mossGreen),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () async {
                              final xFiles = await picker.pickMultiImage();
                              if (xFiles.isNotEmpty) {
                                setDialogState(
                                    () => pickedGalleryImages.addAll(xFiles));
                              }
                            },
                          ),
                          if (pickedGalleryImages.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            TextButton(
                              onPressed: () => setDialogState(
                                  () => pickedGalleryImages.clear()),
                              child: Text('Clear all',
                                  style: GoogleFonts.inter(
                                      fontSize: 11,
                                      color: ResortTheme.charcoal
                                          .withValues(alpha: 0.5))),
                            ),
                          ],
                        ],
                      ),
                      if (pickedGalleryImages.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: SizedBox(
                            height: 60,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: pickedGalleryImages.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 6),
                              itemBuilder: (context, index) {
                                final img = pickedGalleryImages[index];
                                return Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(File(img.path),
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.cover),
                                    ),
                                    Positioned(
                                      top: -4,
                                      right: -4,
                                      child: GestureDetector(
                                        onTap: () => setDialogState(() =>
                                            pickedGalleryImages
                                                .removeAt(index)),
                                        child: const CircleAvatar(
                                          radius: 10,
                                          backgroundColor: Colors.black54,
                                          child: Icon(Icons.close,
                                              size: 12, color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),

                      // Location
                      _buildDialogField(
                          controller: locationController,
                          label: 'Full Location Address',
                          hint:
                              'e.g. Near Ridge Point, Ooty, Tamil Nadu, India',
                          icon: Icons.pin_drop_rounded),
                      Row(
                        children: [
                          Expanded(
                              child: _buildDialogField(
                                  controller: cityController,
                                  label: 'City',
                                  hint: 'e.g. Ooty',
                                  icon: Icons.location_city_rounded)),
                          const SizedBox(width: 12),
                          Expanded(
                              child: _buildDialogField(
                                  controller: stateController,
                                  label: 'State',
                                  hint: 'e.g. Tamil Nadu')),
                        ],
                      ),

                      // Pricing
                      const Divider(color: ResortTheme.lightBone),
                      Text('PRICING',
                          style: GoogleFonts.spaceGrotesk(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color:
                                  ResortTheme.charcoal.withValues(alpha: 0.5),
                              letterSpacing: 1.0)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                              child: _buildDialogField(
                                  controller: basePriceController,
                                  label: 'Weekday Price (₹)',
                                  hint: 'e.g. 12000',
                                  icon: Icons.currency_rupee_rounded)),
                          const SizedBox(width: 12),
                          Expanded(
                              child: _buildDialogField(
                                  controller: weekendPriceController,
                                  label: 'Weekend Price (₹)',
                                  hint: 'e.g. 18000')),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                              child: _buildDialogField(
                                  controller: extraGuestController,
                                  label: 'Extra Guest Charge (₹)',
                                  hint: 'e.g. 1500',
                                  icon: Icons.person_add_alt_1)),
                          const SizedBox(width: 12),
                          Expanded(
                              child: _buildDialogField(
                                  controller: cleaningFeeController,
                                  label: 'Cleaning Fee (₹)',
                                  hint: 'e.g. 2000')),
                        ],
                      ),

                      // Amenities
                      const Divider(color: ResortTheme.lightBone),
                      Text('AMENITIES',
                          style: GoogleFonts.spaceGrotesk(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color:
                                  ResortTheme.charcoal.withValues(alpha: 0.5),
                              letterSpacing: 1.0)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDialogField(
                                controller: amenityLabelController,
                                label: 'Add Amenity',
                                hint: 'e.g. Private Pool',
                                icon: Icons.celebration_outlined),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline,
                                color: ResortTheme.mossGreen),
                            onPressed: () {
                              if (amenityLabelController.text
                                  .trim()
                                  .isNotEmpty) {
                                setDialogState(() {
                                  customAmenities.add(Amenity(
                                      icon: 'Star',
                                      label: amenityLabelController.text.trim(),
                                      category: 'Custom'));
                                  amenityLabelController.clear();
                                });
                              }
                            },
                          ),
                        ],
                      ),
                      if (customAmenities.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: customAmenities
                                .asMap()
                                .entries
                                .map((e) => Chip(
                                      avatar: const Icon(Icons.star,
                                          size: 14,
                                          color: ResortTheme.goldAccent),
                                      label: Text(e.value.label,
                                          style:
                                              GoogleFonts.inter(fontSize: 10)),
                                      deleteIcon:
                                          const Icon(Icons.close, size: 14),
                                      onDeleted: () => setDialogState(() =>
                                          customAmenities.removeAt(e.key)),
                                    ))
                                .toList(),
                          ),
                        ),

                      // Rules
                      const Divider(color: ResortTheme.lightBone),
                      Text('RULES & POLICIES',
                          style: GoogleFonts.spaceGrotesk(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color:
                                  ResortTheme.charcoal.withValues(alpha: 0.5),
                              letterSpacing: 1.0)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDialogField(
                                controller: ruleController,
                                label: 'Add Rule',
                                hint: 'e.g. No smoking inside villas',
                                icon: Icons.rule_rounded),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline,
                                color: ResortTheme.mossGreen),
                            onPressed: () {
                              if (ruleController.text.trim().isNotEmpty) {
                                setDialogState(() {
                                  customRules.add(ruleController.text.trim());
                                  ruleController.clear();
                                });
                              }
                            },
                          ),
                        ],
                      ),
                      if (customRules.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: customRules
                                .asMap()
                                .entries
                                .map((e) => Chip(
                                      label: Text(e.value,
                                          style:
                                              GoogleFonts.inter(fontSize: 10)),
                                      deleteIcon:
                                          const Icon(Icons.close, size: 14),
                                      onDeleted: () => setDialogState(
                                          () => customRules.removeAt(e.key)),
                                    ))
                                .toList(),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              actionsPadding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel',
                      style: GoogleFonts.inter(
                          color: ResortTheme.charcoal.withValues(alpha: 0.6),
                          fontWeight: FontWeight.bold)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final defaultAmenities = [
                      const Amenity(
                          icon: 'Pool',
                          label: 'Infinity Pool',
                          category: 'Luxury'),
                      const Amenity(
                          icon: 'Wifi',
                          label: 'High Speed WiFi',
                          category: 'Essentials'),
                    ];
                    final amenities = customAmenities.isNotEmpty
                        ? customAmenities
                        : defaultAmenities;
                    final rules = customRules.isNotEmpty
                        ? customRules
                        : [
                            'No smoking inside villas',
                            'Quiet hours after 10 PM'
                          ];

                    final name = nameController.text.isNotEmpty
                        ? nameController.text
                        : 'New Luxury Resort';
                    final tagline = taglineController.text.isNotEmpty
                        ? taglineController.text
                        : 'A Premium Getaway';
                    final description = descController.text.isNotEmpty
                        ? descController.text
                        : 'A newly onboarded premium sanctuary.';
                    final location = locationController.text.isNotEmpty
                        ? locationController.text
                        : 'Unknown Location';
                    final city = cityController.text.isNotEmpty
                        ? cityController.text
                        : 'Unknown City';
                    final state = stateController.text.isNotEmpty
                        ? stateController.text
                        : 'Unknown State';
                    final basePriceWeekday =
                        double.tryParse(basePriceController.text) ?? 10000;
                    final basePriceWeekend =
                        double.tryParse(weekendPriceController.text) ?? 15000;
                    final extraGuestCharge =
                        double.tryParse(extraGuestController.text) ?? 2000;
                    final cleaningFee =
                        double.tryParse(cleaningFeeController.text) ?? 1500;

                    try {
                      final repo = ref.read(superAdminRepositoryProvider);
                      final data = <String, dynamic>{
                        'name': name,
                        'tagline': tagline,
                        'description': description,
                        'location': location,
                        'city': city,
                        'state': state,
                        'basePriceWeekday': basePriceWeekday.toString(),
                        'basePriceWeekend': basePriceWeekend.toString(),
                        'extraGuestCharge': extraGuestCharge.toString(),
                        'cleaningFee': cleaningFee.toString(),
                        'amenities': jsonEncode(amenities
                            .map((a) => {
                                  'icon': a.icon,
                                  'label': a.label,
                                  'category': a.category,
                                })
                            .toList()),
                        'rules': jsonEncode(rules),
                      };
                      if (pickedCoverImage != null) {
                        data['image'] = await MultipartFile.fromFile(
                          pickedCoverImage!.path,
                          filename: pickedCoverImage!.name,
                        );
                      }
                      if (pickedGalleryImages.isNotEmpty) {
                        data['gallery'] = await Future.wait(
                          pickedGalleryImages.map(
                            (x) => MultipartFile.fromFile(x.path,
                                filename: x.name),
                          ),
                        );
                      }
                      await repo.createProperty(data);
                    } catch (e) {
                      if (context.mounted) {
                        SnackbarHelper.error(context,
                            'Could not create property. Please try again.');
                      }
                      return;
                    }

                    _notify(
                      'Resort Added',
                      '$name has been successfully added to the portal.',
                      'system',
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ResortTheme.mossGreen,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                  child: Text('Add Resort',
                      style: GoogleFonts.inter(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildMultilineField(
      {required TextEditingController controller,
      required String label,
      required String hint,
      IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(),
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: ResortTheme.charcoal.withValues(alpha: 0.5),
                  letterSpacing: 1.0)),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.inter(
                  fontSize: 12,
                  color: ResortTheme.charcoal.withValues(alpha: 0.35)),
              prefixIcon: icon != null
                  ? Icon(icon,
                      size: 16,
                      color: ResortTheme.charcoal.withValues(alpha: 0.5))
                  : null,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              filled: true,
              fillColor: ResortTheme.softCream,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: ResortTheme.lightBone)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: ResortTheme.lightBone)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                      color: ResortTheme.mossGreen, width: 1.5)),
            ),
            style: GoogleFonts.inter(fontSize: 13, color: ResortTheme.charcoal),
          ),
        ],
      ),
    );
  }

  Widget _buildAuditLogsView() {
    final logs = ref.watch(superAdminAuditLogsProvider);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: ResortTheme.lightBone),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.history_rounded, color: ResortTheme.mossGreen, size: 22),
              const SizedBox(width: 8),
              Text('Audit Logs', style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.bold, color: ResortTheme.charcoal)),
            ],
          ),
          const SizedBox(height: 8),
          Text('All system actions recorded for compliance and monitoring.', style: GoogleFonts.inter(fontSize: 11, color: ResortTheme.charcoal.withValues(alpha: 0.5))),
          const SizedBox(height: 16),
          const Divider(color: ResortTheme.lightBone),
          const SizedBox(height: 16),
          if (logs.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Icon(Icons.history_rounded, size: 40, color: ResortTheme.charcoal.withValues(alpha: 0.15)),
                    const SizedBox(height: 12),
                    Text('No audit logs recorded yet.', style: GoogleFonts.inter(fontSize: 13, color: ResortTheme.charcoal.withValues(alpha: 0.5))),
                  ],
                ),
              ),
            )
          else
            ...logs.map((log) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: ResortTheme.softCream,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: ResortTheme.lightBone),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: ResortTheme.goldAccent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.touch_app_rounded, size: 16, color: ResortTheme.goldAccent),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(log['action'] as String? ?? '', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: ResortTheme.charcoal)),
                            const SizedBox(width: 8),
                            if (log['targetType'] != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: ResortTheme.mossGreen.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Text(log['targetType'] as String? ?? '', style: GoogleFonts.spaceGrotesk(fontSize: 9, fontWeight: FontWeight.bold, color: ResortTheme.mossGreen)),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        if (log['userName'] != null)
                          Text('by ${log['userName']} (${log['userRole'] ?? ''})', style: GoogleFonts.inter(fontSize: 10, color: ResortTheme.charcoal.withValues(alpha: 0.5))),
                        if (log['details'] != null)
                          Text(log['details'] as String? ?? '', style: GoogleFonts.inter(fontSize: 10, color: ResortTheme.charcoal.withValues(alpha: 0.6))),
                      ],
                    ),
                  ),
                  Text(log['timestamp'] as String? ?? '', style: GoogleFonts.spaceGrotesk(fontSize: 9, color: ResortTheme.charcoal.withValues(alpha: 0.4))),
                ],
              ),
            )),
        ],
      ),
    );
  }

  Widget _buildNotificationsView() {
    final notifications = ref.watch(superAdminNotificationsProvider);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: ResortTheme.lightBone),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.notifications_outlined, color: ResortTheme.mossGreen, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text('System Notifications', style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.bold, color: ResortTheme.charcoal)),
              ),
              if (notifications.any((n) => !n.read))
                TextButton.icon(
                  onPressed: () async {
                    for (final n in notifications.where((n) => !n.read)) {
                      await ref.read(superAdminNotificationsProvider.notifier).markAsRead(n.id);
                    }
                  },
                  icon: const Icon(Icons.done_all, size: 14),
                  label: Text('Mark All Read', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: ResortTheme.lightBone),
          const SizedBox(height: 16),
          if (notifications.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Icon(Icons.notifications_none_rounded, size: 40, color: ResortTheme.charcoal.withValues(alpha: 0.15)),
                    const SizedBox(height: 12),
                    Text('No notifications yet.', style: GoogleFonts.inter(fontSize: 13, color: ResortTheme.charcoal.withValues(alpha: 0.5))),
                  ],
                ),
              ),
            )
          else
            ...notifications.map((n) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: n.read ? ResortTheme.softCream : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: n.read ? ResortTheme.lightBone : ResortTheme.goldAccent.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: n.read ? ResortTheme.charcoal.withValues(alpha: 0.05) : ResortTheme.goldAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      n.type == 'booking' ? Icons.book_online_outlined :
                      n.type == 'payment' ? Icons.payment_outlined :
                      n.type == 'promo' ? Icons.local_offer_outlined :
                      Icons.notifications_outlined,
                      size: 16, color: n.read ? ResortTheme.charcoal.withValues(alpha: 0.3) : ResortTheme.goldAccent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(n.title, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: ResortTheme.charcoal)),
                        const SizedBox(height: 2),
                        Text(n.message, style: GoogleFonts.inter(fontSize: 10, color: ResortTheme.charcoal.withValues(alpha: 0.6)), maxLines: 2, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(n.timestamp, style: GoogleFonts.spaceGrotesk(fontSize: 9, color: ResortTheme.charcoal.withValues(alpha: 0.4))),
                  if (!n.read) ...[
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 24,
                      child: IconButton(
                        icon: const Icon(Icons.check_circle_outline, size: 14),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                        color: ResortTheme.mossGreen,
                        onPressed: () => ref.read(superAdminNotificationsProvider.notifier).markAsRead(n.id),
                      ),
                    ),
                  ],
                ],
              ),
            )),
        ],
      ),
    );
  }

  Widget _buildFinancialSection() {
    final analyticsAsync = ref.watch(superAdminAnalyticsProvider);

    final analytics = analyticsAsync.valueOrNull;
    final revenueData = analytics?.revenue ?? {};
    final sourceData = analytics?.bookingSources ?? [];
    final resortData = analytics?.resortRevenueTable ?? [];

    final totalRevenue = (revenueData['totalRevenue'] as num?)?.toDouble() ?? 0;
    final adr = (revenueData['averageDailyRate'] as num?)?.toDouble() ?? 0;
    final totalNights = (revenueData['totalNights'] as num?)?.toInt() ?? 0;
    final pendingBalance = (revenueData['pendingBalance'] as num?)?.toDouble() ?? 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: ResortTheme.lightBone),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.analytics_rounded,
                  color: ResortTheme.mossGreen, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Financial Operations & Performance',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ResortTheme.charcoal,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: ResortTheme.lightBone),
          const SizedBox(height: 16),

          // Stat Cards Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 600;
              final cardWidth = isNarrow
                  ? (constraints.maxWidth - 16) / 2
                  : (constraints.maxWidth - 48) / 4;
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  SizedBox(
                    width: cardWidth,
                    child: _buildStatCard(
                      title: 'TOTAL REVENUE',
                      value: '₹${_formatAmount(totalRevenue)}',
                      subtext: 'Room stays & services',
                      icon: Icons.currency_rupee_rounded,
                      color: ResortTheme.mossGreen,
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: _buildStatCard(
                      title: 'AVERAGE DAILY RATE',
                      value: '₹${_formatAmount(adr)}',
                      subtext: 'Average per night stayed',
                      icon: Icons.bar_chart_rounded,
                      color: ResortTheme.goldAccent,
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: _buildStatCard(
                      title: 'TOTAL NIGHTS',
                      value: '$totalNights nights',
                      subtext: 'Total volume booked',
                      icon: Icons.bed_rounded,
                      color: ResortTheme.charcoal,
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: _buildStatCard(
                      title: 'PENDING BALANCE',
                      value: '₹${_formatAmount(pendingBalance)}',
                      subtext: 'Collections outstanding',
                      icon: Icons.pending_actions_rounded,
                      color: const Color(0xFFC53030),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // Row of Source Breakdown & Secondary metrics
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 800) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                        flex: 3, child: _buildSourceBreakdown(sourceData)),
                    const SizedBox(width: 32),
                    Expanded(
                        flex: 2,
                        child: _buildRefundsAndTaxStats(analyticsAsync)),
                  ],
                );
              } else {
                return Column(
                  children: [
                    _buildSourceBreakdown(sourceData),
                    const SizedBox(height: 24),
                    _buildRefundsAndTaxStats(analyticsAsync),
                  ],
                );
              }
            },
          ),
          const SizedBox(height: 24),

          // Resort breakdown table
          Text(
            'RESORT-BY-RESORT REVENUE BREAKDOWN',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: ResortTheme.charcoal.withValues(alpha: 0.5),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: ResortTheme.softCream,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: ResortTheme.lightBone),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Table(
                columnWidths: const {
                  0: FlexColumnWidth(2.5),
                  1: FlexColumnWidth(0.8),
                  2: FlexColumnWidth(1.2),
                  3: FlexColumnWidth(1.0),
                },
                children: [
                  TableRow(
                    decoration: const BoxDecoration(
                      color: ResortTheme.lightBone,
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        child: Text('PROPERTY NAME',
                            style: GoogleFonts.spaceGrotesk(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: ResortTheme.charcoal)),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        child: Text('BOOKINGS',
                            style: GoogleFonts.spaceGrotesk(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: ResortTheme.charcoal),
                            textAlign: TextAlign.right),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        child: Text('REVENUE',
                            style: GoogleFonts.spaceGrotesk(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: ResortTheme.charcoal),
                            textAlign: TextAlign.right),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        child: Text('OCCUPANCY',
                            style: GoogleFonts.spaceGrotesk(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: ResortTheme.charcoal),
                            textAlign: TextAlign.right),
                      ),
                    ],
                  ),
                  if (resortData.isEmpty)
                    TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                          child: Text('No resort data available',
                              style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: ResortTheme.charcoal.withValues(alpha: 0.5))),
                        ),
                      ],
                    )
                  else
                    ...resortData.asMap().entries.map((entry) {
                      final r = entry.value;
                      final isLast = entry.key == resortData.length - 1;
                      final rev = (r['totalRevenue'] as num?)?.toDouble() ?? 0;
                      final count = (r['totalBookings'] as num?)?.toInt() ?? 0;
                      final occRate = (r['occupancyRate'] as num?)?.toDouble() ?? 0;
                      final name = r['propertyName'] as String? ?? r['propertyId'] as String? ?? 'Unknown';
                      return TableRow(
                        decoration: BoxDecoration(
                          border: isLast
                              ? null
                              : const Border(
                                  bottom: BorderSide(
                                      color: ResortTheme.lightBone, width: 1)),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            child: Text(name,
                                style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: ResortTheme.charcoal)),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            child: Text('$count',
                                style: GoogleFonts.spaceGrotesk(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: ResortTheme.charcoal),
                                textAlign: TextAlign.right),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            child: Text('₹${_formatAmount(rev)}',
                                style: GoogleFonts.spaceGrotesk(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: ResortTheme.mossGreen),
                                textAlign: TextAlign.right),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            child: Text('${occRate.toStringAsFixed(1)}%',
                                style: GoogleFonts.spaceGrotesk(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: ResortTheme.charcoal),
                                textAlign: TextAlign.right),
                          ),
                        ],
                      );
                    }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtext,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: ResortTheme.softCream,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ResortTheme.lightBone),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: ResortTheme.charcoal.withValues(alpha: 0.5),
                    letterSpacing: 1.0,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Icon(icon, size: 14, color: color),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: ResortTheme.charcoal,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            subtext,
            style: GoogleFonts.inter(
              fontSize: 8,
              color: ResortTheme.charcoal.withValues(alpha: 0.5),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSourceBreakdown(List<Map<String, dynamic>> sourceData) {
    final totalBookings = sourceData.fold<int>(0, (sum, s) => sum + ((s['count'] as num?)?.toInt() ?? 0));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ResortTheme.softCream,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ResortTheme.lightBone),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'BOOKINGS BY CHANNEL',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: ResortTheme.charcoal.withValues(alpha: 0.6),
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 16),
          if (sourceData.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text('No booking source data available',
                  style: GoogleFonts.inter(fontSize: 11, color: ResortTheme.charcoal.withValues(alpha: 0.5))),
            )
          else
            ...sourceData.map((src) {
              final label = src['label'] as String? ?? src['source'] as String? ?? 'Unknown';
              final count = (src['count'] as num?)?.toInt() ?? 0;
              final revenue = (src['revenue'] as num?)?.toDouble() ?? 0;
              final percent = (src['percentage'] as num?)?.toDouble() ?? (totalBookings > 0 ? (count / totalBookings) * 100 : 0.0);

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            label,
                            style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: ResortTheme.charcoal),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$count (${percent.toStringAsFixed(1)}%)',
                          style: GoogleFonts.spaceGrotesk(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: ResortTheme.charcoal),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percent / 100,
                        minHeight: 5,
                        backgroundColor: ResortTheme.lightBone,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            ResortTheme.mossGreen),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '₹${_formatAmount(revenue)}',
                          style: GoogleFonts.spaceGrotesk(
                              fontSize: 9,
                              color: ResortTheme.mossGreen,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildRefundsAndTaxStats(AsyncValue<SuperAdminAnalyticsState>? analyticsAsync) {
    final analytics = analyticsAsync?.valueOrNull;
    final revenueData = analytics?.revenue ?? {};
    final currency = revenueData['currency'] as String? ?? 'INR';
    final period = revenueData['period'] as Map<String, dynamic>? ?? {};
    final periodFrom = period['start'] as String? ?? 'N/A';
    final periodTo = period['end'] as String? ?? 'N/A';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ResortTheme.softCream,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ResortTheme.lightBone),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'REVENUE PERIOD INFO',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: ResortTheme.charcoal.withValues(alpha: 0.6),
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 20),
          _buildDetailRow(
            icon: Icons.calendar_month_rounded,
            label: 'Reporting Period',
            value: '$periodFrom – $periodTo',
            subtext: 'Fiscal year to date',
            color: ResortTheme.mossGreen,
          ),
          const Divider(color: ResortTheme.lightBone, height: 24),
          _buildDetailRow(
            icon: Icons.currency_exchange_rounded,
            label: 'Base Currency',
            value: currency,
            subtext: 'All amounts in this currency',
            color: ResortTheme.goldAccent,
          ),
          const Divider(color: ResortTheme.lightBone, height: 24),
          _buildDetailRow(
            icon: Icons.analytics_rounded,
            label: 'Average Daily Rate (ADR)',
            value: '₹${_formatAmount((revenueData['averageDailyRate'] as num?)?.toDouble() ?? 0)}',
            subtext: 'Per occupied room/night',
            color: ResortTheme.charcoal,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required String subtext,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: ResortTheme.charcoal)),
              const SizedBox(height: 2),
              Text(subtext,
                  style: GoogleFonts.inter(
                      fontSize: 9,
                      color: ResortTheme.charcoal.withValues(alpha: 0.5))),
            ],
          ),
        ),
        Text(
          value,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: ResortTheme.charcoal,
          ),
        ),
      ],
    );
  }

  String _formatAmount(double amt) {
    if (amt >= 100000) {
      return '${(amt / 100000).toStringAsFixed(2)} L';
    }
    return amt.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}
