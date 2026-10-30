import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:transit_kit/transit_kit.dart';

import '../../features/account/about_screen.dart';
import '../../features/account/account_screen.dart';
import '../../features/account/feedback_screen.dart';
import '../../features/account/language_screen.dart';
import '../../features/account/me_screen.dart';
import '../../features/account/notifications_screen.dart';
import '../../features/account/password_screen.dart';
import '../../features/account/plans_screen.dart';
import '../../features/account/playback_settings_screen.dart';
import '../../features/account/profile_edit_screen.dart';
import '../../features/account/profiles_screen.dart';
import '../../features/account/settings_screen.dart';
import '../../features/admin/admin_auth_gate_screen.dart';
import '../../features/admin/admin_movie_form_screen.dart';
import '../../features/admin/admin_movie_list_screen.dart';
import '../../features/admin/server_monitor_screen.dart';
import '../../features/auth/forgot_password_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/onboarding_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/auth/splash_screen.dart';
import '../../features/auth/welcome_screen.dart';
import '../../features/discover/filter_screen.dart';
import '../../features/discover/genres_screen.dart';
import '../../features/discover/hot_screen.dart';
import '../../features/discover/movie_grid_screen.dart';
import '../../features/discover/search_screen.dart';
import '../../features/discover/top10_screen.dart';
import '../../features/library/continue_watching_screen.dart';
import '../../features/library/downloads_screen.dart';
import '../../features/library/liked_movies_screen.dart';
import '../../features/library/my_list_screen.dart';
import '../../features/library/watch_history_screen.dart';
import '../../features/system/contact_screen.dart';
import '../../features/system/help_screen.dart';
import '../../features/system/system_status_screen.dart';
import '../../features/watch/audio_subtitle_screen.dart';
import '../../features/watch/detail_screen.dart';
import '../../features/watch/episodes_screen.dart';
import '../../features/watch/reviews_screen.dart';
import '../../features/watch/similar_movies_screen.dart';
import '../../features/watch/trailer_screen.dart';
import '../../features/watch/write_review_screen.dart';
import '../../models/movie_model.dart';
import '../../presentation/screens/shell/main_tabs_screen.dart';
import '../../services/auth_service.dart';
import '../../screens/home_screen.dart';
import '../../screens/player_screen.dart';
import '../../features/cinema/cinema_article_detail_screen.dart';
import '../../features/cinema/cinema_checkout_screen.dart';
import '../../features/cinema/cinema_concessions_screen.dart';
import '../../features/cinema/cinema_hub_screen.dart';
import '../../features/cinema/cinema_movie_detail_screen.dart';
import '../../features/cinema/cinema_news_screen.dart';
import '../../features/cinema/cinema_seat_selection_screen.dart';
import '../../features/cinema/cinema_ticket_screen.dart';
import '../../features/cinema/my_cinema_tickets_screen.dart';
import '../../dark_luxury_background.dart';
import '../../models/cinema/cinema_models.dart';

TransitPage<T> _wavesTransitPage<T>({
  required LocalKey key,
  required Widget child,
  required TransitType type,
  required Duration duration,
  required Curve curve,
  bool fullscreenDialog = false,
}) {
  return TransitPage<T>(
    key: key,
    type: type,
    duration: duration,
    curve: curve,
    fullscreenDialog: fullscreenDialog,
    // KHÔNG bọc thêm nền động ở đây: nền đã có duy nhất một bản ở cấp app
    // (`ThemedBackdrop` trong `MaterialApp.builder`). Trước đây mỗi route tự
    // dựng thêm một shader nền + một `ListenableBuilder` theo theme, nên lúc
    // chuyển màn có 2–3 shader toàn màn hình cùng chạy và mỗi lần đổi theme
    // toàn bộ nội dung route bị remount.
    child: child,
  );
}

