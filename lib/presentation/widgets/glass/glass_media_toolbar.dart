import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../services/theme_service.dart';
import 'glass_surface.dart';
import 'openflix_morph_icon.dart';

/// Thanh công cụ điều khiển phương tiện kính mờ quang học (Glass Media Toolbar - Giai đoạn 3).
/// Thiết kế thanh ngang Capsule kính mờ điện ảnh:
/// - Chiều cao: 48px, bo góc hoàn toàn 24px (Capsule).
/// - Khúc xạ Snell: 1.45, Blur: 16.0, viền Hairline Rim sáng ánh kim.
/// - Mỗi nút bên trong đảm bảo Touch target >= 44x44px và phản hồi xúc giác [HapticFeedback.lightImpact].
/// - Đảm bảo Zero UI Regression và tương thích tốt trên cả màn hình hẹp (320px) lẫn tablet.
class GlassMediaToolbar extends StatelessWidget {
  final VoidCallback? onReplay10;
  final VoidCallback? onForward10;
  final VoidCallback? onFitModeToggle;
  final String fitModeLabel;
  final IconData? fitModeIcon;
  final VoidCallback? onSpeedToggle;
  final double currentSpeed;
  final VoidCallback? onMuteToggle;
  final bool isMuted;
  final VoidCallback? onFullscreenToggle;
  final bool isFullscreen;
  final double height;
  final Color tintColor;

  const GlassMediaToolbar({
    super.key,
    this.onReplay10,
    this.onForward10,
    this.onFitModeToggle,
    this.fitModeLabel = '16:9',
    this.fitModeIcon,
    this.onSpeedToggle,
    this.currentSpeed = 1.0,
    this.onMuteToggle,
    this.isMuted = false,
    this.onFullscreenToggle,
    this.isFullscreen = false,
    this.height = 48.0,
    this.tintColor = const Color(0x33141414),
  });

  @override
  Widget build(BuildContext context) {
    return GlassSurface.capsule(
      height: height,
      blur: 16.0,
      refractiveIndex: 1.45,
      thickness: 36.0,
      tintColor: tintColor,
      borderTint: const Color(0x26FFFFFF),
      shadows: const [
        BoxShadow(
          color: Color(0x55000000),
          offset: Offset(0, 4),
          blurRadius: 16,
          spreadRadius: -2,
        ),
      ],
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 1. Nút Tua lùi 10 giây
          if (onReplay10 != null)
            _ToolbarIconButton(
              icon: Icons.replay_10_rounded,
              tooltip: 'Tua lùi 10s',
              onPressed: onReplay10,
            ),

          // 2. Nút Tỷ lệ khung hình / Tràn viền
          if (onFitModeToggle != null)
            _ToolbarTextIconButton(
              icon: fitModeIcon ?? Icons.aspect_ratio_rounded,
              label: fitModeLabel,
              tooltip: 'Khung hình: $fitModeLabel',
              onPressed: onFitModeToggle,
            ),

          // 3. Nút Tốc độ phát (Speed)
          if (onSpeedToggle != null)
            _ToolbarBadgeButton(
              label: '${currentSpeed.toStringAsFixed(currentSpeed % 1 == 0 ? 0 : 2)}x',
              tooltip: 'Tốc độ: ${currentSpeed}x',
              onPressed: onSpeedToggle,
            ),

          // 4. Nút Âm lượng / Tắt tiếng (Mute)
          if (onMuteToggle != null)
            _ToolbarIconButton(
              icon: isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
              tooltip: isMuted ? 'Bật âm thanh' : 'Tắt tiếng',
              activeColor: isMuted ? ThemeService.instance.primaryColor : null,
              onPressed: onMuteToggle,
            ),

          // 5. Nút Tua tới 10 giây
          if (onForward10 != null)
            _ToolbarIconButton(
              icon: Icons.forward_10_rounded,
              tooltip: 'Tua tới 10s',
              onPressed: onForward10,
            ),

          // 6. Nút Toàn màn hình (Fullscreen)
          if (onFullscreenToggle != null)
            _ToolbarIconButton(
              icon: isFullscreen ? Icons.fullscreen_exit_rounded : Icons.fullscreen_rounded,
              tooltip: isFullscreen ? 'Thu nhỏ màn hình' : 'Toàn màn hình',
              onPressed: onFullscreenToggle,
            ),
        ],
      ),
    );
  }
}

