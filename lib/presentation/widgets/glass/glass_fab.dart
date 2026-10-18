import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../services/theme_service.dart';

/// Nút hành động nổi bề mặt kính mờ (Optical Frosted Glass Floating Action Button).
/// - Dạng tròn cổ điển (56x56px) hoặc viên thuốc mở rộng (Extended Capsule).
/// - Tích hợp sẵn biến thể [GlassFAB.scrollToTop] tự động ẩn/hiện theo độ cuộn màn hình.
/// - Hiệu ứng ánh sáng viền sáng quang học (Hairline Rim) và bóng phát quang (Halo Glow).
/// - Phản hồi xúc giác [HapticFeedback.lightImpact] và hoạt ảnh nhún lò xo (Micro-scale 0.94x).
class GlassFAB extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final double size;
  final double? width;
  final double height;
  final bool isCircle;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? glowColor;
  final bool hasGlow;
  final String? tooltip;
  final bool enableHaptic;

  const GlassFAB({
    super.key,
    required this.child,
    required this.onPressed,
    this.size = 56.0,
    this.width,
    this.height = 56.0,
    this.isCircle = true,
    this.backgroundColor,
    this.borderColor,
    this.glowColor,
    this.hasGlow = true,
    this.tooltip,
    this.enableHaptic = true,
  });

  /// Factory tiện ích cho Nút tròn (Circular Glass FAB)
  factory GlassFAB.circle({
    Key? key,
    required IconData icon,
    required VoidCallback? onPressed,
    double size = 56.0,
    double iconSize = 24.0,
    Color iconColor = Colors.white,
    Color? backgroundColor,
    Color? glowColor,
    String? tooltip,
  }) {
    return GlassFAB(
      key: key,
      size: size,
      height: size,
      isCircle: true,
      onPressed: onPressed,
      backgroundColor: backgroundColor,
      glowColor: glowColor,
      tooltip: tooltip,
      child: Icon(icon, size: iconSize, color: iconColor),
    );
  }

  /// Factory tiện ích cho Nút mở rộng (Extended Capsule Glass FAB)
  factory GlassFAB.extended({
    Key? key,
    required String label,
    required IconData icon,
    required VoidCallback? onPressed,
    double height = 48.0,
    double iconSize = 20.0,
    Color iconColor = Colors.white,
    Color textColor = Colors.white,
    Color? backgroundColor,
    Color? glowColor,
    String? tooltip,
  }) {
    return GlassFAB(
      key: key,
      height: height,
      isCircle: false,
      onPressed: onPressed,
      backgroundColor: backgroundColor,
      glowColor: glowColor,
      tooltip: tooltip,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: iconSize, color: iconColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Factory tiện ích: Nút cuộn nhanh lên đầu trang (Scroll To Top Glass FAB).
  /// Tự động gắn listener theo dõi [controller] và chỉ hiển thị khi cuộn quá [threshold].
  static Widget scrollToTop({
    Key? key,
    required ScrollController controller,
    double threshold = 320.0,
    Duration duration = const Duration(milliseconds: 450),
    Curve curve = Curves.easeOutCubic,
    String tooltip = 'Lên đầu trang',
  }) {
    return _ScrollToTopGlassFAB(
      key: key,
      controller: controller,
      threshold: threshold,
      duration: duration,
      curve: curve,
      tooltip: tooltip,
    );
  }

  @override
  State<GlassFAB> createState() => _GlassFABState();
}

class _GlassFABState extends State<GlassFAB> {
  bool _isPressed = false;
  bool _isHovered = false;

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
      HapticFeedback.lightImpact();
    }
    widget.onPressed!();
  }

  @override
  Widget build(BuildContext context) {
    final isInteractive = widget.onPressed != null;
    final effectiveGlowColor = widget.glowColor ?? ThemeService.instance.primaryColor;

    final Color bgColor = widget.backgroundColor ??
        (_isPressed
            ? const Color(0x662A2A2A)
            : (_isHovered ? const Color(0x552A2A2A) : const Color(0x401E1E1E)));

    final Color bdrColor = widget.borderColor ??
        (_isHovered || _isPressed
            ? Colors.white.withValues(alpha: 0.40)
            : Colors.white.withValues(alpha: 0.20));

    final borderRadius = widget.isCircle
        ? BorderRadius.circular(widget.size / 2)
        : BorderRadius.circular(widget.height / 2);

    Widget content = Semantics(
      button: true,
      enabled: isInteractive,
      label: widget.tooltip,
      child: FocusableActionDetector(
        onShowHoverHighlight: (v) => setState(() => _isHovered = v),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: isInteractive ? _handleTapDown : null,
          onTapUp: isInteractive ? _handleTapUp : null,
          onTapCancel: isInteractive ? _handleTapCancel : null,
          onTap: isInteractive ? _handleTap : null,
          child: AnimatedScale(
            scale: _isPressed ? 0.93 : (_isHovered ? 1.05 : 1.0),
            duration: const Duration(milliseconds: 140),
            curve: Curves.easeOutCubic,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              width: widget.isCircle ? widget.size : widget.width,
              height: widget.isCircle ? widget.size : widget.height,
              decoration: BoxDecoration(
                borderRadius: borderRadius,
                color: bgColor,
                border: Border.all(color: bdrColor, width: 1.0),
                boxShadow: widget.hasGlow
                    ? [
                        BoxShadow(
                          color: effectiveGlowColor.withValues(
                            alpha: _isHovered ? 0.45 : 0.22,
                          ),
                          blurRadius: _isHovered ? 18 : 10,
                          offset: const Offset(0, 3),
                        ),
                        const BoxShadow(
                          color: Color(0x44000000),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Center(child: widget.child),
            ),
          ),
        ),
      ),
    );

    if (widget.tooltip != null) {
      content = Tooltip(
        message: widget.tooltip!,
        waitDuration: const Duration(milliseconds: 400),
        child: content,
      );
    }

    return content;
  }
}

/// Widget theo dõi ScrollController để hiển thị GlassFAB cuộn lên đầu trang
class _ScrollToTopGlassFAB extends StatefulWidget {
  final ScrollController controller;
  final double threshold;
  final Duration duration;
  final Curve curve;
  final String tooltip;

  const _ScrollToTopGlassFAB({
    super.key,
    required this.controller,
    required this.threshold,
    required this.duration,
    required this.curve,
    required this.tooltip,
  });

  @override
  State<_ScrollToTopGlassFAB> createState() => _ScrollToTopGlassFABState();
}

class _ScrollToTopGlassFABState extends State<_ScrollToTopGlassFAB> {
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_scrollListener);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_scrollListener);
    super.dispose();
  }

  void _scrollListener() {
    if (!widget.controller.hasClients) return;
    final isOver = widget.controller.offset > widget.threshold;
    if (isOver != _isVisible) {
      setState(() => _isVisible = isOver);
    }
  }

  void _scrollToTop() {
    if (!widget.controller.hasClients) return;
    widget.controller.animateTo(
      0.0,
      duration: widget.duration,
      curve: widget.curve,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutBack,
      child: AnimatedOpacity(
        opacity: _isVisible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: GlassFAB.circle(
          icon: Icons.keyboard_arrow_up_rounded,
          iconSize: 28,
          size: 50,
          tooltip: widget.tooltip,
          onPressed: _isVisible ? _scrollToTop : null,
        ),
      ),
    );
  }
}
