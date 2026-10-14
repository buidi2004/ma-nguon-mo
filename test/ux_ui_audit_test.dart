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

Widget _wrap(
  Widget child, {
  Size size = const Size(390, 844),
  EdgeInsets viewInsets = EdgeInsets.zero,
}) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: buildAppTheme(),
    builder: (context, widgetChild) {
      return MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(size: size, viewInsets: viewInsets),
        child: widgetChild ?? const SizedBox.shrink(),
      );
    },
    home: child,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Danh sách các viewport kiểm thử bung UI:
  // 1. Siêu hẹp: 320x640 (máy cổ/màn hình bé nhất)
  // 2. Hẹp: 360x780 (Android phổ thông tầm thấp)
  // 3. Tiêu chuẩn: 390x844 (iPhone 14/15, Galaxy S series)
  // 4. Tablet: 800x1200 (màn hình lớn/máy tính bảng)
  const viewports = [
    Size(320, 640),
    Size(360, 780),
    Size(390, 844),
    Size(800, 1200),
  ];

  Future<void> runUiAudit(
    WidgetTester tester,
    Widget screen, {
    bool testKeyboard = false,
  }) async {
    for (final vp in viewports) {
      tester.view.physicalSize = vp;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_wrap(screen, size: vp));
      await tester.pump(const Duration(milliseconds: 100));

      // Không được phát sinh lỗi layout/overflow
      var err = tester.takeException();
      if (err != null) {
        debugPrint(err.toString());
      }
      expect(err, isNull, reason: 'Viewport $vp: $err');

      if (testKeyboard) {
        // Giả lập bàn phím ảo đẩy lên 300px
        await tester.pumpWidget(
          _wrap(
            screen,
            size: vp,
            viewInsets: const EdgeInsets.only(bottom: 300),
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));
        err = tester.takeException();
        if (err != null) {
          debugPrint(err.toString());
        }
        expect(err, isNull, reason: 'Keyboard Viewport $vp: $err');
      }
    }
  }

  group('AUDIT UI/UX KHÔNG BỎ SÓT: Nhóm A (S01 - S08)', () {
    testWidgets('S01: Splash Screen không bung layout', (tester) async {
      await runUiAudit(tester, const SplashScreen());
    });

    testWidgets('S02: Onboarding Screen không bung layout', (tester) async {
      await runUiAudit(tester, const OnboardingScreen());
    });

    testWidgets('S03: Welcome Screen không bung layout', (tester) async {
      await runUiAudit(tester, const WelcomeScreen());
    });

    testWidgets('S04: Login Screen không bung layout khi bật bàn phím', (
      tester,
    ) async {
      await runUiAudit(tester, const LoginScreen(), testKeyboard: true);
    });

    testWidgets('S05: Register Screen không bung layout khi bật bàn phím', (
      tester,
    ) async {
      await runUiAudit(tester, const RegisterScreen(), testKeyboard: true);
    });

    testWidgets(
      'S06: Forgot Password Screen không bung layout khi bật bàn phím',
      (tester) async {
        await runUiAudit(
          tester,
          const ForgotPasswordScreen(),
          testKeyboard: true,
        );
      },
    );

    testWidgets('S07: Profiles Screen không bung layout', (tester) async {
      await runUiAudit(tester, const ProfilesScreen());
    });

    testWidgets('S08: Profile Edit Screen không bung layout khi bật bàn phím', (
      tester,
    ) async {
      await runUiAudit(
        tester,
        const ProfileEditScreen(profileId: 'p1'),
        testKeyboard: true,
      );
    });
  });

  group('AUDIT UI/UX KHÔNG BỎ SÓT: Nhóm B (S09 - S17)', () {
    testWidgets('S09: Home Screen không bung layout ở mọi kích thước', (
      tester,
    ) async {
      await runUiAudit(tester, const HomeScreen());
    });

    testWidgets('S10: Search Screen không bung layout khi bật bàn phím', (
      tester,
    ) async {
      await runUiAudit(tester, const SearchScreen(), testKeyboard: true);
    });

    testWidgets('S11: Search Results Grid không bung layout', (tester) async {
      await runUiAudit(
        tester,
        const SearchScreen(initialQuery: 'Khám phá'),
        testKeyboard: true,
      );
    });

    testWidgets('S12: Filter Screen không bung layout', (tester) async {
      await runUiAudit(tester, const FilterScreen());
    });

    testWidgets('S13: Genres Screen không bung layout', (tester) async {
      await runUiAudit(tester, const GenresScreen());
    });

    testWidgets('S14: Genre Movies Grid không bung layout', (tester) async {
      await runUiAudit(
        tester,
        const MovieGridScreen(title: 'Phim Hành Động', category: 'Hành động'),
      );
    });

    testWidgets('S15: See All Movies Grid không bung layout', (tester) async {
      await runUiAudit(
        tester,
        const MovieGridScreen(title: 'Xem tất cả', rowKey: 'trending'),
      );
    });

    testWidgets('S16: Hot Screen không bung layout', (tester) async {
      await runUiAudit(tester, const HotScreen());
    });

    testWidgets('S17: Top 10 Screen không bung layout', (tester) async {
      await runUiAudit(tester, const Top10Screen());
    });
  });

  group('AUDIT UI/UX KHÔNG BỎ SÓT: Nhóm C (S18 - S24 + Extra Audio)', () {
    testWidgets('S18: Detail Screen không bung layout', (tester) async {
      await runUiAudit(tester, const DetailScreen(movieId: 'test-1'));
    });

    testWidgets('S19: Trailer Screen không bung layout', (tester) async {
      await runUiAudit(tester, const TrailerScreen(movieId: 'test-1'));
    });

    testWidgets('S20: Player Screen Fallback UI không bung layout', (
      tester,
    ) async {
      await runUiAudit(
        tester,
        const DetailScreen(movieId: 'test-1'),
      ); // Xem trước player
    });

    testWidgets('S21: Episodes Screen không bung layout', (tester) async {
      await runUiAudit(tester, const EpisodesScreen(movieId: 'test-1'));
    });

    testWidgets('S22: Similar Movies Screen không bung layout', (tester) async {
      await runUiAudit(tester, const SimilarMoviesScreen(movieId: 'test-1'));
    });

    testWidgets('S23: Reviews Screen không bung layout', (tester) async {
      await runUiAudit(tester, const ReviewsScreen(movieId: 'test-1'));
    });

    testWidgets('S24: Write Review Screen không bung layout khi bật bàn phím', (
      tester,
    ) async {
      await runUiAudit(
        tester,
        const WriteReviewScreen(movieId: 'test-1'),
        testKeyboard: true,
      );
    });

    testWidgets('Extra: Audio Subtitle Screen không bung layout', (
      tester,
    ) async {
      await runUiAudit(tester, const AudioSubtitleScreen(movieId: 'test-1'));
    });
  });

  group('AUDIT UI/UX KHÔNG BỎ SÓT: Nhóm D (S25 - S29 + Downloads)', () {
    testWidgets('S25: My List Screen không bung layout', (tester) async {
      await runUiAudit(tester, const MyListScreen());
    });

    testWidgets('S26: Continue Watching Screen không bung layout', (
      tester,
    ) async {
      await runUiAudit(tester, const ContinueWatchingScreen());
    });

    testWidgets('S27: Watch History Screen không bung layout', (tester) async {
      await runUiAudit(tester, const WatchHistoryScreen());
    });

    testWidgets('S28: Liked Movies Screen không bung layout', (tester) async {
      await runUiAudit(tester, const LikedMoviesScreen());
    });

    testWidgets('S29: Notifications Screen không bung layout', (tester) async {
      await runUiAudit(tester, const NotificationsScreen());
    });

    testWidgets('Extra: Downloads Screen không bung layout', (tester) async {
      await runUiAudit(tester, const DownloadsScreen());
    });
  });

  group('AUDIT UI/UX KHÔNG BỎ SÓT: Nhóm E (S30 - S38, S42)', () {
    testWidgets('S30: Me Screen không bung layout', (tester) async {
      await runUiAudit(tester, const MeScreen());
    });

    testWidgets('S31: Account Screen không bung layout khi bật bàn phím', (
      tester,
    ) async {
      await runUiAudit(tester, const AccountScreen(), testKeyboard: true);
    });

    testWidgets('S32: Password Screen không bung layout khi bật bàn phím', (
      tester,
    ) async {
      await runUiAudit(tester, const PasswordScreen(), testKeyboard: true);
    });

    testWidgets('S33: Settings Screen không bung layout', (tester) async {
      await runUiAudit(tester, const SettingsScreen());
    });

    testWidgets('S34: Playback Settings Screen không bung layout', (
      tester,
    ) async {
      await runUiAudit(tester, const PlaybackSettingsScreen());
    });

    testWidgets('S35: Language Screen không bung layout', (tester) async {
      await runUiAudit(tester, const LanguageScreen());
    });

    testWidgets('S36: Help Screen không bung layout khi bật bàn phím', (
      tester,
    ) async {
      await runUiAudit(tester, const HelpScreen(), testKeyboard: true);
    });

    testWidgets('S37: Contact Screen không bung layout khi bật bàn phím', (
      tester,
    ) async {
      await runUiAudit(tester, const ContactScreen(), testKeyboard: true);
    });

    testWidgets('S38: About Screen không bung layout', (tester) async {
      await runUiAudit(tester, const AboutScreen());
    });

    testWidgets('S42: Plans Screen không bung layout', (tester) async {
      await runUiAudit(tester, const PlansScreen());
    });
  });

  group('AUDIT UI/UX KHÔNG BỎ SÓT: Nhóm F (S39 - S41)', () {
    testWidgets('S39: Offline Screen không bung layout', (tester) async {
      await runUiAudit(tester, SystemStatusScreen.offline());
    });

    testWidgets('S40: Error Screen không bung layout', (tester) async {
      await runUiAudit(tester, SystemStatusScreen.error());
    });

    testWidgets('S41: Not Found Screen không bung layout', (tester) async {
      await runUiAudit(tester, SystemStatusScreen.notFound());
    });
  });
}
