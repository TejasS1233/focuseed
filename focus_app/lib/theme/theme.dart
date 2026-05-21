import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  AppColors._();

  static const Color deepBg = Color(0xFF08080F);
  static const Color surface = Color(0xFF0D0D1A);
  static const Color surfaceElevated = Color(0xFF151528);
  static const Color surfaceHighlight = Color(0xFF1F1F3A);

  static const Color primary = Color(0xFF00FF88);
  static const Color primaryDark = Color(0xFF00CC6A);
  static const Color primaryGlow = Color(0x3300FF88);

  static const Color secondary = Color(0xFFFFB347);
  static const Color tertiary = Color(0xFF7C3AED);
  static const Color error = Color(0xFFFF4D6D);

  static const Color textPrimary = Color(0xFFE5E7EB);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textMuted = Color(0xFF6B7280);

  static const Color border = Color(0xFF2A2A45);
  static const Color borderFocused = Color(0xFF00FF88);

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  static const Color success = Color(0xFF00FF88);
  static const Color warning = Color(0xFFFFB347);
  static const Color destructive = Color(0xFFFF4D6D);
}

class AppTypography {
  AppTypography._();

  static String get bodyFont => 'PlusJakartaSans';

  static TextStyle get display1 => GoogleFonts.playfairDisplay(
    fontSize: 34, fontWeight: FontWeight.w700, height: 1.2, letterSpacing: -0.5,
  );

  static TextStyle get display2 => GoogleFonts.playfairDisplay(
    fontSize: 28, fontWeight: FontWeight.w600, height: 1.25,
  );

  static TextStyle get heading1 => GoogleFonts.plusJakartaSans(
    fontSize: 22, fontWeight: FontWeight.w700, height: 1.3,
  );

  static TextStyle get heading2 => GoogleFonts.plusJakartaSans(
    fontSize: 18, fontWeight: FontWeight.w600, height: 1.4,
  );

  static TextStyle get heading3 => GoogleFonts.plusJakartaSans(
    fontSize: 15, fontWeight: FontWeight.w600, height: 1.4, letterSpacing: 0.3,
  );

  static TextStyle get body => GoogleFonts.plusJakartaSans(
    fontSize: 15, fontWeight: FontWeight.w400, height: 1.6,
  );

  static TextStyle get bodySmall => GoogleFonts.plusJakartaSans(
    fontSize: 13, fontWeight: FontWeight.w400, height: 1.5,
  );

  static TextStyle get caption => GoogleFonts.plusJakartaSans(
    fontSize: 11, fontWeight: FontWeight.w500, height: 1.3, letterSpacing: 0.5,
  );

  static TextStyle get label => GoogleFonts.plusJakartaSans(
    fontSize: 12, fontWeight: FontWeight.w600, height: 1.2, letterSpacing: 0.8,
  );

  static TextStyle get timer => GoogleFonts.plusJakartaSans(
    fontSize: 64, fontWeight: FontWeight.w200, height: 1.0, letterSpacing: -2,
  );
}

class AppRadius {
  AppRadius._();
  static const double sm = 6;
  static const double md = 10;
  static const double lg = 16;
  static const double xl = 24;
  static const double full = 9999;
}

class AppSpacing {
  AppSpacing._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double xxxl = 64;
}

class AppShadows {
  AppShadows._();
  static List<BoxShadow> glow(Color color, {double intensity = 0.5}) => [
    BoxShadow(
      color: color.withOpacity(intensity * 0.3),
      blurRadius: 12,
      spreadRadius: -2,
    ),
    BoxShadow(
      color: color.withOpacity(intensity * 0.15),
      blurRadius: 24,
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> card = [
    BoxShadow(
      color: Colors.black.withOpacity(0.4),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: AppColors.primaryGlow,
      blurRadius: 1,
      offset: const Offset(0, 0),
    ),
  ];

  static List<BoxShadow> elevated = [
    BoxShadow(
      color: Colors.black.withOpacity(0.5),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];
}

class AppColorsLight {
  AppColorsLight._();

  static const Color bg = Color(0xFFFAF8F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFF5F3F0);
  static const Color surfaceHighlight = Color(0xFFEEECE8);

  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);

  static const Color border = Color(0xFFE5E7EB);

  static BoxDecoration gradientBg = const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFFFAF8F5),
        Color(0xFFF7F4EF),
        Color(0xFFF5F2EC),
      ],
    ),
  );
}

extension ThemeColorsX on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  Color get textPrimary => isDark ? AppColors.textPrimary : AppColorsLight.textPrimary;
  Color get textSecondary => isDark ? AppColors.textSecondary : AppColorsLight.textSecondary;
  Color get textMuted => isDark ? AppColors.textMuted : AppColorsLight.textMuted;
  Color get surfaceElevated => isDark ? AppColors.surfaceElevated : AppColorsLight.surfaceElevated;
  Color get surfaceHighlight => isDark ? AppColors.surfaceHighlight : AppColorsLight.surfaceHighlight;
  Color get border => isDark ? AppColors.border : AppColorsLight.border;
  Color get surface => isDark ? AppColors.surface : AppColorsLight.surface;
  Color get bg => isDark ? AppColors.deepBg : AppColorsLight.bg;
  BoxDecoration get gradientBg => isDark ? AppEffects.gradientBg : AppColorsLight.gradientBg;
}

class AppEffects {
  AppEffects._();

  static BoxDecoration glass({
    Color? bg,
    double blur = 16,
    double opacity = 0.15,
    double radius = AppRadius.lg,
    Color? borderColor,
  }) {
    return BoxDecoration(
      color: (bg ?? AppColors.surfaceElevated).withOpacity(opacity),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: (borderColor ?? AppColors.border).withOpacity(0.3),
        width: 0.5,
      ),
    );
  }

  static BoxDecoration glassCard({
    Color? bg,
    Color? accentColor,
    double radius = AppRadius.lg,
  }) {
    final accent = accentColor ?? AppColors.primaryGlow;
    return BoxDecoration(
      color: (bg ?? AppColors.surfaceElevated).withOpacity(0.4),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: accent,
        width: 0.5,
      ),
      boxShadow: [
        BoxShadow(
          color: accent,
          blurRadius: 2,
          spreadRadius: -1,
        ),
      ],
    );
  }

  static BoxDecoration gradientBg = const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFF08080F),
        Color(0xFF0A0A1A),
        Color(0xFF0C0C20),
        Color(0xFF0D0D1A),
      ],
    ),
  );

  static BoxDecoration glowBorder({
    Color color = AppColors.primary,
    double radius = AppRadius.md,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: color.withOpacity(0.4), width: 1),
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.2),
          blurRadius: 8,
          spreadRadius: 0,
        ),
      ],
    );
  }
}
