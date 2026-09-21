import 'package:flutter/material.dart';

/// ==================== APP THEME ====================
///
/// Единая тема приложения с поддержкой Material 3
/// и тёмным дизайном по умолчанию.

class AppTheme {
  // Основные цвета
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF8B85FF);
  static const Color primaryDark = Color(0xFF5046CC);

  static const Color secondary = Color(0xFF00BFA6);
  static const Color secondaryLight = Color(0xFF33CDB8);
  static const Color secondaryDark = Color(0xFF008E7A);

  static const Color accent = Color(0xFFFF6D00);
  static const Color accentLight = Color(0xFFFF9E40);

  static const Color error = Color(0xFFD50000);
  static const Color warning = Color(0xFFFFB300);
  static const Color success = Color(0xFF00BFA6);

  // Фон
  static const Color background = Color(0xFF0F0F0F);
  static const Color surface = Color(0xFF1A1A1A);
  static const Color surfaceVariant = Color(0xFF252525);
  static const Color surfaceElevated = Color(0xFF2A2A2A);

  // Текст
  static const Color onPrimary = Colors.white;
  static const Color onSecondary = Colors.white;
  static const Color onBackground = Colors.white;
  static const Color onSurface = Colors.white;
  static const Color onSurfaceVariant = Color(0xFFB0B0B0);
  static const Color onSurfaceMuted = Color(0xFF808080);

  // Миссии
  static const Color missionRed = Color(0xFFFF6B6B);
  static const Color missionTeal = Color(0xFF4ECDC4);
  static const Color missionYellow = Color(0xFFFFD93D);

  // Границы
  static const Color outline = Color(0xFF3A3A3A);
  static const Color outlineVariant = Color(0xFF2A2A2A);

  // Градиенты
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    colors: [surface, surfaceVariant],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Размеры
  static const double cardRadius = 20.0;
  static const double buttonRadius = 16.0;
  static const double inputRadius = 12.0;
  static const double chipRadius = 8.0;
  static const double avatarRadius = 32.0;

  // Отступы
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;

  // Тени
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get elevatedShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get glowShadow => [
        BoxShadow(
          color: primary.withOpacity(0.3),
          blurRadius: 20,
          spreadRadius: 5,
        ),
      ];

  /// Material 3 Color Scheme
  static ColorScheme get colorScheme => const ColorScheme.dark(
        primary: primary,
        onPrimary: onPrimary,
        primaryContainer: primaryDark,
        onPrimaryContainer: onPrimary,
        secondary: secondary,
        onSecondary: onSecondary,
        secondaryContainer: secondaryDark,
        onSecondaryContainer: onSecondary,
        tertiary: accent,
        onTertiary: Colors.white,
        tertiaryContainer: accentLight,
        onTertiaryContainer: Colors.white,
        error: error,
        onError: Colors.white,
        errorContainer: Color(0xFF3A1010),
        onErrorContainer: Colors.white,
        surface: surface,
        onSurface: onSurface,
        surfaceVariant: surfaceVariant,
        onSurfaceVariant: onSurfaceVariant,
        outline: outline,
        outlineVariant: outlineVariant,
        background: background,
        onBackground: onBackground,
        surfaceTint: primary,
        brightness: Brightness.dark,
      );

  /// Основная тема приложения
  static ThemeData get theme => ThemeData.dark().copyWith(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: background,

        // AppBar
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: onSurface,
          ),
          iconTheme: IconThemeData(color: onSurface),
        ),

        // Cards
        cardTheme: CardThemeData(
          color: surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(cardRadius),
          ),
          margin: const EdgeInsets.symmetric(
              horizontal: paddingM, vertical: paddingS),
        ),

        // Buttons
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: onPrimary,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(buttonRadius),
            ),
            padding: const EdgeInsets.symmetric(
                horizontal: paddingL, vertical: paddingM),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: primary,
            side: const BorderSide(color: primary, width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(buttonRadius),
            ),
            padding: const EdgeInsets.symmetric(
                horizontal: paddingL, vertical: paddingM),
          ),
        ),

        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(buttonRadius),
            ),
          ),
        ),

        // Input
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surface,
          contentPadding: const EdgeInsets.all(paddingM),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(inputRadius),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(inputRadius),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(inputRadius),
            borderSide: const BorderSide(color: primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(inputRadius),
            borderSide: const BorderSide(color: error, width: 2),
          ),
          labelStyle: const TextStyle(color: onSurfaceVariant),
          hintStyle: TextStyle(color: onSurfaceMuted.withOpacity(0.6)),
        ),

        // Switches
        switchTheme: SwitchThemeData(
          thumbColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return primary;
            }
            return onSurfaceMuted;
          }),
          trackColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return primary.withOpacity(0.3);
            }
            return outline;
          }),
        ),

        // Sliders
        sliderTheme: const SliderThemeData(
          activeTrackColor: primary,
          inactiveTrackColor: outline,
          thumbColor: primary,
          overlayColor: primaryLight,
          trackHeight: 4,
        ),

        // Chips
        chipTheme: ChipThemeData(
          backgroundColor: surfaceVariant,
          selectedColor: primary.withOpacity(0.2),
          labelStyle: const TextStyle(color: onSurface),
          secondaryLabelStyle: const TextStyle(color: primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(chipRadius),
          ),
          side: BorderSide.none,
        ),

        // Dialogs
        dialogTheme: DialogThemeData(
          backgroundColor: surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(cardRadius),
          ),
        ),

        // Bottom Sheets
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: surface,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(cardRadius)),
          ),
        ),

        // Floating Action Button
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(buttonRadius)),
          ),
        ),

        // Typography
        textTheme: const TextTheme(
          displayLarge: TextStyle(
              fontSize: 57, fontWeight: FontWeight.w300, color: onSurface),
          displayMedium: TextStyle(
              fontSize: 45, fontWeight: FontWeight.w300, color: onSurface),
          displaySmall: TextStyle(
              fontSize: 36, fontWeight: FontWeight.w400, color: onSurface),
          headlineLarge: TextStyle(
              fontSize: 32, fontWeight: FontWeight.w600, color: onSurface),
          headlineMedium: TextStyle(
              fontSize: 28, fontWeight: FontWeight.w500, color: onSurface),
          headlineSmall: TextStyle(
              fontSize: 24, fontWeight: FontWeight.w500, color: onSurface),
          titleLarge: TextStyle(
              fontSize: 22, fontWeight: FontWeight.w600, color: onSurface),
          titleMedium: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w500, color: onSurface),
          titleSmall: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: onSurfaceVariant),
          bodyLarge: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w400, color: onSurface),
          bodyMedium: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w400, color: onSurface),
          bodySmall: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: onSurfaceVariant),
          labelLarge: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w600, color: onSurface),
          labelMedium: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: onSurfaceVariant),
          labelSmall: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w500, color: onSurfaceMuted),
        ),
      );
}

