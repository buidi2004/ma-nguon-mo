import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/movie_model.dart';
import '../services/library_service.dart';
import '../services/pocketbase_service.dart';
import '../theme/app_theme.dart';
import '../widgets/hero_banner.dart';
import '../widgets/movie_row.dart';

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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final movies = await _pbService.getMovies();
      final featured = await _pbService.getFeaturedMovies();

      if (!mounted) return;

      setState(() {
        _allMovies = movies;
        _filteredMovies = movies;
        if (featured.isNotEmpty) {
          _featuredMovie = featured.first;
        } else if (movies.isNotEmpty) {
          _featuredMovie = movies.first;
        } else {
          _featuredMovie = null;
        }
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String query) {
    final trimmed = query.trim().toLowerCase();
    setState(() {
      if (trimmed.isEmpty && _selectedCategory == 'Tất cả') {
        _filteredMovies = _allMovies;
      } else {
        _filteredMovies = _allMovies.where((m) {
          final matchesQuery =
              trimmed.isEmpty ||
              m.title.toLowerCase().contains(trimmed) ||
              m.description.toLowerCase().contains(trimmed);
          final matchesCategory =
              _selectedCategory == 'Tất cả' || m.category == _selectedCategory;
          return matchesQuery && matchesCategory;
        }).toList();
      }
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

  void _playMovie(MovieModel movie) {
    context.push('/watch/${movie.id}');
  }

  void _openMovieDetail(MovieModel movie) {
    context.push('/movie/${movie.id}');
  }

  /// Netflix-style Quick Details Bottom Sheet
  void _showMovieDetailModal(MovieModel movie) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thanh kéo modal trên cùng
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // Thông tin nhanh với ảnh thu nhỏ
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: CachedNetworkImage(
                        imageUrl: movie.posterUrl,
                        width: 76,
                        height: 114,
                        fit: BoxFit.cover,
                        placeholder: (_, _) =>
                            const ColoredBox(color: AppColors.surfaceLight),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            movie.title,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Text(
                                '${movie.releaseYear}',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: AppColors.textMuted,
                                    width: 0.8,
                                  ),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: const Text(
                                  'HD',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                movie.category,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            movie.description,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Nút Phát toàn chiều ngang
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _playMovie(movie);
                    },
                    icon: const Icon(
                      Icons.play_arrow,
                      color: Colors.black,
                      size: 24,
                    ),
                    label: const Text(
                      'Phát',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openServerConfigDialog() {
    final urlController = TextEditingController(text: _pbService.baseUrl);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              title: const Row(
                children: [
                  Icon(Icons.cloud_outlined, color: AppColors.red),
                  SizedBox(width: 8),
                  Text(
                    'Cấu hình PocketBase',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
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
                          ? '🟡 Đang dùng Mock Data offline'
                          : '🟢 Đã kết nối PocketBase API',
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
                      'Địa chỉ máy chủ PocketBase:',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: urlController,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.background,
                        hintText: 'https://xxx.pockethost.io',
                        hintStyle: const TextStyle(color: AppColors.textMuted),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
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
                            content: Text(
                              'Đang nạp dữ liệu phim mẫu vào PocketBase...',
                            ),
                            backgroundColor: Colors.blueAccent,
                          ),
                        );
                        final count = await _pbService.seedRemotePocketBase(
                          targetUrl,
                        );
                        scaffoldMsg.showSnackBar(
                          SnackBar(
                            content: Text(
                              'Đã nạp thành công $count phim vào PocketBase!',
                            ),
                            backgroundColor: AppColors.red,
                          ),
                        );
                        _pbService.updateBaseUrl(targetUrl);
                        _loadData();
                      },
                      icon: const Icon(Icons.upload_file, size: 18),
                      label: const Text('Nạp dữ liệu phim mẫu lên Server'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.red,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 38),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Đóng',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
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
      backgroundColor: AppColors.background,
      // AppBar trong suốt đè lên HeroBanner
      extendBodyBehindAppBar: !_isSearching,
      appBar: AppBar(
        backgroundColor: _isSearching
            ? AppColors.background
            : Colors.black.withValues(alpha: 0.3),
        elevation: 0,
        titleSpacing: 12,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: _onSearchChanged,
                style: const TextStyle(color: Colors.white, fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Tìm phim, diễn viên, thể loại...',
                  hintStyle: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.clear,
                            color: Colors.white70,
                            size: 18,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                        )
                      : null,
                ),
              )
            : Row(
                children: [
                  // OpenFlix Red Wordmark chuẩn Netflix
                  const Text(
                    'OPENFLIX',
                    style: TextStyle(
                      color: AppColors.red,
                      fontWeight: FontWeight.w900,
                      fontSize: 21,
                      letterSpacing: 2.0,
                    ),
                  ),
                ],
              ),
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: Colors.white,
              size: 24,
            ),
            tooltip: _isSearching ? 'Đóng tìm kiếm' : 'Tìm kiếm',
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
              Icons.cloud_done_rounded,
              color: _pbService.isUsingOfflineMock
                  ? Colors.amberAccent
                  : Colors.greenAccent,
              size: 22,
            ),
            tooltip: 'Kết nối máy chủ',
            onPressed: _openServerConfigDialog,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.red),
                strokeWidth: 3,
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadData,
              color: AppColors.red,
              backgroundColor: AppColors.surface,
              child: _buildBody(),
            ),
    );
  }

  Widget _buildBody() {
    if (_allMovies.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.movie_filter_outlined,
              size: 64,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 16),
            const Text(
              'Chưa có dữ liệu phim nào',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _openServerConfigDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: const Text('Cấu hình / Nạp dữ liệu mẫu'),
            ),
          ],
        ),
      );
    }

    // Nếu đang tìm kiếm hoặc chọn lọc thể loại
    if (_isSearching || _selectedCategory != 'Tất cả') {
      return _buildSearchOrFilterGrid();
    }

    // Giao diện chính Netflix: HeroBanner + các hàng phim cuộn ngang
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Hero Banner nổi bật trên cùng
          if (_featuredMovie != null)
            HeroBanner(
              movie: _featuredMovie!,
              onPlay: () => _playMovie(_featuredMovie!),
              onInfo: () => _showMovieDetailModal(_featuredMovie!),
            ),

          // 2. Chip lọc thể loại nhỏ gọn đè nhẹ dưới Hero
          _buildCategoryFilterRow(),

          const SizedBox(height: 4),

          // 3. Hàng "Tiếp tục xem của bạn" chuẩn Netflix (S26)
          ListenableBuilder(
            listenable: LibraryService.instance,
            builder: (context, _) {
              final progressIds = LibraryService.instance.progressMap.keys
                  .toSet();
              final continueMovies = _allMovies
                  .where((m) => progressIds.contains(m.id))
                  .toList();
              if (continueMovies.isEmpty) return const SizedBox.shrink();
              return MovieRow(
                title: 'Tiếp tục xem của bạn',
                movies: continueMovies,
                onTap: _openMovieDetail,
                onSeeAll: () => context.push('/me/continue'),
              );
            },
          ),

          // 4. Hàng Top 10 Phim Thịnh Hành (S17)
          MovieRow(
            title: 'Top 10 Phim Thịnh Hành',
            movies: _allMovies.take(10).toList(),
            onTap: _openMovieDetail,
            onSeeAll: () => context.push('/top10'),
          ),

          // 5. Các hàng phim cuộn ngang chuẩn Netflix 3.4 peek ratio
          MovieRow(
            title: 'Phim thịnh hành',
            movies: _allMovies,
            onTap: _openMovieDetail,
            onSeeAll: () => context.push('/see-all/trending'),
          ),

          MovieRow(
            title: 'Hoạt hình đặc sắc',
            movies: _allMovies
                .where((m) => m.category.toLowerCase().contains('hoạt'))
                .toList(),
            onTap: _openMovieDetail,
            onSeeAll: () => context.push('/genre/Hoạt hình'),
          ),

          MovieRow(
            title: 'Khoa học viễn tưởng',
            movies: _allMovies
                .where((m) => m.category.toLowerCase().contains('viễn'))
                .toList(),
            onTap: _openMovieDetail,
            onSeeAll: () => context.push('/genre/Viễn tưởng'),
          ),

          MovieRow(
            title: 'Hành động & Phiêu lưu',
            movies: _allMovies
                .where(
                  (m) =>
                      m.category.toLowerCase().contains('hành') ||
                      m.category.toLowerCase().contains('phiêu'),
                )
                .toList(),
            onTap: _openMovieDetail,
            onSeeAll: () => context.push('/genre/Hành động'),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  /// Chip lọc danh mục phong cách tối giản
  Widget _buildCategoryFilterRow() {
    return Container(
      height: 40,
      margin: const EdgeInsets.only(top: 8, bottom: 4),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = cat == _selectedCategory;
          return GestureDetector(
            onTap: () => _onCategorySelected(cat),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                cat,
                style: TextStyle(
                  color: isSelected ? Colors.black : AppColors.textPrimary,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Lưới 3 cột poster khi tìm kiếm hoặc lọc danh mục (theo mục 3 trong docs/fe.md)
  Widget _buildSearchOrFilterGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCategoryFilterRow(),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
          child: Text(
            'Kết quả (${_filteredMovies.length} phim)',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(
          child: _filteredMovies.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 56,
                        color: AppColors.textMuted,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Không tìm thấy bộ phim phù hợp',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  itemCount: _filteredMovies.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 2 / 3,
                    crossAxisSpacing: 6,
                    mainAxisSpacing: 6,
                  ),
                  itemBuilder: (context, index) {
                    final movie = _filteredMovies[index];
                    return GestureDetector(
                      onTap: () => _openMovieDetail(movie),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: CachedNetworkImage(
                            imageUrl: movie.posterUrl,
                            fit: BoxFit.cover,
                            placeholder: (_, _) =>
                                const ColoredBox(color: AppColors.surface),
                            errorWidget: (_, _, _) => Container(
                              color: AppColors.surface,
                              padding: const EdgeInsets.all(4),
                              child: Center(
                                child: Text(
                                  movie.title,
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
