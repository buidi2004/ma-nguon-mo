import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openflix/core/router/app_router.dart';
import 'package:openflix/features/account/plans_screen.dart';
import 'package:openflix/features/watch/trailer_screen.dart';
import 'package:openflix/presentation/widgets/floating_glass_bottom_bar.dart';

void main() {
  testWidgets('AppRouter initial route splash works and routes exist', (
    tester,
  ) async {
    final router = AppRouter.router;
    expect(router, isNotNull);
  });

  testWidgets('AppRouter trailer routes (/movie/:id/trailer and /trailer/:id) exist and render TrailerScreen', (
    tester,
  ) async {
    final router = AppRouter.router;
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));

    // Test 1: Route chính thức /movie/:id/trailer render đúng TrailerScreen
    router.push('/movie/test-123/trailer');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.byType(TrailerScreen), findsOneWidget);
    expect(router.state.matchedLocation, '/movie/test-123/trailer');

    // Test 2: Route alias /trailer/:id cũng render đúng TrailerScreen
    router.push('/trailer/test-456');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.byType(TrailerScreen), findsOneWidget);
    expect(router.state.matchedLocation, '/trailer/test-456');
  });

  testWidgets(
    'Tapping bottom bar 4-tile quick action button opens /plans screen',
    (tester) async {
      final router = AppRouter.router;
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      router.go('/');
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));

      final quickBtn = find.byType(FourTileQuickActionIcon);
      expect(quickBtn, findsOneWidget);

      await tester.tap(quickBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(PlansScreen), findsOneWidget);
    },
  );

  testWidgets(
    'HomeScreen to Watch and Trailer routes preserves FloatingGlassBottomBar on return',
    (tester) async {
      final router = AppRouter.router;
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      router.go('/');
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));

      // 1. Tại Trang chủ: Bottom bar tồn tại với tab 0 được chọn
      final bottomBarFinder = find.byType(FloatingGlassBottomBar);
      expect(bottomBarFinder, findsOneWidget);
      final initialBar = tester.widget<FloatingGlassBottomBar>(bottomBarFinder);
      expect(initialBar.selectedIndex, 0);

      // 2. Chuyển sang màn xem phim /watch/movie-1 qua context.push
      router.push('/watch/movie-1');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      expect(router.state.matchedLocation, '/watch/movie-1');

      // 3. Pop quay trở lại Trang chủ
      router.pop();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      // 4. CHỨNG CỨ: Bottom bar vẫn tồn tại nguyên vẹn, tab index vẫn là 0 (Trang chủ)
      expect(find.byType(FloatingGlassBottomBar), findsOneWidget);
      final returnedBar = tester.widget<FloatingGlassBottomBar>(
        find.byType(FloatingGlassBottomBar),
      );
      expect(returnedBar.selectedIndex, 0);

      // 5. Chuyển sang màn trailer /movie/movie-1/trailer
      router.push('/movie/movie-1/trailer');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      expect(router.state.matchedLocation, '/movie/movie-1/trailer');

      // 6. Pop quay lại Trang chủ
      router.pop();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      // 7. CHỨNG CỨ: Bottom bar vẫn nguyên vẹn 100%, không bị ảnh hưởng
      expect(find.byType(FloatingGlassBottomBar), findsOneWidget);
      final finalBar = tester.widget<FloatingGlassBottomBar>(
        find.byType(FloatingGlassBottomBar),
      );
      expect(finalBar.selectedIndex, 0);
    },
  );
}
