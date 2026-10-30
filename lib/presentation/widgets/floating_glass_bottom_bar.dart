import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:morphnext/morphnext.dart';

import '../../services/theme_service.dart';
import '../../waves_background.dart';
import 'glass/glass_perf.dart';

/// Icon 4 ô vuông bo góc đa sắc XOAY NGHIÊNG CHÉO 3D với chuyển động nhịp thở thạch (Jelly Pulse)
/// và lơ lửng bồng bềnh vi mô (Micro-Float), lệch pha 90 độ, tuyệt đối không chạm viền ngoài.
class FourTileQuickActionIcon extends StatefulWidget {
  final double size;
  final bool? animate;
  const FourTileQuickActionIcon({super.key, this.size = 32, this.animate});

  @override
  State<FourTileQuickActionIcon> createState() =>
      _FourTileQuickActionIconState();
}

class _FourTileQuickActionIconState extends State<FourTileQuickActionIcon>
    with SingleTickerProviderStateMixin {
  /// Nhịp cập nhật của icon: 30 fps thay vì 60 fps.
  ///
  /// Chuyển động là sin tuần hoàn 3.2s nên 30 fps cho cùng một quỹ đạo mắt
  /// thường không phân biệt được, nhưng cắt đúng một nửa số lần build + raster
  /// của icon. Icon này chạy vô hạn ở bottom bar, nên đây là chi phí nền mà
  /// mọi animation khác (chuyển tab, mở màn phim) phải chia sẻ.
  static const Duration _frameStep = Duration(milliseconds: 33);
  static const Duration _cycle = Duration(milliseconds: 3200);

  late final Ticker _ticker;
  final ValueNotifier<double> _phase = ValueNotifier<double>(0.0);
  Duration _lastTick = Duration.zero;
  double _accumulatedSeconds = 0.0;
  bool _reduceMotion = false;

  // Bộ vẽ tĩnh (4 ô màu + gradient) được cache lại: mỗi frame chỉ còn
  // Transform/Scale thay đổi, không dựng lại Decoration/Gradient/Shadow.
  double? _artworkSize;
  List<Widget> _tiles = const [];

  bool get _shouldAnimate {
    if (widget.animate != null) return widget.animate!;
    final isTestEnv = WidgetsBinding.instance.runtimeType.toString().contains(
      'Test',
    );
    return !isTestEnv;
  }

  bool get _isAllowed =>
      _shouldAnimate && !_reduceMotion && !WavesBackground.isVideoPlaying;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    if (_isAllowed) {
      _ticker.start();
    }
    WavesBackground.addSuspensionListener(_onSuspensionChanged);
  }

  void _onSuspensionChanged() {
    if (!mounted) return;
    _syncTicker();
  }

  void _onTick(Duration elapsed) {
    if (_lastTick == Duration.zero) {
      _lastTick = elapsed;
      return;
    }
    final delta = elapsed - _lastTick;
    if (delta < _frameStep) return;
    _lastTick = elapsed;
    _accumulatedSeconds += delta.inMicroseconds / 1e6;
    final cycleSec = _cycle.inMicroseconds / 1e6;
    _phase.value = (_accumulatedSeconds % cycleSec) / cycleSec;
  }

  void _syncTicker() {
    if (_isAllowed) {
      if (!_ticker.isActive) {
        _lastTick = Duration.zero;
        _ticker.start();
      }
    } else {
      if (_ticker.isActive) _ticker.stop();
    }
  }

  @override
  void didUpdateWidget(FourTileQuickActionIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate != oldWidget.animate) {
      _syncTicker();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Ticker do SingleTickerProviderStateMixin tạo ra đã tự mute theo
    // TickerMode (tab bị che, route không còn hiển thị) nên ở đây chỉ cần
    // tôn trọng tuỳ chọn giảm chuyển động của hệ điều hành.
    _reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    _syncTicker();
  }

  @override
  void dispose() {
    WavesBackground.removeSuspensionListener(_onSuspensionChanged);
    _ticker.dispose();
    _phase.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    _ensureArtwork(size);

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _phase,
        builder: (context, _) {
          final double t = _phase.value * 2.0 * math.pi;

          // 1. Độ phồng thạch dẻo lệch pha 90 độ cho từng viên (Scale: 0.95 - 1.05)
          final s1 = 1.0 + 0.05 * math.sin(t);
          final s2 = 1.0 + 0.05 * math.sin(t + math.pi / 2.0);
          final s3 = 1.0 + 0.05 * math.sin(t + math.pi);
          final s4 = 1.0 + 0.05 * math.sin(t + 3.0 * math.pi / 2.0);

          // 2. Chuyển động lơ lửng bồng bềnh vi mô (tối đa ±1.2px)
          final dy = 1.2 * math.cos(t);
          final dx = 0.6 * math.sin(t);

          // 3. Lắc lư góc nghiêng vi mô (22 độ ± 1.5 độ)
          final angle = 0.384 + 0.026 * math.sin(t);

          // 4. Hào quang thở (Radial Glow)
          final glowOpacity = 0.22 + 0.14 * (0.5 + 0.5 * math.sin(t));

          return SizedBox(
            width: size + 8,
            height: size + 8,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Hiệu ứng ánh sáng tỏa tròn (Radial Glow) thở nhịp nhàng
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          ThemeService.instance.primaryColor.withValues(
                            alpha: glowOpacity,
                          ),
                          ThemeService.instance.accentColor.withValues(
                            alpha: glowOpacity * 0.45,
                          ),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.55, 1.0],
                      ),
                    ),
                  ),
                ),
                // Khối 4 ô vuông bồng bềnh và lắc lư nhẹ
                Transform.translate(
                  offset: Offset(dx, dy),
                  child: Transform.rotate(
                    angle: angle,
                    child: SizedBox(
                      width: size,
                      height: size,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // 1. Ô TRÊN-TRÁI: Cyan phát sáng (thở nhịp 1)
                              Transform.scale(scale: s1, child: _tiles[0]),
                              const SizedBox(width: 3),
                              // 2. Ô TRÊN-PHẢI: Royal Blue (thở nhịp 2)
                              Transform.scale(scale: s2, child: _tiles[1]),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // 3. Ô DƯỚI-TRÁI: Vàng cam Sunburst (thở nhịp 3)
                              Transform.scale(scale: s3, child: _tiles[2]),
                              const SizedBox(width: 3),
                              // 4. Ô DƯỚI-PHẢI: Xanh lá mạ Neon Green (thở nhịp 4)
                              Transform.scale(scale: s4, child: _tiles[3]),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Dựng 4 ô màu đúng một lần cho mỗi kích thước (thay vì mỗi frame).
  void _ensureArtwork(double size) {
    if (_artworkSize == size && _tiles.length == 4) return;
    _artworkSize = size;

    final tileSize = size * 0.42;
    final borderRadius = BorderRadius.circular(tileSize * 0.38);

    _tiles = [
      _buildTile(
        size: tileSize,
        borderRadius: borderRadius,
        colors: const [Color(0xFF2AF598), Color(0xFF009EFD)],
        shadowColor: const Color(0xFF00E5FF).withValues(alpha: 0.60),
        hasSpecularHighlight: true,
      ),
      _buildTile(
        size: tileSize,
        borderRadius: borderRadius,
        colors: const [Color(0xFF5B86E5), Color(0xFF363795)],
        shadowColor: const Color(0xFF5B86E5).withValues(alpha: 0.50),
      ),
      _buildTile(
        size: tileSize,
        borderRadius: borderRadius,
        colors: const [Color(0xFFFFB300), Color(0xFFFF6F00)],
        shadowColor: const Color(0xFFFF9800).withValues(alpha: 0.55),
      ),
      _buildTile(
        size: tileSize,
        borderRadius: borderRadius,
        colors: const [Color(0xFFB4EC51), Color(0xFF429321)],
        shadowColor: const Color(0xFF7ED321).withValues(alpha: 0.50),
      ),
    ];
  }

  Widget _buildTile({
    required double size,
    required BorderRadius borderRadius,
    required List<Color> colors,
    required Color shadowColor,
    bool hasSpecularHighlight = false,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 5,
            offset: const Offset(0, 2.5),
          ),
        ],
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.35),
          width: 0.8,
        ),
      ),
      child: hasSpecularHighlight
          ? Container(
              decoration: BoxDecoration(
                borderRadius: borderRadius,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.center,
                  colors: [
                    Colors.white.withValues(alpha: 0.40),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.55],
                ),
              ),
            )
          : null,
    );
  }
}

