import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  AppColors._();

  // Brand
  static const mossGreen = Color(0xFF2C3627);
  static const mossGreenLight = Color(0xFF4A5A3F);
  static const goldAccent = Color(0xFFD4B483);
  static const goldLight = Color(0xFFE5CFA3);
  static const goldDark = Color(0xFFA3865D);
  static const stoneBg = Color(0xFFF4F1EA);
  static const charcoal = Color(0xFF1C1E1D);
  static const softCream = Color(0xFFFAF9F6);
  static const lightBone = Color(0xFFE6E2D3);

  // Functional
  static const error = Color(0xFFC62828);
  static const errorLight = Color(0xFFFFCDD2);
  static const success = Color(0xFF2E7D32);
  static const successLight = Color(0xFFC8E6C9);
  static const warning = Color(0xFFF9A825);
  static const warningLight = Color(0xFFFFF9C4);
  static const whatsapp = Color(0xFF25D366);

  // Neutral
  static const white = Colors.white;
  static const black = Colors.black;
  static const grey100 = Color(0xFFF5F5F5);
  static const grey200 = Color(0xFFEEEEEE);
  static const grey300 = Color(0xFFE0E0E0);
  static const grey400 = Color(0xFFBDBDBD);
  static const grey500 = Color(0xFF9E9E9E);
  static const grey600 = Color(0xFF757575);
  static const grey700 = Color(0xFF616161);
  static const grey800 = Color(0xFF424242);
}

class AppSpacing {
  AppSpacing._();
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 40;

  // Edge insets
  static const EdgeInsets pageH = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets pageHV =
      EdgeInsets.symmetric(horizontal: lg, vertical: md);
  static const EdgeInsets allLg = EdgeInsets.all(lg);
  static const EdgeInsets allMd = EdgeInsets.all(md);
}

class AppRadius {
  AppRadius._();
  static const double xs = 6;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double full = 100;

  static BorderRadius get xsBr => BorderRadius.circular(xs);
  static BorderRadius get smBr => BorderRadius.circular(sm);
  static BorderRadius get mdBr => BorderRadius.circular(md);
  static BorderRadius get lgBr => BorderRadius.circular(lg);
  static BorderRadius get xlBr => BorderRadius.circular(xl);
  static BorderRadius get xxlBr => BorderRadius.circular(xxl);
  static BorderRadius get xxxlBr => BorderRadius.circular(xxxl);
}

class AppShadows {
  AppShadows._();
  static const List<BoxShadow> card = [
    BoxShadow(color: Color(0x14000000), blurRadius: 24, offset: Offset(0, 12)),
  ];
  static const List<BoxShadow> cardSm = [
    BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2)),
  ];
  static const List<BoxShadow> button = [
    BoxShadow(color: Color(0x1A000000), blurRadius: 6, offset: Offset(0, 2)),
  ];
  static List<BoxShadow> glowGold = [
    BoxShadow(
        color: AppColors.goldAccent.withValues(alpha: 0.15),
        blurRadius: 6,
        offset: Offset(0, 2)),
  ];
  static List<BoxShadow> glowGoldHover = [
    BoxShadow(
        color: AppColors.goldAccent.withValues(alpha: 0.3),
        blurRadius: 16,
        offset: Offset(0, 4)),
  ];
}

class AppGradients {
  AppGradients._();
  static const LinearGradient gold = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.goldLight,
      AppColors.goldAccent,
      AppColors.goldAccent,
      AppColors.goldDark
    ],
  );
  static const LinearGradient darkEmerald = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0C120A), Color(0xFF182015), Color(0xFF0E130D)],
  );
  static const LinearGradient mossGreen = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A2116), Color(0xFF2C3627)],
  );
}

class AppTextStyles {
  AppTextStyles._();

  // Display / Headings — Playfair Display
  static TextStyle displayLarge = GoogleFonts.playfairDisplay(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.mossGreen,
  );
  static TextStyle displayMedium = GoogleFonts.playfairDisplay(
    fontSize: 26,
    fontWeight: FontWeight.bold,
    color: AppColors.mossGreen,
  );
  static TextStyle titleXl = GoogleFonts.playfairDisplay(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.mossGreen,
  );
  static TextStyle titleLg = GoogleFonts.playfairDisplay(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.mossGreen,
  );
  static TextStyle titleMd = GoogleFonts.playfairDisplay(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.mossGreen,
  );
  static TextStyle titleSm = GoogleFonts.playfairDisplay(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.mossGreen,
  );

