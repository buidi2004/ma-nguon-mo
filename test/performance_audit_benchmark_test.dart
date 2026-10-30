import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openflix/features/cinema/cinema_hub_screen.dart';
import 'package:openflix/features/discover/hot_screen.dart';
import 'package:openflix/features/discover/search_screen.dart';
import 'package:openflix/features/watch/detail_screen.dart';
import 'package:openflix/models/movie_model.dart';
import 'package:openflix/screens/home_screen.dart';
import 'package:openflix/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'support/test_image_mock.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: buildAppTheme(),
    home: child,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  mockNetworkImages();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Mobile Performance Audit & Latency Benchmarks', () {
    testWidgets('AUDIT-01: Measure HomeScreen initial mount and warm frame budget', (tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(393, 852);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final sw = Stopwatch()..start();
      await tester.pumpWidget(_wrap(const HomeScreen(enableTrialPromo: false)));
      sw.stop();
      final mountMs = sw.elapsedMicroseconds / 1000.0;

      final swFrame = Stopwatch()..start();
      await tester.pump(const Duration(milliseconds: 300));
      swFrame.stop();
      final frameMs = swFrame.elapsedMicroseconds / 1000.0;

      debugPrint('📊 [AUDIT-01] HomeScreen: Mount = ${mountMs.toStringAsFixed(2)}ms | Warm Frame = ${frameMs.toStringAsFixed(2)}ms');
      expect(mountMs, lessThan(800.0));
      expect(frameMs, lessThan(500.0));
    });

    testWidgets('AUDIT-02: Measure HotScreen mount and scroll render cost (Zero GPU Blur)', (tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(393, 852);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final sw = Stopwatch()..start();
      await tester.pumpWidget(_wrap(const HotScreen()));
      await tester.pump(const Duration(milliseconds: 100));
      sw.stop();
      final mountMs = sw.elapsedMicroseconds / 1000.0;

      // Scroll simulation
      final swScroll = Stopwatch()..start();
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
      await tester.pump(const Duration(milliseconds: 16));
      swScroll.stop();
      final scrollMs = swScroll.elapsedMicroseconds / 1000.0;

      debugPrint('📊 [AUDIT-02] HotScreen: Mount = ${mountMs.toStringAsFixed(2)}ms | Scroll Drag = ${scrollMs.toStringAsFixed(2)}ms');
      expect(mountMs, lessThan(600.0));
      expect(scrollMs, lessThan(100.0));
    });

    testWidgets('AUDIT-03: Measure DetailScreen mount with preloaded MovieModel', (tester) async {
      final sample = MovieModel(
        id: 'perf-detail-1',
        title: 'Thử Thách Hiệu Năng',
        description: 'Mô tả chi tiết',
        category: 'Hành động',
        posterUrl: 'https://example.com/poster.jpg',
        videoUrl: 'https://example.com/video.mp4',
        releaseYear: 2024,
        isFeatured: true,
      );

      final sw = Stopwatch()..start();
      await tester.pumpWidget(_wrap(DetailScreen(movieId: sample.id, initialMovie: sample)));
      await tester.pump(const Duration(milliseconds: 100));
      sw.stop();
      final mountMs = sw.elapsedMicroseconds / 1000.0;

      debugPrint('📊 [AUDIT-03] DetailScreen: Mount = ${mountMs.toStringAsFixed(2)}ms');
      expect(mountMs, lessThan(500.0));
    });

    testWidgets('AUDIT-04: Measure CinemaHubScreen mount with CachedNetworkImage', (tester) async {
      final sw = Stopwatch()..start();
      await tester.pumpWidget(_wrap(const CinemaHubScreen()));
      await tester.pump(const Duration(milliseconds: 100));
      sw.stop();
      final mountMs = sw.elapsedMicroseconds / 1000.0;

      debugPrint('📊 [AUDIT-04] CinemaHubScreen: Mount = ${mountMs.toStringAsFixed(2)}ms');
      expect(mountMs, lessThan(600.0));
    });

    testWidgets('AUDIT-05: Measure SearchScreen mount and text typing filter debounce', (tester) async {
      final sw = Stopwatch()..start();
      await tester.pumpWidget(_wrap(const SearchScreen()));
      await tester.pump(const Duration(milliseconds: 100));
      sw.stop();
      final mountMs = sw.elapsedMicroseconds / 1000.0;

      final swType = Stopwatch()..start();
      await tester.enterText(find.byType(TextField), 'Hành động');
      await tester.pump(const Duration(milliseconds: 300));
      swType.stop();
      final typeMs = swType.elapsedMicroseconds / 1000.0;

      debugPrint('📊 [AUDIT-05] SearchScreen: Mount = ${mountMs.toStringAsFixed(2)}ms | Input Reaction = ${typeMs.toStringAsFixed(2)}ms');
      expect(mountMs, lessThan(500.0));
      expect(typeMs, lessThan(300.0));
    });
  });
}
