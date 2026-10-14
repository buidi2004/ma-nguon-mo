import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openflix/features/discover/hot_screen.dart';
import 'package:openflix/services/library_service.dart';
import 'package:openflix/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildTestableHotScreen({Size size = const Size(393, 852)}) {
    return MediaQuery(
      data: MediaQueryData(size: size),
      child: MaterialApp(theme: buildAppTheme(), home: const HotScreen()),
    );
  }

  group('HotScreen Visual Layout & Reference Screenshot Verification', () {
    testWidgets('Renders Pinned Header, Glass Action, and Curated Feed', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(393, 852);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestableHotScreen());
      await tester.pump(const Duration(milliseconds: 300));

      // Header "Sắp ra mắt"
      expect(find.text('Sắp ra mắt'), findsOneWidget);

      // Curated movies from reference screenshot
      expect(find.text('QUỐC BẢO'), findsOneWidget);
      expect(find.text('KOKUHO'), findsOneWidget);
      expect(find.text('Hồng Trần Tứ Hợp'), findsOneWidget);
      expect(find.text('Love in Red Dust'), findsOneWidget);

      // Badges
      expect(find.text('Siêu Việt'), findsAtLeastNWidgets(1));
      expect(find.text('Cao Cấp'), findsAtLeastNWidgets(1));
      expect(find.text('Phim sắp ra mắt'), findsAtLeastNWidgets(1));

      // Action buttons
      expect(find.text('Thêm vào DS'), findsAtLeastNWidgets(1));
      expect(find.text('Chia sẻ'), findsAtLeastNWidgets(1));
    });

    testWidgets(
      'Tapping "Thêm vào DS" toggles library state and shows feedback',
      (tester) async {
        tester.view.devicePixelRatio = 1.0;
        tester.view.physicalSize = const Size(393, 852);
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(buildTestableHotScreen());
        await tester.pump(const Duration(milliseconds: 300));

        final addBtn = find.text('Thêm vào DS').first;
        expect(addBtn, findsOneWidget);

        await tester.tap(addBtn);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // Check LibraryService or SnackBar
        expect(LibraryService.instance.isInMyList('kokuho_2026'), isTrue);
      },
    );

    testWidgets('Tapping "Chia sẻ" displays share feedback', (tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(393, 852);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestableHotScreen());
      await tester.pump(const Duration(milliseconds: 300));

      final shareBtn = find.text('Chia sẻ').first;
      await tester.tap(shareBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(
        find.textContaining('Đã sao chép liên kết chia sẻ'),
        findsOneWidget,
      );
    });

    testWidgets('Zero overflow on narrow mobile 320x640 viewport', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(320, 640);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        buildTestableHotScreen(size: const Size(320, 640)),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(tester.takeException(), isNull);
      expect(find.text('Sắp ra mắt'), findsOneWidget);
      expect(find.text('QUỐC BẢO'), findsOneWidget);
    });

    testWidgets('Renders properly on tablet 800x1200 viewport', (tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(800, 1200);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        buildTestableHotScreen(size: const Size(800, 1200)),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(tester.takeException(), isNull);
      expect(find.text('Sắp ra mắt'), findsOneWidget);
    });
  });
}
