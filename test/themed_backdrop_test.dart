import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openflix/dark_luxury_background.dart';
import 'package:openflix/services/theme_service.dart';
import 'package:openflix/waves_background.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Một màn hình giả lập có state riêng (bộ đếm + vị trí cuộn) để chứng minh
/// thao tác "chuyển màu" không remount lại nội dung.
class _StatefulProbe extends StatefulWidget {
  const _StatefulProbe();

  @override
  State<_StatefulProbe> createState() => _StatefulProbeState();
}

class _StatefulProbeState extends State<_StatefulProbe> {
  int counter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Text('counter: $counter'),
          TextButton(
            onPressed: () => setState(() => counter++),
            child: const Text('tăng'),
          ),
          // Màn hình lồng thêm một lời gọi wrapIfBlue giống các screen thật.
          Expanded(
            child: WavesBackground.wrapIfBlue(
              const ColoredBox(color: Colors.transparent),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _app({Widget? child}) {
  return MaterialApp(
    builder: (context, inner) => ThemedBackdrop(child: inner),
    home: child,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({'app_theme_mode': 'netflixRed'});
  });

  group('ThemedBackdrop — nền dùng chung duy nhất', () {
    testWidgets('Chỉ có đúng một nền động dù màn hình tự gọi wrapIfBlue', (
      tester,
    ) async {
      await ThemeService.instance.setThemeMode(AppThemeMode.windowsBlue);
      await tester.pumpWidget(_app(child: const _StatefulProbe()));
      await tester.pump();

      // wrapIfBlue bên trong phải trở thành no-op nhờ scope của ThemedBackdrop.
      expect(find.byType(WavesBackground), findsOneWidget);
      expect(find.byType(DarkLuxuryBackground), findsNothing);
    });

    testWidgets('Đổi theme không remount nội dung (giữ nguyên state)', (
      tester,
    ) async {
      await ThemeService.instance.setThemeMode(AppThemeMode.windowsBlue);
      await tester.pumpWidget(_app(child: const _StatefulProbe()));
      await tester.pump();

      await tester.tap(find.text('tăng'));
      await tester.tap(find.text('tăng'));
      await tester.pump();
      expect(find.text('counter: 2'), findsOneWidget);

      // "Chuyển màu" Xanh → Vàng → Đỏ.
      await ThemeService.instance.setThemeMode(AppThemeMode.luxuryGold);
      await tester.pump();
      expect(find.byType(DarkLuxuryBackground), findsOneWidget);
      expect(find.byType(WavesBackground), findsNothing);
      // State của nội dung vẫn còn nguyên, tức là cây widget không bị remount.
      expect(find.text('counter: 2'), findsOneWidget);

      await ThemeService.instance.setThemeMode(AppThemeMode.netflixRed);
      await tester.pump();
      expect(find.byType(DarkLuxuryBackground), findsNothing);
      expect(find.byType(WavesBackground), findsNothing);
      expect(find.text('counter: 2'), findsOneWidget);

      // Trở lại theme xanh vẫn phải chỉ có một nền.
      await ThemeService.instance.setThemeMode(AppThemeMode.windowsBlue);
      await tester.pump();
      expect(find.byType(WavesBackground), findsOneWidget);
      expect(find.text('counter: 2'), findsOneWidget);
    });

    testWidgets('wrapIfBlue tự dựng nền khi đứng độc lập (test/preview)', (
      tester,
    ) async {
      await ThemeService.instance.setThemeMode(AppThemeMode.windowsBlue);
      await tester.pumpWidget(
        MaterialApp(
          home: WavesBackground.wrapIfBlue(
            const Scaffold(backgroundColor: Colors.transparent, body: Text('x')),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(WavesBackground), findsOneWidget);
    });
  });
}
