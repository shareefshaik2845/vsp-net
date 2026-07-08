import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../routing/route_names.dart';
import '../widgets/vsp_nest_logo.dart';

class VspNestSplashScreen extends ConsumerStatefulWidget {
  const VspNestSplashScreen({super.key});

  @override
  ConsumerState<VspNestSplashScreen> createState() => _VspNestSplashScreenState();
}

class _VspNestSplashScreenState extends ConsumerState<VspNestSplashScreen> with SingleTickerProviderStateMixin {
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

    // Automatically transition after 2.5 seconds
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, RouteNames.login);
    });
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
                        color: ResortTheme.goldAccent.withValues(alpha: 0.8),
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
                          color: ResortTheme.goldAccent,
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
