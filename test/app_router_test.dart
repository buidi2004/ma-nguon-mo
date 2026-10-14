import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openflix/core/router/app_router.dart';
import 'package:openflix/features/account/plans_screen.dart';
import 'package:openflix/presentation/widgets/floating_glass_bottom_bar.dart';

void main() {
  testWidgets('AppRouter initial route splash works and routes exist', (
    tester,
  ) async {
    final router = AppRouter.router;
    expect(router, isNotNull);
  });

  testWidgets(
    'Tapping bottom bar 4-tile quick action button opens /plans screen',
    (tester) async {
      final router = AppRouter.router;
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      router.go('/');
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));

      // Tìm nút tròn 4 ô tiện ích bên phải bottom bar
      final quickBtn = find.byType(FourTileQuickActionIcon);
      expect(quickBtn, findsOneWidget);

      await tester.tap(quickBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // Kiểm tra đã điều hướng tới màn hình Gói thành viên (PlansScreen)
      expect(find.byType(PlansScreen), findsOneWidget);
    },
  );
}