/// Trang chuyển tab của bottom navigation: hiển thị **tức thì**, không chạy
/// transition.
///
/// `StatefulShellRoute.indexedStack` vốn đã đổi tab bằng cách bật index của
/// stack, nên transition chỉ phát sinh ở lần đầu mở mỗi tab. Ở lần đầu đó, một
/// [FadeTransition] phủ lên toàn trang sẽ buộc engine dựng một `saveLayer` cho
/// cả màn hình, và mọi widget kính mờ bên trong (chip thể loại, hero, bottom
/// bar) phải chạy lại lớp BackdropFilter mỗi frame — nguyên nhân chính của
/// hiện tượng giật khi bấm 5 nút bottom bar. Đổi tab tức thì vừa đúng chuẩn
/// điều hướng tab, vừa bỏ được toàn bộ chi phí đó.
TransitPage<T> _instantBranchPage<T>({
  required LocalKey key,
  required Widget child,
}) {
  return TransitPage<T>(
    key: key,
    duration: Duration.zero,
    reverseDuration: Duration.zero,
    transitionBuilder: (context, animation, secondaryAnimation, child) => child,
    child: child,
  );
}

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

/// Cầu nối `Listenable` chỉ phát khi trạng thái đăng nhập đổi.
///
/// Dùng làm `refreshListenable` cho [GoRouter] để router không phải đánh giá
/// lại điều hướng mỗi khi `AuthService.notifyListeners()` được gọi vì lý do
/// khác (đổi ảnh đại diện, đổi tên hiển thị…).
class _AuthGateListenable extends ChangeNotifier {
  _AuthGateListenable() {
    _lastIsLoggedIn = AuthService.instance.isLoggedIn;
    AuthService.instance.addListener(_handleAuthChanged);
  }

  late bool _lastIsLoggedIn;

  void _handleAuthChanged() {
    final bool current = AuthService.instance.isLoggedIn;
    if (current == _lastIsLoggedIn) return;
    _lastIsLoggedIn = current;
    notifyListeners();
  }
}

class AppRouter {
  /// Các tuyến chỉ dành cho phiên CHƯA đăng nhập (màn hình xác thực).
  ///
  /// Khi phiên đã đăng nhập, người dùng phải được đưa thẳng vào app thay vì
  /// bị kẹt ở màn Đăng nhập / Đăng ký / Chào mừng (nguồn gốc bug "đăng ký xong
  /// lại nhảy ra màn đăng nhập").
  static const Set<String> _guestOnlyRoutes = <String>{
    '/login',
    '/register',
    '/welcome',
  };

  /// Các tuyến chứa DỮ LIỆU CÁ NHÂN: khách vãng lai bị chuyển tới màn Đăng nhập
  /// kèm `?redirect=` để sau khi đăng nhập quay lại đúng màn đang muốn xem.
  ///
  /// Áp dụng cho cả tuyến con (ví dụ `/profiles/edit/new`).
  static const List<String> _protectedRoutePrefixes = <String>[
    '/me/list',
    '/me/continue',
    '/me/history',
    '/me/liked',
    '/me/notifications',
    '/me/downloads',
    '/me/account',
    '/me/password',
    '/profiles',
  ];

  static bool _isProtected(String path) => _protectedRoutePrefixes.any(
    (prefix) => path == prefix || path.startsWith('$prefix/'),
  );

