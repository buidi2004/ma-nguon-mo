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

  group('Giai đoạn 3 & 4: GlassPlayerPlayButton Tests', () {
    testWidgets('Touch target meets cinema standard >= 44x44px (default 68x68px)', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestable(
          GlassPlayerPlayButton(
            isPlaying: false,
            onPressed: () {},
          ),
        ),
      );

      final renderBox = tester.renderObject<RenderBox>(
        find.byType(GlassPlayerPlayButton),
      );
      expect(renderBox.size.width, greaterThanOrEqualTo(44.0));
      expect(renderBox.size.height, greaterThanOrEqualTo(44.0));
      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
    });

    testWidgets('Toggles icon between Play and Pause states', (tester) async {
      // 1. Pause state -> displays Play icon
      await tester.pumpWidget(
        buildTestable(
          GlassPlayerPlayButton(
            isPlaying: false,
            onPressed: () {},
          ),
        ),
      );
      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
      expect(find.byIcon(Icons.pause_rounded), findsNothing);

      // 2. Play state -> displays Pause icon
      await tester.pumpWidget(
        buildTestable(
          GlassPlayerPlayButton(
            isPlaying: true,
            onPressed: () {},
          ),
        ),
      );
      expect(find.byIcon(Icons.pause_rounded), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow_rounded), findsNothing);
    });

    testWidgets('Shows CircularProgressIndicator when isLoading is true', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestable(
          GlassPlayerPlayButton(
            isPlaying: true,
            isLoading: true,
            onPressed: () {},
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byIcon(Icons.pause_rounded), findsNothing);
      expect(find.byIcon(Icons.play_arrow_rounded), findsNothing);
    });

    testWidgets('Triggers onPressed callback when tapped', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        buildTestable(
          GlassPlayerPlayButton(
            isPlaying: false,
            onPressed: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.byType(GlassPlayerPlayButton));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('Disabled state (null onPressed) safely handles tap without crashing', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestable(
          const GlassPlayerPlayButton(
            isPlaying: false,
            onPressed: null,
          ),
        ),
      );

      await tester.tap(find.byType(GlassPlayerPlayButton));
      await tester.pump();
      expect(find.byType(GlassPlayerPlayButton), findsOneWidget);
    });
  });

  group('Giai đoạn 3 & 4: GlassMediaToolbar Tests', () {
    testWidgets('Renders all controls and touch targets meet >= 44x44px standard', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestable(
          GlassMediaToolbar(
            onReplay10: () {},
            onForward10: () {},
            onFitModeToggle: () {},
            fitModeLabel: '16:9',
            onSpeedToggle: () {},
            currentSpeed: 1.0,
            onMuteToggle: () {},
            isMuted: false,
            onFullscreenToggle: () {},
            isFullscreen: false,
          ),
        ),
      );

      expect(find.byIcon(Icons.replay_10_rounded), findsOneWidget);
      expect(find.byIcon(Icons.forward_10_rounded), findsOneWidget);
      expect(find.text('16:9'), findsOneWidget);
      expect(find.text('1x'), findsOneWidget);
      expect(find.byIcon(Icons.volume_up_rounded), findsOneWidget);
      expect(find.byIcon(Icons.fullscreen_rounded), findsOneWidget);

      final renderBox = tester.renderObject<RenderBox>(
        find.byType(GlassMediaToolbar),
      );
      expect(renderBox.size.height, greaterThanOrEqualTo(44.0));
    });

    testWidgets('Dispatches all media interaction callbacks', (tester) async {
      bool replayed = false;
      bool forwarded = false;
      bool fitToggled = false;
      bool speedToggled = false;
      bool muteToggled = false;
      bool fullscreenToggled = false;

      await tester.pumpWidget(
        buildTestable(
          GlassMediaToolbar(
            onReplay10: () => replayed = true,
            onForward10: () => forwarded = true,
            onFitModeToggle: () => fitToggled = true,
            fitModeLabel: 'Tràn viền',
            onSpeedToggle: () => speedToggled = true,
            currentSpeed: 1.25,
            onMuteToggle: () => muteToggled = true,
            isMuted: true,
            onFullscreenToggle: () => fullscreenToggled = true,
            isFullscreen: true,
          ),
        ),
      );

      // 1. Tua lùi 10s
      await tester.tap(find.byIcon(Icons.replay_10_rounded));
      await tester.pump();
      expect(replayed, isTrue);

      // 2. Tua tới 10s
      await tester.tap(find.byIcon(Icons.forward_10_rounded));
      await tester.pump();
      expect(forwarded, isTrue);

      // 3. Tỷ lệ màn hình (Fit mode)
      await tester.tap(find.text('Tràn viền'));
      await tester.pump();
      expect(fitToggled, isTrue);

      // 4. Tốc độ phát (Speed)
      await tester.tap(find.text('1.25x'));
      await tester.pump();
      expect(speedToggled, isTrue);

      // 5. Mute toggle (khi đang tắt tiếng -> hiển thị volume_off)
      expect(find.byIcon(Icons.volume_off_rounded), findsOneWidget);
      await tester.tap(find.byIcon(Icons.volume_off_rounded));
      await tester.pump();
      expect(muteToggled, isTrue);

      // 6. Fullscreen exit toggle
      expect(find.byIcon(Icons.fullscreen_exit_rounded), findsOneWidget);
      await tester.tap(find.byIcon(Icons.fullscreen_exit_rounded));
      await tester.pump();
      expect(fullscreenToggled, isTrue);
    });
  });

  group('Giai đoạn 4: Responsive & Zero Overflow Tests', () {
    testWidgets('No overflow on narrow screen (320 x 640)', (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        buildTestable(
          SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GlassPlayerPlayButton(
                  isPlaying: false,
                  onPressed: () {},
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: GlassMediaToolbar(
                    onReplay10: () {},
                    onForward10: () {},
                    onFitModeToggle: () {},
                    fitModeLabel: '16:9',
                    onSpeedToggle: () {},
                    currentSpeed: 1.0,
                    onMuteToggle: () {},
                    onFullscreenToggle: () {},
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);
    });

    testWidgets('No overflow on tablet screen (800 x 1200)', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        buildTestable(
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GlassPlayerPlayButton(
                isPlaying: true,
                onPressed: () {},
              ),
              const SizedBox(height: 24),
              GlassMediaToolbar(
                onReplay10: () {},
                onForward10: () {},
                onFitModeToggle: () {},
                fitModeLabel: '16:9',
                onSpeedToggle: () {},
                currentSpeed: 1.5,
                onMuteToggle: () {},
                onFullscreenToggle: () {},
              ),
            ],
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  group('Giai đoạn 4: Optical Tokens Specification Tests', () {
    test('Verifies optical tokens match system specification table', () {
      expect(GlassOpticalTokens.playerPlayButtonSize, equals(68.0));
      expect(GlassOpticalTokens.playerPlayButtonBlur, equals(20.0));
      expect(GlassOpticalTokens.playerPlayButtonSnell, equals(1.48));
      expect(GlassOpticalTokens.playerPlayButtonRadius, equals(34.0));

      expect(GlassOpticalTokens.mediaToolbarHeight, equals(48.0));
      expect(GlassOpticalTokens.mediaToolbarBlur, equals(16.0));
      expect(GlassOpticalTokens.mediaToolbarSnell, equals(1.45));
      expect(GlassOpticalTokens.mediaToolbarRadius, equals(24.0));
    });
  });
}
