import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openflix/presentation/widgets/glass/glass_components.dart';

void main() {
  group('GlassOpticalTokens Tests', () {
    test('Tokens contain Snell law parameters and proper values', () {
      expect(GlassOpticalTokens.buttonRefractiveIndex, 1.82);
      expect(GlassOpticalTokens.buttonThickness, 56.0);
      expect(GlassOpticalTokens.buttonBlur, 8.5);
      expect(GlassOpticalTokens.menuRefractiveIndex, 1.68);
      expect(GlassOpticalTokens.hairlineRimWidth, 0.6);

      final buttonSettings = GlassOpticalTokens.createButtonSettings();
      expect(buttonSettings.refractiveIndex, 1.82);
      expect(buttonSettings.thickness, 56.0);

      final menuSettings = GlassOpticalTokens.createMenuSettings();
      expect(menuSettings.refractiveIndex, 1.68);
    });
  });

  group('GlassSurface Tests', () {
    testWidgets('Renders with child and fallback backdrop filter', (
      tester,
    ) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassSurface(
              useBackdropFilter: true,
              onTap: () => tapped = true,
              child: const Text('Surface Content'),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Surface Content'), findsOneWidget);
      await tester.tap(find.text('Surface Content'));
      expect(tapped, isTrue);
    });

    testWidgets('Renders capsule and circle variants without crashing', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                GlassSurface.capsule(
                  useBackdropFilter: true,
                  child: const Text('Capsule Surface'),
                ),
                GlassSurface.circle(
                  size: 60,
                  useBackdropFilter: true,
                  child: const Icon(Icons.star),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Capsule Surface'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('Renders with optical glass container', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GlassSurface(
              useBackdropFilter: false,
              child: Text('Optical Shader Content'),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Optical Shader Content'), findsOneWidget);
    });
  });

  group('GlassButton Tests', () {
    testWidgets('Primary White button renders text, icon and handles tap', (
      tester,
    ) async {
      bool pressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassButton.primary(
              text: 'Phát',
              icon: Icons.play_arrow_rounded,
              useBackdropFilter: true,
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Phát'), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);

      await tester.tap(find.text('Phát'));
      await tester.pump();
      expect(pressed, isTrue);
    });

    testWidgets('Brand Red button renders correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassButton.brand(
              text: 'Đăng ký gói VIP',
              useBackdropFilter: true,
              onPressed: () {},
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Đăng ký gói VIP'), findsOneWidget);
    });

    testWidgets('Neutral Dark & Capsule buttons render', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                GlassButton.neutral(
                  text: 'Chi tiết phim',
                  useBackdropFilter: true,
                  onPressed: () {},
                ),
                GlassButton.capsule(
                  text: 'Viên thuốc',
                  useBackdropFilter: true,
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Chi tiết phim'), findsOneWidget);
      expect(find.text('Viên thuốc'), findsOneWidget);
    });

    testWidgets('Loading button shows indicator and ignores tap', (
      tester,
    ) async {
      bool pressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassButton(
              text: 'Đang tải',
              isLoading: true,
              useBackdropFilter: true,
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.tap(find.byType(CircularProgressIndicator));
      expect(pressed, isFalse);
    });

    testWidgets('Disabled button (onPressed null) renders with dim opacity', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GlassButton(
              text: 'Vô hiệu hóa',
              onPressed: null,
              useBackdropFilter: true,
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Vô hiệu hóa'), findsOneWidget);
    });
  });

  group('GlassIconButton Tests', () {
    testWidgets('GlassIconButton circle and rounded render and tap', (
      tester,
    ) async {
      bool circleTapped = false;
      bool roundedTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                GlassIconButton.circle(
                  icon: Icons.play_arrow,
                  hasGlow: true,
                  useBackdropFilter: true,
                  onPressed: () => circleTapped = true,
                ),
                GlassIconButton.rounded(
                  icon: Icons.bookmark,
                  useBackdropFilter: true,
                  onPressed: () => roundedTapped = true,
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
      expect(find.byIcon(Icons.bookmark), findsOneWidget);

      await tester.tap(find.byIcon(Icons.play_arrow));
      expect(circleTapped, isTrue);

      await tester.tap(find.byIcon(Icons.bookmark));
      expect(roundedTapped, isTrue);
    });
  });

  group('GlassMenu Tests', () {
    testWidgets('GlassMenuCard and GlassMenuItem render with interaction', (
      tester,
    ) async {
      bool itemTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassMenuCard(
              useBackdropFilter: true,
              child: Column(
                children: [
                  GlassMenuItem(
                    icon: Icons.movie,
                    title: 'Tập 1: Khởi đầu',
                    subtitle: '45 phút',
                    isSelected: true,
                    onTap: () => itemTapped = true,
                  ),
                  const GlassMenuItem(
                    icon: Icons.delete_outline,
                    title: 'Xóa khỏi danh sách',
                    isDestructive: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Tập 1: Khởi đầu'), findsOneWidget);
      expect(find.text('45 phút'), findsOneWidget);
      expect(find.text('Xóa khỏi danh sách'), findsOneWidget);

      await tester.tap(find.text('Tập 1: Khởi đầu'));
      expect(itemTapped, isTrue);
    });

    testWidgets('showGlassDialog opens curved glass dialog', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () {
                  showGlassDialog(
                    context: ctx,
                    title: 'Xác nhận xem',
                    child: const Text('Bạn có muốn tiếp tục tập này?'),
                  );
                },
                child: const Text('Mở Dialog'),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Mở Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Xác nhận xem'), findsOneWidget);
      expect(find.text('Bạn có muốn tiếp tục tập này?'), findsOneWidget);
    });
  });
}
