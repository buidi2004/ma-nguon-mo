import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../services/theme_service.dart';
import 'border_beam.dart';

/// Thanh tìm kiếm Mobile cao cấp tích hợp hiệu ứng viền sáng chuyển động BorderBeam.
///
/// Tuân thủ quy chuẩn UX/UI:
/// - Chiều cao tiêu chuẩn 48px, touch target >= 44px
/// - Nền tối obsidian kính mờ quang học
/// - BorderBeam tự động tăng tốc và sáng rực khi người dùng chạm vào (Focus)
/// - Hỗ trợ nút xoá nhanh (Clear), tìm kiếm giọng nói (Voice), và bộ lọc (Filter)
/// - Tự động debounce tìm kiếm mượt mà tránh gọi API liên tục
class BorderBeamSearchBar extends StatefulWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onFilterTap;
  final VoidCallback? onVoiceTap;
  final VoidCallback? onCancelTap;
  final String hintText;
  final double height;
  final bool autofocus;
  final FocusNode? focusNode;
  final EdgeInsetsGeometry padding;
  final BorderRadiusGeometry borderRadius;
  final BorderBeamSize beamSize;
  final BorderBeamColorVariant colorVariant;
  final List<Color>? customBeamColors;
  final Duration debounceDuration;
  final bool activeOnFocusOnly;
  final bool showSearchButton;
  final String searchButtonLabel;
  final bool showCancelButton;

  const BorderBeamSearchBar({
    super.key,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onFilterTap,
    this.onVoiceTap,
    this.onCancelTap,
    this.hintText = 'Tìm kiếm phim, diễn viên, thể loại...',
    this.height = 48.0,
    this.autofocus = false,
    this.focusNode,
    this.padding = const EdgeInsets.symmetric(horizontal: 14.0),
    this.borderRadius = const BorderRadius.all(Radius.circular(24.0)),
    this.beamSize = BorderBeamSize.md,
    this.colorVariant = BorderBeamColorVariant.brand,
    this.customBeamColors,
    this.debounceDuration = const Duration(milliseconds: 280),
    this.activeOnFocusOnly = false,
    this.showSearchButton = true,
    this.searchButtonLabel = 'Tìm',
    this.showCancelButton = false,
  });

  @override
  State<BorderBeamSearchBar> createState() => _BorderBeamSearchBarState();
}

