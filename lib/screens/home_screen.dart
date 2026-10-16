import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../models/movie_model.dart';
import '../presentation/widgets/glass/glass_components.dart';
import '../services/library_service.dart';
import '../services/pocketbase_service.dart';
import '../services/trial_promo_service.dart';
import '../theme/app_theme.dart';
import '../widgets/hero_banner.dart';
import '../widgets/movie_row.dart';
import '../widgets/top10_row.dart';

class HomeScreen extends StatefulWidget {
  final bool enableTrialPromo;

  const HomeScreen({
    super.key,
    this.enableTrialPromo = true,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PocketBaseService _pbService = PocketBaseService.instance;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _homeScrollController = ScrollController();
  final ValueNotifier<double> _appBarOpacityNotifier = ValueNotifier<double>(
    0.0,
  );
  Timer? _searchDebounceTimer;
  Timer? _trialPromoTimer;

  List<MovieModel> _allMovies = [];
  List<MovieModel> _filteredMovies = [];
  List<MovieModel> _featuredMovies = [];
  List<MovieModel> _top10Movies = [];
  List<MovieModel> _newReleases = [];
  List<MovieModel> _animatedMovies = [];
  List<MovieModel> _sciFiMovies = [];
  List<MovieModel> _actionMovies = [];
  List<String> _categories = const ['Tất cả'];
  late bool _isLoading;
  bool _isSearching = false;
  String _selectedCategory = 'Tất cả';

  @override
  void initState() {
    super.initState();
    _isLoading = !_pbService.hasCachedMovies;
    _homeScrollController.addListener(_onHomeScroll);
    _loadData();
    _scheduleTrialPromo();
  }

  void _scheduleTrialPromo() {
    if (!widget.enableTrialPromo) return;
    _trialPromoTimer?.cancel();
    _trialPromoTimer = Timer(const Duration(milliseconds: 650), () async {
      if (!mounted) return;
      final shouldShow = await TrialPromoService.instance.shouldShowPromo();
      if (!mounted || !shouldShow) return;

      GlassTrialPromoModal.show(
        context,
        onSubscribe: () {
          TrialPromoService.instance.markDismissed();
          try {
            context.push('/plans');
          } catch (_) {
            try {
              context.go('/plans');
            } catch (_) {}
          }
        },
        onDismiss: () {
          TrialPromoService.instance.markDismissed();
        },
      );
    });
  }

  void _onHomeScroll() {
    if (!_homeScrollController.hasClients) return;
    final offset = _homeScrollController.offset;
    final newOpacity = (offset / 140.0).clamp(0.0, 1.0);
    if ((newOpacity - _appBarOpacityNotifier.value).abs() > 0.01) {
      _appBarOpacityNotifier.value = newOpacity;
    }
  }

  @override
  void dispose() {
    _trialPromoTimer?.cancel();
    _searchDebounceTimer?.cancel();
    _homeScrollController.removeListener(_onHomeScroll);
    _homeScrollController.dispose();
    _searchController.dispose();
    _appBarOpacityNotifier.dispose();
    super.dispose();
  }


  Future<void> _loadData() async {
    // Chỉ kích hoạt cờ loading khi chưa có dữ liệu trong RAM cache
    if (!_pbService.hasCachedMovies) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final movies = await _pbService.getMovies();
      final featured = movies.where((m) => m.isFeatured).toList();

      if (!mounted) return;

      final catSet = {'Tất cả'};
      for (var m in movies) {
        if (m.category.isNotEmpty) catSet.add(m.category);
      }

      final top10 = await _pbService.getTop10Movies();
      final top10Ids = top10.map((m) => m.id).toSet();
      final newReleases = movies
          .where((m) => m.isNew && !top10Ids.take(5).contains(m.id))
          .toList();
      for (final m in movies) {
        if (newReleases.length >= 10) break;
        if (!top10Ids.contains(m.id) && !newReleases.any((e) => e.id == m.id)) {
          newReleases.add(m);
        }
      }

      setState(() {
        _allMovies = movies;
        _filteredMovies = movies;
        _categories = catSet.toList();
        // Hero carousel: Ưu tiên phim nổi bật (featured) VÀ các trailer hot (< 5 phút / sắp chiếu)
        final heroList = <MovieModel>[];
        for (final m in featured) {
          if (!heroList.any((e) => e.id == m.id)) {
            heroList.add(m);
          }
        }
        final trailers = movies
            .where((m) => m.comingSoon || m.durationMinutes <= 5)
            .toList();
        for (final m in trailers) {
          if (heroList.length >= 8) break;
          if (!heroList.any((e) => e.id == m.id)) {
            heroList.add(m);
          }
        }
        for (final m in movies) {
          if (heroList.length >= 8) break;
          if (!heroList.any((e) => e.id == m.id)) {
            heroList.add(m);
          }
        }
        _featuredMovies = heroList;
        _top10Movies = top10;
        _newReleases = newReleases.isNotEmpty ? newReleases : movies;
        _animatedMovies = movies
            .where((m) => m.category.toLowerCase().contains('hoạt'))
            .toList();
        _sciFiMovies = movies
            .where((m) => m.category.toLowerCase().contains('viễn'))
            .toList();
        _actionMovies = movies
            .where(
              (m) =>
                  m.category.toLowerCase().contains('hành') ||
                  m.category.toLowerCase().contains('phiêu'),
            )
            .toList();
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String query, {bool immediate = false}) {
    _searchDebounceTimer?.cancel();
    final trimmed = query.trim().toLowerCase();

    void executeFilter() {
      if (!mounted) return;
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
                _selectedCategory == 'Tất cả' ||
                m.category == _selectedCategory;
            return matchesQuery && matchesCategory;
          }).toList();
        }
      });
    }

