import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/snackbar_helper.dart';
import '../../../core/theme.dart';
import '../../../domain/entities.dart';

class RoleManagementView extends ConsumerStatefulWidget {
  final List<RoleDefinition>? remoteRoles;
  final Future<void> Function(RoleDefinition)? onRemoteSave;
  const RoleManagementView({super.key, this.remoteRoles, this.onRemoteSave});

  @override
  ConsumerState<RoleManagementView> createState() => _RoleManagementViewState();
}

class _RoleManagementViewState extends ConsumerState<RoleManagementView> {
  UserRole? _selectedRoleValue;
  List<RolePermission>? _dirtyPermissions;

  static const Map<UserRole, String> _roleLabels = {
    UserRole.superAdmin: 'Super Administrator',
    UserRole.admin: 'Administrator',
    UserRole.staff: 'Staff',
    UserRole.accountant: 'Accountant',
    UserRole.customer: 'Customer',
  };

  static const Map<UserRole, String> _roleDescriptions = {
    UserRole.superAdmin: 'Full system access',
    UserRole.admin: 'System administration access',
    UserRole.staff: 'Day-to-day operations',
    UserRole.accountant: 'Financial and reports access',
    UserRole.customer: 'Standard customer access',
  };

  List<RoleDefinition> get _roles => widget.remoteRoles ?? [];

  String _backendId(UserRole role) {
    switch (role) {
      case UserRole.superAdmin: return 'SUPER_ADMIN';
      case UserRole.admin: return 'ADMIN';
      case UserRole.staff: return 'STAFF';
      case UserRole.accountant: return 'ACCOUNTANT';
      case UserRole.customer: return 'CUSTOMER';
    }
  }

  RoleDefinition? _findRole(UserRole role) {
    final id = _backendId(role);
    try {
      return _roles.firstWhere((r) => r.id.toUpperCase() == id);
    } catch (_) {
      return null;
    }
  }

  RoleDefinition? get _selectedRole {
    if (_selectedRoleValue == null) return null;
    return _findRole(_selectedRoleValue!);
  }

