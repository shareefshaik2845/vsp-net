import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ResortTheme {
  // Brand color scheme matching the web styled portal
  static const Color mossGreen = Color(0xFF2C3627);
  static const Color goldAccent = Color(0xFFD4B483);
  static const Color stoneBg = Color(0xFFF4F1EA);
  static const Color charcoal = Color(0xFF1C1E1D);
  static const Color softCream = Color(0xFFFAF9F6);
  static const Color lightBone = Color(0xFFE6E2D3);

  // Premium luxury visual tokens
  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFE5CFA3),
      Color(0xFFC5A880),
      Color(0xFFD4B483),
      Color(0xFFA3865D),
    ],
  );

  static const LinearGradient darkEmeraldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0C120A),
      Color(0xFF182015),
      Color(0xFF0E130D),
    ],
  );

  static final List<BoxShadow> premiumShadows = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 24,
      offset: const Offset(0, 12),
    ),
  ];

  static BoxDecoration glassDecoration({required BorderRadius borderRadius}) {
    return BoxDecoration(
      color: Colors.white.withValues(alpha: 0.08),
      borderRadius: borderRadius,
      border: Border.all(color: Colors.white.withValues(alpha: 0.12), width: 1.0),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: stoneBg,
      primaryColor: mossGreen,
      colorScheme: ColorScheme.fromSeed(
        seedColor: mossGreen,
        primary: mossGreen,
        secondary: goldAccent,
        background: stoneBg,
        surface: Colors.white,
        onPrimary: softCream,
        onSecondary: charcoal,
        error: const Color(0xFFC62828),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.0),
          side: const BorderSide(color: lightBone, width: 1.0),
        ),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.playfairDisplay(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: mossGreen,
        ),
        displayMedium: GoogleFonts.playfairDisplay(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: mossGreen,
        ),
        titleLarge: GoogleFonts.playfairDisplay(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: mossGreen,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: charcoal,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.normal,
          color: charcoal.withValues(alpha: 0.8),
        ),
        labelSmall: GoogleFonts.spaceGrotesk(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: charcoal.withValues(alpha: 0.5),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: mossGreen),
        titleTextStyle: GoogleFonts.playfairDisplay(
          color: mossGreen,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        shape: const BorderShape(),
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: stoneBg.withValues(alpha: 0.3),
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: lightBone, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: lightBone, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: mossGreen, width: 1.5),
        ),
        labelStyle: GoogleFonts.inter(fontSize: 12, color: charcoal.withValues(alpha: 0.6)),
        hintStyle: GoogleFonts.inter(fontSize: 12, color: charcoal.withValues(alpha: 0.4)),
      ),
      buttonTheme: const ButtonThemeData(
        buttonColor: mossGreen,
      ),
    );
  }
}

class BorderShape extends OutlinedBorder {
  const BorderShape();
  @override
  OutlinedBorder copyWith({BorderSide? side}) => this;
  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => Path();
  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return Path()..addRect(rect);
  }
  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final paint = Paint()
      ..color = ResortTheme.lightBone
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(rect.left, rect.bottom),
      Offset(rect.right, rect.bottom),
      paint,
    );
  }
  @override
  OutlinedBorder scale(double t) => this;
  
  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;
}
