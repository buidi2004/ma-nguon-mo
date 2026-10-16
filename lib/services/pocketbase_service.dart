import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:pocketbase/pocketbase.dart';

import '../models/movie_model.dart';

class MoviePageResult {
  final int page;
  final int perPage;
  final int totalItems;
  final int totalPages;
  final List<MovieModel> items;

  const MoviePageResult({
    required this.page,
    required this.perPage,
    required this.totalItems,
    required this.totalPages,
    required this.items,
  });

  bool get hasMore => page < totalPages;
  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;
}

class PocketBaseService {
  static final PocketBaseService instance = PocketBaseService._internal();

  PocketBaseService._internal() {
    _initPb(_currentBaseUrl);
  }

  // VPS Linux Production: http://180.93.120.246:8090
  // PocketHost ví dụ: https://openflix-demo.pockethost.io
  // Local Android Emulator: http://10.0.2.2:8090
  // Local Windows/Web: http://127.0.0.1:8090
  String _currentBaseUrl = 'http://180.93.120.246:8090';
  late PocketBase _pb;
  bool _isUsingOfflineMock = false;
  List<MovieModel>? _cachedMovies;
  Future<List<MovieModel>>? _inFlightMoviesRequest;
  final Map<String, MoviePageResult> _pagedCache = {};
  final Map<String, Future<MoviePageResult>> _inFlightPagedRequests = {};

  String get baseUrl => _currentBaseUrl;
  bool get isUsingOfflineMock => _isUsingOfflineMock;
  bool get hasCachedMovies => _cachedMovies != null && _cachedMovies!.isNotEmpty;

  void _initPb(String url) {
    _currentBaseUrl = url.replaceAll(RegExp(r'/+$'), '');
    _pb = PocketBase(_currentBaseUrl);
    _cachedMovies = null;
    _inFlightMoviesRequest = null;
    _pagedCache.clear();
    _inFlightPagedRequests.clear();
  }

  void updateBaseUrl(String newUrl) {
    _initPb(newUrl);
  }

  /// Xóa bộ nhớ đệm để ép nạp lại dữ liệu
  void clearCache() {
    _cachedMovies = null;
    _inFlightMoviesRequest = null;
    _pagedCache.clear();
    _inFlightPagedRequests.clear();
  }

  /// Lấy toàn bộ danh sách phim từ PocketBase (có bộ nhớ đệm trong RAM & chống trùng request)
  Future<List<MovieModel>> getMovies({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedMovies != null && _cachedMovies!.isNotEmpty) {
      return _cachedMovies!;
    }

    // Nếu đã có 1 request đang gửi đi, các màn hình khác sẽ dùng chung Future đó
    if (!forceRefresh && _inFlightMoviesRequest != null) {
      return _inFlightMoviesRequest!;
    }

    final future = _fetchMoviesInternal();
    if (!forceRefresh) {
      _inFlightMoviesRequest = future;
    }
    return future;
  }

  Future<List<MovieModel>> _fetchMoviesInternal() async {
    try {
      // Dùng batch 50 an toàn với giới hạn PocketBase server (triệt tiêu lỗi 400 Bad Request)
      final records = await _pb
          .collection('movies')
          .getFullList(batch: 50, sort: '-created')
          .timeout(const Duration(milliseconds: 3500));

      _isUsingOfflineMock = false;
      final result = records
          .map((record) => MovieModel.fromRecord(record))
          .toList();
      _cachedMovies = result;
      return result;
    } catch (e) {
      debugPrint(
        '⚠️ Không thể kết nối tới PocketBase ($e). Đang chuyển sang dữ liệu mẫu offline.',
      );
      _isUsingOfflineMock = true;
      _cachedMovies = _mockMovies;
      return _mockMovies;
    } finally {
      _inFlightMoviesRequest = null;
    }
  }

  /// Nạp danh sách phim phân trang thông minh (Smart Pagination)
  Future<MoviePageResult> getMoviesPaged({
    int page = 1,
    int perPage = 20,
    String? category,
    String? filter,
    String? sort = '-created',
    bool forceRefresh = false,
  }) async {
    final cacheKey = '${page}_${perPage}_${category ?? ''}_${filter ?? ''}_${sort ?? ''}';

    if (!forceRefresh && _pagedCache.containsKey(cacheKey)) {
      return _pagedCache[cacheKey]!;
    }

    if (!forceRefresh && _inFlightPagedRequests.containsKey(cacheKey)) {
      return _inFlightPagedRequests[cacheKey]!;
    }

    final future = _fetchMoviesPagedInternal(
      page: page,
      perPage: perPage,
      category: category,
      filter: filter,
      sort: sort,
      cacheKey: cacheKey,
    );

    if (!forceRefresh) {
      _inFlightPagedRequests[cacheKey] = future;
    }

    return future;
  }

