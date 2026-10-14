import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openflix/models/movie_model.dart';
import 'package:openflix/services/library_service.dart';
import 'package:openflix/theme/app_theme.dart';
import 'package:openflix/widgets/hero_banner.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final mockMovies = [
    MovieModel(
      id: 'movie-1',
      title: 'Madame Web',
      category: 'Hành Động, Siêu Anh Hùng',
      description: 'Cassandra Webb phát triển năng lực thấu thị...',
      posterUrl: 'https://example.com/poster1.jpg',
      videoUrl: 'https://example.com/video1.mp4',
      trailerUrl: 'https://example.com/trailer1.mp4',
      releaseYear: 2024,
      durationMinutes: 116,
      ageRating: 'T13',
      isFeatured: false,
    ),
    MovieModel(
      id: 'movie-2',
      title: 'Avatar: Dòng Chảy Của Nước',
      category: 'Khoa Học Viễn Tưởng',
      description: 'Jake Sully sống cùng gia đình mới tại Pandora...',
      posterUrl: 'https://example.com/poster2.jpg',
      videoUrl: 'https://example.com/video2.mp4',
      trailerUrl: 'https://example.com/trailer2.mp4',
      releaseYear: 2022,
      durationMinutes: 192,
      ageRating: 'T16',
      isFeatured: true,
    ),
  ];

  Widget buildTestableBanner(
    Widget banner, {
    Size size = const Size(393, 852),
  }) {
    return MediaQuery(
      data: MediaQueryData(size: size),
      child: MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(body: banner),
      ),
    );
  }

  group('HeroBannerCarousel Tri-Action Cluster (Madame Web style)', () {
    testWidgets('Renders 3-button cluster and dot indicators at bottom', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestableBanner(
          HeroBannerCarousel(
            movies: mockMovies,
            onPlay: (_) {},
            onInfo: (_) {},
          ),
        ),
      );
      await tester.pump();

      // Bookmark / Thêm vào DS
      expect(find.text('Thêm vào DS'), findsOneWidget);
      expect(find.byIcon(Icons.bookmark_outline), findsOneWidget);

      // Center pill button: [ HD ] + price
      expect(find.text('HD'), findsOneWidget);
      expect(find.text('29.000đ'), findsOneWidget);

      // Info / Chi tiết
      expect(find.text('Chi tiết'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsOneWidget);

      // Meta row
      expect(find.text('Galaxy VIP'), findsOneWidget);
      expect(find.text('T13'), findsOneWidget);
    });

    testWidgets('Tapping image fires onImageTap callback', (tester) async {
      MovieModel? tappedMovie;

      await tester.pumpWidget(
        buildTestableBanner(
          HeroBannerCarousel(
            movies: mockMovies,
            onPlay: (_) {},
            onInfo: (_) {},
            onImageTap: (m) => tappedMovie = m,
          ),
        ),
      );
      await tester.pump();

      // Tap on the hero image container (above the action buttons)
      await tester.tapAt(const Offset(200, 200));
      await tester.pump();

      expect(tappedMovie, isNotNull);
      expect(tappedMovie!.id, 'movie-1');
    });

    testWidgets('Tapping Bookmark toggles library state and updates UI icon', (
      tester,
    ) async {
      final library = LibraryService.instance;
      // Reset state for movie-1
      if (library.isInMyList('movie-1')) {
        await library.toggleMyList('movie-1');
      }
      expect(library.isInMyList('movie-1'), isFalse);

      await tester.pumpWidget(
        buildTestableBanner(
          HeroBannerCarousel(
            movies: mockMovies,
            onPlay: (_) {},
            onInfo: (_) {},
          ),
        ),
      );
      await tester.pump();

      // Tap Bookmark
      await tester.tap(find.text('Thêm vào DS'));
      await tester.pump();

      expect(library.isInMyList('movie-1'), isTrue);
      expect(find.text('Đã thêm'), findsOneWidget);
      expect(find.byIcon(Icons.bookmark), findsOneWidget);

      // Tap again to remove
      await tester.tap(find.text('Đã thêm'));
      await tester.pump();

      expect(library.isInMyList('movie-1'), isFalse);
      expect(find.text('Thêm vào DS'), findsOneWidget);
      expect(find.byIcon(Icons.bookmark_outline), findsOneWidget);
    });

    testWidgets('Tapping Center Capsule fires onPlay', (tester) async {
      MovieModel? watchedMovie;

      await tester.pumpWidget(
        buildTestableBanner(
          HeroBannerCarousel(
            movies: mockMovies,
            onPlay: (m) => watchedMovie = m,
            onInfo: (_) {},
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('29.000đ'));
      await tester.pump();

      expect(watchedMovie, isNotNull);
      expect(watchedMovie!.id, 'movie-1');
    });

    testWidgets('Tapping Info fires onInfo', (tester) async {
      MovieModel? infoMovie;

      await tester.pumpWidget(
        buildTestableBanner(
          HeroBannerCarousel(
            movies: mockMovies,
            onPlay: (_) {},
            onInfo: (m) => infoMovie = m,
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Chi tiết'));
      await tester.pump();

      expect(infoMovie, isNotNull);
      expect(infoMovie!.id, 'movie-1');
    });

    testWidgets('Zero overflow on ultra-narrow 320x640 mobile viewport', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestableBanner(
          HeroBannerCarousel(
            movies: mockMovies,
            onPlay: (_) {},
            onInfo: (_) {},
          ),
          size: const Size(320, 640),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.byType(HeroBannerCarousel), findsOneWidget);
      expect(find.text('Chi tiết'), findsOneWidget);
      expect(find.text('29.000đ'), findsOneWidget);
    });

    testWidgets('Renders properly on 800x1200 tablet viewport', (tester) async {
      await tester.pumpWidget(
        buildTestableBanner(
          HeroBannerCarousel(
            movies: mockMovies,
            onPlay: (_) {},
            onInfo: (_) {},
          ),
          size: const Size(800, 1200),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.byType(HeroBannerCarousel), findsOneWidget);
    });
  });
}
