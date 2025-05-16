import 'package:flutter/material.dart';

/// A class that defines the color palette for the application.
/// Using a more professional color scheme with primary, secondary and neutral colors.
class AppColors {
  // Primary Colors
  static const Color primaryDark = Color(0xFF1E3A8A); // Dark blue
  static const Color primary = Color(0xFF2563EB); // Medium blue
  static const Color primaryLight = Color(0xFF93C5FD); // Light blue

  // Secondary/Accent Colors
  static const Color secondary = Color(0xFFF59E0B); // Amber
  static const Color secondaryLight = Color(0xFFFCD34D); // Light amber
  static const Color secondaryDark = Color(0xFFB45309); // Dark amber

  // Neutral Colors
  static const Color black = Color(
    0xFF111827,
  ); // Not pure black for better readability
  static const Color darkGrey = Color(0xFF374151);
  static const Color grey = Color(0xFF6B7280);
  static const Color lightGrey = Color(0xFFE5E7EB);
  static const Color white = Color(
    0xFFFAFAFA,
  ); // Off-white for better eye comfort

  // Semantic Colors
  static const Color success = Color(0xFF10B981); // Green
  static const Color error = Color(0xFFEF4444); // Red
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color info = Color(0xFF3B82F6); // Blue

  // Background Colors
  static const Color background = Color(0xFFF9FAFB);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color scaffoldBackground = Color(0xFFF9FAFB);

  static const Color divider = Color(0xFFE5E7EB);
}
