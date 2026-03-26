import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'tokens.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.onPrimaryContainer,
        primaryFixed: AppColors.primaryFixed,
        primaryFixedDim: AppColors.primaryFixedDim,
        onPrimaryFixed: AppColors.onPrimaryFixed,
        onPrimaryFixedVariant: AppColors.onPrimaryFixedVariant,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        secondaryContainer: AppColors.secondaryContainer,
        onSecondaryContainer: AppColors.onSecondaryContainer,
        secondaryFixed: AppColors.secondaryFixed,
        secondaryFixedDim: AppColors.secondaryFixedDim,
        onSecondaryFixed: AppColors.onSecondaryFixed,
        onSecondaryFixedVariant: AppColors.onSecondaryFixedVariant,
        tertiary: AppColors.tertiary,
        onTertiary: AppColors.onTertiary,
        tertiaryContainer: AppColors.tertiaryContainer,
        onTertiaryContainer: AppColors.onTertiaryContainer,
        tertiaryFixed: AppColors.tertiaryFixed,
        tertiaryFixedDim: AppColors.tertiaryFixedDim,
        onTertiaryFixed: AppColors.onTertiaryFixed,
        onTertiaryFixedVariant: AppColors.onTertiaryFixedVariant,
        error: AppColors.error,
        onError: AppColors.onError,
        errorContainer: AppColors.errorContainer,
        onErrorContainer: AppColors.onErrorContainer,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        surfaceDim: AppColors.surfaceDim,
        surfaceBright: AppColors.surfaceBright,
        surfaceContainerLowest: AppColors.surfaceContainerLowest,
        surfaceContainerLow: AppColors.surfaceContainerLow,
        surfaceContainer: AppColors.surfaceContainer,
        surfaceContainerHigh: AppColors.surfaceContainerHigh,
        surfaceContainerHighest: AppColors.surfaceContainerHighest,
        onSurfaceVariant: AppColors.onSurfaceVariant,
        outline: AppColors.outline,
        outlineVariant: AppColors.outlineVariant,
        inverseSurface: AppColors.inverseSurface,
        onInverseSurface: AppColors.inverseOnSurface,
        inversePrimary: AppColors.inversePrimary,
        surfaceTint: AppColors.surfaceTint,
        shadow: AppColors.onSurface,
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(
        const TextTheme(
          displayLarge: TextStyle(
            fontSize: AppTypography.font4xl,
            fontWeight: FontWeight.w800,
            color: AppColors.onSurface,
            letterSpacing: AppTypography.letterSpacingDisplay,
            height: AppTypography.lineHeightEditorial,
          ),
          displayMedium: TextStyle(
            fontSize: AppTypography.font3xl,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
            letterSpacing: AppTypography.letterSpacingHeadline,
          ),
          displaySmall: TextStyle(
            fontSize: AppTypography.font2xl,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
            letterSpacing: AppTypography.letterSpacingHeadline,
          ),
          headlineLarge: TextStyle(
            fontSize: AppTypography.font2xl,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
            letterSpacing: AppTypography.letterSpacingHeadline,
          ),
          headlineMedium: TextStyle(
            fontSize: AppTypography.fontXl,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
            letterSpacing: AppTypography.letterSpacingTitle,
          ),
          headlineSmall: TextStyle(
            fontSize: AppTypography.fontLg,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
            letterSpacing: AppTypography.letterSpacingTitle,
          ),
          titleLarge: TextStyle(
            fontSize: AppTypography.fontXl,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
          titleMedium: TextStyle(
            fontSize: AppTypography.fontMd,
            fontWeight: FontWeight.w500,
            color: AppColors.onSurface,
          ),
          titleSmall: TextStyle(
            fontSize: AppTypography.fontSm,
            fontWeight: FontWeight.w500,
            color: AppColors.onSurface,
          ),
          bodyLarge: TextStyle(
            fontSize: AppTypography.fontMd,
            color: AppColors.onSurface,
            letterSpacing: AppTypography.letterSpacingBody,
          ),
          bodyMedium: TextStyle(
            fontSize: AppTypography.fontSm,
            color: AppColors.onSurfaceVariant,
            letterSpacing: AppTypography.letterSpacingBody,
          ),
          bodySmall: TextStyle(
            fontSize: AppTypography.fontXs,
            color: AppColors.outline,
            letterSpacing: AppTypography.letterSpacingBody,
          ),
          labelLarge: TextStyle(
            fontSize: AppTypography.fontMd,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
          labelMedium: TextStyle(
            fontSize: AppTypography.fontXs,
            fontWeight: FontWeight.w500,
            color: AppColors.onSurfaceVariant,
          ),
          labelSmall: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: AppColors.outline,
            letterSpacing: 0.5,
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.onSurface),
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: AppTypography.fontLg,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface,
          letterSpacing: AppTypography.letterSpacingTitle,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceContainerHighest,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.md,
        ),
        // Ghost border: outlineVariant at 10% opacity
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(
            color: AppColors.outlineVariant.withValues(alpha: 0.1),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(
            color: AppColors.outlineVariant.withValues(alpha: 0.1),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        hintStyle: GoogleFonts.plusJakartaSans(
          color: AppColors.outline,
          fontSize: AppTypography.fontSm,
          letterSpacing: AppTypography.letterSpacingBody,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: AppTypography.fontMd,
            fontWeight: FontWeight.w600,
            letterSpacing: AppTypography.letterSpacingBody,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          side: const BorderSide(color: AppColors.outlineVariant),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: AppTypography.fontMd,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: AppTypography.fontMd,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceContainerLowest,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        margin: EdgeInsets.zero,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceContainerHigh,
        selectedColor: AppColors.primaryFixed,
        labelStyle: GoogleFonts.plusJakartaSans(
          fontSize: AppTypography.fontSm,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.onSurface,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      dividerTheme: const DividerThemeData(
        color: Colors.transparent, // no-line rule
        thickness: 0,
        space: AppSpacing.lg,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
        ),
      ),
    );
  }

  static ThemeData get dark => light;
}
