import 'package:flutter/material.dart';

/// Moda Design Tokens — Digital Atelier M3 Palette
/// Extracted from Stitch project: stitch.withgoogle.com/projects/1500541745791565533
/// Central source of truth for all visual constants.

class AppColors {
  AppColors._();

  // ─── Primary ─────────────────────────────────────────────
  static const primary = Color(0xFFAC2C14); // burnt rust red
  static const primaryContainer = Color(0xFFCE452A); // medium terracotta
  static const onPrimary = Color(0xFFFFFFFF);
  static const onPrimaryContainer = Color(0xFFFFFBFF);
  static const primaryFixed = Color(0xFFFFDAD3);
  static const primaryFixedDim = Color(0xFFFFB4A4);
  static const onPrimaryFixed = Color(0xFF3E0500);
  static const onPrimaryFixedVariant = Color(0xFF8D1600);
  static const inversePrimary = Color(0xFFFFB4A4);
  static const surfaceTint = Color(0xFFAF2F16);

  // ─── Secondary ───────────────────────────────────────────
  static const secondary = Color(0xFF006D3E); // forest green
  static const secondaryContainer = Color(0xFF6FF9A8);
  static const onSecondary = Color(0xFFFFFFFF);
  static const onSecondaryContainer = Color(0xFF007241);
  static const secondaryFixed = Color(0xFF72FCAA);
  static const secondaryFixedDim = Color(0xFF52DF90);
  static const onSecondaryFixed = Color(0xFF00210F);
  static const onSecondaryFixedVariant = Color(0xFF00522D);

  // ─── Tertiary ────────────────────────────────────────────
  static const tertiary = Color(0xFF615B53); // warm taupe
  static const tertiaryContainer = Color(0xFF7A746B);
  static const onTertiary = Color(0xFFFFFFFF);
  static const onTertiaryContainer = Color(0xFFFFFBFF);
  static const tertiaryFixed = Color(0xFFEAE1D6);
  static const tertiaryFixedDim = Color(0xFFCDC5BB);
  static const onTertiaryFixed = Color(0xFF1F1B14);
  static const onTertiaryFixedVariant = Color(0xFF4B463E);

  // ─── Surface hierarchy (tonal depth, no-line rule) ──────
  static const background = Color(0xFFFBF9F1); // warm cream base (Level 0)
  static const onBackground = Color(0xFF1B1C17);
  static const surface = Color(0xFFFBF9F1);
  static const surfaceDim = Color(0xFFDCDAD2);
  static const surfaceBright = Color(0xFFFBF9F1);
  static const surfaceContainerLowest = Color(0xFFFFFFFF); // Level 2 cards
  static const surfaceContainerLow = Color(0xFFF5F4EB); // Level 1 sections
  static const surfaceContainer = Color(0xFFF0EEE5);
  static const surfaceContainerHigh = Color(0xFFEAE8E0);
  static const surfaceContainerHighest = Color(0xFFE4E3DA);
  static const surfaceVariant = Color(0xFFE4E3DA);
  static const onSurface = Color(0xFF1B1C17); // near-black (never pure #000)
  static const onSurfaceVariant = Color(0xFF59413C);

  // ─── Outline ─────────────────────────────────────────────
  static const outline = Color(0xFF8D706A);
  static const outlineVariant = Color(0xFFE1BFB8);

  // ─── Error ───────────────────────────────────────────────
  static const error = Color(0xFFBA1A1A);
  static const errorContainer = Color(0xFFFFDAD6);
  static const onError = Color(0xFFFFFFFF);
  static const onErrorContainer = Color(0xFF93000A);

  // ─── Inverse ─────────────────────────────────────────────
  static const inverseSurface = Color(0xFF30312B);
  static const inverseOnSurface = Color(0xFFF2F1E8);

  // ─── Semantic aliases ────────────────────────────────────
  static const success = Color(0xFF006D3E); // = secondary
  static const warning = Color(0xFFF5A623);

  // Swipe overlays
  static const likeGreen = Color(0xFF006D3E);
  static const nopeRed = Color(0xFFBA1A1A);

  // ─── Glassmorphism ───────────────────────────────────────
  static const glassBackground =
      Color(0xCCFBF9F1); // surface at 80% — nav bars
  static const glassBackgroundLight =
      Color(0xB3FFFFFF); // white at 70% — cards/overlays
  static const glassBorder =
      Color(0x33E1BFB8); // outlineVariant at 20% — ghost border
  static const glassBorderLight = Color(0x59FFFFFF);

  // ─── Legacy compatibility aliases ────────────────────────
  static const black = onSurface;
  static const white = onPrimary;
  static const textPrimary = onSurface;
  static const textSecondary = onSurfaceVariant;
  static const textTertiary = outline;
  static const border = outlineVariant;
  static const borderLight = surfaceContainerHigh;
  static const shadowColor = onSurface;
  static const surfaceSecondary = surfaceContainerLow;
  static const surfaceElevated = surfaceContainerLow;
  static const accent = secondary;
  static const accentWarm = Color(0xFFFFB4A4); // primaryFixedDim
  static const primaryLight = primaryFixed;
  static const primaryDark = primaryContainer;

