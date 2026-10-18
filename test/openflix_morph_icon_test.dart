import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openflix/presentation/widgets/glass/openflix_morph_icon.dart';
import 'package:openflix/presentation/widgets/glass/glass_player_play_button.dart';
import 'package:openflix/presentation/widgets/glass/glass_action_button.dart';
import 'package:openflix/presentation/widgets/glass/glass_icon_button.dart';
import 'package:openflix/presentation/widgets/glass/glass_media_toolbar.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OpenFlixMorphIcon Tests', () {
    testWidgets('renders initial icon correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OpenFlixMorphIcon(
              icon: Icons.play_arrow_rounded,
              size: 32,
              color: Colors.red,
            ),
          ),
        ),
      );

      expect(find.byType(OpenFlixMorphIcon), findsOneWidget);
    });

    testWidgets('morphs to new icon smoothly without error', (tester) async {
      IconData currentIcon = Icons.play_arrow_rounded;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              home: Scaffold(
                body: GestureDetector(
                  onTap: () {
                    setState(() {
                      currentIcon = Icons.pause_rounded;
                    });
                  },
                  child: OpenFlixMorphIcon.smooth(
                    icon: currentIcon,
                    size: 36,
                  ),
                ),
              ),
            );
          },
        ),
      );

      expect(find.byType(OpenFlixMorphIcon), findsOneWidget);

      // Tap to switch icon
      await tester.tap(find.byType(GestureDetector));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      expect(find.byType(OpenFlixMorphIcon), findsOneWidget);
    });

    testWidgets('GlassPlayerPlayButton uses morph icon on play/pause toggle', (tester) async {
      bool isPlaying = false;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              home: Scaffold(
                body: GlassPlayerPlayButton(
                  isPlaying: isPlaying,
                  onPressed: () {
                    setState(() {
                      isPlaying = !isPlaying;
                    });
                  },
                ),
              ),
            );
          },
        ),
      );

      expect(find.byType(GlassPlayerPlayButton), findsOneWidget);
      expect(find.byType(OpenFlixMorphIcon), findsOneWidget);

      // Tap play button
      await tester.tap(find.byType(GlassPlayerPlayButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      expect(isPlaying, isTrue);
    });

    testWidgets('GlassActionButton bookmark morphs between inactive and active', (tester) async {
      bool isBookmarked = false;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              home: Scaffold(
                body: GlassActionButton.bookmark(
                  isBookmarked: isBookmarked,
                  onPressed: () {
                    setState(() {
                      isBookmarked = !isBookmarked;
                    });
                  },
                ),
              ),
            );
          },
        ),
      );

      expect(find.byType(GlassActionButton), findsOneWidget);
      expect(find.byType(OpenFlixMorphIcon), findsOneWidget);

      await tester.tap(find.byType(GlassActionButton));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(isBookmarked, isTrue);
    });

    testWidgets('GlassIconButton morphs icon on update', (tester) async {
      IconData icon = Icons.add;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              home: Scaffold(
                body: GlassIconButton.rounded(
                  icon: icon,
                  onPressed: () {
                    setState(() {
                      icon = Icons.check;
                    });
                  },
                ),
              ),
            );
          },
        ),
      );

      expect(find.byType(GlassIconButton), findsOneWidget);
      expect(find.byType(OpenFlixMorphIcon), findsOneWidget);

      await tester.tap(find.byType(GlassIconButton));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.byType(OpenFlixMorphIcon), findsOneWidget);
    });

    testWidgets('GlassMediaToolbar integrates OpenFlixMorphIcon for mute and fullscreen', (tester) async {
      bool isMuted = false;
      bool isFullscreen = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassMediaToolbar(
              isMuted: isMuted,
              isFullscreen: isFullscreen,
              onMuteToggle: () => isMuted = !isMuted,
              onFullscreenToggle: () => isFullscreen = !isFullscreen,
              onForward10: () {},
              onFitModeToggle: () {},
            ),
          ),
        ),
      );

      // Verify morph icons are used in toolbar
      expect(find.byType(OpenFlixMorphIcon), findsWidgets);
    });

    testWidgets('Hot-reload proof: OpenFlixMorphIcon safely handles rebuild and didUpdateWidget without LateInitializationError', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OpenFlixMorphIcon(icon: Icons.person),
          ),
        ),
      );

      // Re-pump with updated icon simulating hot-reload state update
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OpenFlixMorphIcon(icon: Icons.child_care),
          ),
        ),
      );

      expect(find.byIcon(Icons.child_care), findsOneWidget);
    });
  });
}