  /// Chỉ thông báo cho router khi trạng thái ĐĂNG NHẬP thực sự đổi.
  ///
  /// Tránh việc đổi ảnh đại diện / tên hiển thị (cũng gọi `notifyListeners`)
  /// kích hoạt đánh giá lại điều hướng không cần thiết.
  static final _AuthGateListenable _authGate = _AuthGateListenable();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    // Tự động đánh giá lại điều hướng mỗi khi phiên đăng nhập thay đổi.
    refreshListenable: _authGate,
    redirect: (BuildContext context, GoRouterState state) {
      final bool isLoggedIn = AuthService.instance.isLoggedIn;
      final String path = state.uri.path;

      if (!isLoggedIn) {
        // Khách vãng lai được tự do duyệt toàn bộ app; chỉ các màn dữ liệu cá
        // nhân mới bị chặn và chuyển tới màn Đăng nhập (kèm redirect quay lại).
        if (_isProtected(path)) {
          final String target = Uri.encodeComponent(state.uri.toString());
          return '/login?redirect=$target';
        }
        return null;
      }

      // Phiên đã đăng nhập: không được kẹt ở màn hình xác thực.
      if (!_guestOnlyRoutes.contains(path)) return null;

      // Tôn trọng tham số ?redirect=... (ví dụ /watch/:id khi mở khóa phim).
      final String? redirectTarget = state.uri.queryParameters['redirect'];
      if (redirectTarget != null &&
          redirectTarget.isNotEmpty &&
          !_guestOnlyRoutes.contains(redirectTarget)) {
        return redirectTarget;
      }

      // Mặc định: đưa thẳng vào ứng dụng.
      return '/';
    },
    routes: [
      // S01: Splash Screen — Mở đầu mượt mà, nhẹ nhàng
      GoRoute(
        path: '/splash',
        pageBuilder: (context, state) => _wavesTransitPage(
          key: state.pageKey,
          type: TransitType.fade,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
          child: const SplashScreen(),
        ),
      ),

      // 4-Tab Bottom Navigation Stateful Shell (S09, S10, S16, S30)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainTabsScreen(navigationShell: navigationShell);
        },
        branches: [
          // Tab 1: Trang chủ (S09)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                pageBuilder: (context, state) => _instantBranchPage(
                  key: state.pageKey,
                  child: const HomeScreen(),
                ),
              ),
            ],
          ),
          // Tab 2: Tìm kiếm (S10)
          StatefulShellBranch(
            preload: true,
            routes: [
              GoRoute(
                path: '/search',
                pageBuilder: (context, state) => _instantBranchPage(
                  key: state.pageKey,
                  child: const SearchScreen(),
                ),
              ),
            ],
          ),
          // Tab 3: Mới & Hot (S16)
          StatefulShellBranch(
            preload: true,
            routes: [
              GoRoute(
                path: '/hot',
                pageBuilder: (context, state) => _instantBranchPage(
                  key: state.pageKey,
                  child: const HotScreen(),
                ),
              ),
            ],
          ),
          // Tab 4: Đặt vé rạp toàn quốc (S43)
          StatefulShellBranch(
            preload: true,
            routes: [
              GoRoute(
                path: '/cinema',
                pageBuilder: (context, state) => _instantBranchPage(
                  key: state.pageKey,
                  child: const CinemaHubScreen(),
                ),
              ),
            ],
          ),
        ],
      ),

      // ==================== NHÓM A. KHỞI ĐỘNG & TÀI KHOẢN (S02 - S08) ====================
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) => _wavesTransitPage(
          key: state.pageKey,
          type: TransitType.slideRightFade,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          child: const OnboardingScreen(), // S02
        ),
      ),
      GoRoute(
        path: '/welcome',
        pageBuilder: (context, state) => _wavesTransitPage(
          key: state.pageKey,
          type: TransitType.fadeThrough,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          child: const WelcomeScreen(), // S03
        ),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) {
          final redirect = state.uri.queryParameters['redirect'];
          return _wavesTransitPage(
            key: state.pageKey,
            type: TransitType.fadeSlideUp,
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            child: LoginScreen(redirect: redirect), // S04
          );
        },
      ),
      GoRoute(
        path: '/register',
        pageBuilder: (context, state) {
          final redirect = state.uri.queryParameters['redirect'];
          return _wavesTransitPage(
            key: state.pageKey,
            type: TransitType.sharedAxisX,
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            child: RegisterScreen(redirect: redirect), // S05
          );
        },
      ),
      GoRoute(
        path: '/forgot-password',
        pageBuilder: (context, state) => _wavesTransitPage(
          key: state.pageKey,
          type: TransitType.slideRightFade,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          child: const ForgotPasswordScreen(), // S06
        ),
      ),
      GoRoute(
        path: '/profiles',
        pageBuilder: (context, state) => _wavesTransitPage(
          key: state.pageKey,
          type: TransitType.fadeThrough,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          child: const ProfilesScreen(), // S07
        ),
      ),
      GoRoute(
        path: '/profiles/edit/:id',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'] ?? 'new';
          return _wavesTransitPage(
            key: state.pageKey,
            type: TransitType.fadeSlideUp,
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            fullscreenDialog: true,
            child: ProfileEditScreen(profileId: id), // S08
          );
        },
      ),

      // ==================== NHÓM B. KHÁM PHÁ (S11 - S17) ====================
      GoRoute(
        path: '/search/results',
        pageBuilder: (context, state) {
          final query = state.uri.queryParameters['q'] ?? '';
          return _wavesTransitPage(
            key: state.pageKey,
            type: TransitType.fadeThrough,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            child: SearchScreen(initialQuery: query),
          );
        },
      ),
      GoRoute(
        path: '/search/filter',
        pageBuilder: (context, state) {
          final cat = state.uri.queryParameters['category'];
          final year = state.uri.queryParameters['year'];
          final sort = state.uri.queryParameters['sort'];
          return _wavesTransitPage(
            key: state.pageKey,
            type: TransitType.fadeSlideUp,
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            fullscreenDialog: true,
            child: FilterScreen(
              initialCategory: cat,
              initialYear: year,
              initialSort: sort,
            ), // S12
          );
        },
      ),
      GoRoute(
        path: '/genres',
        pageBuilder: (context, state) => _wavesTransitPage(
          key: state.pageKey,
          type: TransitType.slideRightFade,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          child: const GenresScreen(), // S13
        ),
      ),
      GoRoute(
        path: '/genre/:name',
        pageBuilder: (context, state) {
          final name = state.pathParameters['name'] ?? 'Tất cả';
          final year = state.uri.queryParameters['year'];
          final sort = state.uri.queryParameters['sort'];

          String title;
          if (name == 'Tất cả' || name == 'all') {
            if (year != null && year != 'Tất cả') {
              title = 'Phim năm $year';
            } else {
              title = 'Tất cả phim';
            }
          } else {
            if (year != null && year != 'Tất cả') {
              title = '$name ($year)';
            } else {
              title = 'Phim thể loại $name';
            }
          }

          return _wavesTransitPage(
            key: state.pageKey,
            type: TransitType.slideRightFade,
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            child: MovieGridScreen(
              title: title,
              category: name,
              year: year,
              sort: sort,
            ),
          );
        },
      ),
      GoRoute(
        path: '/see-all/:rowKey',
        pageBuilder: (context, state) {
          final key = state.pathParameters['rowKey'] ?? 'danh-sach';
          return _wavesTransitPage(
            key: state.pageKey,
            type: TransitType.slideRightFade,
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            child: MovieGridScreen(title: 'Xem tất cả', rowKey: key),
          );
        },
      ),
      GoRoute(
        path: '/top10',
        pageBuilder: (context, state) => _wavesTransitPage(
          key: state.pageKey,
          type: TransitType.slideRightFade,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          child: const Top10Screen(), // S17
        ),
      ),

      // ==================== NHÓM C. XEM PHIM & RẠP CHIẾU (S18 - S24) ====================
      GoRoute(
        path: '/movie/:id',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          // Truyền sẵn MovieModel khi mở từ danh sách: màn chi tiết dựng được
          // nội dung ngay frame đầu tiên, không phải hiện spinner rồi dựng lại
          // toàn bộ cây widget giữa lúc transition đang chạy.
          final preloaded = state.extra is MovieModel
              ? state.extra as MovieModel
              : null;
          return _wavesTransitPage(
            key: state.pageKey,
            // Chỉ trượt ngang, không phủ FadeTransition lên toàn trang: màn
            // chi tiết có ~10 bề mặt kính mờ, mỗi frame fade sẽ kéo theo một
            // saveLayer cho cả trang + 10 lượt BackdropFilter.
            type: TransitType.slideRight,
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            child: DetailScreen(movieId: id, initialMovie: preloaded), // S18
          );
        },
      ),
      GoRoute(
        path: '/movie/:id/trailer',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return _wavesTransitPage(
            key: state.pageKey,
            type: TransitType.fadeSlideUp,
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            child: TrailerScreen(movieId: id), // S19
          );
        },
      ),
      GoRoute(
        path: '/trailer/:id',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return _wavesTransitPage(
            key: state.pageKey,
            type: TransitType.fadeSlideUp,
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            child: TrailerScreen(movieId: id), // S19 Alias
          );
        },
      ),
      GoRoute(
        path: '/movie/:id/audio',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return _wavesTransitPage(
            key: state.pageKey,
            type: TransitType.fadeSlideUp,
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            fullscreenDialog: true,
            child: AudioSubtitleScreen(movieId: id),
          );
        },
      ),
      GoRoute(
        path: '/watch/:id',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return _wavesTransitPage(
            key: state.pageKey,
            // Trượt lên thuần tuý (không fade): màn phát chứa platform view
            // của video_player + các nút kính, fade toàn trang vừa đắt vừa
            // dễ lộ viền platform view.
            type: TransitType.slideUp,
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            child: PlayerScreen(movieId: id), // S20 Cinema Player
          );
        },
      ),
      GoRoute(
        path: '/movie/:id/episodes',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return _wavesTransitPage(
            key: state.pageKey,
            type: TransitType.fadeSlideUp,
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            fullscreenDialog: true,
            child: EpisodesScreen(movieId: id), // S21
          );
        },
      ),
      GoRoute(
        path: '/movie/:id/similar',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return _wavesTransitPage(
            key: state.pageKey,
            type: TransitType.slideRightFade,
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            child: SimilarMoviesScreen(movieId: id), // S22
          );
        },
      ),
      GoRoute(
        path: '/movie/:id/reviews',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return _wavesTransitPage(
            key: state.pageKey,
            type: TransitType.slideRightFade,
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            child: ReviewsScreen(movieId: id), // S23
          );
        },
      ),
      GoRoute(
        path: '/movie/:id/reviews/new',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return _wavesTransitPage(
            key: state.pageKey,
            type: TransitType.fadeSlideUp,
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            fullscreenDialog: true,
            child: WriteReviewScreen(movieId: id), // S24
          );
        },
      ),

      // ==================== NHÓM D. CÁ NHÂN & THƯ VIỆN (S25 - S30) ====================
      GoRoute(
        path: '/me',
        pageBuilder: (context, state) => _wavesTransitPage(
          key: state.pageKey,
          type: TransitType.slideRightFade,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          child: const MeScreen(), // S30
        ),
      ),
      GoRoute(
        path: '/me/list',
        pageBuilder: (context, state) => _wavesTransitPage(
          key: state.pageKey,
          type: TransitType.slideRightFade,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          child: const MyListScreen(), // S25
        ),
      ),
      GoRoute(
        path: '/me/continue',
        pageBuilder: (context, state) => _wavesTransitPage(
          key: state.pageKey,
          type: TransitType.slideRightFade,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          child: const ContinueWatchingScreen(), // S26
        ),
      ),
      GoRoute(
        path: '/me/history',
        pageBuilder: (context, state) => _wavesTransitPage(
          key: state.pageKey,
          type: TransitType.slideRightFade,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          child: const WatchHistoryScreen(), // S27
        ),
      ),
      GoRoute(
        path: '/me/liked',
        pageBuilder: (context, state) => _wavesTransitPage(
          key: state.pageKey,
          type: TransitType.slideRightFade,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          child: const LikedMoviesScreen(), // S28
        ),
      ),
      GoRoute(
        path: '/me/notifications',
        pageBuilder: (context, state) => _wavesTransitPage(
          key: state.pageKey,
          type: TransitType.slideRightFade,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          child: const NotificationsScreen(), // S29
        ),
      ),
      GoRoute(
        path: '/me/downloads',
        pageBuilder: (context, state) => _wavesTransitPage(
          key: state.pageKey,
          type: TransitType.slideRightFade,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          child: const DownloadsScreen(),
        ),
      ),

      // ==================== NHÓM E. TÀI KHOẢN & CÀI ĐẶT (S31 - S38, S42) ====================
      GoRoute(
        path: '/me/account',
        pageBuilder: (context, state) => _wavesTransitPage(
          key: state.pageKey,
          type: TransitType.cupertinoFade,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          child: const AccountScreen(), // S31
        ),
      ),
      GoRoute(
        path: '/me/password',
        pageBuilder: (context, state) => _wavesTransitPage(
          key: state.pageKey,
          type: TransitType.slideRightFade,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          child: const PasswordScreen(), // S32
        ),
      ),
      GoRoute(
        path: '/settings',
        pageBuilder: (context, state) => _wavesTransitPage(
          key: state.pageKey,
          type: TransitType.slideRightFade,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          child: const SettingsScreen(), // S33
        ),
      ),
      GoRoute(
        path: '/settings/playback',
        pageBuilder: (context, state) => _wavesTransitPage(
          key: state.pageKey,
          type: TransitType.slideRightFade,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          child: const PlaybackSettingsScreen(), // S34
        ),
      ),
      GoRoute(
        path: '/settings/language',
        pageBuilder: (context, state) => _wavesTransitPage(
          key: state.pageKey,
          type: TransitType.slideRightFade,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          child: const LanguageScreen(), // S35
        ),
      ),
      GoRoute(
        path: '/help',
        pageBuilder: (context, state) => _wavesTransitPage(
          key: state.pageKey,
          type: TransitType.slideRightFade,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          child: const HelpScreen(), // S36
        ),
      ),
      GoRoute(
        path: '/contact',
        pageBuilder: (context, state) => _wavesTransitPage(
          key: state.pageKey,
          type: TransitType.fadeSlideUp,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          fullscreenDialog: true,
          child: const ContactScreen(), // S37
        ),
      ),
      GoRoute(
        path: '/feedback',
        pageBuilder: (context, state) => _wavesTransitPage(
          key: state.pageKey,
          type: TransitType.fadeSlideUp,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          fullscreenDialog: true,
          child: const FeedbackScreen(),
        ),
      ),
      GoRoute(
        path: '/about',
        pageBuilder: (context, state) => _wavesTransitPage(
          key: state.pageKey,
          type: TransitType.slideRightFade,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          child: const AboutScreen(), // S38
        ),
      ),
      GoRoute(
        path: '/plans',
        pageBuilder: (context, state) => _wavesTransitPage(
          key: state.pageKey,
          type: TransitType.fadeSlideUp,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          child: const PlansScreen(), // S42 Premium
        ),
      ),

      // ==================== NHÓM F. TRẠNG THÁI TOÀN TRANG (S39 - S41) ====================
      GoRoute(
        path: '/offline',
        pageBuilder: (context, state) => _wavesTransitPage(
          key: state.pageKey,
          type: TransitType.fadeThrough,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          child: SystemStatusScreen.offline(), // S39
        ),
      ),
      GoRoute(
        path: '/error',
        pageBuilder: (context, state) => _wavesTransitPage(
          key: state.pageKey,
          type: TransitType.fadeThrough,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          child: SystemStatusScreen.error(), // S40
        ),
      ),
      GoRoute(
        path: '/404',
        pageBuilder: (context, state) => _wavesTransitPage(
          key: state.pageKey,
          type: TransitType.fadeThrough,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          child: SystemStatusScreen.notFound(), // S41
        ),
      ),
      GoRoute(
        path: '/not-found',
        pageBuilder: (context, state) => _wavesTransitPage(
          key: state.pageKey,
          type: TransitType.fadeThrough,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          child: SystemStatusScreen.notFound(), // S41
        ),
      ),

      // Admin Security Gate: Khóa xác thực quản trị viên (mật khẩu 123)
      GoRoute(
        path: '/admin/auth',
        pageBuilder: (context, state) => _wavesTransitPage(
          key: state.pageKey,
          type: TransitType.fadeSlideUp,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          child: AdminAuthGateScreen(
            onAuthenticated: () {
              final target = state.extra as String? ?? '/admin/movies';
              context.go(target);
            },
          ),
        ),
      ),

      // Admin Server Telemetry: Giám sát máy chủ thời gian thực
      GoRoute(
        path: '/admin/server',
        pageBuilder: (context, state) => _wavesTransitPage(
          key: state.pageKey,
          type: TransitType.slideRightFade,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          child: const ServerMonitorScreen(),
        ),
      ),

      // Admin Routes: Quản lý kho phim & Form tạo/sửa phim
      GoRoute(
        path: '/admin/movies',
        pageBuilder: (context, state) => _wavesTransitPage(
          key: state.pageKey,
          type: TransitType.slideRightFade,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          child: const AdminMovieListScreen(),
        ),
        routes: [
          GoRoute(
            path: 'create',
            pageBuilder: (context, state) => _wavesTransitPage(
              key: state.pageKey,
              type: TransitType.fadeSlideUp,
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutCubic,
              child: const AdminMovieFormScreen(),
            ),
          ),
          GoRoute(
            path: ':id/edit',
            pageBuilder: (context, state) {
              final movie = state.extra as MovieModel?;
              return _wavesTransitPage(
                key: state.pageKey,
                type: TransitType.fadeSlideUp,
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOutCubic,
                child: AdminMovieFormScreen(movie: movie),
              );
            },
          ),
        ],
      ),

      // ==========================================
      // MODULE ĐẶT VÉ PHIM RẠP (S43 - S51)
      // ==========================================

      // S44: Chi tiết phim rạp & suất chiếu
      GoRoute(
        path: '/cinema/movie/:id',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return _wavesTransitPage(
            key: state.pageKey,
            type: TransitType.slideRightFade,
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            child: CinemaMovieDetailScreen(movieId: id),
          );
        },
      ),

      // S45: Sơ đồ chọn ghế ngồi
      GoRoute(
        path: '/cinema/seat-selection',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return _wavesTransitPage(
            key: state.pageKey,
            type: TransitType.slideRightFade,
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            child: CinemaSeatSelectionScreen(
              movie: extra?['movie'] as CinemaMovieModel,
              theater: extra?['theater'] as CinemaTheaterModel,
              showtime: extra?['showtime'] as CinemaShowtimeModel,
            ),
          );
        },
      ),

      // S46: Chọn bắp nước & combo
      GoRoute(
        path: '/cinema/concessions',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return _wavesTransitPage(
            key: state.pageKey,
            type: TransitType.slideRightFade,
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            child: CinemaConcessionsScreen(
              movie: extra?['movie'] as CinemaMovieModel,
              theater: extra?['theater'] as CinemaTheaterModel,
              showtime: extra?['showtime'] as CinemaShowtimeModel,
              seatLabels: (extra?['seatLabels'] as List<String>?) ?? [],
              seatsPrice: (extra?['seatsPrice'] as int?) ?? 0,
            ),
          );
        },
      ),

      // S47: Thanh toán & giữ ghế
      GoRoute(
        path: '/cinema/checkout',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return _wavesTransitPage(
            key: state.pageKey,
            type: TransitType.slideRightFade,
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            child: CinemaCheckoutScreen(
              movie: extra?['movie'] as CinemaMovieModel,
              theater: extra?['theater'] as CinemaTheaterModel,
              showtime: extra?['showtime'] as CinemaShowtimeModel,
              seatLabels: (extra?['seatLabels'] as List<String>?) ?? [],
              concessions: (extra?['concessions'] as Map<String, int>?) ?? {},
              totalAmount: (extra?['totalAmount'] as int?) ?? 0,
            ),
          );
        },
      ),

      // S48: Vé điện tử / QR Code
      GoRoute(
        path: '/cinema/ticket/:bookingId',
        pageBuilder: (context, state) {
          final bookingId = state.pathParameters['bookingId'] ?? '';
          final booking = state.extra as CinemaBookingModel?;
          return _wavesTransitPage(
            key: state.pageKey,
            type: TransitType.fadeSlideUp,
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            child: CinemaTicketScreen(bookingId: bookingId, booking: booking),
          );
        },
      ),

      // S49: Vé của tôi
      GoRoute(
        path: '/cinema/my-tickets',
        pageBuilder: (context, state) => _wavesTransitPage(
          key: state.pageKey,
          type: TransitType.slideRightFade,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          child: const MyCinemaTicketsScreen(),
        ),
      ),

      // S50: Tin tức & Blog điện ảnh rạp
      GoRoute(
        path: '/cinema/news',
        pageBuilder: (context, state) => _wavesTransitPage(
          key: state.pageKey,
          type: TransitType.slideRightFade,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          child: const CinemaNewsScreen(),
        ),
      ),

      // S51: Chi tiết bài viết review
      GoRoute(
        path: '/cinema/news/:articleId',
        pageBuilder: (context, state) {
          final articleId = state.pathParameters['articleId'] ?? '';
          final article = state.extra as CinemaArticleModel?;
          return _wavesTransitPage(
            key: state.pageKey,
            type: TransitType.slideRightFade,
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            child: CinemaArticleDetailScreen(
              articleId: articleId,
              article: article,
            ),
          );
        },
      ),

      // Dark Luxury Wallpaper preview
      GoRoute(
        path: '/wallpaper',
        pageBuilder: (context, state) => _wavesTransitPage(
          key: state.pageKey,
          type: TransitType.fade,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: const DarkLuxuryWallpaper(),
        ),
      ),
      GoRoute(
        path: '/dark-luxury',
        pageBuilder: (context, state) => _wavesTransitPage(
          key: state.pageKey,
          type: TransitType.fade,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: const DarkLuxuryWallpaper(),
        ),
      ),
    ],

    // Trang 404 Route Not Found (nền dùng chung đã nằm ở cấp app)
    errorBuilder: (context, state) =>
        SystemStatusScreen.notFound(attemptedPath: state.uri.toString()),
  );
}
