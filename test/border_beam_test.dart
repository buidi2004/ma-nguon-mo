import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openflix/presentation/widgets/glass/border_beam.dart';
import 'package:openflix/presentation/widgets/glass/border_beam_search_bar.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BorderBeam Widget Tests', () {
    testWidgets('Renders BorderBeam with default properties and child', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BorderBeam(
              child: SizedBox(
                width: 200,
                height: 50,
                child: Text('Test Child'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Test Child'), findsOneWidget);
      expect(find.byType(BorderBeam), findsOneWidget);

      // Verify animation frames pump without error
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 500));
    });

    testWidgets('Renders BorderBeam with all color variants', (tester) async {
      for (final variant in BorderBeamColorVariant.values) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BorderBeam(
                colorVariant: variant,
                size: BorderBeamSize.lg,
                child: SizedBox(
                  width: 150,
                  height: 40,
                ),
              ),
            ),
          ),
        );

        expect(find.byType(BorderBeam), findsOneWidget);
        await tester.pump(const Duration(milliseconds: 50));
      }
    });

    testWidgets('Initializes BorderBeam from BorderBeamProps factory', (tester) async {
      const props = BorderBeamProps(
        duration: 4.0,
        borderWidth: 2.5,
        size: BorderBeamSize.sm,
        colorVariant: BorderBeamColorVariant.neonBlue,
        reverse: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BorderBeam.fromProps(
              props: props,
              child: const Text('Props Child'),
            ),
          ),
        ),
      );

      expect(find.text('Props Child'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 100));
    });
  });

  group('BorderBeamSearchBar Tests', () {
    testWidgets('Renders search bar, types text, and triggers callbacks', (tester) async {
      String searchedQuery = '';
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BorderBeamSearchBar(
              controller: controller,
              debounceDuration: Duration.zero,
              onChanged: (val) => searchedQuery = val,
            ),
          ),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.search_rounded), findsOneWidget);
      // Close button not present initially when text is empty
      expect(find.byIcon(Icons.close_rounded), findsNothing);

      // Enter text
      await tester.enterText(find.byType(TextField), 'Avengers');
      await tester.pump();

      expect(searchedQuery, 'Avengers');
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);

      // Tap clear button
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pump();

      expect(searchedQuery, '');
      expect(controller.text, '');
      expect(find.byIcon(Icons.close_rounded), findsNothing);
    });

    testWidgets('Renders action buttons (Voice and Filter) when callbacks provided', (tester) async {
      bool voiceTapped = false;
      bool filterTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BorderBeamSearchBar(
              onVoiceTap: () => voiceTapped = true,
              onFilterTap: () => filterTapped = true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.mic_none_rounded), findsOneWidget);
      expect(find.byIcon(Icons.tune_rounded), findsOneWidget);

      await tester.tap(find.byIcon(Icons.mic_none_rounded));
      expect(voiceTapped, isTrue);

      await tester.tap(find.byIcon(Icons.tune_rounded));
      expect(filterTapped, isTrue);
    });

    testWidgets('Renders Pill Search button when text is entered and triggers submit on tap', (tester) async {
      String submittedQuery = '';
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BorderBeamSearchBar(
              controller: controller,
              showSearchButton: true,
              searchButtonLabel: 'Tìm',
              onSubmitted: (val) => submittedQuery = val,
            ),
          ),
        ),
      );

      // Initially no search pill button when text is empty
      expect(find.text('Tìm'), findsNothing);

      // Enter text to trigger pill search button
      await tester.enterText(find.byType(TextField), 'Inception');
      await tester.pump();

      expect(find.text('Tìm'), findsOneWidget);

      // Tap the pill search button
      await tester.tap(find.text('Tìm'));
      await tester.pump();

      expect(submittedQuery, 'Inception');
    });

    testWidgets('Renders Cancel button when showCancelButton is true and focused', (tester) async {
      bool cancelTapped = false;
      final focusNode = FocusNode();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BorderBeamSearchBar(
              focusNode: focusNode,
              showCancelButton: true,
              onCancelTap: () => cancelTapped = true,
            ),
          ),
        ),
      );

      // Initially cancel button is collapsed
      expect(find.text('Hủy'), findsNothing);

      // Request focus
      focusNode.requestFocus();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));

      expect(find.text('Hủy'), findsOneWidget);

      // Tap Cancel button
      await tester.tap(find.text('Hủy'));
      await tester.pump();

      expect(cancelTapped, isTrue);
      expect(focusNode.hasFocus, isFalse);
    });
  });
}
