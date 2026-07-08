import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';

class VspNestLogo extends StatelessWidget {
  final double size;
  final bool isDarkBackground;

  const VspNestLogo({
    super.key,
    this.size = 44,
    this.isDarkBackground = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isDarkBackground 
              ? ResortTheme.goldAccent.withValues(alpha: 0.4)
              : ResortTheme.mossGreen.withValues(alpha: 0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDarkBackground ? ResortTheme.goldAccent : ResortTheme.mossGreen).withValues(alpha: 0.08),
            blurRadius: size * 0.15,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Container(
        margin: EdgeInsets.all(size * 0.06),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: ResortTheme.goldGradient,
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.spa_outlined, // Elegant leaf/nest spa shape
          size: size * 0.52,
          color: const Color(0xFF2C3627),
        ),
      ),
    );
  }
}

class VspNestBrandHeader extends StatelessWidget {
  final bool isVertical;
  final double logoSize;
  final double titleFontSize;
  final double subtitleFontSize;
  final bool isDarkBackground;
  final bool useSingleLine;

  const VspNestBrandHeader({
    super.key,
    this.isVertical = false,
    this.logoSize = 44,
    this.titleFontSize = 19,
    this.subtitleFontSize = 14,
    this.isDarkBackground = false,
    this.useSingleLine = false,
  });

  @override
  Widget build(BuildContext context) {
    final logo = VspNestLogo(
      size: logoSize,
      isDarkBackground: isDarkBackground,
    );

    final Widget textWidget;
    if (useSingleLine) {
      textWidget = Text.rich(
        TextSpan(
          style: GoogleFonts.playfairDisplay(
            fontSize: titleFontSize,
            fontWeight: FontWeight.bold,
          ),
          children: [
            TextSpan(
              text: 'VSP ',
              style: TextStyle(
                color: isDarkBackground ? Colors.white : const Color(0xFF4A4A35),
              ),
            ),
            const TextSpan(
              text: 'Nest',
              style: TextStyle(
                color: ResortTheme.goldAccent,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        textAlign: isVertical ? TextAlign.center : TextAlign.start,
      );
    } else {
      textWidget = Column(
        crossAxisAlignment: isVertical ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'VSP',
            style: GoogleFonts.playfairDisplay(
              color: isDarkBackground ? Colors.white : const Color(0xFF4A4A35),
              fontSize: titleFontSize,
              fontWeight: FontWeight.bold,
              height: 1.1,
            ),
          ),
          Text(
            'Nest',
            style: GoogleFonts.playfairDisplay(
              color: ResortTheme.goldAccent,
              fontSize: subtitleFontSize,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      );
    }

    if (isVertical) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          logo,
          SizedBox(height: logoSize * 0.25),
          textWidget,
        ],
      );
    } else {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          logo,
          const SizedBox(width: 12),
          textWidget,
        ],
      );
    }
  }
}
