import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';

class AppStatsCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? iconColor;
  final String? subtitle;
  final Widget? trailing;

  const AppStatsCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.iconColor,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.lgBr,
        border: Border.all(color: AppColors.lightBone, width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (iconColor ?? AppColors.mossGreen).withValues(alpha: 0.1),
              borderRadius: AppRadius.mdBr,
            ),
            child: Icon(icon, color: iconColor ?? AppColors.mossGreen, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(value,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.mossGreen,
                    )),
                const SizedBox(height: 2),
                Text(label,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.charcoal.withValues(alpha: 0.6),
                    )),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: AppColors.charcoal.withValues(alpha: 0.4),
                      )),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
