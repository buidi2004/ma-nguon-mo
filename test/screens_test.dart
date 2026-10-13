import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openflix/features/account/about_screen.dart';
import 'package:openflix/features/account/account_screen.dart';
import 'package:openflix/features/account/language_screen.dart';
import 'package:openflix/features/account/me_screen.dart';
import 'package:openflix/features/account/notifications_screen.dart';
import 'package:openflix/features/account/password_screen.dart';
import 'package:openflix/features/account/plans_screen.dart';
import 'package:openflix/features/account/playback_settings_screen.dart';
import 'package:openflix/features/account/profile_edit_screen.dart';
import 'package:openflix/features/account/profiles_screen.dart';
import 'package:openflix/features/account/settings_screen.dart';
import 'package:openflix/features/auth/forgot_password_screen.dart';
import 'package:openflix/features/auth/login_screen.dart';
import 'package:openflix/features/auth/onboarding_screen.dart';
import 'package:openflix/features/auth/register_screen.dart';
import 'package:openflix/features/auth/splash_screen.dart';
import 'package:openflix/features/auth/welcome_screen.dart';
import 'package:openflix/features/discover/filter_screen.dart';
import 'package:openflix/features/discover/genres_screen.dart';
import 'package:openflix/features/discover/hot_screen.dart';
import 'package:openflix/features/discover/movie_grid_screen.dart';
import 'package:openflix/features/discover/search_screen.dart';
import 'package:openflix/features/discover/top10_screen.dart';
import 'package:openflix/features/library/continue_watching_screen.dart';
import 'package:openflix/features/library/downloads_screen.dart';
import 'package:openflix/features/library/liked_movies_screen.dart';
import 'package:openflix/features/library/my_list_screen.dart';
import 'package:openflix/features/library/watch_history_screen.dart';
import 'package:openflix/features/system/contact_screen.dart';
import 'package:openflix/features/system/help_screen.dart';
import 'package:openflix/features/system/system_status_screen.dart';
import 'package:openflix/features/watch/audio_subtitle_screen.dart';
import 'package:openflix/features/watch/detail_screen.dart';
import 'package:openflix/features/watch/episodes_screen.dart';
import 'package:openflix/features/watch/reviews_screen.dart';
import 'package:openflix/features/watch/similar_movies_screen.dart';
import 'package:openflix/features/watch/trailer_screen.dart';
import 'package:openflix/features/watch/write_review_screen.dart';
import 'package:openflix/screens/home_screen.dart';
import 'package:openflix/theme/app_theme.dart';

