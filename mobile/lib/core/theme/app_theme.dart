import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'typography.dart';

/// Application Theme Configuration
/// Provides Light and Dark theme configurations using ColorScheme & TextTheme
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  static const ColorScheme _lightColorScheme = ColorScheme.light(
    primary: AppColors.primary,
    onPrimary: AppColors.white,
    secondary: AppColors.secondary,
    onSecondary: AppColors.white,
    surface: AppColors.white,
    surfaceContainerLow: AppColors.primaryLight,
    onSurface: AppColors.textMain,
    onSurfaceVariant: AppColors.textSub,
    outlineVariant: AppColors.borderLight,
    error: AppColors.danger,
    onError: AppColors.white,
  );

  static const ColorScheme _darkColorScheme = ColorScheme.dark(
    primary: AppColors.primary,
    onPrimary: AppColors.white,
    secondary: Color(0xFF94A3B8),
    onSecondary: AppColors.white,
    surface: Color(0xFF1E293B),
    surfaceContainerLow: AppColors.primaryDark,
    onSurface: Color(0xFFF8FAFC),
    onSurfaceVariant: Color(0xFF94A3B8),
    outlineVariant: AppColors.borderDark,
    error: AppColors.dangerLight,
    onError: AppColors.white,
  );

  static TextTheme _buildTextTheme(ColorScheme colorScheme) {
    return TextTheme(
      displayLarge: AppTypography.h1.copyWith(color: colorScheme.onSurface),
      displayMedium: AppTypography.h2.copyWith(color: colorScheme.onSurface),
      displaySmall: AppTypography.h3.copyWith(color: colorScheme.onSurface),
      headlineMedium: AppTypography.h4.copyWith(color: colorScheme.onSurface),
      headlineSmall: AppTypography.h5.copyWith(color: colorScheme.onSurface),
      titleLarge: AppTypography.h6.copyWith(color: colorScheme.onSurface),
      bodyLarge: AppTypography.bodyLarge.copyWith(color: colorScheme.onSurface),
      bodyMedium: AppTypography.bodyMedium.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
      bodySmall: AppTypography.bodySmall.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
      labelLarge: AppTypography.labelLarge.copyWith(color: colorScheme.onSurface),
      labelMedium: AppTypography.labelMedium.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
      labelSmall: AppTypography.labelSmall.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }

  static InputDecorationTheme _buildInputDecorationTheme(
    ColorScheme colorScheme,
  ) {
    return InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.surface,
      hintStyle: TextStyle(
        color: colorScheme.onSurfaceVariant,
        fontSize: 12,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.error, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
    );
  }

  /// Light Theme Configuration
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      colorScheme: _lightColorScheme,

      // AppBar Theme
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.backgroundLight,
        foregroundColor: _lightColorScheme.onSurface,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: AppTypography.h2.copyWith(
          color: _lightColorScheme.onSurface,
        ),
      ),

      // Text Theme
      textTheme: _buildTextTheme(_lightColorScheme),

      // Input Decoration Theme
      inputDecorationTheme: _buildInputDecorationTheme(_lightColorScheme),

      // Card Theme
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: _lightColorScheme.surface,
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _lightColorScheme.primary,
          foregroundColor: AppColors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: AppTypography.button,
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _lightColorScheme.primary,
          textStyle: AppTypography.button,
        ),
      ),

      // Icon Theme
      iconTheme: IconThemeData(
        color: _lightColorScheme.onSurface,
        size: 24,
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: _lightColorScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
    );
  }

  /// Dark Theme Configuration
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: const Color(0xFF0B1120),
      colorScheme: _darkColorScheme,

      // AppBar Theme
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: const Color(0xFF0B1120),
        foregroundColor: _darkColorScheme.onSurface,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: AppTypography.h2.copyWith(
          color: _darkColorScheme.onSurface,
        ),
      ),

      // Text Theme
      textTheme: _buildTextTheme(_darkColorScheme),

      // Input Decoration Theme
      inputDecorationTheme: _buildInputDecorationTheme(_darkColorScheme),

      // Card Theme
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: _darkColorScheme.surface,
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _darkColorScheme.primary,
          foregroundColor: AppColors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: AppTypography.button,
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _darkColorScheme.primary,
          textStyle: AppTypography.button,
        ),
      ),

      // Icon Theme
      iconTheme: IconThemeData(
        color: _darkColorScheme.onSurface,
        size: 24,
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: _darkColorScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
