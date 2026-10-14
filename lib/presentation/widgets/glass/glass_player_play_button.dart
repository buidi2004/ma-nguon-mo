import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../theme/app_theme.dart';
import 'glass_surface.dart';

/// Nút phát tròn kính mờ quang học (Glass Player Play Button - Giai đoạn 3).
/// Tuân thủ quy chuẩn thiết kế điện ảnh chuẩn Netflix:
/// - Kích thước: 68 x 68 px (vượt chuẩn Touch target >= 44x44px).
/// - Khúc xạ quang học: Snell's Law 1.48, Blur 20.0, bo tròn hoàn toàn (Radius 34px).
/// - Viền sáng quang học: Hairline Rim rgba(255, 255, 255, 0.20).
/// - Vòng hào quang mở rộng nhẹ (Pulse Glow Ring) khi tạm dừng hoặc đang đệm (buffering).
/// - Phản hồi xúc giác rung nhẹ [HapticFeedback.lightImpact] + Micro-spring nhún 0.92x (180ms).
class GlassPlayerPlayButton extends StatefulWidget {
  final bool isPlaying;
  final bool isLoading;
  final VoidCallback? onPressed;
  final double size;
  final Color iconColor;
  final Color glowColor;
  final bool enablePulse;
  final String? tooltip;

  const GlassPlayerPlayButton({
    super.key,
    required this.isPlaying,
    required this.onPressed,
    this.isLoading = false,
    this.size = 68.0,
    this.iconColor = Colors.white,
    this.glowColor = AppColors.red,
    this.enablePulse = true,
    this.tooltip,
  });

  @override
  State<GlassPlayerPlayButton> createState() => _GlassPlayerPlayButtonState();
}

class _GlassPlayerPlayButtonState extends State<GlassPlayerPlayButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOutCubic),
    );

    // Kích hoạt hào quang đập nhẹ khi tạm dừng hoặc đang loading
    if (widget.enablePulse && (!widget.isPlaying || widget.isLoading)) {
      _pulseController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant GlassPlayerPlayButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    final shouldPulse = widget.enablePulse && (!widget.isPlaying || widget.isLoading);
    if (shouldPulse && !_pulseController.isAnimating) {
      _pulseController.repeat();
    } else if (!shouldPulse && _pulseController.isAnimating) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails _) {
    if (widget.onPressed == null) return;
    setState(() => _isPressed = true);
    HapticFeedback.lightImpact();
  }

  void _handleTapUp(TapUpDetails _) {
    if (widget.onPressed == null) return;
    setState(() => _isPressed = false);
  }

  void _handleTapCancel() {
    if (widget.onPressed == null) return;
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final double buttonSize = widget.size;

    Widget buttonContent = Stack(
      alignment: Alignment.center,
      children: [
        // 1. Vòng hào quang phập phồng (Pulse Glow Ring)
        if (widget.enablePulse)
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              final double value = _pulseAnimation.value;
              final double ringSize = buttonSize + (value * 24.0);
              final double opacity = (1.0 - value) * 0.45;
              return Container(
                width: ringSize,
                height: ringSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.glowColor.withValues(alpha: opacity.clamp(0.0, 1.0)),
                    width: 2.0 * (1.0 - value),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.glowColor.withValues(alpha: (opacity * 0.6).clamp(0.0, 1.0)),
                      blurRadius: 18.0 * value,
                      spreadRadius: 2.0 * value,
                    ),
                  ],
                ),
              );
            },
          ),

        // 2. Bề mặt khối kính mờ quang học tròn hoàn hảo (Snell 1.48, Blur 20.0)
        GlassSurface.circle(
          size: buttonSize,
          blur: 20.0,
          refractiveIndex: 1.48,
          thickness: 48.0,
          tintColor: const Color(0x33141414), // Nền kính điện ảnh đen mờ
          borderTint: const Color(0x33FFFFFF), // Viền rim 20% sáng
          shadows: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.6),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
          child: Center(
            child: widget.isLoading
                ? SizedBox(
                    width: buttonSize * 0.42,
                    height: buttonSize * 0.42,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.8,
                      valueColor: AlwaysStoppedAnimation<Color>(widget.iconColor),
                    ),
                  )
                : Icon(
                    widget.isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    size: buttonSize * 0.52,
                    color: widget.iconColor,
                  ),
          ),
        ),
      ],
    );

    // Bọc hiệu ứng nhún lò xo (Micro-spring Scale 0.92x)
    return Semantics(
      button: true,
      label: widget.tooltip ?? (widget.isPlaying ? 'Tạm dừng video' : 'Phát video'),
      child: Tooltip(
        message: widget.tooltip ?? (widget.isPlaying ? 'Tạm dừng' : 'Phát'),
        child: GestureDetector(
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          onTap: widget.onPressed,
          behavior: HitTestBehavior.opaque,
          child: AnimatedScale(
            scale: _isPressed ? 0.92 : 1.0,
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            child: SizedBox(
              width: buttonSize + 28, // Đủ diện tích chứa hào quang pulse
              height: buttonSize + 28,
              child: Center(child: buttonContent),
            ),
          ),
        ),
      ),
    );
  }
}
