import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:openflix/features/account/account_screen.dart';
import 'package:openflix/features/account/me_screen.dart';
import 'package:openflix/features/account/profile_edit_screen.dart';
import 'package:openflix/presentation/widgets/brand/app_brand_logo.dart';
import 'package:openflix/presentation/widgets/brand/user_avatar_circle.dart';
import 'package:openflix/presentation/widgets/dialogs/user_avatar_dialog.dart';
import 'package:openflix/presentation/widgets/glass/glass_back_button.dart';
import 'package:openflix/screens/home_screen.dart';
import 'package:openflix/services/auth_service.dart';
import 'package:openflix/theme/app_theme.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      theme: buildAppTheme(),
      home: child,
    );
  }

  group('User Avatar in HomeScreen & Management Dialog Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await AuthService.instance.removeAvatar();
    });

    testWidgets('HomeScreen renders UserAvatarButton aligned in AppBar',
        (tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const HomeScreen(enableTrialPromo: false),
      ));
      await tester.pump(const Duration(milliseconds: 300));

      // Brand logo present
      expect(find.byType(AppBrandLogo), findsOneWidget);

      // UserAvatarButton present in actions
      final avatarBtnFinder = find.byType(UserAvatarButton);
      expect(avatarBtnFinder, findsOneWidget);

      // Check default avatar character (Panda 🐼 as in user reference)
      expect(find.text('🐼'), findsOneWidget);
    });

    testWidgets('Long-pressing UserAvatarButton opens UserAvatarDialog sheet',
        (tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const HomeScreen(enableTrialPromo: false),
      ));
      await tester.pump(const Duration(milliseconds: 300));

      // Long press avatar button
      await tester.longPress(find.byType(UserAvatarButton));
      await tester.pumpAndSettle();

      // UserAvatarDialog should be visible
      expect(find.byType(UserAvatarDialog), findsOneWidget);
      expect(find.text('Ảnh đại diện chân dung'), findsOneWidget);
      expect(find.text('Lưu thay đổi'), findsOneWidget);
      expect(find.text('Xóa ảnh'), findsOneWidget);
    });

    testWidgets('Tapping UserAvatarButton navigates to MeScreen (/me)',
        (tester) async {
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const HomeScreen(enableTrialPromo: false),
          ),
          GoRoute(
            path: '/me',
            builder: (context, state) => const MeScreen(),
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(
        theme: buildAppTheme(),
        routerConfig: router,
      ));
      await tester.pump(const Duration(milliseconds: 300));

      // Tap avatar button on HomeScreen
      await tester.tap(find.byType(UserAvatarButton));
      await tester.pumpAndSettle();

      // Should now be on MeScreen ("Tài khoản & Cá nhân")
      expect(find.text('Tài khoản & Cá nhân'), findsOneWidget);
      expect(find.byType(MeScreen), findsOneWidget);
      expect(find.byType(GlassBackButton), findsOneWidget);

      // Tap back button
      await tester.tap(find.byType(GlassBackButton));
      await tester.pumpAndSettle();

      // Returns to HomeScreen
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('MeScreen avatar tap opens UserAvatarDialog sheet',
        (tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const MeScreen(),
      ));
      await tester.pumpAndSettle();

      // Find UserAvatarCircle on MeScreen
      final avatarFinder = find.byType(UserAvatarCircle);
      expect(avatarFinder, findsOneWidget);

      // Tap avatar on MeScreen
      await tester.tap(avatarFinder);
      await tester.pumpAndSettle();

      // UserAvatarDialog should be visible
      expect(find.byType(UserAvatarDialog), findsOneWidget);
      expect(find.text('Ảnh đại diện chân dung'), findsOneWidget);
    });

    testWidgets('AccountScreen avatar tap opens UserAvatarDialog sheet',
        (tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const AccountScreen(),
      ));
      await tester.pumpAndSettle();

      // Find UserAvatarCircle on AccountScreen
      final avatarFinder = find.byType(UserAvatarCircle);
      expect(avatarFinder, findsOneWidget);

      // Tap avatar on AccountScreen
      await tester.tap(avatarFinder);
      await tester.pumpAndSettle();

      // UserAvatarDialog should be visible
      expect(find.byType(UserAvatarDialog), findsOneWidget);
      expect(find.text('Ảnh đại diện chân dung'), findsOneWidget);
    });

    testWidgets('ProfileEditScreen avatar tap opens UserAvatarDialog sheet',
        (tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const ProfileEditScreen(profileId: 'p1'),
      ));
      await tester.pumpAndSettle();

      // Find UserAvatarCircle on ProfileEditScreen
      final avatarFinder = find.byType(UserAvatarCircle);
      expect(avatarFinder, findsOneWidget);

      // Tap avatar on ProfileEditScreen
      await tester.tap(avatarFinder);
      await tester.pumpAndSettle();

      // UserAvatarDialog should be visible
      expect(find.byType(UserAvatarDialog), findsOneWidget);
      expect(find.text('Ảnh đại diện chân dung'), findsOneWidget);
    });

    testWidgets('Selecting a new avatar preset updates AuthService',
        (tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const Scaffold(body: UserAvatarDialog()),
      ));
      await tester.pumpAndSettle();

      // Tap on Cat 🐱 avatar
      final catFinder = find.text('🐱');
      expect(catFinder, findsWidgets);
      await tester.tap(catFinder.first);
      await tester.pumpAndSettle();

      // Scroll to Save button & Tap Save
      await tester.ensureVisible(find.text('Lưu thay đổi'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lưu thay đổi'));
      await tester.pumpAndSettle();

      // AuthService should be updated with cat emoji
      expect(AuthService.instance.avatarValue, '🐱');
      expect(AuthService.instance.avatarType, 'preset');
    });

    testWidgets('Resetting / Deleting avatar restores default panda',
        (tester) async {
      // Set to another avatar first
      await AuthService.instance.updateAvatar(
        type: 'preset',
        value: '🦊',
        bgColor: 0xFF00A2ED,
      );
      expect(AuthService.instance.avatarValue, '🦊');

      await tester.pumpWidget(buildTestableWidget(
        const Scaffold(body: UserAvatarDialog()),
      ));
      await tester.pumpAndSettle();

      // Scroll to Delete button & Tap Reset/Delete button
      await tester.ensureVisible(find.text('Xóa ảnh'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Xóa ảnh'));
      await tester.pumpAndSettle();

      // Should be restored to default 🐼
      expect(AuthService.instance.avatarValue, '🐼');
      expect(AuthService.instance.avatarBgColor, 0xFF7C83FD);
    });

    testWidgets('Tapping Từ thiết bị tab displays device photo options',
        (tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const Scaffold(body: UserAvatarDialog()),
      ));
      await tester.pumpAndSettle();

      // Find and tap 'Từ thiết bị' tab
      final deviceTab = find.text('Từ thiết bị');
      expect(deviceTab, findsOneWidget);
      await tester.tap(deviceTab);
      await tester.pumpAndSettle();

      // Should show 'Thư viện ảnh' and 'Chụp ảnh mới' buttons
      expect(find.text('Thư viện ảnh'), findsOneWidget);
      expect(find.text('Chụp ảnh mới'), findsOneWidget);
      expect(find.text('Ảnh từ máy của bạn:'), findsOneWidget);
      expect(find.text('Chạm để tải ảnh từ thiết bị'), findsOneWidget);
    });

    testWidgets('UserAvatarCircle renders base64 device avatar correctly',
        (tester) async {
      // 1x1 transparent GIF base64 string
      const sampleBase64 =
          'R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7';

      await AuthService.instance.updateAvatar(
        type: 'file',
        value: sampleBase64,
        bgColor: 0xFF00C9A7,
      );

      await tester.pumpWidget(buildTestableWidget(
        const UserAvatarCircle(size: 60),
      ));
      await tester.pumpAndSettle();

      // Image widget should be rendered instead of text
      expect(find.byType(Image), findsOneWidget);
      expect(find.text('🐼'), findsNothing);
    });
  });
}
