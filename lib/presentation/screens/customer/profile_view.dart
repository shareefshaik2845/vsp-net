import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/state_provider.dart';
import '../../../core/theme.dart';
import '../../../core/snackbar_helper.dart';

class CustomerProfileView extends ConsumerStatefulWidget {
  const CustomerProfileView({super.key});

  @override
  ConsumerState<CustomerProfileView> createState() =>
      _CustomerProfileViewState();
}

class _CustomerProfileViewState extends ConsumerState<CustomerProfileView> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();

  bool _isEditing = false;
  bool _showPasswordSection = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  String _formatIndianCurrency(dynamic value) {
    final num n =
        value is num ? value : (double.tryParse(value.toString()) ?? 0);
    final String s = n.toInt().toString();
    if (s.length <= 3) return s;
    final String lastThree = s.substring(s.length - 3);
    String remaining = s.substring(0, s.length - 3);
    final List<String> groups = [];
    while (remaining.length > 2) {
      groups.insert(0, remaining.substring(remaining.length - 2));
      remaining = remaining.substring(0, remaining.length - 2);
    }
    if (remaining.isNotEmpty) {
      groups.insert(0, remaining);
    }
    return '${groups.join(',')},$lastThree';
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(customerProfileProvider);
    final statsAsync = ref.watch(customerStatsProvider);

    final profileData = profileAsync.valueOrNull ?? {};
    final name = (profileData['name'] as String?) ?? '';
    final email = (profileData['email'] as String?) ?? '';
    final phone = (profileData['phone'] as String?) ?? '';

    if (!_isEditing && _nameController.text != name) {
      _nameController.text = name;
      _emailController.text = email;
      _phoneController.text = phone;
    }

    final stats = statsAsync.valueOrNull ?? {};
    final totalBookings = stats['totalBookings'] as int? ??
        profileData['totalBookings'] as int? ??
        0;
    final totalSpent = (stats['totalSpent'] as num?)?.toDouble() ??
        (profileData['totalSpent'] as num?)?.toDouble() ??
        0;
    final activeStays = stats['activeStays'] as int? ?? 0;
    final memberSince = profileData['memberSince'] as String? ?? '';

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile details card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: const Color(0xFFE6E2D3)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row
                  LayoutBuilder(
                    builder: (context, headerConstraints) {
                      final isHeaderNarrow = headerConstraints.maxWidth < 420;
                      if (isHeaderNarrow) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: const BoxDecoration(
                                    color: AppColors.goldAccent,
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    name.isNotEmpty
                                        ? name.substring(0, 1).toUpperCase()
                                        : 'U',
                                    style: GoogleFonts.playfairDisplay(
                                      color: AppColors.mossGreen,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        name.isNotEmpty ? name : 'User Profile',
                                        style: GoogleFonts.playfairDisplay(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.mossGreen,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Direct Sanctuary Guest Member',
                                        style: GoogleFonts.inter(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.charcoal
                                              .withValues(alpha: 0.5),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              onPressed: () {
                                setState(() {
                                  if (_isEditing) {
                                    _nameController.text = name;
                                    _emailController.text = email;
                                    _phoneController.text = phone;
                                  }
                                  _isEditing = !_isEditing;
                                });
                              },
                              icon: Icon(
                                _isEditing ? Icons.close : Icons.edit_outlined,
                                size: 14,
                                color: AppColors.mossGreen,
                              ),
                              label: Text(
                                _isEditing ? 'Cancel' : 'Edit Profile',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.mossGreen,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                    color: AppColors.lightBone),
                                shape: RoundedRectangleBorder(
                                    borderRadius: AppRadius.mdBr),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
                              ),
                            ),
                          ],
                        );
                      }
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: const BoxDecoration(
                                    color: AppColors.goldAccent,
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    name.isNotEmpty
                                        ? name.substring(0, 1).toUpperCase()
                                        : 'U',
                                    style: GoogleFonts.playfairDisplay(
                                      color: AppColors.mossGreen,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        name.isNotEmpty ? name : 'User Profile',
                                        style: GoogleFonts.playfairDisplay(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.mossGreen,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Direct Sanctuary Guest Member',
                                        style: GoogleFonts.inter(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.charcoal
                                              .withValues(alpha: 0.5),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          OutlinedButton.icon(
                            onPressed: () {
                              setState(() {
                                if (_isEditing) {
                                  _nameController.text = name;
                                  _emailController.text = email;
                                  _phoneController.text = phone;
                                }
                                _isEditing = !_isEditing;
                              });
                            },
                            icon: Icon(
                              _isEditing ? Icons.close : Icons.edit_outlined,
                              size: 14,
                              color: AppColors.mossGreen,
                            ),
                            label: Text(
                              _isEditing ? 'Cancel' : 'Edit Profile',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.mossGreen,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side:
                                  const BorderSide(color: AppColors.lightBone),
                              shape: RoundedRectangleBorder(
                                  borderRadius: AppRadius.mdBr),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  const Divider(color: AppColors.lightBone),
                  const SizedBox(height: 24),

                  // Profile fields
                  _profileField('FULL NAME', _nameController, _isEditing,
                      Icons.person_outline),
                  const SizedBox(height: AppSpacing.lg),
                  _profileField('EMAIL ADDRESS', _emailController, _isEditing,
                      Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: AppSpacing.lg),
                  _profileField('TELEPHONE NUMBER', _phoneController,
                      _isEditing, Icons.phone_android_outlined,
                      keyboardType: TextInputType.phone),

                  if (_isEditing) ...[
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_nameController.text.trim().isEmpty ||
                              _emailController.text.trim().isEmpty ||
                              _phoneController.text.trim().isEmpty) {
                            SnackbarHelper.warning(context,
                                'Please complete all contact profile fields.');
                            return;
                          }

                          await ref
                              .read(customerProfileProvider.notifier)
                              .updateProfile({
                            'name': _nameController.text.trim(),
                            'email': _emailController.text.trim(),
                            'phone': _phoneController.text.trim(),
                          });

                          setState(() {
                            _isEditing = false;
                          });
                          SnackbarHelper.success(
                              context, 'Profile details updated successfully!');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.mossGreen,
                          shape: RoundedRectangleBorder(
                              borderRadius: AppRadius.lgBr),
                        ),
                        child: Text(
                          'Save Settings Changes',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Profile stats
            Text(
              'ACCOUNT MEMBERSHIP INSIGHTS',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: AppColors.charcoal.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 600;

                final statItems = [
                  _statCard(
                      'Total Bookings',
                      '$totalBookings',
                      const Color(0xFFE8EAF6),
                      const Color(0xFF3F51B5),
                      Icons.book_online_outlined),
                  _statCard(
                      'Active Stays',
                      '$activeStays Stays',
                      const Color(0xFFE8F5E9),
                      const Color(0xFF2E7D32),
                      Icons.hotel_outlined),
                  _statCard(
                      'Total Spent',
                      '₹${_formatIndianCurrency(totalSpent)}',
                      const Color(0xFFFFF8E1),
                      const Color(0xFFF57F17),
                      Icons.wallet_outlined),
                ];

                if (isMobile) {
                  return Column(
                    children: statItems
                        .map((card) => Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: card,
                            ))
                        .toList(),
                  );
                } else {
                  return Row(
                    children: statItems
                        .map((card) => Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 12.0),
                                child: card,
                              ),
                            ))
                        .toList(),
                  );
                }
              },
            ),
            if (memberSince.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Member since ${memberSince.split('T').first}',
                style: GoogleFonts.inter(fontSize: 11, color: Colors.grey),
              ),
            ],

            const SizedBox(height: 24),

            // Password Change Section
            GestureDetector(
              onTap: () =>
                  setState(() => _showPasswordSection = !_showPasswordSection),
              child: Container(
                padding: AppSpacing.allLg,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppRadius.lgBr,
                  border: Border.all(color: const Color(0xFFE6E2D3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock_outline,
                        size: 18, color: AppColors.mossGreen),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Security & Password',
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: AppColors.charcoal),
                      ),
                    ),
                    Icon(
                      _showPasswordSection
                          ? Icons.expand_less
                          : Icons.expand_more,
                      color: AppColors.charcoal.withValues(alpha: 0.5),
                    ),
                  ],
                ),
              ),
            ),
            if (_showPasswordSection) ...[
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: AppSpacing.allLg,
                decoration: BoxDecoration(
                  color: AppColors.stoneBg.withValues(alpha: 0.3),
                  borderRadius: AppRadius.lgBr,
                  border: Border.all(color: const Color(0xFFE6E2D3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _currentPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Current Password',
                        prefixIcon: const Icon(Icons.lock, size: 18),
                        border:
                            OutlineInputBorder(borderRadius: AppRadius.mdBr),
                      ),
                      style: GoogleFonts.inter(fontSize: 12),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      controller: _newPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'New Password',
                        prefixIcon: const Icon(Icons.lock_outline, size: 18),
                        border:
                            OutlineInputBorder(borderRadius: AppRadius.mdBr),
                      ),
                      style: GoogleFonts.inter(fontSize: 12),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_currentPasswordController.text.isEmpty ||
                              _newPasswordController.text.isEmpty) {
                            SnackbarHelper.warning(context,
                                'Please fill in both password fields.');
                            return;
                          }
                          try {
                            await ref
                                .read(customerRepositoryProvider)
                                .changePassword(
                                  _currentPasswordController.text,
                                  _newPasswordController.text,
                                );
                            _currentPasswordController.clear();
                            _newPasswordController.clear();
                            SnackbarHelper.success(
                                context, 'Password changed successfully!');
                          } catch (e) {
                            SnackbarHelper.error(
                                context, 'Failed to change password.');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.mossGreen,
                          shape: RoundedRectangleBorder(
                              borderRadius: AppRadius.mdBr),
                        ),
                        child: Text(
                          'Change Password',
                          style: GoogleFonts.inter(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _profileField(String label, TextEditingController controller,
      bool enabled, IconData prefixIcon,
      {TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            color: AppColors.charcoal.withValues(alpha: 0.4),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: enabled
                ? AppColors.charcoal
                : AppColors.charcoal.withValues(alpha: 0.6),
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(prefixIcon,
                size: 18, color: AppColors.mossGreen.withValues(alpha: 0.6)),
            filled: true,
            fillColor: enabled
                ? Colors.white
                : AppColors.stoneBg.withValues(alpha: 0.4),
            disabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.lgBr,
              borderSide: const BorderSide(color: AppColors.lightBone),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.lgBr,
              borderSide:
                  BorderSide(color: AppColors.lightBone.withValues(alpha: 0.8)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.lgBr,
              borderSide: const BorderSide(color: AppColors.mossGreen),
            ),
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
      ],
    );
  }

  Widget _statCard(
      String label, String value, Color bg, Color text, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.xxlBr,
        border: Border.all(color: const Color(0xFFE6E2D3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.01),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: text),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 8.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.charcoal.withValues(alpha: 0.4),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.charcoal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
