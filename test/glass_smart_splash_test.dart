import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openflix/features/auth/splash_screen.dart';
import 'package:openflix/presentation/widgets/glass/glass_smart_splash.dart';
import 'package:smart_splash_kit/smart_splash_kit.dart';

Widget _buildWrapper(Widget child) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    home: child,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GlassSmartSplash & Smart Splash Kit Integration Tests', () {
    testWidgets('Renders default branding, wordmark, tagline and progress indicator', (tester) async {
      await tester.pumpWidget(_buildWrapper(const SplashScreen()));

      expect(find.text('OPENFLIX'), findsOneWidget);
      expect(find.text('Điện ảnh không giới hạn'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Executes smart routing via onInit callback and invokes onNavigate', (tester) async {
      SplashRoute? receivedRoute;

      await tester.pumpWidget(
        _buildWrapper(
          GlassSmartSplash(
            config: const SplashConfig(
              durationMs: 50,
              animation: SplashAnimation(type: SplashAnimationType.none),
              appName: 'OPENFLIX',
            ),
            onInit: () async {
              return SplashRoute.custom('/test_target');
            },
            onNavigate: (route) {
              receivedRoute = route;
            },
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(receivedRoute, isNotNull);
      expect(receivedRoute!.route, equals('/test_target'));
    });

    testWidgets('Supports skip button and tap to continue interactivity', (tester) async {
      bool skipped = false;

      await tester.pumpWidget(
        _buildWrapper(
          GlassSmartSplash(
            config: const SplashConfig(
              durationMs: 2000,
              animation: SplashAnimation(type: SplashAnimationType.none),
              appName: 'OPENFLIX',
              showSkipButton: true,
              skipButtonLabel: 'Bỏ qua',
            ),
            onInit: () async {
              return SplashRoute.home();
            },
            onNavigate: (_) {
              skipped = true;
            },
          ),
        ),
      );

      expect(find.text('Bỏ qua'), findsOneWidget);
      await tester.tap(find.text('Bỏ qua'));
      await tester.pump();

      expect(skipped, isTrue);
    });

    testWidgets('Shows error fallback UI with Retry button on failure', (tester) async {
      bool retried = false;

      await tester.pumpWidget(
        _buildWrapper(
          GlassSmartSplash(
            config: const SplashConfig(
              durationMs: 20,
              animation: SplashAnimation(type: SplashAnimationType.none),
              appName: 'OPENFLIX',
            ),
            onInit: () async {
              if (!retried) {
                throw Exception('Mất kết nối máy chủ');
              }
              return SplashRoute.home();
            },
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Không thể tải dữ liệu khởi động'), findsOneWidget);
      expect(find.text('Thử lại'), findsOneWidget);

      retried = true;
      await tester.tap(find.text('Thử lại'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
    });

    testWidgets('Disposes cleanly without timer leaks', (tester) async {
      await tester.pumpWidget(_buildWrapper(const SplashScreen()));
      // Unmount immediately without waiting for timers
      await tester.pumpWidget(_buildWrapper(const SizedBox.shrink()));
      // If timers were leaked, Flutter test framework will throw an assertion error here
    });
  });
}
