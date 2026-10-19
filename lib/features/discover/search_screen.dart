import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/movie_grid.dart';
import '../../models/movie_model.dart';
import '../../presentation/widgets/glass/glass_components.dart';
import '../../services/pocketbase_service.dart';
import '../../services/theme_service.dart';
import '../../theme/app_theme.dart';

class SearchScreen extends StatefulWidget {
  final String initialQuery;

  const SearchScreen({super.key, this.initialQuery = ''});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _GenreItem {
  final String title;
  final List<Color> gradientColors;
  final String imageUrl;

  const _GenreItem({
    required this.title,
    required this.gradientColors,
    required this.imageUrl,
  });
}

class _SearchScreenState extends State<SearchScreen>
    with AutomaticKeepAliveClientMixin {
  final PocketBaseService _pbService = PocketBaseService.instance;
  late final TextEditingController _searchController;
  List<MovieModel> _allMovies = [];
  List<MovieModel> _searchResults = [];
  bool _isLoading = false;
  bool _isCategoriesExpanded = false;

  Timer? _debounceTimer;

  @override
  bool get wantKeepAlive => true;

  static const List<_GenreItem> _allGenres = [
    _GenreItem(
      title: 'Gia đình',
      gradientColors: [Color(0xFF1E88E5), Color(0xFF0D47A1)],
      imageUrl: 'https://images.unsplash.com/photo-1511895426328-dc8714191300?w=600&auto=format&fit=crop&q=80',
    ),
    _GenreItem(
      title: 'Tâm lý',
      gradientColors: [Color(0xFF00897B), Color(0xFF004D40)],
      imageUrl: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=600&auto=format&fit=crop&q=80',
    ),
    _GenreItem(
      title: 'Hành động',
      gradientColors: [Color(0xFFE53935), Color(0xFF880E4F)],
      imageUrl: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=600&auto=format&fit=crop&q=80',
    ),
    _GenreItem(
      title: 'Hài',
      gradientColors: [Color(0xFFFB8C00), Color(0xFFD84315)],
      imageUrl: 'https://images.unsplash.com/photo-1536440136628-849c177e76a1?w=600&auto=format&fit=crop&q=80',
    ),
    _GenreItem(
      title: 'Phim Việt',
      gradientColors: [Color(0xFFFBC02D), Color(0xFFE65100)],
      imageUrl: 'https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=600&auto=format&fit=crop&q=80',
    ),
    _GenreItem(
      title: 'Kiếm hiệp',
      gradientColors: [Color(0xFF1E3A8A), Color(0xFF0F172A)],
      imageUrl: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=600&auto=format&fit=crop&q=80',
    ),
    // Danh mục mở rộng khi bấm "Xem thêm"
    _GenreItem(
      title: 'Kinh dị',
      gradientColors: [Color(0xFF4A148C), Color(0xFF1A0033)],
      imageUrl: 'https://images.unsplash.com/photo-1509248961158-e54f6934749c?w=600&auto=format&fit=crop&q=80',
    ),
    _GenreItem(
      title: 'Hoạt hình',
      gradientColors: [Color(0xFF0288D1), Color(0xFF01579B)],
      imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c5/Big_buck_bunny_poster_big.jpg/600px-Big_buck_bunny_poster_big.jpg',
    ),
    _GenreItem(
      title: 'Viễn tưởng',
      gradientColors: [Color(0xFF5E35B1), Color(0xFF311B92)],
      imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e0/Tears_of_Steel_poster.jpg/600px-Tears_of_Steel_poster.jpg',
    ),
    _GenreItem(
      title: 'Lãng mạn',
      gradientColors: [Color(0xFFD81B60), Color(0xFF880E4F)],
      imageUrl: 'https://images.unsplash.com/photo-1518199266791-5375a83190b7?w=600&auto=format&fit=crop&q=80',
    ),
    _GenreItem(
      title: 'Tài liệu',
      gradientColors: [Color(0xFF37474F), Color(0xFF212121)],
      imageUrl: 'https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=600&auto=format&fit=crop&q=80',
    ),
    _GenreItem(
      title: 'Cổ trang',
      gradientColors: [Color(0xFF8D6E63), Color(0xFF3E2723)],
      imageUrl: 'https://images.unsplash.com/photo-1469474968028-56623f02e42e?w=600&auto=format&fit=crop&q=80',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadData();
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final movies = await _pbService.getMovies();
    if (!mounted) return;
    setState(() {
      _allMovies = movies;
      _isLoading = false;
    });
    if (_searchController.text.isNotEmpty) {
      _onSearchChanged(_searchController.text, immediate: true);
    }
  }

  void _onSearchChanged(String query, {bool immediate = false}) {
    _debounceTimer?.cancel();
    final lower = query.trim().toLowerCase();
    if (lower.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    void executeSearch() {
      if (!mounted) return;
      setState(() {
        _searchResults = _allMovies.where((m) {
          return m.title.toLowerCase().contains(lower) ||
              m.description.toLowerCase().contains(lower) ||
              m.category.toLowerCase().contains(lower) ||
              m.director.toLowerCase().contains(lower) ||
              m.cast.toLowerCase().contains(lower);
        }).toList();
      });
    }

    if (immediate) {
      executeSearch();
    } else {
      _debounceTimer = Timer(const Duration(milliseconds: 280), executeSearch);
    }
  }

  void _onGenreTapped(String genre) {
    _searchController.text = genre;
    _onSearchChanged(genre, immediate: true);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isSearching = _searchController.text.trim().isNotEmpty;
    final topPadding = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          children: [
            SizedBox(height: topPadding + 8),
            // Header: Tiêu đề "Tìm kiếm" & Thanh tìm kiếm Kính Mờ Quang Học
            _buildHeaderAndSearchBar(),
            const SizedBox(height: 12),
            Expanded(
              child: isSearching
                  ? _buildSearchResultsGrid()
                  : _buildMainDiscoveryView(),
            ),
          ],
        ),
      ),
    );
  }

