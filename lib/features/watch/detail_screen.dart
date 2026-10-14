import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/movie_model.dart';
import '../../presentation/widgets/glass/glass_components.dart';
import '../../services/library_service.dart';
import '../../services/pocketbase_service.dart';
import '../../theme/app_theme.dart';

class DetailScreen extends StatefulWidget {
  final String movieId;

  const DetailScreen({super.key, required this.movieId});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final PocketBaseService _pbService = PocketBaseService.instance;
  MovieModel? _movie;
  List<MovieModel> _similarMovies = [];
  bool _isLoading = true;
  bool _isLiked = false;
  bool _isBookmarked = false;

  @override
  void initState() {
    super.initState();
    _loadMovie();
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
      final all = await _pbService.getMovies();
      final similar = all
          .where((m) => m.id != movie.id && m.category == movie.category)
          .toList();
      if (!mounted) return;
      setState(() {
        _movie = movie;
        _similarMovies = similar.isNotEmpty
            ? similar
            : all.where((m) => m.id != movie.id).toList();
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
    context.push('/watch/${movie.id}');
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.red),
          ),
        ),
      );
    }

    if (_movie == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(leading: const BackButton()),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 56,
                color: AppColors.textMuted,
              ),
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
      );
    }

    final movie = _movie!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // App bar đè lên hình ảnh xem trước
          SliverAppBar(
            pinned: true,
            expandedHeight: 260,
            backgroundColor: AppColors.background,
            leading: Center(
              child: GlassIconButton.circle(
                size: 38,
                iconSize: 20,
                icon: Icons.arrow_back,
                onPressed: () => context.pop(),
              ),
            ),
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
                        const SnackBar(
                          content: Text('Đã sao chép liên kết chia sẻ phim!'),
                          backgroundColor: AppColors.red,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'movie_poster_${movie.id}',
                    child: CachedNetworkImage(
                      imageUrl: movie.posterUrl,
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                      memCacheWidth: 720,
                      maxHeightDiskCache: 1080,
                      placeholder: (_, _) =>
                          const ColoredBox(color: AppColors.surface),
                    ),
                  ),
                  // Nút Play tròn lớn ở giữa khung xem trước
                  Center(
                    child: GestureDetector(
                      onTap: () => _playMovie(movie),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                  // Gradient chân ảnh
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.6, 1.0],
                          colors: [Colors.transparent, AppColors.background],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Nội dung chi tiết phim
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tên phim
                  Text(
                    movie.title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Metadata badges
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
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
                          horizontal: 5,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Text(
                          movie.ageRating,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${movie.durationMinutes} phút',
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
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Hàng nút Phát và Trailer
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: GlassButton.primary(
                          text: 'Phát',
                          icon: Icons.play_arrow_rounded,
                          borderRadius: 12,
                          height: 46,
                          onPressed: () => _playMovie(movie),
                        ),
                      ),
                      const SizedBox(width: 10),
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
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Mô tả phim
                  Text(
                    movie.description,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      height: 1.45,
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Đạo diễn & Diễn viên
                  Text(
                    'Đạo diễn: ${movie.director}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Diễn viên: ${movie.cast}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12.5,
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
                          await LibraryService.instance.toggleMyList(movie.id);
                          setState(() {
                            _isBookmarked = LibraryService.instance.isInMyList(
                              movie.id,
                            );
                          });
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  _isBookmarked
                                      ? 'Đã thêm "${movie.title}" vào Danh sách của tôi'
                                      : 'Đã xóa khỏi Danh sách của tôi',
                                ),
                                backgroundColor: AppColors.red,
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
                        icon: Icons.video_library_outlined,
                        label: 'Tập phim',
                        onTap: () =>
                            context.push('/movie/${movie.id}/episodes'),
                      ),
                      _buildActionButton(
                        icon: Icons.rate_review_outlined,
                        label: 'Đánh giá',
                        onTap: () => context.push('/movie/${movie.id}/reviews'),
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
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        TextButton(
                          onPressed: () =>
                              context.push('/movie/${movie.id}/similar'),
                          child: const Text(
                            'Xem tất cả >',
                            style: TextStyle(
                              color: AppColors.red,
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

          // Lưới 3 cột phim tương tự — Lazy evaluation qua Sliver, loại bỏ hoàn toàn shrinkWrap
          if (_similarMovies.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 24, 16, 48),
                child: Center(
                  child: Text(
                    'Không có phim tương tự nào',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 2 / 3,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final sim = _similarMovies[index];
                  return GestureDetector(
                    onTap: () {
                      context.pushReplacement('/movie/${sim.id}');
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: CachedNetworkImage(
                        imageUrl: sim.posterUrl,
                        fit: BoxFit.cover,
                        memCacheWidth: 350,
                        memCacheHeight: 525,
                        maxHeightDiskCache: 600,
                        placeholder: (_, _) =>
                            const ColoredBox(color: AppColors.surface),
                        errorWidget: (_, _, _) => Container(
                          color: AppColors.surface,
                          padding: const EdgeInsets.all(4),
                          child: Center(
                            child: Text(
                              sim.title,
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }, childCount: _similarMovies.length),
              ),
            ),
        ],
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
          iconColor: isActive ? AppColors.red : Colors.white,
          hasGlow: isActive,
          glowColor: AppColors.red,
          onPressed: onTap,
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: isActive ? AppColors.red : AppColors.textSecondary,
            fontSize: 11.5,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
