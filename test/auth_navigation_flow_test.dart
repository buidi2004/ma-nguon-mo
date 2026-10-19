import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openflix/core/router/app_router.dart';
import 'package:openflix/features/auth/login_screen.dart';
import 'package:openflix/features/auth/register_screen.dart';
import 'package:openflix/features/auth/welcome_screen.dart';
import 'package:openflix/features/library/my_list_screen.dart';
import 'package:openflix/features/account/me_screen.dart';
import 'package:openflix/presentation/widgets/glass/glass_button.dart';
import 'package:openflix/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Regression tests cho bug điều hướng xác thực:
/// "Đăng ký / Đăng nhập thành công nhưng lại bị nhảy về màn đăng nhập,
///  phải bấm thêm nút mới vào được app."
///
/// Bộ test này kiểm tra ở tầng ĐIỀU HƯỚNG (router + widget), không chỉ tầng
/// AuthService — đúng phần mà các báo cáo cũ đã bỏ sót.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  void useTallViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(1200, 3000);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  Future<void> resetToGuest(WidgetTester tester) async {
    await tester.runAsync(() async {
      await AuthService.instance.logout();
    });
  }

  Future<void> signIn(WidgetTester tester) async {
    await tester.runAsync(() async {
      await AuthService.instance.login('user@openflix.vn', 'password123');
    });
  }

  Future<void> pumpRouter(WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp.router(routerConfig: AppRouter.router));
    await tester.pump();
  }

  Future<void> settleTransitions(WidgetTester tester) async {
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));
  }

  group('Luồng đăng nhập (S04)', () {
    testWidgets(
      'BUG-01: Đăng nhập thành công vào thẳng app, KHÔNG quay lại màn Đăng nhập',
      (tester) async {
        useTallViewport(tester);
        await resetToGuest(tester);
        final router = AppRouter.router;
        await pumpRouter(tester);

        router.go('/welcome');
        await settleTransitions(tester);
        expect(find.byType(WelcomeScreen), findsOneWidget);

        // Đúng luồng thực tế: /welcome -> push /login (ngăn xếp còn /welcome)
        router.push('/login');
        await settleTransitions(tester);
        expect(find.byType(LoginScreen), findsOneWidget);
        expect(AuthService.instance.isLoggedIn, isFalse);

        // "1-Click Đăng nhập Demo" tự điền tài khoản và submit form
        await tester.tap(
          find.widgetWithText(GlassButton, '1-Click Đăng nhập Demo'),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 900));
        await settleTransitions(tester);

        expect(AuthService.instance.isLoggedIn, isTrue);
        expect(router.state.matchedLocation, '/');
        expect(find.byType(LoginScreen), findsNothing);
        expect(find.byType(WelcomeScreen), findsNothing);
      },
    );

    testWidgets(
      'BUG-03: Phiên đã đăng nhập mở /login sẽ được đưa thẳng vào app (guard)',
      (tester) async {
        useTallViewport(tester);
        await resetToGuest(tester);
        final router = AppRouter.router;
        await pumpRouter(tester);
        await signIn(tester);
        await tester.pump();

        router.go('/login');
        await settleTransitions(tester);

        expect(router.state.matchedLocation, '/');
        expect(find.byType(LoginScreen), findsNothing);
      },
    );

    testWidgets(
      'BUG-04: Guard tôn trọng tham số ?redirect= khi phiên đã đăng nhập',
      (tester) async {
        useTallViewport(tester);
        await resetToGuest(tester);
        final router = AppRouter.router;
        await pumpRouter(tester);
        await signIn(tester);
        await tester.pump();

        router.go('/login?redirect=%2Fhot');
        await settleTransitions(tester);

        expect(router.state.matchedLocation, '/hot');
        expect(find.byType(LoginScreen), findsNothing);
      },
    );
  });

  group('Luồng đăng ký (S05)', () {
    testWidgets(
      'BUG-02: Đăng ký từ màn Đăng nhập xong vào thẳng app, KHÔNG quay lại Đăng nhập',
      (tester) async {
        useTallViewport(tester);
        await resetToGuest(tester);
        final router = AppRouter.router;
        await pumpRouter(tester);

        // Đúng luồng thực tế: /login -> bấm "Đăng ký ngay" -> /register
        router.go('/login');
        await settleTransitions(tester);
        expect(find.byType(LoginScreen), findsOneWidget);

        await tester.tap(find.text('Đăng ký ngay'));
        await settleTransitions(tester);
        expect(find.byType(RegisterScreen), findsOneWidget);

        final fields = find.byType(TextFormField);
        await tester.enterText(fields.at(0), 'Nguyễn Văn A');
        await tester.enterText(fields.at(1), 'newuser@openflix.vn');
        await tester.enterText(fields.at(2), '123456');
        await tester.enterText(fields.at(3), '123456');
        await tester.pump();

        await tester.tap(find.widgetWithText(GlassButton, 'Hoàn tất đăng ký'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 1000));
        await settleTransitions(tester);

        expect(AuthService.instance.isLoggedIn, isTrue);
        expect(router.state.matchedLocation, '/');
        expect(find.byType(RegisterScreen), findsNothing);
        expect(find.byType(LoginScreen), findsNothing);
      },
    );

    testWidgets(
      'BUG-05: Phiên đã đăng nhập mở /welcome sẽ được đưa thẳng vào app',
      (tester) async {
        useTallViewport(tester);
        await resetToGuest(tester);
        final router = AppRouter.router;
        await pumpRouter(tester);
        await signIn(tester);
        await tester.pump();

        router.go('/welcome');
        await settleTransitions(tester);

        expect(router.state.matchedLocation, '/');
        expect(find.byType(WelcomeScreen), findsNothing);
      },
    );
  });

  group('Guard dữ liệu cá nhân cho khách vãng lai', () {
    testWidgets(
      'BUG-06: Khách mở /me/list bị chuyển tới /login kèm ?redirect=',
      (tester) async {
        useTallViewport(tester);
        await resetToGuest(tester);
        final router = AppRouter.router;
        await pumpRouter(tester);

        router.go('/me/list');
        await settleTransitions(tester);

        expect(router.state.matchedLocation, '/login');
        expect(router.state.uri.queryParameters['redirect'], '/me/list');
        expect(find.byType(LoginScreen), findsOneWidget);
        expect(find.byType(MyListScreen), findsNothing);
      },
    );

    testWidgets(
      'BUG-07: Khách vẫn mở được /me (có CTA đăng nhập) — không bị chặn',
      (tester) async {
        useTallViewport(tester);
        await resetToGuest(tester);
        final router = AppRouter.router;
        await pumpRouter(tester);

        router.go('/me');
        await settleTransitions(tester);

        expect(router.state.matchedLocation, '/me');
        expect(find.byType(MeScreen), findsOneWidget);
        expect(find.byType(LoginScreen), findsNothing);
      },
    );

    testWidgets(
      'BUG-08: Khách mở tuyến con /profiles/edit/new cũng bị chặn',
      (tester) async {
        useTallViewport(tester);
        await resetToGuest(tester);
        final router = AppRouter.router;
        await pumpRouter(tester);

        router.go('/profiles/edit/new');
        await settleTransitions(tester);

        expect(router.state.matchedLocation, '/login');
        expect(
          router.state.uri.queryParameters['redirect'],
          '/profiles/edit/new',
        );
      },
    );

    testWidgets(
      'BUG-09: Đăng nhập từ redirect của guard quay lại đúng màn cá nhân',
      (tester) async {
        useTallViewport(tester);
        await resetToGuest(tester);
        final router = AppRouter.router;
        await pumpRouter(tester);

        router.go('/me/list');
        await settleTransitions(tester);
        expect(router.state.matchedLocation, '/login');

        await tester.tap(
          find.widgetWithText(GlassButton, '1-Click Đăng nhập Demo'),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 900));
        await settleTransitions(tester);

        expect(AuthService.instance.isLoggedIn, isTrue);
        expect(router.state.matchedLocation, '/me/list');
        expect(find.byType(MyListScreen), findsOneWidget);
        expect(find.byType(LoginScreen), findsNothing);
      },
    );
  });
}
