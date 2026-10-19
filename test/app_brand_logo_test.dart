import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openflix/theme/app_theme.dart';
import 'package:openflix/presentation/widgets/brand/app_brand_logo.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppBrandLogo UX/UI & Optical Alignment Tests', () {
    testWidgets('Renders 3D movie icon and FLIX text without OPEN', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: AppBrandLogo(),
            ),
          ),
        ),
      );

      // Chữ 'OPEN' đã bị loại bỏ hoàn toàn
      expect(find.text('OPEN'), findsNothing);
      expect(find.text('OPENFLIX'), findsNothing);

      // Chữ 'FLIX' xuất hiện nổi bật
      expect(find.text('FLIX'), findsOneWidget);

      // Tìm thấy Image widget đại diện cho Icon 3D
      expect(find.byType(Image), findsOneWidget);

      final textWidget = tester.widget<Text>(find.text('FLIX'));
      expect(textWidget.style?.color, AppColors.red);
      expect(textWidget.style?.fontWeight, FontWeight.w900);
      expect(textWidget.style?.letterSpacing, 2.0);
    });

    testWidgets('Icon and FLIX text are vertically centered and optically aligned', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: AppBrandLogo(
                iconSize: 34,
                fontSize: 21,
              ),
            ),
          ),
        ),
      );

      final rowFinder = find.byType(Row).first;
      final rowWidget = tester.widget<Row>(rowFinder);
      expect(rowWidget.crossAxisAlignment, CrossAxisAlignment.center);

      final iconBox = tester.getRect(find.byType(SizedBox).first);
      final textBox = tester.getRect(find.text('FLIX'));

      // Kiểm tra độ cân đối và tâm trục dọc nằm trong ngưỡng sai lệch quang học rất nhỏ (< 3px)
      final iconCenterY = iconBox.center.dy;
      final textCenterY = textBox.center.dy;
      expect((iconCenterY - textCenterY).abs(), lessThanOrEqualTo(2.5));
    });

    testWidgets('Tapping on AppBrandLogo fires onTap callback', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: AppBrandLogo(
                onTap: () {
                  tapped = true;
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(AppBrandLogo));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('Supports showText: false to render icon-only mode', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: AppBrandLogo(showText: false),
            ),
          ),
        ),
      );

      expect(find.text('FLIX'), findsNothing);
      expect(find.byType(Image), findsOneWidget);
    });
  });
}
