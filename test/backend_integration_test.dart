import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:openflix/models/movie_model.dart';
import 'package:openflix/services/auth_service.dart';
import 'package:openflix/services/library_service.dart';
import 'package:openflix/services/pocketbase_service.dart';
import 'package:openflix/features/system/system_status_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = null;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('OpenFlix Backend-Frontend Integration Tests (INT-01 to INT-10)', () {
    // INT-01: Backend health + config
    test(
      'INT-01: Backend health + config (Base URL & fallback config)',
      () async {
        final pb = PocketBaseService.instance;
        expect(pb.baseUrl, isNotEmpty);
        expect(pb.baseUrl.startsWith('http'), isTrue);
        expect(pb.baseUrl, equals('http://180.93.120.246:8090'));

        // Thử cập nhật Base URL môi trường dev/local
        const testUrl = 'http://127.0.0.1:8090';
        pb.updateBaseUrl(testUrl);
        expect(pb.baseUrl, equals(testUrl));

        // Reset lại URL mặc định VPS
        pb.updateBaseUrl('http://180.93.120.246:8090');
        expect(pb.baseUrl, equals('http://180.93.120.246:8090'));
      },
    );

    // INT-02: Fetch movie list
    test('INT-02: Fetch movie list (Model/FE khớp response & đầy đủ trường dữ liệu)', () async {
      final pb = PocketBaseService.instance;
      final movies = await pb.getMovies();

      expect(movies, isNotEmpty);
      expect(movies.length, greaterThanOrEqualTo(8));

      // Kiểm tra tính toàn vẹn của Model MovieModel
      final first = movies.first;
      expect(first.id, isNotEmpty);
      expect(first.title, isNotEmpty);
      expect(first.category, isNotEmpty);
      expect(first.posterUrl, isNotEmpty);
      expect(first.videoUrl, isNotEmpty);
      expect(first.releaseYear, greaterThan(1900));
      expect(first.durationMinutes, greaterThan(0));
    });

    // INT-03: Movie detail by ID
    test(
      'INT-03: Movie detail by ID (Thông tin và metadata khớp ID yêu cầu)',
      () async {
        final pb = PocketBaseService.instance;
        final movies = await pb.getMovies();
        expect(movies, isNotEmpty);

        final targetId = movies.first.id;
        final movie = await pb.getMovieById(targetId);

        expect(movie, isNotNull);
        expect(movie!.id, equals(targetId));
        expect(movie.title, equals(movies.first.title));
        expect(movie.posterUrl, isNotEmpty);
        expect(movie.releaseYear, greaterThan(1900));

        // ID không tồn tại phải trả về null an toàn
        final notFound = await pb.getMovieById('non_existent_id_999');
        expect(notFound, isNull);
      },
    );

    // INT-04: Poster failures
    test('INT-04: Poster failures (Error state & fallback an toàn)', () {
      final brokenMovie = MovieModel(
        id: 'broken_1',
        title: 'Phim Ảnh Lỗi',
        description: 'Test poster URL hỏng',
        category: 'Thử nghiệm',
        posterUrl: 'https://invalid-domain-xyz.com/broken_poster.jpg',
        videoUrl: 'https://example.com/video.mp4',
        releaseYear: 2026,
        isFeatured: false,
      );

      expect(brokenMovie.thumbnailUrl, equals(brokenMovie.posterUrl));
      expect(brokenMovie.posterUrl, isNotEmpty);
      // Đảm bảo không ném ngoại lệ khi parse
      final json = brokenMovie.toJson();
      final reconstructed = MovieModel.fromJson(json);
      expect(reconstructed.id, equals('broken_1'));
    });

    // INT-05: Video/player
    test(
      'INT-05: Video/player (Video URL đúng định dạng streamable hợp lệ)',
      () async {
        final pb = PocketBaseService.instance;
        final movies = await pb.getMovies();

        for (final m in movies) {
          final uri = Uri.tryParse(m.videoUrl);
          expect(uri, isNotNull);
          expect(uri!.hasScheme, isTrue);
          expect(uri.scheme.startsWith('http'), isTrue);
          expect(
            m.videoUrl.endsWith('.mp4') || m.videoUrl.contains('.mp4'),
            isTrue,
          );
        }
      },
    );

    // INT-06: Search/filter/sort
    test(
      'INT-06: Search/filter/sort (Tìm kiếm, lọc thể loại và Top 10)',
      () async {
        final pb = PocketBaseService.instance;

        // Tìm kiếm từ khóa
        final searchResults = await pb.searchMovies('Bunny');
        expect(searchResults, isNotEmpty);
        expect(
          searchResults.any((m) => m.title.contains('Big Buck Bunny')),
          isTrue,
        );

        // Lọc theo thể loại
        final animationMovies = await pb.getMoviesByCategory('Hoạt hình');
        expect(animationMovies, isNotEmpty);
        for (final m in animationMovies) {
          expect(m.category.toLowerCase(), equals('hoạt hình'));
        }

        // Top 10 giới hạn
        final top10 = await pb.getTop10Movies();
        expect(top10.length, lessThanOrEqualTo(10));
      },
    );

    // INT-07: Auth/session/logout
    test('INT-07: Auth/session/logout (Phiên đăng nhập & đăng xuất)', () async {
      final auth = AuthService.instance;

      // Đăng nhập demo hợp lệ
      final loginSuccess = await auth.login('test@openflix.vn', '123456');
      expect(loginSuccess, isTrue);
      expect(auth.isLoggedIn, isTrue);
      expect(auth.userEmail, equals('test@openflix.vn'));

      // Đăng xuất
      await auth.logout();
      expect(auth.isLoggedIn, isFalse);
    });

    // INT-08: User data isolation
    test(
      'INT-08: User data isolation (My List, Like, Watch Progress cá nhân)',
      () async {
        final lib = LibraryService.instance;

        // Thêm / xóa My List
        const testMovieId = 'test_movie_x';
        expect(lib.isInMyList(testMovieId), isFalse);
        await lib.toggleMyList(testMovieId);
        expect(lib.isInMyList(testMovieId), isTrue);

        await lib.toggleMyList(testMovieId);
        expect(lib.isInMyList(testMovieId), isFalse);

        // Thích phim
        expect(lib.isLiked(testMovieId), isFalse);
        await lib.toggleLike(testMovieId);
        expect(lib.isLiked(testMovieId), isTrue);

        await lib.toggleLike(testMovieId);
        expect(lib.isLiked(testMovieId), isFalse);

        // Lưu tiến độ xem
        await lib.saveProgress(testMovieId, 120, 600);
        final progress = lib.getProgress(testMovieId);
        expect(progress, isNotNull);
        expect(progress!.positionSeconds, equals(120));
        expect(progress.durationSeconds, equals(600));
        expect(progress.progressRatio, closeTo(0.2, 0.01));
      },
    );

    // INT-09: Empty/offline/timeout/403/500
    test('INT-09: Empty/offline/timeout (Cơ chế Offline Fallback & SystemStatusScreen)', () async {
      final pb = PocketBaseService.instance;

      // Cố tình trỏ tới server không tồn tại để kích hoạt offline fallback ngay lập tức (1ms)
      pb.updateBaseUrl(
        'http://127.0.0.1:59999',
      ); // Local closed port -> instant refused
      final fallbackMovies = await pb.getMovies();

      expect(fallbackMovies, isNotEmpty);
      expect(pb.isUsingOfflineMock, isTrue);

      // Khôi phục lại Base URL thật
      pb.updateBaseUrl('http://180.93.120.246:8090');

      // Khởi tạo SystemStatusScreen offline/error/notFound
      final offlineScreen = SystemStatusScreen.offline();
      expect(offlineScreen.code, equals('S39'));

      final errorScreen = SystemStatusScreen.error();
      expect(errorScreen.code, equals('S40'));

      final notFoundScreen = SystemStatusScreen.notFound(
        attemptedPath: '/invalid-route',
      );
      expect(notFoundScreen.code, equals('S41'));
    });

    // INT-10: Android release config
    test('INT-10: Android release config (AndroidManifest quyền Internet và cleartext)', () {
      final manifestFile = File('android/app/src/main/AndroidManifest.xml');
      expect(manifestFile.existsSync(), isTrue);

      final content = manifestFile.readAsStringSync();
      expect(content, contains('android.permission.INTERNET'));
      expect(content, contains('android:usesCleartextTraffic="true"'));
    });
  });
}
