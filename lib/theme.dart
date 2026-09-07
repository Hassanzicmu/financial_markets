import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BinanceColors {
  static const Color primary = Color(0xFFFCD535);
  static const Color primaryActive = Color(0xFFF0B90B);
  static const Color primaryDisabled = Color(0xFF3A3A1F);
  
  static const Color ink = Color(0xFF181A20);
  static const Color body = Color(0xFFEAECEF);
  static const Color bodyOnLight = Color(0xFF181A20);
  
  static const Color muted = Color(0xFF707A8A);
  static const Color mutedStrong = Color(0xFF929AA5);
  
  static const Color hairlineOnLight = Color(0xFFEAECEF);
  static const Color hairlineOnDark = Color(0xFF2B3139);
  static const Color borderStrong = Color(0xFFCDD1D6);
  
  static const Color canvasLight = Color(0xFFFFFFFF);
  static const Color canvasDark = Color(0xFF0B0E11);
  
  static const Color surfaceCardDark = Color(0xFF1E2329);
  static const Color surfaceElevatedDark = Color(0xFF2B3139);
  
  static const Color surfaceSoftLight = Color(0xFFFAFAFA);
  static const Color surfaceStrongLight = Color(0xFFF5F5F5);
  
  static const Color onPrimary = Color(0xFF181A20);
  static const Color onDark = Color(0xFFFFFFFF);
  
  static const Color tradingUp = Color(0xFF0ECB81);
  static const Color tradingDown = Color(0xFFF6465D);
  
  static const Color info = Color(0xFF3B82F6);
}

extension AppThemeColors on BuildContext {
  // We use dark mode as the base for most product pages, and light for transactional.
  // Instead of using generic surface, we can expose Binance specific tokens based on theme brightness.
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  Color get canvas => isDark ? BinanceColors.canvasDark : BinanceColors.canvasLight;
  Color get surfaceCard => isDark ? BinanceColors.surfaceCardDark : BinanceColors.canvasLight;
  Color get surfaceElevated => isDark ? BinanceColors.surfaceElevatedDark : BinanceColors.surfaceStrongLight;
  Color get surfaceSoft => isDark ? BinanceColors.canvasDark : BinanceColors.surfaceSoftLight;
  
  Color get ink => isDark ? BinanceColors.onDark : BinanceColors.ink;
  Color get inkMute => BinanceColors.muted;
  Color get inkBody => isDark ? BinanceColors.body : BinanceColors.bodyOnLight;
  
  Color get hairline => isDark ? BinanceColors.hairlineOnDark : BinanceColors.hairlineOnLight;
  
  Color get primary => BinanceColors.primary;
  Color get primaryActive => BinanceColors.primaryActive;
  Color get onPrimary => BinanceColors.onPrimary;
  
  Color get tradingUp => BinanceColors.tradingUp;
  Color get tradingDown => BinanceColors.tradingDown;
}

class AppTypography {
  // BinanceNova fallback (Inter)
  static TextStyle _nova(double size, FontWeight weight, double height, double letterSpacing) {
    return GoogleFonts.inter(
      fontSize: size,
      fontWeight: weight,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  // BinancePlex fallback (IBM Plex Sans)
  static TextStyle _plex(double size, FontWeight weight, double height, double letterSpacing) {
    return GoogleFonts.ibmPlexSans(
      fontSize: size,
      fontWeight: weight,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static final heroDisplay = _nova(64, FontWeight.w700, 1.1, -1.0);
  static final displayLg = _nova(48, FontWeight.w700, 1.1, -0.5);
  static final displayMd = _nova(40, FontWeight.w600, 1.15, -0.3);
  static final displaySm = _nova(32, FontWeight.w600, 1.2, 0);
  
  static final titleLg = _nova(24, FontWeight.w600, 1.3, 0);
  static final titleMd = _nova(20, FontWeight.w600, 1.35, 0);
  static final titleSm = _nova(16, FontWeight.w600, 1.4, 0);
  
  static final numberDisplay = _plex(40, FontWeight.w700, 1.1, -0.3);
  static final numberMd = _plex(16, FontWeight.w500, 1.4, 0);
  static final numberSm = _plex(14, FontWeight.w500, 1.4, 0);
  
  static final bodyMd = _nova(14, FontWeight.w400, 1.5, 0);
  static final bodySm = _nova(13, FontWeight.w400, 1.5, 0);
  static final caption = _nova(12, FontWeight.w500, 1.4, 0);
  
  static final button = _nova(14, FontWeight.w600, 1.0, 0);
  static final navLink = _nova(14, FontWeight.w500, 1.4, 0);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: BinanceColors.primary,
        onPrimary: BinanceColors.onPrimary,
        surface: BinanceColors.canvasLight,
        onSurface: BinanceColors.ink,
      ),
      scaffoldBackgroundColor: BinanceColors.canvasLight,
      dividerColor: BinanceColors.hairlineOnLight,
      textTheme: _buildTextTheme(BinanceColors.ink),
    );
  }
  
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: BinanceColors.primary,
        onPrimary: BinanceColors.onPrimary,
        surface: BinanceColors.canvasDark,
        onSurface: BinanceColors.onDark,
      ),
      scaffoldBackgroundColor: BinanceColors.canvasDark,
      dividerColor: BinanceColors.hairlineOnDark,
      textTheme: _buildTextTheme(BinanceColors.onDark),
    );
  }

  static TextTheme _buildTextTheme(Color color) {
    return TextTheme(
      displayLarge: AppTypography.heroDisplay.copyWith(color: color),
      displayMedium: AppTypography.displayLg.copyWith(color: color),
      displaySmall: AppTypography.displayMd.copyWith(color: color),
      headlineLarge: AppTypography.displaySm.copyWith(color: color),
      headlineMedium: AppTypography.titleLg.copyWith(color: color),
      headlineSmall: AppTypography.titleMd.copyWith(color: color),
      titleLarge: AppTypography.titleSm.copyWith(color: color),
      bodyLarge: AppTypography.bodyMd.copyWith(color: color),
      bodyMedium: AppTypography.bodySm.copyWith(color: color),
      bodySmall: AppTypography.caption.copyWith(color: color),
      labelLarge: AppTypography.button.copyWith(color: color),
      labelMedium: AppTypography.navLink.copyWith(color: color),
    );
  }
}
