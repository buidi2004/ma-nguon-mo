import 'package:flutter_test/flutter_test.dart';
import 'package:openflix/services/pocketbase_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PocketBaseService CRUD & Status Management Tests', () {
    final pb = PocketBaseService.instance;

    test('Tạo phim mới (createMovie) thành công và xóa cache', () async {
      final initialMovies = await pb.getMovies();
      final initialCount = initialMovies.length;

      final newMovie = await pb.createMovie({
        'title': 'Test Movie Created',
        'description': 'Mô tả phim test tự động',
        'category': 'Hành động',
        'poster_url': 'https://example.com/poster.jpg',
        'video_url': 'https://example.com/video.mp4',
        'release_year': 2025,
        'duration_minutes': 120,
        'is_featured': true,
        'is_new': true,
        'coming_soon': false,
      });

      expect(newMovie.id, isNotEmpty);
      expect(newMovie.title, equals('Test Movie Created'));
      expect(newMovie.isFeatured, isTrue);

      final updatedMovies = await pb.getMovies();
      expect(updatedMovies.length, equals(initialCount + 1));
      expect(updatedMovies.any((m) => m.id == newMovie.id), isTrue);
    });

    test('Cập nhật phim (updateMovie) thành công', () async {
      final movies = await pb.getMovies();
      final target = movies.first;

      final updated = await pb.updateMovie(target.id, {
        'title': 'Updated Title For Test',
        'category': 'Khoa học viễn tưởng',
      });

      expect(updated.id, equals(target.id));
      expect(updated.title, equals('Updated Title For Test'));

      final refreshed = await pb.getMovieById(target.id);
      expect(refreshed?.title, equals('Updated Title For Test'));
    });

    test('Cập nhật trạng thái phim (updateMovieStatus) thành công', () async {
      final movies = await pb.getMovies();
      final target = movies.first;

      final success = await pb.updateMovieStatus(
        target.id,
        isFeatured: false,
        isNew: true,
        comingSoon: true,
        rank: 1,
      );

      expect(success, isTrue);

      final refreshed = await pb.getMovieById(target.id);
      expect(refreshed?.isFeatured, isFalse);
      expect(refreshed?.isNew, isTrue);
      expect(refreshed?.comingSoon, isTrue);
      expect(refreshed?.rank, equals(1));
    });

    test('Xóa phim (deleteMovie) thành công', () async {
      final movies = await pb.getMovies();
      final target = movies.first;
      final countBefore = movies.length;

      final success = await pb.deleteMovie(target.id);
      expect(success, isTrue);

      final countAfter = (await pb.getMovies()).length;
      expect(countAfter, equals(countBefore - 1));

      final deleted = await pb.getMovieById(target.id);
      expect(deleted, isNull);
    });
  });
}