Widget buildTestableWidget(Widget child, {Size size = const Size(393, 852)}) {
  return MediaQuery(
    data: MediaQueryData(size: size),
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: child,
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Group A: Khởi động & Tài khoản (S01 - S08)', () {
    testWidgets('S01: Splash renders wordmark and spinner', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const SplashScreen()));
      expect(find.text('OPENFLIX'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('S02: Onboarding renders PageView and action buttons', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget(const OnboardingScreen()));
      expect(find.text('Bỏ qua'), findsOneWidget);
      expect(find.text('Tiếp theo'), findsOneWidget);
    });

    testWidgets('S03: Welcome renders branding and entry options', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget(const WelcomeScreen()));
      expect(find.text('OPENFLIX'), findsOneWidget);
      expect(find.text('Đăng nhập'), findsOneWidget);
      expect(find.text('Tạo tài khoản mới'), findsOneWidget);
      expect(find.text('Khám phá ngay (Không cần đăng nhập)'), findsOneWidget);
    });

    testWidgets('S04: Login renders fields and validation', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const LoginScreen()));
      expect(find.text('Chào mừng trở lại'), findsOneWidget);
      expect(find.text('Đăng nhập'), findsWidgets);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Đăng nhập'));
      await tester.pump();
      expect(find.text('Vui lòng nhập email'), findsOneWidget);
    });

    testWidgets('S05: Register renders form fields', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const RegisterScreen()));
      expect(find.text('Tạo tài khoản OpenFlix'), findsOneWidget);
      expect(find.text('Đăng ký tài khoản'), findsWidgets);
    });

    testWidgets('S06: Forgot password validates email input', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(const ForgotPasswordScreen()),
      );
      expect(find.text('Quên mật khẩu?'), findsOneWidget);
      expect(find.text('Gửi liên kết khôi phục'), findsOneWidget);
    });

    testWidgets('S07: Profiles renders profile choices', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const ProfilesScreen()));
      expect(find.text('Ai đang xem?'), findsOneWidget);
      expect(find.text('Thêm hồ sơ'), findsOneWidget);
    });

    testWidgets('S08: Profile edit renders customization controls', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(const ProfileEditScreen(profileId: 'p1')),
      );
      expect(find.text('Chỉnh sửa hồ sơ'), findsOneWidget);
      expect(find.text('Lưu thay đổi'), findsOneWidget);
    });
  });

  group('Group B: Khám phá (S09 - S17)', () {
    testWidgets('S09: Home screen renders main layout', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const HomeScreen()));
      expect(find.text('OPENFLIX'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 300));
    });

    testWidgets('S10 & S11: Search screen renders search bar and tags', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget(const SearchScreen()));
      expect(find.byType(TextField), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 300));
    });

    testWidgets('S12: Filter screen renders category & sorting chips', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget(const FilterScreen()));
      expect(find.text('Bộ lọc nâng cao'), findsOneWidget);
      expect(find.text('Đặt lại'), findsOneWidget);
      expect(find.text('Áp dụng bộ lọc'), findsOneWidget);
    });

    testWidgets('S13: Genres screen renders category tiles', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const GenresScreen()));
      expect(find.text('Danh mục thể loại'), findsOneWidget);
    });

    testWidgets('S14 & S15: MovieGridScreen renders grid view', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const MovieGridScreen(title: 'Phim Hành Động', category: 'Hành động'),
        ),
      );
      expect(find.text('Phim Hành Động'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 300));
    });

    testWidgets('S16: Hot screen renders tabs', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const HotScreen()));
      expect(find.text('Mới & Hot'), findsOneWidget);
      expect(find.text('🍿 Phim mới ra mắt'), findsOneWidget);
      expect(find.text('🔥 Nổi bật nhất'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 300));
    });

    testWidgets('S17: Top 10 screen renders ranked list header', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget(const Top10Screen()));
      expect(find.text('Top 10 Phim Thịnh Hành'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 300));
    });
  });

  group('Group C: Xem phim (S18 - S24)', () {
    testWidgets('S18: Detail screen renders movie details and actions', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(const DetailScreen(movieId: 'sample1')),
      );
      await tester.pump(const Duration(milliseconds: 300));
    });

    testWidgets('S19: Trailer screen renders trailer view', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(const TrailerScreen(movieId: 'sample1')),
      );
      await tester.pump(const Duration(milliseconds: 300));
    });

    testWidgets('S21: Episodes screen renders season/episode options', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(const EpisodesScreen(movieId: 'sample1')),
      );
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Chọn mùa: '), findsOneWidget);
    });

    testWidgets('S22: Similar movies screen renders recommendations', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(const SimilarMoviesScreen(movieId: 'sample1')),
      );
      await tester.pump(const Duration(milliseconds: 300));
    });

    testWidgets('S23: Reviews screen renders rating overview', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(const ReviewsScreen(movieId: 'sample1')),
      );
      expect(find.text('Đánh giá phim'), findsOneWidget);
      expect(find.text('Viết đánh giá'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 300));
    });

    testWidgets('S24: Write review renders star rating and form', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(const WriteReviewScreen(movieId: 'sample1')),
      );
      expect(find.text('Viết đánh giá'), findsOneWidget);
      expect(find.text('Bạn cảm thấy bộ phim này thế nào?'), findsOneWidget);
    });

    testWidgets('Extra: Audio subtitle screen renders options', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(const AudioSubtitleScreen(movieId: 'sample1')),
      );
      expect(find.text('Âm thanh & Phụ đề'), findsOneWidget);
    });
  });

  group('Group D: Cá nhân (S25 - S29 & Downloads)', () {
    testWidgets('S25: My list screen renders saved items header', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget(const MyListScreen()));
      expect(find.text('Danh sách của tôi'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 300));
    });

    testWidgets('S26: Continue watching screen renders progress list', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(const ContinueWatchingScreen()),
      );
      expect(find.text('Đang xem dở'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 300));
    });

    testWidgets('S27: Watch history screen renders history list', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget(const WatchHistoryScreen()));
      expect(find.text('Lịch sử xem phim'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 300));
    });

    testWidgets('S28: Liked movies screen renders liked movies list', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget(const LikedMoviesScreen()));
      expect(find.text('Phim đã thích'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 300));
    });

    testWidgets('S29: Notifications screen renders notification list', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget(const NotificationsScreen()));
      expect(find.text('Thông báo'), findsOneWidget);
    });

    testWidgets('Extra: Downloads screen renders offline items', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget(const DownloadsScreen()));
      expect(find.text('Tệp tải xuống & Bộ nhớ'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 300));
    });
  });

  group('Group E: Tài khoản & Cài đặt (S30 - S38, S42)', () {
    testWidgets('S30: Me screen renders profile and navigation tiles', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget(const MeScreen()));
      expect(find.text('Tài khoản & Cá nhân'), findsOneWidget);
      expect(find.text('NỘI DUNG CỦA TÔI'), findsOneWidget);
      expect(find.text('TÀI KHOẢN & DỊCH VỤ'), findsOneWidget);
    });

    testWidgets('S31: Account screen renders user profile fields', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget(const AccountScreen()));
      expect(find.text('Thông tin tài khoản'), findsOneWidget);
      expect(find.text('Lưu thay đổi'), findsOneWidget);
    });

    testWidgets('S32: Password screen renders password fields', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const PasswordScreen()));
      expect(find.text('Đổi mật khẩu'), findsOneWidget);
      expect(find.text('Cập nhật mật khẩu'), findsOneWidget);
    });

    testWidgets('S33: Settings screen renders settings options', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget(const SettingsScreen()));
      expect(find.text('Cài đặt ứng dụng'), findsOneWidget);
    });

    testWidgets('S34: Playback settings renders video quality options', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(const PlaybackSettingsScreen()),
      );
      expect(find.text('Phát lại & Chất lượng'), findsOneWidget);
    });

    testWidgets('S35: Language screen renders supported languages', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget(const LanguageScreen()));
      expect(find.text('Ngôn ngữ / Language'), findsOneWidget);
      expect(find.text('Tiếng Việt'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
    });

    testWidgets('S36: Help screen renders FAQs', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const HelpScreen()));
      expect(find.text('Trung tâm trợ giúp'), findsOneWidget);
      expect(find.text('CÂU HỎI THƯỜNG GẶP (FAQ)'), findsOneWidget);
    });

    testWidgets('S37: Contact screen renders feedback form', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const ContactScreen()));
      expect(find.text('Liên hệ & Góp ý'), findsOneWidget);
      expect(find.text('Gửi phản hồi'), findsOneWidget);
    });

    testWidgets('S38: About screen renders version and licenses', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget(const AboutScreen()));
      expect(find.text('Giới thiệu & Giấy phép'), findsOneWidget);
      expect(find.text('OPENFLIX'), findsOneWidget);
      expect(find.text('Giấy phép mã nguồn mở MIT'), findsOneWidget);
    });

    testWidgets('S42: Plans screen renders membership tiers with demo tag', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget(const PlansScreen()));
      expect(find.text('Gói Thành Viên OpenFlix'), findsOneWidget);
      expect(find.text('Gói Tiêu Chuẩn'), findsOneWidget);
      expect(find.text('Gói Cao Cấp'), findsOneWidget);
      expect(find.text('Mô phỏng đồ án học tập'), findsOneWidget);
    });
  });

  group('Group F: Trạng thái toàn trang (S39 - S41)', () {
    testWidgets('S39: Offline screen renders retry action', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(SystemStatusScreen.offline()),
      );
      expect(find.text('Mất kết nối Internet'), findsOneWidget);
      expect(find.text('Thử lại kết nối'), findsOneWidget);
    });

    testWidgets('S40: Error screen renders error message and retry', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget(SystemStatusScreen.error()));
      expect(find.text('Đã xảy ra lỗi hệ thống'), findsOneWidget);
      expect(find.text('Thử lại kết nối'), findsOneWidget);
    });

    testWidgets('S41: Not found screen renders 404 message and return CTA', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(
          SystemStatusScreen.notFound(attemptedPath: '/invalid-route'),
        ),
      );
      expect(find.text('S41'), findsOneWidget);
      expect(find.text('Không tìm thấy trang (404)'), findsOneWidget);
      expect(find.text('Về Trang chủ'), findsOneWidget);
    });
  });

  group('Responsive Layout: Viewport tests', () {
    testWidgets(
      'Narrow mobile (360x780): HomeScreen renders without overflow',
      (tester) async {
        tester.view.physicalSize = const Size(360, 780);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          buildTestableWidget(const HomeScreen(), size: const Size(360, 780)),
        );
        expect(find.text('OPENFLIX'), findsOneWidget);
        await tester.pump(const Duration(milliseconds: 300));
      },
    );

    testWidgets('Tablet/Wide (800x1200): HomeScreen renders gracefully', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        buildTestableWidget(const HomeScreen(), size: const Size(800, 1200)),
      );
      expect(find.text('OPENFLIX'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 300));
    });
  });
}
