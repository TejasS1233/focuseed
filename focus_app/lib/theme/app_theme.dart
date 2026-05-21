import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme.dart';

class AppTheme {
  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.deepBg,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      tertiary: AppColors.tertiary,
      error: AppColors.error,
      surface: AppColors.surface,
    ),
    fontFamily: AppTypography.bodyFont,
    textTheme: GoogleFonts.plusJakartaSansTextTheme().copyWith(
      displayLarge: GoogleFonts.playfairDisplay(
        fontSize: 34, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
      ),
      displayMedium: GoogleFonts.playfairDisplay(
        fontSize: 28, fontWeight: FontWeight.w600, color: AppColors.textPrimary,
      ),
      headlineLarge: GoogleFonts.plusJakartaSans(
        fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
      ),
      headlineMedium: GoogleFonts.plusJakartaSans(
        fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary,
      ),
      headlineSmall: GoogleFonts.plusJakartaSans(
        fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary, letterSpacing: 0.3,
      ),
      bodyLarge: GoogleFonts.plusJakartaSans(
        fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.textPrimary, height: 1.6,
      ),
      bodyMedium: GoogleFonts.plusJakartaSans(
        fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.textSecondary, height: 1.5,
      ),
      bodySmall: GoogleFonts.plusJakartaSans(
        fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textMuted, letterSpacing: 0.5,
      ),
      labelLarge: GoogleFonts.plusJakartaSans(
        fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary, letterSpacing: 0.8,
      ),
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.textPrimary,
      titleTextStyle: GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surface.withOpacity(0.85),
      elevation: 0,
      indicatorColor: AppColors.primary.withOpacity(0.15),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
            letterSpacing: 0.5,
          );
        }
        return GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppColors.textMuted,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: AppColors.primary, size: 22);
        }
        return const IconThemeData(color: AppColors.textMuted, size: 22);
      }),
    ),
    cardTheme: CardTheme(
      elevation: 0,
      color: AppColors.surfaceElevated.withOpacity(0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: const BorderSide(color: AppColors.border, width: 0.5),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.black,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 28),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        textStyle: GoogleFonts.plusJakartaSans(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        side: const BorderSide(color: AppColors.border, width: 1),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 28),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.textMuted,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      hintStyle: GoogleFonts.plusJakartaSans(
        color: AppColors.textMuted,
        fontSize: 15,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.primary, width: 1),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.primary;
        return AppColors.textMuted;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.primary.withOpacity(0.3);
        return AppColors.border;
      }),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: AppColors.primary,
      inactiveTrackColor: AppColors.border,
      thumbColor: AppColors.primary,
      overlayColor: AppColors.primary.withOpacity(0.12),
      valueIndicatorColor: AppColors.primary,
      valueIndicatorTextStyle: GoogleFonts.plusJakartaSans(
        color: AppColors.black,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.border,
      thickness: 0.5,
      space: 1,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.surface,
      selectedColor: AppColors.primary.withOpacity(0.15),
      labelStyle: GoogleFonts.plusJakartaSans(
        color: AppColors.textSecondary,
        fontSize: 13,
      ),
      side: const BorderSide(color: AppColors.border),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
    ),
    dialogTheme: DialogTheme(
      backgroundColor: AppColors.surfaceElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: const BorderSide(color: AppColors.border, width: 0.5),
      ),
      titleTextStyle: GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primary,
      circularTrackColor: AppColors.border,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: AppColors.surfaceElevated.withOpacity(0.95),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.surfaceElevated,
      contentTextStyle: GoogleFonts.plusJakartaSans(
        color: AppColors.textPrimary,
        fontSize: 14,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      behavior: SnackBarBehavior.floating,
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: _ProSlideTransitionBuilder(),
        TargetPlatform.iOS: _ProSlideTransitionBuilder(),
      },
    ),
  );

  static ThemeData get light => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColorsLight.bg,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primaryDark,
      secondary: AppColors.secondary,
      tertiary: AppColors.tertiary,
      error: AppColors.error,
      surface: AppColorsLight.surface,
    ),
    fontFamily: AppTypography.bodyFont,
    textTheme: GoogleFonts.plusJakartaSansTextTheme().copyWith(
      displayLarge: GoogleFonts.playfairDisplay(
        fontSize: 34, fontWeight: FontWeight.w700, color: AppColorsLight.textPrimary,
      ),
      displayMedium: GoogleFonts.playfairDisplay(
        fontSize: 28, fontWeight: FontWeight.w600, color: AppColorsLight.textPrimary,
      ),
      headlineLarge: GoogleFonts.plusJakartaSans(
        fontSize: 22, fontWeight: FontWeight.w700, color: AppColorsLight.textPrimary,
      ),
      headlineMedium: GoogleFonts.plusJakartaSans(
        fontSize: 18, fontWeight: FontWeight.w600, color: AppColorsLight.textPrimary,
      ),
      headlineSmall: GoogleFonts.plusJakartaSans(
        fontSize: 15, fontWeight: FontWeight.w600, color: AppColorsLight.textPrimary, letterSpacing: 0.3,
      ),
      bodyLarge: GoogleFonts.plusJakartaSans(
        fontSize: 15, fontWeight: FontWeight.w400, color: AppColorsLight.textPrimary, height: 1.6,
      ),
      bodyMedium: GoogleFonts.plusJakartaSans(
        fontSize: 13, fontWeight: FontWeight.w400, color: AppColorsLight.textSecondary, height: 1.5,
      ),
      bodySmall: GoogleFonts.plusJakartaSans(
        fontSize: 11, fontWeight: FontWeight.w500, color: AppColorsLight.textMuted, letterSpacing: 0.5,
      ),
      labelLarge: GoogleFonts.plusJakartaSans(
        fontSize: 12, fontWeight: FontWeight.w600, color: AppColorsLight.textPrimary, letterSpacing: 0.8,
      ),
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      backgroundColor: Colors.transparent,
      foregroundColor: AppColorsLight.textPrimary,
      titleTextStyle: GoogleFonts.plusJakartaSans(
        fontSize: 18, fontWeight: FontWeight.w600, color: AppColorsLight.textPrimary,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColorsLight.surface.withOpacity(0.92),
      elevation: 0,
      indicatorColor: AppColors.primary.withOpacity(0.12),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return GoogleFonts.plusJakartaSans(
            fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primaryDark, letterSpacing: 0.5,
          );
        }
        return GoogleFonts.plusJakartaSans(
          fontSize: 11, fontWeight: FontWeight.w500, color: AppColorsLight.textMuted,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: AppColors.primaryDark, size: 22);
        }
        return const IconThemeData(color: AppColorsLight.textMuted, size: 22);
      }),
    ),
    cardTheme: CardTheme(
      elevation: 0,
      color: AppColorsLight.surfaceElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: const BorderSide(color: AppColorsLight.border, width: 0.5),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: AppColorsLight.surface,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 28),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        textStyle: GoogleFonts.plusJakartaSans(
          fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 0.3,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColorsLight.textPrimary,
        side: const BorderSide(color: AppColorsLight.border, width: 1),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 28),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColorsLight.textMuted,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColorsLight.bg,
      hintStyle: GoogleFonts.plusJakartaSans(
        color: AppColorsLight.textMuted, fontSize: 15,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColorsLight.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColorsLight.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.primaryDark, width: 1),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.primaryDark;
        return AppColorsLight.textMuted;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.primaryDark.withOpacity(0.3);
        return AppColorsLight.border;
      }),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: AppColors.primaryDark,
      inactiveTrackColor: AppColorsLight.border,
      thumbColor: AppColors.primaryDark,
      overlayColor: AppColors.primaryDark.withOpacity(0.12),
      valueIndicatorColor: AppColors.primaryDark,
      valueIndicatorTextStyle: GoogleFonts.plusJakartaSans(
        color: AppColorsLight.surface, fontSize: 12, fontWeight: FontWeight.w600,
      ),
    ),
    dividerTheme: DividerThemeData(
      color: AppColorsLight.border,
      thickness: 0.5,
      space: 1,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColorsLight.bg,
      selectedColor: AppColors.primaryDark.withOpacity(0.1),
      labelStyle: GoogleFonts.plusJakartaSans(
        color: AppColorsLight.textSecondary, fontSize: 13,
      ),
      side: const BorderSide(color: AppColorsLight.border),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
    ),
    dialogTheme: DialogTheme(
      backgroundColor: AppColorsLight.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: const BorderSide(color: AppColorsLight.border, width: 0.5),
      ),
      titleTextStyle: GoogleFonts.plusJakartaSans(
        fontSize: 18, fontWeight: FontWeight.w600, color: AppColorsLight.textPrimary,
      ),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: AppColors.primaryDark,
      circularTrackColor: AppColorsLight.border,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: AppColorsLight.surface.withOpacity(0.98),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColorsLight.surfaceElevated,
      contentTextStyle: GoogleFonts.plusJakartaSans(
        color: AppColorsLight.textPrimary, fontSize: 14,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      behavior: SnackBarBehavior.floating,
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: _ProSlideTransitionBuilder(),
        TargetPlatform.iOS: _ProSlideTransitionBuilder(),
      },
    ),
  );
}

class _ProSlideTransitionBuilder extends PageTransitionsBuilder {
  const _ProSlideTransitionBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    const begin = Offset(0.0, 0.06);
    const end = Offset.zero;
    const curve = Curves.easeOutCubic;

    final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
    final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animation, curve: const Interval(0.0, 0.4, curve: Curves.easeOut)),
    );
    final slideAnimation = tween.animate(animation);

    return SlideTransition(
      position: slideAnimation,
      child: FadeTransition(opacity: fadeAnimation, child: child),
    );
  }
}
