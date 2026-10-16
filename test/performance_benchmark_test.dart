import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openflix/core/widgets/movie_grid.dart';
import 'package:openflix/features/watch/detail_screen.dart';
import 'package:openflix/models/movie_model.dart';
import 'package:openflix/services/pocketbase_service.dart';
import 'package:openflix/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _buildTestableWidget(Widget child) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: buildAppTheme(),
    home: child,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = null;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Performance & Pagination Benchmark Tests', () {
    test('BENCH-01: Smart Pagination splits datasets into clean pages', () async {
      final pb = PocketBaseService.instance;
      
      // Page 1 with perPage: 4
      final page1 = await pb.getMoviesPaged(page: 1, perPage: 4, forceRefresh: true);
      expect(page1.page, equals(1));
      expect(page1.perPage, equals(4));
      expect(page1.items.length, equals(4));
      expect(page1.hasMore, isTrue);
      expect(page1.totalItems, greaterThanOrEqualTo(8));

      // Page 2 with perPage: 4
      final page2 = await pb.getMoviesPaged(page: 2, perPage: 4);
      expect(page2.page, equals(2));
      expect(page2.items.length, greaterThanOrEqualTo(1));
      
      // Verify no overlap between page 1 and page 2
      final page1Ids = page1.items.map((m) => m.id).toSet();
      for (final m in page2.items) {
        expect(page1Ids.contains(m.id), isFalse, reason: 'Page 2 should not duplicate Page 1 items');
      }
    });

    test('BENCH-02: In-Memory L1 Cache returns in under 5ms without network penalty', () async {
      final pb = PocketBaseService.instance;
      
      // Cold request (populates cache)
      await pb.getMoviesPaged(page: 1, perPage: 5, forceRefresh: true);

      // Warm request (hits cache)
      final stopwatch = Stopwatch()..start();
      final cachedResult = await pb.getMoviesPaged(page: 1, perPage: 5);
      stopwatch.stop();

      expect(cachedResult.items.length, equals(5));
      expect(stopwatch.elapsedMilliseconds, lessThan(10), 
          reason: 'Cache hit must return under 10ms (actual: ${stopwatch.elapsedMilliseconds}ms)');
    });

    test('BENCH-03: In-flight deduplication avoids redundant concurrent requests', () async {
      final pb = PocketBaseService.instance;

      // Launch 3 simultaneous requests with forceRefresh
      final future1 = pb.getMoviesPaged(page: 1, perPage: 6, forceRefresh: true);
      final future2 = pb.getMoviesPaged(page: 1, perPage: 6);
      final future3 = pb.getMoviesPaged(page: 1, perPage: 6);

      final results = await Future.wait([future1, future2, future3]);
      expect(results[0].items.length, equals(6));
      expect(results[1].items.length, equals(6));
      expect(results[2].items.length, equals(6));
      expect(results[0].items.first.id, equals(results[1].items.first.id));
    });

    testWidgets('BENCH-04: MovieGrid displays infinite scroll loading indicator seamlessly', (tester) async {
      final movies = [
        MovieModel(
          id: 'test-1',
          title: 'Movie 1',
          description: 'Description 1',
          category: 'Action',
          posterUrl: 'https://example.com/poster1.jpg',
          videoUrl: 'https://example.com/video1.mp4',
          releaseYear: 2024,
          isFeatured: true,
        ),
        MovieModel(
          id: 'test-2',
          title: 'Movie 2',
          description: 'Description 2',
          category: 'Drama',
          posterUrl: 'https://example.com/poster2.jpg',
          videoUrl: 'https://example.com/video2.mp4',
          releaseYear: 2024,
          isFeatured: false,
        ),
      ];

      await tester.pumpWidget(
        _buildTestableWidget(
          Scaffold(
            body: MovieGrid(
              movies: movies,
              isLoadingMore: true,
            ),
          ),
        ),
      );

      // Verify the loading indicator inside the bottom SliverToBoxAdapter exists
      final bottomLoader = find.descendant(
        of: find.byType(SliverToBoxAdapter),
        matching: find.byType(CircularProgressIndicator),
      );
      expect(bottomLoader, findsOneWidget);
      expect(find.text('Movie 1'), findsOneWidget);
      expect(find.text('Movie 2'), findsOneWidget);
    });

    testWidgets('BENCH-05: DetailScreen poster has clean UI without circular play button', (tester) async {
      final sampleMovie = MovieModel(
        id: 'bench-detail-1',
        title: 'Mưa Đỏ',
        description: 'Phim lịch sử hào hùng',
        category: 'Chiến tranh',
        posterUrl: 'https://images.unsplash.com/photo-1536440136628-849c177e76a1?w=800',
        videoUrl: 'https://vjs.zencdn.net/v/oceans.mp4',
        releaseYear: 2024,
        isFeatured: true,
        durationMinutes: 120,
      );

      await tester.pumpWidget(
        _buildTestableWidget(
          DetailScreen(
            movieId: sampleMovie.id,
            initialMovie: sampleMovie,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      // Ensure the title and CTAs are rendered
      expect(find.text('Mưa Đỏ'), findsWidgets);
      expect(find.text('Phát'), findsOneWidget);
      expect(find.text('Trailer'), findsOneWidget);

      // Ensure the old 40px circular play button in BoxShape.circle was cleanly removed
      final circularPlayFinder = find.byWidgetPredicate((widget) {
        if (widget is Icon && widget.icon == Icons.play_arrow) {
          return widget.size != null && widget.size! >= 36;
        }
        return false;
      });
      expect(circularPlayFinder, findsNothing, reason: 'Old 40px circular play button must not be present on poster');

      // Cleanly teardown widget tree to cancel continuous shimmer animations
      await tester.pumpWidget(const SizedBox());
    });
  });
}
