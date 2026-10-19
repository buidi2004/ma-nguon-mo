// Capture màn hình S01–S14 (tách từ capture_all_42_screens_test.dart).
//
// Nội dung test giữ nguyên; setup chung nằm ở `visual_harness.dart`.
import 'package:flutter_test/flutter_test.dart';
import 'package:openflix/features/account/profile_edit_screen.dart';
import 'package:openflix/features/account/profiles_screen.dart';
import 'package:openflix/features/auth/forgot_password_screen.dart';
import 'package:openflix/features/auth/login_screen.dart';
import 'package:openflix/features/auth/onboarding_screen.dart';
import 'package:openflix/features/auth/register_screen.dart';
import 'package:openflix/features/auth/splash_screen.dart';
import 'package:openflix/features/auth/welcome_screen.dart';
import 'package:openflix/features/discover/filter_screen.dart';
import 'package:openflix/features/discover/genres_screen.dart';
import 'package:openflix/features/discover/movie_grid_screen.dart';
import 'package:openflix/features/discover/search_screen.dart';
import 'package:openflix/screens/home_screen.dart';

import 'visual_harness.dart';

void main() {
  setUpVisualHarness();

  group('Capture 42 Screens - True Mobile Portrait 1080x2316', () {
    testWidgets('S01: Splash Screen', (tester) async {
      await captureScreenWidget(tester, const SplashScreen(), 'S01_splash.png');
    });

    testWidgets('S02: Onboarding Screen', (tester) async {
      await captureScreenWidget(tester, const OnboardingScreen(), 'S02_onboarding.png');
    });

    testWidgets('S03: Welcome Screen', (tester) async {
      await captureScreenWidget(tester, const WelcomeScreen(), 'S03_welcome.png');
    });

    testWidgets('S04: Login Screen', (tester) async {
      await captureScreenWidget(tester, const LoginScreen(), 'S04_login.png');
    });

    testWidgets('S05: Register Screen', (tester) async {
      await captureScreenWidget(tester, const RegisterScreen(), 'S05_register.png');
    });

    testWidgets('S06: Forgot Password Screen', (tester) async {
      await captureScreenWidget(tester, const ForgotPasswordScreen(), 'S06_forgot_password.png');
    });

    testWidgets('S07: Profiles Screen', (tester) async {
      await captureScreenWidget(tester, const ProfilesScreen(), 'S07_profiles.png');
    });

    testWidgets('S08: Profile Edit Screen', (tester) async {
      await captureScreenWidget(tester, const ProfileEditScreen(profileId: 'p1'), 'S08_profile_edit.png');
    });

    testWidgets('S09: Home Screen', (tester) async {
      await captureScreenWidget(tester, const HomeScreen(), 'S09_home.png');
    });

    testWidgets('S10: Search Screen', (tester) async {
      await captureScreenWidget(tester, const SearchScreen(), 'S10_search.png');
    });

    testWidgets('S11: Search Results Screen', (tester) async {
      await captureScreenWidget(tester, const MovieGridScreen(title: 'Kết quả tìm kiếm', category: 'Hành động'), 'S11_search_results.png');
    });

    testWidgets('S12: Filter Screen', (tester) async {
      await captureScreenWidget(tester, const FilterScreen(), 'S12_filter.png');
    });

    testWidgets('S13: Genres Screen', (tester) async {
      await captureScreenWidget(tester, const GenresScreen(), 'S13_genres.png');
    });

    testWidgets('S14: Genre Detail Screen', (tester) async {
      await captureScreenWidget(tester, const MovieGridScreen(title: 'Phim Kinh Dị & Tâm Linh', category: 'Kinh dị'), 'S14_genre_detail.png');
    });
  });
}
