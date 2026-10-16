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

  group('GlassTrialPromoModal Widget Tests', () {
    testWidgets('Renders all VIP trial elements correctly', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const GlassTrialPromoModal(),
        ),
      );

      // 1. Kiểm tra tiêu đề và badge
      expect(find.text('7 NGÀY DÙNG THỬ VIP'), findsOneWidget);
      expect(find.text('ƯU ĐÃI ĐẶC QUYỀN'), findsOneWidget);

      // 2. Kiểm tra các dòng quyền lợi
      expect(find.textContaining('1.000+ bom tấn'), findsOneWidget);
      expect(find.textContaining('Chất lượng 4K HDR'), findsOneWidget);
      expect(find.textContaining('Không quảng cáo'), findsOneWidget);

      // 3. Kiểm tra nút hành động và chú thích
      expect(find.text('DÙNG THỬ NGAY (0Đ)'), findsOneWidget);
      expect(find.text('0đ trong 7 ngày đầu. Tự do hủy bất cứ lúc nào.'), findsOneWidget);
      expect(find.text('Để sau'), findsOneWidget);

      // 4. Kiểm tra nút X đóng
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
    });

    testWidgets('Tapping Subscribe button calls onSubscribe callback', (tester) async {
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

      expect(find.text('7 NGÀY DÙNG THỬ VIP'), findsOneWidget);

      // Bấm DÙNG THỬ NGAY
      await tester.tap(find.text('DÙNG THỬ NGAY (0Đ)'));
      await tester.pumpAndSettle();

      expect(subscribed, isTrue);
      expect(find.text('7 NGÀY DÙNG THỬ VIP'), findsNothing);
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
      expect(find.text('7 NGÀY DÙNG THỬ VIP'), findsNothing);
    });

    testWidgets('Tapping "Để sau" button dismisses modal', (tester) async {
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

      await tester.tap(find.text('Để sau'));
      await tester.pumpAndSettle();

      expect(dismissed, isTrue);
      expect(find.text('7 NGÀY DÙNG THỬ VIP'), findsNothing);
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
        expect(find.text('7 NGÀY DÙNG THỬ VIP'), findsOneWidget);
      }
    });
  });
}
