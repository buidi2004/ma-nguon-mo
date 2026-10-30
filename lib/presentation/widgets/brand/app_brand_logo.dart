import 'package:flutter/material.dart';

import '../../../services/theme_service.dart';
import 'v_movie_brand_asset.dart';

/// Widget Logo thương hiệu OpenFlix kết hợp Icon điện ảnh 3D và chữ FLIX.
///
/// Thay thế chữ 'OPEN' bằng biểu tượng Icon 3D điện ảnh (chữ V, clapperboard,
/// cuộn phim và nút play đỏ), căn chỉnh thẳng hàng tuyệt đối và cân đối quang học
/// với chữ 'FLIX' chuẩn phong cách Netflix Dark Cinema.
class AppBrandLogo extends StatelessWidget {
  /// Kích thước cạnh của icon (chiều cao và chiều rộng)
  final double iconSize;

  /// Cỡ chữ của 'FLIX'
  final double fontSize;

  /// Khoảng cách giữa icon và chữ 'FLIX'
  final double spacing;

  /// Hiển thị phần chữ 'FLIX' hay chỉ hiển thị icon đơn lẻ
  final bool showText;

  /// Cho phép nhấn vào logo (ví dụ cuộn mượt lên đầu trang)
  final VoidCallback? onTap;

  /// Bù trừ vị trí trục Y quang học (để căn thẳng tâm giữa Icon và chữ FLIX)
  final double opticalYOffset;

  const AppBrandLogo({
    super.key,
    this.iconSize = 34.0,
    this.fontSize = 21.0,
    this.spacing = 7.0,
    this.showText = true,
    this.onTap,
    this.opticalYOffset = -0.5,
  });

  /// Biến thể kích thước nhỏ dùng cho modal hoặc thanh phụ
  const AppBrandLogo.small({
    super.key,
    this.iconSize = 24.0,
    this.fontSize = 16.0,
    this.spacing = 5.0,
    this.showText = true,
    this.onTap,
    this.opticalYOffset = -0.5,
  });

  /// Biến thể kích thước lớn dùng cho màn hình Chào mừng / Giới thiệu
  const AppBrandLogo.large({
    super.key,
    this.iconSize = 52.0,
    this.fontSize = 32.0,
    this.spacing = 10.0,
    this.showText = true,
    this.onTap,
    this.opticalYOffset = -1.0,
  });

  @override
  Widget build(BuildContext context) {
    final brandColor = ThemeService.instance.primaryColor;

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 1. Biểu tượng 3D điện ảnh (thay cho chữ OPEN)
        Transform.translate(
          offset: Offset(0, opticalYOffset),
          child: SizedBox(
            width: iconSize,
            height: iconSize,
            child: Image.memory(
              kVMovie3dIconBytes,
              width: iconSize,
              height: iconSize,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  'web/icons/Biểu tượng V xem phim 3D điện ảnh.png',
                  width: iconSize,
                  height: iconSize,
                  fit: BoxFit.contain,
                  errorBuilder: (ctx, err, st) => Image.asset(
                    'assets/icons/v_movie_icon.png',
                    width: iconSize,
                    height: iconSize,
                    fit: BoxFit.contain,
                    errorBuilder: (c, e, s) => Icon(
                      Icons.movie_creation_rounded,
                      color: brandColor,
                      size: iconSize * 0.85,
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // 2. Chữ 'FLIX' màu thương hiệu dóng thẳng hàng
        if (showText) ...[
          SizedBox(width: spacing),
          Text(
            'FLIX',
            style: TextStyle(
              color: brandColor,
              fontWeight: FontWeight.w900,
              fontSize: fontSize,
              letterSpacing: 2.0,
              height: 1.0, // Triệt tiêu padding trên/dưới ngầm định của font để thẳng hàng
              shadows: [
                Shadow(
                  color: brandColor.withValues(alpha: 0.35),
                  blurRadius: 6,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
        ],
      ],
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: content,
      );
    }

    return content;
  }
}
