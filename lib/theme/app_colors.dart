import 'package:flutter/material.dart';

class AppColors {
  // Brand
  static const saffron = Color(0xFFFF6B00);
  static const teal = Color(0xFF009688);
  static const deepPurple = Color(0xFF7B1FA2);
  
  // Light Mode
  static const lightBackground = Color(0xFFF8F9FA);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightOnSurface = Color(0xFF1A1A1A);
  static const lightSurfaceVariant = Color(0xFFF0F0F0);
  static const lightOutline = Color(0xFFE0E0E0);
  
  // Dark Mode
  static const darkBackground = Color(0xFF121212);
  static const darkSurface = Color(0xFF1E1E1E);
  static const darkOnSurface = Color(0xFFE8E8E8);
  static const darkSurfaceVariant = Color(0xFF2C2C2C);
  static const darkOutline = Color(0xFF3A3A3A);
  
  // Semantic
  static const success = Color(0xFF4CAF50);
  static const warning = Color(0xFFFFC107);
  static const error = Color(0xFFE53935);
  static const info = Color(0xFF2196F3);
  
  // Book Condition
  static const conditionNew = Color(0xFF4CAF50);     // Like New
  static const conditionGood = Color(0xFFFFC107);    // Good
  static const conditionFair = Color(0xFFFF9800);    // Fair
  
  // Transaction Status
  static const statusInitiated = Color(0xFF9E9E9E);
  static const statusConfirmed = Color(0xFF2196F3);
  static const statusHandover = Color(0xFFFF9800);
  static const statusCompleted = Color(0xFF4CAF50);
  static const statusReviewed = Color(0xFF7B1FA2);
  static const statusDisputed = Color(0xFFE53935);
  
  // Distance
  static const distanceNear = Color(0xFF4CAF50);     // ≤ 5 km
  static const distanceMedium = Color(0xFFFF9800);   // ≤ 15 km
  static const distanceFar = Color(0xFF9E9E9E);      // > 15 km
  
  // Light ColorScheme
  static ColorScheme get lightScheme => ColorScheme(
    brightness: Brightness.light,
    primary: saffron,
    onPrimary: Colors.white,
    secondary: teal,
    onSecondary: Colors.white,
    tertiary: deepPurple,
    onTertiary: Colors.white,
    error: error,
    onError: Colors.white,
    surface: lightSurface,
    onSurface: lightOnSurface,
    surfaceContainerHighest: lightSurfaceVariant,
    outline: lightOutline,
  );
  
  // Dark ColorScheme
  static ColorScheme get darkScheme => ColorScheme(
    brightness: Brightness.dark,
    primary: saffron,
    onPrimary: Colors.black,
    secondary: teal,
    onSecondary: Colors.black,
    tertiary: deepPurple,
    onTertiary: Colors.white,
    error: error,
    onError: Colors.black,
    surface: darkSurface,
    onSurface: darkOnSurface,
    surfaceContainerHighest: darkSurfaceVariant,
    outline: darkOutline,
  );
}