/// Widget chuyên trách CHỈ vẽ nền kính mờ quang học (Layer 1: Background)
/// Chuẩn hóa 5 thông số vàng:
/// - RefractiveIndex: 1.28 (khúc xạ mềm mại, không tạo viền giả hay bóng vát méo)
/// - Thickness: 25, Blur: 4.0, GlassColor: 0x14FFFFFF (trong suốt thanh lịch)
/// - Không dùng lensModel spherical gây hiện tượng phồng khối "viên thuốc" bên trong
class GlassNavBackground extends StatelessWidget {
  final double blurSigma;
  final double borderRadius;
  final double tintOpacity;
  final bool isOval;
  final double height;
  final double? width;

  const GlassNavBackground({
    super.key,
    this.blurSigma = 24.0,
    this.borderRadius = 33,
    this.tintOpacity = 0.12,
    this.isOval = false,
    this.height = 66,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    // Nền kính quang học LiquidGlass (Snell's Law: refractiveIndex 1.28) + Viền vát siêu mảnh Hairline Rim (~0.8px)
    return _DarkBevelGlassWrapper(
      borderRadius: borderRadius,
      isOval: isOval,
      child: GlassContainer(
        width: width,
        height: height,
        useOwnLayer: true,
        // Thanh điều hướng luôn nằm trên nội dung cuộn nên lớp kính phải lấy
        // lại backdrop ở mỗi khung hình cuộn. Mobile dùng hạng shader nhẹ
        // (vẫn khúc xạ nền, vẫn viền vát + phản quang); desktop giữ premium.
        quality: GlassPerf.overlayChrome,
        shape: isOval
            ? const LiquidOval()
            : LiquidRoundedRectangle(borderRadius: borderRadius),
        settings: const LiquidGlassSettings(
          thickness: 25,
          blur: 4.0,
          glassColor: Color(0x14FFFFFF),
          lightIntensity: 0.78,
          refractiveIndex: 1.28, // Độ bẻ cong hình ảnh nền theo định luật Snell
          chromaticAberration: 0.0,
          ambientStrength: 0.16,
          fresnelStrength: 1.05,
          saturation: 1.20,
          edgeAbsorption: 0.07,
          shadowElevation: 0.0,
        ),
      ),
    );
  }
}

/// Thanh điều hướng nổi sử dụng kiến trúc 2 Layer Sibling trong Stack:
/// - Layer 1: [GlassNavBackground] CHỈ vẽ nền kính mờ và viền vát quang học (không chứa nội dung)
/// - Layer 2: Nội dung (4 tab icons, active red pill, 3D quick action button) nằm ĐÈ LÊN TRÊN, sắc nét 100%
class FloatingGlassBottomBar extends StatelessWidget
    implements PreferredSizeWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onQuickActionPressed;
  final bool? animateQuickAction;

