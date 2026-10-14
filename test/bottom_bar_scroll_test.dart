import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openflix/presentation/widgets/floating_glass_bottom_bar.dart';

void main() {
  testWidgets('Bottom bar near-bottom hide and show animation test', (
    WidgetTester tester,
  ) async {
    bool isBarVisible = true;

    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            return Scaffold(
              body: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification.metrics.axis != Axis.vertical) return false;
                  final maxScroll = notification.metrics.maxScrollExtent;
                  final extentAfter = notification.metrics.extentAfter;
                  if (maxScroll < 120.0) return false;

                  if (notification is ScrollUpdateNotification) {
                    final delta = notification.scrollDelta ?? 0.0;
                    if (delta < -2.0 && !isBarVisible) {
                      setState(() => isBarVisible = true);
                    } else if (delta > 2.0 &&
                        extentAfter <= 80.0 &&
                        isBarVisible) {
                      setState(() => isBarVisible = false);
                    }
                  }
                  return false;
                },
                child: ListView.builder(
                  itemCount: 50,
                  itemBuilder: (context, index) =>
                      ListTile(title: Text('Movie item $index')),
                ),
              ),
              bottomNavigationBar: AnimatedSlide(
                offset: isBarVisible ? Offset.zero : const Offset(0, 1.25),
                duration: const Duration(milliseconds: 300),
                child: AnimatedOpacity(
                  opacity: isBarVisible ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 260),
                  child: FloatingGlassBottomBar(
                    selectedIndex: 0,
                    onTabSelected: (_) {},
                    onQuickActionPressed: () {},
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    // 1. Ban đầu: Bottom bar hiển thị đầy đủ
    final initialSlide = tester.widget<AnimatedSlide>(
      find.byType(AnimatedSlide),
    );
    expect(initialSlide.offset, Offset.zero);
    final initialOpacity = tester.widget<AnimatedOpacity>(
      find.byType(AnimatedOpacity),
    );
    expect(initialOpacity.opacity, 1.0);

    // 2. Cuộn nhẹ ở giữa trang: Bottom bar VẪN hiển thị
    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pump();
    final midSlide = tester.widget<AnimatedSlide>(find.byType(AnimatedSlide));
    expect(midSlide.offset, Offset.zero);

    // 3. Cuộn mạnh đến sát đáy (chạm đáy): Bottom bar trượt ẩn
    await tester.drag(find.byType(ListView), const Offset(0, -4000));
    await tester.pump();
    final hidingSlide = tester.widget<AnimatedSlide>(
      find.byType(AnimatedSlide),
    );
    expect(hidingSlide.offset, const Offset(0, 1.25));

    // 4. Vuốt ngược lên từ đáy: Bottom bar trượt hiện trở lại
    await tester.drag(find.byType(ListView), const Offset(0, 300));
    await tester.pump();
    final showingSlide = tester.widget<AnimatedSlide>(
      find.byType(AnimatedSlide),
    );
    expect(showingSlide.offset, Offset.zero);
  });

  testWidgets(
    'Bottom bar hides when virtual keyboard opens and shows when closed',
    (WidgetTester tester) async {
      double keyboardBottomInset = 0.0;

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              final isKeyboardOpen = keyboardBottomInset > 0.0;
              final shouldShowBar = !isKeyboardOpen;

              return MediaQuery(
                data: MediaQueryData(
                  viewInsets: EdgeInsets.only(bottom: keyboardBottomInset),
                ),
                child: Scaffold(
                  body: Center(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          keyboardBottomInset = keyboardBottomInset > 0
                              ? 0.0
                              : 320.0;
                        });
                      },
                      child: const Text('Toggle Keyboard'),
                    ),
                  ),
                  bottomNavigationBar: AnimatedSlide(
                    offset: shouldShowBar ? Offset.zero : const Offset(0, 1.25),
                    duration: const Duration(milliseconds: 300),
                    child: AnimatedOpacity(
                      opacity: shouldShowBar ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 260),
                      child: FloatingGlassBottomBar(
                        selectedIndex: 0,
                        onTabSelected: (_) {},
                        onQuickActionPressed: () {},
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 1. Khi bàn phím đóng: Bottom bar hiển thị bình thường
      var slide = tester.widget<AnimatedSlide>(find.byType(AnimatedSlide));
      expect(slide.offset, Offset.zero);
      var opacity = tester.widget<AnimatedOpacity>(
        find.byType(AnimatedOpacity),
      );
      expect(opacity.opacity, 1.0);

      // 2. Mở bàn phím: Bottom bar trượt ẩn
      await tester.tap(find.text('Toggle Keyboard'));
      await tester.pump();
      slide = tester.widget<AnimatedSlide>(find.byType(AnimatedSlide));
      expect(slide.offset, const Offset(0, 1.25));

      // 3. Đóng bàn phím: Bottom bar trượt hiện trở lại
      await tester.tap(find.text('Toggle Keyboard'));
      await tester.pump();
      slide = tester.widget<AnimatedSlide>(find.byType(AnimatedSlide));
      expect(slide.offset, Offset.zero);
    },
  );
}
