import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../services/theme_service.dart';
import '../../../theme/app_theme.dart';
import 'glass_icon_button.dart';

/// Lớp phủ ảnh thu nhỏ tích hợp nút Phát kính mờ và thanh tiến trình quang học
/// (Frosted Glass Play Thumbnail Overlay with Glass Progress Bar).
///
/// Phù hợp cho danh sách "Đang xem dở" (Continue Watching) và hàng phim tiếp tục xem trên Trang chủ.
class GlassPlayThumbnailOverlay extends StatelessWidget {
  final String imageUrl;
  final VoidCallback onTap;
  final double width;
  final double height;
  final double? progressRatio; // 0.0 -> 1.0 (null nếu không có tiến trình)
  final double borderRadius;
  final double playIconSize;
  final double playButtonSize;
  final String? semanticLabel;

  const GlassPlayThumbnailOverlay({
    super.key,
    required this.imageUrl,
    required this.onTap,
    this.width = 120.0,
    this.height = 80.0,
    this.progressRatio,
    this.borderRadius = 6.0,
    this.playIconSize = 22.0,
    this.playButtonSize = 38.0,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRatio = progressRatio?.clamp(0.0, 1.0);

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: width,
          height: height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Ảnh thu nhỏ áp dụng bộ nhớ đệm
              if (imageUrl.isNotEmpty)
                CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  memCacheWidth: (width * 3).toInt().clamp(200, 720),
                  memCacheHeight: (height * 3).toInt().clamp(150, 480),
                  placeholder: (_, _) =>
                      const ColoredBox(color: AppColors.surfaceLight),
                  errorWidget: (_, _, _) => const ColoredBox(
                    color: AppColors.surface,
                    child: Center(
                      child: Icon(
                        Icons.movie_filter_outlined,
                        color: Colors.white24,
                        size: 28,
                      ),
                    ),
                  ),
                )
              else
                const ColoredBox(
                  color: AppColors.surface,
                  child: Center(
                    child: Icon(
                      Icons.movie_filter_outlined,
                      color: Colors.white24,
                      size: 28,
                    ),
                  ),
                ),

              // 2. Lớp phủ tối nhẹ (Vignette) để nổi bật nút Play
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x33000000),
                      Color(0x66000000),
                    ],
                  ),
                ),
              ),

              // 3. Nút Play kính mờ chính giữa
              Center(
                child: GlassIconButton.circle(
                  size: playButtonSize,
                  iconSize: playIconSize,
                  icon: Icons.play_arrow_rounded,
                  tooltip: semanticLabel ?? 'Tiếp tục phát',
                  hasGlow: true,
                  glowColor: ThemeService.instance.primaryColor,
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    onTap();
                  },
                ),
              ),

              // 4. Thanh tiến trình đỏ phát quang (Glass Progress Bar) ở đáy
              if (effectiveRatio != null && effectiveRatio > 0)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 4.5,
                  child: Stack(
                    children: [
                      // Rãnh kính mờ phía sau
                      Container(
                        color: Colors.black.withValues(alpha: 0.5),
                      ),
                      // Dải đỏ tiến trình phát quang
                      FractionallySizedBox(
                        widthFactor: effectiveRatio,
                        child: Container(
                          decoration: BoxDecoration(
                            color: ThemeService.instance.primaryColor,
                            boxShadow: [
                              BoxShadow(
                                color: ThemeService.instance.primaryColor.withValues(alpha: 0.6),
                                blurRadius: 4,
                                offset: const Offset(0, -0.5),
                              ),
                            ],
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
    );
  }
}