  Future<MoviePageResult> _fetchMoviesPagedInternal({
    required int page,
    required int perPage,
    String? category,
    String? filter,
    String? sort,
    required String cacheKey,
  }) async {
    try {
      String? combinedFilter = filter;
      if (category != null && category.isNotEmpty && category != 'Tất cả') {
        final catFilter = 'category = "$category"';
        combinedFilter = combinedFilter == null || combinedFilter.isEmpty
            ? catFilter
            : '($combinedFilter) && ($catFilter)';
      }

      final result = await _pb
          .collection('movies')
          .getList(
            page: page,
            perPage: perPage,
            sort: sort ?? '-created',
            filter: combinedFilter,
          )
          .timeout(const Duration(milliseconds: 3500));

      _isUsingOfflineMock = false;
      final items = result.items.map((r) => MovieModel.fromRecord(r)).toList();
      final pageResult = MoviePageResult(
        page: result.page,
        perPage: result.perPage,
        totalItems: result.totalItems,
        totalPages: result.totalPages,
        items: items,
      );

      _pagedCache[cacheKey] = pageResult;
      return pageResult;
    } catch (e) {
      debugPrint('⚠️ Lỗi tải phân trang PocketBase ($e). Phục vụ qua mock cache.');
      _isUsingOfflineMock = true;
      return _paginateMockMovies(
        page: page,
        perPage: perPage,
        category: category,
        filter: filter,
        sort: sort,
      );
    } finally {
      _inFlightPagedRequests.remove(cacheKey);
    }
  }

