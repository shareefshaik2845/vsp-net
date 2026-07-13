import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final IconData? prefixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool readOnly;
  final Widget? suffix;

  const AppTextField({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.prefixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.readOnly = false,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (isDark) {
      return TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        readOnly: readOnly,
        style: GoogleFonts.inter(fontSize: 13, color: Colors.white.withValues(alpha: 0.9)),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.white38),
          labelText: labelText,
          labelStyle: const TextStyle(color: Colors.white60),
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, size: 18, color: AppColors.goldAccent)
              : null,
          suffixIcon: suffix,
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.04),
          border: OutlineInputBorder(
            borderRadius: AppRadius.lgBr,
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.lgBr,
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppRadius.lgBr,
            borderSide: const BorderSide(color: AppColors.goldAccent),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: AppRadius.lgBr,
            borderSide: const BorderSide(color: AppColors.error),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      );
    }

    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      readOnly: readOnly,
      style: GoogleFonts.inter(fontSize: 13, color: AppColors.charcoal),
      decoration: InputDecoration(
        hintText: hintText,
        labelText: labelText,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, size: 18, color: AppColors.mossGreen)
            : null,
        suffixIcon: suffix,
        filled: true,
        fillColor: AppColors.stoneBg.withValues(alpha: 0.3),
        border: OutlineInputBorder(
          borderRadius: AppRadius.lgBr,
          borderSide: const BorderSide(color: AppColors.lightBone),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.lgBr,
          borderSide: const BorderSide(color: AppColors.lightBone),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.lgBr,
          borderSide: const BorderSide(color: AppColors.mossGreen, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.lgBr,
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}

class AppDarkTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final IconData? prefixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final VoidCallback? onTap;

  const AppDarkTextField({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.prefixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      readOnly: onTap != null,
      onTap: onTap,
      style: GoogleFonts.inter(fontSize: 12, color: Colors.white.withValues(alpha: 0.9)),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, size: 16, color: AppColors.goldAccent)
            : null,
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.04),
        border: OutlineInputBorder(
          borderRadius: AppRadius.lgBr,
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.lgBr,
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.lgBr,
          borderSide: const BorderSide(color: AppColors.goldAccent),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
    );
  }
}
