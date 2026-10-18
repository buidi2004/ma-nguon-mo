import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openflix/features/admin/admin_movie_list_screen.dart';
import 'package:openflix/features/admin/widgets/admin_movie_tile.dart';
import 'package:openflix/features/admin/widgets/confirm_delete_dialog.dart';
import 'package:openflix/services/pocketbase_service.dart';
import 'package:openflix/theme/app_theme.dart';

Widget buildTestableScreen() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: buildAppTheme(),
    home: const AdminMovieListScreen(),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    HttpOverrides.global = null;
    // Nạp sẵn cache mock để các widget test chạy tức thì không bị timeout
    await PocketBaseService.instance.getMovies();
  });

  group('AdminMovieListScreen Widget Tests', () {
    testWidgets(
      'Hiển thị AppBar, nút + Thêm phim, ô tìm kiếm và filter chips',
      (tester) async {
        await tester.pumpWidget(buildTestableScreen());
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        // Kiểm tra tiêu đề AppBar
        expect(find.textContaining('Quản lý nội dung phim'), findsOneWidget);

        // Kiểm tra nút CTA + Thêm phim
        expect(find.text('+ Thêm phim'), findsOneWidget);

        // Kiểm tra ô tìm kiếm
        expect(find.byType(TextField), findsOneWidget);
        expect(find.text('Tìm theo tên phim, đạo diễn...'), findsOneWidget);

        // Kiểm tra các filter ChoiceChips cơ bản
        expect(find.widgetWithText(ChoiceChip, 'Tất cả'), findsOneWidget);
        expect(find.widgetWithText(ChoiceChip, '⭐ Nổi bật'), findsOneWidget);
        expect(find.widgetWithText(ChoiceChip, '🔥 Mới & Hot'), findsOneWidget);
        expect(find.widgetWithText(ChoiceChip, '⏳ Sắp chiếu'), findsOneWidget);
      },
    );

    testWidgets('Tìm kiếm phim tức thì và nút xóa từ khóa (x)', (tester) async {
      await tester.pumpWidget(buildTestableScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);

      // Nhập từ khóa tìm kiếm
      await tester.enterText(searchField, 'Sintel');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Nút xóa (clear icon) phải xuất hiện
      final clearButton = find.byIcon(Icons.clear);
      expect(clearButton, findsOneWidget);

      // Bấm nút xóa
      await tester.tap(clearButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Nút xóa biến mất sau khi clear
      expect(find.byIcon(Icons.clear), findsNothing);
    });

    testWidgets('Lọc theo Filter Chips: ⭐ Nổi bật', (tester) async {
      await tester.pumpWidget(buildTestableScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Nhấn vào chip ⭐ Nổi bật
      final featuredChip = find.widgetWithText(ChoiceChip, '⭐ Nổi bật');
      expect(featuredChip, findsOneWidget);

      await tester.tap(featuredChip);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Kiểm tra danh sách hiển thị các AdminMovieTile
      expect(find.byType(AdminMovieTile), findsWidgets);
    });

    testWidgets('Bấm nút Xóa mở ConfirmDeleteDialog', (tester) async {
      await tester.pumpWidget(buildTestableScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Tìm nút xóa đầu tiên
      final deleteButtons = find.byIcon(Icons.delete_outline_rounded);
      expect(deleteButtons, findsWidgets);

      await tester.tap(deleteButtons.first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Xác nhận dialog mở ra
      expect(find.byType(ConfirmDeleteDialog), findsOneWidget);
      expect(find.text('Xác nhận xóa phim?'), findsOneWidget);

      // Bấm nút Hủy
      await tester.tap(find.text('Hủy'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(ConfirmDeleteDialog), findsNothing);
    });

    testWidgets(
      'Gạt Switch trạng thái thực hiện Optimistic Update và hiện thông báo',
      (tester) async {
        await tester.pumpWidget(buildTestableScreen());
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        // Tìm các switch trong màn hình
        final switches = find.byType(Switch);
        expect(switches, findsWidgets);

        // Gạt switch đầu tiên
        await tester.tap(switches.first);
        await tester.pump();

        // Kiểm tra SnackBar xuất hiện
        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.textContaining('Đã cập nhật'), findsOneWidget);

        // Xả toàn bộ timer timeout còn lại của request
        await tester.pump(const Duration(seconds: 5));
      },
    );
  });
}
