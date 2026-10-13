import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:pocketbase/pocketbase.dart';
import '../models/movie_model.dart';

class PocketBaseService {
  static final PocketBaseService instance = PocketBaseService._internal();

  PocketBaseService._internal() {
    _initPb(_currentBaseUrl);
  }

  // URL mặc định - có thể đổi qua giao diện app hoặc tại đây
  // PocketHost ví dụ: https://openflix-demo.pockethost.io
  // Local Android Emulator: http://10.0.2.2:8090
  // Local Windows/Web: http://127.0.0.1:8090
  String _currentBaseUrl = 'http://10.0.2.2:8090';
  late PocketBase _pb;
  bool _isUsingOfflineMock = false;

  String get baseUrl => _currentBaseUrl;
  bool get isUsingOfflineMock => _isUsingOfflineMock;

  void _initPb(String url) {
    _currentBaseUrl = url.replaceAll(RegExp(r'/+$'), '');
    _pb = PocketBase(_currentBaseUrl);
  }

  void updateBaseUrl(String newUrl) {
    _initPb(newUrl);
  }

  /// Lấy toàn bộ danh sách phim từ PocketBase
  Future<List<MovieModel>> getMovies() async {
    try {
      final records = await _pb.collection('movies').getFullList(
            sort: '-created',
          );

      _isUsingOfflineMock = false;
      return records.map((record) => MovieModel.fromRecord(record)).toList();
    } catch (e) {
      debugPrint('⚠️ Không thể kết nối tới PocketBase ($e). Đang chuyển sang dữ liệu mẫu offline.');
      _isUsingOfflineMock = true;
      return _mockMovies;
    }
  }

  /// Lấy danh sách phim nổi bật (Banner)
  Future<List<MovieModel>> getFeaturedMovies() async {
    final allMovies = await getMovies();
    final featured = allMovies.where((m) => m.isFeatured).toList();
    if (featured.isEmpty && allMovies.isNotEmpty) {
      return [allMovies.first];
    }
    return featured;
  }

  /// Lấy danh sách phim theo danh mục
  Future<List<MovieModel>> getMoviesByCategory(String category) async {
    final allMovies = await getMovies();
    return allMovies.where((m) => m.category.toLowerCase() == category.toLowerCase()).toList();
  }

  /// Tìm kiếm phim theo tiêu đề hoặc mô tả
  Future<List<MovieModel>> searchMovies(String query) async {
    final allMovies = await getMovies();
    if (query.trim().isEmpty) return allMovies;
    final lower = query.toLowerCase().trim();
    return allMovies.where((m) {
      return m.title.toLowerCase().contains(lower) ||
          m.description.toLowerCase().contains(lower) ||
          m.category.toLowerCase().contains(lower);
    }).toList();
  }

