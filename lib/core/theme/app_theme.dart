import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  const AppTheme._();

  static const Color _bg = Color(0xFF0B1020);
  static const Color _surface = Color(0xFF121A2B);
  static const Color _surfaceAlt = Color(0xFF182235);
  static const Color _surfaceElevated = Color(0xFF1D2940);

  static const Color _primary = Color(0xFF7C9BFF);
  static const Color _primarySoft = Color(0xFF2A3D73);
  static const Color _secondary = Color(0xFF5EEAD4);

  static const Color _textPrimary = Color(0xFFF3F7FF);
  static const Color _textSecondary = Color(0xFFB5C0D4);
  static const Color _textMuted = Color(0xFF8090AA);

  static const Color _border = Color(0xFF25314A);
  static const Color _success = Color(0xFF34D399);
  static const Color _warning = Color(0xFFFBBF24);
  static const Color _error = Color(0xFFF87171);

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

  static ThemeData _buildDarkTheme() {
    final baseTextTheme = GoogleFonts.interTextTheme().copyWith(
      displayLarge: GoogleFonts.inter(
        fontSize: 40,
        height: 1.08,
        fontWeight: FontWeight.w700,
        color: _textPrimary,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: 32,
        height: 1.12,
        fontWeight: FontWeight.w700,
        color: _textPrimary,
      ),
      displaySmall: GoogleFonts.inter(
        fontSize: 28,
        height: 1.15,
        fontWeight: FontWeight.w700,
        color: _textPrimary,
      ),
      headlineLarge: GoogleFonts.inter(
        fontSize: 24,
        height: 1.2,
        fontWeight: FontWeight.w700,
        color: _textPrimary,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 22,
        height: 1.24,
        fontWeight: FontWeight.w700,
        color: _textPrimary,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 20,
        height: 1.28,
        fontWeight: FontWeight.w700,
        color: _textPrimary,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 18,
        height: 1.3,
        fontWeight: FontWeight.w700,
        color: _textPrimary,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        height: 1.35,
        fontWeight: FontWeight.w600,
        color: _textPrimary,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 14,
        height: 1.35,
        fontWeight: FontWeight.w600,
        color: _textPrimary,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        height: 1.5,
        fontWeight: FontWeight.w400,
        color: _textPrimary,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        height: 1.5,
        fontWeight: FontWeight.w400,
        color: _textSecondary,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        height: 1.45,
        fontWeight: FontWeight.w400,
        color: _textMuted,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        height: 1.2,
        fontWeight: FontWeight.w600,
        color: _textPrimary,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        height: 1.2,
        fontWeight: FontWeight.w600,
        color: _textSecondary,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        height: 1.2,
        fontWeight: FontWeight.w600,
        color: _textMuted,
      ),
    );

    final colorScheme = const ColorScheme.dark(
      brightness: Brightness.dark,
      primary: _primary,
      onPrimary: Colors.white,
      secondary: _secondary,
      onSecondary: Color(0xFF07131C),
      error: _error,
      onError: Colors.white,
      surface: _surface,
      onSurface: _textPrimary,
      outline: _border,
      outlineVariant: Color(0xFF1E2940),
      scrim: Colors.black,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _bg,
      canvasColor: _bg,
      splashFactory: InkSparkle.splashFactory,
      textTheme: baseTextTheme,
      dividerColor: _border,
      disabledColor: _textMuted,
      cardColor: _surface,
      shadowColor: Colors.black.withValues(alpha: 0.28),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: _textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: baseTextTheme.titleLarge,
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: _surfaceElevated,
        contentTextStyle: baseTextTheme.bodyMedium?.copyWith(
          color: _textPrimary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          side: const BorderSide(color: _border),
        ),
      ),
      cardTheme: CardThemeData(
        color: _surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          side: const BorderSide(color: _border),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: _border,
        thickness: 1,
        space: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: _surfaceAlt,
        selectedColor: _primarySoft,
        disabledColor: _surface,
        side: const BorderSide(color: _border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        labelStyle: baseTextTheme.labelMedium!.copyWith(color: _textSecondary),
        secondaryLabelStyle: baseTextTheme.labelMedium!.copyWith(
          color: _textPrimary,
        ),
        padding: const EdgeInsets.symmetric(horizontal: space3, vertical: 10),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: _surfaceAlt,
          disabledForegroundColor: _textMuted,
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: space5, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: baseTextTheme.labelLarge,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: space5, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: baseTextTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _textPrimary,
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: space5, vertical: 14),
          side: const BorderSide(color: _border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: baseTextTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _primary,
          textStyle: baseTextTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSm),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surface,
        hintStyle: baseTextTheme.bodyMedium?.copyWith(color: _textMuted),
        labelStyle: baseTextTheme.bodyMedium?.copyWith(color: _textSecondary),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: space4,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: _border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: _primary, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: _error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: _error, width: 1.4),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: _border),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: _surface,
        selectedItemColor: _primary,
        unselectedItemColor: _textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: _surface,
        indicatorColor: _primarySoft,
        height: 74,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return baseTextTheme.labelMedium?.copyWith(color: _textPrimary);
          }
          return baseTextTheme.labelMedium?.copyWith(color: _textMuted);
        }),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: _primary,
        circularTrackColor: _surfaceAlt,
        linearTrackColor: _surfaceAlt,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return _primary;
          return _textMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return _primarySoft;
          return _surfaceAlt;
        }),
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: space4,
          vertical: 4,
        ),
        iconColor: _textSecondary,
        textColor: _textPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
      ),
    );
  }

  static Color get background => _bg;
  static Color get surface => _surface;
  static Color get surfaceAlt => _surfaceAlt;
  static Color get surfaceElevated => _surfaceElevated;
  static Color get primary => _primary;
  static Color get primarySoft => _primarySoft;
  static Color get secondary => _secondary;
  static Color get textPrimary => _textPrimary;
  static Color get textSecondary => _textSecondary;
  static Color get textMuted => _textMuted;
  static Color get border => _border;
  static Color get success => _success;
  static Color get warning => _warning;
  static Color get error => _error;
}
