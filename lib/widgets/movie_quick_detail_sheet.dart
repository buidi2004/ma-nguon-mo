import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/movie_model.dart';
import '../services/library_service.dart';
import '../services/theme_service.dart';
import '../theme/app_theme.dart';

/// Modal Bottom Sheet dạng 2 tầng kéo thả mượt mà theo phong cách Netflix (S09 - Hero Quick Glance).
///
/// Hỗ trợ 2 nấc snapping:
/// - Nấc 1 (Collapsed ~44%): Xem nhanh ảnh thu nhỏ, tiêu đề, nhãn chất lượng, nút Phát,
///   và cụm nút chức năng (Danh sách, Thích, Chia sẻ, Chi tiết).
/// - Nấc 2 (Expanded ~92%): Kéo vuốt lên để xem tóm tắt trọn vẹn, đạo diễn, diễn viên,
///   phim liên quan ("Nội dung tương tự") và nút điều hướng sang trang chi tiết đầy đủ.
class MovieQuickDetailSheet extends StatefulWidget {
  final MovieModel movie;
  final List<MovieModel> similarMovies;
  final void Function(MovieModel movie) onPlay;
  final void Function(MovieModel movie) onWatchTrailer;
  final void Function(MovieModel movie) onOpenFullDetail;

  const MovieQuickDetailSheet({
    super.key,
    required this.movie,
    this.similarMovies = const [],
    required this.onPlay,
    required this.onWatchTrailer,
    required this.onOpenFullDetail,
  });

  /// Hàm tiện ích tĩnh mở Bottom Sheet
  static Future<void> show({
    required BuildContext context,
    required MovieModel movie,
    List<MovieModel> similarMovies = const [],
    required void Function(MovieModel movie) onPlay,
    required void Function(MovieModel movie) onWatchTrailer,
    required void Function(MovieModel movie) onOpenFullDetail,
  }) {
    return showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (modalContext) => MovieQuickDetailSheet(
        movie: movie,
        similarMovies: similarMovies,
        onPlay: onPlay,
        onWatchTrailer: onWatchTrailer,
        onOpenFullDetail: onOpenFullDetail,
      ),
    );
  }

  @override
  State<MovieQuickDetailSheet> createState() => _MovieQuickDetailSheetState();
}

class _MovieQuickDetailSheetState extends State<MovieQuickDetailSheet> {
  bool _isExpanded = false;

  void _onNotification(DraggableScrollableNotification notification) {
    final isNowExpanded = notification.extent > 0.65;
    if (isNowExpanded != _isExpanded) {
      _isExpanded = isNowExpanded;
      HapticFeedback.selectionClick();
    }
  }

