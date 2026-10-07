import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Application Typography
/// Centralized text style definitions
class AppTypography {
  // Private constructor to prevent instantiation
  AppTypography._();

  // Base Font Family
  static String get fontFamily => GoogleFonts.inter().fontFamily!;

  // Heading Styles
  static TextStyle h1 = GoogleFonts.inter(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static TextStyle h2 = GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.3,
    height: 1.3,
  );

  static TextStyle h3 = GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.4,
  );

  static TextStyle h4 = GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
    height: 1.4,
  );

  static TextStyle h5 = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.5,
  );

  static TextStyle h6 = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.5,
  );

  // Body Text Styles
  static TextStyle bodyLarge = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.5,
    letterSpacing: 0.15,
  );

  static TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.5,
    letterSpacing: 0.25,
  );

  static TextStyle bodySmall = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.5,
    letterSpacing: 0.4,
  );

  // Button Text Style
  static TextStyle button = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  // Caption Text Style
  static TextStyle caption = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.4,
    height: 1.3,
  );

  // Overline Text Style
  static TextStyle overline = GoogleFonts.inter(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.5,
    height: 1.6,
  );

  // Label Text Styles
  static TextStyle labelLarge = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  );

  static TextStyle labelMedium = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  static TextStyle labelSmall = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );
}
