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
import '../../models/cinema/cinema_models.dart';

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
        pageBuilder: (context, state) => TransitPage(
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
                pageBuilder: (context, state) => TransitPage(
                  key: state.pageKey,
                  type: TransitType.fadeThrough,
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeInOutCubic,
                  child: const HomeScreen(),
                ),
              ),
            ],
          ),
          // Tab 2: Tìm kiếm (S10)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/search',
                pageBuilder: (context, state) => TransitPage(
                  key: state.pageKey,
                  type: TransitType.fadeThrough,
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeInOutCubic,
                  child: const SearchScreen(),
                ),
              ),
            ],
          ),
          // Tab 3: Mới & Hot (S16)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/hot',
                pageBuilder: (context, state) => TransitPage(
                  key: state.pageKey,
                  type: TransitType.fadeThrough,
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeInOutCubic,
                  child: const HotScreen(),
                ),
              ),
            ],
          ),
          // Tab 4: Đặt vé rạp toàn quốc (S43)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/cinema',
                pageBuilder: (context, state) => TransitPage(
                  key: state.pageKey,
                  type: TransitType.fadeThrough,
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeInOutCubic,
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
        pageBuilder: (context, state) => TransitPage(
          key: state.pageKey,
          type: TransitType.slideRightFade,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          child: const OnboardingScreen(), // S02
        ),
      ),
      GoRoute(
        path: '/welcome',
        pageBuilder: (context, state) => TransitPage(
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
          return TransitPage(
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
          return TransitPage(
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
        pageBuilder: (context, state) => TransitPage(
          key: state.pageKey,
          type: TransitType.slideRightFade,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          child: const ForgotPasswordScreen(), // S06
        ),
      ),
      GoRoute(
        path: '/profiles',
        pageBuilder: (context, state) => TransitPage(
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
          return TransitPage(
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
          return TransitPage(
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
        pageBuilder: (context, state) => TransitPage(
          key: state.pageKey,
          type: TransitType.fadeSlideUp,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          fullscreenDialog: true,
          child: const FilterScreen(), // S12
        ),
      ),
      GoRoute(
        path: '/genres',
        pageBuilder: (context, state) => TransitPage(
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
          return TransitPage(
            key: state.pageKey,
            type: TransitType.slideRightFade,
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            child: MovieGridScreen(
              title: 'Phim thể loại $name',
              category: name,
            ),
          );
        },
      ),
      GoRoute(
        path: '/see-all/:rowKey',
        pageBuilder: (context, state) {
          final key = state.pathParameters['rowKey'] ?? 'danh-sach';
          return TransitPage(
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
        pageBuilder: (context, state) => TransitPage(
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
          return TransitPage(
            key: state.pageKey,
            type: TransitType.slideRightFade,
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            child: DetailScreen(movieId: id), // S18
          );
        },
      ),
      GoRoute(
        path: '/movie/:id/trailer',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return TransitPage(
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
          return TransitPage(
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
          return TransitPage(
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
          return TransitPage(
            key: state.pageKey,
            type: TransitType.fadeSlideUp,
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
          return TransitPage(
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
          return TransitPage(
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
          return TransitPage(
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
          return TransitPage(
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
        pageBuilder: (context, state) => TransitPage(
          key: state.pageKey,
          type: TransitType.slideRightFade,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          child: const MeScreen(), // S30
        ),
      ),
      GoRoute(
        path: '/me/list',
        pageBuilder: (context, state) => TransitPage(
          key: state.pageKey,
          type: TransitType.slideRightFade,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          child: const MyListScreen(), // S25
        ),
      ),
      GoRoute(
        path: '/me/continue',
        pageBuilder: (context, state) => TransitPage(
          key: state.pageKey,
          type: TransitType.slideRightFade,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          child: const ContinueWatchingScreen(), // S26
        ),
      ),
      GoRoute(
        path: '/me/history',
        pageBuilder: (context, state) => TransitPage(
          key: state.pageKey,
          type: TransitType.slideRightFade,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          child: const WatchHistoryScreen(), // S27
        ),
      ),
      GoRoute(
        path: '/me/liked',
        pageBuilder: (context, state) => TransitPage(
          key: state.pageKey,
          type: TransitType.slideRightFade,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          child: const LikedMoviesScreen(), // S28
        ),
      ),
      GoRoute(
        path: '/me/notifications',
        pageBuilder: (context, state) => TransitPage(
          key: state.pageKey,
          type: TransitType.slideRightFade,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          child: const NotificationsScreen(), // S29
        ),
      ),
      GoRoute(
        path: '/me/downloads',
        pageBuilder: (context, state) => TransitPage(
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
        pageBuilder: (context, state) => TransitPage(
          key: state.pageKey,
          type: TransitType.cupertinoFade,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          child: const AccountScreen(), // S31
        ),
      ),
      GoRoute(
        path: '/me/password',
        pageBuilder: (context, state) => TransitPage(
          key: state.pageKey,
          type: TransitType.slideRightFade,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          child: const PasswordScreen(), // S32
        ),
      ),
      GoRoute(
        path: '/settings',
        pageBuilder: (context, state) => TransitPage(
          key: state.pageKey,
          type: TransitType.slideRightFade,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          child: const SettingsScreen(), // S33
        ),
      ),
      GoRoute(
        path: '/settings/playback',
        pageBuilder: (context, state) => TransitPage(
          key: state.pageKey,
          type: TransitType.slideRightFade,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          child: const PlaybackSettingsScreen(), // S34
        ),
      ),
      GoRoute(
        path: '/settings/language',
        pageBuilder: (context, state) => TransitPage(
          key: state.pageKey,
          type: TransitType.slideRightFade,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          child: const LanguageScreen(), // S35
        ),
      ),
      GoRoute(
        path: '/help',
        pageBuilder: (context, state) => TransitPage(
          key: state.pageKey,
          type: TransitType.slideRightFade,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          child: const HelpScreen(), // S36
        ),
      ),
      GoRoute(
        path: '/contact',
        pageBuilder: (context, state) => TransitPage(
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
        pageBuilder: (context, state) => TransitPage(
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
        pageBuilder: (context, state) => TransitPage(
          key: state.pageKey,
          type: TransitType.slideRightFade,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          child: const AboutScreen(), // S38
        ),
      ),
      GoRoute(
        path: '/plans',
        pageBuilder: (context, state) => TransitPage(
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
        pageBuilder: (context, state) => TransitPage(
          key: state.pageKey,
          type: TransitType.fadeThrough,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          child: SystemStatusScreen.offline(), // S39
        ),
      ),
      GoRoute(
        path: '/error',
        pageBuilder: (context, state) => TransitPage(
          key: state.pageKey,
          type: TransitType.fadeThrough,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          child: SystemStatusScreen.error(), // S40
        ),
      ),
      GoRoute(
        path: '/404',
        pageBuilder: (context, state) => TransitPage(
          key: state.pageKey,
          type: TransitType.fadeThrough,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          child: SystemStatusScreen.notFound(), // S41
        ),
      ),
      GoRoute(
        path: '/not-found',
        pageBuilder: (context, state) => TransitPage(
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
        pageBuilder: (context, state) => TransitPage(
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
        pageBuilder: (context, state) => TransitPage(
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
        pageBuilder: (context, state) => TransitPage(
          key: state.pageKey,
          type: TransitType.slideRightFade,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          child: const AdminMovieListScreen(),
        ),
        routes: [
          GoRoute(
            path: 'create',
            pageBuilder: (context, state) => TransitPage(
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
              return TransitPage(
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
          return TransitPage(
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
          return TransitPage(
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
          return TransitPage(
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
          return TransitPage(
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
          return TransitPage(
            key: state.pageKey,
            type: TransitType.fadeSlideUp,
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            child: CinemaTicketScreen(
              bookingId: bookingId,
              booking: booking,
            ),
          );
        },
      ),

      // S49: Vé của tôi
      GoRoute(
        path: '/cinema/my-tickets',
        pageBuilder: (context, state) => TransitPage(
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
        pageBuilder: (context, state) => TransitPage(
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
          return TransitPage(
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
    ],

    // Trang 404 Route Not Found
    errorBuilder: (context, state) =>
        SystemStatusScreen.notFound(attemptedPath: state.uri.toString()),
  );
}