  /// Nạp tự động dữ liệu mẫu vào PocketBase từ ứng dụng
  Future<int> seedRemotePocketBase(String targetUrl) async {
    int count = 0;
    final cleanUrl = targetUrl.replaceAll(RegExp(r'/+$'), '');
    final uri = Uri.parse('$cleanUrl/api/collections/movies/records');

    for (final movie in _mockMovies) {
      try {
        final res = await http.post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(movie.toJson()),
        );
        if (res.statusCode >= 200 && res.statusCode < 300) {
          count++;
        }
      } catch (e) {
        debugPrint('Lỗi nạp phim ${movie.title}: $e');
      }
    }
    return count;
  }

  /// Dữ liệu phim mẫu offline dự phòng
  static final List<MovieModel> _mockMovies = [
    MovieModel(
      id: 'mock_1',
      title: 'Big Buck Bunny',
      description:
          'Một chú thỏ khổng lồ tốt bụng quyết định trả đũa ba chú sóc bay hay bắt nạt các sinh vật nhỏ bé trong khu rừng tươi đẹp. Một tác phẩm phim 3D mã nguồn mở kinh điển của Blender Foundation.',
      category: 'Hoạt hình',
      posterUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c5/Big_buck_bunny_poster_big.jpg/600px-Big_buck_bunny_poster_big.jpg',
      videoUrl:
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
      releaseYear: 2008,
      isFeatured: true,
    ),
    MovieModel(
      id: 'mock_2',
      title: 'Sintel - Trái Tim Rồng',
      description:
          'Cuộc hành trình đơn độc và đầy trắc trở của cô gái trẻ Sintel vượt qua sa mạc băng giá để tìm lại chú rồng con Scales bị bắt cóc.',
      category: 'Hoạt hình',
      posterUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/8/8f/Sintel_poster.jpg/600px-Sintel_poster.jpg',
      videoUrl:
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4',
      releaseYear: 2010,
      isFeatured: true,
    ),
    MovieModel(
      id: 'mock_3',
      title: 'Tears of Steel',
      description:
          'Lấy bối cảnh tương lai hậu tận thế tại Amsterdam, một nhóm chiến binh và nhà khoa học cố gắng cứu vãn tương lai loài người khỏi sự thống trị của người máy tàn bạo.',
      category: 'Viễn tưởng',
      posterUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e0/Tears_of_Steel_poster.jpg/600px-Tears_of_Steel_poster.jpg',
      videoUrl:
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4',
      releaseYear: 2012,
      isFeatured: true,
    ),
    MovieModel(
      id: 'mock_4',
      title: 'Elephants Dream',
      description:
          'Hai nhân vật Proog và Emo cùng lạc vào cỗ máy khổng lồ vô tận, đối mặt với những ảo cảnh siêu thực trong thế giới máy móc phức tạp.',
      category: 'Viễn tưởng',
      posterUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/0/0c/Elephants_Dream_poster.jpg/600px-Elephants_Dream_poster.jpg',
      videoUrl:
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
      releaseYear: 2006,
      isFeatured: false,
    ),
    MovieModel(
      id: 'mock_5',
      title: 'For Bigger Blazes',
      description:
          'Những pha hành động mạo hiểm nghẹt thở, những cú nhảy phi thân và tốc độ bùng nổ của các tay đua mạo hiểm đỉnh cao thế giới.',
      category: 'Hành động',
      posterUrl:
          'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=800&auto=format&fit=crop&q=80',
      videoUrl:
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
      releaseYear: 2023,
      isFeatured: false,
    ),
    MovieModel(
      id: 'mock_6',
      title: 'For Bigger Escape',
      description:
          'Cuộc tẩu thoát ngoạn mục khỏi thành phố ngầm với những màn rượt đuổi tốc độ cao cùng hiệu ứng kỹ xảo điện ảnh ấn tượng.',
      category: 'Hành động',
      posterUrl:
          'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=800&auto=format&fit=crop&q=80',
      videoUrl:
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
      releaseYear: 2024,
      isFeatured: false,
    ),
    MovieModel(
      id: 'mock_7',
      title: 'For Bigger Fun',
      description:
          'Tận hưởng những khoảnh khắc vui tươi, phấn khích với hành trình phiêu lưu dã ngoại khám phá những điều kỳ thú của thiên nhiên hoang dã.',
      category: 'Hài hước',
      posterUrl:
          'https://images.unsplash.com/photo-1536440136628-849c177e76a1?w=800&auto=format&fit=crop&q=80',
      videoUrl:
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
      releaseYear: 2023,
      isFeatured: false,
    ),
    MovieModel(
      id: 'mock_8',
      title: 'Bullrun Supercar Rally',
      description:
          'Giải đua xe siêu cấp xuyên lục địa quy tụ dàn siêu xe tốc độ cao mạnh mẽ nhất hành tinh và tinh thần thi đấu bất diệt.',
      category: 'Hành động',
      posterUrl:
          'https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=800&auto=format&fit=crop&q=80',
      videoUrl:
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WeAreGoingOnBullrun.mp4',
      releaseYear: 2022,
      isFeatured: false,
    ),
  ];
}
