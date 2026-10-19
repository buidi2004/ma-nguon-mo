import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openflix/presentation/widgets/dialogs/auth_required_dialog.dart';
import 'package:openflix/services/auth_guard.dart';
import 'package:openflix/services/auth_service.dart';
import 'package:openflix/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _buildTestApp(Widget child, {Size size = const Size(390, 844)}) {
  return MediaQuery(
    data: MediaQueryData(size: size),
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AuthGuard & AuthRequiredDialog Tests', () {
    testWidgets('Guest user: AuthGuard blocks playback and displays AuthRequiredDialog', (tester) async {
      // Ensure user is logged out (Guest)
      await tester.runAsync(() async {
        await AuthService.instance.logout();
      });
      expect(AuthService.instance.isLoggedIn, isFalse);

      bool playbackStarted = false;
      bool trailerStarted = false;

      await tester.pumpWidget(
        _buildTestApp(
          Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  AuthGuard.runWithAuth(
                    context,
                    movieId: 'movie_123',
                    movieTitle: 'Đào, Phở và Piano',
                    hasTrailer: true,
                    onWatchTrailer: () => trailerStarted = true,
                    onAuthorized: () => playbackStarted = true,
                  );
                },
                child: const Text('Bấm Phát'),
              );
            },
          ),
        ),
      );

      // Bấm nút Phát
      await tester.tap(find.text('Bấm Phát'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // Kiểm tra: Không được chạy playback
      expect(playbackStarted, isFalse);

      // Kiểm tra: Pop-up yêu cầu đăng nhập xuất hiện
      expect(find.byType(AuthRequiredDialog), findsOneWidget);
      expect(find.text('Đăng nhập để xem phim'), findsOneWidget);
      expect(find.text('« Đào, Phở và Piano »'), findsOneWidget);
      expect(find.text('Đăng nhập ngay'), findsOneWidget);
      expect(find.text('Xem Trailer miễn phí'), findsOneWidget);
      expect(find.text('Để sau'), findsOneWidget);

      // Bấm "Xem Trailer miễn phí"
      await tester.tap(find.text('Xem Trailer miễn phí'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // Kiểm tra: Trailer callback được gọi, dialog được đóng
      expect(trailerStarted, isTrue);
      expect(find.byType(AuthRequiredDialog), findsNothing);
    });

    testWidgets('Guest user: Dismiss button closes AuthRequiredDialog', (tester) async {
      await tester.runAsync(() async {
        await AuthService.instance.logout();
      });

      await tester.pumpWidget(
        _buildTestApp(
          Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  AuthGuard.runWithAuth(
                    context,
                    movieId: 'movie_123',
                    movieTitle: 'Mai',
                    onAuthorized: () {},
                  );
                },
                child: const Text('Phát'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Phát'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(AuthRequiredDialog), findsOneWidget);

      // Bấm "Để sau"
      await tester.tap(find.text('Để sau'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // Dialog biến mất
      expect(find.byType(AuthRequiredDialog), findsNothing);
    });

    testWidgets('Logged-in user: AuthGuard executes playback directly without dialog', (tester) async {
      // Đăng nhập tài khoản
      await tester.runAsync(() async {
        await AuthService.instance.login('user@openflix.vn', 'password123');
      });
      expect(AuthService.instance.isLoggedIn, isTrue);

      bool playbackStarted = false;

      await tester.pumpWidget(
        _buildTestApp(
          Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  AuthGuard.runWithAuth(
                    context,
                    movieId: 'movie_999',
                    movieTitle: 'Lật Mặt 7',
                    onAuthorized: () => playbackStarted = true,
                  );
                },
                child: const Text('Phát'),
              );
            },
          ),
        ),
      );

      // Bấm Phát
      await tester.tap(find.text('Phát'));
      await tester.pumpAndSettle();

      // Kiểm tra: Phát ngay lập tức, không hiện bất kỳ dialog nào
      expect(playbackStarted, isTrue);
      expect(find.byType(AuthRequiredDialog), findsNothing);
    });
  });
}
