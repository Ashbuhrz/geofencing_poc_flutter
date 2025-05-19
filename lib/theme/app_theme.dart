import 'package:flutter/material.dart';
import 'package:geofencingpoc/theme/app_colors.dart';

/// A class that provides theme data for the application.
class AppTheme {
  /// Returns the light theme data for the application.
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.scaffoldBackground,
      
      // Color scheme
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: AppColors.white,
        secondary: AppColors.secondary,
        onSecondary: AppColors.white,
        tertiary: AppColors.primaryLight,
        onTertiary: AppColors.black,
        error: AppColors.error,
        onError: AppColors.white,
        surface: AppColors.cardBackground,
        onSurface: AppColors.black,
      ),
      
      // AppBar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
      ),
      
      // Card theme
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: AppColors.cardBackground,
      ),
      
      // Button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 2,
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      
      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.lightGrey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.lightGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
      ),
      
      // Text theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: AppColors.black, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(color: AppColors.black, fontWeight: FontWeight.bold),
        displaySmall: TextStyle(color: AppColors.black, fontWeight: FontWeight.bold),
        headlineLarge: TextStyle(color: AppColors.black, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: AppColors.black, fontWeight: FontWeight.bold),
        headlineSmall: TextStyle(color: AppColors.black, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(color: AppColors.black, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: AppColors.black, fontWeight: FontWeight.w600),
        titleSmall: TextStyle(color: AppColors.black, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: AppColors.black),
        bodyMedium: TextStyle(color: AppColors.black),
        bodySmall: TextStyle(color: AppColors.grey),
        labelLarge: TextStyle(color: AppColors.black, fontWeight: FontWeight.w500),
        labelMedium: TextStyle(color: AppColors.black, fontWeight: FontWeight.w500),
        labelSmall: TextStyle(color: AppColors.grey),
      ),
      
      // Divider theme
      dividerTheme: const DividerThemeData(
        color: AppColors.lightGrey,
        thickness: 1,
        space: 16,
      ),
      
      // Floating action button theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.white,
      ),
    );
  }

  /// Returns the dark theme data for the application.
  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      primaryColor: AppColors.primaryLight,
      scaffoldBackgroundColor: AppColors.black,
      
      // Color scheme
      colorScheme: ColorScheme(
        brightness: Brightness.dark,
        primary: AppColors.primaryLight,
        onPrimary: AppColors.black,
        secondary: AppColors.secondaryLight,
        onSecondary: AppColors.black,
        tertiary: AppColors.primary,
        onTertiary: AppColors.white,
        error: AppColors.error,
        onError: AppColors.white,
        surface: AppColors.darkGrey,
        onSurface: AppColors.white,
      ),
      
      // AppBar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.black,
        foregroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
      ),
      
      // Card theme
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: AppColors.darkGrey,
      ),
      
      // Button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondaryLight,
          foregroundColor: AppColors.black,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 2,
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryLight,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryLight,
          side: const BorderSide(color: AppColors.primaryLight),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      
      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkGrey,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
      ),
      
      // Text theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        displaySmall: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        headlineLarge: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        headlineSmall: TextStyle(color: AppColors.white, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(color: AppColors.white, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: AppColors.white, fontWeight: FontWeight.w600),
        titleSmall: TextStyle(color: AppColors.white, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: AppColors.white),
        bodyMedium: TextStyle(color: AppColors.white),
        bodySmall: TextStyle(color: AppColors.lightGrey),
        labelLarge: TextStyle(color: AppColors.white, fontWeight: FontWeight.w500),
        labelMedium: TextStyle(color: AppColors.white, fontWeight: FontWeight.w500),
        labelSmall: TextStyle(color: AppColors.lightGrey),
      ),
      
      // Divider theme
      dividerTheme: const DividerThemeData(
        color: AppColors.grey,
        thickness: 1,
        space: 16,
      ),
      
      // Floating action button theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.secondaryLight,
        foregroundColor: AppColors.black,
      ),
    );
  }
}
