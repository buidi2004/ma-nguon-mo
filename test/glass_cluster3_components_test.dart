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

  group('Đợt 3: GlassPlayThumbnailOverlay Tests', () {
    testWidgets('Renders play button and triggers onTap callback', (
      tester,
    ) async {
      bool tapped = false;

      await tester.pumpWidget(
        buildTestable(
          GlassPlayThumbnailOverlay(
            imageUrl: '',
            width: 120,
            height: 80,
            progressRatio: 0.45,
            onTap: () => tapped = true,
          ),
        ),
      );

      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);

      await tester.tap(find.byType(GlassPlayThumbnailOverlay));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('Renders progress bar correctly when progressRatio is provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestable(
          GlassPlayThumbnailOverlay(
            imageUrl: '',
            width: 140,
            height: 90,
            progressRatio: 0.75,
            onTap: () {},
          ),
        ),
      );

      // Verify widget builds without error
      expect(find.byType(GlassPlayThumbnailOverlay), findsOneWidget);
      expect(find.byType(FractionallySizedBox), findsOneWidget);
    });
  });

  group('Đợt 3: GlassRadioTileGroup Tests', () {
    testWidgets('Renders options and selection triggers onChanged', (
      tester,
    ) async {
      String selected = 'Full HD (1080p)';
      const options = ['Tự động', 'Full HD (1080p)', 'HD (720p)'];

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return buildTestable(
              GlassRadioTileGroup.fromStrings(
                options: options,
                selectedOption: selected,
                onChanged: (val) {
                  setState(() => selected = val);
                },
              ),
            );
          },
        ),
      );

      expect(find.text('Tự động'), findsOneWidget);
      expect(find.text('Full HD (1080p)'), findsOneWidget);
      expect(find.text('HD (720p)'), findsOneWidget);

      // Selected option should have check circle icon
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
      expect(find.byIcon(Icons.circle_outlined), findsNWidgets(2));

      // Tap on HD (720p)
      await tester.tap(find.text('HD (720p)'));
      await tester.pump();

      expect(selected, equals('HD (720p)'));
    });

    testWidgets('Supports vertical list mode (isWrap: false)', (tester) async {
      String selected = 'Tiếng Việt';
      const items = [
        GlassRadioItem(value: 'Tiếng Việt', label: 'Tiếng Việt', subtitle: 'Mặc định'),
        GlassRadioItem(value: 'English', label: 'English', subtitle: 'US/UK'),
      ];

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return buildTestable(
              GlassRadioTileGroup<String>(
                items: items,
                selectedValue: selected,
                isWrap: false,
                onChanged: (val) {
                  setState(() => selected = val);
                },
              ),
            );
          },
        ),
      );

      expect(find.text('Tiếng Việt'), findsOneWidget);
      expect(find.text('Mặc định'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
      expect(find.text('US/UK'), findsOneWidget);

      await tester.tap(find.text('English'));
      await tester.pump();

      expect(selected, equals('English'));
    });
  });
}
