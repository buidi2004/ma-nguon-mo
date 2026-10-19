import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openflix/presentation/widgets/floating_glass_bottom_bar.dart';

void main() {
  testWidgets('FloatingGlassBottomBar renders without crashing', (
    tester,
  ) async {
    int selectedTab = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: const SizedBox.expand(),
          bottomNavigationBar: FloatingGlassBottomBar(
            selectedIndex: selectedTab,
            onTabSelected: (i) => selectedTab = i,
            onQuickActionPressed: () {},
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(FloatingGlassBottomBar), findsOneWidget);
    expect(find.byType(AnimatedPositioned), findsOneWidget);
  });

  testWidgets(
    'Single fluid glider pill transitions across tabs and aligns accurately',
    (tester) async {
      int selectedTab = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: const SizedBox.expand(),
                bottomNavigationBar: FloatingGlassBottomBar(
                  selectedIndex: selectedTab,
                  onTabSelected: (i) {
                    setState(() => selectedTab = i);
                  },
                  onQuickActionPressed: () {},
                ),
              );
            },
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 400));

      // Verify exactly 1 sliding pill
      expect(find.byType(AnimatedPositioned), findsOneWidget);

      final pillFinder = find.byType(AnimatedPositioned);
      final initialPillRect = tester.getRect(pillFinder);

      // Tap tab 2 (Hot)
      await tester.tap(find.byIcon(Icons.local_fire_department_outlined));
      await tester.pump(); // Start animation
      await tester.pump(const Duration(milliseconds: 180)); // Mid-flight

      final midPillRect = tester.getRect(pillFinder);
      // Pill has slid to the right
      expect(midPillRect.left, greaterThan(initialPillRect.left));

      await tester.pump(const Duration(milliseconds: 400)); // Complete animation
      final finalPillRect = tester.getRect(pillFinder);
      expect(finalPillRect.left, greaterThan(midPillRect.left));

      // Verify height is consistent and centered vertically
      expect(finalPillRect.height, 42.0);
      expect(selectedTab, 2);
    },
  );

  testWidgets('Zero overflow on ultra-narrow 320x640 mobile viewport', (
    tester,
  ) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(size: Size(320, 640)),
        child: MaterialApp(
          home: Scaffold(
            body: const SizedBox.expand(),
            bottomNavigationBar: FloatingGlassBottomBar(
              selectedIndex: 0,
              onTabSelected: (_) {},
              onQuickActionPressed: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 400));

    expect(tester.takeException(), isNull);
    expect(find.byType(FloatingGlassBottomBar), findsOneWidget);
  });

  testWidgets('Renders properly on 800x1200 tablet viewport', (tester) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(size: Size(800, 1200)),
        child: MaterialApp(
          home: Scaffold(
            body: const SizedBox.expand(),
            bottomNavigationBar: FloatingGlassBottomBar(
              selectedIndex: 1,
              onTabSelected: (_) {},
              onQuickActionPressed: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 400));

    expect(tester.takeException(), isNull);
    expect(find.byType(FloatingGlassBottomBar), findsOneWidget);
  });

  testWidgets('FourTileQuickActionIcon animates gently and stays safely within boundaries', (tester) async {
    bool quickActionPressed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: const SizedBox.expand(),
          bottomNavigationBar: FloatingGlassBottomBar(
            selectedIndex: 0,
            onTabSelected: (_) {},
            onQuickActionPressed: () => quickActionPressed = true,
          ),
        ),
      ),
    );
    await tester.pump();

    // 1. Kiểm tra sự hiện diện của FourTileQuickActionIcon và RepaintBoundary cách ly
    expect(find.byType(FourTileQuickActionIcon), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(FourTileQuickActionIcon),
        matching: find.byType(RepaintBoundary),
      ),
      findsOneWidget,
    );

    // 2. Kiểm tra khoảng cách an toàn tới mép viền ngoài (đảo kính 66x66)
    final iconFinder = find.byType(FourTileQuickActionIcon);
    final iconSize = tester.getSize(iconFinder);

    // Kích thước của cụm icon là size + 8 = 38x38 (nằm gọn lọt trong ô tròn 66x66)
    expect(iconSize.width, lessThanOrEqualTo(42.0));
    expect(iconSize.height, lessThanOrEqualTo(42.0));

    // Khoảng cách tới mép viền đảo kính luôn >= 12px
    final outerCircleRadius = 33.0;
    final maxInnerExtent = iconSize.width / 2.0;
    final marginToRim = outerCircleRadius - maxInnerExtent;
    expect(marginToRim, greaterThanOrEqualTo(12.0));

    // 3. Cho animation chạy qua các frame (nhịp thở và bồng bềnh)
    await tester.pump(const Duration(milliseconds: 800));
    expect(tester.takeException(), isNull);

    await tester.pump(const Duration(milliseconds: 1600));
    expect(tester.takeException(), isNull);

    // 4. Kiểm tra sự kiện bấm nút nhanh
    await tester.tap(find.byType(FourTileQuickActionIcon));
    await tester.pump();
    expect(quickActionPressed, isTrue);
  });

  testWidgets('Tab 3 renders ticket icon and switches to tab 3 on tap', (tester) async {
    int selectedTab = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            return Scaffold(
              body: const SizedBox.expand(),
              bottomNavigationBar: FloatingGlassBottomBar(
                selectedIndex: selectedTab,
                onTabSelected: (i) {
                  setState(() => selectedTab = i);
                },
                onQuickActionPressed: () {},
              ),
            );
          },
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    // Verify ticket icon is present
    expect(find.byIcon(Icons.confirmation_number_outlined), findsOneWidget);

    // Tap on Tab 3 (Đặt vé)
    await tester.tap(find.byTooltip('Đặt vé'));
    await tester.pumpAndSettle();

    expect(selectedTab, 3);
    expect(find.byTooltip('Đặt vé'), findsOneWidget);
  });
}
