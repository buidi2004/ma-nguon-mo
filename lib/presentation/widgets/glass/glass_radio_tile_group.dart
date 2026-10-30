import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../services/theme_service.dart';
import '../../../theme/app_theme.dart';
import 'glass_surface.dart';

/// Mục phân loại bên trong [GlassRadioTileGroup]
class GlassRadioItem<T> {
  final T value;
  final String label;
  final String? subtitle;
  final IconData? icon;

  const GlassRadioItem({
    required this.value,
    required this.label,
    this.subtitle,
    this.icon,
  });
}

/// Nhóm lựa chọn nút kính mờ quang học (Optical Frosted Glass Radio Group).
///
/// Hỗ trợ dạng dàn hàng (Wrap Capsules) cho cài đặt chất lượng video hoặc dạng danh sách dọc (List Tiles).
class GlassRadioTileGroup<T> extends StatelessWidget {
  final List<GlassRadioItem<T>> items;
  final T selectedValue;
  final ValueChanged<T> onChanged;
  final bool isWrap;
  final double spacing;
  final double runSpacing;
  final Color? activeColor;
  final bool enableHaptic;

  const GlassRadioTileGroup({
    super.key,
    required this.items,
    required this.selectedValue,
    required this.onChanged,
    this.isWrap = true,
    this.spacing = 8.0,
    this.runSpacing = 8.0,
    this.activeColor,
    this.enableHaptic = true,
  });

  /// Factory cho danh sách chuỗi đơn giản
  static GlassRadioTileGroup<String> fromStrings({
    Key? key,
    required List<String> options,
    required String selectedOption,
    required ValueChanged<String> onChanged,
    bool isWrap = true,
    double spacing = 8.0,
    double runSpacing = 8.0,
    Color? activeColor,
    bool enableHaptic = true,
  }) {
    return GlassRadioTileGroup<String>(
      key: key,
      items: options
          .map((s) => GlassRadioItem<String>(value: s, label: s))
          .toList(),
      selectedValue: selectedOption,
      onChanged: onChanged,
      isWrap: isWrap,
      spacing: spacing,
      runSpacing: runSpacing,
      activeColor: activeColor,
      enableHaptic: enableHaptic,
    );
  }

  void _handleSelect(T val) {
    if (val == selectedValue) return;
    if (enableHaptic) {
      HapticFeedback.selectionClick();
    }
    onChanged(val);
  }

  @override
  Widget build(BuildContext context) {
    final isBlue = ThemeService.instance.isWindowsBlue;
    final effectiveActive = activeColor ?? ThemeService.instance.primaryColor;
    final unselectedTint = isBlue
        ? const Color(0xCC0A2433)
        : const Color(0x80262626);
    final selectedTint = isBlue
        ? const Color(0xE6006BA6)
        : effectiveActive.withValues(alpha: 0.32);

    if (isWrap) {
      return Wrap(
        spacing: spacing,
        runSpacing: runSpacing,
        children: items.map((item) {
          final isSelected = item.value == selectedValue;

          return GestureDetector(
            onTap: () => _handleSelect(item.value),
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              child: GlassSurface.capsule(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 9,
                ),
                tintColor: isSelected ? selectedTint : unselectedTint,
                customBorder: Border.all(
                  color: isSelected
                      ? (isBlue
                            ? const Color(0xFF66C7F4)
                            : effectiveActive.withValues(alpha: 0.75))
                      : (isBlue
                            ? const Color(0x4D5AD2F4)
                            : Colors.white.withValues(alpha: 0.18)),
                  width: isSelected ? 1.2 : 0.8,
                ),
                blur: 8.5,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isSelected
                          ? Icons.check_circle_rounded
                          : Icons.circle_outlined,
                      color: isSelected
                          ? Colors.white
                          : (isBlue
                                ? const Color(0xFFB8D4E8)
                                : AppColors.textSecondary),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : (isBlue
                                    ? const Color(0xFFE2F1FF)
                                    : AppColors.textPrimary),
                          fontSize: 13,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      );
    }

    // Dạng cột đứng (Vertical list)
    return Column(
      children: items.map((item) {
        final isSelected = item.value == selectedValue;

        return Padding(
          padding: EdgeInsets.only(bottom: runSpacing),
          child: GestureDetector(
            onTap: () => _handleSelect(item.value),
            behavior: HitTestBehavior.opaque,
            child: GlassSurface(
              borderRadius: 8.0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              tintColor: isSelected ? selectedTint : unselectedTint,
              customBorder: Border.all(
                color: isSelected
                    ? (isBlue
                          ? const Color(0xFF66C7F4)
                          : effectiveActive.withValues(alpha: 0.70))
                    : (isBlue ? const Color(0x4D5AD2F4) : Colors.white24),
              ),
              blur: 10.0,
              child: Row(
                crossAxisAlignment: item.subtitle != null
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      top: item.subtitle != null ? 1.5 : 0.0,
                    ),
                    child: Icon(
                      isSelected
                          ? Icons.check_circle_rounded
                          : Icons.circle_outlined,
                      color: isSelected
                          ? (isBlue ? Colors.white : effectiveActive)
                          : (isBlue
                                ? const Color(0xFFB8D4E8)
                                : AppColors.textSecondary),
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.label,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppColors.textPrimary,
                            fontSize: 15,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w500,
                          ),
                        ),
                        if (item.subtitle != null) ...[
                          SizedBox(height: 2),
                          Text(
                            item.subtitle!,
                            style: TextStyle(
                              color: isBlue
                                  ? const Color(0xFFD6EBFC)
                                  : AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
