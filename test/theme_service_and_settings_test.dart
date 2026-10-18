import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openflix/features/account/settings_screen.dart';
import 'package:openflix/presentation/widgets/glass/silk_background.dart';
import 'package:openflix/services/theme_service.dart';
import 'package:openflix/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _buildWrapper(Widget child) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: buildAppTheme(ThemeService.instance.primaryColor),
    home: child,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await ThemeService.instance.setThemeMode(AppThemeMode.netflixRed);
  });

  group('ThemeService Tests', () {
    test('Defaults to Netflix Red palette', () {
      expect(ThemeService.instance.mode, equals(AppThemeMode.netflixRed));
      expect(ThemeService.instance.isNetflixRed, isTrue);
      expect(ThemeService.instance.isWindowsBlue, isFalse);
      expect(ThemeService.instance.shaderThemeValue, equals(0.0));
      expect(ThemeService.instance.primaryColor, equals(AppColors.red));
      expect(ThemeService.instance.name, contains('Đỏ Netflix'));
    });

    test('Can switch to Cyan Blue (#00A2ED) & White palette', () async {
      await ThemeService.instance.setThemeMode(AppThemeMode.windowsBlue);

      expect(ThemeService.instance.mode, equals(AppThemeMode.windowsBlue));
      expect(ThemeService.instance.isWindowsBlue, isTrue);
      expect(ThemeService.instance.isNetflixRed, isFalse);
      expect(ThemeService.instance.shaderThemeValue, equals(1.0));
      expect(ThemeService.instance.primaryColor, equals(const Color(0xFF00A2ED)));
      expect(AppColors.primary, equals(const Color(0xFF00A2ED))); // All components adapt to #00A2ED!
      expect(ThemeService.instance.name, contains('#00A2ED'));
    });

    test('Toggles back to Netflix Red', () async {
      await ThemeService.instance.setThemeMode(AppThemeMode.windowsBlue);
      await ThemeService.instance.toggleTheme();
      expect(ThemeService.instance.isNetflixRed, isTrue);
      expect(AppColors.primary, equals(const Color(0xFFE50914))); // All components return to #E50914!
    });
  });

  group('SilkBackground Dual Theme Tests', () {
    testWidgets('Renders SilkBackground with Netflix Red (default)', (tester) async {
      await tester.pumpWidget(
        _buildWrapper(
          const SizedBox(
            width: 300,
            height: 300,
            child: SilkBackground(themeMode: AppThemeMode.netflixRed),
          ),
        ),
      );
      expect(find.byType(SilkBackground), findsOneWidget);
    });

    testWidgets('Renders SilkBackground with Cyan Blue #00A2ED', (tester) async {
      await tester.pumpWidget(
        _buildWrapper(
          const SizedBox(
            width: 300,
            height: 300,
            child: SilkBackground(themeMode: AppThemeMode.windowsBlue),
          ),
        ),
      );
      expect(find.byType(SilkBackground), findsOneWidget);
    });
  });

  group('SettingsScreen Theme Customization Tests', () {
    testWidgets('Displays Theme Option tile and opens selection modal', (tester) async {
      await tester.pumpWidget(_buildWrapper(const SettingsScreen()));

      expect(find.text('Màu sắc giao diện & Sóng lụa Silk'), findsOneWidget);
      expect(find.text(ThemeService.instance.name), findsOneWidget);

      // Tap to open theme bottom sheet
      await tester.tap(find.text('Màu sắc giao diện & Sóng lụa Silk'));
      await tester.pumpAndSettle();

      expect(find.text('Màu sắc ứng dụng & Sóng lụa Silk'), findsOneWidget);
      expect(find.text('Đỏ Netflix (Mặc định)'), findsNWidgets(2));
      expect(find.text('Xanh Hiện Đại (#00A2ED) & Trắng Mờ'), findsOneWidget);

      // Select Cyan Blue #00A2ED
      await tester.tap(find.text('Xanh Hiện Đại (#00A2ED) & Trắng Mờ'));
      await tester.pumpAndSettle();

      expect(ThemeService.instance.isWindowsBlue, isTrue);
      expect(find.text('Xanh Hiện Đại (#00A2ED) & Trắng Mờ'), findsOneWidget);
    });
  });
}
