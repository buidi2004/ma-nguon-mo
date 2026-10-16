import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../theme/app_theme.dart';
import 'glass_surface.dart';

/// Nút bấm kêu gọi hành động kính mờ cao cấp với hiệu ứng ánh kim điện ảnh lướt qua
/// (Frosted Glass CTA Button with Periodic Specular Shimmer Sweep).
///
/// Phù hợp cho nút "Phát", "Xem ngay", "Đăng ký VIP" trên Hero Banner và Detail Screen.
class GlassShimmerCTA extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final double height;
  final double? width;
  final bool isCapsule;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? glowColor;
  final bool hasGlow;
  final bool enableShimmer;
  final Duration shimmerInterval;
  final bool enableHaptic;
  final String? tooltip;

  const GlassShimmerCTA({
    super.key,
    required this.child,
    required this.onPressed,
    this.height = 48.0,
    this.width,
    this.isCapsule = true,
    this.borderRadius = 24.0,
    this.backgroundColor,
    this.glowColor,
    this.hasGlow = true,
    this.enableShimmer = true,
    this.shimmerInterval = const Duration(milliseconds: 3500),
    this.enableHaptic = true,
    this.tooltip,
  });

  /// Factory cho nút Xem / Phát phim chuẩn rạp chiếu
  factory GlassShimmerCTA.play({
    Key? key,
    required VoidCallback? onPressed,
    String label = 'Phát',
    IconData icon = Icons.play_arrow_rounded,
    double height = 48.0,
    double? width,
    Color? glowColor,
    bool enableShimmer = true,
  }) {
    return GlassShimmerCTA(
      key: key,
      onPressed: onPressed,
      height: height,
      width: width,
      isCapsule: true,
      glowColor: glowColor ?? AppColors.red,
      enableShimmer: enableShimmer,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  /// Factory cho nút Vé VIP / Giá vé điện ảnh trên Hero Banner
  factory GlassShimmerCTA.vipPrice({
    Key? key,
    required VoidCallback? onPressed,
    required String price,
    String qualityTag = 'HD',
    double height = 46.0,
    double? width,
  }) {
    return GlassShimmerCTA(
      key: key,
      onPressed: onPressed,
      height: height,
      width: width,
      isCapsule: true,
      glowColor: AppColors.red.withValues(alpha: 0.5),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.85),
                  width: 1.2,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                qualityTag,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              price,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  State<GlassShimmerCTA> createState() => _GlassShimmerCTAState();
}

class _GlassShimmerCTAState extends State<GlassShimmerCTA>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmerController;
  late final Animation<double> _shimmerAnimation;
  Timer? _shimmerTimer;
  bool _isPressed = false;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _shimmerAnimation = Tween<double>(begin: -1.5, end: 2.5).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOutSine),
    );

    if (widget.enableShimmer) {
      _startPeriodicShimmer();
    }
  }

  void _startPeriodicShimmer() {
    _shimmerTimer?.cancel();
    _shimmerTimer = Timer.periodic(widget.shimmerInterval, (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (widget.onPressed != null && !_shimmerController.isAnimating) {
        _shimmerController.forward(from: 0.0);
      }
    });
  }

  @override
  void dispose() {
    _shimmerTimer?.cancel();
    _shimmerController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails _) {
    if (widget.onPressed == null) return;
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails _) {
    setState(() => _isPressed = false);
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  void _handleTap() {
    if (widget.onPressed == null) return;
    if (widget.enableHaptic) {
      HapticFeedback.mediumImpact();
    }
    widget.onPressed!();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = widget.isCapsule
        ? widget.height / 2
        : widget.borderRadius;
    final isEnabled = widget.onPressed != null;

    final effectiveGlow = widget.glowColor ?? AppColors.red;

    final Color bgColor = widget.backgroundColor ??
        (_isPressed
            ? const Color(0x66333333)
            : (_isHovered ? const Color(0x552A2A2A) : const Color(0x381E1E1E)));

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: _handleTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedScale(
          scale: _isPressed ? 0.95 : (_isHovered ? 1.02 : 1.0),
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: widget.height,
            width: widget.width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(effectiveRadius),
              boxShadow: (widget.hasGlow && isEnabled)
                  ? [
                      BoxShadow(
                        color: effectiveGlow.withValues(
                          alpha: _isHovered ? 0.45 : 0.25,
                        ),
                        blurRadius: _isHovered ? 16 : 10,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(effectiveRadius),
              child: Stack(
                fit: StackFit.passthrough,
                alignment: Alignment.center,
                children: [
                  // 1. Lớp kính mờ quang học nền
                  GlassSurface(
                    width: widget.width,
                    height: widget.height,
                    isCircle: false,
                    borderRadius: effectiveRadius,
                    tintColor: bgColor,
                    blur: 14.0,
                    refractiveIndex: 1.40,
                    thickness: 32.0,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Center(child: widget.child),
                    ),
                  ),

                  // 2. Lớp vệt sáng kim loại Shimmer Sweep lướt qua
                  if (widget.enableShimmer && isEnabled)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: AnimatedBuilder(
                          animation: _shimmerAnimation,
                          builder: (context, _) {
                            final val = _shimmerAnimation.value;
                            return ShaderMask(
                              blendMode: BlendMode.srcATop,
                              shaderCallback: (bounds) {
                                return LinearGradient(
                                  begin: Alignment(val - 1.0, -0.2),
                                  end: Alignment(val, 0.2),
                                  colors: [
                                    Colors.transparent,
                                    Colors.white.withValues(alpha: 0.05),
                                    Colors.white.withValues(alpha: 0.35),
                                    Colors.white.withValues(alpha: 0.05),
                                    Colors.transparent,
                                  ],
                                  stops: const [0.0, 0.35, 0.50, 0.65, 1.0],
                                ).createShader(bounds);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    effectiveRadius,
                                  ),
                                  color: Colors.white.withValues(alpha: 0.1),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                  // 3. Đường viền phản chiếu ánh sáng vát (Double-bevel hairline)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(effectiveRadius),
                          border: Border.all(
                            color: Colors.white.withValues(
                              alpha: _isHovered ? 0.40 : 0.22,
                            ),
                            width: 1.0,
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
      ),
    );
  }
}
