import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../core/rate_limiter.dart';
import '../../domain/entities.dart';
import '../../core/api_client.dart';
import '../../core/snackbar_helper.dart';
import '../../data/remote/auth_api_service.dart' show AuthApiService, AuthFailure, AuthSuccess;
import '../providers/state_provider.dart';
import '../routing/app_router.dart';
import '../routing/route_names.dart';
import '../widgets/vsp_nest_logo.dart';
import '../components/app_button.dart';
import '../components/app_text_field.dart';

UserRole? _mapBackendRole(String backendRole) {
  switch (backendRole) {
    case 'SUPER_ADMIN': return UserRole.superAdmin;
    case 'ADMIN': return UserRole.admin;
    case 'STAFF': return UserRole.staff;
    case 'ACCOUNTANT': return UserRole.accountant;
    case 'CUSTOMER': return UserRole.customer;
    default: return null;
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

    if (email.isEmpty) { SnackbarHelper.warning(context, 'Please enter an email address.'); return; }
    if (password.isEmpty) { SnackbarHelper.warning(context, 'Please enter a password.'); return; }
    if (password.length < 6) { SnackbarHelper.warning(context, 'Password must be at least 6 characters.'); return; }

    if (!_rateLimiter.canAttempt) {
      final wait = _rateLimiter.retryAfter;
      if (wait.inSeconds > 0) {
        SnackbarHelper.warning(context, 'Too many attempts. Please wait ${wait.inSeconds}s and try again.');
      }
      return;
    }

    setState(() => _isLoading = true);
    await ApiClient.instance.clearTokens();
    final authResult = await AuthApiService().login(email, password);
    if (!mounted) return;

    if (authResult is AuthFailure) {
      _rateLimiter.recordAttempt();
      setState(() => _isLoading = false);
      SnackbarHelper.error(context, (authResult as AuthFailure).message);
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

    final formCard = ClipRRect(
      borderRadius: AppRadius.xxxlBr,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          width: isWide ? 440 : double.infinity,
          padding: const EdgeInsets.all(AppSpacing.xxxl),
          decoration: AppTheme.glass(borderRadius: AppRadius.xxxlBr, opacity: 0.06),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Sanctuary Portal', style: AppTextStyles.titleLg.copyWith(color: AppColors.goldAccent)),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Sign in to access the sanctuary portal.',
                style: AppTextStyles.bodyXs.copyWith(color: Colors.white.withValues(alpha: 0.6)),
              ),
              const SizedBox(height: AppSpacing.xxl),

              Text('CREDENTIALS', style: AppTextStyles.labelSm.copyWith(color: AppColors.goldAccent.withValues(alpha: 0.6))),
              const SizedBox(height: AppSpacing.sm),
              AppDarkTextField(
                controller: _usernameController,
                hintText: 'Enter email address',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppDarkTextField(
                controller: _passwordController,
                hintText: 'Enter password',
                prefixIcon: Icons.lock_outline,
                obscureText: true,
              ),
              const SizedBox(height: AppSpacing.xl),

              AppButton(
                label: 'Access Sanctuary Portal',
                onPressed: _isLoading ? null : _handleLogin,
                variant: AppButtonVariant.gold,
                loading: _isLoading,
              ),
              const SizedBox(height: AppSpacing.lg),

              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pushNamed(context, RouteNames.forgotPassword),
                      child: Text('Forgot Password?',
                          style: AppTextStyles.bodyXs.copyWith(color: AppColors.goldAccent.withValues(alpha: 0.8))),
                    ),
                  ),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pushNamed(context, RouteNames.install),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.goldAccent.withValues(alpha: 0.4)),
                        shape: RoundedRectangleBorder(borderRadius: AppRadius.lgBr),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: Text('Request a Live Demo',
                          style: AppTextStyles.bodyXs.copyWith(color: AppColors.goldAccent.withValues(alpha: 0.8))),
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
        decoration: const BoxDecoration(gradient: AppGradients.darkEmerald),
        child: Stack(
          children: [
            Positioned(
              top: -100, left: -100,
              child: Container(
                width: 350, height: 350,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [AppColors.goldAccent.withValues(alpha: 0.08), AppColors.goldAccent.withValues(alpha: 0.0)]),
                ),
              ),
            ),
            Positioned(
              bottom: -150, right: -100,
              child: Container(
                width: 450, height: 450,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [AppColors.goldAccent.withValues(alpha: 0.05), AppColors.goldAccent.withValues(alpha: 0.0)]),
                ),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const VspNestBrandHeader(
                      isVertical: true, logoSize: 72, titleFontSize: 34, subtitleFontSize: 26,
                      isDarkBackground: true, useSingleLine: true,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'A U T H E N T I C   S A N C T U A R I E S',
                        style: AppTextStyles.labelSm.copyWith(fontSize: 9.5, color: AppColors.goldAccent, letterSpacing: 2.5),
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
