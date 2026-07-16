import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';

class AppDialog {
  static Future<bool?> confirm({
    required BuildContext context,
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    IconData? icon,
    Color? confirmColor,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lgBr),
        title: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: AppColors.goldAccent, size: 22),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(title, style: AppTextStyles.titleSm),
            ),
          ],
        ),
        content: Text(message, style: AppTextStyles.bodyMd),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(cancelLabel,
                style: GoogleFonts.inter(color: AppColors.grey600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor ?? AppColors.mossGreen,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(borderRadius: AppRadius.mdBr),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(confirmLabel,
                style: GoogleFonts.inter(
                    color: AppColors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  static Future<T?> bottomSheet<T>({
    required BuildContext context,
    required String title,
    required List<Widget> children,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppRadius.xxl),
          topRight: Radius.circular(AppRadius.xxl),
        ),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Text(title, style: AppTextStyles.titleLg),
              ),
              const Divider(color: AppColors.lightBone),
              ...children,
            ],
          ),
        ),
      ),
    );
  }

  static Future<void> info({
    required BuildContext context,
    required String title,
    required String message,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lgBr),
        title: Text(title, style: AppTextStyles.titleSm),
        content: Text(message, style: AppTextStyles.bodyMd),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('OK',
                style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
