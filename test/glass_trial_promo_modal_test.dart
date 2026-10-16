import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openflix/presentation/widgets/glass/glass_trial_promo_modal.dart';
import 'package:openflix/services/trial_promo_service.dart';
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
    TrialPromoService.instance.resetSession();
  });

  group('TrialPromoService Tests', () {
    test('Initial state allows showing promo', () async {
      final canShow = await TrialPromoService.instance.shouldShowPromo();
      expect(canShow, isTrue);
    });

    test('markDismissed prevents showing promo again in same day/session', () async {
      await TrialPromoService.instance.markDismissed();
      final canShow = await TrialPromoService.instance.shouldShowPromo();
      expect(canShow, isFalse);
    });
  });

  group('GlassTrialPromoModal Widget Tests (CGV Style)', () {
    testWidgets('Renders all CGV campaign banner elements correctly', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const GlassTrialPromoModal(),
        ),
      );

      // 1. Kiểm tra logo và tiêu đề nghệ thuật
      expect(find.text('OPENFLIX'), findsAtLeastNWidgets(1));
      expect(find.text('Tháng của Nàng'), findsOneWidget);

      expect(find.text('DEAL GIẢM ĐẾN'), findsOneWidget);
      expect(find.text('100.000Đ'), findsAtLeastNWidgets(1));

      // 2. Kiểm tra viên thuốc thời gian
      expect(find.text('Thời gian: 12/10 - 20/10'), findsOneWidget);

      // 3. Kiểm tra thẻ voucher quà tặng bên trong phong bì
      expect(find.text('VIP PASS'), findsOneWidget);
      expect(find.text('HAPPY'), findsOneWidget);
      expect(find.text('YES!'), findsOneWidget);

      // 4. Kiểm tra nút bấm Oval Vàng Hoàng Kim "MUA NGAY" & chú thích chân thiệp
      expect(find.text('MUA NGAY'), findsOneWidget);
      expect(
        find.text('*Áp dụng khi mua Gói thành viên hoặc Thẻ Quà Tặng OpenFlix'),
        findsOneWidget,
      );

      // 5. Kiểm tra nút tròn đóng X
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
    });

    testWidgets('Tapping "MUA NGAY" button calls onSubscribe callback', (tester) async {
      bool subscribed = false;

      await tester.pumpWidget(
        _buildTestApp(
          Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                GlassTrialPromoModal.show(
                  context,
                  onSubscribe: () {
                    subscribed = true;
                  },
                );
              },
              child: const Text('Open Modal'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      expect(find.text('MUA NGAY'), findsOneWidget);

      // Bấm nút MUA NGAY
      await tester.tap(find.text('MUA NGAY'));
      await tester.pumpAndSettle();

      expect(subscribed, isTrue);
      expect(find.text('MUA NGAY'), findsNothing);
    });

    testWidgets('Tapping Close X button calls onDismiss callback', (tester) async {
      bool dismissed = false;

      await tester.pumpWidget(
        _buildTestApp(
          Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                GlassTrialPromoModal.show(
                  context,
                  onDismiss: () {
                    dismissed = true;
                  },
                );
              },
              child: const Text('Open Modal'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.close_rounded), findsOneWidget);

      // Bấm nút X
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      expect(dismissed, isTrue);
      expect(find.text('MUA NGAY'), findsNothing);
    });

    testWidgets('Responsive audit across 4 viewports without overflow', (tester) async {
      const viewports = [
        Size(320, 640),
        Size(360, 780),
        Size(390, 844),
        Size(800, 1200),
      ];

      for (final vp in viewports) {
        tester.view.physicalSize = vp;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          _buildTestApp(
            const GlassTrialPromoModal(),
            size: vp,
          ),
        );
        await tester.pump();

        expect(tester.takeException(), isNull, reason: 'Lỗi layout tại viewport: $vp');
        expect(find.text('MUA NGAY'), findsOneWidget);
      }
    });
  });
}