/// Nút Icon bên trong Toolbar (Touch target >= 44x44px, Haptic Feedback)
class _ToolbarIconButton extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final Color? activeColor;

  const _ToolbarIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.activeColor,
  });

  @override
  State<_ToolbarIconButton> createState() => _ToolbarIconButtonState();
}

class _ToolbarIconButtonState extends State<_ToolbarIconButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.tooltip,
      child: Tooltip(
        message: widget.tooltip,
        child: GestureDetector(
          onTapDown: (_) {
            if (widget.onPressed == null) return;
            setState(() => _isPressed = true);
            HapticFeedback.lightImpact();
          },
          onTapUp: (_) {
            if (widget.onPressed == null) return;
            setState(() => _isPressed = false);
          },
          onTapCancel: () {
            if (widget.onPressed == null) return;
            setState(() => _isPressed = false);
          },
          onTap: widget.onPressed,
          behavior: HitTestBehavior.opaque,
          child: AnimatedScale(
            scale: _isPressed ? 0.88 : 1.0,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOutCubic,
            child: Container(
              constraints: const BoxConstraints(minWidth: 44.0, minHeight: 44.0),
              alignment: Alignment.center,
              child: OpenFlixMorphIcon.smooth(
                icon: widget.icon,
                color: widget.activeColor ?? Colors.white.withValues(alpha: 0.90),
                size: 22.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Nút Icon kèm nhãn ngắn gọn bên trong Toolbar
class _ToolbarTextIconButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final String tooltip;
  final VoidCallback? onPressed;

  const _ToolbarTextIconButton({
    required this.icon,
    required this.label,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  State<_ToolbarTextIconButton> createState() => _ToolbarTextIconButtonState();
}

class _ToolbarTextIconButtonState extends State<_ToolbarTextIconButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.tooltip,
      child: Tooltip(
        message: widget.tooltip,
        child: GestureDetector(
          onTapDown: (_) {
            if (widget.onPressed == null) return;
            setState(() => _isPressed = true);
            HapticFeedback.lightImpact();
          },
          onTapUp: (_) {
            if (widget.onPressed == null) return;
            setState(() => _isPressed = false);
          },
          onTapCancel: () {
            if (widget.onPressed == null) return;
            setState(() => _isPressed = false);
          },
          onTap: widget.onPressed,
          behavior: HitTestBehavior.opaque,
          child: AnimatedScale(
            scale: _isPressed ? 0.90 : 1.0,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOutCubic,
            child: Container(
              constraints: const BoxConstraints(minWidth: 46.0, minHeight: 44.0),
              padding: const EdgeInsets.symmetric(horizontal: 6.0),
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  OpenFlixMorphIcon.smooth(
                    icon: widget.icon,
                    color: Colors.white.withValues(alpha: 0.90),
                    size: 18.0,
                  ),
                  const SizedBox(width: 4.0),
                  Text(
                    widget.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.2,
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

/// Nút Badge chữ (ví dụ tốc độ 1.0x, 1.25x...)
class _ToolbarBadgeButton extends StatefulWidget {
  final String label;
  final String tooltip;
  final VoidCallback? onPressed;

  const _ToolbarBadgeButton({
    required this.label,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  State<_ToolbarBadgeButton> createState() => _ToolbarBadgeButtonState();
}

class _ToolbarBadgeButtonState extends State<_ToolbarBadgeButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.tooltip,
      child: Tooltip(
        message: widget.tooltip,
        child: GestureDetector(
          onTapDown: (_) {
            if (widget.onPressed == null) return;
            setState(() => _isPressed = true);
            HapticFeedback.lightImpact();
          },
          onTapUp: (_) {
            if (widget.onPressed == null) return;
            setState(() => _isPressed = false);
          },
          onTapCancel: () {
            if (widget.onPressed == null) return;
            setState(() => _isPressed = false);
          },
          onTap: widget.onPressed,
          behavior: HitTestBehavior.opaque,
          child: AnimatedScale(
            scale: _isPressed ? 0.90 : 1.0,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOutCubic,
            child: Container(
              constraints: const BoxConstraints(minWidth: 44.0, minHeight: 44.0),
              alignment: Alignment.center,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 3.0),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.20),
                    width: 0.6,
                  ),
                ),
                child: Text(
                  widget.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
