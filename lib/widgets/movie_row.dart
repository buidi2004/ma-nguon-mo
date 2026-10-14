import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/movie_model.dart';
import '../theme/app_theme.dart';

class MovieRow extends StatelessWidget {
  final String title;
  final List<MovieModel> movies;
  final void Function(MovieModel movie) onTap;
  final VoidCallback? onSeeAll;
  final bool isTop10;

  const MovieRow({
    super.key,
    required this.title,
    required this.movies,
    required this.onTap,
    this.onSeeAll,
    this.isTop10 = false,
  });

  @override
  Widget build(BuildContext context) {
    if (movies.isEmpty) return const SizedBox.shrink();

    final screenWidth = MediaQuery.sizeOf(context).width;
    // Tỷ lệ chuẩn: hiển thị 3 poster và lộ ~40% poster thứ 4 để gợi ý vuốt
    final posterWidth = screenWidth / 3.4;
    final posterHeight = posterWidth * 1.5; // Tỷ lệ poster 2:3 chuẩn

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 20, 12, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
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
            ],
          ),
        ),
        SizedBox(
          height: posterHeight,
          child: RepaintBoundary(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: movies.length,
              separatorBuilder: (_, _) => const SizedBox(width: 6),
              itemBuilder: (context, index) {
                final movie = movies[index];
                final imageWidget = ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: CachedNetworkImage(
                    imageUrl: movie.posterUrl,
                    width: posterWidth,
                    height: posterHeight,
                    fit: BoxFit.cover,
                    memCacheWidth: 350,
                    memCacheHeight: 525,
                    maxHeightDiskCache: 600,
                    placeholder: (_, _) => Container(
                      width: posterWidth,
                      height: posterHeight,
                      color: AppColors.surface,
                      child: const Center(
                        child: Icon(
                          Icons.movie_outlined,
                          color: Colors.white24,
                          size: 28,
                        ),
                      ),
                    ),
                    errorWidget: (_, _, _) => Container(
                      width: posterWidth,
                      height: posterHeight,
                      color: AppColors.surface,
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.broken_image_outlined,
                            color: Colors.white38,
                            size: 24,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            movie.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );

                Widget content = imageWidget;
                if (isTop10) {
                  final rank = index + 1;
                  content = SizedBox(
                    width: posterWidth,
                    height: posterHeight,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        imageWidget,
                        // Lớp gradient chân card giúp số xếp hạng nổi bật rõ nét
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          height: 54,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(4),
                              ),
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withAlpha(210),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Số thứ tự Top 10 phóng to chuẩn phong cách Netflix (Double-text Stroke)
                        Positioned(
                          left: 4,
                          bottom: -6,
                          child: Stack(
                            children: [
                              // Viền đen stroke đậm
                              Text(
                                '$rank',
                                style: TextStyle(
                                  fontSize: 52,
                                  fontWeight: FontWeight.w900,
                                  foreground: Paint()
                                    ..style = PaintingStyle.stroke
                                    ..strokeWidth = 4.5
                                    ..color = Colors.black,
                                ),
                              ),
                              // Thân số màu trắng / đỏ Top 3
                              Text(
                                '$rank',
                                style: TextStyle(
                                  fontSize: 52,
                                  fontWeight: FontWeight.w900,
                                  color: rank <= 3
                                      ? AppColors.red
                                      : Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return GestureDetector(
                  onTap: () => onTap(movie),
                  child: content,
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
