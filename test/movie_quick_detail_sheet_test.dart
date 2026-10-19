import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openflix/models/movie_model.dart';
import 'package:openflix/widgets/movie_quick_detail_sheet.dart';

void main() {
  final sampleMovie = MovieModel(
    id: 'movie_001',
    title: 'Đại Chiến Vũ Trụ',
    description: 'Một cuộc phiêu lưu ngoạn mục giải cứu thiên hà.',
    category: 'Khoa học viễn tưởng',
    posterUrl: 'https://example.com/poster.jpg',
    videoUrl: 'https://example.com/video.mp4',
    releaseYear: 2024,
    durationMinutes: 125,
    ageRating: '16+',
    director: 'Nguyễn Văn Đạo',
    cast: 'Trần Diễn Viên, Lê Ngôi Sao',
    isFeatured: true,
  );

  final sampleSimilar = [
    MovieModel(
      id: 'movie_002',
      title: 'Thiên Hà Rực Lửa',
      description: 'Phần tiếp theo.',
      category: 'Khoa học viễn tưởng',
      posterUrl: 'https://example.com/poster2.jpg',
      videoUrl: 'https://example.com/video2.mp4',
      releaseYear: 2023,
      isFeatured: false,
    ),
  ];

  Widget buildTestWidget({
    required void Function(MovieModel) onPlay,
    required void Function(MovieModel) onWatchTrailer,
    required void Function(MovieModel) onOpenFullDetail,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () {
                MovieQuickDetailSheet.show(
                  context: context,
                  movie: sampleMovie,
                  similarMovies: sampleSimilar,
                  onPlay: onPlay,
                  onWatchTrailer: onWatchTrailer,
                  onOpenFullDetail: onOpenFullDetail,
                );
              },
              child: const Text('Mở Modal'),
            );
          },
        ),
      ),
    );
  }

  void setupMobileViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  testWidgets('MovieQuickDetailSheet renders basic info and triggers onPlay', (tester) async {
    setupMobileViewport(tester);
    bool playCalled = false;

    await tester.pumpWidget(
      buildTestWidget(
        onPlay: (_) => playCalled = true,
        onWatchTrailer: (_) {},
        onOpenFullDetail: (_) {},
      ),
    );

    // Bấm mở modal
    await tester.tap(find.text('Mở Modal'));
    await tester.pumpAndSettle();

    // Kiểm tra các thành phần cơ bản ở tầng Collapsed
    expect(find.text('Đại Chiến Vũ Trụ'), findsOneWidget);
    expect(find.text('2024'), findsOneWidget);
    expect(find.text('HD'), findsOneWidget);
    expect(find.text('125p'), findsOneWidget);
    expect(find.text('16+'), findsOneWidget);
    expect(find.text('Khoa học viễn tưởng'), findsOneWidget);
    expect(find.text('Phát'), findsOneWidget);

    // Kiểm tra 4 nút chức năng
    expect(find.text('Chi tiết'), findsOneWidget);
    expect(find.text('Danh sách'), findsOneWidget);
    expect(find.text('Thích'), findsOneWidget);
    expect(find.text('Chia sẻ'), findsOneWidget);

    // Bấm nút Phát
    await tester.tap(find.text('Phát'));
    await tester.pumpAndSettle();

    expect(playCalled, isTrue);
  });

  testWidgets('MovieQuickDetailSheet opens full detail when tapping Chi tiết', (tester) async {
    setupMobileViewport(tester);
    bool detailCalled = false;

    await tester.pumpWidget(
      buildTestWidget(
        onPlay: (_) {},
        onWatchTrailer: (_) {},
        onOpenFullDetail: (_) => detailCalled = true,
      ),
    );

    await tester.tap(find.text('Mở Modal'));
    await tester.pumpAndSettle();

    // Bấm nút Chi tiết
    await tester.tap(find.text('Chi tiết'));
    await tester.pumpAndSettle();

    expect(detailCalled, isTrue);
  });

  testWidgets('MovieQuickDetailSheet drags up to reveal expanded details and similar movies', (tester) async {
    setupMobileViewport(tester);
    bool detailCalled = false;

    await tester.pumpWidget(
      buildTestWidget(
        onPlay: (_) {},
        onWatchTrailer: (_) {},
        onOpenFullDetail: (_) => detailCalled = true,
      ),
    );

    await tester.tap(find.text('Mở Modal'));
    await tester.pumpAndSettle();

    // Vuốt lên trên để mở rộng sang nấc 2 (Expanded)
    await tester.drag(find.text('Đại Chiến Vũ Trụ'), const Offset(0, -350));
    await tester.pumpAndSettle();

    // Xác nhận các thành phần tầng 2 đã xuất hiện
    expect(find.text('Tóm tắt nội dung'), findsOneWidget);
    expect(find.textContaining('Nguyễn Văn Đạo'), findsOneWidget);
    expect(find.text('Mở toàn trang chi tiết phim'), findsOneWidget);
    expect(find.text('Nội dung tương tự'), findsOneWidget);

    // Bấm nút "Mở toàn trang chi tiết phim"
    await tester.tap(find.text('Mở toàn trang chi tiết phim'));
    await tester.pumpAndSettle();

    expect(detailCalled, isTrue);
  });
}
