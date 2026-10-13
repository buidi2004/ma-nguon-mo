import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFF141414);
  static const surface = Color(0xFF2A2A2A);
  static const surfaceLight = Color(0xFF333333);
  static const red = Color(0xFFE50914);
  static const success = Color(0xFF2E7D32);
  static const warning = Color(0xFFFFAB00);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFB3B3B3);
  static const textMuted = Color(0xFF808080);
  static const divider = Color(0xFF2A2A2A);
  static const cardDark = Color(0xFF1E1E1E);
}

class AppTheme {
  static const background = AppColors.background;
  static const surface = AppColors.surface;
  static const cardBackground = AppColors.surface;
  static const surfaceLight = AppColors.surfaceLight;
  static const netflixRed = AppColors.red;
  static const red = AppColors.red;
  static const textPrimary = AppColors.textPrimary;
  static const textSecondary = AppColors.textSecondary;
  static const textMuted = AppColors.textMuted;
  static const divider = AppColors.divider;
  static const cardDark = AppColors.cardDark;
}

ThemeData buildAppTheme() => ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.red,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
      ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
    iconTheme: IconThemeData(color: Colors.white),
  ),
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: AppColors.background,
    indicatorColor: Colors.transparent,
    iconTheme: WidgetStateProperty.resolveWith(
      (s) => IconThemeData(
        color: s.contains(WidgetState.selected)
            ? Colors.white
            : AppColors.textMuted,
      ),
    ),
    labelTextStyle: WidgetStateProperty.resolveWith(
      (s) => TextStyle(
        fontSize: 11,
        color: s.contains(WidgetState.selected)
            ? Colors.white
            : AppColors.textMuted,
      ),
    ),
  ),
);
