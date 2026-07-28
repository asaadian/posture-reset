
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  const AppTheme._();

  // =========================================================
  // Dark palette — premium health-tech / deep navy / violet / teal
  // =========================================================
  static const Color _darkBg = Color(0xFF050A14);
  static const Color _darkSurface = Color(0xFF0E1728);
  static const Color _darkSurfaceAlt = Color(0xFF17233A);
  static const Color _darkSurfaceElevated = Color(0xFF1C2944);

  static const Color _darkPrimary = Color(0xFF8EA2FF);
  static const Color _darkPrimarySoft = Color(0xFF252F5C);

  static const Color _darkSecondary = Color(0xFF2DD4BF);
  static const Color _darkSecondarySoft = Color(0xFF11383D);

  static const Color _darkTertiary = Color(0xFFA78BFA);
  static const Color _darkTertiarySoft = Color(0xFF34285F);

  static const Color _darkTextPrimary = Color(0xFFF5F7FF);
  static const Color _darkTextSecondary = Color(0xFFB8C2D9);
  static const Color _darkTextMuted = Color(0xFF8090AD);

  static const Color _darkBorder = Color(0xFF2D3956);
  static const Color _darkBorderSoft = Color(0xFF202B43);

  static const Color _darkSuccess = Color(0xFF34D399);
  static const Color _darkWarning = Color(0xFFF6C453);
  static const Color _darkError = Color(0xFFF87171);

  // =========================================================
  // Light palette — clean modern cool-light / airy / premium
  // =========================================================
  static const Color _lightBg = Color(0xFFEAF1F8);
  static const Color _lightSurface = Color(0xFFF6FAFE);
  static const Color _lightSurfaceAlt = Color(0xFFE4EDF7);
  static const Color _lightSurfaceElevated = Color(0xFFF9FCFF);

  static const Color _lightPrimary = Color(0xFF5364F6);
  static const Color _lightPrimarySoft = Color(0xFFDCE4FF);

  static const Color _lightSecondary = Color(0xFF0D9488);
  static const Color _lightSecondarySoft = Color(0xFFD4F1ED);

  static const Color _lightTertiary = Color(0xFF7C5CF4);
  static const Color _lightTertiarySoft = Color(0xFFE4DFFF);

  static const Color _lightTextPrimary = Color(0xFF111827);
  static const Color _lightTextSecondary = Color(0xFF4B5A70);
  static const Color _lightTextMuted = Color(0xFF718197);

  static const Color _lightBorder = Color(0xFFCBD8E8);
  static const Color _lightBorderSoft = Color(0xFFDCE6F2);

  static const Color _lightError = Color(0xFFE25555);

  // =========================================================
  // Design tokens
  // =========================================================
  static const double radiusXs = 10;
  static const double radiusSm = 14;
  static const double radiusMd = 18;
  static const double radiusLg = 24;
  static const double radiusXl = 30;

  static const double space2 = 8;
  static const double space3 = 12;
  static const double space4 = 16;
  static const double space5 = 20;
  static const double space6 = 24;
  static const double space8 = 32;

  static final ThemeData darkTheme = _buildDarkTheme();
  static final ThemeData lightTheme = _buildLightTheme();

  static ThemeData _buildDarkTheme() {
    final textTheme = _buildTextTheme(
      textPrimary: _darkTextPrimary,
      textSecondary: _darkTextSecondary,
      textMuted: _darkTextMuted,
    );

    final colorScheme = const ColorScheme.dark(
      brightness: Brightness.dark,
      primary: _darkPrimary,
      onPrimary: Color(0xFF0D1326),
      primaryContainer: _darkPrimarySoft,
      onPrimaryContainer: Color(0xFFEAF0FF),

      secondary: _darkSecondary,
      onSecondary: Color(0xFF051715),
      secondaryContainer: _darkSecondarySoft,
      onSecondaryContainer: Color(0xFFDDFBF8),

      tertiary: _darkTertiary,
      onTertiary: Color(0xFF0D1430),
      tertiaryContainer: _darkTertiarySoft,
      onTertiaryContainer: Color(0xFFEAEFFF),

      error: _darkError,
      onError: Colors.white,
      errorContainer: Color(0xFF4B181C),
      onErrorContainer: Color(0xFFFFDCDD),

      surface: _darkSurface,
      onSurface: _darkTextPrimary,
      onSurfaceVariant: _darkTextSecondary,

      surfaceContainerLowest: Color(0xFF050912),
      surfaceContainerLow: Color(0xFF0B1322),
      surfaceContainer: Color(0xFF111C2F),
      surfaceContainerHigh: Color(0xFF182641),
      surfaceContainerHighest: Color(0xFF22314F),

      outline: _darkBorder,
      outlineVariant: _darkBorderSoft,
      scrim: Colors.black,
    );

    return _buildTheme(
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      textTheme: textTheme,
      background: _darkBg,
      surface: _darkSurface,
      surfaceAlt: _darkSurfaceAlt,
      surfaceElevated: _darkSurfaceElevated,
      primary: _darkPrimary,
      primarySoft: _darkPrimarySoft,
      textPrimary: _darkTextPrimary,
      textSecondary: _darkTextSecondary,
      textMuted: _darkTextMuted,
      border: _darkBorder,
      error: _darkError,
      shadow: Colors.black.withValues(alpha: 0.34),
    );
  }

  static ThemeData _buildLightTheme() {
    final textTheme = _buildTextTheme(
      textPrimary: _lightTextPrimary,
      textSecondary: _lightTextSecondary,
      textMuted: _lightTextMuted,
    );

    final colorScheme = const ColorScheme.light(
      brightness: Brightness.light,
      primary: _lightPrimary,
      onPrimary: Colors.white,
      primaryContainer: _lightPrimarySoft,
      onPrimaryContainer: Color(0xFF27348A),

      secondary: _lightSecondary,
      onSecondary: Colors.white,
      secondaryContainer: _lightSecondarySoft,
      onSecondaryContainer: Color(0xFF0A4C45),

      tertiary: _lightTertiary,
      onTertiary: Colors.white,
      tertiaryContainer: _lightTertiarySoft,
      onTertiaryContainer: Color(0xFF3D2D92),

      error: _lightError,
      onError: Colors.white,
      errorContainer: Color(0xFFFFE4E4),
      onErrorContainer: Color(0xFF7F1717),

      surface: _lightSurface,
      onSurface: _lightTextPrimary,
      onSurfaceVariant: _lightTextSecondary,

      surfaceContainerLowest: Color(0xFFF8FBFF),
      surfaceContainerLow: Color(0xFFF1F6FB),
      surfaceContainer: Color(0xFFEAF2FA),
      surfaceContainerHigh: Color(0xFFE1EBF6),
      surfaceContainerHighest: Color(0xFFD8E5F2),

      outline: _lightBorder,
      outlineVariant: _lightBorderSoft,
      scrim: Colors.black,
    );

    return _buildTheme(
      brightness: Brightness.light,
      colorScheme: colorScheme,
      textTheme: textTheme,
      background: _lightBg,
      surface: _lightSurface,
      surfaceAlt: _lightSurfaceAlt,
      surfaceElevated: _lightSurfaceElevated,
      primary: _lightPrimary,
      primarySoft: _lightPrimarySoft,
      textPrimary: _lightTextPrimary,
      textSecondary: _lightTextSecondary,
      textMuted: _lightTextMuted,
      border: _lightBorder,
      error: _lightError,
      shadow: const Color(0xFF263B57).withValues(alpha: 0.12),
    );
  }

  static TextTheme _buildTextTheme({
    required Color textPrimary,
    required Color textSecondary,
    required Color textMuted,
  }) {
    return GoogleFonts.interTextTheme().copyWith(
      displayLarge: GoogleFonts.inter(
        fontSize: 40,
        height: 1.08,
        fontWeight: FontWeight.w700,
        color: textPrimary,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: 32,
        height: 1.12,
        fontWeight: FontWeight.w700,
        color: textPrimary,
      ),
      displaySmall: GoogleFonts.inter(
        fontSize: 28,
        height: 1.15,
        fontWeight: FontWeight.w700,
        color: textPrimary,
      ),
      headlineLarge: GoogleFonts.inter(
        fontSize: 24,
        height: 1.2,
        fontWeight: FontWeight.w700,
        color: textPrimary,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 22,
        height: 1.24,
        fontWeight: FontWeight.w700,
        color: textPrimary,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 20,
        height: 1.28,
        fontWeight: FontWeight.w700,
        color: textPrimary,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 18,
        height: 1.3,
        fontWeight: FontWeight.w700,
        color: textPrimary,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        height: 1.35,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 14,
        height: 1.35,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        height: 1.5,
        fontWeight: FontWeight.w400,
        color: textPrimary,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        height: 1.5,
        fontWeight: FontWeight.w400,
        color: textSecondary,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        height: 1.45,
        fontWeight: FontWeight.w400,
        color: textMuted,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        height: 1.2,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        height: 1.2,
        fontWeight: FontWeight.w600,
        color: textSecondary,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        height: 1.2,
        fontWeight: FontWeight.w600,
        color: textMuted,
      ),
    );
  }

  static ThemeData _buildTheme({
    required Brightness brightness,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
    required Color background,
    required Color surface,
    required Color surfaceAlt,
    required Color surfaceElevated,
    required Color primary,
    required Color primarySoft,
    required Color textPrimary,
    required Color textSecondary,
    required Color textMuted,
    required Color border,
    required Color error,
    required Color shadow,
  }) {
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      canvasColor: background,
      splashFactory: InkSparkle.splashFactory,
      textTheme: textTheme,
      dividerColor: border,
      disabledColor: textMuted,
      cardColor: surface,
      shadowColor: shadow,

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
        iconTheme: IconThemeData(color: textPrimary),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? surfaceElevated : const Color(0xFF172033),
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          side: BorderSide(
            color: isDark ? border : Colors.transparent,
          ),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      cardTheme: CardThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
        elevation: isDark ? 0 : 0.5,
        shadowColor: shadow,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          side: BorderSide(color: border),
        ),
      ),

      dividerTheme: DividerThemeData(
        color: border,
        thickness: 1,
        space: 1,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: isDark
            ? colorScheme.surfaceContainerHigh
            : colorScheme.surfaceContainerLow,
        selectedColor: primarySoft,
        disabledColor: surfaceAlt,
        side: BorderSide(color: border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
        labelStyle: textTheme.labelMedium!.copyWith(color: textSecondary),
        secondaryLabelStyle: textTheme.labelMedium!.copyWith(
          color: textPrimary,
        ),
        padding: const EdgeInsets.symmetric(horizontal: space3, vertical: 10),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: primary,
          foregroundColor: isDark ? const Color(0xFF0D1326) : Colors.white,
          disabledBackgroundColor: surfaceAlt,
          disabledForegroundColor: textMuted,
          minimumSize: const Size(0, 50),
          padding: const EdgeInsets.symmetric(horizontal: space5, vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: isDark ? const Color(0xFF0D1326) : Colors.white,
          disabledBackgroundColor: surfaceAlt,
          disabledForegroundColor: textMuted,
          minimumSize: const Size(0, 50),
          padding: const EdgeInsets.symmetric(horizontal: space5, vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          minimumSize: const Size(0, 50),
          padding: const EdgeInsets.symmetric(horizontal: space5, vertical: 13),
          side: BorderSide(color: border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSm),
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? colorScheme.surfaceContainerLow
            : colorScheme.surfaceContainerLow,
        hintStyle: textTheme.bodyMedium?.copyWith(color: textMuted),
        labelStyle: textTheme.bodyMedium?.copyWith(color: textSecondary),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: space4,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: primary, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: error, width: 1.4),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: border),
        ),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: primarySoft,
        height: 74,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return textTheme.labelMedium?.copyWith(color: textPrimary);
          }
          return textTheme.labelMedium?.copyWith(color: textMuted);
        }),
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primary,
        circularTrackColor: surfaceAlt,
        linearTrackColor: surfaceAlt,
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return isDark ? textMuted : Colors.white;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primarySoft;
          return surfaceAlt;
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primarySoft;
          return border;
        }),
      ),

      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: space4,
          vertical: 4,
        ),
        iconColor: textSecondary,
        textColor: textPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
      ),

      popupMenuTheme: PopupMenuThemeData(
        color: surfaceElevated,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          side: BorderSide(color: border),
        ),
        textStyle: textTheme.bodyMedium?.copyWith(color: textPrimary),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: surfaceElevated,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
        ),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surfaceElevated,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(radiusXl)),
        ),
      ),
    );
  }

  // Backward-compatible getters for older widgets.
  static Color get background => _darkBg;
  static Color get surface => _darkSurface;
  static Color get surfaceAlt => _darkSurfaceAlt;
  static Color get surfaceElevated => _darkSurfaceElevated;
  static Color get primary => _darkPrimary;
  static Color get primarySoft => _darkPrimarySoft;
  static Color get secondary => _darkSecondary;
  static Color get textPrimary => _darkTextPrimary;
  static Color get textSecondary => _darkTextSecondary;
  static Color get textMuted => _darkTextMuted;
  static Color get border => _darkBorder;
  static Color get success => _darkSuccess;
  static Color get warning => _darkWarning;
  static Color get error => _darkError;
}

