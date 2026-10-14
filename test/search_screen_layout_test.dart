import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openflix/features/discover/search_screen.dart';
import 'package:openflix/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildTestableSearch({Size size = const Size(393, 852)}) {
    return MediaQuery(
      data: MediaQueryData(size: size),
      child: MaterialApp(theme: buildAppTheme(), home: const SearchScreen()),
    );
  }

  group('SearchScreen Visual Layout (Reference Screenshot Match)', () {
    testWidgets(
      'Renders Search Header, Glass Search Capsule, and Default 6 Genres',
      (tester) async {
        tester.view.devicePixelRatio = 1.0;
        tester.view.physicalSize = const Size(393, 852);
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(buildTestableSearch());
        await tester.pump(const Duration(milliseconds: 300));

        // Header title & search placeholder
        expect(find.text('Tìm kiếm'), findsOneWidget);
        expect(find.text('Tên phim, diễn viên, thể loại'), findsOneWidget);

        // Top genres
        expect(find.text('Gia đình'), findsOneWidget);
        expect(find.text('Tâm lý'), findsOneWidget);
        expect(find.text('Hành động'), findsOneWidget);
        expect(find.text('Hài'), findsOneWidget);

        // Drag CustomScrollView down to reveal bottom genres and sections
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
        await tester.pump(const Duration(milliseconds: 200));

        expect(find.text('Phim Việt'), findsOneWidget);
        expect(find.text('Kiếm hiệp'), findsOneWidget);
        expect(find.text('Xem thêm'), findsOneWidget);
        expect(find.text('Có thể bạn quan tâm'), findsOneWidget);
      },
    );

    testWidgets('Tapping "Xem thêm" expands genre grid to show more genres', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(393, 852);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestableSearch());
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Kinh dị'), findsNothing);

      // Drag to bring "Xem thêm" into view
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -250));
      await tester.pump(const Duration(milliseconds: 200));

      // Tap "Xem thêm"
      await tester.tap(find.text('Xem thêm'));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Kinh dị'), findsOneWidget);

      // Drag down to bring "Thu gọn" into view
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Thu gọn'), findsOneWidget);

      // Tap "Thu gọn"
      await tester.tap(find.text('Thu gọn'));
      await tester.pump(const Duration(milliseconds: 300));

      // Drag back up to verify "Xem thêm" is back
      await tester.drag(find.byType(CustomScrollView), const Offset(0, 300));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Xem thêm'), findsOneWidget);
      expect(find.text('Kinh dị'), findsNothing);
    });

    testWidgets('Tapping a genre card filters by that genre', (tester) async {
      await tester.pumpWidget(buildTestableSearch());
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.text('Hành động'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.textContaining('Kết quả tìm kiếm'), findsOneWidget);
    });

    testWidgets('Zero overflow on ultra-narrow 320x640 mobile viewport', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestableSearch(size: const Size(320, 640)));
      await tester.pump(const Duration(milliseconds: 300));

      expect(tester.takeException(), isNull);
      expect(find.text('Tìm kiếm'), findsOneWidget);
      expect(find.text('Gia đình'), findsOneWidget);
    });

    testWidgets('Renders properly on 800x1200 tablet viewport', (tester) async {
      await tester.pumpWidget(buildTestableSearch(size: const Size(800, 1200)));
      await tester.pump(const Duration(milliseconds: 300));

      expect(tester.takeException(), isNull);
      expect(find.text('Tìm kiếm'), findsOneWidget);
      expect(find.text('Gia đình'), findsOneWidget);
    });
  });
}