  // Body — Inter
  static TextStyle bodyLg = GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.charcoal,
  );
  static TextStyle bodyMd = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.normal,
    color: AppColors.charcoal.withValues(alpha: 0.8),
  );
  static TextStyle bodySm = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.charcoal.withValues(alpha: 0.7),
  );
  static TextStyle bodyXs = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.normal,
    color: AppColors.charcoal.withValues(alpha: 0.6),
  );

  // Label / Caption — Space Grotesk
  static TextStyle labelLg = GoogleFonts.spaceGrotesk(
    fontSize: 13,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.2,
    color: AppColors.charcoal.withValues(alpha: 0.5),
  );
  static TextStyle labelMd = GoogleFonts.spaceGrotesk(
    fontSize: 11,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.2,
    color: AppColors.charcoal.withValues(alpha: 0.5),
  );
  static TextStyle labelSm = GoogleFonts.spaceGrotesk(
    fontSize: 9,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.2,
    color: AppColors.charcoal.withValues(alpha: 0.5),
  );

  // Helper to create colored variants
  static TextStyle of(TextStyle base, {Color? color}) =>
      base.copyWith(color: color);
}

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.stoneBg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.mossGreen,
        primary: AppColors.mossGreen,
        secondary: AppColors.goldAccent,
        surface: AppColors.white,
        error: AppColors.error,
      ),
      fontFamily: GoogleFonts.inter().fontFamily,

      // Card
      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.xxlBr,
          side: const BorderSide(color: AppColors.lightBone, width: 1),
        ),
      ),

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: AppColors.mossGreen),
        titleTextStyle: AppTextStyles.titleMd,
        shape: const _BottomBorderShape(),
      ),

      // Bottom Navigation
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.mossGreen,
        unselectedItemColor: AppColors.grey400,
      ),

      // Input Fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.stoneBg.withValues(alpha: 0.3),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: AppRadius.lgBr,
          borderSide: const BorderSide(color: AppColors.lightBone, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.lgBr,
          borderSide: const BorderSide(color: AppColors.lightBone, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.lgBr,
          borderSide: const BorderSide(color: AppColors.mossGreen, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.lgBr,
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.lgBr,
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        labelStyle: AppTextStyles.bodySm,
        hintStyle: GoogleFonts.inter(
            fontSize: 12, color: AppColors.charcoal.withValues(alpha: 0.4)),
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.mossGreen,
          foregroundColor: AppColors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.lgBr),
          textStyle:
              GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ),

      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.mossGreen,
          side: const BorderSide(color: AppColors.lightBone),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.lgBr),
          textStyle:
              GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.mossGreen,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          textStyle:
              GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),

      // Floating Action Button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.whatsapp,
        foregroundColor: AppColors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lgBr),
        titleTextStyle: AppTextStyles.titleSm,
        contentTextStyle: AppTextStyles.bodyMd,
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.stoneBg,
        selectedColor: AppColors.mossGreen,
        labelStyle:
            GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
        secondaryLabelStyle:
            GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.smBr),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: AppColors.lightBone,
        thickness: 1,
        space: 1,
      ),

      // Progress Indicator
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.mossGreen,
        circularTrackColor: AppColors.lightBone,
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.mdBr),
      ),
    );
  }

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF121413),
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.mossGreen,
        brightness: Brightness.dark,
        primary: AppColors.mossGreenLight,
        secondary: AppColors.goldAccent,
        surface: const Color(0xFF1E201E),
        error: AppColors.error,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1E201E),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.xxlBr,
          side: const BorderSide(color: Color(0xFF2E302E), width: 1),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF1E201E),
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: AppColors.goldAccent),
        titleTextStyle:
            AppTextStyles.titleMd.copyWith(color: AppColors.goldAccent),
        shape: const _BottomBorderShape(),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.04),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: AppRadius.lgBr,
          borderSide:
              BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.lgBr,
          borderSide:
              BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.lgBr,
          borderSide: const BorderSide(color: AppColors.goldAccent, width: 1.5),
        ),
        labelStyle: GoogleFonts.inter(
            fontSize: 12, color: Colors.white.withValues(alpha: 0.6)),
        hintStyle: GoogleFonts.inter(
            fontSize: 12, color: Colors.white.withValues(alpha: 0.3)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.goldAccent,
          foregroundColor: AppColors.charcoal,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.lgBr),
          textStyle:
              GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.goldAccent,
          side: BorderSide(color: AppColors.goldAccent.withValues(alpha: 0.4)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.lgBr),
          textStyle:
              GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.goldAccent,
        circularTrackColor: Color(0xFF2E302E),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF2E302E),
        thickness: 1,
        space: 1,
      ),
    );
  }

  // Glassmorphism helper
  static BoxDecoration glass({
    required BorderRadius borderRadius,
    Color tint = AppColors.white,
    double opacity = 0.06,
    Color borderTint = AppColors.white,
    double borderOpacity = 0.12,
  }) {
    return BoxDecoration(
      color: tint.withValues(alpha: opacity),
      borderRadius: borderRadius,
      border: Border.all(
          color: borderTint.withValues(alpha: borderOpacity), width: 1),
    );
  }

  // Bottom border shape used in AppBar
  static const bottomBorderShape = _BottomBorderShape();
}

class _BottomBorderShape extends OutlinedBorder {
  const _BottomBorderShape();
  @override
  OutlinedBorder copyWith({BorderSide? side}) => this;
  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;
  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => Path();
  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) =>
      Path()..addRect(rect);
  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final paint = Paint()
      ..color = AppColors.lightBone
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
        Offset(rect.left, rect.bottom), Offset(rect.right, rect.bottom), paint);
  }

  @override
  OutlinedBorder scale(double t) => this;
}
