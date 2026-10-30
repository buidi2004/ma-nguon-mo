import 'package:flutter/material.dart';

import '../../../services/theme_service.dart';

/// Huy hiệu thông số kỹ thuật điện ảnh bề mặt kính mờ (Cinematic Frosted Glass Spec Badge).
///
/// Sử dụng cho các thẻ thông số trên MovieCard, HeroBanner và DetailScreen:
/// 4K Ultra HD, HDR10+, Dolby Vision, Top 10, Độ tuổi (T13, T18), v.v.
class GlassSpecBadge extends StatelessWidget {
  final String label;
  final Widget? icon;
  final Color? textColor;
  final Color? borderColor;
  final Color? backgroundColor;
  final double height;
  final double borderRadius;
  final bool isCapsule;

  const GlassSpecBadge({
    super.key,
    required this.label,
    this.icon,
    this.textColor,
    this.borderColor,
    this.backgroundColor,
    this.height = 20.0,
    this.borderRadius = 4.0,
    this.isCapsule = false,
  });

  /// Factory cho huy hiệu 4K Ultra HD
  factory GlassSpecBadge.uhd4k({Key? key, double height = 20.0}) {
    return GlassSpecBadge(
      key: key,
      label: '4K ULTRA HD',
      height: height,
      textColor: Colors.white,
      borderColor: Colors.white.withValues(alpha: 0.35),
      backgroundColor: const Color(0x331E1E1E),
    );
  }

  /// Factory cho huy hiệu HD
  factory GlassSpecBadge.hd({Key? key, double height = 20.0}) {
    return GlassSpecBadge(
      key: key,
      label: 'HD',
      height: height,
      textColor: Colors.white,
      borderColor: Colors.white.withValues(alpha: 0.30),
      backgroundColor: const Color(0x281E1E1E),
    );
  }

  /// Factory cho huy hiệu HDR10+
  factory GlassSpecBadge.hdr({Key? key, double height = 20.0}) {
    return GlassSpecBadge(
      key: key,
      label: 'HDR10+',
      height: height,
      textColor: const Color(0xFFFFD700), // Vàng kim
      borderColor: const Color(0xFFFFD700).withValues(alpha: 0.40),
      backgroundColor: const Color(0x332A2000),
    );
  }

  /// Factory cho huy hiệu Dolby Atmos / Vision
  factory GlassSpecBadge.dolby({
    Key? key,
    String type = 'ATMOS',
    double height = 20.0,
  }) {
    return GlassSpecBadge(
      key: key,
      label: 'DOLBY $type',
      height: height,
      textColor: Colors.white,
      borderColor: Colors.white.withValues(alpha: 0.35),
      backgroundColor: const Color(0x331E1E1E),
    );
  }

  /// Factory cho huy hiệu Top 10 độc quyền
  factory GlassSpecBadge.top10({
    Key? key,
    int? rank,
    double height = 22.0,
    Color? primaryColor,
  }) {
    final text = rank != null ? 'TOP $rank' : 'TOP 10';
    final primary = primaryColor ?? ThemeService.instance.primaryColor;
    return GlassSpecBadge(
      key: key,
      label: text,
      height: height,
      textColor: Colors.white,
      borderColor: primary.withValues(alpha: 0.75),
      backgroundColor: primary.withValues(alpha: 0.35),
      isCapsule: true,
      borderRadius: 11.0,
    );
  }

  /// Factory cho huy hiệu giới hạn độ tuổi (T13, T16, T18, P)
  factory GlassSpecBadge.age({
    Key? key,
    required String rating,
    double height = 20.0,
  }) {
    Color bdrColor = Colors.white.withValues(alpha: 0.25);
    Color bgColor = const Color(0x331E1E1E);

    if (rating.toUpperCase().contains('18')) {
      final brand = ThemeService.instance.primaryColor;
      bdrColor = brand.withValues(alpha: 0.6);
      bgColor = brand.withValues(alpha: 0.2);
    }

    return GlassSpecBadge(
      key: key,
      label: rating,
      height: height,
      textColor: Colors.white,
      borderColor: bdrColor,
      backgroundColor: bgColor,
    );
  }

  /// Factory cho nhãn gắn tag chung
  factory GlassSpecBadge.tag({
    Key? key,
    required String label,
    Color? accentColor,
    double height = 20.0,
    bool isCapsule = false,
  }) {
    return GlassSpecBadge(
      key: key,
      label: label,
      height: height,
      textColor: accentColor ?? Colors.white,
      borderColor: (accentColor ?? Colors.white).withValues(alpha: 0.35),
      backgroundColor: (accentColor ?? const Color(0xFF1E1E1E)).withValues(
        alpha: 0.18,
      ),
      isCapsule: isCapsule,
      borderRadius: isCapsule ? height / 2 : 4.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = isCapsule ? height / 2 : borderRadius;

    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      decoration: BoxDecoration(
        color: backgroundColor ?? const Color(0x331E1E1E),
        borderRadius: BorderRadius.circular(effectiveRadius),
        border: Border.all(
          color: borderColor ?? Colors.white.withValues(alpha: 0.25),
          width: 0.8,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x2A000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[icon!, const SizedBox(width: 3.5)],
          Text(
            label,
            style: TextStyle(
              color: textColor ?? Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
