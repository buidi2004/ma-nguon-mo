import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openflix/presentation/widgets/glass/glass_components.dart';
import 'package:openflix/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildTestable(Widget child) {
    return MaterialApp(
      theme: buildAppTheme(),
      home: Scaffold(
        backgroundColor: const Color(0xFF141414),
        body: Center(child: child),
      ),
    );
  }

  group('Giai đoạn 2: GlassSegmentedControl Tests', () {
    testWidgets('Renders all segment options and honors initial value', (
      tester,
    ) async {
      int selected = 1;

      await tester.pumpWidget(
        buildTestable(
          GlassSegmentedControl<int>(
            selectedValue: selected,
            items: const [
              GlassSegmentItem(value: 1, label: 'Mùa 1'),
              GlassSegmentItem(value: 2, label: 'Mùa 2'),
              GlassSegmentItem(value: 3, label: 'Hậu trường', badgeCount: 3),
            ],
            onValueChanged: (val) => selected = val,
          ),
        ),
      );

      expect(find.text('Mùa 1'), findsOneWidget);
      expect(find.text('Mùa 2'), findsOneWidget);
      expect(find.text('Hậu trường'), findsOneWidget);
      expect(find.text('3'), findsOneWidget); // Badge count
    });

    testWidgets('Tapping segment triggers onValueChanged and animates glider', (
      tester,
    ) async {
      int selected = 1;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return buildTestable(
              GlassSegmentedControl<int>(
                selectedValue: selected,
                items: const [
                  GlassSegmentItem(value: 1, label: 'Mùa 1'),
                  GlassSegmentItem(value: 2, label: 'Mùa 2'),
                ],
                onValueChanged: (val) {
                  setState(() => selected = val);
                },
              ),
            );
          },
        ),
      );

      expect(selected, equals(1));

      // Tap on Season 2
      await tester.tap(find.text('Mùa 2'));
      await tester.pumpAndSettle();

      expect(selected, equals(2));
    });

    testWidgets('GlassSegmentedControl.fromStrings factory works seamlessly', (
      tester,
    ) async {
      String selected = 'Tất cả';

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return buildTestable(
              GlassSegmentedControl.fromStrings(
                selectedSegment: selected,
                segments: const ['Tất cả', 'Phim lẻ', 'Phim bộ'],
                onSegmentChanged: (val) {
                  setState(() => selected = val);
                },
              ),
            );
          },
        ),
      );

      expect(find.text('Tất cả'), findsOneWidget);
      expect(find.text('Phim lẻ'), findsOneWidget);
      expect(find.text('Phim bộ'), findsOneWidget);

      await tester.tap(find.text('Phim lẻ'));
      await tester.pumpAndSettle();

      expect(selected, equals('Phim lẻ'));
    });
  });

  group('Giai đoạn 2: GlassFAB Tests', () {
    testWidgets('GlassFAB.circle renders icon and triggers onPressed', (
      tester,
    ) async {
      bool tapped = false;

      await tester.pumpWidget(
        buildTestable(
          GlassFAB.circle(
            icon: Icons.play_arrow_rounded,
            tooltip: 'Phát ngay',
            onPressed: () => tapped = true,
          ),
        ),
      );

      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);

      await tester.tap(find.byType(GlassFAB));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('GlassFAB.extended renders icon and label', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        buildTestable(
          GlassFAB.extended(
            label: 'Viết đánh giá',
            icon: Icons.rate_review_rounded,
            onPressed: () => tapped = true,
          ),
        ),
      );

      expect(find.text('Viết đánh giá'), findsOneWidget);
      expect(find.byIcon(Icons.rate_review_rounded), findsOneWidget);

      await tester.tap(find.byType(GlassFAB));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('GlassFAB.scrollToTop hides at top and appears when scrolled', (
      tester,
    ) async {
      final controller = ScrollController();

      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: Scaffold(
            floatingActionButton: GlassFAB.scrollToTop(
              controller: controller,
              threshold: 100.0,
            ),
            body: ListView.builder(
              controller: controller,
              itemCount: 50,
              itemExtent: 80.0,
              itemBuilder: (context, index) => ListTile(title: Text('Item $index')),
            ),
          ),
        ),
      );

      // Initially at 0 scroll offset -> FAB should be scaled to 0 (hidden)
      await tester.pumpAndSettle();
      expect(controller.offset, equals(0.0));

      // Scroll down past threshold (e.g. 250px)
      controller.jumpTo(250.0);
      await tester.pumpAndSettle();

      expect(controller.offset, equals(250.0));
      expect(find.byIcon(Icons.keyboard_arrow_up_rounded), findsOneWidget);

      // Tap scroll to top button
      await tester.tap(find.byIcon(Icons.keyboard_arrow_up_rounded));
      await tester.pumpAndSettle();

      // Controller should have smoothly scrolled to 0.0
      expect(controller.offset, equals(0.0));
    });
  });
}
