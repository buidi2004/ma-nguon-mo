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

  group('Cụm 1: GlassShimmerCTA Tests', () {
    testWidgets('Renders label, icon and satisfies touch target >= 44x44px', (
      tester,
    ) async {
      bool tapped = false;

      await tester.pumpWidget(
        buildTestable(
          GlassShimmerCTA.play(
            label: 'Phát ngay',
            icon: Icons.play_arrow_rounded,
            onPressed: () => tapped = true,
          ),
        ),
      );

      expect(find.text('Phát ngay'), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);

      final renderBox = tester.renderObject<RenderBox>(
        find.byType(GlassShimmerCTA),
      );
      expect(renderBox.size.height, greaterThanOrEqualTo(44.0));

      await tester.tap(find.byType(GlassShimmerCTA));
      expect(tapped, isTrue);
    });

    testWidgets('GlassShimmerCTA.vipPrice renders price and quality tag', (
      tester,
    ) async {
      bool tapped = false;

      await tester.pumpWidget(
        buildTestable(
          GlassShimmerCTA.vipPrice(
            price: '29.000đ',
            qualityTag: 'HD',
            onPressed: () => tapped = true,
          ),
        ),
      );

      expect(find.text('29.000đ'), findsOneWidget);
      expect(find.text('HD'), findsOneWidget);

      await tester.tap(find.byType(GlassShimmerCTA));
      expect(tapped, isTrue);
    });

    testWidgets('GlassShimmerCTA disabled state ignores clicks', (tester) async {
      await tester.pumpWidget(
        buildTestable(
          GlassShimmerCTA.play(
            label: 'Khóa',
            onPressed: null,
            enableShimmer: false,
          ),
        ),
      );

      expect(find.text('Khóa'), findsOneWidget);
      await tester.tap(find.byType(GlassShimmerCTA));
      // Safely does nothing
    });
  });

  group('Cụm 1: GlassDynamicSearchBar Tests', () {
    testWidgets('Renders hint, search icon and responds to text changes', (
      tester,
    ) async {
      final controller = TextEditingController();
      String changedText = '';

      await tester.pumpWidget(
        buildTestable(
          GlassDynamicSearchBar(
            controller: controller,
            hintText: 'Tìm kiếm phim...',
            onChanged: (val) => changedText = val,
          ),
        ),
      );

      expect(find.text('Tìm kiếm phim...'), findsOneWidget);
      expect(find.byIcon(Icons.search_rounded), findsOneWidget);

      // Nhập text
      await tester.enterText(find.byType(TextField), 'Oceans');
      await tester.pump();

      expect(changedText, equals('Oceans'));
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);

      // Bấm nút xoá nhanh (Clear)
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pump();

      expect(controller.text, isEmpty);
      expect(changedText, isEmpty);
      expect(find.byIcon(Icons.close_rounded), findsNothing);
    });

    testWidgets('Fires onFilterTap callback when filter icon is provided', (
      tester,
    ) async {
      final controller = TextEditingController();
      bool filterTapped = false;

      await tester.pumpWidget(
        buildTestable(
          GlassDynamicSearchBar(
            controller: controller,
            onFilterTap: () => filterTapped = true,
          ),
        ),
      );

      expect(find.byIcon(Icons.tune_rounded), findsOneWidget);
      await tester.tap(find.byIcon(Icons.tune_rounded));
      expect(filterTapped, isTrue);
    });
  });

  group('Cụm 1: GlassSpecBadge Tests', () {
    testWidgets('Renders all predefined factory variants correctly', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestable(
          Wrap(
            spacing: 8,
            children: [
              GlassSpecBadge.uhd4k(),
              GlassSpecBadge.hdr(),
              GlassSpecBadge.dolby(),
              GlassSpecBadge.hd(),
              GlassSpecBadge.top10(rank: 1),
              GlassSpecBadge.age(rating: 'T18'),
              GlassSpecBadge.tag(label: 'THUYẾT MINH'),
            ],
          ),
        ),
      );

      expect(find.text('4K ULTRA HD'), findsOneWidget);
      expect(find.text('HDR10+'), findsOneWidget);
      expect(find.text('DOLBY ATMOS'), findsOneWidget);
      expect(find.text('HD'), findsOneWidget);
      expect(find.text('TOP 1'), findsOneWidget);
      expect(find.text('T18'), findsOneWidget);
      expect(find.text('THUYẾT MINH'), findsOneWidget);
    });
  });
}
