import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../services/theme_service.dart';
import 'glass_surface.dart';
import 'openflix_morph_icon.dart';

/// Thanh tìm kiếm kính mờ quang học động (Optical Dynamic Frosted Glass Search Bar).
///
/// Tự động chuyển đổi mượt mà độ mờ (Blur), vầng sáng (Glow) và viền khi Focus.
/// Tích hợp sẵn nút xoá nhanh (Clear) và phím tắt mở bộ lọc / tìm kiếm giọng nói.
class GlassDynamicSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onFilterTap;
  final VoidCallback? onVoiceTap;
  final String hintText;
  final double height;
  final bool autofocus;
  final FocusNode? focusNode;
  final EdgeInsetsGeometry padding;

  const GlassDynamicSearchBar({
    super.key,
    required this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onFilterTap,
    this.onVoiceTap,
    this.hintText = 'Tên phim, diễn viên, thể loại...',
    this.height = 48.0,
    this.autofocus = false,
    this.focusNode,
    this.padding = const EdgeInsets.symmetric(horizontal: 14.0),
  });

  @override
  State<GlassDynamicSearchBar> createState() => _GlassDynamicSearchBarState();
}

class _GlassDynamicSearchBarState extends State<GlassDynamicSearchBar> {
  late final FocusNode _internalFocusNode;
  bool _isFocused = false;
  bool _hasText = false;

  FocusNode get _effectiveFocusNode => widget.focusNode ?? _internalFocusNode;

  @override
  void initState() {
    super.initState();
    _internalFocusNode = FocusNode();
    _effectiveFocusNode.addListener(_handleFocusChange);
    widget.controller.addListener(_handleTextChange);
    _hasText = widget.controller.text.isNotEmpty;
  }

  @override
  void dispose() {
    _effectiveFocusNode.removeListener(_handleFocusChange);
    if (widget.focusNode == null) {
      _internalFocusNode.dispose();
    }
    widget.controller.removeListener(_handleTextChange);
    super.dispose();
  }

  void _handleFocusChange() {
    if (_effectiveFocusNode.hasFocus != _isFocused) {
      setState(() => _isFocused = _effectiveFocusNode.hasFocus);
    }
  }

  void _handleTextChange() {
    final nowHasText = widget.controller.text.isNotEmpty;
    if (nowHasText != _hasText) {
      setState(() => _hasText = nowHasText);
    }
  }

  void _handleClear() {
    HapticFeedback.lightImpact();
    widget.controller.clear();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = widget.height / 2;
    final primaryColor = ThemeService.instance.primaryColor;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.28),
                  blurRadius: 14,
                  offset: const Offset(0, 2),
                ),
              ]
            : const [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 1. Nền kính quang học thích ứng
            GlassSurface(
              height: widget.height,
              isCircle: false,
              borderRadius: borderRadius,
              tintColor: _isFocused
                  ? const Color(0x4D2A2A2A)
                  : const Color(0x301E1E1E),
              blur: _isFocused ? 18.0 : 10.0,
              refractiveIndex: _isFocused ? 1.48 : 1.38,
              thickness: 36.0,
              padding: widget.padding,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Icon Kính Lúp biến hình (Morphing Search Icon)
                  OpenFlixMorphIcon.snappy(
                    icon: _hasText
                        ? Icons.manage_search_rounded
                        : Icons.search_rounded,
                    size: 22,
                    color: _isFocused
                        ? primaryColor
                        : Colors.white.withValues(alpha: 0.65),
                  ),
                  const SizedBox(width: 8),

                  // Ô nhập văn bản
                  Expanded(
                    child: TextField(
                      controller: widget.controller,
                      focusNode: _effectiveFocusNode,
                      autofocus: widget.autofocus,
                      onChanged: widget.onChanged,
                      onSubmitted: widget.onSubmitted,
                      textInputAction: TextInputAction.search,
                      textAlignVertical: TextAlignVertical.center,
                      cursorColor: primaryColor,
                      cursorHeight: 18,
                      cursorWidth: 2,
                      cursorRadius: const Radius.circular(1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        isCollapsed: true,
                        hintText: widget.hintText,
                        hintStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.45),
                          fontSize: 13.5,
                          height: 1.2,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),

                  // Nút xoá nhanh khi có text
                  if (_hasText)
                    GestureDetector(
                      onTap: _handleClear,
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),

                  // Nút giọng nói nếu có callback
                  if (widget.onVoiceTap != null && !_hasText) ...[
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: widget.onVoiceTap,
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.mic_none_rounded,
                          size: 20,
                          color: Colors.white.withValues(alpha: 0.70),
                        ),
                      ),
                    ),
                  ],

                  // Nút mở bộ lọc nếu có callback
                  if (widget.onFilterTap != null) ...[
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: widget.onFilterTap,
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.10),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.tune_rounded,
                          size: 16,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // 2. Viền kim loại hairline phản chiếu
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(borderRadius),
                    border: Border.all(
                      color: _isFocused
                          ? primaryColor.withValues(alpha: 0.65)
                          : Colors.white.withValues(alpha: 0.15),
                      width: 1.0,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
