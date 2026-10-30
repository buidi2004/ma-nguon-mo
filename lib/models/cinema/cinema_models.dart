import 'package:flutter/material.dart';

/// Trạng thái phát hành của phim rạp
enum CinemaMovieStatus {
  nowShowing, // Đang chiếu
  comingSoon, // Sắp chiếu
  imax, // Suất chiếu IMAX / Đặc biệt
}

/// Loại ghế trong rạp
enum SeatType {
  standard, // Ghế thường (90k)
  vip, // Ghế VIP trung tâm (110k)
  sweetbox, // Ghế đôi Sweetbox cuối phòng (220k/cặp)
}

/// Trạng thái của ghế
enum SeatStatus {
  available, // Còn trống
  selected, // Đang chọn
  reserved, // Đã bán / Khóa
}

/// Model Phim Chiếu Rạp
class CinemaMovieModel {
  final String id;
  final String title;
  final String posterUrl;
  final String trailerUrl;
  final String backdropUrl;
  final int durationMinutes;
  final String releaseDate;
  final String ageRating; // 'T18', 'T16', 'T13', 'P'
  final double rating;
  final int voteCount;
  final String country;
  final String productionStudio;
  final List<String> genres;
  final String director;
  final List<String> cast;
  final String synopsis;
  final CinemaMovieStatus status;
  final List<String> formats; // ['2D Phụ đề', '2D Lồng tiếng', 'VIP', 'IMAX']

  const CinemaMovieModel({
    required this.id,
    required this.title,
    required this.posterUrl,
    required this.trailerUrl,
    required this.backdropUrl,
    required this.durationMinutes,
    required this.releaseDate,
    required this.ageRating,
    required this.rating,
    required this.voteCount,
    required this.country,
    required this.productionStudio,
    required this.genres,
    required this.director,
    required this.cast,
    required this.synopsis,
    required this.status,
    this.formats = const ['2D Phụ đề', 'VIP'],
  });

  Color get ageRatingColor {
    switch (ageRating) {
      case 'T18':
        return const Color(0xFFF97316); // Cam nổi bật
      case 'T16':
        return const Color(0xFFEAB308); // Vàng
      case 'T13':
        return const Color(0xFF22C55E); // Xanh lục
      case 'P':
      default:
        return const Color(0xFF3B82F6); // Xanh dương
    }
  }
}

/// Model Tỉnh / Thành Phố
class CinemaCityModel {
  final String id;
  final String name;
  final String landmark;
  final IconData icon;

  const CinemaCityModel({
    required this.id,
    required this.name,
    required this.landmark,
    required this.icon,
  });
}

/// Model Cụm Rạp Chiếu Phim
class CinemaTheaterModel {
  final String id;
  final String name;
  final String chain; // 'CineFlix', 'CGV', 'BHD', 'Lotte'
  final String cityId;
  final String address;
  final double distanceKm;

  const CinemaTheaterModel({
    required this.id,
    required this.name,
    required this.chain,
    required this.cityId,
    required this.address,
    this.distanceKm = 1.2,
  });
}

/// Model Suất Chiếu
class CinemaShowtimeModel {
  final String id;
  final String movieId;
  final String theaterId;
  final String hallName; // 'VIP - AQUALIS', 'VIP - LAURUS', 'HALL 01'
  final String format; // '2D Phụ Đề', '2D Lồng Tiếng', 'IMAX 2D'
  final String time; // '14:45', '16:15', '19:30'
  final DateTime date;
  final int basePrice;

  const CinemaShowtimeModel({
    required this.id,
    required this.movieId,
    required this.theaterId,
    required this.hallName,
    required this.format,
    required this.time,
    required this.date,
    this.basePrice = 90000,
  });
}

/// Model Ghế Ngồi
class CinemaSeatModel {
  final String id;
  final String row;
  final int number;
  final SeatType type;
  SeatStatus status;
  final int price;

  CinemaSeatModel({
    required this.id,
    required this.row,
    required this.number,
    required this.type,
    this.status = SeatStatus.available,
    required this.price,
  });

  String get label => '$row$number';
}

/// Model Combo Bắp Nước & Merchandise
class CinemaConcessionModel {
  final String id;
  final String name;
  final String description;
  final int price;
  final String imageUrl;
  final String category; // 'combo', 'popcorn', 'drink', 'merch'

  const CinemaConcessionModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
  });
}

/// Model Đơn Đặt Vé & Vé Điện Tử
class CinemaBookingModel {
  final String id;
  final String bookingCode;
  final String movieId;
  final String movieTitle;
  final String posterUrl;
  final String theaterName;
  final String theaterAddress;
  final String hallName;
  final String format;
  final String showtime;
  final DateTime date;
  final List<String> seatLabels;
  final Map<String, int> concessions; // Concession ID -> Quantity
  final int totalAmount;
  final String paymentMethod;
  final String qrCodeData;
  final DateTime createdAt;
  final bool isUsed;

  const CinemaBookingModel({
    required this.id,
    required this.bookingCode,
    required this.movieId,
    required this.movieTitle,
    required this.posterUrl,
    required this.theaterName,
    required this.theaterAddress,
    required this.hallName,
    required this.format,
    required this.showtime,
    required this.date,
    required this.seatLabels,
    required this.concessions,
    required this.totalAmount,
    required this.paymentMethod,
    required this.qrCodeData,
    required this.createdAt,
    this.isUsed = false,
  });
}

/// Model Bài Viết Tin Tức / Review Điện Ảnh
class CinemaArticleModel {
  final String id;
  final String title;
  final String excerpt;
  final String content;
  final String imageUrl;
  final String author;
  final String category; // 'review', 'blog'
  final DateTime publishedAt;
  final int likesCount;
  final int viewsCount;
  final String? relatedMovieId;

  const CinemaArticleModel({
    required this.id,
    required this.title,
    required this.excerpt,
    required this.content,
    required this.imageUrl,
    required this.author,
    required this.category,
    required this.publishedAt,
    required this.likesCount,
    required this.viewsCount,
    this.relatedMovieId,
  });
}
