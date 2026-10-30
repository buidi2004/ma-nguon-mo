import 'package:flutter/material.dart';

import '../services/theme_service.dart';
import 'app_typography.dart';

class AppColors {
  static const darkBackground = Color(0xFF141414);
  static Color get background => ThemeService.instance.scaffoldBackgroundColor;
  static Color get scaffoldBackground =>
      ThemeService.instance.scaffoldBackgroundColor;
  static Color get surface => ThemeService.instance.surfaceColor;
  static Color get surfaceLight => ThemeService.instance.surfaceLightColor;

  /// Màu đỏ cố định Netflix nguyên bản
  static const red = Color(0xFFE50914);
  static const netflixRed = Color(0xFFE50914);

  /// Màu xanh cố định #00A2ED
  static const cyanBlue = Color(0xFF00A2ED);
  static const win11Blue = Color(0xFF00A2ED);
  static const win11LightBlue = Color(0xFF66C7F4);
  static const win11Navy = Color(0xFF010D1A);

  /// Màu vàng hoàng gia Dark Luxury (#D4AF37)
  static const gold = Color(0xFFD4AF37);
  static const luxuryGold = Color(0xFFD4AF37);
  static const goldLight = Color(0xFFF1D48B);
  static const goldDark = Color(0xFF6D4A18);

  static const success = Color(0xFF2E7D32);
  static const warning = Color(0xFFFFAB00);
  static const info = Color(0xFF2196F3);
  static const blue = Color(0xFF2196F3);
  static Color get textPrimary => ThemeService.instance.textPrimary;
  static Color get textSecondary => ThemeService.instance.textSecondary;
  static Color get textMuted => ThemeService.instance.textMuted;
  static Color get divider => ThemeService.instance.dividerColor;
  static Color get cardDark => ThemeService.instance.cardColor;

  /// Nền tối sâu khi chọn theme xanh đen (Đen nhiều hơn xanh)
  static Color get darkBlueBackground => ThemeService.instance.backgroundColor;
  static Color get darkBlueSurface => ThemeService.instance.surfaceColor;
  static Color get darkBlueCard => ThemeService.instance.cardColor;

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

/// Light palette scoped to the phone home screen in the blue theme.
class HomeScreenPalette extends ThemeExtension<HomeScreenPalette> {
  final Color background;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color divider;
  final Color action;

  const HomeScreenPalette({
    this.background = Colors.transparent,
    this.surface = const Color(0xE608202E),
    this.textPrimary = Colors.white,
    this.textSecondary = const Color(0xFFE2F1FF),
    this.textMuted = const Color(0xFFB8D4E8),
    this.divider = const Color(0x4D5AD2F4),
    this.action = const Color(0xFF5AD2F4),
  });

  static const lightBlue = HomeScreenPalette();

  @override
  HomeScreenPalette copyWith({
    Color? background,
    Color? surface,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? divider,
    Color? action,
  }) => HomeScreenPalette(
    background: background ?? this.background,
    surface: surface ?? this.surface,
    textPrimary: textPrimary ?? this.textPrimary,
    textSecondary: textSecondary ?? this.textSecondary,
    textMuted: textMuted ?? this.textMuted,
    divider: divider ?? this.divider,
    action: action ?? this.action,
  );

  @override
  HomeScreenPalette lerp(covariant HomeScreenPalette? other, double t) => this;
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
  static const gold = AppColors.gold;
  static const luxuryGold = AppColors.luxuryGold;
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

  final onSurfaceText = isLight ? const Color(0xFF14212B) : Colors.white;

  return ThemeData(
    useMaterial3: true,
    brightness: isLight ? Brightness.light : Brightness.dark,
    scaffoldBackgroundColor: bg,
    // Thang chữ chuẩn Apple iOS (HIG Typography) thay cho fontSize rời rạc.
    textTheme: AppTypography.applyTo(ThemeData.dark().textTheme, onSurfaceText),
    colorScheme: isLight
        ? ColorScheme.light(
            primary: const Color(0xFF006B9F),
            surface: surface,
            onSurface: const Color(0xFF14212B),
          )
        : ColorScheme.dark(
            primary: primary,
            surface: surface,
            onSurface: Colors.white,
          ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      iconTheme: IconThemeData(
        color: isLight ? const Color(0xFF14212B) : Colors.white,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: bg,
      indicatorColor: Colors.transparent,
      iconTheme: WidgetStateProperty.resolveWith(
        (s) => IconThemeData(
          color: s.contains(WidgetState.selected)
              ? (isLight ? const Color(0xFF006B9F) : primary)
              : (isLight ? const Color(0xFF526575) : const Color(0xFF808080)),
        ),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (s) => AppTypography.caption2.copyWith(
          color: s.contains(WidgetState.selected)
              ? (isLight ? const Color(0xFF006B9F) : primary)
              : (isLight ? const Color(0xFF526575) : const Color(0xFF808080)),
        ),
      ),
    ),
  );
}
