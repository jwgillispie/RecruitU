import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// RecruitU Color Palette (Sports-Inspired)
class RecruitUColors {
  // Primary colors
  static const Color primary = Color(0xFF2E7D32);        // Soccer green
  static const Color primaryLight = Color(0xFF60AD5E);   // Light green
  static const Color primaryDark = Color(0xFF005005);    // Dark green
  
  // Secondary colors
  static const Color secondary = Color(0xFFFF9800);      // Orange accent
  static const Color secondaryLight = Color(0xFFFFB74D); // Light orange
  static const Color secondaryDark = Color(0xFFE65100);  // Dark orange
  
  // Neutral colors
  static const Color background = Color(0xFFFAFAFA);     // Light gray
  static const Color surface = Color(0xFFFFFFFF);        // White
  static const Color onPrimary = Color(0xFFFFFFFF);      // White text
  static const Color onSecondary = Color(0xFF000000);    // Black text
  static const Color onBackground = Color(0xFF1C1C1C);   // Dark gray text
  static const Color onSurface = Color(0xFF1C1C1C);      // Dark gray text
  
  // Status colors
  static const Color success = Color(0xFF4CAF50);        // Green
  static const Color warning = Color(0xFFFF9800);        // Orange
  static const Color error = Color(0xFFF44336);          // Red
  static const Color info = Color(0xFF2196F3);           // Blue
  
  // Match status colors
  static const Color match = Color(0xFFE91E63);          // Pink
  static const Color like = Color(0xFF4CAF50);           // Green
  static const Color pass = Color(0xFF9E9E9E);           // Gray
  static const Color superLike = Color(0xFF2196F3);      // Blue
}

/// RecruitU Theme Configuration
class RecruitUTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.white,
      colorScheme: const ColorScheme.light(
        primary: RecruitUColors.primary,
        secondary: RecruitUColors.secondary,
        surface: RecruitUColors.surface,
        background: RecruitUColors.background,
        onPrimary: RecruitUColors.onPrimary,
        onSecondary: RecruitUColors.onSecondary,
        onSurface: RecruitUColors.onSurface,
        onBackground: RecruitUColors.onBackground,
      ),
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.light().textTheme,
      ).copyWith(
        headlineLarge: GoogleFonts.poppins(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        headlineMedium: GoogleFonts.poppins(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        titleMedium: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: Colors.black87,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: Colors.black87,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: Colors.grey[600],
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.all(8),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: RecruitUColors.primary,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        labelStyle: const TextStyle(
          color: Colors.grey,
        ),
        hintStyle: TextStyle(
          color: Colors.grey[400],
        ),
        prefixIconColor: Colors.grey[600],
        suffixIconColor: Colors.grey[600],
      ),
    );
  }
  
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: RecruitUColors.primaryLight,
        secondary: RecruitUColors.secondaryLight,
        surface: Color(0xFF121212),
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: Colors.white,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        headlineLarge: GoogleFonts.poppins(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        headlineMedium: GoogleFonts.poppins(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: Colors.white,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: Colors.white,
        ),
      ),
    );
  }
}