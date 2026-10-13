import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/movie_model.dart';
import '../theme/app_theme.dart';

class HeroBanner extends StatelessWidget {
  final MovieModel movie;
  final VoidCallback onPlay;
  final VoidCallback? onInfo;

  const HeroBanner({
    super.key,
    required this.movie,
    required this.onPlay,
    this.onInfo,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final heroHeight = screenHeight * 0.55;

    return SizedBox(
      height: heroHeight,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Ảnh Poster Hero dọc phủ toàn màn hình
          CachedNetworkImage(
            imageUrl: movie.posterUrl,
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
            placeholder: (_, _) => const ColoredBox(color: AppColors.surface),
            errorWidget: (_, _, _) => const ColoredBox(
              color: AppColors.surface,
              child: Center(
                child: Icon(
                  Icons.movie_filter_outlined,
                  size: 64,
                  color: Colors.white24,
                ),
              ),
            ),
          ),

          // 2. Lớp phủ Gradient trên đỉnh (bảo vệ chữ AppBar)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 120,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.8),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // 3. Lớp mờ dần xuống nền đen (#141414) không có đường cắt
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.4, 0.75, 1.0],
                  colors: [
                    Colors.transparent,
                    AppColors.background.withValues(alpha: 0.7),
                    AppColors.background,
                  ],
                ),
              ),
            ),
          ),

          // 4. Nội dung và Cụm Nút điều khiển chuẩn Netflix
          Positioned(
            left: 16,
            right: 16,
            bottom: 12,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Thể loại & Thông tin tóm tắt
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (movie.category.isNotEmpty) ...[
                      Text(
                        movie.category,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Icon(
                          Icons.circle,
                          size: 4,
                          color: AppColors.red,
                        ),
                      ),
                    ],
                    Text(
                      '${movie.releaseYear}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(Icons.circle, size: 4, color: AppColors.red),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
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
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Cặp nút: Phát (trắng) & Thông tin (xám mờ)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Nút PHÁT chính - Nền trắng, chữ đen, bo góc 4px
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onPlay,
                        icon: const Icon(
                          Icons.play_arrow,
                          color: Colors.black,
                          size: 24,
                        ),
                        label: const Text(
                          'Phát',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Nút THÔNG TIN phụ - Nền xám mờ (#2A2A2A), chữ trắng, bo góc 4px
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onInfo,
                        icon: const Icon(
                          Icons.info_outline,
                          color: Colors.white,
                          size: 22,
                        ),
                        label: const Text(
                          'Thông tin',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.surface,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
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
    );
  }
}