  // Warm stone gray scale (mapped to M3 surface tiers)
  static const gray50 = surfaceContainerLowest;
  static const gray100 = surfaceContainerLow;
  static const gray200 = surfaceContainerHigh;
  static const gray300 = surfaceDim;
  static const gray400 = outline;
  static const gray500 = onSurfaceVariant;
  static const gray600 = Color(0xFF57534E);
  static const gray700 = Color(0xFF3D3935);
  static const gray800 = Color(0xFF292524);
  static const gray900 = onSurface;

  // Glass-specific legacy
  static const glassBackgroundDark = Color(0x99000000);
  static const glassBorderSubtle = glassBorder;
  static const accentLight = primaryFixedDim;
  static const accentMuted = outline;
}

class AppGradients {
  AppGradients._();

  // Signature CTA gradient — "sun-drenched" warmth (#AC2C14 → #CE452A)
  static const primary = LinearGradient(
    colors: [Color(0xFFAC2C14), Color(0xFFCE452A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Card image scrim
  static const cardScrim = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.transparent, Color(0x331B1C17), Color(0x991B1C17)],
  );

  // Background fade for floating nav bar
  static const backgroundFade = LinearGradient(
    colors: [Color(0x00FBF9F1), Color(0xCCFBF9F1)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Subtle card gradient
  static const card = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF5F4EB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const subtle = card;

  static const background = LinearGradient(
    colors: [Color(0xFFFBF9F1), Color(0xFFFBF9F1)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Warm sunset accent
  static const sunset = LinearGradient(
    colors: [Color(0xFFFFB4A4), Color(0xFFF5A623)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppSpacing {
  AppSpacing._();

  // Stitch spacing scale (scale factor 2)
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48; // 3rem — primary section gap
  static const double xxxxl = 64; // 4rem — major section gap
}

class AppRadius {
  AppRadius._();

  // Stitch "ROUND_FULL" profile — larger, softer radii
  static const double sm = 12;
  static const double md = 16; // 1rem — default for cards, buttons
  static const double lg = 24; // 1.5rem — image containers
  static const double xl = 32; // 2rem — large cards, sheets
  static const double xxl = 48; // 3rem — hero sections
  static const double xxxl = 48;
  static const double full = 9999; // pill shapes
}

class AppTypography {
  AppTypography._();

  // Stitch typography scale
  static const double fontXs = 12; // Label MD
  static const double fontSm = 14; // Body MD
  static const double fontMd = 16; // Body LG
  static const double fontLg = 18; // Title MD
  static const double fontXl = 22; // Title LG (1.375rem)
  static const double font2xl = 28; // Headline MD (1.75rem)
  static const double font3xl = 34; // Headline LG
  static const double font4xl = 56; // Display LG (3.5rem)

  static const double lineHeightTight = 1.2;
  static const double lineHeightNormal = 1.5;
  static const double lineHeightRelaxed = 1.75;
  static const double lineHeightEditorial = 0.85; // for display type

  // Letter spacing — editorial authority
  static const double letterSpacingDisplay = -2.24; // -0.04em at 56px
  static const double letterSpacingHeadline = -0.56; // -0.02em at 28px
  static const double letterSpacingTitle = -0.5;
  static const double letterSpacingBody = 0.1;
  static const double letterSpacingTight = -0.5;
}

class AppShadows {
  AppShadows._();

  // Tinted ambient shadows using on-surface color (#1B1C17)
  static const sm = [
    BoxShadow(
      color: Color(0x0A1B1C17), // 4% opacity
      offset: Offset(0, 2),
      blurRadius: 8,
    ),
  ];

  static const md = [
    BoxShadow(
      color: Color(0x0F1B1C17), // 6% opacity
      offset: Offset(0, 4),
      blurRadius: 16,
    ),
  ];

  static const lg = [
    BoxShadow(
      color: Color(0x141B1C17), // 8% opacity — signature ambient
      offset: Offset(0, 20),
      blurRadius: 50,
    ),
  ];

  static const xl = [
    BoxShadow(
      color: Color(0x141B1C17),
      offset: Offset(0, 20),
      blurRadius: 60,
    ),
  ];

  // Nav bar floating shadow
  static const navBar = [
    BoxShadow(
      color: Color(0x141B1C17),
      offset: Offset(0, 8),
      blurRadius: 40,
    ),
  ];
}

class AppGlass {
  AppGlass._();

  static const double blur = 12; // glass cards
  static const double blurIntense = 20; // nav bars, major overlays
  static const double blurLight = 8; // subtle hints
}

class AppAnimation {
  AppAnimation._();

  static const double swipeThrowThreshold = 120;
  static const double swipeRotationFactor = 0.07;
  static const int swipeSnapBackDuration = 400;
  static const int swipeFlyOutDuration = 300;
  static const double overlayOpacityMin = 0;
  static const double overlayOpacityMax = 0.8;

  static const double springDamping = 15;
  static const double springStiffness = 150;
  static const double springMass = 1;

  static const int matchPopupDuration = 600;
  static const int confettiCount = 30;

  static const int cardEntranceDuration = 500;
}

class AppLayout {
  AppLayout._();

  static const double cardMarginHorizontal = 16;
  static const double cardMarginTop = 8;
  static const double cardInfoStripHeight = 100;
  static const double tabBarHeight = 80;
  static const double headerHeight = 56;
  static const int matchGridColumns = 2;
  static const double matchGridGap = 14;
  static const double chatInputHeight = 56;
  static const double screenPaddingH = 20;
}
