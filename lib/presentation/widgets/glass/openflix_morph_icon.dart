import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:morphnext/morphnext.dart';

/// Bộ Icon biến hình quang học mượt mà (Morphing Icon) lấy cảm hứng từ công nghệ Morphicons.
/// Tự động chuyển đổi biểu tượng với hệ thống vật lý lò xo (Spring Physics),
/// tối ưu hóa chuyển động xoay (Rotational Spring) và phản hồi xúc giác thị giác sống động.
class OpenFlixMorphIcon extends StatefulWidget {
  final IconData icon;
  final double? size;
  final Color? color;
  final SpringDescription spring;
  final bool enableScalePulse;
  final String? semanticLabel;

  const OpenFlixMorphIcon({
    super.key,
    required this.icon,
    this.size,
    this.color,
    this.spring = MorphSprings.snappy,
    this.enableScalePulse = true,
    this.semanticLabel,
  });

  /// Preset mượt mà critically-damped: Thích hợp cho Play/Pause, Mute/Unmute
  const OpenFlixMorphIcon.smooth({
    super.key,
    required this.icon,
    this.size,
    this.color,
    this.enableScalePulse = true,
    this.semanticLabel,
  }) : spring = MorphSprings.smooth;

  /// Preset dứt khoát snappy-overshoot: Thích hợp cho Bookmark, Like, Download, Search
  const OpenFlixMorphIcon.snappy({
    super.key,
    required this.icon,
    this.size,
    this.color,
    this.enableScalePulse = true,
    this.semanticLabel,
  }) : spring = MorphSprings.snappy;

  @override
  State<OpenFlixMorphIcon> createState() => _OpenFlixMorphIconState();
}

class _OpenFlixMorphIconState extends State<OpenFlixMorphIcon>
    with SingleTickerProviderStateMixin {
  AnimationController? _springController;

  AnimationController get _effectiveController {
    return _springController ??= AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
      lowerBound: 0.0,
      upperBound: 2.0,
    )..value = 1.0;
  }

  @override
  void initState() {
    super.initState();
    _effectiveController;
  }

  @override
  void didUpdateWidget(covariant OpenFlixMorphIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.icon != widget.icon) {
      _runSpringAnimation();
    }
  }

  void _runSpringAnimation() {
    if (!mounted) return;
    final controller = _effectiveController;
    controller.reset();
    final simulation = SpringSimulation(widget.spring, 0.0, 1.0, 0.0);
    controller.animateWith(simulation);
  }

  @override
  void dispose() {
    _springController?.dispose();
    _springController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _effectiveController;
    final effectiveColor =
        widget.color ?? IconTheme.of(context).color ?? Colors.white;
    final effectiveSize = widget.size ?? IconTheme.of(context).size ?? 24.0;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final progress = controller.value.clamp(0.0, 1.25);
        // 1. Góc xoay lò xo (Spring Rotation)
        final rotation = (1.0 - progress) * 0.32; // ~18 độ đàn hồi
        // 2. Độ nảy lò xo (Spring Scale Bounce)
        final scale = widget.enableScalePulse
            ? (0.86 +
                  0.14 * progress +
                  (progress > 0.6 && progress < 1.1
                      ? 0.06 * (1.1 - progress)
                      : 0.0))
            : 1.0;

        return Transform.rotate(
          angle: rotation,
          child: Transform.scale(
            scale: scale,
            child: Icon(
              widget.icon,
              size: effectiveSize,
              color: effectiveColor,
              semanticLabel: widget.semanticLabel,
            ),
          ),
        );
      },
    );
  }
}
