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

  group('Giai đoạn 1: GlassActionButton Tests', () {
    testWidgets('Renders label, icon and satisfies touch target >= 48x48px', (
      tester,
    ) async {
      bool tapped = false;

      await tester.pumpWidget(
        buildTestable(
          GlassActionButton(
            label: 'Thêm vào DS',
            icon: Icons.bookmark_outline_rounded,
            onPressed: () => tapped = true,
          ),
        ),
      );

      expect(find.text('Thêm vào DS'), findsOneWidget);
      expect(find.byIcon(Icons.bookmark_outline_rounded), findsOneWidget);

      final renderBox = tester.renderObject<RenderBox>(
        find.byType(GlassActionButton),
      );
      expect(renderBox.size.width, greaterThanOrEqualTo(48.0));
      expect(renderBox.size.height, greaterThanOrEqualTo(48.0));

      await tester.tap(find.byType(GlassActionButton));
      expect(tapped, isTrue);
    });

    testWidgets('GlassActionButton.bookmark changes active icon when bookmarked', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestable(
          GlassActionButton.bookmark(
            isBookmarked: true,
            onPressed: () {},
          ),
        ),
      );

      expect(find.byIcon(Icons.bookmark_rounded), findsOneWidget);
      expect(find.byIcon(Icons.bookmark_outline_rounded), findsNothing);
    });

    testWidgets('GlassActionButton disabled stops input', (tester) async {
      await tester.pumpWidget(
        buildTestable(
          const GlassActionButton(
            label: 'Khóa',
            icon: Icons.lock_outline,
            onPressed: null,
          ),
        ),
      );

      expect(find.text('Khóa'), findsOneWidget);
      await tester.tap(find.byType(GlassActionButton));
      // No crash, input safely ignored
    });
  });

  group('Giai đoạn 1: GlassChipButton Tests', () {
    testWidgets('Renders label, count and toggles selection', (tester) async {
      bool selectedState = false;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return buildTestable(
              GlassChipButton(
                label: 'Hành động',
                count: 42,
                isSelected: selectedState,
                onSelected: (val) {
                  setState(() => selectedState = val);
                },
              ),
            );
          },
        ),
      );

      expect(find.text('Hành động'), findsOneWidget);
      expect(find.text('42'), findsOneWidget);

      await tester.tap(find.byType(GlassChipButton));
      await tester.pumpAndSettle();

      expect(selectedState, isTrue);
    });

    testWidgets('GlassChipButton.filter shows checkmark when selected', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestable(
          GlassChipButton.filter(
            label: 'Tâm lý',
            isSelected: true,
            onSelected: (_) {},
          ),
        ),
      );

      expect(find.text('Tâm lý'), findsOneWidget);
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });
  });

  group('Giai đoạn 1: GlassDestructiveButton Tests', () {
    testWidgets('Renders destructive styling and opens confirmation dialog', (
      tester,
    ) async {
      bool deleted = false;

      await tester.pumpWidget(
        buildTestable(
          GlassDestructiveButton(
            text: 'Xóa toàn bộ lịch sử',
            icon: Icons.delete_outline_rounded,
            requiresConfirmation: true,
            confirmationTitle: 'Xác nhận xóa lịch sử',
            confirmActionLabel: 'Đồng ý xóa',
            onPressed: () => deleted = true,
          ),
        ),
      );

      expect(find.text('Xóa toàn bộ lịch sử'), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline_rounded), findsOneWidget);

      // Tap button to show dialog
      await tester.tap(find.byType(GlassDestructiveButton));
      await tester.pumpAndSettle();

      expect(find.text('Xác nhận xóa lịch sử'), findsOneWidget);
      expect(find.text('Đồng ý xóa'), findsOneWidget);
      expect(find.text('Hủy bỏ'), findsOneWidget);

      // Confirm in dialog
      await tester.tap(find.text('Đồng ý xóa'));
      await tester.pumpAndSettle();

      expect(deleted, isTrue);
    });

    testWidgets('Cancelling dialog does not trigger onPressed', (tester) async {
      bool deleted = false;

      await tester.pumpWidget(
        buildTestable(
          GlassDestructiveButton(
            text: 'Xóa hồ sơ',
            requiresConfirmation: true,
            onPressed: () => deleted = true,
          ),
        ),
      );

      await tester.tap(find.byType(GlassDestructiveButton));
      await tester.pumpAndSettle();

      // Cancel
      await tester.tap(find.text('Hủy bỏ'));
      await tester.pumpAndSettle();

      expect(deleted, isFalse);
    });

    testWidgets('GlassDestructiveButton shows loading spinner when isLoading', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestable(
          GlassDestructiveButton(
            text: 'Đang xóa...',
            isLoading: true,
            onPressed: () {},
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Đang xóa...'), findsNothing);
    });
  });
}
