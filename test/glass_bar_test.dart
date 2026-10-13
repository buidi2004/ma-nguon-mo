import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openflix/presentation/widgets/floating_glass_bottom_bar.dart';

void main() {
  testWidgets('FloatingGlassBottomBar renders without crashing', (tester) async {
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
  });
}
