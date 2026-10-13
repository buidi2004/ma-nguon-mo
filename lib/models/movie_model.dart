import 'package:pocketbase/pocketbase.dart';

class MovieModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String posterUrl;
  final String videoUrl;
  final int releaseYear;
  final bool isFeatured;

  MovieModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.posterUrl,
    required this.videoUrl,
    required this.releaseYear,
    required this.isFeatured,
  });

  /// Khởi tạo MovieModel từ RecordModel của thư viện PocketBase
  factory MovieModel.fromRecord(RecordModel record) {
    return MovieModel(
      id: record.id,
      title: record.getStringValue('title', ''),
      description: record.getStringValue('description', ''),
      category: record.getStringValue('category', 'Khác'),
      posterUrl: record.getStringValue('poster_url', ''),
      videoUrl: record.getStringValue('video_url', ''),
      releaseYear: record.getIntValue('release_year', 2024),
      isFeatured: record.getBoolValue('is_featured', false),
    );
  }

  /// Khởi tạo MovieModel từ Map JSON chuẩn
  factory MovieModel.fromJson(Map<String, dynamic> json) {
    return MovieModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Chưa có tên',
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? 'Khác',
      posterUrl: json['poster_url']?.toString() ?? '',
      videoUrl: json['video_url']?.toString() ?? '',
      releaseYear: (json['release_year'] as num?)?.toInt() ?? 2024,
      isFeatured: json['is_featured'] == true,
    );
  }

  /// Xuất dữ liệu sang Map JSON để lưu hoặc gửi API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'poster_url': posterUrl,
      'video_url': videoUrl,
      'release_year': releaseYear,
      'is_featured': isFeatured,
    };
  }
}