  /// Tiêu đề "Tìm kiếm" và Thanh tìm kiếm kính mờ bo tròn (Glass Capsule)
  Widget _buildHeaderAndSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'Tìm kiếm',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              GlassIconButton.circle(
                size: 38,
                iconSize: 20,
                icon: Icons.tune_rounded,
                tooltip: 'Bộ lọc nâng cao',
                onPressed: () => context.push('/search/filter'),
              ),
            ],
          ),
          // Thanh tìm kiếm kính mờ thích ứng quang học
          GlassDynamicSearchBar(
            controller: _searchController,
            onChanged: _onSearchChanged,
            hintText: 'Tên phim, diễn viên, thể loại',
          ),
        ],
      ),
    );
  }

  /// Giao diện khám phá chính: Lưới Thể loại (Genre Cards) + Có thể bạn quan tâm
  Widget _buildMainDiscoveryView() {
    final displayedGenres = _isCategoriesExpanded
        ? _allGenres
        : _allGenres.take(6).toList();

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // 1. Lưới 2 cột các thẻ Thể Loại (Genre Cards)
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.62,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final genre = displayedGenres[index];
              return _buildGenreCard(genre);
            }, childCount: displayedGenres.length),
          ),
        ),

        // 2. Nút "Xem thêm" / "Thu gọn" với mũi tên chỉ hướng
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: 6, bottom: 16),
            child: Center(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isCategoriesExpanded = !_isCategoriesExpanded;
                  });
                },
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isCategoriesExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _isCategoriesExpanded ? 'Thu gọn' : 'Xem thêm',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // 3. Tiêu đề mục "Có thể bạn quan tâm"
        const SliverPadding(
          padding: EdgeInsets.fromLTRB(16, 4, 16, 12),
          sliver: SliverToBoxAdapter(
            child: Text(
              'Có thể bạn quan tâm',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ),

        // 4. Lưới 2 cột các phim gợi ý tỷ lệ 16:9 kèm Badges Độc Quyền & Thể thức
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 110),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.52,
              crossAxisSpacing: 10,
              mainAxisSpacing: 12,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (_allMovies.isEmpty) {
                  return Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  );
                }
                final movie = _allMovies[index % _allMovies.length];
                return _buildRecommendedMovieCard(movie, index);
              },
              childCount: _allMovies.isEmpty
                  ? 4
                  : (_allMovies.length.clamp(4, 12)),
            ),
          ),
        ),
      ],
    );
  }

  /// Thẻ thể loại có nền chuyển sắc rực rỡ và hình nhân vật cắt cúp nghệ thuật
  Widget _buildGenreCard(_GenreItem genre) {
    return RepaintBoundary(
      child: GestureDetector(
        onTap: () => _onGenreTapped(genre.title),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: LinearGradient(
                colors: genre.gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.12),
                width: 0.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: genre.gradientColors.first.withValues(alpha: 0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Stack(
              children: [
                // 1. Hình ảnh nền nhân vật/poster nghệ thuật cắt cúp bên phải
                Positioned(
                  right: -8,
                  top: 0,
                  bottom: 0,
                  width: 105,
                  child: Opacity(
                    opacity: 0.85,
                    child: CachedNetworkImage(
                      imageUrl: genre.imageUrl,
                      fit: BoxFit.cover,
                      alignment: Alignment.centerRight,
                      memCacheWidth: 260,
                      memCacheHeight: 180,
                      placeholder: (_, _) => const SizedBox.shrink(),
                      errorWidget: (_, _, _) => const SizedBox.shrink(),
                    ),
                  ),
                ),

                // 2. Lớp gradient che phủ bên trái để chữ luôn nổi bật
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          genre.gradientColors.first.withValues(alpha: 0.95),
                          genre.gradientColors.first.withValues(alpha: 0.65),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.55, 1.0],
                      ),
                    ),
                  ),
                ),

                // 3. Lớp Vignette tối ở chân chữ
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.40),
                        ],
                        stops: const [0.5, 1.0],
                      ),
                    ),
                  ),
                ),

                // 4. Tiêu đề thể loại đặt ở góc dưới bên trái
                Positioned(
                  left: 12,
                  bottom: 10,
                  right: 36,
                  child: Text(
                    genre.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                      shadows: [
                        Shadow(
                          color: Colors.black87,
                          blurRadius: 6,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Thẻ phim 16:9 mục "Có thể bạn quan tâm" với Badge Độc Quyền & Format Pill
  Widget _buildRecommendedMovieCard(MovieModel movie, int index) {
    // Phân loại badge để tạo độ phong phú điện ảnh như ảnh mẫu
    final bool isExclusive = index % 2 == 0 || movie.isFeatured;
    final bool isRental = index % 3 == 0;
    final bool isFullSeries = index % 3 == 1;

    return RepaintBoundary(
      child: GestureDetector(
        onTap: () => context.push('/movie/${movie.id}'),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.14),
                width: 0.8,
              ),
            ),
            child: Stack(
              children: [
                // 1. Ảnh thumbnail 16:9
                Positioned.fill(
                  child: CachedNetworkImage(
                    imageUrl: movie.posterUrl,
                    fit: BoxFit.cover,
                    memCacheWidth: 380,
                    memCacheHeight: 240,
                    placeholder: (_, _) =>
                        const ColoredBox(color: AppColors.surfaceLight),
                    errorWidget: (_, _, _) => Container(
                      color: AppColors.surface,
                      child: const Icon(
                        Icons.movie_outlined,
                        color: Colors.white38,
                        size: 28,
                      ),
                    ),
                  ),
                ),

                // 2. Lớp gradient chuyển tiếp ở đáy card
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.30),
                          Colors.black.withValues(alpha: 0.85),
                        ],
                        stops: const [0.35, 0.65, 1.0],
                      ),
                    ),
                  ),
                ),

                // 3. Badge tròn vàng góc trên bên trái "ĐỘC QUYỀN"
                if (isExclusive)
                  Positioned(top: 6, left: 6, child: _buildExclusiveBadge()),

                // 4. Badge định dạng ở góc dưới bên trái (PHIM THUÊ / TRỌN BỘ / MỚI)
                Positioned(
                  left: 6,
                  bottom: 6,
                  child: _buildFormatBadge(
                    isRental: isRental,
                    isFullSeries: isFullSeries,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Badge tròn vàng rực rỡ "ĐỘC QUYỀN" chuẩn mẫu tham chiếu
  Widget _buildExclusiveBadge() {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [Color(0xFFFFEA00), Color(0xFFFFB300)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.55),
            blurRadius: 4,
            offset: const Offset(0, 1.5),
          ),
        ],
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.65),
          width: 0.8,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'ĐỘC',
              style: TextStyle(
                color: Color(0xFFB71C1C),
                fontSize: 6,
                fontWeight: FontWeight.w900,
                height: 1.0,
              ),
            ),
            Text(
              'QUYỀN',
              style: TextStyle(
                color: Color(0xFFB71C1C),
                fontSize: 5,
                fontWeight: FontWeight.w900,
                height: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Badge định dạng phim (PHIM THUÊ / TRỌN BỘ / MỚI)
  Widget _buildFormatBadge({
    required bool isRental,
    required bool isFullSeries,
  }) {
    if (isRental) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        decoration: BoxDecoration(
          color: const Color(0xFF007AFF),
          borderRadius: BorderRadius.circular(3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 3,
            ),
          ],
        ),
        child: const Text(
          'PHIM THUÊ',
          style: TextStyle(
            color: Colors.white,
            fontSize: 8.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
          ),
        ),
      );
    }

    if (isFullSeries) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.75),
          borderRadius: BorderRadius.circular(3),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 0.6,
          ),
        ),
        child: const Text(
          'TRỌN BỘ',
          style: TextStyle(
            color: Colors.white,
            fontSize: 8.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: ThemeService.instance.primaryColor,
        borderRadius: BorderRadius.circular(3),
      ),
      child: const Text(
        'MỚI',
        style: TextStyle(
          color: Colors.white,
          fontSize: 8.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  /// Khi gõ tìm kiếm: Lưới poster kết quả tìm kiếm thích ứng (S11)
  Widget _buildSearchResultsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
          child: Text(
            'Kết quả tìm kiếm (${_searchResults.length})',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: MovieGrid(
            movies: _searchResults,
            isLoading: _isLoading,
            showCategory: true,
            emptyTitle: 'Không tìm thấy phim phù hợp',
            emptyMessage:
                'Hãy thử tìm kiếm với tên phim, đạo diễn hoặc thể loại khác.',
          ),
        ),
      ],
    );
  }
}
