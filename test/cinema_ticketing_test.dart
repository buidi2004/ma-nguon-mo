import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openflix/models/cinema/cinema_models.dart';
import 'package:openflix/features/cinema/cinema_article_detail_screen.dart';
import 'package:openflix/features/cinema/cinema_checkout_screen.dart';
import 'package:openflix/features/cinema/cinema_concessions_screen.dart';
import 'package:openflix/features/cinema/cinema_hub_screen.dart';
import 'package:openflix/features/cinema/cinema_movie_detail_screen.dart';
import 'package:openflix/features/cinema/cinema_news_screen.dart';
import 'package:openflix/features/cinema/cinema_seat_selection_screen.dart';
import 'package:openflix/features/cinema/cinema_ticket_screen.dart';
import 'package:openflix/features/cinema/my_cinema_tickets_screen.dart';
import 'package:openflix/services/cinema/cinema_service.dart';

Widget _buildTestApp(Widget child) {
  return MediaQuery(
    data: const MediaQueryData(size: Size(393, 852)),
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      home: child,
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CinemaService Data & Business Logic Tests', () {
    final service = CinemaService.instance;

    test('CinemaService contains Vietnamese cinema movies and chains', () {
      expect(service.movies.isNotEmpty, isTrue);
      expect(service.theaters.isNotEmpty, isTrue);
      expect(service.cities.isNotEmpty, isTrue);
      expect(service.concessions.isNotEmpty, isTrue);
      expect(service.articles.isNotEmpty, isTrue);

      final anMangMovie =
          service.movies.firstWhere((m) => m.id == 'cm_an_mang');
      expect(anMangMovie.title, 'Án Mạng Xém Hoàn Hảo');
      expect(anMangMovie.ageRating, 'T18');
      expect(anMangMovie.durationMinutes, 124);
      expect(anMangMovie.rating, 8.3);
    });

    test('CinemaService city selection changes selectedCityName', () {
      service.selectCity('hcm');
      expect(service.selectedCityId, 'hcm');
      expect(service.selectedCityName, 'TP Hồ Chí Minh');

      service.selectCity('all');
      expect(service.selectedCityName, 'Toàn quốc');
    });

    test('CinemaService showtimes generation returns showtimes with hall names',
        () {
      final showtimes = service.getShowtimes(
        movieId: 'cm_an_mang',
        theaterId: 'cnf_thiso_sala',
        date: DateTime.now(),
      );

      expect(showtimes.isNotEmpty, isTrue);
      expect(showtimes.any((st) => st.time == '14:45'), isTrue);
    });

    test('CinemaService seat generation returns Standard, VIP, and Sweetbox',
        () {
      final seats = service.generateSeatsForShowtime('st_test_1');
      expect(seats.length, greaterThan(100));

      expect(seats.any((s) => s.type == SeatType.standard), isTrue);
      expect(seats.any((s) => s.type == SeatType.vip), isTrue);
      expect(seats.any((s) => s.type == SeatType.sweetbox), isTrue);
    });
  });

  group('Cinema Screens Widget Tests (S43 - S51)', () {
    testWidgets('S43: CinemaHubScreen renders tabs and brand title',
        (tester) async {
      await tester.pumpWidget(_buildTestApp(const CinemaHubScreen()));
      await tester.pump();
      tester.takeException();

      expect(find.text('Mua Vé'), findsOneWidget);
      expect(find.text('Đang chiếu'), findsOneWidget);
      expect(find.text('Sắp chiếu'), findsOneWidget);
      expect(find.text('Phim IMAX'), findsOneWidget);
    });

    testWidgets('S44: CinemaMovieDetailScreen renders movie details and showtimes',
        (tester) async {
      await tester.pumpWidget(
        _buildTestApp(const CinemaMovieDetailScreen(movieId: 'cm_an_mang')),
      );
      await tester.pump();
      tester.takeException();

      expect(find.text('Án Mạng Xém Hoàn Hảo'), findsOneWidget);
      expect(find.text('Lịch Chiếu'), findsOneWidget);
      expect(find.text('Hôm Nay'), findsOneWidget);
    });

    testWidgets('S45: CinemaSeatSelectionScreen renders screen arc and legend',
        (tester) async {
      final service = CinemaService.instance;
      final movie = service.movies.first;
      final theater = service.theaters.first;
      final showtime = service.getShowtimes(
        movieId: movie.id,
        theaterId: theater.id,
        date: DateTime.now(),
      ).first;

      await tester.pumpWidget(
        _buildTestApp(
          CinemaSeatSelectionScreen(
            movie: movie,
            theater: theater,
            showtime: showtime,
          ),
        ),
      );
      await tester.pump();
      tester.takeException();

      expect(find.text('MÀN HÌNH / SCREEN'), findsOneWidget);
      expect(find.text('Thường'), findsOneWidget);
      expect(find.text('VIP'), findsOneWidget);
      expect(find.text('Tiếp tục >'), findsOneWidget);
    });

    testWidgets('S46: CinemaConcessionsScreen renders combo categories',
        (tester) async {
      final service = CinemaService.instance;
      final movie = service.movies.first;
      final theater = service.theaters.first;
      final showtime = service.getShowtimes(
        movieId: movie.id,
        theaterId: theater.id,
        date: DateTime.now(),
      ).first;

      await tester.pumpWidget(
        _buildTestApp(
          CinemaConcessionsScreen(
            movie: movie,
            theater: theater,
            showtime: showtime,
            seatLabels: const ['G08', 'G09'],
            seatsPrice: 230000,
          ),
        ),
      );
      await tester.pump();
      tester.takeException();

      expect(find.text('Chọn Bắp Nước & Combo'), findsOneWidget);
      expect(find.text('Combo Ưu Đãi'), findsOneWidget);
      expect(find.text('Thanh toán >'), findsOneWidget);
    });

    testWidgets('S47: CinemaCheckoutScreen renders timer and payment options',
        (tester) async {
      final service = CinemaService.instance;
      final movie = service.movies.first;
      final theater = service.theaters.first;
      final showtime = service.getShowtimes(
        movieId: movie.id,
        theaterId: theater.id,
        date: DateTime.now(),
      ).first;

      await tester.pumpWidget(
        _buildTestApp(
          CinemaCheckoutScreen(
            movie: movie,
            theater: theater,
            showtime: showtime,
            seatLabels: const ['G08', 'G09'],
            concessions: const {'combo_couple': 1},
            totalAmount: 349000,
          ),
        ),
      );
      await tester.pump();
      tester.takeException();

      expect(find.text('Thanh Toán Đặt Vé'), findsOneWidget);
      expect(find.text('Ví MoMo'), findsOneWidget);
      expect(find.text('Cổng VNPAY-QR'), findsOneWidget);
    });

    testWidgets('S48: CinemaTicketScreen renders booking code and e-ticket',
        (tester) async {
      await tester.pumpWidget(
        _buildTestApp(const CinemaTicketScreen(bookingId: 'bk_001')),
      );
      await tester.pump();
      tester.takeException();

      expect(find.text('Vé Điện Tử Vào Rạp'), findsOneWidget);
      expect(find.textContaining('MÃ ĐẶT CHỖ'), findsOneWidget);
      expect(find.text('Lưu ảnh vé'), findsOneWidget);
    });

    testWidgets('S49: MyCinemaTicketsScreen renders tabs', (tester) async {
      await tester.pumpWidget(_buildTestApp(const MyCinemaTicketsScreen()));
      await tester.pump();
      tester.takeException();

      expect(find.text('Vé Rạp Của Tôi'), findsOneWidget);
      expect(find.text('Vé sắp xem'), findsOneWidget);
      expect(find.text('Lịch sử vé đã xem'), findsOneWidget);
    });

    testWidgets('S50: CinemaNewsScreen renders review tabs', (tester) async {
      await tester.pumpWidget(_buildTestApp(const CinemaNewsScreen()));
      await tester.pump();
      tester.takeException();

      expect(find.text('Bình luận phim'), findsOneWidget);
      expect(find.text('Blog điện ảnh'), findsOneWidget);
    });

    testWidgets('S51: CinemaArticleDetailScreen renders article and CTA button',
        (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const CinemaArticleDetailScreen(articleId: 'art_trai_buon_nguoi'),
        ),
      );
      await tester.pump();
      tester.takeException();

      expect(find.text('ĐẶT VÉ PHIM NÀY NGAY'), findsOneWidget);
      expect(find.textContaining('Trại Buôn Người'), findsWidgets);
    });
  });
}
