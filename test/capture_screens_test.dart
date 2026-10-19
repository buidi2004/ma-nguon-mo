// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openflix/features/auth/login_screen.dart';
import 'package:openflix/theme/app_theme.dart';

Future<void> loadFonts() async {
  // 1. Load System Fonts for Typography
  final regularFile = File(r'C:\Windows\Fonts\segoeui.ttf');
  if (regularFile.existsSync()) {
    final fontData = regularFile.readAsBytesSync();
    for (final family in ['Outfit', 'Roboto', 'sans-serif', '']) {
      final loader = FontLoader(family);
      loader.addFont(Future.value(ByteData.view(fontData.buffer)));
      await loader.load();
    }
  }

  // 2. Load MaterialIcons Font for Real Icons
  final iconFile = File(r'C:\Users\buidi\flutter\bin\cache\artifacts\material_fonts\MaterialIcons-Regular.otf');
  if (iconFile.existsSync()) {
    final fontData = iconFile.readAsBytesSync();
    final loader = FontLoader('MaterialIcons');
    loader.addFont(Future.value(ByteData.view(fontData.buffer)));
    await loader.load();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Test true mobile portrait with real icons', (tester) async {
    await tester.runAsync(() async {
      await loadFonts();
    });

    final boundaryKey = GlobalKey();

    // Chuẩn xác điện thoại dọc 1080 x 2316 (tỉ lệ 9:19.3 của Samsung Note 20 Ultra)
    tester.view.physicalSize = const Size(1080, 2316);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        home: RepaintBoundary(
          key: boundaryKey,
          child: const Scaffold(
            body: LoginScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.runAsync(() async {
      final boundary = boundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 2.75);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final file = File('docs/qa/screenshots/test_portrait_login.png');
      file.writeAsBytesSync(byteData!.buffer.asUint8List());
      print('Saved ${file.path}, size: ${image.width} x ${image.height}');
    });
  });
}
