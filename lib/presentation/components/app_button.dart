import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';

enum AppButtonVariant { primary, gold, outline, text }

enum AppButtonSize { sm, md, lg }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? icon;
  final bool fullWidth;
  final bool loading;
  final Color? color;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.md,
    this.icon,
    this.fullWidth = true,
    this.loading = false,
    this.color,
  });

  bool get _isEnabled => onPressed != null && !loading;

  @override
  Widget build(BuildContext context) {
    switch (variant) {
      case AppButtonVariant.gold:
        return _buildGoldButton();
      case AppButtonVariant.outline:
        return _buildOutlineButton();
      case AppButtonVariant.text:
        return _buildTextButton();
      default:
        return _buildPrimaryButton();
    }
  }

  Widget _wrap(Widget child) {
    final button = child;
    if (!fullWidth) return button;
    return SizedBox(width: double.infinity, child: button);
  }

  (EdgeInsetsGeometry, double) get _dimensions {
    switch (size) {
      case AppButtonSize.sm:
        return (const EdgeInsets.symmetric(horizontal: 16, vertical: 8), 12);
      case AppButtonSize.lg:
        return (const EdgeInsets.symmetric(horizontal: 32, vertical: 18), 14);
      default:
        return (const EdgeInsets.symmetric(horizontal: 24, vertical: 14), 13);
    }
  }

  Widget _buildPrimaryButton() {
    final (pad, fontSize) = _dimensions;
    final bgColor = color ?? AppColors.mossGreen;

    return _wrap(
      ElevatedButton(
        onPressed: _isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: loading ? bgColor.withValues(alpha: 0.7) : bgColor,
          foregroundColor: AppColors.white,
          padding: pad,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.lgBr),
          textStyle: GoogleFonts.inter(fontSize: fontSize, fontWeight: FontWeight.bold),
        ),
        child: loading
            ? SizedBox(
                width: fontSize + 6,
                height: fontSize + 6,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.white.withValues(alpha: 0.9),
                ),
              )
            : _buildLabel(fontSize),
      ),
    );
  }

  Widget _buildGoldButton() {
    final (pad, fontSize) = _dimensions;

    return _wrap(
      InkWell(
        onTap: _isEnabled ? onPressed : null,
        borderRadius: AppRadius.lgBr,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: pad,
          decoration: BoxDecoration(
            gradient: AppGradients.gold,
            borderRadius: AppRadius.lgBr,
            boxShadow: _isEnabled ? AppShadows.glowGoldHover : null,
          ),
          alignment: Alignment.center,
          child: loading
              ? SizedBox(
                  width: fontSize + 6,
                  height: fontSize + 6,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.mossGreen,
                  ),
                )
              : _buildLabel(fontSize, color: AppColors.mossGreen),
        ),
      ),
    );
  }

  Widget _buildOutlineButton() {
    final (pad, fontSize) = _dimensions;

    return _wrap(
      OutlinedButton(
        onPressed: _isEnabled ? onPressed : null,
        style: OutlinedButton.styleFrom(
          foregroundColor: color ?? AppColors.mossGreen,
          side: BorderSide(color: color ?? AppColors.lightBone),
          padding: pad,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.lgBr),
          textStyle: GoogleFonts.inter(fontSize: fontSize, fontWeight: FontWeight.w600),
        ),
        child: loading
            ? SizedBox(
                width: fontSize + 6,
                height: fontSize + 6,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: (color ?? AppColors.mossGreen).withValues(alpha: 0.7),
                ),
              )
            : _buildLabel(fontSize),
      ),
    );
  }

  Widget _buildTextButton() {
    final fontSize = switch (size) { AppButtonSize.sm => 11.0, AppButtonSize.lg => 14.0, _ => 12.0 };

    return _wrap(
      TextButton(
        onPressed: _isEnabled ? onPressed : null,
        style: TextButton.styleFrom(
          foregroundColor: color ?? AppColors.mossGreen,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          textStyle: GoogleFonts.inter(fontSize: fontSize, fontWeight: FontWeight.w600),
        ),
        child: _buildLabel(fontSize),
      ),
    );
  }

  Widget _buildLabel(double fontSize, {Color? color}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: fontSize + 4, color: color),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
