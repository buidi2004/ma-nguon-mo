import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:video_player/video_player.dart';

import 'package:openflix/presentation/widgets/player/fullscreen_player_overlay.dart';
import 'package:openflix/presentation/widgets/glass/glass_player_play_button.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late VideoPlayerController videoPlayerController;
  late ChewieController chewieController;

  setUp(() {
    videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse('https://vjs.zencdn.net/v/oceans.mp4'),
    );
    chewieController = ChewieController(
      videoPlayerController: videoPlayerController,
      autoPlay: false,
      looping: false,
    );
  });

  tearDown(() {
    chewieController.dispose();
    videoPlayerController.dispose();
  });

  Widget buildTestPlayer({
    String movieTitle = 'Cực Quang Tử Địa',
    VideoFitMode initialFitMode = VideoFitMode.fit,
    ValueChanged<VideoFitMode>? onFitModeChanged,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: OpenFlixFullscreenPlayer(
          controller: chewieController,
          movieTitle: movieTitle,
          initialFitMode: initialFitMode,
          onFitModeChanged: onFitModeChanged,
        ),
      ),
    );
  }

  group('OpenFlixFullscreenPlayer YouTube Hybrid Gestures & UI Tests', () {
    testWidgets('1. Fullscreen player renders title, mode chip, and play button', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestPlayer());
      await tester.pump();

      expect(find.text('Cực Quang Tử Địa'), findsOneWidget);
      expect(find.text('16:9'), findsOneWidget);
      expect(find.byType(GlassPlayerPlayButton), findsOneWidget);
      expect(find.byType(InteractiveViewer), findsOneWidget);
    });

    testWidgets('2. Tapping mode chip cycles 16:9 -> Tràn viền -> Kéo giãn', (
      tester,
    ) async {
      VideoFitMode? updatedMode;
      await tester.pumpWidget(
        buildTestPlayer(
          onFitModeChanged: (mode) => updatedMode = mode,
        ),
      );
      await tester.pump();

      expect(find.text('16:9'), findsOneWidget);

      // Tap to cycle to Tràn viền (Fill)
      await tester.tap(find.text('16:9'));
      await tester.pump();

      expect(find.text('Tràn viền'), findsOneWidget);
      expect(updatedMode, VideoFitMode.fill);
      expect(find.text('Phóng to để vừa màn hình'), findsOneWidget);

      // Tap to cycle to Kéo giãn (Stretch)
      await tester.tap(find.text('Tràn viền'));
      await tester.pump();

      expect(find.text('Kéo giãn'), findsOneWidget);
      expect(updatedMode, VideoFitMode.stretch);
      expect(find.text('Kéo giãn toàn màn hình'), findsOneWidget);

      // Tap to cycle back to 16:9 (Fit)
      await tester.tap(find.text('Kéo giãn'));
      await tester.pump();

      expect(find.text('16:9'), findsOneWidget);
      expect(updatedMode, VideoFitMode.fit);
      expect(find.text('Vừa màn hình (Gốc)'), findsOneWidget);
    });

    testWidgets('3. Single tap toggles controls overlay visibility', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestPlayer());
      await tester.pump();

      // Controls initially visible
      expect(find.byType(GlassPlayerPlayButton), findsOneWidget);

      // Single tap on empty area (x=100, y=300) toggles controls off
      await tester.tapAt(const Offset(100, 300));
      await tester.pump(const Duration(milliseconds: 300));

      final animatedOpacity = tester.widget<AnimatedOpacity>(
        find.byType(AnimatedOpacity),
      );
      expect(animatedOpacity.opacity, 0.0);

      // Single tap again toggles controls back on
      await tester.tapAt(const Offset(100, 300));
      await tester.pump(const Duration(milliseconds: 300));

      final animatedOpacityBack = tester.widget<AnimatedOpacity>(
        find.byType(AnimatedOpacity),
      );
      expect(animatedOpacityBack.opacity, 1.0);

      await tester.pump(const Duration(seconds: 4));
    });

    testWidgets('4. Double tap on left/right triggers seek HUD & ripples', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestPlayer());
      await tester.pump();

      // Double tap on left (x=60) -> Tua lùi
      final leftPoint = const Offset(60, 200);

      await tester.tapAt(leftPoint);
      await tester.pump(const Duration(milliseconds: 60));
      await tester.tapAt(leftPoint);
      await tester.pump(const Duration(milliseconds: 60));

      expect(find.text('Tua -10s'), findsOneWidget);
      expect(find.text('-10 giây'), findsOneWidget);

      // Chờ debounce tua lùi hoàn tất trước khi tua tới
      await tester.pump(const Duration(milliseconds: 600));

      // Double tap on right (x=740) -> Tua tới
      final rightPoint = const Offset(740, 200);

      await tester.tapAt(rightPoint);
      await tester.pump(const Duration(milliseconds: 60));
      await tester.tapAt(rightPoint);
      await tester.pump(const Duration(milliseconds: 60));

      expect(find.text('Tua +10s'), findsOneWidget);
      expect(find.text('+10 giây'), findsOneWidget);

      await tester.pump(const Duration(seconds: 4));
    });

    testWidgets('5. Double tap center cycles between 16:9 and Tràn viền', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestPlayer());
      await tester.pump();

      // Tap in center area but above play button (x=400, y=180)
      const centerPoint = Offset(400, 180);

      await tester.tapAt(centerPoint);
      await tester.pump(const Duration(milliseconds: 60));
      await tester.tapAt(centerPoint);
      await tester.pump(const Duration(milliseconds: 60));

      expect(find.text('Tràn viền'), findsOneWidget);
      expect(find.text('Phóng to để vừa màn hình'), findsOneWidget);

      await tester.pump(const Duration(seconds: 4));
    });

    testWidgets('6. Speed chip cycles playback speeds (1.0x -> 1.25x -> 1.5x -> 2.0x)', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestPlayer());
      await tester.pump();

      expect(find.text('1.0x'), findsOneWidget);

      await tester.tap(find.text('1.0x'));
      await tester.pump();
      expect(find.text('1.25x'), findsOneWidget);
      expect(find.text('Tốc độ: 1.25x'), findsOneWidget);

      await tester.tap(find.text('1.25x'));
      await tester.pump();
      expect(find.text('1.5x'), findsOneWidget);

      await tester.tap(find.text('1.5x'));
      await tester.pump();
      expect(find.text('2.0x'), findsOneWidget);

      await tester.tap(find.text('2.0x'));
      await tester.pump();
      expect(find.text('1.0x'), findsOneWidget);
    });
  });
}
