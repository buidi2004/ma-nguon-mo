import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/movie_model.dart';
import '../../presentation/widgets/glass/glass_components.dart';
import '../../services/auth_guard.dart';
import '../../services/library_service.dart';
import '../../services/pocketbase_service.dart';
import '../../services/theme_service.dart';
import '../../theme/app_theme.dart';
import '../../waves_background.dart';

class DetailScreen extends StatefulWidget {
  final String movieId;
  final MovieModel? initialMovie;

  const DetailScreen({super.key, required this.movieId, this.initialMovie});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final PocketBaseService _pbService = PocketBaseService.instance;
  MovieModel? _movie;
  bool _isLoading = true;
  bool _isLiked = false;
  bool _isBookmarked = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialMovie != null) {
      _movie = widget.initialMovie;
      _isLoading = false;
      _isBookmarked = LibraryService.instance.isInMyList(
        widget.initialMovie!.id,
      );
      _isLiked = LibraryService.instance.isLiked(widget.initialMovie!.id);
    } else {
      _loadMovie();
    }
  }

  @override
  void didUpdateWidget(covariant DetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.movieId != widget.movieId) {
      _loadMovie();
    }
  }

  Future<void> _loadMovie() async {
    setState(() => _isLoading = true);
    final movie = await _pbService.getMovieById(widget.movieId);
    if (movie != null) {
      if (!mounted) return;
      setState(() {
        _movie = movie;
        _isBookmarked = LibraryService.instance.isInMyList(movie.id);
        _isLiked = LibraryService.instance.isLiked(movie.id);
        _isLoading = false;
      });
    } else {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  void _playMovie(MovieModel movie) {
    AuthGuard.runWithAuth(
      context,
      movieId: movie.id,
      movieTitle: movie.title,
      hasTrailer: true,
      onWatchTrailer: () => context.push('/movie/${movie.id}/trailer'),
      onAuthorized: () => context.push('/watch/${movie.id}'),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return WavesBackground.wrapIfBlue(
        Scaffold(
          backgroundColor: AppColors.background,
          body: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                ThemeService.instance.primaryColor,
              ),
            ),
          ),
        ),
      );
    }

    if (_movie == null) {
      return WavesBackground.wrapIfBlue(
        Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(leading: const GlassBackButton(fallbackRoute: '/')),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 56, color: AppColors.textMuted),
                const SizedBox(height: 12),
                const Text(
                  'Không tìm thấy thông tin bộ phim',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.surface,
                  ),
                  child: const Text('Quay lại'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final movie = _movie!;

    return WavesBackground.wrapIfBlue(
      Scaffold(
        backgroundColor: AppColors.background,
        body: CustomScrollView(
          cacheExtent: 500.0,
          physics: const BouncingScrollPhysics(),
          slivers: [
            // App bar đè lên hình ảnh xem trước
            SliverAppBar(
              pinned: true,
              expandedHeight: 260,
              backgroundColor: AppColors.background,
              leading: const GlassBackButton(fallbackRoute: '/'),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Center(
                    child: GlassIconButton.circle(
                      size: 38,
                      iconSize: 20,
                      icon: Icons.share_outlined,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              'Đã sao chép liên kết chia sẻ phim!',
                            ),
                            backgroundColor: ThemeService.instance.primaryColor,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                // RepaintBoundary: SliverAppBar chỉ thay đổi transform khi cuộn
                // (parallax + collapse), nên ảnh poster + ShaderMask + gradient
                // được raster một lần và tái sử dụng, thay vì vẽ lại mỗi frame.
                background: RepaintBoundary(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Ảnh poster phim điện ảnh sắc nét, hòa tan quang học ở chân
                      Hero(
                        tag: 'movie_poster_${movie.id}',
                        child: GestureDetector(
                          onTap: () => _playMovie(movie),
                          child: ShaderMask(
                            shaderCallback: (bounds) {
                              return const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                stops: [0.0, 0.45, 0.70, 0.88, 1.0],
                                colors: [
                                  Colors.white,
                                  Colors.white,
                                  Color(0xCCFFFFFF),
                                  Color(0x33FFFFFF),
                                  Colors.transparent,
                                ],
                              ).createShader(bounds);
                            },
                            blendMode: BlendMode.dstIn,
                            child: CachedNetworkImage(
                              imageUrl: movie.posterUrl,
                              fit: BoxFit.cover,
                              alignment: Alignment.topCenter,
                              memCacheWidth: 720,
                              maxHeightDiskCache: 1080,
                              placeholder: (_, _) =>
                                  ColoredBox(color: AppColors.surface),
                            ),
                          ),
                        ),
                      ),
                      // Gradient chân ảnh: hòa trộn quang học đa tầng (Multi-stop Oceanic Blend)
                      Positioned.fill(
                        child: IgnorePointer(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                stops: const [0.35, 0.58, 0.78, 0.90, 1.0],
                                colors: ThemeService.instance.isWindowsBlue
                                    ? const [
                                        Colors.transparent,
                                        Color(0x2E011420),
                                        Color(0x8A021826),
                                        Color(0x66031C26),
                                        Colors.transparent,
                                      ]
                                    : [
                                        Colors.transparent,
                                        AppColors.dynamicBackground.withValues(
                                          alpha: 0.25,
                                        ),
                                        AppColors.dynamicBackground.withValues(
                                          alpha: 0.65,
                                        ),
                                        AppColors.dynamicBackground.withValues(
                                          alpha: 0.92,
                                        ),
                                        AppColors.dynamicBackground,
                                      ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Nội dung chi tiết phim
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tên phim
                    Text(
                      movie.title,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 8),

                    // Metadata badges
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          '${movie.releaseYear}',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        GlassSpecBadge.age(rating: movie.ageRating),
                        Text(
                          '${movie.durationMinutes} phút',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        GlassSpecBadge.uhd4k(),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Hàng nút Phát, Trailer và Đặt Vé Rạp
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: GlassShimmerCTA.play(
                            label: 'Phát',
                            icon: Icons.play_arrow_rounded,
                            height: 46,
                            onPressed: () => _playMovie(movie),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: GlassButton.neutral(
                            text: 'Trailer',
                            icon: Icons.play_circle_outline,
                            borderRadius: 12,
                            height: 46,
                            onPressed: () =>
                                context.push('/movie/${movie.id}/trailer'),
                          ),
                        ),
                        SizedBox(width: 8),
                        GlassIconButton(
                          icon: Icons.confirmation_num_rounded,
                          tooltip: 'Đặt vé rạp',
                          size: 46,
                          onPressed: () => context.push('/cinema'),
                        ),
                      ],
                    ),

                    SizedBox(height: 14),

                    // Mô tả phim
                    Text(
                      movie.description,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        height: 1.45,
                      ),
                    ),

                    SizedBox(height: 14),

                    // Đạo diễn & Diễn viên
                    Text(
                      'Đạo diễn: ${movie.director}',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Diễn viên: ${movie.cast}',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Hàng nút hành động: Danh sách, Thích, Tập phim, Đánh giá
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildActionButton(
                          icon: _isBookmarked ? Icons.check : Icons.add,
                          label: 'Danh sách',
                          isActive: _isBookmarked,
                          onTap: () async {
                            await LibraryService.instance.toggleMyList(
                              movie.id,
                            );
                            setState(() {
                              _isBookmarked = LibraryService.instance
                                  .isInMyList(movie.id);
                            });
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    _isBookmarked
                                        ? 'Đã thêm "${movie.title}" vào Danh sách của tôi'
                                        : 'Đã xóa khỏi Danh sách của tôi',
                                  ),
                                  backgroundColor:
                                      ThemeService.instance.primaryColor,
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            }
                          },
                        ),
                        _buildActionButton(
                          icon: _isLiked
                              ? Icons.thumb_up
                              : Icons.thumb_up_alt_outlined,
                          label: 'Thích',
                          isActive: _isLiked,
                          onTap: () async {
                            await LibraryService.instance.toggleLike(movie.id);
                            setState(() {
                              _isLiked = LibraryService.instance.isLiked(
                                movie.id,
                              );
                            });
                          },
                        ),
                        _buildActionButton(
                          icon:
                              (movie.category.toLowerCase().contains('bộ') ||
                                  movie.category.toLowerCase().contains(
                                    'series',
                                  ) ||
                                  movie.category.toLowerCase().contains(
                                    'truyền hình',
                                  ))
                              ? Icons.video_library_outlined
                              : Icons.subtitles_outlined,
                          label:
                              (movie.category.toLowerCase().contains('bộ') ||
                                  movie.category.toLowerCase().contains(
                                    'series',
                                  ) ||
                                  movie.category.toLowerCase().contains(
                                    'truyền hình',
                                  ))
                              ? 'Tập phim'
                              : 'Phụ đề',
                          onTap: () {
                            final isSeries =
                                movie.category.toLowerCase().contains('bộ') ||
                                movie.category.toLowerCase().contains(
                                  'series',
                                ) ||
                                movie.category.toLowerCase().contains(
                                  'truyền hình',
                                );
                            if (isSeries) {
                              context.push('/movie/${movie.id}/episodes');
                            } else {
                              context.push('/movie/${movie.id}/audio');
                            }
                          },
                        ),
                        _buildActionButton(
                          icon: Icons.rate_review_outlined,
                          label: 'Đánh giá',
                          onTap: () =>
                              context.push('/movie/${movie.id}/reviews'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    const Divider(color: Colors.white12),

                    // Header Phim tương tự
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'PHIM TƯƠNG TỰ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                          TextButton(
                            onPressed: () =>
                                context.push('/movie/${movie.id}/similar'),
                            child: Text(
                              'Xem tất cả >',
                              style: TextStyle(
                                color: ThemeService.instance.primaryColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Lưới 3 cột phim tương tự — Sliver tự quản lý vòng đời riêng
            // (tải dữ liệu + setState) nên khi dữ liệu về, trang chi tiết phía
            // trên KHÔNG bị dựng lại toàn bộ.
            _SimilarMoviesSliver(movie: movie),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    bool isActive = false,
    required VoidCallback onTap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GlassIconButton.rounded(
          size: 46,
          iconSize: 22,
          icon: icon,
          iconColor: isActive
              ? ThemeService.instance.primaryColor
              : Colors.white,
          hasGlow: isActive,
          glowColor: ThemeService.instance.primaryColor,
          onPressed: onTap,
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: isActive
                ? ThemeService.instance.primaryColor
                : AppColors.textSecondary,
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// Khối "Phim tương tự" tự tải dữ liệu và tự dựng lưới.
///
/// Trước đây phần này nằm chung State với trang chi tiết, nên mỗi lần danh
/// sách phim tương tự về là `setState` dựng lại toàn bộ Scaffold +
/// CustomScrollView (poster, ShaderMask, ~10 nút kính) đúng lúc transition
/// vừa chạy xong → giật. Tách ra widget riêng thì chỉ lưới này rebuild.
///
/// Việc tải cũng được hoãn tới khi animation chuyển màn kết thúc để không
/// tranh CPU/GPU với chính hiệu ứng chuyển màn và với việc decode poster.
class _SimilarMoviesSliver extends StatefulWidget {
  final MovieModel movie;

  const _SimilarMoviesSliver({required this.movie});

  @override
  State<_SimilarMoviesSliver> createState() => _SimilarMoviesSliverState();
}

class _SimilarMoviesSliverState extends State<_SimilarMoviesSliver> {
  List<MovieModel>? _similarMovies;
  int _requestId = 0;

  @override
  void initState() {
    super.initState();
    _scheduleLoad();
  }

  @override
  void didUpdateWidget(covariant _SimilarMoviesSliver oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.movie.id != widget.movie.id) {
      _similarMovies = null;
      _scheduleLoad();
    }
  }

  void _scheduleLoad() {
    // Không đọc InheritedWidget trong initState → hẹn sang frame kế tiếp.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _load();
    });
  }

  Future<void> _load() async {
    final int requestId = ++_requestId;
    await _waitForRouteTransition();
    if (!mounted || requestId != _requestId) return;

    final all = await PocketBaseService.instance.getMovies();
    if (!mounted || requestId != _requestId) return;

    final movie = widget.movie;
    final matches = all
        .where((m) => m.id != movie.id && m.category == movie.category)
        .toList();

    setState(() {
      _similarMovies = matches.isNotEmpty
          ? matches
          : all.where((m) => m.id != movie.id).toList();
    });
  }

  /// Chờ animation mở màn chạy xong (nếu có) rồi mới tải.
  Future<void> _waitForRouteTransition() async {
    final animation = ModalRoute.of(context)?.animation;
    if (animation == null || animation.isCompleted) return;

    final completer = Completer<void>();
    void listener(AnimationStatus status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        if (!completer.isCompleted) completer.complete();
      }
    }

    animation.addStatusListener(listener);
    try {
      await completer.future;
    } finally {
      animation.removeStatusListener(listener);
    }
  }

  @override
  Widget build(BuildContext context) {
    final movies = _similarMovies;

    // Đang tải: chừa một khoảng trống nhỏ thay vì nhấp nháy chữ "không có".
    if (movies == null) {
      return const SliverToBoxAdapter(child: SizedBox(height: 32));
    }

    if (movies.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 48),
          child: Center(
            child: Text(
              'Không có phim tương tự nào',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 2 / 3,
          crossAxisSpacing: 6,
          mainAxisSpacing: 6,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final sim = movies[index];
          return RepaintBoundary(
            child: GestureDetector(
              onTap: () {
                context.pushReplacement('/movie/${sim.id}', extra: sim);
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: CachedNetworkImage(
                  imageUrl: sim.posterUrl,
                  fit: BoxFit.cover,
                  memCacheWidth: 350,
                  memCacheHeight: 525,
                  maxHeightDiskCache: 600,
                  placeholder: (_, _) => ColoredBox(color: AppColors.surface),
                  errorWidget: (_, _, _) => Container(
                    color: AppColors.surface,
                    padding: const EdgeInsets.all(4),
                    child: Center(
                      child: Text(
                        sim.title,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }, childCount: movies.length),
      ),
    );
  }
}
