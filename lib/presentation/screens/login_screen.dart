import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/state_provider.dart';
import '../routing/app_router.dart';
import '../../core/theme.dart';
import '../../domain/entities.dart';
import '../widgets/vsp_nest_logo.dart';
import '../../core/api_client.dart';
import '../../core/snackbar_helper.dart';
import '../../data/remote/auth_api_service.dart';

UserRole? _mapBackendRole(String backendRole) {
  switch (backendRole) {
    case 'SUPER_ADMIN':
      return UserRole.superAdmin;
    case 'ADMIN':
      return UserRole.admin;
    case 'STAFF':
      return UserRole.staff;
    case 'ACCOUNTANT':
      return UserRole.accountant;
    case 'CUSTOMER':
      return UserRole.customer;
    default:
      return null;
  }
}

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  UserRole _selectedRole = UserRole.customer;
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onRoleChanged(UserRole role) {
    setState(() {
      _selectedRole = role;
    });
  }

  String _getRoleLabel(UserRole role) {
    switch (role) {
      case UserRole.customer:
        return 'Customer Suite';
      case UserRole.admin:
        return 'Operational Admin';
      case UserRole.staff:
        return 'Resort Staff';
      case UserRole.accountant:
        return 'Financial Accountant';
      case UserRole.superAdmin:
        return 'Super Admin';
    }
  }

  String _getRoleSubtitle(UserRole role) {
    switch (role) {
      case UserRole.customer:
        return 'Book stays, view invoices, request cancellations';
      case UserRole.admin:
        return 'Manage bookings, rules, check-ins & sync status';
      case UserRole.staff:
        return 'Update room cleanliness and housekeeping notes';
      case UserRole.accountant:
        return 'Audit refunds queue and track resort ledger';
      case UserRole.superAdmin:
        return 'System configuration and global parameters';
    }
  }

  IconData _getRoleIcon(UserRole role) {
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

  Future<void> _handleLogin() async {
    final email = _usernameController.text.trim().toLowerCase();
    final password = _passwordController.text;

    if (email.isEmpty) {
      SnackbarHelper.warning(context, 'Please enter an email address.');
      return;
    }

    if (password.isEmpty) {
      SnackbarHelper.warning(context, 'Please enter a password.');
      return;
    }

    if (password.length < 6) {
      SnackbarHelper.warning(context, 'Password must be at least 6 characters.');
      return;
    }

    setState(() => _isLoading = true);

    // Clear any stale tokens before login to avoid 403 from interceptor
    await ApiClient.instance.clearTokens();

    final result = await AuthApiService().login(email, password);

    if (!mounted) return;

    if (result == null) {
      setState(() => _isLoading = false);
      SnackbarHelper.error(context, 'Invalid email or password. Please try again.');
      return;
    }

    final targetRole = _mapBackendRole(result.user.role);
    if (targetRole == null) {
      setState(() => _isLoading = false);
      SnackbarHelper.error(context, 'Unknown user role. Please contact support.');
      return;
    }

    ref.read(activeRoleProvider.notifier).state = targetRole;
    ref.read(authenticatedRoleProvider.notifier).state = targetRole;

    if (targetRole == UserRole.customer) {
      ref.read(activeTabProvider.notifier).state = 'villa';
      ref.read(customerProfileProvider.notifier).setProfile({
        'name': result.user.name,
        'email': result.user.email,
        'phone': result.user.phone ?? '',
        'id': result.user.id,
        'avatar': result.user.profileImageUrl ?? '',
      });
    }

    ref.read(isLoggedInProvider.notifier).state = true;

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRouter.routeForRole(targetRole));
  }



  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width >= 800;

    Widget formCard = ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          width: isWide ? 440 : double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Sanctuary Portal',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: ResortTheme.goldAccent,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Select your role to access the sanctuary portal.',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.6),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),

              // Role selection list
              Text(
                'CHOOSE ROLE PERSPECTIVE',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: ResortTheme.goldAccent.withValues(alpha: 0.6),
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 10),
              
              Container(
                constraints: const BoxConstraints(maxHeight: 280),
                child: ListView(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  children: UserRole.values.map((role) {
                    final isSelected = _selectedRole == role;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(bottom: 8.0),
                      decoration: BoxDecoration(
                        color: isSelected ? ResortTheme.goldAccent.withValues(alpha: 0.12) : Colors.white.withValues(alpha: 0.02),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? ResortTheme.goldAccent : Colors.white.withValues(alpha: 0.08),
                          width: isSelected ? 1.5 : 1.0,
                        ),
                        boxShadow: isSelected ? [
                          BoxShadow(
                            color: ResortTheme.goldAccent.withValues(alpha: 0.08),
                            blurRadius: 8,
                            spreadRadius: 1,
                          )
                        ] : null,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        clipBehavior: Clip.antiAlias,
                        child: ListTile(
                          dense: true,
                          leading: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: isSelected ? ResortTheme.goldGradient : null,
                              color: isSelected ? null : Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              _getRoleIcon(role),
                              size: 16,
                              color: isSelected ? const Color(0xFF2C3627) : ResortTheme.goldAccent.withValues(alpha: 0.7),
                            ),
                          ),
                          title: Text(
                            _getRoleLabel(role),
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              fontSize: 12.5,
                              color: isSelected ? ResortTheme.goldAccent : Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                          subtitle: Text(
                            _getRoleSubtitle(role),
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: isSelected ? Colors.white.withValues(alpha: 0.7) : Colors.white.withValues(alpha: 0.45),
                            ),
                          ),
                          onTap: () => _onRoleChanged(role),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 24),

              // Username & Password fields
              Text(
                'CREDENTIALS',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: ResortTheme.goldAccent.withValues(alpha: 0.6),
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _usernameController,
                readOnly: false,
                keyboardType: TextInputType.emailAddress,
                style: GoogleFonts.inter(fontSize: 12, color: Colors.white.withValues(alpha: 0.9)),
                decoration: InputDecoration(
                  hintText: 'Enter email address',
                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                  prefixIcon: const Icon(Icons.email_outlined, size: 16, color: ResortTheme.goldAccent),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.04),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: ResortTheme.goldAccent),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                obscureText: true,
                readOnly: false,
                style: GoogleFonts.inter(fontSize: 12, color: Colors.white.withValues(alpha: 0.9)),
                decoration: InputDecoration(
                  hintText: 'Enter password',
                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                  prefixIcon: const Icon(Icons.lock_outline, size: 16, color: ResortTheme.goldAccent),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.04),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: ResortTheme.goldAccent),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
              const SizedBox(height: 20),

              // Access button with Gold Gradient
              InkWell(
                onTap: _isLoading ? null : _handleLogin,
                borderRadius: BorderRadius.circular(16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: ResortTheme.goldGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: ResortTheme.goldAccent.withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Color(0xFF2C3627),
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          'Access Sanctuary Portal',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF2C3627),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            letterSpacing: 0.5,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: ResortTheme.darkEmeraldGradient,
        ),
        child: Stack(
          children: [
            // Ambient light glow backdrops
            Positioned(
              top: -100,
              left: -100,
              child: Container(
                width: 350,
                height: 350,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      ResortTheme.goldAccent.withValues(alpha: 0.08),
                      ResortTheme.goldAccent.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -150,
              right: -100,
              child: Container(
                width: 450,
                height: 450,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      ResortTheme.goldAccent.withValues(alpha: 0.05),
                      ResortTheme.goldAccent.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),

            // Main content
            Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Premium Logo Header
                    const VspNestBrandHeader(
                      isVertical: true,
                      logoSize: 72,
                      titleFontSize: 34,
                      subtitleFontSize: 26,
                      isDarkBackground: true,
                      useSingleLine: true,
                    ),
                    const SizedBox(height: 6),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'A U T H E N T I C   S A N C T U A R I E S',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.5,
                          color: ResortTheme.goldAccent,
                        ),
                      ),
                    ),
                    const SizedBox(height: 36),

                    formCard,

                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
