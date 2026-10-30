import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/movie_model.dart';
import '../services/theme_service.dart';
import '../theme/app_theme.dart';

/// Hàng Top 10 (S17): số thứ hạng xám to nằm sau, poster 2:3 đè lên nửa phải số.
///
/// Chuyển thể từ mẫu [RankedMovieList] của người dùng sang chuẩn OpenFlix:
/// - Dùng trực tiếp [MovieModel] (không bịa badge: chỉ hiện `MỚI` khi `isNew == true`).
/// - Ảnh dùng [CachedNetworkImage] + memCache + placeholder/error (không `Image.network` trần).
/// - Màu dùng token [AppColors], bo góc 8px, chữ có ellipsis + semantics.
class Top10Row extends StatelessWidget {
  final String title;
  final List<MovieModel> movies;
  final void Function(MovieModel movie) onTap;
  final VoidCallback? onSeeAll;

  const Top10Row({
    super.key,
    this.title = 'Top 10 Phim Thịnh Hành',
    required this.movies,
    required this.onTap,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    if (movies.isEmpty) return const SizedBox.shrink();

    final screenWidth = MediaQuery.sizeOf(context).width;
    final homePalette = Theme.of(context).extension<HomeScreenPalette>();
    // Item Top 10 rộng hơn poster thường (số + poster), nên poster nhỏ hơn
    // một chút để vẫn lộ item kế tiếp gợi ý vuốt.
    final posterWidth = (screenWidth / 4.2).clamp(96.0, 140.0).toDouble();
    final itemHeight = posterWidth * 1.5 + 10;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 20, 12, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: homePalette?.textPrimary ?? AppColors.textPrimary,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (onSeeAll != null) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onSeeAll,
                  child: Text(
                    'Xem tất cả >',
                    style: TextStyle(
                      color:
                          Theme.of(context)
                              .extension<HomeScreenPalette>()
                              ?.action ??
                          ThemeService.instance.primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        SizedBox(
          height: itemHeight,
          child: RepaintBoundary(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              cacheExtent: 450.0,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: movies.length > 10 ? 10 : movies.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final movie = movies[index];
                return Align(
                  alignment: Alignment.topCenter,
                  child: RankedMovieCard(
                    rank: index + 1,
                    movie: movie,
                    posterWidth: posterWidth,
                    onTap: () => onTap(movie),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

/// 1 item: số to màu xám nằm sau, poster đè lên nửa phải của số.
class RankedMovieCard extends StatelessWidget {
  final int rank;
  final MovieModel movie;
  final double posterWidth;
  final VoidCallback? onTap;

  /// Poster tỷ lệ 2:3.
  double get posterHeight => posterWidth * 1.5;

  /// Cỡ chữ của số, tỷ lệ theo chiều cao poster (~65%).
  double get numberFontSize => posterHeight * 0.65;

  const RankedMovieCard({
    super.key,
    required this.rank,
    required this.movie,
    this.posterWidth = 110,
    this.onTap,
  });

  /// Poster bắt đầu từ đâu (tính từ mép trái item).
  /// Số 1 chữ số: poster đè lên ~40% bên phải của số. Số 10+: dịch thêm.
  double get _posterLeft {
    final digits = rank.toString().length;
    return numberFontSize * (0.38 + 0.58 * (digits - 1));
  }

  @override
  Widget build(BuildContext context) {
    final fs = numberFontSize;
    final homePalette = Theme.of(context).extension<HomeScreenPalette>();

    return Semantics(
      button: true,
      label: 'Hạng $rank: ${movie.title}',
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: _posterLeft + posterWidth,
          height: posterHeight + 10,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // 1) SỐ (nằm dưới cùng, căn đáy theo đáy poster)
              Positioned(
                left: 0,
                bottom: 10 - fs * 0.16, // bù descent + chừa khe badge
                child: ExcludeSemantics(
                  child: Text(
                    '$rank',
                    style: TextStyle(
                      fontSize: fs,
                      height: 1,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -fs * 0.04,
                      color: homePalette?.textMuted ?? AppColors.textMuted,
                    ),
                  ),
                ),
              ),

              // 2) POSTER (đè lên số)
              Positioned(
                left: _posterLeft,
                top: 0,
                width: posterWidth,
                height: posterHeight,
                child: _Top10Poster(movie: movie, posterWidth: posterWidth),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Top10Poster extends StatelessWidget {
  final MovieModel movie;
  final double posterWidth;

  const _Top10Poster({required this.movie, required this.posterWidth});

  @override
  Widget build(BuildContext context) {
    // Chỉ hiện badge khi có dữ liệu thật (isNew). Không bịa ĐỘC QUYỀN/PHỤ ĐỀ.
    final bottomBadge = movie.isNew ? 'MỚI' : null;

    // Giải mã ảnh theo đúng số điểm ảnh vật lý của poster (2:3), có chặn trên
    // để không giữ bitmap quá lớn trong bộ nhớ đệm khi cuộn.
    final cacheWidth = (posterWidth * MediaQuery.devicePixelRatioOf(context))
        .round()
        .clamp(200, 420);
    final cacheHeight = (cacheWidth * 1.5).round().clamp(300, 630);

    return Stack(
      clipBehavior: Clip.none, // để badge dưới tràn ra ngoài mép poster
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: movie.posterUrl.isEmpty
              ? _placeholder()
              : CachedNetworkImage(
                  imageUrl: movie.posterUrl,
                  fit: BoxFit.cover,
                  memCacheWidth: cacheWidth,
                  memCacheHeight: cacheHeight,
                  maxHeightDiskCache: 600,
                  fadeInDuration: Duration(milliseconds: 180),
                  placeholder: (_, _) => ColoredBox(color: AppColors.surface),
                  errorWidget: (_, _, _) => _placeholder(),
                ),
        ),

        // Viền hairline cho poster nổi trên nền đen.
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.14),
                  width: 0.8,
                ),
              ),
            ),
          ),
        ),

        // Nhãn MỚI đè lên mép dưới poster (khi có dữ liệu thật).
        if (bottomBadge != null)
          Positioned(
            left: 0,
            right: 0,
            bottom: -7,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: ThemeService.instance.primaryColor,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  bottomBadge,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _placeholder() => Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [AppColors.surfaceLight, AppColors.surface],
      ),
    ),
    padding: EdgeInsets.all(8),
    alignment: Alignment.bottomCenter,
    child: Text(
      movie.title,
      maxLines: 2,
      textAlign: TextAlign.center,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: AppColors.textSecondary,
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
