import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../services/theme_service.dart';
import 'glass_optical_tokens.dart';
import 'glass_perf.dart';
import 'glass_surface.dart';

/// Thẻ Menu nổi bề mặt kính quang học bo cong mềm mại (Curved Optical Glass Menu Card).
/// Bán kính bo góc lớn (24–28px), độ tương phản cao cho chữ trắng trên mọi nền video/poster.
class GlassMenuCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Color? tintColor;
  final double? blur;
  final bool? useBackdropFilter;

  const GlassMenuCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.borderRadius = 24.0,
    this.padding = const EdgeInsets.all(16.0),
    this.margin,
    this.tintColor,
    this.blur,
    this.useBackdropFilter,
  });

  @override
  Widget build(BuildContext context) {
    final defaultTint = ThemeService.instance.isWindowsBlue
        ? const Color(0xCC082233)
        : const Color(0xB31E1E1E);
    return GlassSurface(
      width: width,
      height: height,
      borderRadius: borderRadius,
      margin: margin,
      padding: padding,
      tintColor: tintColor ?? defaultTint,
      blur: blur ?? GlassOpticalTokens.menuBlur,
      refractiveIndex: GlassOpticalTokens.menuRefractiveIndex,
      thickness: GlassOpticalTokens.menuThickness,
      useBackdropFilter: useBackdropFilter,
      // Menu/dialog là bề mặt tiêu điểm: giữ hạng premium trên mọi thiết bị.
      quality: GlassPerf.focal,
      shadows: const [
        BoxShadow(
          color: Color(0x66000000),
          offset: Offset(0, 12),
          blurRadius: 32,
          spreadRadius: -4,
        ),
      ],
      child: child,
    );
  }
}

/// Dòng mục lựa chọn bên trong Glass Menu (Glass Menu Item Row).
class GlassMenuItem extends StatelessWidget {
  final IconData? icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isDestructive;
  final bool isSelected;

  const GlassMenuItem({
    super.key,
    this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.isDestructive = false,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = isDestructive
        ? const Color(0xFFFF4D4D)
        : (isSelected ? const Color(0xFF00E5FF) : Colors.white);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (onTap != null) {
            HapticFeedback.selectionClick();
            onTap!();
          }
        },
        borderRadius: BorderRadius.circular(12),
        splashColor: Colors.white.withValues(alpha: 0.08),
        highlightColor: Colors.white.withValues(alpha: 0.04),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
          child: Row(
            crossAxisAlignment: subtitle != null
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Padding(
                  padding: EdgeInsets.only(top: subtitle != null ? 1.5 : 0.0),
                  child: Icon(icon, size: 22, color: activeColor),
                ),
                const SizedBox(width: 14),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: activeColor,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.65),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }
}

/// Tiện ích hiển thị Modal Bottom Sheet dạng kính bo cong quang học
Future<T?> showGlassBottomSheet<T>({
  required BuildContext context,
  required Widget child,
  String? title,
  bool isDismissible = true,
  bool enableDrag = true,
  double topRadius = 28.0,
}) {
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: Colors.transparent,
    elevation: 0,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    isScrollControlled: true,
    builder: (ctx) {
      return SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
          child: GlassSurface(
            borderRadius: topRadius,
            tintColor: ThemeService.instance.isWindowsBlue
                ? const Color(0xE6082233)
                : const Color(0xD91E1E1E),
            blur: 14.0,
            refractiveIndex: 1.68,
            thickness: 38.0,
            // Bề mặt tiêu điểm: giữ premium trên mọi thiết bị.
            quality: GlassPerf.focal,
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Thanh kéo handle bo cong nhỏ
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                if (title != null) ...[
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                child,
              ],
            ),
          ),
        ),
      );
    },
  );
}

/// Tiện ích hiển thị Dialog nổi dạng kính bo cong quang học
Future<T?> showGlassDialog<T>({
  required BuildContext context,
  Widget? child,
  Widget? content,
  String? title,
  List<Widget>? actions,
  bool barrierDismissible = true,
  double borderRadius = 24.0,
}) {
  final dialogBody = child ?? content;
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierColor: Colors.black.withValues(alpha: 0.65),
    builder: (ctx) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Material(
            color: Colors.transparent,
            child: GlassSurface(
              borderRadius: borderRadius,
              tintColor: ThemeService.instance.isWindowsBlue
                  ? const Color(0xE6082233)
                  : const Color(0xD91E1E1E),
              blur: 16.0,
              refractiveIndex: 1.68,
              thickness: 40.0,
              // Bề mặt tiêu điểm: giữ premium trên mọi thiết bị.
              quality: GlassPerf.focal,
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (title != null) ...[
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                  ?dialogBody,
                  if (actions != null && actions.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: actions,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
