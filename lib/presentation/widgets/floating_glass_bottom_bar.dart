import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:morphnext/morphnext.dart';

/// Icon 4 ô vuông bo góc đa sắc XOAY NGHIÊNG CHÉO 3D kèm ánh sáng tỏa tròn (Radial Glow)
/// Khớp chuẩn xác góc nghiêng ~22 độ và bề mặt nổi 3D
class FourTileQuickActionIcon extends StatelessWidget {
  final double size;
  const FourTileQuickActionIcon({
    super.key,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    final tileSize = size * 0.42;
    final borderRadius = BorderRadius.circular(tileSize * 0.38);
    return SizedBox(
      width: size + 8,
      height: size + 8,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Hiệu ứng ánh sáng tỏa tròn (Radial Glow) phía sau cụm icon
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFE50914).withValues(alpha: 0.42),
                    const Color(0xFFFF3838).withValues(alpha: 0.20),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
            ),
          ),
          // Khối 4 ô vuông xoay góc 22 độ
          Transform.rotate(
            angle: 0.384, // ~22 độ
            child: SizedBox(
              width: size,
              height: size,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 1. Ô TRÊN-TRÁI: Cyan phát sáng
                      _buildTile(
                        size: tileSize,
                        borderRadius: borderRadius,
                        colors: const [Color(0xFF2AF598), Color(0xFF009EFD)],
                        shadowColor:
                            const Color(0xFF00E5FF).withValues(alpha: 0.60),
                        hasSpecularHighlight: true,
                      ),
                      const SizedBox(width: 3),
                      // 2. Ô TRÊN-PHẢI: Royal Blue
                      _buildTile(
                        size: tileSize,
                        borderRadius: borderRadius,
                        colors: const [Color(0xFF5B86E5), Color(0xFF363795)],
                        shadowColor:
                            const Color(0xFF5B86E5).withValues(alpha: 0.50),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 3. Ô DƯỚI-TRÁI: Vàng cam Sunburst
                      _buildTile(
                        size: tileSize,
                        borderRadius: borderRadius,
                        colors: const [Color(0xFFFFB300), Color(0xFFFF6F00)],
                        shadowColor:
                            const Color(0xFFFF9800).withValues(alpha: 0.55),
                      ),
                      const SizedBox(width: 3),
                      // 4. Ô DƯỚI-PHẢI: Xanh lá mạ Neon Green
                      _buildTile(
                        size: tileSize,
                        borderRadius: borderRadius,
                        colors: const [Color(0xFFB4EC51), Color(0xFF429321)],
                        shadowColor:
                            const Color(0xFF7ED321).withValues(alpha: 0.50),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTile({
    required double size,
    required BorderRadius borderRadius,
    required List<Color> colors,
    required Color shadowColor,
    bool hasSpecularHighlight = false,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 5,
            offset: const Offset(0, 2.5),
          ),
        ],
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.35),
          width: 0.8,
        ),
      ),
      child: hasSpecularHighlight
          ? Container(
              decoration: BoxDecoration(
                borderRadius: borderRadius,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.center,
                  colors: [
                    Colors.white.withValues(alpha: 0.40),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.55],
                ),
              ),
            )
          : null,
    );
  }
}

/// Widget chuyên trách CHỈ vẽ nền kính mờ (Layer 1: Background)
class GlassNavBackground extends StatelessWidget {
  final double blurSigma;
  final double borderRadius;
  final double tintOpacity;
  final bool isOval;
  final double height;
  final double? width;
  final bool useBackdropFilter;

  const GlassNavBackground({
    super.key,
    this.blurSigma = 18,
    this.borderRadius = 33,
    this.tintOpacity = 0.12,
    this.isOval = false,
    this.height = 66,
    this.width,
    this.useBackdropFilter = true,
  });

