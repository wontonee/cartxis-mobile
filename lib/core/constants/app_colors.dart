import 'package:flutter/material.dart';

/// App color palette based on the design system
class AppColors {
  AppColors._();

  // Primary Colors
  static const Color primary = Color(0xFF137FEC);
  static const Color primaryDark = Color(0xFF0C62B8);
  static const Color primaryLight = Color(0xFF3B9BFF);

  // Background Colors
  static const Color backgroundLight = Color(0xFFF6F7F8);
  static const Color backgroundDark = Color(0xFF101922);

  // Surface Colors
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF2A1A1A);

  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFF9E9E9E);
  static const Color textInverse = Color(0xFFFFFFFF);

  // Border Colors
  static const Color borderLight = Color(0xFFE0E0E0);
  static const Color borderDark = Color(0xFF402020);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);

  // Rating Colors
  static const Color starColor = Color(0xFFFFC107);

  // Gradient Colors (for splash screen)
  static const List<Color> primaryGradient = [
    primary,
    primaryDark,
  ];

  // Dark mode colors
  static const Color darkText = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkDivider = Color(0xFF334155);
}
