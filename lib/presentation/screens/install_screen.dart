import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../routing/route_names.dart';
import '../../core/snackbar_helper.dart';
import '../../core/theme.dart';
import '../widgets/vsp_nest_logo.dart';
import '../../data/remote/auth_api_service.dart' show AuthApiService, AuthFailure;

class InstallationScreen extends ConsumerStatefulWidget {
  const InstallationScreen({super.key});

  @override
  ConsumerState<InstallationScreen> createState() => _InstallationScreenState();
}

class _InstallationScreenState extends ConsumerState<InstallationScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  String? _validate() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (name.isEmpty) return 'Please enter your name.';
    if (name.length < 2) return 'Name must be at least 2 characters.';
    if (email.isEmpty) return 'Please enter an email address.';
    if (!email.contains('@') || !email.contains('.')) return 'Enter a valid email address.';
    if (password.isEmpty) return 'Please enter a password.';
    if (password.length < 6) return 'Password must be at least 6 characters.';
    if (password != confirm) return 'Passwords do not match.';
    return null;
  }

  void _handleSetup() async {
    final error = _validate();
    if (error != null) {
      SnackbarHelper.warning(context, error);
      return;
    }

    setState(() => _isLoading = true);

    final authResult = await AuthApiService().setup(
      name: _nameController.text.trim(),
      email: _emailController.text.trim().toLowerCase(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (authResult is AuthFailure) {
      setState(() => _isLoading = false);
      final failure = authResult as AuthFailure;
      SnackbarHelper.error(context, failure.message);
      return;
    }

    SnackbarHelper.success(context, 'Super Admin created! Please log in.');

    setState(() => _isLoading = false);

    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, RouteNames.login);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width >= 800;

    final formCard = ClipRRect(
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
                'Initialize Sanctuary',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.goldAccent,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Create the first Super Admin account to get started.',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.6),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),

              Text(
                'SUPER ADMIN CREDENTIALS',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: AppColors.goldAccent.withValues(alpha: 0.6),
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 12),

              _buildField('Full Name', 'Enter your full name', _nameController, Icons.person_outline, false),
              const SizedBox(height: 12),
              _buildField('Email Address', 'Enter email address', _emailController, Icons.email_outlined, false),
              const SizedBox(height: 12),
              _buildField('Password', 'Create a password', _passwordController, Icons.lock_outline, true),
              const SizedBox(height: 12),
              _buildField('Confirm Password', 'Confirm your password', _confirmController, Icons.lock_outline, true),

              const SizedBox(height: 28),

              InkWell(
                onTap: _isLoading ? null : _handleSetup,
                borderRadius: BorderRadius.circular(16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: AppGradients.gold,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.goldAccent.withValues(alpha: 0.3),
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
                          'Create Super Admin',
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
          gradient: AppGradients.darkEmerald,
        ),
        child: Stack(
          children: [
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
            Positioned(
              top: 48,
              left: 16,
              child: SafeArea(
                child: IconButton(
                  icon: Icon(Icons.arrow_back_ios_new, color: AppColors.goldAccent.withValues(alpha: 0.8), size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
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
                        'S E T U P   W I Z A R D',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.5,
                          color: AppColors.goldAccent,
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

  Widget _buildField(String label, String hint, TextEditingController controller, IconData icon, bool obscure) {
    return TextField(
      controller: controller,
      obscureText: obscure && (icon == Icons.lock_outline && controller == _passwordController ? _obscurePassword : _obscureConfirm),
      keyboardType: label == 'Email Address' ? TextInputType.emailAddress : TextInputType.text,
      style: GoogleFonts.inter(fontSize: 12, color: Colors.white.withValues(alpha: 0.9)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
        prefixIcon: Icon(icon, size: 16, color: AppColors.goldAccent),
        suffixIcon: obscure
            ? IconButton(
                icon: Icon(
                  (controller == _passwordController ? _obscurePassword : _obscureConfirm)
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 16,
                  color: Colors.white.withValues(alpha: 0.4),
                ),
                onPressed: () {
                  setState(() {
                    if (controller == _passwordController) {
                      _obscurePassword = !_obscurePassword;
                    } else {
                      _obscureConfirm = !_obscureConfirm;
                    }
                  });
                },
              )
            : null,
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
          borderSide: const BorderSide(color: AppColors.goldAccent),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
    );
  }
}