  @override
  Widget build(BuildContext context) {
    if (useBackdropFilter) {
      return _DarkBevelGlassWrapper(
        borderRadius: borderRadius,
        isOval: isOval,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
            child: Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF2C2C2C).withValues(alpha: 0.48),
                    const Color(0xFF101010).withValues(alpha: 0.68),
                  ],
                ),
                borderRadius:
                    isOval ? null : BorderRadius.circular(borderRadius),
                shape: isOval ? BoxShape.circle : BoxShape.rectangle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.28),
                  width: 0.8,
                ),
              ),
              child: Stack(
                fit: StackFit.passthrough,
                children: [
                  // Lớp vòm phản quang khúc xạ quang học (Specular Curvature Sheen)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: height * 0.48,
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: isOval
                              ? null
                              : BorderRadius.vertical(
                                  top: Radius.circular(borderRadius),
                                ),
                          shape: isOval ? BoxShape.circle : BoxShape.rectangle,
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.white.withValues(alpha: 0.26),
                              Colors.white.withValues(alpha: 0.04),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.55, 1.0],
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
      );
    }

    // Mặc định: Nền kính quang học LiquidGlass (Snell's Law) + Viền vát siêu mảnh Hairline Rim (~0.8px)
    return _DarkBevelGlassWrapper(
      borderRadius: borderRadius,
      isOval: isOval,
      child: GlassContainer(
        width: width,
        height: height,
        useOwnLayer: true,
        quality: GlassQuality.premium,
        shape: isOval
            ? const LiquidOval()
            : LiquidRoundedRectangle(borderRadius: borderRadius),
        settings: const LiquidGlassSettings(
          thickness: 42,
          blur: 24.0,
          glassColor: Color(0x38FFFFFF),
          lightIntensity: 1.25,
          refractiveIndex: 1.68, // Tăng mạnh độ khúc xạ bẻ cong ảnh theo định luật Snell
          chromaticAberration: 0.05,
          ambientStrength: 0.22,
          fresnelStrength: 1.65,
          saturation: 1.35,
          edgeAbsorption: 0.12,
          lensModel: GlassLensModel.paraxial,
          glowIntensity: 0.85,
          shadowElevation: 2.0,
        ),
      ),
    );
  }
}

