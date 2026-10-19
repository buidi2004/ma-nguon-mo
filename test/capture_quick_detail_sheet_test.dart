// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openflix/models/movie_model.dart';
import 'package:openflix/theme/app_theme.dart';
import 'package:openflix/widgets/movie_quick_detail_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  SharedPreferences.setMockInitialValues({});

  final sampleMovie = MovieModel(
    id: 'movie_001',
    title: 'Madame Web',
    description: 'Cassandra Webb là một nhân viên y tế ở Manhattan phát hiện mình có khả năng thấu thị. Bị buộc phải đối mặt với những tiết lộ về quá khứ của mình, cô tạo mối quan hệ với ba phụ nữ trẻ bị định đoạt số phận.',
    category: 'Hành động, Viễn tưởng',
    posterUrl: '',
    videoUrl: '',
    releaseYear: 2024,
    durationMinutes: 116,
    ageRating: '16+',
    director: 'S.J. Clarkson',
    cast: 'Dakota Johnson, Sydney Sweeney, Celeste O\'Connor',
    isFeatured: true,
  );

  final sampleSimilar = [
    MovieModel(
      id: 'movie_002',
      title: 'Người Nhện: Không Còn Nhà',
      description: 'Peter Parker đối mặt với đa vũ trụ.',
      category: 'Hành động',
      posterUrl: '',
      videoUrl: '',
      releaseYear: 2021,
      isFeatured: false,
    ),
    MovieModel(
      id: 'movie_003',
      title: 'Venom: Kèo Cuối',
      description: 'Cuộc chiến cuối cùng của Eddie Brock.',
      category: 'Hành động',
      posterUrl: '',
      videoUrl: '',
      releaseYear: 2024,
      isFeatured: false,
    ),
    MovieModel(
      id: 'movie_004',
      title: 'Morbius',
      description: 'Tiến sĩ Michael Morbius.',
      category: 'Hành động',
      posterUrl: '',
      videoUrl: '',
      releaseYear: 2022,
      isFeatured: false,
    ),
  ];

  testWidgets('Capture Collapsed and Expanded states of MovieQuickDetailSheet', (tester) async {
    const MethodChannel pathChannel = MethodChannel('plugins.flutter.io/path_provider');
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(pathChannel, (MethodCall methodCall) async {
      return '.';
    });

    await tester.runAsync(() async {
      await loadFonts();
    });

    final boundaryKey = GlobalKey();

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
        builder: (context, child) => RepaintBoundary(
          key: boundaryKey,
          child: child ?? const SizedBox(),
        ),
        home: Scaffold(
          backgroundColor: AppColors.background,
          body: Builder(
            builder: (context) {
              return Center(
                child: ElevatedButton(
                  onPressed: () {
                    MovieQuickDetailSheet.show(
                      context: context,
                      movie: sampleMovie,
                      similarMovies: sampleSimilar,
                      onPlay: (_) {},
                      onWatchTrailer: (_) {},
                      onOpenFullDetail: (_) {},
                    );
                  },
                  child: const Text('Mở Modal'),
                ),
              );
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Mở Modal (Collapsed State ~50%)
    await tester.tap(find.text('Mở Modal'));
    await tester.pumpAndSettle();

    await tester.runAsync(() async {
      final boundary = boundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 2.75);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final dir = Directory('docs/qa/screenshots');
      if (!dir.existsSync()) dir.createSync(recursive: true);
      final file = File('docs/qa/screenshots/quick_sheet_collapsed.png');
      file.writeAsBytesSync(byteData!.buffer.asUint8List());
      print('Saved ${file.path}');
    });

    // 2. Kéo vuốt lên để mở Expanded State ~94%
    await tester.drag(find.text('Madame Web'), const Offset(0, -600));
    await tester.pumpAndSettle();

    await tester.runAsync(() async {
      final boundary = boundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 2.75);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final file = File('docs/qa/screenshots/quick_sheet_expanded.png');
      file.writeAsBytesSync(byteData!.buffer.asUint8List());
      print('Saved ${file.path}');
    });

    // Giải phóng bộ hẹn giờ dọn dẹp cache
    await tester.pump(const Duration(seconds: 15));
  });
}