  const FloatingGlassBottomBar({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
    required this.onQuickActionPressed,
    this.animateQuickAction,
  });

  @override
  Size get preferredSize => const Size.fromHeight(88);

  static const List<({IconData active, IconData inactive, String label})>
  _tabIcons = [
    (
      active: Icons.home_rounded,
      inactive: Icons.home_outlined,
      label: 'Trang chủ',
    ),
    (
      active: Icons.search_rounded,
      inactive: Icons.search_outlined,
      label: 'Tìm kiếm',
    ),
    (
      active: Icons.local_fire_department_rounded,
      inactive: Icons.local_fire_department_outlined,
      label: 'Mới & Hot',
    ),
    (
      active: Icons.confirmation_number_rounded,
      inactive: Icons.confirmation_number_outlined,
      label: 'Đặt vé',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeService.instance,
      builder: (context, _) {
        // HIG › Guides and safe areas: phần tử nổi phải nằm trên home indicator.
        final double bottomSafeInset = MediaQuery.paddingOf(context).bottom;
        return GlassAdaptiveScope(
          // Sàn chất lượng cho mọi bề mặt kính không tự khai báo `quality`.
          // Thanh điều hướng tự chọn hạng qua [GlassPerf.overlayChrome]: mobile
          // dùng shader nhẹ, desktop giữ premium — vẫn giữ nguyên hiệu ứng
          // khúc xạ Snell (refractiveIndex 1.28) trên mọi thiết bị.
          minQuality: GlassQuality.standard,
          maxQuality: GlassQuality.premium,
          allowStepUp: true,
          child: Padding(
            padding: EdgeInsets.fromLTRB(14, 0, 14, 14 + bottomSafeInset),
            child: SizedBox(
              height: 66,
              child: Row(
                children: [
                  // ĐẢO BÊN TRÁI: Thanh capsule kính chứa 4 tabs
                  // Ghép 2 layer SIBLING trong Stack: Nền riêng, Nội dung riêng
                  Expanded(
                    child: SizedBox(
                      height: 66,
                      child: Stack(
                        children: [
                          // Layer 1: NỀN kính mờ - CHỈ có blur + refraction + tint + hairline rim
                          // Bọc RepaintBoundary để GPU cache toàn bộ shader kính, cách ly triệt để khỏi animation trượt
                          const Positioned.fill(
                            child: RepaintBoundary(
                              child: GlassNavBackground(
                                borderRadius: 33,
                                height: 66,
                              ),
                            ),
                          ),
                          // Layer 2: NỘI DUNG - Con trỏ viên thuốc đỏ trượt liên tục (Single Liquid Glider) & Icons
                          Positioned.fill(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  final tabCount = _tabIcons.length;
                                  final totalWidth = constraints.maxWidth;
                                  final slotWidth = totalWidth / tabCount;
                                  // Viên thuốc cân đối, tỉ lệ đẹp, co giãn tự thích ứng màn hình nhỏ (320px) đến tablet
                                  final pillWidth = (slotWidth * 0.82)
                                      .clamp(44.0, 56.0)
                                      .toDouble();
                                  const pillHeight = 42.0;
                                  final pillTop =
                                      (constraints.maxHeight - pillHeight) / 2;
                                  final safeIndex = selectedIndex.clamp(
                                    0,
                                    tabCount - 1,
                                  );
                                  final pillLeft =
                                      safeIndex * slotWidth +
                                      (slotWidth - pillWidth) / 2;

                                  return Stack(
                                    children: [
                                      // 1. VIÊN THUỐC ĐỎ DUY NHẤT TRƯỢT MƯỢT TRÊN MẶT KÍNH (Liquid Glider)
                                      // Chuyển động lướt nhung 400ms Curves.easeInOutCubic, biến pill thành GPU texture
                                      AnimatedPositioned(
                                        duration: const Duration(
                                          milliseconds: 400,
                                        ),
                                        curve: Curves.easeInOutCubic,
                                        left: pillLeft,
                                        top: pillTop,
                                        width: pillWidth,
                                        height: pillHeight,
                                        child: RepaintBoundary(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors:
                                                    ThemeService
                                                        .instance
                                                        .isWindowsBlue
                                                    ? const [
                                                        Color(0xFF66C7F4),
                                                        Color(0xFF00A2ED),
                                                      ]
                                                    : ThemeService
                                                          .instance
                                                          .isLuxuryGold
                                                    ? const [
                                                        Color(0xFFF6E2A8),
                                                        Color(0xFFD4AF37),
                                                        Color(0xFF9E782F),
                                                      ]
                                                    : const [
                                                        Color(0xFFFF2E3D),
                                                        Color(0xFFE50914),
                                                      ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    pillHeight / 2,
                                                  ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: ThemeService
                                                      .instance
                                                      .primaryColor
                                                      .withValues(alpha: 0.45),
                                                  blurRadius: 12,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),

                                      // 2. HÀNG 4 TABS CỐ ĐỊNH NẰM TRÊN, CĂN CHÍNH XÁC 100% TỪNG CỘT
                                      Row(
                                        children: List.generate(tabCount, (
                                          index,
                                        ) {
                                          final isSelected =
                                              selectedIndex == index;
                                          return Expanded(
                                            child: _InteractiveTabItem(
                                              tab: _tabIcons[index],
                                              isSelected: isSelected,
                                              onTap: () => onTabSelected(index),
                                            ),
                                          );
                                        }),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // ĐẢO BÊN PHẢI: Nút tròn tiện ích nhanh
                  // Ghép 2 layer SIBLING trong Stack: Nền riêng, Nội dung riêng
                  SizedBox(
                    width: 66,
                    height: 66,
                    child: Stack(
                      children: [
                        // Layer 1: NỀN kính mờ tròn - Bọc RepaintBoundary cách ly shader
                        const Positioned.fill(
                          child: RepaintBoundary(
                            child: GlassNavBackground(
                              isOval: true,
                              borderRadius: 33,
                              width: 66,
                              height: 66,
                            ),
                          ),
                        ),
                        // Layer 2: NỘI DUNG - nút bấm tiện ích 4 ô vuông xoay 3D nằm ĐÈ LÊN TRÊN
                        Positioned.fill(
                          child: RepaintBoundary(
                            child: _QuickActionButton(
                              onPressed: onQuickActionPressed,
                              animate: animateQuickAction,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Nút tab tương tác mượt mà với hiệu ứng phóng nhẹ (Scale 1.10) và độ trong suốt (Alpha Blend)
/// đồng bộ 100% với viên thuốc lướt nhung (Curves.easeInOutCubic, 400ms), cách ly bằng RepaintBoundary
class _InteractiveTabItem extends StatelessWidget {
  final ({IconData active, IconData inactive, String label}) tab;
  final bool isSelected;
  final VoidCallback onTap;

  const _InteractiveTabItem({
    required this.tab,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: tab.label,
      selected: isSelected,
      child: Tooltip(
        message: tab.label,
        child: RepaintBoundary(
          child: GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              onTap();
            },
            behavior: HitTestBehavior.opaque,
            child: Center(
              child: SizedBox(
                width: 56,
                height: 42,
                child: Center(
                  child: AnimatedScale(
                    scale: isSelected ? 1.10 : 1.0,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOutCubic,
                    // Độ mờ của tab chưa chọn được đưa thẳng vào alpha của icon
                    // thay vì bọc thêm Opacity: cùng một kết quả hình ảnh nhưng
                    // không tạo saveLayer mỗi frame trong suốt 400ms chạy pill.
                    child: AnimatedMorphIcon(
                      icon: isSelected ? tab.active : tab.inactive,
                      size: 22,
                      color: Colors.white.withValues(
                        alpha: isSelected ? 1.0 : 0.65,
                      ),
                      spring: MorphSprings.smooth,
                    ),
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

/// Nút tiện ích nhanh (Quick Action Button) có phản hồi nén nhẹ êm ái khi chạm
class _QuickActionButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool? animate;

  const _QuickActionButton({required this.onPressed, this.animate});

  @override
  State<_QuickActionButton> createState() => _QuickActionButtonState();
}

class _QuickActionButtonState extends State<_QuickActionButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onPressed();
      },
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: AnimatedScale(
          scale: _isPressed ? 0.88 : 1.0,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          child: FourTileQuickActionIcon(size: 30, animate: widget.animate),
        ),
      ),
    );
  }
}

/// Khung viền ngoài màu đen vát quang học (Dark Bevel Chamfer Frame)
class _DarkBevelGlassWrapper extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final bool isOval;

  const _DarkBevelGlassWrapper({
    required this.child,
    this.borderRadius = 33,
    this.isOval = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: isOval ? null : BorderRadius.circular(borderRadius),
        shape: isOval ? BoxShape.circle : BoxShape.rectangle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          // 1. Giữ nguyên 100% nội dung glass bên dưới
          child,
          // 2. Viền vát quang học thanh mảnh siêu sắc nét (Hairline Bevel Rim ~0.8px)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _DarkGlassBevelRimPainter(
                  borderRadius: borderRadius,
                  isOval: isOval,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DarkGlassBevelRimPainter extends CustomPainter {
  final double borderRadius;
  final bool isOval;

  const _DarkGlassBevelRimPainter({
    required this.borderRadius,
    required this.isOval,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    // Viền vát quang học thanh mảnh siêu sắc nét (~0.8px) chuẩn phong cách kính cao cấp
    final rimPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(
            0xB0FFFFFF,
          ), // Specular highlight trắng ánh kim sắc nét mép trên-trái
          Color(0x35FFFFFF), // Ánh kính chuyển tiếp
          Color(0x2564748B), // Slate xám thanh mảnh hông
          Color(0x481E293B), // Xám than thanh nhã mép dưới
        ],
        stops: [0.0, 0.20, 0.55, 1.0],
      ).createShader(rect);

    if (isOval) {
      canvas.drawOval(rect.deflate(0.4), rimPaint);
    } else {
      final outerRRect = RRect.fromRectAndRadius(
        rect.deflate(0.4),
        Radius.circular(borderRadius - 0.4),
      );
      canvas.drawRRect(outerRRect, rimPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _DarkGlassBevelRimPainter oldDelegate) =>
      oldDelegate.borderRadius != borderRadius || oldDelegate.isOval != isOval;
}
