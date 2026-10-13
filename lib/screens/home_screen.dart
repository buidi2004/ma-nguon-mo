import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/movie_model.dart';
import '../services/pocketbase_service.dart';
import '../widgets/movie_card.dart';
import 'player_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PocketBaseService _pbService = PocketBaseService.instance;
  final TextEditingController _searchController = TextEditingController();

  List<MovieModel> _allMovies = [];
  List<MovieModel> _filteredMovies = [];
  MovieModel? _featuredMovie;
  bool _isLoading = true;
  bool _isSearching = false;
  String _selectedCategory = 'Tất cả';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    final movies = await _pbService.getMovies();
    final featured = await _pbService.getFeaturedMovies();

    setState(() {
      _allMovies = movies;
      _filteredMovies = movies;
      if (featured.isNotEmpty) {
        _featuredMovie = featured.first;
      } else if (movies.isNotEmpty) {
        _featuredMovie = movies.first;
      }
      _isLoading = false;
    });
  }

  void _onSearchChanged(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _filteredMovies = _selectedCategory == 'Tất cả'
            ? _allMovies
            : _allMovies.where((m) => m.category == _selectedCategory).toList();
      });
      return;
    }

    final lower = query.toLowerCase().trim();
    setState(() {
      _filteredMovies = _allMovies.where((m) {
        final matchesQuery = m.title.toLowerCase().contains(lower) ||
            m.description.toLowerCase().contains(lower);
        final matchesCategory =
            _selectedCategory == 'Tất cả' || m.category == _selectedCategory;
        return matchesQuery && matchesCategory;
      }).toList();
    });
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
      _onSearchChanged(_searchController.text);
    });
  }

  List<String> get _categories {
    final set = {'Tất cả'};
    for (var m in _allMovies) {
      if (m.category.isNotEmpty) set.add(m.category);
    }
    return set.toList();
  }

  void _openServerConfigDialog() {
    final urlController = TextEditingController(text: _pbService.baseUrl);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E1E1E),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: const Row(
                children: [
                  Icon(Icons.cloud_outlined, color: Color(0xFFE50914)),
                  SizedBox(width: 8),
                  Text(
                    'Cấu hình PocketBase',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _pbService.isUsingOfflineMock
                          ? 'Trạng thái: 🟡 Đang dùng dữ liệu Demo offline'
                          : 'Trạng thái: 🟢 Đã kết nối PocketBase API',
                      style: TextStyle(
                        color: _pbService.isUsingOfflineMock
                            ? Colors.amberAccent
                            : Colors.greenAccent,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Địa chỉ máy chủ PocketBase / PocketHost:',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: urlController,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF2A2A2A),
                        hintText: 'https://xxx.pockethost.io',
                        hintStyle: const TextStyle(color: Colors.white38),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final nav = Navigator.of(context);
                        final scaffoldMsg = ScaffoldMessenger.of(context);
                        final targetUrl = urlController.text.trim();
                        nav.pop();
                        scaffoldMsg.showSnackBar(
                          const SnackBar(
                            content: Text('Đang nạp 8 bộ phim mẫu vào PocketBase...'),
                            backgroundColor: Colors.blueAccent,
                          ),
                        );
                        final count = await _pbService.seedRemotePocketBase(targetUrl);
                        scaffoldMsg.showSnackBar(
                          SnackBar(
                            content: Text('Đã nạp thành công $count phim vào PocketBase!'),
                            backgroundColor: const Color(0xFFE50914),
                          ),
                        );
                        _pbService.updateBaseUrl(targetUrl);
                        _loadData();
                      },
                      icon: const Icon(Icons.upload_file, size: 18),
                      label: const Text('1-Click: Nạp 8 phim mẫu lên Server'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE50914),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 38),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Đóng', style: TextStyle(color: Colors.white54)),
                ),
                ElevatedButton(
                  onPressed: () {
                    _pbService.updateBaseUrl(urlController.text.trim());
                    Navigator.pop(context);
                    _loadData();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Lưu & Tải lại'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      appBar: AppBar(
        backgroundColor: const Color(0xFF141414).withValues(alpha: 0.95),
        elevation: 0,
        titleSpacing: 16,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: _onSearchChanged,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Tìm kiếm tên phim, nội dung...',
                  hintStyle: TextStyle(color: Colors.white38),
                  border: InputBorder.none,
                ),
              )
            : Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE50914),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'OPENFLIX',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search, color: Colors.white),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchController.clear();
                  _onSearchChanged('');
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
          IconButton(
            icon: Icon(
              Icons.dns_rounded,
              color: _pbService.isUsingOfflineMock ? Colors.amberAccent : Colors.greenAccent,
            ),
            tooltip: 'Cài đặt kết nối PocketBase',
            onPressed: _openServerConfigDialog,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: const Color(0xFFE50914),
        backgroundColor: const Color(0xFF222222),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE50914)),
                ),
              )
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Thanh lọc Thể loại (Category Filter Chips)
                    _buildCategoryChips(),

                    // Nếu đang tìm kiếm hoặc chọn danh mục cụ thể -> hiển thị Grid kết quả
                    if (_isSearching || _selectedCategory != 'Tất cả')
                      _buildSearchResults()
                    else ...[
                      // 1. Banner nổi bật trên cùng (Hero Banner)
                      if (_featuredMovie != null) _buildFeaturedHeroBanner(_featuredMovie!),

                      const SizedBox(height: 12),

                      // 2. Các hàng danh mục phim cuộn ngang chuẩn Netflix
                      _buildMovieSection(
                        title: 'Phim Thịnh Hành',
                        movies: _allMovies,
                      ),

                      _buildMovieSection(
                        title: 'Hoạt Hình Đặc Sắc',
                        movies: _allMovies
                            .where((m) => m.category.toLowerCase().contains('hoạt'))
                            .toList(),
                      ),

                      _buildMovieSection(
                        title: 'Khoa Học Viễn Tưởng',
                        movies: _allMovies
                            .where((m) => m.category.toLowerCase().contains('viễn'))
                            .toList(),
                      ),

                      _buildMovieSection(
                        title: 'Hành Động Đỉnh Cao',
                        movies: _allMovies
                            .where((m) => m.category.toLowerCase().contains('hành'))
                            .toList(),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ],
                ),
              ),
      ),
    );
  }

  /// Thanh chọn Thể loại phim (Chips)
  Widget _buildCategoryChips() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = cat == _selectedCategory;
          return GestureDetector(
            onTap: () => _onCategorySelected(cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFE50914) : const Color(0xFF262626),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? const Color(0xFFE50914) : Colors.white12,
                ),
              ),
              child: Center(
                child: Text(
                  cat,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Banner Hero phim nổi bật trên cùng
  Widget _buildFeaturedHeroBanner(MovieModel movie) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PlayerScreen(movie: movie)),
        );
      },
      child: Container(
        height: 380,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.6),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Poster nền
              CachedNetworkImage(
                imageUrl: movie.posterUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: const Color(0xFF222222)),
                errorWidget: (context, url, error) => Container(color: const Color(0xFF1E1E1E)),
              ),

              // Gradient phủ mờ từ đen sang trong suốt
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    stops: const [0.0, 0.45, 1.0],
                    colors: [
                      Colors.black.withValues(alpha: 0.95),
                      Colors.black.withValues(alpha: 0.4),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),

              // Huy hiệu Phim nổi bật góc trên trái
              Positioned(
                top: 14,
                left: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE50914).withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    '★ PHIM NỔI BẬT',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),

              // Nội dung và Nút Play ở chân Banner
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      movie.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        shadows: [
                          Shadow(blurRadius: 8, color: Colors.black, offset: Offset(0, 2)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          movie.category,
                          style: const TextStyle(
                            color: Color(0xFFE50914),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '• ${movie.releaseYear}',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      movie.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PlayerScreen(movie: movie),
                                ),
                              );
                            },
                            icon: const Icon(Icons.play_arrow_rounded, color: Colors.black, size: 26),
                            label: const Text(
                              'XEM NGAY',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PlayerScreen(movie: movie),
                                ),
                              );
                            },
                            icon: const Icon(Icons.info_outline, color: Colors.white, size: 20),
                            label: const Text(
                              'CHI TIẾT',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.white60),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Phần danh mục phim cuộn ngang
  Widget _buildMovieSection({required String title, required List<MovieModel> movies}) {
    if (movies.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            itemCount: movies.length,
            itemBuilder: (context, index) {
              return MovieCard(movie: movies[index]);
            },
          ),
        ),
      ],
    );
  }

  /// Hiển thị lưới kết quả tìm kiếm hoặc lọc
  Widget _buildSearchResults() {
    if (_filteredMovies.isEmpty) {
      return Container(
        height: 300,
        alignment: Alignment.center,
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 48, color: Colors.white38),
            SizedBox(height: 12),
            Text(
              'Không tìm thấy bộ phim nào phù hợp!',
              style: TextStyle(color: Colors.white60, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kết quả (${_filteredMovies.length} phim)',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _filteredMovies.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.68,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (context, index) {
              final movie = _filteredMovies[index];
              return MovieCard(
                movie: movie,
                width: double.infinity,
                height: double.infinity,
                showCategory: true,
              );
            },
          ),
        ],
      ),
    );
  }
}
