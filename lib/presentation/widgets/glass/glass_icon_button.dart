import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'glass_surface.dart';

/// Nút bấm Icon kính mờ quang học (Optical Glass Icon Button).
/// Thích hợp cho các nút điều khiển Player (Play, Pause, Tua, Subtitle),
/// nút Đóng (Close), Bookmark, Share và Quick Actions.
class GlassIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final double iconSize;
  final Color? iconColor;
  final Color? tintColor;
  final bool isCircle;
  final double borderRadius;
  final String? tooltip;
  final bool hasGlow;
  final Color? glowColor;
  final bool? useBackdropFilter;

  const GlassIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = 44.0,
    this.iconSize = 22.0,
    this.iconColor = Colors.white,
    this.tintColor,
    this.isCircle = true,
    this.borderRadius = 12.0,
    this.tooltip,
    this.hasGlow = false,
    this.glowColor,
    this.useBackdropFilter,
  });

  /// Factory tiện ích cho nút icon tròn hoàn toàn
  const GlassIconButton.circle({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = 44.0,
    this.iconSize = 22.0,
    this.iconColor = Colors.white,
    this.tintColor,
    this.tooltip,
    this.hasGlow = false,
    this.glowColor,
    this.useBackdropFilter,
  }) : isCircle = true,
       borderRadius = 999.0;

  /// Factory tiện ích cho nút icon bo góc vuông (Rounded square)
  const GlassIconButton.rounded({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = 44.0,
    this.iconSize = 22.0,
    this.iconColor = Colors.white,
    this.tintColor,
    this.borderRadius = 12.0,
    this.tooltip,
    this.hasGlow = false,
    this.glowColor,
    this.useBackdropFilter,
  }) : isCircle = false;

  @override
  State<GlassIconButton> createState() => _GlassIconButtonState();
}

class _GlassIconButtonState extends State<GlassIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnimation;

  bool get _isEnabled => widget.onPressed != null;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 120),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(
        parent: _pressController,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeOutBack,
      ),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!_isEnabled) return;
    _pressController.forward();
    HapticFeedback.lightImpact();
  }

  void _handleTapUp(TapUpDetails details) {
    if (!_isEnabled) return;
    _pressController.reverse();
  }

  void _handleTapCancel() {
    if (!_isEnabled) return;
    _pressController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    Widget button = AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(scale: _scaleAnimation.value, child: child);
      },
      child: Opacity(
        opacity: _isEnabled ? 1.0 : 0.40,
        child: GestureDetector(
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          onTap: _isEnabled ? widget.onPressed : null,
          behavior: HitTestBehavior.opaque,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Ánh sáng tỏa hào quang nếu bật hasGlow
              if (widget.hasGlow)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      shape: widget.isCircle
                          ? BoxShape.circle
                          : BoxShape.rectangle,
                      borderRadius: widget.isCircle
                          ? null
                          : BorderRadius.circular(widget.borderRadius),
                      gradient: RadialGradient(
                        colors: [
                          (widget.glowColor ?? const Color(0xFFE50914))
                              .withValues(alpha: 0.35),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 1.0],
                      ),
                    ),
                  ),
                ),

              // Bề mặt kính quang học
              GlassSurface(
                width: widget.size,
                height: widget.size,
                isCircle: widget.isCircle,
                borderRadius: widget.borderRadius,
                tintColor: widget.tintColor ?? const Color(0x2E2A2A2A),
                blur: 8.5,
                refractiveIndex: 1.82,
                thickness: 52.0,
                useBackdropFilter: widget.useBackdropFilter,
                child: Center(
                  child: Icon(
                    widget.icon,
                    size: widget.iconSize,
                    color: widget.iconColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (widget.tooltip != null) {
      return Tooltip(message: widget.tooltip!, child: button);
    }

    return button;
  }
}
