import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';

enum AppBadgeVariant { success, warning, error, info, neutral }

class AppBadge extends StatelessWidget {
  final String label;
  final AppBadgeVariant variant;

  const AppBadge({super.key, required this.label, this.variant = AppBadgeVariant.neutral});

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color textColor) = switch (variant) {
      AppBadgeVariant.success => (AppColors.successLight, AppColors.success),
      AppBadgeVariant.warning => (AppColors.warningLight, AppColors.warning),
      AppBadgeVariant.error => (AppColors.errorLight, AppColors.error),
      AppBadgeVariant.info => (AppColors.goldAccent.withValues(alpha: 0.15), AppColors.goldDark),
      AppBadgeVariant.neutral => (AppColors.stoneBg, AppColors.charcoal),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.smBr,
      ),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.spaceGrotesk(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
          color: textColor,
        ),
      ),
    );
  }
}