/// Thanh điều hướng nổi sử dụng kiến trúc 2 Layer Sibling trong Stack:
class FloatingGlassBottomBar extends StatelessWidget
    implements PreferredSizeWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onQuickActionPressed;

  const FloatingGlassBottomBar({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
    required this.onQuickActionPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(88);

  static const List<({IconData active, IconData inactive})> _tabIcons = [
    (active: Icons.home_rounded, inactive: Icons.home_outlined),
    (active: Icons.search_rounded, inactive: Icons.search_outlined),
    (
      active: Icons.local_fire_department_rounded,
      inactive: Icons.local_fire_department_outlined
    ),
    (active: Icons.person_rounded, inactive: Icons.person_outline_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return GlassAdaptiveScope(
      minQuality: GlassQuality.standard,
      maxQuality: GlassQuality.premium,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        child: SizedBox(
          height: 66,
          child: Row(
            children: [
              // ĐẢO BÊN TRÁI: Thanh capsule kính chứa 4 tabs
              Expanded(
                child: SizedBox(
                  height: 66,
                  child: Stack(
                    children: [
                      // Layer 1: NỀN kính mờ - CHỈ có blur + refraction + tint + hairline rim
                      const Positioned.fill(
                        child: GlassNavBackground(
                          borderRadius: 33,
                          height: 66,
                        ),
                      ),
                      // Layer 2: NỘI DUNG - icon/active pill nằm ĐÈ LÊN TRÊN, sắc nét 100%
                      Positioned.fill(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Row(
                            children: List.generate(_tabIcons.length, (index) {
                              final isSelected = selectedIndex == index;
                              return Expanded(
                                child: _buildTabItem(
                                  tab: _tabIcons[index],
                                  isSelected: isSelected,
                                  onTap: () => onTabSelected(index),
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // ĐẢO BÊN PHẢI: Nút tròn tiện ích nhanh
              SizedBox(
                width: 66,
                height: 66,
                child: Stack(
                  children: [
                    // Layer 1: NỀN kính mờ tròn
                    const Positioned.fill(
                      child: GlassNavBackground(
                        isOval: true,
                        borderRadius: 33,
                        width: 66,
                        height: 66,
                      ),
                    ),
                    // Layer 2: NỘI DUNG - nút bấm tiện ích 4 ô vuông xoay 3D nằm ĐÈ LÊN TRÊN
                    Positioned.fill(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: onQuickActionPressed,
                          borderRadius: BorderRadius.circular(33),
                          child: const Center(
                            child: FourTileQuickActionIcon(size: 30),
                          ),
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

  Widget _buildTabItem({
    required ({IconData active, IconData inactive}) tab,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        color: Colors.transparent,
        alignment: Alignment.center,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutBack,
          width: isSelected ? 56 : 42,
          height: 42,
          decoration: isSelected
              ? BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFF2233),
                      Color(0xFFE50914),
                      Color(0xFFB80610),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(21),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE50914).withValues(alpha: 0.58),
                      blurRadius: 14,
                      offset: const Offset(0, 3),
                    ),
                    BoxShadow(
                      color: const Color(0xFFFF3344).withValues(alpha: 0.35),
                      blurRadius: 6,
                      offset: const Offset(0, 1),
                    ),
                  ],
                )
              : null,
          alignment: Alignment.center,
          child: AnimatedScale(
            scale: isSelected ? 1.14 : 1.0,
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutBack,
            child: AnimatedMorphIcon(
              icon: isSelected ? tab.active : tab.inactive,
              size: 22,
              color: isSelected
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.60),
              spring: MorphSprings.snappy,
            ),
          ),
        ),
      ),
    );
  }
}

/// Khung viền ngoài màu đen vát quang học (Dark Bevel Chamfer Frame)
class _DarkBevelGlassWrapper extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final bool isOval;

  const _DarkBevelGlassWrapper({
    required this.child,
    this.borderRadius = 33,
    this.isOval = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: isOval ? null : BorderRadius.circular(borderRadius),
        shape: isOval ? BoxShape.circle : BoxShape.rectangle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          child,
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _DarkGlassBevelRimPainter(
                  borderRadius: borderRadius,
                  isOval: isOval,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DarkGlassBevelRimPainter extends CustomPainter {
  final double borderRadius;
  final bool isOval;

  const _DarkGlassBevelRimPainter({
    required this.borderRadius,
    required this.isOval,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    // 1. Viền khúc xạ tán sắc chính ngoài cùng (Outer Refraction Prism Rim)
    final outerRimPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xE0FFFFFF),
          Color(0x60FFFFFF),
          Color(0x2564748B),
          Color(0x401E293B),
        ],
        stops: [0.0, 0.22, 0.60, 1.0],
      ).createShader(rect);

    // 2. Viền khúc xạ ánh sáng vát trong (Inner Caustic Highlight)
    final innerHighlightPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0x90FFFFFF),
          Color(0x18FFFFFF),
          Colors.transparent,
        ],
        stops: [0.0, 0.35, 1.0],
      ).createShader(rect);

    if (isOval) {
      canvas.drawOval(rect.deflate(0.5), outerRimPaint);
      canvas.drawOval(rect.deflate(1.2), innerHighlightPaint);
    } else {
      final outerRRect = RRect.fromRectAndRadius(
        rect.deflate(0.5),
        Radius.circular(borderRadius - 0.5),
      );
      final innerRRect = RRect.fromRectAndRadius(
        rect.deflate(1.2),
        Radius.circular(borderRadius - 1.2),
      );
      canvas.drawRRect(outerRRect, outerRimPaint);
      canvas.drawRRect(innerRRect, innerHighlightPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _DarkGlassBevelRimPainter oldDelegate) =>
      oldDelegate.borderRadius != borderRadius || oldDelegate.isOval != isOval;
}
