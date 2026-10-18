import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../services/theme_service.dart';

/// Mục phân đoạn bên trong [GlassSegmentedControl]
class GlassSegmentItem<T> {
  final T value;
  final String label;
  final IconData? icon;
  final int? badgeCount;

  const GlassSegmentItem({
    required this.value,
    required this.label,
    this.icon,
    this.badgeCount,
  });
}

/// Bộ chuyển mạch phân đoạn viên thuốc kính mờ (Optical Glass Segmented Control).
/// Sử dụng cho chuyển đổi Tab phụ, chọn Mùa phim (Season 1/2), định dạng (Phim lẻ / Phim bộ):
/// - Con trượt viên thuốc nổi (Gliding Pill Indicator) lướt êm ái [Curves.easeOutQuart].
/// - Nền kính quang học nền mờ nhẹ, viền sáng hairline kim loại.
/// - Phản hồi xúc giác [HapticFeedback.selectionClick].
/// - Tự động đo đạc layout thích ứng linh hoạt theo độ rộng màn hình.
class GlassSegmentedControl<T> extends StatefulWidget {
  final List<GlassSegmentItem<T>> items;
  final T selectedValue;
  final ValueChanged<T> onValueChanged;
  final double height;
  final Color? activePillColor;
  final Color? activeTextColor;
  final Color? inactiveTextColor;
  final bool hasGlow;
  final bool enableHaptic;
  final EdgeInsetsGeometry padding;

  const GlassSegmentedControl({
    super.key,
    required this.items,
    required this.selectedValue,
    required this.onValueChanged,
    this.height = 44.0,
    this.activePillColor,
    this.activeTextColor,
    this.inactiveTextColor,
    this.hasGlow = true,
    this.enableHaptic = true,
    this.padding = const EdgeInsets.all(4.0),
  }) : assert(items.length >= 2, 'Cần ít nhất 2 phân đoạn');

  /// Phương thức tiện ích cho danh sách chuỗi đơn giản
  static GlassSegmentedControl<String> fromStrings({
    Key? key,
    required List<String> segments,
    required String selectedSegment,
    required ValueChanged<String> onSegmentChanged,
    double height = 44.0,
    Color? activePillColor,
    Color? activeTextColor,
    Color? inactiveTextColor,
    bool hasGlow = true,
    bool enableHaptic = true,
    EdgeInsetsGeometry padding = const EdgeInsets.all(4.0),
  }) {
    return GlassSegmentedControl<String>(
      key: key,
      items: segments
          .map((s) => GlassSegmentItem<String>(value: s, label: s))
          .toList(),
      selectedValue: selectedSegment,
      onValueChanged: onSegmentChanged,
      height: height,
      activePillColor: activePillColor,
      activeTextColor: activeTextColor,
      inactiveTextColor: inactiveTextColor,
      hasGlow: hasGlow,
      enableHaptic: enableHaptic,
      padding: padding,
    );
  }

  @override
  State<GlassSegmentedControl<T>> createState() =>
      _GlassSegmentedControlState<T>();
}

class _GlassSegmentedControlState<T> extends State<GlassSegmentedControl<T>> {
  int _pressedIndex = -1;

  int get _selectedIndex {
    final idx = widget.items.indexWhere((it) => it.value == widget.selectedValue);
    return idx >= 0 ? idx : 0;
  }

  void _handleSegmentTap(int index) {
    if (index == _selectedIndex) return;
    if (widget.enableHaptic) {
      HapticFeedback.selectionClick();
    }
    widget.onValueChanged(widget.items[index].value);
  }

  @override
  Widget build(BuildContext context) {
    final effectiveActiveColor = widget.activePillColor ?? ThemeService.instance.primaryColor;
    final borderRadius = BorderRadius.circular(widget.height / 2);

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final horizontalPadding = widget.padding.horizontal;
        final availableWidth = (totalWidth - horizontalPadding).clamp(0.0, double.infinity);
        final segmentWidth = availableWidth / widget.items.length;
        final innerHeight = (widget.height - widget.padding.vertical).clamp(0.0, double.infinity);

        return Container(
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            color: const Color(0x331E1E1E),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
              width: 1.0,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          padding: widget.padding,
          child: Stack(
            children: [
              // 1. VIÊN THUỐC KÍNH NỔI LƯỚT MƯỢT MÀ (Gliding Pill Indicator)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutQuart,
                left: _selectedIndex * segmentWidth,
                top: 0,
                width: segmentWidth,
                height: innerHeight,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(innerHeight / 2),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        effectiveActiveColor.withValues(alpha: 0.95),
                        effectiveActiveColor,
                      ],
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.35),
                      width: 1.0,
                    ),
                    boxShadow: widget.hasGlow
                        ? [
                            BoxShadow(
                              color: effectiveActiveColor.withValues(alpha: 0.45),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                ),
              ),

              // 2. HÀNG CÁC PHÂN ĐOẠN TƯƠNG TÁC NẰM ĐÈ LÊN TRÊN
              Row(
                children: List.generate(widget.items.length, (index) {
                  final item = widget.items[index];
                  final isSelected = index == _selectedIndex;
                  final isPressed = index == _pressedIndex;

                  final textColor = isSelected
                      ? (widget.activeTextColor ?? Colors.white)
                      : (widget.inactiveTextColor ?? const Color(0xFFB3B3B3));

                  return Expanded(
                    child: Semantics(
                      button: true,
                      selected: isSelected,
                      label: item.label,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTapDown: (_) => setState(() => _pressedIndex = index),
                        onTapUp: (_) => setState(() => _pressedIndex = -1),
                        onTapCancel: () => setState(() => _pressedIndex = -1),
                        onTap: () => _handleSegmentTap(index),
                        child: AnimatedScale(
                          scale: isPressed ? 0.94 : 1.0,
                          duration: const Duration(milliseconds: 140),
                          curve: Curves.easeOutCubic,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (item.icon != null) ...[
                                    Icon(
                                      item.icon,
                                      size: 16,
                                      color: textColor,
                                    ),
                                    const SizedBox(width: 4),
                                  ],
                                  Flexible(
                                    child: Text(
                                      item.label,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 13,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.w500,
                                        letterSpacing: 0.1,
                                      ),
                                    ),
                                  ),
                                  if (item.badgeCount != null) ...[
                                    const SizedBox(width: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 5,
                                      vertical: 1.5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Colors.white.withValues(alpha: 0.25)
                                          : Colors.white.withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${item.badgeCount}',
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 10,
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
                  ),
                );
              }),
              ),
            ],
          ),
        );
      },
    );
  }
}
