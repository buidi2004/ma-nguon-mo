import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../theme/app_theme.dart';

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
  }) {
    return GlassChipButton(
      key: key,
      label: label,
      isSelected: isSelected,
      onSelected: onSelected,
      icon: icon,
      count: count,
      showCheckmark: true,
      activeColor: AppColors.red,
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
    final effectiveActiveColor = widget.activeColor ?? AppColors.red;
    final isInteractive = widget.onSelected != null;

    final Color backgroundColor = widget.isSelected
        ? effectiveActiveColor.withValues(alpha: 0.28)
        : (_isPressed
            ? Colors.white.withValues(alpha: 0.14)
            : (_isHovered
                ? Colors.white.withValues(alpha: 0.10)
                : const Color(0x1A2A2A2A)));

    final Color borderColor = widget.isSelected
        ? effectiveActiveColor.withValues(alpha: 0.85)
        : (_isHovered || _isPressed
            ? Colors.white.withValues(alpha: 0.32)
            : Colors.white.withValues(alpha: 0.14));

    final Color textColor = widget.isSelected
        ? (widget.activeTextColor ?? Colors.white)
        : (isInteractive ? const Color(0xFFCCCCCC) : const Color(0xFF757575));

    final List<BoxShadow> shadows = widget.isSelected
        ? [
            BoxShadow(
              color: effectiveActiveColor.withValues(alpha: 0.35),
              blurRadius: 10,
              spreadRadius: -1,
              offset: const Offset(0, 2),
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
                    Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: textColor,
                    ),
                    const SizedBox(width: 6),
                  ] else if (widget.icon != null) ...[
                    Icon(
                      widget.icon,
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
                      fontWeight:
                          widget.isSelected ? FontWeight.bold : FontWeight.w500,
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
                          fontSize: 10.5,
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