    if (immediate) {
      executeFilter();
    } else {
      _searchDebounceTimer = Timer(
        const Duration(milliseconds: 280),
        executeFilter,
      );
    }
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
      _onSearchChanged(_searchController.text, immediate: true);
    });
  }

  void _playMovie(MovieModel movie) {
    context.push('/watch/${movie.id}');
  }

  void _openMovieDetail(MovieModel movie) {
    context.push('/movie/${movie.id}');
  }

  /// Netflix-style Quick Details Bottom Sheet
  void _showMovieDetailModal(MovieModel movie) {
    final bool isTrailer = movie.comingSoon || movie.durationMinutes <= 5;

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (modalContext) {
        final double bottomInset =
            MediaQuery.of(modalContext).padding.bottom + 16.0;

        return SafeArea(
          top: false,
          bottom: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, bottomInset),
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
                        width: 80,
                        height: 120,
                        fit: BoxFit.cover,
                        memCacheWidth: 240,
                        memCacheHeight: 360,
                        maxHeightDiskCache: 450,
                        placeholder: (_, _) =>
                            const ColoredBox(color: AppColors.surfaceLight),
                        errorWidget: (_, _, _) => Container(
                          width: 80,
                          height: 120,
                          color: AppColors.surfaceLight,
                          child: const Icon(
                            Icons.movie_outlined,
                            color: Colors.white30,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            movie.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if (isTrailer) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 5,
                                    vertical: 1.5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.red,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: const Text(
                                    'TRAILER',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
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
                              Flexible(
                                child: Text(
                                  movie.category,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13,
                                  ),
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
                const SizedBox(height: 18),
                // Nút Phát / Xem Trailer toàn chiều ngang
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(modalContext);
                      _playMovie(movie);
                    },
                    icon: Icon(
                      isTrailer
                          ? Icons.play_circle_fill_rounded
                          : Icons.play_arrow_rounded,
                      color: Colors.black,
                      size: 24,
                    ),
                    label: Text(
                      isTrailer ? 'Xem Trailer' : 'Phát',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
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
                            ? AppColors.warning
                            : AppColors.success,
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
    ).then((_) {
      urlController.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isFilteringCategory = _selectedCategory != 'Tất cả';
    return Scaffold(
      backgroundColor: AppColors.background,
      // Luôn trải dài toàn màn hình để dải hòa trộn 150px hoạt động liên tục
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: (isFilteringCategory && !_isSearching) ? 0 : 12,
        leading: (isFilteringCategory && !_isSearching)
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 19,
                  color: Colors.white,
                ),
                tooltip: 'Về trang chủ',
                onPressed: () => _onCategorySelected('Tất cả'),
              )
            : null,
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
            : isFilteringCategory
            ? Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedCategory,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.red.withValues(alpha: 0.20),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.red.withValues(alpha: 0.50),
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      '${_filteredMovies.length} phim',
                      style: const TextStyle(
                        color: AppColors.red,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              )
            : const Row(
                children: [
                  // OpenFlix Red Wordmark chuẩn Netflix
                  Text(
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
          if (isFilteringCategory && !_isSearching)
            IconButton(
              icon: const Icon(
                Icons.refresh_rounded,
                color: Colors.white70,
                size: 22,
              ),
              tooltip: 'Xem tất cả phim',
              onPressed: () => _onCategorySelected('Tất cả'),
            ),
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
                  ? AppColors.warning
                  : AppColors.success,
              size: 22,
            ),
            tooltip: 'Kết nối máy chủ',
            onPressed: _openServerConfigDialog,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _isLoading
          ? _buildSkeleton()
          : Stack(
              children: [
                RefreshIndicator(
                  onRefresh: _loadData,
                  color: AppColors.red,
                  backgroundColor: AppColors.surface,
                  child: _buildBody(),
                ),
                // Dãy hòa trộn quang học đỉnh (150px): Triệt tiêu hoàn toàn đường cắt ngang
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 150,
                  child: IgnorePointer(
                    child: ValueListenableBuilder<double>(
                      valueListenable: _appBarOpacityNotifier,
                      builder: (context, opacity, child) {
                        return AnimatedOpacity(
                          opacity: (_isSearching || isFilteringCategory)
                              ? 1.0
                              : opacity,
                          duration: const Duration(milliseconds: 180),
                          curve: Curves.easeOutCubic,
                          child: child,
                        );
                      },
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppColors.background,
                              AppColors.background.withValues(alpha: 0.94),
                              AppColors.background.withValues(alpha: 0.65),
                              AppColors.background.withValues(alpha: 0.25),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.40, 0.65, 0.85, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
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
      controller: _homeScrollController,
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Hero Banner carousel (nhiều phim nổi bật, autoplay lazy)
          if (_featuredMovies.isNotEmpty)
            HeroBannerCarousel(
              movies: _featuredMovies,
              onPlay: _playMovie,
              onInfo: _showMovieDetailModal,
              onImageTap: (movie) => context.push('/trailer/${movie.id}'),
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

          // 4. Hàng Top 10 Phim Thịnh Hành (S17) — số xám to sau poster
          Top10Row(
            title: 'Top 10 Phim Thịnh Hành',
            movies: _top10Movies,
            onTap: _openMovieDetail,
            onSeeAll: () => context.push('/top10'),
          ),

          // 5. Các hàng phim cuộn ngang chuẩn Netflix 3.4 peek ratio
          MovieRow(
            title: 'Mới phát hành trên OpenFlix',
            movies: _newReleases.isNotEmpty ? _newReleases : _allMovies,
            onTap: _openMovieDetail,
            onSeeAll: () => context.push('/see-all/new'),
          ),

          MovieRow(
            title: 'Hoạt hình đặc sắc',
            movies: _animatedMovies,
            onTap: _openMovieDetail,
            onSeeAll: () => context.push('/genre/Hoạt hình'),
          ),

          MovieRow(
            title: 'Khoa học viễn tưởng',
            movies: _sciFiMovies,
            onTap: _openMovieDetail,
            onSeeAll: () => context.push('/genre/Viễn tưởng'),
          ),

          MovieRow(
            title: 'Hành động & Phiêu lưu',
            movies: _actionMovies,
            onTap: _openMovieDetail,
            onSeeAll: () => context.push('/genre/Hành động'),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  /// Chip lọc danh mục phong cách kính mờ quang học nhẹ nhàng (GlassChipButton)
  Widget _buildCategoryFilterRow() {
    return Container(
      height: 38,
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
          return GlassChipButton(
            label: cat,
            isSelected: isSelected,
            height: 34.0,
            activeColor: AppColors.red,
            showCheckmark: false,
            onSelected: (_) => _onCategorySelected(cat),
          );
        },
      ),
    );
  }

  /// Màn hình chờ Skeleton Shimmer chuẩn rạp chiếu Netflix (AGENTS.md Mục 6)
  Widget _buildSkeleton() {
    final screenSize = MediaQuery.sizeOf(context);
    final heroHeight = (screenSize.height * 0.55).clamp(380.0, 560.0);
    final posterWidth = (screenSize.width / 3.4).clamp(90.0, 130.0);
    final posterHeight = posterWidth * 1.5;

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      child: Shimmer.fromColors(
        baseColor: const Color(0xFF1E1E1E),
        highlightColor: const Color(0xFF2C2C2C),
        period: const Duration(milliseconds: 1300),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Khung Hero banner skeleton
            Container(
              height: heroHeight,
              width: double.infinity,
              color: Colors.white,
            ),
            const SizedBox(height: 12),

            // 2. Khung các chip lọc thể loại
            SizedBox(
              height: 34,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                itemCount: 6,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, index) => Container(
                  width: (index == 0) ? 64 : (index.isEven ? 82 : 72),
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // 3. Khung 2 hàng poster phim
            for (int r = 0; r < 2; r++) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                child: Container(
                  width: r == 0 ? 170 : 130,
                  height: 18,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              SizedBox(
                height: posterHeight,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  itemCount: 4,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (_, _) => Container(
                    width: posterWidth,
                    height: posterHeight,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }

  /// Lưới 3 cột poster khi tìm kiếm hoặc lọc danh mục chuẩn điện ảnh Netflix
  Widget _buildSearchOrFilterGrid() {
    final topOffset = MediaQuery.of(context).padding.top + kToolbarHeight + 4;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: topOffset),
        _buildCategoryFilterRow(),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 6, 14, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Danh sách ${_selectedCategory != 'Tất cả' ? _selectedCategory : 'kết quả'} (${_filteredMovies.length} phim)',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (_selectedCategory != 'Tất cả')
                GestureDetector(
                  onTap: () => _onCategorySelected('Tất cả'),
                  child: const Text(
                    'Xem tất cả >',
                    style: TextStyle(
                      color: AppColors.red,
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: _filteredMovies.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off_rounded,
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
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 110),
                  itemCount: _filteredMovies.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 2 / 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 10,
                  ),
                  itemBuilder: (context, index) {
                    final movie = _filteredMovies[index];
                    return GestureDetector(
                      onTap: () => _openMovieDetail(movie),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.40),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              // 1. Ảnh Poster
                              CachedNetworkImage(
                                imageUrl: movie.posterUrl,
                                fit: BoxFit.cover,
                                memCacheWidth: 350,
                                memCacheHeight: 525,
                                maxHeightDiskCache: 600,
                                placeholder: (_, _) => Container(
                                  color: AppColors.surface,
                                  child: const Center(
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              AppColors.red,
                                            ),
                                      ),
                                    ),
                                  ),
                                ),
                                errorWidget: (_, _, _) => Container(
                                  color: AppColors.surface,
                                  padding: const EdgeInsets.all(6),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.movie_outlined,
                                        color: AppColors.textMuted,
                                        size: 24,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        movie.title,
                                        maxLines: 2,
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // 2. Lớp phủ Vignette chuyển tiếp tinh tế ở đáy poster
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.transparent,
                                        Colors.black.withValues(alpha: 0.50),
                                        Colors.black.withValues(alpha: 0.92),
                                      ],
                                      stops: const [0.0, 0.45, 0.70, 1.0],
                                    ),
                                  ),
                                ),
                              ),

                              // 3. Viền Hairline tinh xảo
                              Positioned.fill(
                                child: IgnorePointer(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.white.withValues(
                                          alpha: 0.14,
                                        ),
                                        width: 0.8,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // 4. Badge chất lượng (HD / MỚI)
                              Positioned(
                                top: 5,
                                right: 5,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 5,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: movie.isNew
                                        ? AppColors.red
                                        : Colors.black.withValues(alpha: 0.65),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.25,
                                      ),
                                      width: 0.6,
                                    ),
                                  ),
                                  child: Text(
                                    movie.isNew ? 'MỚI' : 'HD',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                ),
                              ),

                              // 5. Tiêu đề và Năm phát hành ở đáy poster
                              Positioned(
                                left: 6,
                                right: 6,
                                bottom: 8,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      movie.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        height: 1.2,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black,
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${movie.releaseYear}',
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.70,
                                        ),
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