  bool get _isSuperAdmin => _selectedRoleValue == UserRole.superAdmin;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_selectedRoleValue == null) {
        _selectRole(UserRole.superAdmin);
      }
    });
  }

  void _selectRole(UserRole role) {
    final existing = _findRole(role);
    final permissions = existing != null
        ? existing.permissions.map((p) => RolePermission(resource: p.resource, actions: List<PermissionAction>.from(p.actions))).toList()
        : <RolePermission>[];
    setState(() {
      _selectedRoleValue = role;
      _dirtyPermissions = permissions;
    });
  }

  String _labelFor(UserRole role) => _roleLabels[role] ?? role.name;
  String _descriptionFor(UserRole role) => _roleDescriptions[role] ?? '';

  void _togglePermission(PermissionResource resource, PermissionAction action) {
    if (_isSuperAdmin || _dirtyPermissions == null) return;
    final current = List<RolePermission>.from(_dirtyPermissions!);
    final idx = current.indexWhere((p) => p.resource == resource);
    if (idx != -1) {
      final existing = List<PermissionAction>.from(current[idx].actions);
      if (existing.contains(action)) {
        final updated = existing.where((a) => a != action).toList();
        if (updated.isEmpty) {
          current.removeAt(idx);
        } else {
          current[idx] = RolePermission(resource: resource, actions: updated);
        }
      } else {
        current[idx] = RolePermission(resource: resource, actions: [...existing, action]);
      }
    } else {
      current.add(RolePermission(resource: resource, actions: [action]));
    }
    setState(() => _dirtyPermissions = current);
  }

  Future<void> _saveChanges() async {
    if (_selectedRoleValue == null || _dirtyPermissions == null || _isSuperAdmin) return;
    final updated = RoleDefinition(
      id: _backendId(_selectedRoleValue!),
      displayName: '',
      description: '',
      permissions: _dirtyPermissions!,
    );
    try {
      if (widget.onRemoteSave != null) {
        await widget.onRemoteSave!(updated);
      }
      if (!context.mounted) return;
      SnackbarHelper.success(context, '${_labelFor(_selectedRoleValue!)} permissions saved.');
    } catch (e) {
      if (!context.mounted) return;
      SnackbarHelper.error(context, 'Failed to save permissions: $e');
    }
  }

  bool _hasChanges() {
    if (_selectedRoleValue == null || _dirtyPermissions == null) return false;
    if (_selectedRole == null) return _dirtyPermissions!.isNotEmpty;
    if (_selectedRole!.permissions.length != _dirtyPermissions!.length) return true;
    for (final p in _dirtyPermissions!) {
      final original = _selectedRole!.permissions.where((x) => x.resource == p.resource);
      final origActions = original.isNotEmpty ? original.first.actions : <PermissionAction>[];
      if (p.actions.length != origActions.length || !p.actions.every((a) => origActions.contains(a))) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    const allResources = PermissionResource.values;
    const allActions = PermissionAction.values;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: ResortTheme.lightBone),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.admin_panel_settings_outlined, color: ResortTheme.mossGreen, size: 22),
              const SizedBox(width: 8),
              Text(
                'Roles & Permissions',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ResortTheme.charcoal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Select a role to view and edit its permissions. Click Save to apply changes.',
            style: GoogleFonts.inter(fontSize: 11, color: ResortTheme.charcoal.withValues(alpha: 0.5)),
          ),
          const SizedBox(height: 16),
          const Divider(color: ResortTheme.lightBone),
          const SizedBox(height: 16),

          // Role selector dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: ResortTheme.softCream,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ResortTheme.lightBone),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<UserRole>(
                value: _selectedRoleValue,
                isExpanded: true,
                hint: Text('Select a role', style: GoogleFonts.inter(fontSize: 13, color: ResortTheme.charcoal)),
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: ResortTheme.charcoal),
                items: UserRole.values.map((role) => DropdownMenuItem(
                  value: role,
                  child: Row(
                    children: [
                      _roleIcon(role.name),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_labelFor(role), style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13), overflow: TextOverflow.ellipsis),
                            if (_descriptionFor(role).isNotEmpty)
                              Text(_descriptionFor(role), style: GoogleFonts.inter(fontSize: 9, color: ResortTheme.charcoal.withValues(alpha: 0.5)), overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    ],
                  ),
                )).toList(),
                onChanged: (role) {
                  if (role != null) _selectRole(role);
                },
              ),
            ),
          ),

          const SizedBox(height: 20),

          if (_selectedRoleValue == null)
            const Center(child: Padding(
              padding: EdgeInsets.all(40),
              child: Text('Select a role above to configure permissions.'),
            ))
          else if (_isSuperAdmin)
            _buildSuperAdminReadonly(allResources, allActions)
          else ...[
            _buildPermissionsGrid(allResources, allActions),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: _hasChanges() ? () => _selectRole(_selectedRoleValue!) : null,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: Text('Reset', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12)),
                  style: TextButton.styleFrom(foregroundColor: ResortTheme.charcoal.withValues(alpha: 0.6)),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _hasChanges() ? _saveChanges : null,
                  icon: const Icon(Icons.save_outlined, size: 16),
                  label: Text('Save Changes', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ResortTheme.mossGreen,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: ResortTheme.mossGreen.withValues(alpha: 0.3),
                    disabledForegroundColor: Colors.white.withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSuperAdminReadonly(List<PermissionResource> allResources, List<PermissionAction> allActions) {
    final role = _selectedRole;
    if (role == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ResortTheme.goldAccent.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ResortTheme.goldAccent.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _roleIcon(role.id),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      role.displayName.isNotEmpty ? role.displayName : _labelFor(_selectedRoleValue!),
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: ResortTheme.charcoal),
                    ),
                    Text(
                      'Super Admin has full system access. Permissions are locked and cannot be modified.',
                      style: GoogleFonts.inter(fontSize: 10, color: ResortTheme.charcoal.withValues(alpha: 0.5)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowHeight: 36,
              dataRowMinHeight: 32,
              dataRowMaxHeight: 32,
              columnSpacing: 8,
              columns: [
                const DataColumn(label: Text('Resource', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
                ...allActions.map((action) => DataColumn(
                  label: Text(action.name[0].toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                )),
              ],
              rows: allResources.map((resource) {
                final perm = role.permissions.where((p) => p.resource == resource);
                final actions = perm.isNotEmpty ? perm.first.actions : <PermissionAction>[];
                return DataRow(cells: [
                  DataCell(Text(resource.name, style: GoogleFonts.inter(fontSize: 10, color: ResortTheme.charcoal.withValues(alpha: 0.7)))),
                  ...allActions.map((action) => DataCell(
                    Icon(
                      actions.contains(action) ? Icons.check_circle : Icons.remove_circle_outline,
                      size: 16,
                      color: actions.contains(action) ? Colors.green : Colors.grey.shade300,
                    ),
                  )),
                ]);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionsGrid(List<PermissionResource> allResources, List<PermissionAction> allActions) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowHeight: 36,
        dataRowMinHeight: 32,
        dataRowMaxHeight: 32,
        columnSpacing: 8,
        columns: [
          const DataColumn(label: Text('Resource', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
          ...allActions.map((action) => DataColumn(
            label: Text(action.name[0].toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          )),
        ],
        rows: allResources.map((resource) {
          final perm = _dirtyPermissions!.where((p) => p.resource == resource);
          final actions = perm.isNotEmpty ? perm.first.actions : <PermissionAction>[];
          return DataRow(cells: [
            DataCell(Text(resource.name, style: GoogleFonts.inter(fontSize: 10, color: ResortTheme.charcoal.withValues(alpha: 0.7)))),
            ...allActions.map((action) {
              final checked = actions.contains(action);
              return DataCell(
                InkWell(
                  onTap: () => _togglePermission(resource, action),
                  child: Icon(
                    checked ? Icons.check_box : Icons.check_box_outline_blank,
                    size: 16,
                    color: checked ? ResortTheme.mossGreen : Colors.grey.shade400,
                  ),
                ),
              );
            }),
          ]);
        }).toList(),
      ),
    );
  }

  Widget _roleIcon(String id) {
    IconData icon;
    Color color;
    switch (id) {
      case 'superAdmin':
        icon = Icons.admin_panel_settings_outlined;
        color = const Color(0xFFC53030);
        break;
      case 'admin':
        icon = Icons.dashboard_customize_outlined;
        color = Colors.orange;
        break;
      case 'accountant':
        icon = Icons.receipt_long_outlined;
        color = Colors.purple;
        break;
      case 'staff':
        icon = Icons.cleaning_services_outlined;
        color = Colors.teal;
        break;
      default:
        icon = Icons.hotel_outlined;
        color = Colors.blue;
    }
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
      child: Icon(icon, size: 18, color: color),
    );
  }
}
