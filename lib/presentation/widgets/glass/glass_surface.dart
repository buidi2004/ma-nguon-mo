import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import 'glass_optical_tokens.dart';
import 'glass_perf.dart';

/// Widget bề mặt kính quang học nền tảng (Foundation Glass Surface).
/// Sử dụng kiến trúc 2-Layer Sibling trong Stack:
/// - Layer 1 (Bên dưới): Khối khúc xạ quang học LiquidGlass (Snell's Law)
///   hoặc BackdropFilter mượt mà + viền Hairline Rim sáng ánh kim.
/// - Layer 2 (Bên trên): Nội dung [child] hoàn toàn sắc nét, không bị nhòe hay biến dạng.
class GlassSurface extends StatelessWidget {
  final Widget? child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final bool isCapsule;
  final bool isCircle;
  final Color? tintColor;
  final Color? borderTint;
  final double? blur;
  final double? refractiveIndex;
  final double? thickness;
  final LiquidGlassSettings? customSettings;
  final bool? useBackdropFilter;
  /// Hạng chất lượng shader kính. Mặc định lấy theo [GlassPerf.surface]
  /// (mobile: `standard`, desktop/web: `premium`). Bề mặt tiêu điểm truyền
  /// [GlassPerf.focal] để luôn giữ `premium`.
  final GlassQuality? quality;
  final BoxBorder? customBorder;
  final List<BoxShadow>? shadows;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final HitTestBehavior hitTestBehavior;

  const GlassSurface({
    super.key,
    this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius = 16.0,
    this.isCapsule = false,
    this.isCircle = false,
    this.tintColor,
    this.borderTint,
    this.blur,
    this.refractiveIndex,
    this.thickness,
    this.customSettings,
    this.useBackdropFilter,
    this.quality,
    this.customBorder,
    this.shadows,
    this.onTap,
    this.onLongPress,
    this.hitTestBehavior = HitTestBehavior.opaque,
  });

  /// Factory tiện ích cho hình viên thuốc tròn (Capsule)
  factory GlassSurface.capsule({
    Key? key,
    Widget? child,
    double? width,
    double? height,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Color? tintColor,
    Color? borderTint,
    double? blur,
    double? refractiveIndex,
    double? thickness,
    LiquidGlassSettings? customSettings,
    bool? useBackdropFilter,
    GlassQuality? quality,
    BoxBorder? customBorder,
    List<BoxShadow>? shadows,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
  }) {
    return GlassSurface(
      key: key,
      isCapsule: true,
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      tintColor: tintColor,
      borderTint: borderTint,
      blur: blur,
      refractiveIndex: refractiveIndex,
      thickness: thickness,
      customSettings: customSettings,
      useBackdropFilter: useBackdropFilter,
      quality: quality,
      customBorder: customBorder,
      shadows: shadows,
      onTap: onTap,
      onLongPress: onLongPress,
      child: child,
    );
  }

