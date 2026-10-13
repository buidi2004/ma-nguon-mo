import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/account/about_screen.dart';
import '../../features/account/account_screen.dart';
import '../../features/account/language_screen.dart';
import '../../features/account/me_screen.dart';
import '../../features/account/notifications_screen.dart';
import '../../features/account/password_screen.dart';
import '../../features/account/plans_screen.dart';
import '../../features/account/playback_settings_screen.dart';
import '../../features/account/profile_edit_screen.dart';
import '../../features/account/profiles_screen.dart';
import '../../features/account/settings_screen.dart';
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
import '../../features/watch/trailer_screen.dart';
import '../../features/watch/write_review_screen.dart';
import '../../features/discover/top10_screen.dart';
import '../../features/watch/similar_movies_screen.dart';
import '../../screens/home_screen.dart';
import '../../screens/player_screen.dart';
import '../../presentation/screens/shell/main_tabs_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

class AppRouter {
  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    routes: [
      // S01: Splash Screen
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
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
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          // Tab 2: Tìm kiếm (S10)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/search',
                builder: (context, state) => const SearchScreen(),
              ),
            ],
          ),
          // Tab 3: Mới & Hot (S16)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/hot',
                builder: (context, state) => const HotScreen(),
              ),
            ],
          ),
          // Tab 4: Tôi / Trung tâm cá nhân (S30)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/me',
                builder: (context, state) => const MeScreen(),
              ),
            ],
          ),
        ],
      ),

      // ==================== NHÓM A. KHỞI ĐỘNG & TÀI KHOẢN ====================
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(), // S02
      ),
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(), // S03
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(), // S04
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(), // S05
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(), // S06
      ),
      GoRoute(
        path: '/profiles',
        builder: (context, state) => const ProfilesScreen(), // S07
      ),
      GoRoute(
        path: '/profiles/edit/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? 'new';
          return ProfileEditScreen(profileId: id); // S08
        },
      ),

      // ==================== NHÓM B. KHÁM PHÁ ====================
      GoRoute(
        path: '/search/results',
        builder: (context, state) {
          final query = state.uri.queryParameters['q'] ?? '';
          return SearchScreen(initialQuery: query);
        },
      ),
      GoRoute(
        path: '/search/filter',
        builder: (context, state) => const FilterScreen(), // S12
      ),
      GoRoute(
        path: '/genres',
        builder: (context, state) => const GenresScreen(), // S13
      ),
      GoRoute(
        path: '/genre/:name',
        builder: (context, state) {
          final name = state.pathParameters['name'] ?? 'Tất cả';
          return MovieGridScreen(title: 'Phim thể loại $name', category: name);
        },
      ),
      GoRoute(
        path: '/see-all/:rowKey',
        builder: (context, state) {
          final key = state.pathParameters['rowKey'] ?? 'danh-sach';
          return MovieGridScreen(title: 'Xem tất cả', rowKey: key);
        },
      ),
      GoRoute(
        path: '/top10',
        builder: (context, state) => const Top10Screen(), // S17
      ),

      // ==================== NHÓM C. XEM PHIM ====================
      GoRoute(
        path: '/movie/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return DetailScreen(movieId: id); // S18
        },
      ),
      GoRoute(
        path: '/movie/:id/trailer',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return TrailerScreen(movieId: id); // S19
        },
      ),
      GoRoute(
        path: '/movie/:id/audio',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return AudioSubtitleScreen(movieId: id);
        },
      ),
      GoRoute(
        path: '/watch/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return PlayerScreen(movieId: id); // S20
        },
      ),
      GoRoute(
        path: '/movie/:id/episodes',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return EpisodesScreen(movieId: id); // S21
        },
      ),
      GoRoute(
        path: '/movie/:id/similar',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return SimilarMoviesScreen(movieId: id); // S22
        },
      ),
      GoRoute(
        path: '/movie/:id/reviews',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return ReviewsScreen(movieId: id); // S23
        },
      ),
      GoRoute(
        path: '/movie/:id/reviews/new',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return WriteReviewScreen(movieId: id); // S24
        },
      ),

      // ==================== NHÓM D. CÁ NHÂN ====================
      GoRoute(
        path: '/me/list',
        builder: (context, state) => const MyListScreen(), // S25
      ),
      GoRoute(
        path: '/me/continue',
        builder: (context, state) => const ContinueWatchingScreen(), // S26
      ),
      GoRoute(
        path: '/me/history',
        builder: (context, state) => const WatchHistoryScreen(), // S27
      ),
      GoRoute(
        path: '/me/liked',
        builder: (context, state) => const LikedMoviesScreen(), // S28
      ),
      GoRoute(
        path: '/me/notifications',
        builder: (context, state) => const NotificationsScreen(), // S29
      ),
      GoRoute(
        path: '/me/downloads',
        builder: (context, state) => const DownloadsScreen(),
      ),

      // ==================== NHÓM E. TÀI KHOẢN & CÀI ĐẶT ====================
      GoRoute(
        path: '/me/account',
        builder: (context, state) => const AccountScreen(), // S31
      ),
      GoRoute(
        path: '/me/password',
        builder: (context, state) => const PasswordScreen(), // S32
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(), // S33
      ),
      GoRoute(
        path: '/settings/playback',
        builder: (context, state) => const PlaybackSettingsScreen(), // S34
      ),
      GoRoute(
        path: '/settings/language',
        builder: (context, state) => const LanguageScreen(), // S35
      ),
      GoRoute(
        path: '/help',
        builder: (context, state) => const HelpScreen(), // S36
      ),
      GoRoute(
        path: '/contact',
        builder: (context, state) => const ContactScreen(), // S37
      ),
      GoRoute(
        path: '/feedback',
        builder: (context, state) => const ContactScreen(), // S37 alias
      ),
      GoRoute(
        path: '/about',
        builder: (context, state) => const AboutScreen(), // S38
      ),
      GoRoute(
        path: '/plans',
        builder: (context, state) => const PlansScreen(), // S42
      ),

      // ==================== NHÓM F. TRẠNG THÁI TOÀN TRANG ====================
      GoRoute(
        path: '/offline',
        builder: (context, state) => SystemStatusScreen.offline(), // S39
      ),
      GoRoute(
        path: '/error',
        builder: (context, state) => SystemStatusScreen.error(), // S40
      ),
      GoRoute(
        path: '/404',
        builder: (context, state) => SystemStatusScreen.notFound(), // S41
      ),
      GoRoute(
        path: '/not-found',
        builder: (context, state) => SystemStatusScreen.notFound(), // S41
      ),
    ],

    // Trang 404 Route Not Found
    errorBuilder: (context, state) =>
        SystemStatusScreen.notFound(attemptedPath: state.uri.toString()),
  );
}
