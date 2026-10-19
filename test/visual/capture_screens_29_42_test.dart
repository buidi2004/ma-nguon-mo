// Capture màn hình S29–S42 (tách từ capture_all_42_screens_test.dart).
//
// Nội dung test giữ nguyên; setup chung nằm ở `visual_harness.dart`.
import 'package:flutter_test/flutter_test.dart';
import 'package:openflix/features/account/about_screen.dart';
import 'package:openflix/features/account/account_screen.dart';
import 'package:openflix/features/account/language_screen.dart';
import 'package:openflix/features/account/me_screen.dart';
import 'package:openflix/features/account/notifications_screen.dart';
import 'package:openflix/features/account/password_screen.dart';
import 'package:openflix/features/account/plans_screen.dart';
import 'package:openflix/features/account/playback_settings_screen.dart';
import 'package:openflix/features/account/settings_screen.dart';
import 'package:openflix/features/system/contact_screen.dart';
import 'package:openflix/features/system/help_screen.dart';
import 'package:openflix/features/system/system_status_screen.dart';

import 'visual_harness.dart';

void main() {
  setUpVisualHarness();

  group('Capture 42 Screens - True Mobile Portrait 1080x2316', () {
    testWidgets('S29: Notifications Screen', (tester) async {
      await captureScreenWidget(tester, const NotificationsScreen(), 'S29_notifications.png');
    });

    testWidgets('S30: Me Screen (Profile Hub)', (tester) async {
      await captureScreenWidget(tester, const MeScreen(), 'S30_me.png');
    });

    testWidgets('S31: Account Info Screen', (tester) async {
      await captureScreenWidget(tester, const AccountScreen(), 'S31_account.png');
    });

    testWidgets('S32: Password Screen', (tester) async {
      await captureScreenWidget(tester, const PasswordScreen(), 'S32_password.png');
    });

    testWidgets('S33: Settings Screen', (tester) async {
      await captureScreenWidget(tester, const SettingsScreen(), 'S33_settings.png');
    });

    testWidgets('S34: Playback Settings Screen', (tester) async {
      await captureScreenWidget(tester, const PlaybackSettingsScreen(), 'S34_playback_settings.png');
    });

    testWidgets('S35: Language Screen', (tester) async {
      await captureScreenWidget(tester, const LanguageScreen(), 'S35_language.png');
    });

    testWidgets('S36: Help & FAQ Screen', (tester) async {
      await captureScreenWidget(tester, const HelpScreen(), 'S36_help.png');
    });

    testWidgets('S37: Contact & Feedback Screen', (tester) async {
      await captureScreenWidget(tester, const ContactScreen(), 'S37_contact.png');
    });

    testWidgets('S38: About & Licenses Screen', (tester) async {
      await captureScreenWidget(tester, const AboutScreen(), 'S38_about.png');
    });

    testWidgets('S39: Offline Fallback Screen', (tester) async {
      await captureScreenWidget(tester, SystemStatusScreen.offline(), 'S39_offline.png');
    });

    testWidgets('S40: Error Screen', (tester) async {
      await captureScreenWidget(tester, SystemStatusScreen.error(), 'S40_error.png');
    });

    testWidgets('S41: Page Not Found 404 Screen', (tester) async {
      await captureScreenWidget(tester, SystemStatusScreen.notFound(attemptedPath: '/invalid-path'), 'S41_not_found.png');
    });

    testWidgets('S42: Plans Screen (Subscription)', (tester) async {
      await captureScreenWidget(tester, const PlansScreen(), 'S42_plans.png');
    });
  });
}