  MoviePageResult _paginateMockMovies({
    required int page,
    required int perPage,
    String? category,
    String? filter,
    String? sort,
  }) {
    List<MovieModel> list = List.of(_mockMovies);

    if (category != null && category.isNotEmpty && category != 'Tất cả') {
      list = list
          .where((m) => m.category.toLowerCase().contains(category.toLowerCase()))
          .toList();
    }

    if (filter != null && filter.isNotEmpty) {
      final queryLower = filter.toLowerCase();
      list = list
          .where((m) =>
              m.title.toLowerCase().contains(queryLower) ||
              m.description.toLowerCase().contains(queryLower) ||
              m.category.toLowerCase().contains(queryLower))
          .toList();
    }

    final totalItems = list.length;
    final totalPages = (totalItems / perPage).ceil().clamp(1, 999999);
    final startIndex = (page - 1) * perPage;
    final items = (startIndex < totalItems)
        ? list.skip(startIndex).take(perPage).toList()
        : <MovieModel>[];

    return MoviePageResult(
      page: page,
      perPage: perPage,
      totalItems: totalItems,
      totalPages: totalPages,
      items: items,
    );
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

  /// Lấy chi tiết một bộ phim theo ID
  Future<MovieModel?> getMovieById(String id) async {
    final all = await getMovies();
    try {
      return all.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Lấy danh sách Top 10 phim
  Future<List<MovieModel>> getTop10Movies() async {
    final all = await getMovies();
    final ranked = all.where((m) => m.rank != null && m.rank! > 0).toList()
      ..sort((a, b) => a.rank!.compareTo(b.rank!));
    if (ranked.isNotEmpty) {
      return ranked.take(10).toList();
    }
    return all.take(10).toList();
  }

  /// Lấy danh sách phim theo danh mục
  Future<List<MovieModel>> getMoviesByCategory(String category) async {
    final allMovies = await getMovies();
    return allMovies
        .where((m) => m.category.toLowerCase() == category.toLowerCase())
        .toList();
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
      description: 'Một chú thỏ khổng lồ tốt bụng quyết định trả đũa ba chú sóc bay hay bắt nạt các sinh vật nhỏ bé trong khu rừng tươi đẹp. Một tác phẩm phim 3D mã nguồn mở kinh điển của Blender Foundation.',
      category: 'Hoạt hình',
      posterUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c5/Big_buck_bunny_poster_big.jpg/600px-Big_buck_bunny_poster_big.jpg',
      videoUrl: 'https://vjs.zencdn.net/v/oceans.mp4',
      releaseYear: 2008,
      isFeatured: true,
    ),
    MovieModel(
      id: 'mock_2',
      title: 'Sintel - Trái Tim Rồng',
      description: 'Cuộc hành trình đơn độc và đầy trắc trở của cô gái trẻ Sintel vượt qua sa mạc băng giá để tìm lại chú rồng con Scales bị bắt cóc.',
      category: 'Hoạt hình',
      posterUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/8/8f/Sintel_poster.jpg/600px-Sintel_poster.jpg',
      videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
      releaseYear: 2010,
      isFeatured: true,
    ),
    MovieModel(
      id: 'mock_3',
      title: 'Tears of Steel',
      description: 'Lấy bối cảnh tương lai hậu tận thế tại Amsterdam, một nhóm chiến binh và nhà khoa học cố gắng cứu vãn tương lai loài người khỏi sự thống trị của người máy tàn bạo.',
      category: 'Viễn tưởng',
      posterUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e0/Tears_of_Steel_poster.jpg/600px-Tears_of_Steel_poster.jpg',
      videoUrl:
          'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
      releaseYear: 2012,
      isFeatured: true,
    ),
    MovieModel(
      id: 'mock_4',
      title: 'Elephants Dream',
      description: 'Hai nhân vật Proog và Emo cùng lạc vào cỗ máy khổng lồ vô tận, đối mặt với những ảo cảnh siêu thực trong thế giới máy móc phức tạp.',
      category: 'Viễn tưởng',
      posterUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/0c/Elephants_Dream_poster.jpg/600px-Elephants_Dream_poster.jpg',
      videoUrl: 'https://vjs.zencdn.net/v/oceans.mp4',
      releaseYear: 2006,
      isFeatured: false,
    ),
    MovieModel(
      id: 'mock_5',
      title: 'For Bigger Blazes',
      description: 'Những pha hành động mạo hiểm nghẹt thở, những cú nhảy phi thân và tốc độ bùng nổ của các tay đua mạo hiểm đỉnh cao thế giới.',
      category: 'Hành động',
      posterUrl: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=800&auto=format&fit=crop&q=80',
      videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
      releaseYear: 2023,
      isFeatured: false,
    ),
    MovieModel(
      id: 'mock_6',
      title: 'For Bigger Escape',
      description: 'Cuộc tẩu thoát ngoạn mục khỏi thành phố ngầm với những màn rượt đuổi tốc độ cao cùng hiệu ứng kỹ xảo điện ảnh ấn tượng.',
      category: 'Hành động',
      posterUrl: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=800&auto=format&fit=crop&q=80',
      videoUrl: 'https://vjs.zencdn.net/v/oceans.mp4',
      releaseYear: 2024,
      isFeatured: false,
    ),
    MovieModel(
      id: 'mock_7',
      title: 'For Bigger Fun',
      description: 'Tận hưởng những khoảnh khắc vui tươi, phấn khích với hành trình phiêu lưu dã ngoại khám phá những điều kỳ thú của thiên nhiên hoang dã.',
      category: 'Hài hước',
      posterUrl: 'https://images.unsplash.com/photo-1536440136628-849c177e76a1?w=800&auto=format&fit=crop&q=80',
      videoUrl: 'https://vjs.zencdn.net/v/oceans.mp4',
      releaseYear: 2023,
      isFeatured: false,
    ),
    MovieModel(
      id: 'mock_8',
      title: 'Bullrun Supercar Rally',
      description: 'Giải đua xe siêu cấp xuyên lục địa quy tụ dàn siêu xe tốc độ cao mạnh mẽ nhất hành tinh và tinh thần thi đấu bất diệt.',
      category: 'Hành động',
      posterUrl: 'https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=800&auto=format&fit=crop&q=80',
      videoUrl: 'https://vjs.zencdn.net/v/oceans.mp4',
      releaseYear: 2022,
      isFeatured: false,
    ),
    MovieModel(
      id: 'mock_9',
      title: 'Cosmos Laundromat',
      description: 'Trên hòn đảo hoang vắng, chú cừu Franck tuyệt vọng chuẩn bị kết liễu cuộc đời thì một nhân vật bí ẩn xuất hiện đề nghị cho chú một cơ hội tái sinh.',
      category: 'Hoạt hình',
      posterUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/3/36/Cosmos_Laundromat_-_First_Cycle_poster.jpg/600px-Cosmos_Laundromat_-_First_Cycle_poster.jpg',
      videoUrl: 'https://vjs.zencdn.net/v/oceans.mp4',
      releaseYear: 2015,
      isFeatured: false,
      isNew: true,
    ),
    MovieModel(
      id: 'mock_10',
      title: 'Spring - Mùa Xuân Kỳ Diệu',
      description: 'Cô bé chăn cừu và chú chó trung thành phải đối mặt với các linh hồn cổ xưa để đánh thức mùa xuân và giải cứu thung lũng khỏi mùa đông vĩnh cửu.',
      category: 'Hoạt hình',
      posterUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/ca/Spring_-_Blender_Open_Movie_poster.jpg/600px-Spring_-_Blender_Open_Movie_poster.jpg',
      videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
      releaseYear: 2019,
      isFeatured: false,
      isNew: true,
    ),
    MovieModel(
      id: 'mock_11',
      title: 'Charge - Sạc Điện',
      description: 'Trong thành phố robot tương lai, một người đàn ông già tìm cách cứu robot đồng hành của mình bằng cách lấy cắp pin năng lượng cuối cùng.',
      category: 'Viễn tưởng',
      posterUrl: 'https://images.unsplash.com/photo-1579546929518-9e396f3cc809?w=800&auto=format&fit=crop&q=80',
      videoUrl:
          'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
      releaseYear: 2022,
      isFeatured: false,
      isNew: true,
    ),
    MovieModel(
      id: 'mock_12',
      title: 'Sprite Fright',
      description: 'Nhóm thanh thiếu niên thập niên 80 đi dã ngoại trong rừng và vô tình chọc giận những sinh vật yêu tinh nấm tí hon nhưng cực kỳ hung dữ.',
      category: 'Hài hước',
      posterUrl: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=800&auto=format&fit=crop&q=80',
      videoUrl: 'https://vjs.zencdn.net/v/oceans.mp4',
      releaseYear: 2021,
      isFeatured: false,
    ),
    MovieModel(
      id: 'mock_13',
      title: 'Coffee Run',
      description: 'Chuyến đi mua cà phê biến thành một chuỗi sự kiện hài hước dở khóc dở cười khi cô gái gặp phải hàng loạt trở ngại kỳ lạ trên đường phố.',
      category: 'Hài hước',
      posterUrl: 'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=800&auto=format&fit=crop&q=80',
      videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
      releaseYear: 2020,
      isFeatured: false,
    ),
    MovieModel(
      id: 'mock_14',
      title: 'Chasing Aurora',
      description: 'Hành trình săn lùng cực quang phương Bắc tuyệt mỹ qua những ngọn núi tuyết phủ trắng xóa tại Na Uy và Iceland.',
      category: 'Tài liệu',
      posterUrl: 'https://images.unsplash.com/photo-1531366936337-7c912a4589a7?w=800&auto=format&fit=crop&q=80',
      videoUrl: 'https://vjs.zencdn.net/v/oceans.mp4',
      releaseYear: 2023,
      isFeatured: false,
      isNew: true,
    ),
    MovieModel(
      id: 'mock_15',
      title: 'Deep Blue Horizon',
      description: 'Khám phá thế giới đại dương bao la, rạn san hô kỳ vĩ và những sinh vật phát quang bí ẩn dưới đáy vực sâu thẳm.',
      category: 'Tài liệu',
      posterUrl: 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=800&auto=format&fit=crop&q=80',
      videoUrl: 'https://vjs.zencdn.net/v/oceans.mp4',
      releaseYear: 2024,
      isFeatured: false,
      isNew: true,
    ),
    MovieModel(
      id: 'mock_16',
      title: 'Cyberpunk 2099',
      description: 'Trong đô thị ngập tràn ánh đèn neon, một thám tử tư điều tra vụ mất tích bí ẩn của một người máy AI mang ý thức độc lập.',
      category: 'Viễn tưởng',
      posterUrl: 'https://images.unsplash.com/photo-1508739773434-c26b3d09e071?w=800&auto=format&fit=crop&q=80',
      videoUrl:
          'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
      releaseYear: 2024,
      isFeatured: false,
      isNew: true,
    ),
    MovieModel(
      id: 'mock_17',
      title: 'Speed Masters',
      description: 'Giải đua xe công thức không gian trên hành tinh sa mạc với các cỗ máy bay phản lực đạt vận tốc siêu thanh.',
      category: 'Hành động',
      posterUrl: 'https://images.unsplash.com/photo-1568605117036-5fe5e7bab0b7?w=800&auto=format&fit=crop&q=80',
      videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
      releaseYear: 2023,
      isFeatured: false,
    ),
    MovieModel(
      id: 'mock_18',
      title: 'Mystic Highlands',
      description: 'Huyền thoại về vương quốc sương mù nơi các pháp sư bảo vệ nguồn cội của viên ngọc ánh sáng trước bóng tối vĩnh hằng.',
      category: 'Phiêu lưu',
      posterUrl: 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=800&auto=format&fit=crop&q=80',
      videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
      releaseYear: 2021,
      isFeatured: false,
    ),
    MovieModel(
      id: 'mock_19',
      title: 'Beyond The Stars',
      description: 'Chuyến du hành liên thiên hà tìm kiếm nguồn nước mới cho Trái Đất của tàu thám hiểm không gian Endeavor.',
      category: 'Viễn tưởng',
      posterUrl: 'https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=800&auto=format&fit=crop&q=80',
      videoUrl: 'https://vjs.zencdn.net/v/oceans.mp4',
      releaseYear: 2022,
      isFeatured: false,
    ),
    MovieModel(
      id: 'mock_20',
      title: 'Shadow Samurai',
      description: 'Một kiếm sĩ lang thang phải bảo vệ ngôi làng nhỏ trước sự tấn công của băng đảng sơn tặc tàn bạo thời kỳ Edo.',
      category: 'Hành động',
      posterUrl: 'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=800&auto=format&fit=crop&q=80',
      videoUrl: 'https://vjs.zencdn.net/v/oceans.mp4',
      releaseYear: 2023,
      isFeatured: false,
      isNew: true,
    ),
    MovieModel(
      id: 'mock_21',
      title: 'The Wild Kingdom',
      description: 'Ghi lại cuộc sống thường nhật, những màn săn mồi đỉnh cao và tình mẫu tử thiêng liêng trên thảo nguyên Serengeti châu Phi.',
      category: 'Tài liệu',
      posterUrl: 'https://images.unsplash.com/photo-1546182990-dffeafbe841d?w=800&auto=format&fit=crop&q=80',
      videoUrl: 'https://vjs.zencdn.net/v/oceans.mp4',
      releaseYear: 2020,
      isFeatured: false,
    ),
    MovieModel(
      id: 'mock_22',
      title: 'Chronicles of Olympus',
      description: 'Trận chiến giữa các vị thần Hy Lạp và Titan cổ đại trong cuộc chiến giành quyền kiểm soát đỉnh núi Olympus huyền thoại.',
      category: 'Phiêu lưu',
      posterUrl: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=800&auto=format&fit=crop&q=80',
      videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
      releaseYear: 2023,
      isFeatured: false,
      isNew: true,
    ),
    MovieModel(
      id: 'mock_23',
      title: 'Retro Arcade Hero',
      description: 'Một lập trình viên trẻ tuổi bị hút vào thế giới trò chơi điện tử 8-bit và phải đánh bại trùm cuối để quay trở lại thế giới thực.',
      category: 'Hài hước',
      posterUrl: 'https://images.unsplash.com/photo-1550745165-9bc0b252726f?w=800&auto=format&fit=crop&q=80',
      videoUrl: 'https://vjs.zencdn.net/v/oceans.mp4',
      releaseYear: 2022,
      isFeatured: false,
    ),
    MovieModel(
      id: 'mock_24',
      title: 'Flight Over The Alps',
      description: 'Trải nghiệm cảm giác bay lượn trên dãy núi Alps phủ đầy tuyết trắng bằng dù lượn và máy bay không người lái độ phân giải siêu nét.',
      category: 'Tài liệu',
      posterUrl: 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=800&auto=format&fit=crop&q=80',
      videoUrl: 'https://vjs.zencdn.net/v/oceans.mp4',
      releaseYear: 2024,
      isFeatured: false,
      isNew: true,
    ),
  ];
}
