import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../../dark_luxury_background.dart';
import '../../../services/theme_service.dart';
import '../../../waves_background.dart';

/// Nền shader "Silk" uốn lượn phong cách điện ảnh cao cấp:
/// - Mặc định: Đỏ điện ảnh Netflix (#02010A ➔ #E50914).
/// - Tùy chọn: Xanh Windows 11 (#010A14 ➔ #0078D4 & Trắng vi mô).
///
/// Tối ưu hóa hiệu năng cao cho màn hình khởi động (Loading/Splash Screen):
/// - Sử dụng FragmentProgram nạp một lần.
/// - Hỗ trợ renderScale giảm độ phân giải tính toán GPU (0.5 = 1/4 pixel) và phóng đại sắc nét.
/// - Điều tiết FPS (~30fps) cho nền mượt mà, tiết kiệm pin.
/// - Fallback liền mạch với dải màu gradient điện ảnh khi đang nạp shader hoặc trong môi trường test/web.
class SilkBackground extends StatefulWidget {
  const SilkBackground({
    super.key,
    this.child,
    this.renderScale = 0.5,
    this.fps = 30,
    this.speed = 0.38,
    this.themeMode,
  });

  final Widget? child;
  final double renderScale;
  final int fps;
  final double speed;
  final AppThemeMode? themeMode;

  @override
  State<SilkBackground> createState() => _SilkBackgroundState();
}

class _SilkBackgroundState extends State<SilkBackground>
    with SingleTickerProviderStateMixin {
  // Nạp shader một lần cho cả app
  static Future<ui.FragmentProgram>? _programFuture;
  static Future<ui.FragmentProgram> get _program {
    return _programFuture ??= ui.FragmentProgram.fromAsset('shaders/silk.frag');
  }

  // Chu kỳ chung chính xác của các số hạng cos(t*0.8) và cos(t*0.6) => lặp liền mạch,
  // không bị mất độ chính xác khi app chạy lâu.
  static const double _period = 10 * math.pi;

  final _time = ValueNotifier<double>(0);
  Ticker? _ticker;
  ui.FragmentShader? _shader;
  Duration _lastPaint = Duration.zero;

  @override
  void initState() {
    super.initState();
    ThemeService.instance.addListener(_onThemeChanged);
    _ticker = createTicker(_onTick);
    try {
      _program.then((p) {
        if (!mounted) return;
        setState(() => _shader = p.fragmentShader());
      }, onError: (_) {}); // Lỗi nạp shader -> giữ nền gradient dự phòng
    } catch (_) {}
  }

  void _onThemeChanged() {
    if (mounted) setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Người dùng bật "giảm chuyển động" -> đứng yên ở khung hình hiện tại.
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (reduce) {
      _ticker?.stop();
    } else if (_ticker != null && !_ticker!.isActive) {
      _lastPaint = Duration.zero;
      _ticker!.start();
    }
  }

  void _onTick(Duration elapsed) {
    // Cắt xuống ~widget.fps: chỉ cập nhật time (và vẽ lại) khi đủ khoảng cách.
    final minGapUs = 1000000 ~/ widget.fps - 4000;
    if ((elapsed - _lastPaint).inMicroseconds < minGapUs) return;
    _lastPaint = elapsed;
    _time.value = (elapsed.inMicroseconds / 1e6 * widget.speed) % _period;
  }

  @override
  void dispose() {
    ThemeService.instance.removeListener(_onThemeChanged);
    _ticker?.dispose();
    _time.dispose();
    _shader?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Nếu trong cây widget đã có ThemedBackdrop cấp app, không nhân đôi shader
    if (WavesBackground.isActiveIn(context)) {
      return widget.child ?? const SizedBox.expand();
    }

    final shader = _shader;
    final effectiveMode = widget.themeMode ?? ThemeService.instance.mode;
    if (effectiveMode == AppThemeMode.windowsBlue) {
      return WavesBackground(child: widget.child);
    }
    if (effectiveMode == AppThemeMode.luxuryGold) {
      return DarkLuxuryBackground(child: widget.child);
    }
    final themeValue = 0.0;

    return Stack(
      fit: StackFit.expand,
      children: [
        // RepaintBoundary: nền vẽ lại độc lập, không kéo UI phía trên vẽ lại theo.
        IgnorePointer(
          child: RepaintBoundary(
            child: shader == null
                ? _Fallback(
                    isWindowsBlue: effectiveMode == AppThemeMode.windowsBlue,
                    isLuxuryGold: effectiveMode == AppThemeMode.luxuryGold,
                  )
                : LayoutBuilder(
                    builder: (context, c) {
                      final s = widget.renderScale.clamp(0.25, 1.0).toDouble();
                      if (s >= 1.0) {
                        return CustomPaint(
                          size: c.biggest,
                          painter: _SilkPainter(shader, _time, themeValue),
                        );
                      }
                      final w = c.maxWidth * s;
                      final h = c.maxHeight * s;
                      // Vẽ ở kích thước nhỏ, rồi Transform phóng lên như bitmap => GPU chỉ tính shader trên w*h pixel.
                      return ClipRect(
                        child: OverflowBox(
                          alignment: Alignment.topLeft,
                          minWidth: w,
                          maxWidth: w,
                          minHeight: h,
                          maxHeight: h,
                          child: Transform.scale(
                            scale: 1 / s,
                            alignment: Alignment.topLeft,
                            filterQuality: FilterQuality.low,
                            child: CustomPaint(
                              size: Size(w, h),
                              painter: _SilkPainter(shader, _time, themeValue),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
        if (widget.child != null) widget.child!,
      ],
    );
  }
}

class _SilkPainter extends CustomPainter {
  _SilkPainter(this.shader, this.time, this.themeValue) : super(repaint: time);

  final ui.FragmentShader shader;
  final ValueNotifier<double> time;
  final double themeValue;
  late final Paint _paint = Paint()..shader = shader;

  @override
  void paint(Canvas canvas, Size size) {
    shader
      ..setFloat(0, size.width)
      ..setFloat(1, size.height)
      ..setFloat(2, time.value)
      ..setFloat(3, themeValue);
    canvas.drawRect(Offset.zero & size, _paint);
  }

  @override
  bool shouldRepaint(_SilkPainter old) =>
      old.shader != shader || old.themeValue != themeValue;
}

class _Fallback extends StatelessWidget {
  const _Fallback({this.isWindowsBlue = false, this.isLuxuryGold = false});

  final bool isWindowsBlue;
  final bool isLuxuryGold;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isWindowsBlue
            ? const [
                Color(0xFFF0F4F8), // Trắng mờ sương tuyết ngọc trai
                Color(0xFFD6EBFC), // Xanh lam mây sương
                Color(0xFF00A2ED), // Sắc xanh #00A2ED chủ đạo
                Color(0xFFFFFFFF), // Trắng sáng tinh khiết
              ]
            : isLuxuryGold
                ? const [
                    Color(0xFF060504), // Đen tuyền Luxury
                    Color(0xFF34250F), // Nâu sẫm hoàng gia
                    Color(0xFFB98A3A), // Vàng kim cổ điển
                    Color(0xFFF1D48B), // Vàng kim sáng rực
                  ]
                : const [
                    Color(0xFF02010A),
                    Color(0xFF2A0408),
                    Color(0xFFB20710),
                    Color(0xFFE50914),
                  ],
        stops: const [0, 0.45, 0.85, 1],
      ),
    ),
  );
}
