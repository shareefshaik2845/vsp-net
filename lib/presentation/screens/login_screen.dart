import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/state_provider.dart';
import '../routing/app_router.dart';
import '../routing/route_names.dart';
import '../../core/theme.dart';
import '../../core/rate_limiter.dart';
import '../../domain/entities.dart';
import '../widgets/vsp_nest_logo.dart';
import '../../core/api_client.dart';
import '../../core/snackbar_helper.dart';
import '../../data/remote/auth_api_service.dart' show AuthApiService, AuthFailure, AuthSuccess;

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
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _rateLimiter = RateLimiter();
  bool _isLoading = false;
  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
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

    if (!_rateLimiter.canAttempt) {
      final wait = _rateLimiter.retryAfter;
      if (wait.inSeconds > 0) {
        SnackbarHelper.warning(
          context,
          'Too many attempts. Please wait ${wait.inSeconds}s and try again.',
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    // Clear any stale tokens before login to avoid 403 from interceptor
    await ApiClient.instance.clearTokens();

    final authResult = await AuthApiService().login(email, password);

    if (!mounted) return;

    if (authResult is AuthFailure) {
      _rateLimiter.recordAttempt();
      setState(() => _isLoading = false);
      final failure = authResult as AuthFailure;
      SnackbarHelper.error(context, failure.message);
      return;
    }

    final result = (authResult as AuthSuccess).data;
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
                'Sign in to access the sanctuary portal.',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.6),
                  height: 1.4,
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
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, RouteNames.forgotPassword);
                      },
                      child: Text(
                        'Forgot Password?',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: ResortTheme.goldAccent.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, RouteNames.install);
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: ResortTheme.goldAccent.withValues(alpha: 0.4)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: Text(
                        'Request a Live Demo',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: ResortTheme.goldAccent.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
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
