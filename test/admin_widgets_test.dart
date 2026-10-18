import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openflix/features/admin/widgets/admin_movie_tile.dart';
import 'package:openflix/features/admin/widgets/confirm_delete_dialog.dart';
import 'package:openflix/models/movie_model.dart';
import 'package:openflix/theme/app_theme.dart';

void main() {
  group('ConfirmDeleteDialog Tests', () {
    testWidgets(
      'Hiển thị đầy đủ thông tin, icon cảnh báo, tên phim và nút bấm',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: buildAppTheme(),
            home: Builder(
              builder: (context) {
                return Scaffold(
                  body: Center(
                    child: ElevatedButton(
                      onPressed: () {
                        ConfirmDeleteDialog.show(
                          context,
                          movieTitle: 'Avengers: Endgame',
                        );
                      },
                      child: const Text('Open Dialog'),
                    ),
                  ),
                );
              },
            ),
          ),
        );

        // Mở dialog
        await tester.tap(find.text('Open Dialog'));
        await tester.pumpAndSettle();

        // Kiểm tra tiêu đề và icon
        expect(find.text('Xác nhận xóa phim?'), findsOneWidget);
        expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);

        // Kiểm tra nội dung chứa tên phim và cảnh báo
        expect(find.textContaining('"Avengers: Endgame"'), findsOneWidget);
        expect(find.textContaining('không thể hoàn tác'), findsOneWidget);

        // Kiểm tra các nút bấm
        expect(find.text('Hủy'), findsOneWidget);
        expect(find.text('Xác nhận xóa'), findsOneWidget);
      },
    );

    testWidgets('Nút Hủy đóng dialog và trả về false', (tester) async {
      bool? result;

      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      result = await ConfirmDeleteDialog.show(
                        context,
                        movieTitle: 'Spider-Man',
                      );
                    },
                    child: const Text('Open Dialog'),
                  ),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Hủy'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
      expect(result, isFalse);
    });

    testWidgets('Nút Xác nhận xóa đóng dialog và trả về true', (tester) async {
      bool? result;
      bool onConfirmCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      result = await ConfirmDeleteDialog.show(
                        context,
                        movieTitle: 'Spider-Man',
                        onConfirm: () async {
                          onConfirmCalled = true;
                        },
                      );
                    },
                    child: const Text('Open Dialog'),
                  ),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Xác nhận xóa'));
      await tester.pumpAndSettle();

      expect(onConfirmCalled, isTrue);
      expect(result, isTrue);
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('Hiển thị CircularProgressIndicator khi isLoading == true', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: const Scaffold(
            body: ConfirmDeleteDialog(movieTitle: 'Inception', isLoading: true),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Xác nhận xóa'), findsNothing);
    });
  });

  group('AdminMovieTile Tests', () {
    final sampleMovie = MovieModel(
      id: 'movie-101',
      title: 'Inception - Kẻ Đánh Cắp Giấc Mơ',
      description: 'Phim trinh thám khoa học viễn tưởng.',
      category: 'Khoa học viễn tưởng',
      posterUrl: '', // url rỗng để kiểm tra fallback
      videoUrl: 'https://example.com/video.mp4',
      releaseYear: 2010,
      durationMinutes: 148,
      isFeatured: true,
      isNew: false,
      comingSoon: true,
    );

    testWidgets(
      'Hiển thị poster fallback khi url rỗng, tiêu đề và thông tin phụ',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: buildAppTheme(),
            home: Scaffold(body: AdminMovieTile(movie: sampleMovie)),
          ),
        );

        // Tiêu đề
        expect(find.text('Inception - Kẻ Đánh Cắp Giấc Mơ'), findsOneWidget);

        // Thông tin phụ (Năm • Thời lượng • Thể loại)
        expect(
          find.text('2010 • 148 phút • Khoa học viễn tưởng'),
          findsOneWidget,
        );

        // Fallback poster khi posterUrl rỗng
        expect(find.text('Không có ảnh'), findsOneWidget);
        expect(find.byIcon(Icons.movie_outlined), findsOneWidget);
      },
    );

    testWidgets('Hiển thị đủ 3 chip trạng thái: Nổi bật, Mới, Sắp chiếu', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: Scaffold(body: AdminMovieTile(movie: sampleMovie)),
        ),
      );

      expect(find.text('⭐ Nổi bật'), findsOneWidget);
      expect(find.text('🔥 Mới'), findsOneWidget);
      expect(find.text('⏳ Sắp chiếu'), findsOneWidget);
    });

    testWidgets('Nút Sửa và Nút Xóa gọi callback tương ứng', (tester) async {
      bool editClicked = false;
      bool deleteClicked = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: Scaffold(
            body: AdminMovieTile(
              movie: sampleMovie,
              onEdit: () => editClicked = true,
              onDelete: () => deleteClicked = true,
            ),
          ),
        ),
      );

      // Nút Sửa
      await tester.tap(find.byIcon(Icons.edit_outlined));
      expect(editClicked, isTrue);

      // Nút Xóa
      await tester.tap(find.byIcon(Icons.delete_outline_rounded));
      expect(deleteClicked, isTrue);
    });

    testWidgets('Hàng Quick Switch Toggles hoạt động chính xác khi gạt', (
      tester,
    ) async {
      bool? newFeatured;
      bool? newIsNew;
      bool? newComingSoon;

      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: Scaffold(
            body: SingleChildScrollView(
              child: AdminMovieTile(
                movie: sampleMovie,
                onToggleFeatured: (val) => newFeatured = val,
                onToggleNew: (val) => newIsNew = val,
                onToggleComingSoon: (val) => newComingSoon = val,
              ),
            ),
          ),
        ),
      );

      // Tìm các Switch
      final switches = find.byType(Switch);
      expect(switches, findsNWidgets(3));

      // Gạt switch Featured (đang true -> false)
      await tester.tap(switches.at(0));
      expect(newFeatured, isFalse);

      // Gạt switch New (đang false -> true)
      await tester.tap(switches.at(1));
      expect(newIsNew, isTrue);

      // Gạt switch ComingSoon (đang true -> false)
      await tester.tap(switches.at(2));
      expect(newComingSoon, isFalse);
    });
  });
}
