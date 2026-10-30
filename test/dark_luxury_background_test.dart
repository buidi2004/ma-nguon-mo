import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openflix/dark_luxury_background.dart';
import 'package:openflix/services/theme_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await ThemeService.instance.setThemeMode(AppThemeMode.netflixRed);
  });

  group('DarkLuxuryBackground Widget Tests', () {
    testWidgets('Renders all layers by default with child content', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DarkLuxuryBackground(
            child: const Center(
              child: Text('Luxury Content'),
            ),
          ),
        ),
      );

      expect(find.byType(DarkLuxuryBackground), findsOneWidget);
      expect(find.text('Luxury Content'), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('Supports static background mode (showGlow: false, showDust: false)', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DarkLuxuryBackground(
            showGlow: false,
            showDust: false,
            child: Text('Static Luxury'),
          ),
        ),
      );

      expect(find.text('Static Luxury'), findsOneWidget);
      expect(find.byType(DarkLuxuryBackground), findsOneWidget);
    });

    testWidgets('Supports removing flower but retaining vignette', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DarkLuxuryBackground(
            showFlower: false,
            showVignette: true,
            child: Text('No Flower With Vignette'),
          ),
        ),
      );

      expect(find.text('No Flower With Vignette'), findsOneWidget);
      expect(find.byType(DarkLuxuryBackground), findsOneWidget);
    });

    testWidgets('Renders standalone DarkLuxuryWallpaper', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DarkLuxuryWallpaper(),
        ),
      );

      expect(find.byType(DarkLuxuryWallpaper), findsOneWidget);
      expect(find.byType(DarkLuxuryBackground), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('Suspension and resume state works as expected', (tester) async {
      expect(DarkLuxuryBackground.isSuspended, isFalse);

      DarkLuxuryBackground.notifyVideoPlaybackStarted();
      expect(DarkLuxuryBackground.isSuspended, isTrue);

      DarkLuxuryBackground.notifyVideoPlaybackStopped();
      expect(DarkLuxuryBackground.isSuspended, isFalse);
    });

    testWidgets('wrapIfGold wraps child only when in luxuryGold mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DarkLuxuryBackground.wrapIfGold(
            const Text('Wrapped Test'),
          ),
        ),
      );

      // In netflixRed mode, should NOT wrap with DarkLuxuryBackground
      expect(find.text('Wrapped Test'), findsOneWidget);
      expect(find.byType(DarkLuxuryBackground), findsNothing);

      // Switch to luxuryGold
      await ThemeService.instance.setThemeMode(AppThemeMode.luxuryGold);
      await tester.pump();

      // Now should wrap with DarkLuxuryBackground
      expect(find.byType(DarkLuxuryBackground), findsOneWidget);
      expect(find.text('Wrapped Test'), findsOneWidget);
    });
  });
}