  void _handleShare(BuildContext context) {
    HapticFeedback.lightImpact();
    Clipboard.setData(
      ClipboardData(text: 'https://openflix.vn/movie/${widget.movie.id}'),
    );
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã sao chép liên kết "${widget.movie.title}"!'),
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.surface,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final movie = widget.movie;
    final bool isTrailer = movie.comingSoon || movie.durationMinutes <= 5;
    final primaryColor = ThemeService.instance.primaryColor;

    return NotificationListener<DraggableScrollableNotification>(
      onNotification: (notification) {
        _onNotification(notification);
        return false;
      },
      child: DraggableScrollableSheet(
        initialChildSize: 0.50,
        minChildSize: 0.25,
        maxChildSize: 0.94,
        snap: true,
        snapSizes: [0.50, 0.94],
        snapAnimationDuration: Duration(milliseconds: 240),
        builder: (sheetContext, scrollController) {
          final bottomInset =
              MediaQuery.paddingOf(sheetContext).bottom + 16.0;

          return Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 16,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: CustomScrollView(
              controller: scrollController,
              cacheExtent: 400.0,
              physics: const ClampingScrollPhysics(),
              slivers: [
                // 1. Thanh kéo đỉnh chuẩn Netflix (Tinh giản, đối xứng, không nút X thừa)
                SliverToBoxAdapter(
                  child: Center(
                    child: Container(
                      width: 40,
                      height: 4.5,
                      margin: const EdgeInsets.only(top: 10, bottom: 14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.28),
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                  ),
                ),

                // 2. Nội dung tầng 1 (Quick Header + Thông tin cơ bản)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Hàng poster + tiêu đề + metadata
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: CachedNetworkImage(
                                imageUrl: movie.posterUrl,
                                width: 84,
                                height: 124,
                                fit: BoxFit.cover,
                                memCacheWidth: 252,
                                memCacheHeight: 372,
                                maxHeightDiskCache: 450,
                                placeholder: (_, _) =>
                                    ColoredBox(color: AppColors.surfaceLight),
                                errorWidget: (_, _, _) => Container(
                                  width: 84,
                                  height: 124,
                                  color: AppColors.surfaceLight,
                                  child: Icon(
                                    Icons.movie_outlined,
                                    color: Colors.white30,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    movie.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                      height: 1.25,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 4,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      if (isTrailer)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 5,
                                            vertical: 1.5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: primaryColor,
                                            borderRadius: BorderRadius.circular(
                                              3,
                                            ),
                                          ),
                                          child: Text(
                                            'TRAILER',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ),
                                      Text(
                                        '${movie.releaseYear}',
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 4,
                                          vertical: 1,
                                        ),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: AppColors.textMuted,
                                            width: 0.8,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            3,
                                          ),
                                        ),
                                        child: Text(
                                          'HD',
                                          style: TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      if (movie.durationMinutes > 5)
                                        Text(
                                          '${movie.durationMinutes}p',
                                          style: TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 13,
                                          ),
                                        ),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 4,
                                          vertical: 1,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white12,
                                          borderRadius: BorderRadius.circular(
                                            3,
                                          ),
                                        ),
                                        child: Text(
                                          movie.ageRating,
                                          style: TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    movie.category,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: primaryColor,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    movie.description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
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

                        // Nút chính: Phát / Xem Trailer toàn chiều ngang
                        SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              if (isTrailer) {
                                widget.onWatchTrailer(movie);
                              } else {
                                widget.onPlay(movie);
                              }
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
                        const SizedBox(height: 14),

                        // Cụm 4 nút chức năng nhanh (Chi tiết - DS của tôi - Thích - Chia sẻ)
                        ListenableBuilder(
                          listenable: LibraryService.instance,
                          builder: (context, _) {
                            final isInList = LibraryService.instance.isInMyList(
                              movie.id,
                            );
                            final isLiked = LibraryService.instance.isLiked(
                              movie.id,
                            );

                            return Row(
                              children: [
                                Expanded(
                                  child: _ActionButton(
                                    icon: Icons.info_outline_rounded,
                                    label: 'Chi tiết',
                                    onTap: () {
                                      Navigator.pop(context);
                                      widget.onOpenFullDetail(movie);
                                    },
                                  ),
                                ),
                                Expanded(
                                  child: _ActionButton(
                                    icon: isInList
                                        ? Icons.check_rounded
                                        : Icons.add_rounded,
                                    iconColor: isInList
                                        ? primaryColor
                                        : Colors.white,
                                    label: isInList ? 'Đã thêm' : 'Danh sách',
                                    onTap: () {
                                      HapticFeedback.lightImpact();
                                      LibraryService.instance.toggleMyList(
                                        movie.id,
                                      );
                                    },
                                  ),
                                ),
                                Expanded(
                                  child: _ActionButton(
                                    icon: isLiked
                                        ? Icons.thumb_up_alt_rounded
                                        : Icons.thumb_up_off_alt_rounded,
                                    iconColor: isLiked
                                        ? primaryColor
                                        : Colors.white,
                                    label: isLiked ? 'Đã thích' : 'Thích',
                                    onTap: () {
                                      HapticFeedback.lightImpact();
                                      LibraryService.instance.toggleLike(
                                        movie.id,
                                      );
                                    },
                                  ),
                                ),
                                Expanded(
                                  child: _ActionButton(
                                    icon: Icons.share_outlined,
                                    label: 'Chia sẻ',
                                    onTap: () => _handleShare(context),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        SizedBox(height: 12),

                        // Gợi ý kéo lên (Affordance trực quan)
                        Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.keyboard_arrow_up_rounded,
                                  size: 16,
                                  color: AppColors.textMuted,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Kéo lên để xem đầy đủ & phim tương tự',
                                  style: TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 3. Đường phân cách tầng mở rộng
                SliverToBoxAdapter(
                  child: Container(
                    height: 1,
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),

                // 4. Nội dung tầng 2 (Tóm tắt trọn vẹn + Đạo diễn / Diễn viên)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tóm tắt nội dung',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          movie.description.trim().isNotEmpty
                              ? movie.description
                              : 'Chưa có mô tả chi tiết cho phim này.',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            height: 1.45,
                          ),
                        ),
                        SizedBox(height: 14),
                        Text.rich(
                          TextSpan(
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              height: 1.4,
                            ),
                            children: [
                              TextSpan(
                                text: 'Đạo diễn: ',
                                style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              TextSpan(text: '${movie.director}\n'),
                              TextSpan(
                                text: 'Diễn viên: ',
                                style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              TextSpan(text: movie.cast),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Nút lớn dẫn thẳng vào trang chi tiết đầy đủ
                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              widget.onOpenFullDetail(movie);
                            },
                            icon: const Icon(
                              Icons.open_in_new_rounded,
                              size: 18,
                            ),
                            label: const Text(
                              'Mở toàn trang chi tiết phim',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: BorderSide(
                                color: Colors.white.withValues(alpha: 0.25),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 22),

                        // Tiêu đề khối phim tương tự
                        if (widget.similarMovies.isNotEmpty) ...[
                          Text(
                            'Nội dung tương tự',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ],
                    ),
                  ),
                ),

                // 5. Khối phim tương tự dạng Grid (nếu có)
                if (widget.similarMovies.isNotEmpty)
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, bottomInset),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            childAspectRatio: 2 / 3,
                          ),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final item = widget.similarMovies[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            widget.onOpenFullDetail(item);
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: CachedNetworkImage(
                              imageUrl: item.posterUrl,
                              fit: BoxFit.cover,
                              memCacheWidth: 200,
                              memCacheHeight: 300,
                              placeholder: (_, _) =>
                                  ColoredBox(color: AppColors.surfaceLight),
                              errorWidget: (_, _, _) => Container(
                                color: AppColors.surfaceLight,
                                child: const Center(
                                  child: Icon(
                                    Icons.movie_outlined,
                                    color: Colors.white24,
                                    size: 28,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }, childCount: widget.similarMovies.length.clamp(0, 9)),
                    ),
                  )
                else
                  SliverToBoxAdapter(child: SizedBox(height: bottomInset)),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Nút hành động biểu tượng nhỏ phong cách Netflix
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.iconColor = Colors.white,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 22),
            SizedBox(height: 5),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
