import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openflix/presentation/widgets/floating_glass_bottom_bar.dart';
import 'package:openflix/services/theme_service.dart';
import 'package:openflix/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Dynamic Theme & Frosted White Background Tests', () {
    test('Default theme is Netflix Red (#E50914) with Dark Cinema (#141414) background', () async {
      await ThemeService.instance.setThemeMode(AppThemeMode.netflixRed);

      expect(ThemeService.instance.isNetflixRed, isTrue);
      expect(ThemeService.instance.isWindowsBlue, isFalse);
      expect(ThemeService.instance.isLight, isFalse);

      // Màu đỏ thương hiệu cố định và động
      expect(ThemeService.instance.primaryColor, const Color(0xFFE50914));
      expect(AppColors.dynamicPrimary, const Color(0xFFE50914));

      // Nền tối và chữ trắng
      expect(ThemeService.instance.backgroundColor, const Color(0xFF141414));
      expect(ThemeService.instance.surfaceColor, const Color(0xFF2A2A2A));
      expect(ThemeService.instance.textPrimary, const Color(0xFFFFFFFF));
      expect(ThemeService.instance.textSecondary, const Color(0xFFB3B3B3));

      // ThemeData
      final themeData = buildAppTheme(
        ThemeService.instance.primaryColor,
        ThemeService.instance.isLight,
      );
      expect(themeData.brightness, Brightness.dark);
      expect(themeData.scaffoldBackgroundColor, const Color(0xFF141414));
      expect(themeData.colorScheme.primary, const Color(0xFFE50914));
    });

    test('Switching to Blue Theme changes ALL red to #00A2ED and background to Deep Cinema Black (#0B0F17)', () async {
      await ThemeService.instance.setThemeMode(AppThemeMode.windowsBlue);

      expect(ThemeService.instance.isWindowsBlue, isTrue);
      expect(ThemeService.instance.isNetflixRed, isFalse);
      expect(ThemeService.instance.isLight, isFalse); // Cả 2 đều là dark theme điện ảnh

      // 1. Tất cả màu đỏ chuyển thành màu xanh #00A2ED
      expect(ThemeService.instance.primaryColor, const Color(0xFF00A2ED));
      expect(AppColors.dynamicPrimary, const Color(0xFF00A2ED));

      // 2. Nền là màu đen sâu điện ảnh (#0B0F17), đen nhiều hơn xanh
      expect(ThemeService.instance.backgroundColor, const Color(0xFF0B0F17));
      expect(AppColors.dynamicBackground, const Color(0xFF0B0F17));
      expect(AppColors.darkBlueBackground, const Color(0xFF0B0F17));
      expect(ThemeService.instance.surfaceColor, const Color(0xFF161F2E));
      expect(ThemeService.instance.cardColor, const Color(0xFF111827));

      // 3. Chữ luôn trắng sáng trên nền đen điện ảnh
      expect(ThemeService.instance.textPrimary, const Color(0xFFFFFFFF));
      expect(ThemeService.instance.textSecondary, const Color(0xFF94A3B8));
      expect(ThemeService.instance.textMuted, const Color(0xFF64748B));
      expect(ThemeService.instance.dividerColor, const Color(0xFF1E293B));

      // 4. ThemeData là Dark Mode với primary #00A2ED và nền đen sâu #0B0F17
      final themeData = buildAppTheme(
        ThemeService.instance.primaryColor,
        ThemeService.instance.isLight,
      );
      expect(themeData.brightness, Brightness.dark);
      expect(themeData.scaffoldBackgroundColor, const Color(0xFF0B0F17));
      expect(themeData.colorScheme.primary, const Color(0xFF00A2ED));
      expect(themeData.colorScheme.surface, const Color(0xFF161F2E));
      expect(themeData.colorScheme.onSurface, Colors.white);
    });

    test('Switching back and forth seamlessly preserves integrity', () async {
      // Chuyển sang xanh đen #00A2ED
      await ThemeService.instance.setThemeMode(AppThemeMode.windowsBlue);
      expect(ThemeService.instance.primaryColor, const Color(0xFF00A2ED));
      expect(ThemeService.instance.backgroundColor, const Color(0xFF0B0F17));

      // Quay lại đỏ Netflix
      await ThemeService.instance.setThemeMode(AppThemeMode.netflixRed);
      expect(ThemeService.instance.primaryColor, const Color(0xFFE50914));
      expect(ThemeService.instance.backgroundColor, const Color(0xFF141414));
    });

    testWidgets('FloatingGlassBottomBar reflects cyan blue gradient when windowsBlue is selected', (tester) async {
      await ThemeService.instance.setThemeMode(AppThemeMode.windowsBlue);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                FloatingGlassBottomBar(
                  selectedIndex: 0,
                  onTabSelected: (_) {},
                  onQuickActionPressed: () {},
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(FloatingGlassBottomBar), findsOneWidget);
      expect(ThemeService.instance.isWindowsBlue, isTrue);

      // Verify the active pill gradient uses cyan blue palette
      final containers = tester.widgetList<Container>(find.byType(Container));
      final pillContainer = containers.firstWhere(
        (c) {
          final dec = c.decoration;
          if (dec is BoxDecoration && dec.gradient is LinearGradient) {
            final grad = dec.gradient as LinearGradient;
            return grad.colors.contains(const Color(0xFF00A2ED));
          }
          return false;
        },
      );
      final boxDec = pillContainer.decoration as BoxDecoration;
      final grad = boxDec.gradient as LinearGradient;
      expect(grad.colors, const [Color(0xFF66C7F4), Color(0xFF00A2ED)]);
    });

    testWidgets('FloatingGlassBottomBar reflects netflix red gradient when netflixRed is selected', (tester) async {
      await ThemeService.instance.setThemeMode(AppThemeMode.netflixRed);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                FloatingGlassBottomBar(
                  selectedIndex: 0,
                  onTabSelected: (_) {},
                  onQuickActionPressed: () {},
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(FloatingGlassBottomBar), findsOneWidget);
      expect(ThemeService.instance.isNetflixRed, isTrue);

      final containers = tester.widgetList<Container>(find.byType(Container));
      final pillContainer = containers.firstWhere(
        (c) {
          final dec = c.decoration;
          if (dec is BoxDecoration && dec.gradient is LinearGradient) {
            final grad = dec.gradient as LinearGradient;
            return grad.colors.contains(const Color(0xFFE50914));
          }
          return false;
        },
      );
      final boxDec = pillContainer.decoration as BoxDecoration;
      final grad = boxDec.gradient as LinearGradient;
      expect(grad.colors, const [Color(0xFFFF2E3D), Color(0xFFE50914)]);
    });

    testWidgets('FloatingGlassBottomBar reflects gold gradient when luxuryGold is selected', (tester) async {
      await ThemeService.instance.setThemeMode(AppThemeMode.luxuryGold);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                FloatingGlassBottomBar(
                  selectedIndex: 0,
                  onTabSelected: (_) {},
                  onQuickActionPressed: () {},
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(FloatingGlassBottomBar), findsOneWidget);
      expect(ThemeService.instance.isLuxuryGold, isTrue);

      final containers = tester.widgetList<Container>(find.byType(Container));
      final pillContainer = containers.firstWhere(
        (c) {
          final dec = c.decoration;
          if (dec is BoxDecoration && dec.gradient is LinearGradient) {
            final grad = dec.gradient as LinearGradient;
            return grad.colors.contains(const Color(0xFFD4AF37));
          }
          return false;
        },
      );
      final boxDec = pillContainer.decoration as BoxDecoration;
      final grad = boxDec.gradient as LinearGradient;
      expect(grad.colors, const [Color(0xFFF6E2A8), Color(0xFFD4AF37), Color(0xFF9E782F)]);
    });
  });
}
