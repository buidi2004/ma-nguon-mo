import 'package:pocketbase/pocketbase.dart';

class MovieModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String posterUrl;
  final String videoUrl;
  final String trailerUrl;
  final int releaseYear;
  final int durationMinutes;
  final String ageRating;
  final String director;
  final String cast;
  final int? rank;
  final bool isFeatured;
  final bool isNew;
  final bool comingSoon;

  MovieModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.posterUrl,
    required this.videoUrl,
    this.trailerUrl = '',
    required this.releaseYear,
    this.durationMinutes = 90,
    this.ageRating = '13+',
    this.director = 'Đang cập nhật',
    this.cast = 'Đang cập nhật',
    this.rank,
    required this.isFeatured,
    this.isNew = false,
    this.comingSoon = false,
  });

  String get thumbnailUrl => posterUrl;

  /// Khởi tạo MovieModel an toàn từ RecordModel của PocketBase
  factory MovieModel.fromRecord(RecordModel record) {
    return MovieModel(
      id: record.id,
      title: record.getStringValue('title', 'Chưa có tiêu đề'),
      description: record.getStringValue('description', ''),
      category: record.getStringValue('category', 'Khác'),
      posterUrl: record.getStringValue('poster_url', ''),
      videoUrl: record.getStringValue('video_url', ''),
      trailerUrl: record.getStringValue('trailer_url', ''),
      releaseYear: record.getIntValue('release_year', 2024),
      durationMinutes: record.getIntValue('duration_minutes', 90),
      ageRating: record.getStringValue('age_rating', '13+'),
      director: record.getStringValue('director', 'Blender Foundation'),
      cast: record.getStringValue('cast', 'Diễn viên OpenFlix'),
      rank: record.getIntValue('rank', 0) > 0
          ? record.getIntValue('rank', 0)
          : null,
      isFeatured: record.getBoolValue('is_featured', false),
      isNew: record.getBoolValue('is_new', false),
      comingSoon: record.getBoolValue('coming_soon', false),
    );
  }

  /// Khởi tạo MovieModel từ Map JSON
  factory MovieModel.fromJson(Map<String, dynamic> json) {
    return MovieModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Chưa có tên',
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? 'Khác',
      posterUrl: json['poster_url']?.toString() ?? '',
      videoUrl: json['video_url']?.toString() ?? '',
      trailerUrl: json['trailer_url']?.toString() ?? '',
      releaseYear: (json['release_year'] as num?)?.toInt() ?? 2024,
      durationMinutes: (json['duration_minutes'] as num?)?.toInt() ?? 90,
      ageRating: json['age_rating']?.toString() ?? '13+',
      director: json['director']?.toString() ?? 'Blender Foundation',
      cast: json['cast']?.toString() ?? 'Diễn viên OpenFlix',
      rank: (json['rank'] as num?)?.toInt(),
      isFeatured: json['is_featured'] == true,
      isNew: json['is_new'] == true,
      comingSoon: json['coming_soon'] == true,
    );
  }

  /// Xuất dữ liệu sang Map JSON để lưu trữ hoặc gửi API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'poster_url': posterUrl,
      'video_url': videoUrl,
      'trailer_url': trailerUrl,
      'release_year': releaseYear,
      'duration_minutes': durationMinutes,
      'age_rating': ageRating,
      'director': director,
      'cast': cast,
      'rank': rank,
      'is_featured': isFeatured,
      'is_new': isNew,
      'coming_soon': comingSoon,
    };
  }
}

typedef Movie = MovieModel;
