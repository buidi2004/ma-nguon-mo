import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openflix/dark_luxury_background.dart';
import 'package:openflix/features/account/plans_screen.dart';
import 'package:openflix/features/account/settings_screen.dart';
import 'package:openflix/features/auth/welcome_screen.dart';
import 'package:openflix/features/cinema/cinema_hub_screen.dart';
import 'package:openflix/features/cinema/cinema_movie_detail_screen.dart';
import 'package:openflix/features/cinema/cinema_news_screen.dart';
import 'package:openflix/features/discover/filter_screen.dart';
import 'package:openflix/features/discover/genres_screen.dart';
import 'package:openflix/presentation/widgets/glass/glass_components.dart';
import 'package:openflix/services/cinema/cinema_service.dart';
import 'package:openflix/services/theme_service.dart';
import 'package:openflix/theme/app_theme.dart';
import 'package:openflix/waves_background.dart';
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

    test('Can switch to Luxury Gold (#D4AF37) palette', () async {
      await ThemeService.instance.setThemeMode(AppThemeMode.luxuryGold);

      expect(ThemeService.instance.mode, equals(AppThemeMode.luxuryGold));
      expect(ThemeService.instance.isLuxuryGold, isTrue);
      expect(ThemeService.instance.isNetflixRed, isFalse);
      expect(ThemeService.instance.isWindowsBlue, isFalse);
      expect(ThemeService.instance.primaryColor, equals(const Color(0xFFD4AF37)));
      expect(AppColors.primary, equals(const Color(0xFFD4AF37)));
      expect(ThemeService.instance.backgroundColor, equals(const Color(0xFF060504)));
      expect(ThemeService.instance.scaffoldBackgroundColor, equals(Colors.transparent));
      expect(ThemeService.instance.name, contains('Vàng Hoàng Gia Luxury'));
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

    testWidgets('Renders SilkBackground with Cyan Blue #00A2ED (WavesBackground)', (tester) async {
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
      expect(find.byType(WavesBackground), findsOneWidget);
    });

    testWidgets('Renders SilkBackground with Luxury Gold (DarkLuxuryBackground)', (tester) async {
      await tester.pumpWidget(
        _buildWrapper(
          const SizedBox(
            width: 300,
            height: 300,
            child: SilkBackground(themeMode: AppThemeMode.luxuryGold),
          ),
        ),
      );
      expect(find.byType(SilkBackground), findsOneWidget);
      expect(find.byType(DarkLuxuryBackground), findsOneWidget);
    });

    testWidgets('Renders standalone DarkLuxuryWallpaper and DarkLuxuryBackground with child', (tester) async {
      await tester.pumpWidget(
        _buildWrapper(
          const Scaffold(
            body: DarkLuxuryBackground(
              child: SafeArea(
                child: Center(
                  child: Text('Luxury Gold Text'),
                ),
              ),
            ),
          ),
        ),
      );
      expect(find.byType(DarkLuxuryBackground), findsOneWidget);
      expect(find.text('Luxury Gold Text'), findsOneWidget);
    });

    testWidgets('Renders full-screen DarkLuxuryWallpaper standalone', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DarkLuxuryWallpaper(),
        ),
      );
      expect(find.byType(DarkLuxuryWallpaper), findsOneWidget);
      expect(find.byType(DarkLuxuryBackground), findsOneWidget);
    });

    testWidgets('Renders standalone WavesBackground with child content', (tester) async {
      await tester.pumpWidget(
        _buildWrapper(
          const Scaffold(
            body: WavesBackground(
              child: SafeArea(
                child: Center(
                  child: Text('Waves'),
                ),
              ),
            ),
          ),
        ),
      );
      expect(find.byType(WavesBackground), findsOneWidget);
      expect(find.text('Waves'), findsOneWidget);
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
      expect(find.text('Vàng Hoàng Gia Luxury (Chế độ màu vàng)'), findsOneWidget);

      // Select Cyan Blue #00A2ED
      await tester.tap(find.text('Xanh Hiện Đại (#00A2ED) & Trắng Mờ'));
      await tester.pumpAndSettle();

      expect(ThemeService.instance.isWindowsBlue, isTrue);

      // Bottom sheet đã đóng sau khi chọn ⇒ nhãn lựa chọn bên trong sheet
      // KHÔNG còn tồn tại trên màn hình (trước đây test khẳng định sai điều này).
      expect(find.text('Xanh Hiện Đại (#00A2ED) & Trắng Mờ'), findsNothing);

      // Tile cài đặt phải cập nhật ngay theo theme mới: subtitle = ThemeService.name.
      expect(find.text(ThemeService.instance.name), findsOneWidget);
      expect(ThemeService.instance.name, contains('#00A2ED'));
      // Tên theme đỏ cũ không còn xuất hiện ở đâu nữa.
      expect(find.text('Đỏ Netflix (Mặc định)'), findsNothing);
      expect(find.byType(WavesBackground), findsOneWidget);
    });

    testWidgets('Selects Luxury Gold mode in SettingsScreen and switches theme', (tester) async {
      await tester.pumpWidget(_buildWrapper(const SettingsScreen()));

      // Tap to open theme bottom sheet
      await tester.tap(find.text('Màu sắc giao diện & Sóng lụa Silk'));
      await tester.pumpAndSettle();

      // Select Luxury Gold
      await tester.tap(find.text('Vàng Hoàng Gia Luxury (Chế độ màu vàng)'));
      await tester.pumpAndSettle();

      expect(ThemeService.instance.isLuxuryGold, isTrue);
      expect(find.text(ThemeService.instance.name), findsOneWidget);
      expect(ThemeService.instance.name, contains('Vàng Hoàng Gia Luxury'));
      expect(find.byType(DarkLuxuryBackground), findsOneWidget);
    });

    testWidgets('All screen groups render WavesBackground when windowsBlue is active', (tester) async {
      await ThemeService.instance.setThemeMode(AppThemeMode.windowsBlue);

      final screens = <Widget>[
        const WelcomeScreen(),
        const FilterScreen(),
        const GenresScreen(),
        const PlansScreen(),
        const CinemaHubScreen(),
        const SettingsScreen(),
      ];

      for (final screen in screens) {
        await tester.pumpWidget(_buildWrapper(screen));
        expect(
          find.byType(WavesBackground),
          findsWidgets,
          reason: '${screen.runtimeType} should render WavesBackground in blue mode',
        );
        final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
        expect(
          scaffold.backgroundColor,
          equals(Colors.transparent),
          reason: '${screen.runtimeType} Scaffold should be transparent so WavesBackground is visible',
        );
      }
    });

    testWidgets('Cinema screens and Glass controls maintain high contrast over WavesBackground in blue mode', (tester) async {
      await ThemeService.instance.setThemeMode(AppThemeMode.windowsBlue);

      final sampleMovie = CinemaService.instance.movies.first;
      await tester.pumpWidget(
        _buildWrapper(CinemaMovieDetailScreen(movieId: sampleMovie.id)),
      );

      final titleWidget = tester.widget<Text>(find.text(sampleMovie.title).first);
      expect(titleWidget.style?.color, equals(Colors.white));

      final scheduleHeader = tester.widget<Text>(find.text('Lịch Chiếu'));
      expect(scheduleHeader.style?.color, equals(Colors.white));

      await tester.pumpWidget(_buildWrapper(const CinemaNewsScreen()));
      final sampleArticle = CinemaService.instance.articles.first;
      final articleTitle = tester.widget<Text>(find.text(sampleArticle.title).first);
      expect(articleTitle.style?.color, equals(Colors.white));

      await tester.pumpWidget(
        _buildWrapper(
          Scaffold(
            body: Column(
              children: [
                GlassButton.brand(text: 'Đăng ký', onPressed: () {}),
                GlassButton.neutral(text: 'Chi tiết', onPressed: () {}),
                GlassChipButton(
                  label: 'Hành động',
                  isSelected: true,
                  onSelected: (_) {},
                ),
                GlassChipButton(
                  label: 'Viễn tưởng',
                  isSelected: false,
                  onSelected: (_) {},
                ),
              ],
            ),
          ),
        ),
      );

      final selectedChipText = tester.widget<Text>(find.text('Hành động'));
      expect(selectedChipText.style?.color, equals(Colors.white));
      final unselectedChipText = tester.widget<Text>(find.text('Viễn tưởng'));
      expect(unselectedChipText.style?.color, equals(const Color(0xFFE2F1FF)));
    });
  });
}
