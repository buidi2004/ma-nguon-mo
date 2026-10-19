// ignore_for_file: avoid_print
// Harness dùng chung cho các file capture màn hình (test/visual/**).
//
// Nội dung được tách nguyên trạng từ `test/capture_all_42_screens_test.dart`
// để 42 test S01..S42 có thể chạy song song trong nhiều isolate.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openflix/models/movie_model.dart';
import 'package:openflix/theme/app_theme.dart';

import '../support/test_image_mock.dart';

/// Thư mục tạm cấp cho `path_provider` trong test (tránh ghi rác vào repo).
Directory? _mockDocsDir;

Future<void> loadFonts() async {
  final regularFile = File(r'C:\Windows\Fonts\segoeui.ttf');
  if (regularFile.existsSync()) {
    final fontData = regularFile.readAsBytesSync();
    for (final family in ['Outfit', 'Roboto', 'sans-serif', '']) {
      final loader = FontLoader(family);
      loader.addFont(Future.value(ByteData.view(fontData.buffer)));
      await loader.load();
    }
  }

  final iconFile = File(
    r'C:\Users\buidi\flutter\bin\cache\artifacts\material_fonts\MaterialIcons-Regular.otf',
  );
  if (iconFile.existsSync()) {
    final fontData = iconFile.readAsBytesSync();
    final loader = FontLoader('MaterialIcons');
    loader.addFont(Future.value(ByteData.view(fontData.buffer)));
    await loader.load();
  }
}

final sampleMovie = MovieModel(
  id: 'movie_sample_1',
  title: 'Huyết Thống: Ký Ức Đẫm Máu',
  description: 'Bộ phim kinh dị tâm linh giật gân hàng đầu rạp chiếu.',
  category: 'Kinh dị & Tâm linh',
  posterUrl: 'https://images.unsplash.com/photo-1536440136628-849c177e76a1?w=800',
  videoUrl: 'https://vjs.zencdn.net/v/oceans.mp4',
  releaseYear: 2026,
  isFeatured: true,
);

Future<void> captureScreenWidget(
  WidgetTester tester,
  Widget screen,
  String filename, {
  Duration waitDuration = const Duration(milliseconds: 250),
}) async {
  final boundaryKey = GlobalKey();

  tester.view.physicalSize = const Size(1080, 2316);
  tester.view.devicePixelRatio = 2.75;

  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: RepaintBoundary(
        key: boundaryKey,
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: screen,
        ),
      ),
    ),
  );
  await tester.pump(waitDuration);

  await tester.runAsync(() async {
    final boundary =
        boundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 2.75);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final file = File('docs/qa/screenshots/$filename');
    file.parent.createSync(recursive: true);
    file.writeAsBytesSync(byteData!.buffer.asUint8List());
    print('📸 Saved $filename (${image.width}x${image.height})');
  });
}

/// Đăng ký toàn bộ mock/hạ tầng dùng chung cho một file capture.
///
/// Phải gọi ĐỒNG BỘ ở đầu `main()`, trước khi khai báo test.
void setUpVisualHarness() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Ảnh mạng -> PNG 1x1 nhúng sẵn, test không phụ thuộc mạng.
  mockNetworkImages();

  setUpAll(() async {
    await loadFonts();

    final mockDir = Directory(
      '${Directory.systemTemp.path}${Platform.pathSeparator}openflix_visual_test',
    );
    mockDir.createSync(recursive: true);
    _mockDocsDir = mockDir;

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async => _mockDocsDir!.path,
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/shared_preferences'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'getAll') return <String, Object>{};
        return null;
      },
    );
  });

  tearDownAll(() {
    restoreNetworkImages();
  });
}