/// ==================== APP TEXT STYLES ====================

class AppTextStyles {
  static const TextStyle displayLarge = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w200,
    color: AppTheme.onSurface,
    letterSpacing: 2,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w300,
    color: AppTheme.onSurface,
    letterSpacing: 1,
  );

  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    color: AppTheme.onSurface,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppTheme.onSurface,
  );

  static const TextStyle titleLarge = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppTheme.onSurface,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppTheme.onSurface,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppTheme.onSurface,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppTheme.onSurfaceVariant,
  );

  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppTheme.primary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppTheme.onSurfaceMuted,
  );
}

/// ==================== APP DECORATIONS ====================

class AppDecorations {
  static BoxDecoration get cardDecoration => BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        boxShadow: AppTheme.cardShadow,
      );

  static BoxDecoration get elevatedCardDecoration => BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        boxShadow: AppTheme.elevatedShadow,
      );

  static BoxDecoration get primaryGradientDecoration => BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
      );

  static BoxDecoration get circleDecoration => BoxDecoration(
        color: AppTheme.surface,
        shape: BoxShape.circle,
        boxShadow: AppTheme.cardShadow,
      );

  static BoxDecoration get chipDecoration => BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(AppTheme.chipRadius),
      );

  static BoxDecoration get activeChipDecoration => BoxDecoration(
        color: AppTheme.primary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(AppTheme.chipRadius),
        border: Border.all(color: AppTheme.primary, width: 1.5),
      );
}

/// ==================== APP ANIMATIONS ====================

class AppAnimations {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);

  static const Curve easeIn = Curves.easeIn;
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve bounce = Curves.bounceOut;
  static const Curve elastic = Curves.elasticOut;
}
