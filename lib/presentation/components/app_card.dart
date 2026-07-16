import 'package:flutter/material.dart';
import '../../core/theme.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final BorderRadiusGeometry? borderRadius;
  final List<BoxShadow>? shadows;
  final BorderSide? borderSide;
  final Gradient? gradient;
  final VoidCallback? onTap;
  final double? height;
  final double? width;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.borderRadius,
    this.shadows,
    this.borderSide,
    this.gradient,
    this.onTap,
    this.height,
    this.width,
  });

  factory AppCard.outlined({
    required Widget child,
    EdgeInsetsGeometry? padding,
    VoidCallback? onTap,
  }) {
    return AppCard(
      padding: padding,
      color: AppColors.white,
      borderRadius: AppRadius.xxlBr,
      borderSide: const BorderSide(color: AppColors.lightBone, width: 1),
      onTap: onTap,
      child: child,
    );
  }

  factory AppCard.gold({
    required Widget child,
    EdgeInsetsGeometry? padding,
    VoidCallback? onTap,
  }) {
    return AppCard(
      padding: padding,
      gradient: AppGradients.gold,
      borderRadius: AppRadius.lgBr,
      onTap: onTap,
      child: child,
    );
  }

  factory AppCard.glass({required Widget child, EdgeInsetsGeometry? padding}) {
    return AppCard(
      padding: padding,
      color: AppColors.white.withValues(alpha: 0.06),
      borderRadius: AppRadius.lgBr,
      borderSide: BorderSide(color: AppColors.white.withValues(alpha: 0.12)),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final card = Container(
      height: height,
      width: width,
      padding: padding ?? AppSpacing.allLg,
      decoration: BoxDecoration(
        color: gradient == null ? (color ?? AppColors.white) : null,
        gradient: gradient,
        borderRadius: borderRadius ?? AppRadius.xxlBr,
        border: borderSide != null
            ? Border.all(color: borderSide!.color, width: borderSide!.width)
            : null,
        boxShadow: shadows ?? (gradient == null ? AppShadows.card : null),
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        borderRadius: borderRadius ?? AppRadius.xxlBr,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: card,
        ),
      );
    }
    return card;
  }
}
