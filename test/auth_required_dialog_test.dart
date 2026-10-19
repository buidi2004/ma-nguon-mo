import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openflix/presentation/widgets/dialogs/auth_required_dialog.dart';
import 'package:openflix/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildTestableApp({
    VoidCallback? onWatchTrailer,
    String? movieTitle = 'Avengers: Doomsday (Trailer 2 Marvel)',
    String? movieId = 'movie_avengers_1',
    bool hasTrailer = true,
    Size size = const Size(393, 852),
  }) {
    return MediaQuery(
      data: MediaQueryData(size: size),
      child: MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return Center(
                child: ElevatedButton(
                  onPressed: () {
                    AuthRequiredDialog.show(
                      context,
                      movieId: movieId,
                      movieTitle: movieTitle,
                      hasTrailer: hasTrailer,
                      onWatchTrailer: onWatchTrailer,
                    );
                  },
                  child: const Text('Show Dialog'),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  group('AuthRequiredDialog UX/UI & Entrance Animation Tests', () {
    testWidgets('Renders cinematic modal with breathing lock and clean hierarchy', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(393, 852);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestableApp());
      await tester.pump();

      // Open dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // 1. Verify Title & Movie Title
      expect(find.text('Đăng nhập để xem phim'), findsOneWidget);
      expect(
        find.text('« Avengers: Doomsday (Trailer 2 Marvel) »'),
        findsOneWidget,
      );

      // 2. Verify 3 Benefit Perks
      expect(
        find.text('Chất lượng Full HD & 4K siêu sắc nét'),
        findsOneWidget,
      );
      expect(
        find.text('Tự động đồng bộ lịch sử xem đa thiết bị'),
        findsOneWidget,
      );
      expect(
        find.text('Mở khóa toàn bộ các tập phim và series'),
        findsOneWidget,
      );

      // 3. Verify Single Unified Trailer Action & Primary CTA (No duplicates)
      expect(find.text('Đăng nhập ngay'), findsOneWidget);
      expect(find.text('Xem Trailer miễn phí'), findsOneWidget);
      expect(find.text('Xem Trailer trước'), findsNothing); // Duplicate removed!
      expect(
        find.text('Xem Trailer phim hoàn toàn miễn phí'),
        findsNothing,
      ); // Duplicate banner removed!

      // 4. Verify Dismiss
      expect(find.text('Để sau'), findsOneWidget);
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
    });

    testWidgets('Tapping "Xem Trailer miễn phí" triggers callback and closes modal', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(393, 852);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      bool trailerTapped = false;
      await tester.pumpWidget(
        buildTestableApp(onWatchTrailer: () => trailerTapped = true),
      );
      await tester.pump();

      await tester.tap(find.text('Show Dialog'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      await tester.tap(find.text('Xem Trailer miễn phí'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      expect(trailerTapped, isTrue);
      // Dialog dismissed
      expect(find.text('Đăng nhập để xem phim'), findsNothing);
    });

    testWidgets('Tapping "Để sau" dismisses dialog cleanly', (tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(393, 852);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestableApp());
      await tester.pump();

      await tester.tap(find.text('Show Dialog'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      await tester.tap(find.text('Để sau'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.text('Đăng nhập để xem phim'), findsNothing);
    });

    testWidgets('Zero overflow on compact 320x640 mobile screen', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(320, 640);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestableApp(size: const Size(320, 640)));
      await tester.pump();

      await tester.tap(find.text('Show Dialog'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(tester.takeException(), isNull);
      expect(find.text('Đăng nhập để xem phim'), findsOneWidget);
      expect(
        find.text('« Avengers: Doomsday (Trailer 2 Marvel) »'),
        findsOneWidget,
      );
    });
  });
}
