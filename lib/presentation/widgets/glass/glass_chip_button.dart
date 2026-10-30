import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../services/theme_service.dart';
import '../../../theme/app_theme.dart';
import 'openflix_morph_icon.dart';

/// Thẻ lọc tương tác bề mặt kính mờ (Optical Frosted Glass Chip Button).
/// Sử dụng cho bộ lọc thể loại, quốc gia, năm phát hành, xếp hạng độ tuổi.
/// - Hỗ trợ trạng thái Đã chọn (Selected) vs Chưa chọn (Unselected).
/// - Viền vát quang học (Hairline Rim) và bóng phát quang (Halo Glow).
/// - Phản hồi xúc giác [HapticFeedback.selectionClick].
/// - Hoạt ảnh co giãn nhún lò xo (Micro-scale 0.95x).
class GlassChipButton extends StatefulWidget {
  final String label;
  final bool isSelected;
  final ValueChanged<bool>? onSelected;
  final IconData? icon;
  final int? count;
  final Color? activeColor;
  final Color? activeTextColor;
  final double height;
  final EdgeInsetsGeometry padding;
  final bool showCheckmark;
  final bool enableHaptic;

  const GlassChipButton({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onSelected,
    this.icon,
    this.count,
    this.activeColor,
    this.activeTextColor,
    this.height = 36.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 14.0),
    this.showCheckmark = false,
    this.enableHaptic = true,
  });

  /// Factory tiện ích cho Thẻ lọc thể loại / danh mục (Genre filter chip)
  factory GlassChipButton.filter({
    Key? key,
    required String label,
    required bool isSelected,
    required ValueChanged<bool>? onSelected,
    IconData? icon,
    int? count,
    Color? activeColor,
  }) {
    return GlassChipButton(
      key: key,
      label: label,
      isSelected: isSelected,
      onSelected: onSelected,
      icon: icon,
      count: count,
      showCheckmark: true,
      activeColor: activeColor,
    );
  }

  @override
  State<GlassChipButton> createState() => _GlassChipButtonState();
}

class _GlassChipButtonState extends State<GlassChipButton> {
  bool _isPressed = false;
  bool _isHovered = false;

  void _handleTapDown(TapDownDetails _) {
    if (widget.onSelected == null) return;
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails _) {
    setState(() => _isPressed = false);
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  void _handleTap() {
    if (widget.onSelected == null) return;
    if (widget.enableHaptic) {
      HapticFeedback.selectionClick();
    }
    widget.onSelected!(!widget.isSelected);
  }

  @override
  Widget build(BuildContext context) {
    final isBlue = ThemeService.instance.isWindowsBlue;
    final effectiveActiveColor =
        widget.activeColor ??
        (isBlue ? const Color(0xFF006BA6) : ThemeService.instance.primaryColor);
    final isInteractive = widget.onSelected != null;
    final homePalette = Theme.of(context).extension<HomeScreenPalette>();

    final Color unselectedRestBg =
        homePalette?.surface ??
        (isBlue ? const Color(0xCC0A2433) : const Color(0x80262626));
    final Color unselectedHoverBg =
        homePalette?.surface ??
        (isBlue ? const Color(0xD90E3044) : const Color(0x99303030));
    final Color unselectedPressBg =
        homePalette?.surface ??
        (isBlue ? const Color(0xE6123B52) : const Color(0xB3383838));

    final Color backgroundColor = widget.isSelected
        ? (isBlue
              ? effectiveActiveColor.withValues(alpha: 0.92)
              : (homePalette != null
                    ? effectiveActiveColor
                    : effectiveActiveColor.withValues(alpha: 0.78)))
        : (_isPressed
              ? unselectedPressBg
              : (_isHovered ? unselectedHoverBg : unselectedRestBg));

    final Color borderColor = widget.isSelected
        ? (isBlue
              ? const Color(0xFF66C7F4)
              : effectiveActiveColor.withValues(alpha: 0.90))
        : (_isHovered || _isPressed
              ? (homePalette?.textMuted ??
                    (isBlue
                        ? const Color(0x805AD2F4)
                        : Colors.white.withValues(alpha: 0.36)))
              : (homePalette?.divider ??
                    (isBlue
                        ? const Color(0x4D5AD2F4)
                        : Colors.white.withValues(alpha: 0.20))));

    final Color textColor = widget.isSelected
        ? (widget.activeTextColor ?? (homePalette?.textPrimary ?? Colors.white))
        : (homePalette?.textSecondary ??
              (isInteractive
                  ? (isBlue
                        ? const Color(0xFFE2F1FF)
                        : const Color(0xFFE5E5E5))
                  : (isBlue
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF8A8A8A))));

    final List<BoxShadow> shadows = widget.isSelected
        ? [
            BoxShadow(
              color: effectiveActiveColor.withValues(alpha: 0.24),
              blurRadius: 6,
              spreadRadius: 0,
              offset: Offset.zero,
            ),
          ]
        : [];

    return Semantics(
      button: true,
      selected: widget.isSelected,
      enabled: isInteractive,
      label: widget.label,
      child: FocusableActionDetector(
        onShowHoverHighlight: (v) => setState(() => _isHovered = v),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: isInteractive ? _handleTapDown : null,
          onTapUp: isInteractive ? _handleTapUp : null,
          onTapCancel: isInteractive ? _handleTapCancel : null,
          onTap: isInteractive ? _handleTap : null,
          child: AnimatedScale(
            scale: _isPressed ? 0.95 : (_isHovered ? 1.03 : 1.0),
            duration: const Duration(milliseconds: 140),
            curve: Curves.easeOutCubic,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              height: widget.height,
              padding: widget.padding,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.height / 2),
                color: backgroundColor,
                border: Border.all(color: borderColor, width: 1.0),
                boxShadow: shadows,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Icon đầu thẻ (nếu có) hoặc Checkmark khi đã chọn
                  if (widget.showCheckmark && widget.isSelected) ...[
                    OpenFlixMorphIcon.snappy(
                      icon: Icons.check_rounded,
                      size: 16,
                      color: textColor,
                    ),
                    const SizedBox(width: 6),
                  ] else if (widget.icon != null) ...[
                    OpenFlixMorphIcon.snappy(
                      icon: widget.icon!,
                      size: 16,
                      color: textColor,
                    ),
                    const SizedBox(width: 6),
                  ],

                  // Nhãn thẻ
                  Text(
                    widget.label,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 13,
                      fontWeight: widget.isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                      letterSpacing: 0.1,
                    ),
                  ),

                  // Số lượng phim kèm theo (badge count)
                  if (widget.count != null) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1.5,
                      ),
                      decoration: BoxDecoration(
                        color: widget.isSelected
                            ? Colors.white.withValues(alpha: 0.22)
                            : Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${widget.count}',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