extension AppThemeSurfaceX on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  ColorScheme get colors => Theme.of(this).colorScheme;

  LinearGradient get premiumCardGradient {
    if (isDarkMode) {
      return const LinearGradient(
        colors: [
          Color(0xFF101725),
          Color(0xFF162033),
          Color(0xFF0E1524),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }

    return const LinearGradient(
      colors: [
        Color(0xFFF8FBFF),
        Color(0xFFEFF6FD),
        Color(0xFFE4EEF8),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  LinearGradient get accentCardGradient {
    if (isDarkMode) {
      return const LinearGradient(
        colors: [
          Color(0xFF131C2D),
          Color(0xFF1A2640),
          Color(0xFF111A2B),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }

    return const LinearGradient(
      colors: [
        Color(0xFFF8FCFF),
        Color(0xFFEAF4FF),
        Color(0xFFE3F3F1),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  LinearGradient get actionCardGradient {
    if (isDarkMode) {
      return const LinearGradient(
        colors: [
          Color(0xFF1A2140),
          Color(0xFF232C56),
          Color(0xFF141D32),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }

    return const LinearGradient(
      colors: [
        Color(0xFFEDF3FF),
        Color(0xFFE6F1FF),
        Color(0xFFE6F6F3),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  Color get softCardColor {
    if (isDarkMode) {
      return const Color(0xFF101725);
    }
    return const Color(0xFFF6FAFE);
  }

  Color get elevatedCardColor {
    if (isDarkMode) {
      return const Color(0xFF1A2438);
    }
    return const Color(0xFFF6FAFE);
  }

  Color get subtleBorderColor {
    if (isDarkMode) {
      return const Color(0xFF2A3550);
    }
    return const Color(0xFFCBD8E8);
  }

  Color get premiumAccentColor {
    if (isDarkMode) {
      return const Color(0xFF9AA7FF);
    }
    return const Color(0xFF5364F6);
  }

  Color get warmAccentColor {
    if (isDarkMode) {
      return const Color(0xFF31D6C6);
    }
    return const Color(0xFF0D9488);
  }
}