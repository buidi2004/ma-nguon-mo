import 'package:flutter/material.dart';

import '../services/theme_service.dart';

class AppColors {
  static const darkBackground = Color(0xFF141414);
  static Color get background => ThemeService.instance.backgroundColor;
  static const surface = Color(0xFF2A2A2A);
  static const surfaceLight = Color(0xFF333333);

  /// Màu đỏ cố định Netflix nguyên bản
  static const red = Color(0xFFE50914);
  static const netflixRed = Color(0xFFE50914);

  /// Màu xanh cố định #00A2ED
  static const cyanBlue = Color(0xFF00A2ED);
  static const win11Blue = Color(0xFF00A2ED);
  static const win11LightBlue = Color(0xFF66C7F4);
  static const win11Navy = Color(0xFF010D1A);

  static const success = Color(0xFF2E7D32);
  static const warning = Color(0xFFFFAB00);
  static const info = Color(0xFF2196F3);
  static const blue = Color(0xFF2196F3);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFB3B3B3);
  static const textMuted = Color(0xFF808080);
  static const divider = Color(0xFF2A2A2A);
  static const cardDark = Color(0xFF1E1E1E);

  /// Nền tối sâu khi chọn theme xanh đen (Đen nhiều hơn xanh)
  static const darkBlueBackground = Color(0xFF0B0F17);
  static const darkBlueSurface = Color(0xFF161F2E);
  static const darkBlueCard = Color(0xFF111827);

  /// Getter động theo ThemeService khi dùng ngữ cảnh động
  static Color get primary => ThemeService.instance.primaryColor;
  static Color get dynamicPrimary => ThemeService.instance.primaryColor;
  static Color get dynamicBackground => ThemeService.instance.backgroundColor;
  static Color get dynamicSurface => ThemeService.instance.surfaceColor;
  static Color get dynamicCardDark => ThemeService.instance.cardColor;
  static Color get dynamicTextPrimary => ThemeService.instance.textPrimary;
  static Color get dynamicTextSecondary => ThemeService.instance.textSecondary;
  static Color get dynamicTextMuted => ThemeService.instance.textMuted;
}

class AppTheme {
  static Color get background => AppColors.background;
  static Color get surface => AppColors.surface;
  static Color get cardBackground => AppColors.cardDark;
  static Color get surfaceLight => AppColors.surfaceLight;
  static const netflixRed = AppColors.netflixRed;
  static const red = AppColors.red;
  static const win11Blue = AppColors.win11Blue;
  static const win11LightBlue = AppColors.win11LightBlue;
  static const info = AppColors.info;
  static const blue = AppColors.blue;
  static Color get textPrimary => AppColors.textPrimary;
  static Color get textSecondary => AppColors.textSecondary;
  static Color get textMuted => AppColors.textMuted;
  static Color get divider => AppColors.divider;
  static Color get cardDark => AppColors.cardDark;
}

ThemeData buildAppTheme([Color? primaryOverride, bool isLight = false]) {
  final primary = primaryOverride ?? ThemeService.instance.primaryColor;
  final bg = ThemeService.instance.backgroundColor;
  final surface = ThemeService.instance.surfaceColor;

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bg,
    colorScheme: ColorScheme.dark(
      primary: primary,
      surface: surface,
      onSurface: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: bg,
      indicatorColor: Colors.transparent,
      iconTheme: WidgetStateProperty.resolveWith(
        (s) => IconThemeData(
          color: s.contains(WidgetState.selected)
              ? primary
              : const Color(0xFF808080),
        ),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (s) => TextStyle(
          fontSize: 11,
          color: s.contains(WidgetState.selected)
              ? primary
              : const Color(0xFF808080),
        ),
      ),
    ),
  );
}
