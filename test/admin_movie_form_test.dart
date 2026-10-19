import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openflix/features/admin/admin_movie_form_screen.dart';
import 'package:openflix/models/movie_model.dart';
import 'package:openflix/theme/app_theme.dart';

Widget buildTestableWidget(Widget child, {Size size = const Size(393, 852)}) {
  return MediaQuery(
    data: MediaQueryData(size: size),
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: child,
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    HttpOverrides.global = null;
  });

  group('AdminMovieFormScreen Widget Tests', () {
    testWidgets('Hiển thị đúng ở chế độ Thêm phim mới', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(const AdminMovieFormScreen()),
      );
      await tester.pump();

      expect(find.text('Thêm phim mới'), findsOneWidget);
      expect(find.text('Tạo phim mới'), findsOneWidget);
      expect(find.text('1. Thông tin cơ bản'), findsOneWidget);
      expect(find.text('2. Thông số phát hành & Sản xuất'), findsOneWidget);
      expect(find.text('3. Đường dẫn Media & Poster'), findsOneWidget);
      expect(find.text('4. Cài đặt Trạng thái & Vị trí'), findsOneWidget);
      expect(find.text('Xem trước'), findsOneWidget);
    });

    testWidgets('Validate báo lỗi khi để trống trường bắt buộc', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(const AdminMovieFormScreen()),
      );
      await tester.pump();

      // Bấm nút Lưu khi chưa nhập gì
      await tester.tap(find.text('Tạo phim mới'));
      await tester.pump();

      expect(find.text('Tên phim không được để trống'), findsOneWidget);
    });

    testWidgets('Hiển thị đúng ở chế độ Chỉnh sửa phim có sẵn', (tester) async {
      final sampleMovie = MovieModel(
        id: 'test_123',
        title: 'Phim Thử Nghiệm Sửa',
        description: 'Mô tả thử nghiệm',
        category: 'Hành động',
        posterUrl: '',
        videoUrl: 'https://example.com/video.mp4',
        releaseYear: 2024,
        isFeatured: true,
      );

      await tester.pumpWidget(
        buildTestableWidget(AdminMovieFormScreen(movie: sampleMovie)),
      );
      await tester.pump();

      expect(find.text('Chỉnh sửa phim'), findsOneWidget);
      expect(find.text('Lưu thay đổi'), findsOneWidget);
      expect(find.text('Phim Thử Nghiệm Sửa'), findsOneWidget);
    });
  });
}