  /// Factory tiện ích cho hình tròn (Circle / Avatar / Icon)
  factory GlassSurface.circle({
    Key? key,
    Widget? child,
    double? size,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Color? tintColor,
    Color? borderTint,
    double? blur,
    double? refractiveIndex,
    double? thickness,
    LiquidGlassSettings? customSettings,
    bool? useBackdropFilter,
    GlassQuality? quality,
    BoxBorder? customBorder,
    List<BoxShadow>? shadows,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
  }) {
    return GlassSurface(
      key: key,
      isCircle: true,
      width: size,
      height: size,
      padding: padding,
      margin: margin,
      tintColor: tintColor,
      borderTint: borderTint,
      blur: blur,
      refractiveIndex: refractiveIndex,
      thickness: thickness,
      customSettings: customSettings,
      useBackdropFilter: useBackdropFilter,
      quality: quality,
      customBorder: customBorder,
      shadows: shadows,
      onTap: onTap,
      onLongPress: onLongPress,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = isCapsule
        ? 999.0
        : (isCircle ? 999.0 : borderRadius);
    final effectiveBorderRadius = BorderRadius.circular(effectiveRadius);

    Widget content = Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: isCircle ? null : effectiveBorderRadius,
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        boxShadow: shadows ?? GlassOpticalTokens.elevationShadow,
      ),
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          // ==========================================
          // LAYER 1: NỀN KÍNH QUANG HỌC & VIỀN VÁT (IgnorePointer để không chặn cử chỉ)
          // ==========================================
          Positioned.fill(
            child: IgnorePointer(
              child: _buildOpticalBackground(
                context: context,
                effectiveRadius: effectiveRadius,
                effectiveBorderRadius: effectiveBorderRadius,
              ),
            ),
          ),

          // ==========================================
          // LAYER 2: NỘI DUNG SẮC NÉT (CHILD CONTENT)
          // ==========================================
          if (child != null)
            Padding(padding: padding ?? EdgeInsets.zero, child: child!),
        ],
      ),
    );

    if (onTap != null || onLongPress != null) {
      return GestureDetector(
        behavior: hitTestBehavior,
        onTap: onTap,
        onLongPress: onLongPress,
        child: content,
      );
    }

    return content;
  }

  Widget _buildOpticalBackground({
    required BuildContext context,
    required double effectiveRadius,
    required BorderRadius effectiveBorderRadius,
  }) {
    // Tự động kích hoạt fallback nếu đang ở chế độ web hoặc test không shader
    final bool preferFallback = useBackdropFilter ?? false;

    if (preferFallback) {
      return _buildBackdropFallback(
        effectiveRadius: effectiveRadius,
        effectiveBorderRadius: effectiveBorderRadius,
      );
    }

    // Nhánh Fragment Shader: LiquidGlassSettings với độ khúc xạ Snell's Law
    final settings =
        customSettings ??
        GlassOpticalTokens.createButtonSettings(
          tint: tintColor ?? GlassOpticalTokens.buttonTint,
          blur: blur ?? GlassOpticalTokens.buttonBlur,
          refractiveIndex:
              refractiveIndex ?? GlassOpticalTokens.buttonRefractiveIndex,
          thickness: thickness ?? GlassOpticalTokens.buttonThickness,
        );

    final LiquidShape liquidShape = isCircle
        ? const LiquidOval()
        : LiquidRoundedRectangle(borderRadius: effectiveRadius);

    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: isCircle
            ? BorderRadius.circular(9999)
            : effectiveBorderRadius,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Thấu kính quang học LiquidGlass
            GlassContainer(
              useOwnLayer: true,
              // Hạng chất lượng theo năng lực thiết bị: mobile dùng shader
              // nhẹ, desktop giữ premium. Xem [GlassPerf].
              quality: quality ?? GlassPerf.surface,
              shape: liquidShape,
              settings: settings,
            ),

            // Viền vát siêu mỏng (Hairline Rim)
            _buildHairlineRim(
              effectiveRadius: effectiveRadius,
              effectiveBorderRadius: effectiveBorderRadius,
            ),

            // Lớp phản quang vòm cầu phía trên (Specular Curvature Sheen)
            _buildSpecularSheen(
              effectiveRadius: effectiveRadius,
              effectiveBorderRadius: effectiveBorderRadius,
            ),
          ],
        ),
      ),
    );
  }

  /// Fallback BackdropFilter tương thích 100% mọi nền tảng và test runner
  Widget _buildBackdropFallback({
    required double effectiveRadius,
    required BorderRadius effectiveBorderRadius,
  }) {
    final effectiveBlur = blur ?? GlassOpticalTokens.buttonBlur;
    final effectiveTint = tintColor ?? GlassOpticalTokens.buttonTint;

    final effectiveBorder =
        customBorder ??
        (borderTint != null
            ? Border.all(
                color: borderTint!,
                width: GlassOpticalTokens.hairlineRimWidth,
              )
            : null);

    return ClipRRect(
      borderRadius: isCircle
          ? BorderRadius.circular(9999)
          : effectiveBorderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: effectiveBlur, sigmaY: effectiveBlur),
        child: Container(
          decoration: BoxDecoration(
            color: effectiveTint,
            borderRadius: isCircle ? null : effectiveBorderRadius,
            shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
            border:
                effectiveBorder ??
                Border.all(
                  color: Colors.white.withValues(alpha: 0.18),
                  width: GlassOpticalTokens.hairlineRimWidth,
                ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildSpecularSheen(
                effectiveRadius: effectiveRadius,
                effectiveBorderRadius: effectiveBorderRadius,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Viền Hairline Rim kim cương
  Widget _buildHairlineRim({
    required double effectiveRadius,
    required BorderRadius effectiveBorderRadius,
  }) {
    final effectiveBorder =
        customBorder ??
        (borderTint != null
            ? Border.all(
                color: borderTint!,
                width: GlassOpticalTokens.hairlineRimWidth,
              )
            : null);

    if (effectiveBorder != null) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: isCircle ? null : effectiveBorderRadius,
          shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
          border: effectiveBorder,
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: isCircle ? null : effectiveBorderRadius,
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.22),
          width: GlassOpticalTokens.hairlineRimWidth,
        ),
      ),
    );
  }

  /// Phản quang bề mặt cong (Specular Sheen)
  Widget _buildSpecularSheen({
    required double effectiveRadius,
    required BorderRadius effectiveBorderRadius,
  }) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: 24,
      child: IgnorePointer(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: isCircle
                ? null
                : BorderRadius.vertical(top: Radius.circular(effectiveRadius)),
            shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
            gradient: GlassOpticalTokens.specularSheenGradient,
          ),
        ),
      ),
    );
  }
}