class _BorderBeamSearchBarState extends State<BorderBeamSearchBar> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  bool _ownsController = false;
  bool _ownsFocusNode = false;

  bool _isFocused = false;
  bool _hasText = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = TextEditingController();
      _ownsController = true;
    }

    if (widget.focusNode != null) {
      _focusNode = widget.focusNode!;
    } else {
      _focusNode = FocusNode();
      _ownsFocusNode = true;
    }

    _hasText = _controller.text.isNotEmpty;
    _controller.addListener(_handleTextChange);
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.removeListener(_handleTextChange);
    _focusNode.removeListener(_handleFocusChange);
    if (_ownsController) {
      _controller.dispose();
    }
    if (_ownsFocusNode) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus != _isFocused) {
      setState(() => _isFocused = _focusNode.hasFocus);
    }
  }

  void _handleTextChange() {
    final nowHasText = _controller.text.isNotEmpty;
    if (nowHasText != _hasText) {
      setState(() => _hasText = nowHasText);
    }
  }

  void _onInputChanged(String query) {
    _debounceTimer?.cancel();
    if (widget.onChanged == null) return;

    if (widget.debounceDuration == Duration.zero) {
      widget.onChanged!(query);
    } else {
      _debounceTimer = Timer(widget.debounceDuration, () {
        if (mounted) {
          widget.onChanged!(query);
        }
      });
    }
  }

  void _handleClear() {
    HapticFeedback.lightImpact();
    _controller.clear();
    _debounceTimer?.cancel();
    widget.onChanged?.call('');
  }

  void _handleSearchSubmit() {
    HapticFeedback.mediumImpact();
    _debounceTimer?.cancel();
    final query = _controller.text.trim();
    if (widget.onSubmitted != null) {
      widget.onSubmitted!(query);
    } else if (widget.onChanged != null) {
      widget.onChanged!(query);
    }
    _focusNode.unfocus();
  }

  void _handleCancel() {
    HapticFeedback.lightImpact();
    _debounceTimer?.cancel();
    _focusNode.unfocus();
    widget.onCancelTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = ThemeService.instance.primaryColor;

    // Khi người dùng focus, chùm sáng chạy nhanh hơn (2.8s) & phát sáng rực rỡ hơn
    final double duration = _isFocused ? 2.8 : 7.0;
    final double glowRadius = _isFocused ? 11.0 : 6.0;

    // Xác định màu chùm sáng: Nếu chọn brand thì đồng bộ với ThemeService (Đỏ Netflix hoặc Xanh Cyan)
    List<Color>? resolvedColors = widget.customBeamColors;
    if (resolvedColors == null && widget.colorVariant == BorderBeamColorVariant.brand) {
      resolvedColors = [
        primaryColor,
        primaryColor.withValues(alpha: 0.8),
        Colors.white,
      ];
    }

    final isBeamActive = !widget.activeOnFocusOnly || _isFocused;

    final searchBarWidget = AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: widget.borderRadius,
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.28),
                  blurRadius: 16,
                  offset: const Offset(0, 3),
                ),
                const BoxShadow(
                  color: Color(0x66000000),
                  blurRadius: 10,
                  offset: Offset(0, 2),
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
      child: BorderBeam(
        duration: duration,
        borderWidth: _isFocused ? 2.0 : 1.6,
        borderRadius: widget.borderRadius,
        size: widget.beamSize,
        colorVariant: widget.colorVariant,
        customColors: resolvedColors,
        glowRadius: glowRadius,
        showGlow: true,
        active: isBeamActive,
        trackColor: Colors.white.withValues(alpha: _isFocused ? 0.16 : 0.08),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            color: _isFocused
                ? const Color(0xFF1E1E1E)
                : const Color(0xFF161616),
          ),
          padding: widget.padding,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Icon tìm kiếm dẫn đầu (Chạm để Submit hoặc Focus)
              Semantics(
                label: 'Tìm kiếm',
                button: true,
                child: GestureDetector(
                  onTap: () {
                    if (_hasText) {
                      _handleSearchSubmit();
                    } else {
                      _focusNode.requestFocus();
                    }
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        _hasText ? Icons.manage_search_rounded : Icons.search_rounded,
                        size: 22,
                        color: _isFocused
                            ? primaryColor
                            : Colors.white.withValues(alpha: 0.65),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // 2. Ô nhập TextField mượt mà
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  autofocus: widget.autofocus,
                  onChanged: _onInputChanged,
                  onSubmitted: (value) {
                    _handleSearchSubmit();
                  },
                  textInputAction: TextInputAction.search,
                  textAlignVertical: TextAlignVertical.center,
                  cursorColor: primaryColor,
                  cursorHeight: 18,
                  cursorWidth: 2,
                  cursorRadius: const Radius.circular(1),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    isCollapsed: true,
                    hintText: widget.hintText,
                    hintStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.40),
                      fontSize: 14,
                      height: 1.2,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),

              // 3. Cụm nút khi có văn bản: Nút Xóa nhanh (Clear) + Nút Tìm kiếm viên thuốc (Pill Button)
              if (_hasText) ...[
                Semantics(
                  label: 'Xóa nội dung tìm kiếm',
                  button: true,
                  child: GestureDetector(
                    onTap: _handleClear,
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.14),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                // Nút tìm kiếm viên thuốc (Pill CTA Button)
                if (widget.showSearchButton) ...[
                  const SizedBox(width: 8),
                  Semantics(
                    label: 'Thực hiện tìm kiếm',
                    button: true,
                    child: GestureDetector(
                      onTap: _handleSearchSubmit,
                      behavior: HitTestBehavior.opaque,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOutCubic,
                        height: 32,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              primaryColor,
                              primaryColor.withValues(alpha: 0.88),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withValues(alpha: 0.38),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.search_rounded,
                              size: 15,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.searchButtonLabel,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],

              // 4. Nút tìm kiếm giọng nói (Voice Tap) khi chưa có chữ
              if (widget.onVoiceTap != null && !_hasText) ...[
                const SizedBox(width: 4),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  icon: Icon(
                    Icons.mic_none_rounded,
                    size: 20,
                    color: Colors.white.withValues(alpha: 0.70),
                  ),
                  tooltip: 'Tìm kiếm bằng giọng nói',
                  onPressed: widget.onVoiceTap,
                ),
              ],

              // 5. Nút bộ lọc nâng cao (Filter Tap) khi chưa có chữ
              if (widget.onFilterTap != null && !_hasText) ...[
                const SizedBox(width: 4),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  icon: Icon(
                    Icons.tune_rounded,
                    size: 18,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                  tooltip: 'Bộ lọc tìm kiếm',
                  onPressed: widget.onFilterTap,
                ),
              ],
            ],
          ),
        ),
      ),
    );

    if (!widget.showCancelButton) {
      return searchBarWidget;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: searchBarWidget),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          child: _isFocused
              ? Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Semantics(
                    label: 'Hủy tìm kiếm',
                    button: true,
                    child: GestureDetector(
                      onTap: _handleCancel,
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        constraints: const BoxConstraints(minHeight: 44, minWidth: 44),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: const Text(
                          'Hủy',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
