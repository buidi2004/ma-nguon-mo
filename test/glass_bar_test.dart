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
      await tester.pumpAndSettle();

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

      await tester.pumpAndSettle(); // Complete animation
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
    await tester.pumpAndSettle();

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
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(FloatingGlassBottomBar), findsOneWidget);
  });
}
