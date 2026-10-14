import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../theme/app_theme.dart';
import 'glass_optical_tokens.dart';
import 'glass_surface.dart';

enum GlassButtonStyle {
  /// Kính trắng trong suốt, chữ tối màu (dành cho Play/Tiếp tục xem)
  primaryWhite,

  /// Kính ánh đỏ Netflix, chữ trắng (dành cho CTA Đăng ký / VIP / Điểm nhấn thương hiệu)
  brandRed,

  /// Kính xám khói trong suốt, chữ trắng (dành cho Thêm danh sách / Chi tiết / Tải xuống)
  neutralDark,

  /// Kính viền mờ tối giản
  ghost,
}

/// Nút bấm tương tác kính mờ quang học (Optical Frosted Glass Button).
/// Tích hợp phản hồi xúc giác (Haptic Feedback), hoạt ảnh nhún nhẹ (Micro-scale 0.96x),
/// trạng thái đang tải (Loading), và viền vát sáng ánh kim.
class GlassButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final GlassButtonStyle style;
  final double height;
  final double? width;
  final double borderRadius;
  final bool isCapsule;
  final EdgeInsetsGeometry padding;
  final bool? useBackdropFilter;

  const GlassButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.style = GlassButtonStyle.neutralDark,
    this.height = 48.0,
    this.width,
    this.borderRadius = 12.0,
    this.isCapsule = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 20.0),
    this.useBackdropFilter,
  });

  /// Biến thể White Glass: Nút kính trắng sáng, chữ tối màu - hành động chính
  const GlassButton.primary({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.height = 48.0,
    this.width,
    this.borderRadius = 12.0,
    this.isCapsule = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 20.0),
    this.useBackdropFilter,
  }) : style = GlassButtonStyle.primaryWhite;

  /// Biến thể Brand Red: Nút kính ánh đỏ Netflix - CTA quan trọng
  const GlassButton.brand({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.height = 48.0,
    this.width,
    this.borderRadius = 12.0,
    this.isCapsule = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 20.0),
    this.useBackdropFilter,
  }) : style = GlassButtonStyle.brandRed;

  /// Biến thể Neutral: Nút kính xám trong suốt, chữ trắng
  const GlassButton.neutral({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.height = 48.0,
    this.width,
    this.borderRadius = 12.0,
    this.isCapsule = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 20.0),
    this.useBackdropFilter,
  }) : style = GlassButtonStyle.neutralDark;

  /// Biến thể Capsule Pill: Nút hình viên thuốc bo cong hoàn toàn
  const GlassButton.capsule({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.style = GlassButtonStyle.neutralDark,
    this.height = 44.0,
    this.width,
    this.padding = const EdgeInsets.symmetric(horizontal: 22.0),
    this.useBackdropFilter,
  }) : borderRadius = 999.0,
       isCapsule = true;

  @override
  State<GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<GlassButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnimation;

  bool get _isEnabled => widget.onPressed != null && !widget.isLoading;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 110),
      reverseDuration: const Duration(milliseconds: 140),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
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
    final styleConfig = _resolveStyleConfig(widget.style);

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(scale: _scaleAnimation.value, child: child);
      },
      child: Opacity(
        opacity: _isEnabled ? 1.0 : 0.45,
        child: GestureDetector(
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          onTap: _isEnabled ? widget.onPressed : null,
          behavior: HitTestBehavior.opaque,
          child: GlassSurface(
            width: widget.width,
            height: widget.height,
            borderRadius: widget.borderRadius,
            isCapsule: widget.isCapsule,
            useBackdropFilter: widget.useBackdropFilter,
            tintColor: styleConfig.tintColor,
            blur: styleConfig.blur,
            refractiveIndex: styleConfig.refractiveIndex,
            thickness: styleConfig.thickness,
            customBorder: styleConfig.border,
            padding: widget.padding,
            child: Center(
              child: widget.isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          styleConfig.textColor,
                        ),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(
                            widget.icon,
                            size: 20,
                            color: styleConfig.textColor,
                          ),
                          const SizedBox(width: 8),
                        ],
                        Flexible(
                          child: Text(
                            widget.text,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: styleConfig.textColor,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                              shadows: styleConfig.textShadow,
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

  _StyleConfig _resolveStyleConfig(GlassButtonStyle style) {
    switch (style) {
      case GlassButtonStyle.primaryWhite:
        return _StyleConfig(
          tintColor: const Color(0xE6FFFFFF), // Kính trắng phủ mờ cao
          textColor: const Color(0xFF141414), // Chữ đen tương phản sắc nét
          blur: 10.0,
          refractiveIndex: 1.82,
          thickness: 56.0,
          border: Border.all(color: Colors.white, width: 0.8),
          textShadow: null,
        );

      case GlassButtonStyle.brandRed:
        return _StyleConfig(
          tintColor: AppColors.red.withValues(alpha: 0.40),
          textColor: Colors.white,
          blur: 8.5,
          refractiveIndex: 1.80,
          thickness: 52.0,
          border: Border.all(
            color: const Color(0xFFFF4D4D).withValues(alpha: 0.55),
            width: GlassOpticalTokens.hairlineRimWidth,
          ),
          textShadow: const [Shadow(color: Color(0x88000000), blurRadius: 4)],
        );

      case GlassButtonStyle.neutralDark:
        return _StyleConfig(
          tintColor: const Color(0x352A2A2A),
          textColor: Colors.white,
          blur: 8.5,
          refractiveIndex: 1.78,
          thickness: 48.0,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.22),
            width: GlassOpticalTokens.hairlineRimWidth,
          ),
          textShadow: const [Shadow(color: Color(0xAA000000), blurRadius: 4)],
        );

      case GlassButtonStyle.ghost:
        return _StyleConfig(
          tintColor: const Color(0x12FFFFFF),
          textColor: Colors.white,
          blur: 6.0,
          refractiveIndex: 1.65,
          thickness: 30.0,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.15),
            width: GlassOpticalTokens.subtleRimWidth,
          ),
          textShadow: const [Shadow(color: Color(0xAA000000), blurRadius: 3)],
        );
    }
  }
}

class _StyleConfig {
  final Color tintColor;
  final Color textColor;
  final double blur;
  final double refractiveIndex;
  final double thickness;
  final BoxBorder border;
  final List<Shadow>? textShadow;

  const _StyleConfig({
    required this.tintColor,
    required this.textColor,
    required this.blur,
    required this.refractiveIndex,
    required this.thickness,
    required this.border,
    this.textShadow,
  });
}
