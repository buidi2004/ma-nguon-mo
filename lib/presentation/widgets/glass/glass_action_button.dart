import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../services/theme_service.dart';
import 'openflix_morph_icon.dart';

/// Nút hành động tương tác dọc kính mờ (Vertical Optical Glass Action Button).
/// Thiết kế chuẩn điện ảnh theo quy chuẩn Netflix:
/// - Bố cục dọc: Icon phía trên (24px) và nhãn chữ phía dưới (11sp).
/// - Phản hồi xúc giác rung nhẹ [HapticFeedback.lightImpact].
/// - Hoạt ảnh nhún lò xo (Micro-scale 0.94x) khi chạm.
/// - Đảm bảo kích thước cảm ứng tối thiểu đạt chuẩn Accessibility (>= 48x48px).
/// - Bề mặt kính quang học nền mờ nhẹ, viền vát sáng ánh kim.
class GlassActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final IconData? activeIcon;
  final bool isActive;
  final Color? iconColor;
  final Color? activeIconColor;
  final Color? textColor;
  final Color? activeTextColor;
  final double iconSize;
  final double fontSize;
  final double minWidth;
  final double minHeight;
  final bool hasGlassHalo;
  final String? tooltip;
  final bool enableHaptic;

  const GlassActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.activeIcon,
    this.isActive = false,
    this.iconColor,
    this.activeIconColor,
    this.textColor,
    this.activeTextColor,
    this.iconSize = 24.0,
    this.fontSize = 11.0,
    this.minWidth = 52.0,
    this.minHeight = 48.0,
    this.hasGlassHalo = true,
    this.tooltip,
    this.enableHaptic = true,
  });

  /// Factory tiện ích: Nút Lưu / Thêm vào Danh sách (Bookmark / My List)
  factory GlassActionButton.bookmark({
    Key? key,
    required bool isBookmarked,
    required VoidCallback? onPressed,
    String label = 'Thêm vào DS',
    String? tooltip,
    Color? activeIconColor,
  }) {
    return GlassActionButton(
      key: key,
      label: label,
      icon: Icons.bookmark_outline_rounded,
      activeIcon: Icons.bookmark_rounded,
      isActive: isBookmarked,
      activeIconColor: activeIconColor,
      onPressed: onPressed,
      tooltip: tooltip ?? (isBookmarked ? 'Xóa khỏi danh sách' : 'Thêm vào danh sách'),
    );
  }

  /// Factory tiện ích: Nút Chia sẻ (Share)
  factory GlassActionButton.share({
    Key? key,
    required VoidCallback? onPressed,
    String label = 'Chia sẻ',
    String? tooltip,
  }) {
    return GlassActionButton(
      key: key,
      label: label,
      icon: Icons.share_outlined,
      onPressed: onPressed,
      tooltip: tooltip ?? 'Chia sẻ phim',
    );
  }

  /// Factory tiện ích: Nút Tải xuống (Download)
  factory GlassActionButton.download({
    Key? key,
    required bool isDownloaded,
    required VoidCallback? onPressed,
    String label = 'Tải xuống',
    String? tooltip,
  }) {
    return GlassActionButton(
      key: key,
      label: isDownloaded ? 'Đã tải' : label,
      icon: Icons.download_rounded,
      activeIcon: Icons.file_download_done_rounded,
      isActive: isDownloaded,
      activeIconColor: const Color(0xFF00E5FF),
      onPressed: onPressed,
      tooltip: tooltip ?? (isDownloaded ? 'Đã tải xuống' : 'Tải phim về máy'),
    );
  }

  /// Factory tiện ích: Nút Nhắc tôi (Remind Me)
  factory GlassActionButton.remindMe({
    Key? key,
    required bool isReminded,
    required VoidCallback? onPressed,
    String label = 'Nhắc tôi',
    String? tooltip,
  }) {
    return GlassActionButton(
      key: key,
      label: label,
      icon: Icons.notifications_none_rounded,
      activeIcon: Icons.notifications_active_rounded,
      isActive: isReminded,
      activeIconColor: const Color(0xFFFFD700),
      onPressed: onPressed,
      tooltip: tooltip ?? (isReminded ? 'Hủy nhận thông báo' : 'Nhận thông báo khi có tập mới'),
    );
  }

  /// Factory tiện ích: Nút Thích / Đánh giá (Like / Rate)
  factory GlassActionButton.like({
    Key? key,
    required bool isLiked,
    required VoidCallback? onPressed,
    String label = 'Thích',
    String? tooltip,
  }) {
    return GlassActionButton(
      key: key,
      label: label,
      icon: Icons.thumb_up_alt_outlined,
      activeIcon: Icons.thumb_up_alt_rounded,
      isActive: isLiked,
      activeIconColor: ThemeService.instance.primaryColor,
      onPressed: onPressed,
      tooltip: tooltip ?? (isLiked ? 'Bỏ thích' : 'Yêu thích bộ phim này'),
    );
  }

  @override
  State<GlassActionButton> createState() => _GlassActionButtonState();
}

class _GlassActionButtonState extends State<GlassActionButton> {
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
    final effectiveIcon = widget.isActive && widget.activeIcon != null
        ? widget.activeIcon!
        : widget.icon;

    final effectiveIconColor = widget.isActive
        ? (widget.activeIconColor ?? ThemeService.instance.primaryColor)
        : (widget.iconColor ?? Colors.white);

    final effectiveTextColor = widget.isActive
        ? (widget.activeTextColor ?? Colors.white)
        : (widget.textColor ?? const Color(0xFFB3B3B3));

    final isInteractive = widget.onPressed != null;

    Widget content = Semantics(
      button: true,
      enabled: isInteractive,
      selected: widget.isActive,
      label: widget.tooltip ?? widget.label,
      child: FocusableActionDetector(
        onShowHoverHighlight: (v) => setState(() => _isHovered = v),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: isInteractive ? _handleTapDown : null,
          onTapUp: isInteractive ? _handleTapUp : null,
          onTapCancel: isInteractive ? _handleTapCancel : null,
          onTap: isInteractive ? _handleTap : null,
          child: AnimatedScale(
            scale: _isPressed ? 0.94 : (_isHovered ? 1.04 : 1.0),
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOutCubic,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: widget.minWidth,
                minHeight: widget.minHeight,
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: widget.hasGlassHalo
                      ? (_isPressed
                          ? Colors.white.withValues(alpha: 0.12)
                          : (_isHovered
                              ? Colors.white.withValues(alpha: 0.08)
                              : Colors.transparent))
                      : Colors.transparent,
                  border: Border.all(
                    color: _isHovered || _isPressed
                        ? Colors.white.withValues(alpha: 0.18)
                        : Colors.transparent,
                    width: 0.8,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    OpenFlixMorphIcon.snappy(
                      icon: effectiveIcon,
                      size: widget.iconSize,
                      color: isInteractive
                          ? effectiveIconColor
                          : effectiveIconColor.withValues(alpha: 0.38),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isInteractive
                            ? effectiveTextColor
                            : effectiveTextColor.withValues(alpha: 0.38),
                        fontSize: widget.fontSize,
                        fontWeight:
                            widget.isActive ? FontWeight.w700 : FontWeight.w500,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ],
                ),
              ),
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
