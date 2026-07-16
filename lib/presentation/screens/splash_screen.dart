import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/api_client.dart';
import '../../core/theme.dart';
import '../../data/remote/auth_api_service.dart'
    show AuthApiService, AuthFailure, AuthSuccess, AuthResult, RemoteUserInfo;
import '../../domain/entities.dart';
import '../providers/state_provider.dart';
import '../routing/app_router.dart';
import '../routing/route_names.dart';
import '../widgets/vsp_nest_logo.dart';

class VspNestSplashScreen extends ConsumerStatefulWidget {
  const VspNestSplashScreen({super.key});

  @override
  ConsumerState<VspNestSplashScreen> createState() =>
      _VspNestSplashScreenState();
}

class _VspNestSplashScreenState extends ConsumerState<VspNestSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();

    Future.delayed(const Duration(milliseconds: 2500), _restoreSession);
  }

  Future<void> _restoreSession() async {
    if (!mounted) return;

    final token = await ApiClient.instance.accessToken;
    if (token == null || token.isEmpty) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, RouteNames.login);
      return;
    }

    if (_isTokenExpired(token)) {
      await ApiClient.instance.clearTokens();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, RouteNames.login);
      return;
    }

    try {
      final authResult = await AuthApiService().me();
      if (!mounted) return;

      if (authResult is AuthFailure) {
        await ApiClient.instance.clearTokens();
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, RouteNames.login);
        return;
      }

      if (authResult is AuthSuccess<RemoteUserInfo> &&
          !authResult.data.active) {
        await ApiClient.instance.clearTokens();
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, RouteNames.login);
        return;
      }

      final result = (authResult as AuthSuccess<RemoteUserInfo>).data;
      final targetRole = _mapBackendRole(result.role);
      if (targetRole == null) {
        await ApiClient.instance.clearTokens();
        Navigator.pushReplacementNamed(context, RouteNames.login);
        return;
      }

      ref.read(activeRoleProvider.notifier).state = targetRole;
      ref.read(authenticatedRoleProvider.notifier).state = targetRole;
      ref.read(isLoggedInProvider.notifier).state = true;

      if (targetRole == UserRole.customer) {
        ref.read(activeTabProvider.notifier).state = 'villa';
        ref.read(customerProfileProvider.notifier).setProfile({
          'name': result.name,
          'email': result.email,
          'phone': result.phone ?? '',
          'id': result.id,
          'avatar': result.profileImageUrl ?? '',
        });
      }

      Navigator.pushReplacementNamed(
          context, AppRouter.routeForRole(targetRole));
    } catch (_) {
      await ApiClient.instance.clearTokens();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, RouteNames.login);
    }
  }

  bool _isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;
      final payload =
          utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      final claims = json.decode(payload) as Map<String, dynamic>;
      final exp = claims['exp'] as int?;
      if (exp == null) return false;
      return DateTime.now().millisecondsSinceEpoch > exp * 1000;
    } catch (_) {
      return true;
    }
  }

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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppGradients.darkEmerald,
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
                      AppColors.goldAccent.withValues(alpha: 0.08),
                      AppColors.goldAccent.withValues(alpha: 0.0),
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
                      AppColors.goldAccent.withValues(alpha: 0.05),
                      AppColors.goldAccent.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),

            // Center Logo and Brand Title
            Center(
              child: FadeTransition(
                opacity: _fadeInAnimation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const VspNestBrandHeader(
                      isVertical: true,
                      logoSize: 90,
                      titleFontSize: 38,
                      subtitleFontSize: 28,
                      isDarkBackground: true,
                      useSingleLine: true,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'A U T H E N T I C   S A N C T U A R I E S',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4.0,
                        color: AppColors.goldAccent.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Premium loader at bottom
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _fadeInAnimation,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: AppColors.goldAccent,
                          strokeWidth: 2.0,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'L O A D I N G   E X P E R I E N C E',
                        style: GoogleFonts.inter(
                          fontSize: 8.5,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
