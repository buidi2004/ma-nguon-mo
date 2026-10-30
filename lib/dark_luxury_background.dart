import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'services/theme_service.dart';
import 'waves_background.dart';

/// Nền nghệ thuật Dark Luxury cao cấp:
/// - Lụa đen tuyền uốn lượn viền vàng kim
/// - Ánh vàng hoàng gia phát sáng ("thở" nhịp nhàng)
/// - Bông hoa bóng đêm cánh đen viền vàng, nhụy hoa phát sáng + vignette tối viền
/// - Hạt bụi vàng lấp lánh (Golden Dust particles) bay bổng
///
/// Hỗ trợ cả 2 chế độ:
/// 1. [DarkLuxuryBackground]: Bọc nội dung ứng dụng (`child`), cho phép chạm/vuốt bình thường qua IgnorePointer.
/// 2. [DarkLuxuryWallpaper]: Chế độ hình nền toàn màn hình độc lập (Scaffold).
class DarkLuxuryBackground extends StatefulWidget {
  const DarkLuxuryBackground({
    super.key,
    this.child,
    this.showGlow = true,
    this.showFlower = true,
    this.showDust = true,
    this.showVignette = true,
  });

  /// Widget nội dung hiển thị đè lên trên nền
  final Widget? child;

  /// Bật/tắt ánh vàng "thở" sau bông hoa
  final bool showGlow;

  /// Bật/tắt bông hoa đen viền vàng
  final bool showFlower;

  /// Bật/tắt hạt bụi vàng lấp lánh
  final bool showDust;

  /// Bật/tắt hiệu ứng tối 4 góc (Vignette)
  final bool showVignette;

  /// Số yêu cầu tạm ngưng chủ động (ví dụ: đang phát video che kín hoặc tiết kiệm GPU).
  static final ValueNotifier<int> _suspensions = ValueNotifier<int>(0);

  /// Tạm ngưng vẽ hoạt ảnh chuyển động.
  static void suspend() => _suspensions.value++;

  /// Khôi phục hoạt ảnh chuyển động sau khi tạm ngưng.
  static void resume() {
    if (_suspensions.value > 0) _suspensions.value--;
  }

  /// Báo hiệu video player bắt đầu phát
  static void notifyVideoPlaybackStarted() => suspend();

  /// Báo hiệu video player dừng phát hoặc huỷ
  static void notifyVideoPlaybackStopped() => resume();

  /// Kiểm tra có đang bị tạm ngưng hay không
  static bool get isSuspended => _suspensions.value > 0;

  /// Kiểm tra phía trên [context] đã có nền động DarkLuxury (hoặc ThemedBackdrop) chưa.
  static bool isActiveIn(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_DarkLuxuryBackgroundScope>() != null ||
        WavesBackground.isActiveIn(context);
  }

  /// Tự động bọc [child] trong [DarkLuxuryBackground] khi người dùng chọn chế độ màu vàng (Luxury Gold).
  static Widget wrapIfGold(Widget child) {
    return Builder(
      builder: (context) {
        if (isActiveIn(context)) return child;
        return ListenableBuilder(
          listenable: ThemeService.instance,
          builder: (context, _) {
            if (ThemeService.instance.isLuxuryGold) {
              return DarkLuxuryBackground(child: child);
            }
            return child;
          },
        );
      },
    );
  }

  @override
  State<DarkLuxuryBackground> createState() => _DarkLuxuryBackgroundState();
}

class _DarkLuxuryBackgroundState extends State<DarkLuxuryBackground>
    with SingleTickerProviderStateMixin {
  /// Nền này chỉ là ánh vàng "thở" 8 giây/vòng + bụi vàng trôi rất chậm.
  /// 30 fps cho cùng một quỹ đạo mắt thường không phân biệt được, nhưng cắt
  /// hẳn một nửa số lần vẽ lại toàn màn hình (mỗi lần gồm 1 bóng blur bán
  /// kính 320 px) — chi phí mà mọi thao tác cuộn/chuyển màn phía trên phải
  /// chia sẻ. Đây cũng là mức fps của `WavesBackground`.
  static const Duration _frameStep = Duration(milliseconds: 33);
  static const Duration _cycle = Duration(seconds: 8);

  late final Ticker _ticker;
  final ValueNotifier<double> _phase = ValueNotifier<double>(0.0);
  Duration _lastTick = Duration.zero;
  double _accumulatedSeconds = 0.0;
  bool _reduceMotion = false;

  bool get _isInTestBinding =>
      WidgetsBinding.instance.runtimeType.toString().contains('Test');

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    DarkLuxuryBackground._suspensions.addListener(_onSuspensionChanged);
    if (!_isInTestBinding && (widget.showGlow || widget.showDust)) {
      _ticker.start();
    }
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

  void _onSuspensionChanged() {
    if (mounted) _checkAnimationState();
  }

  void _checkAnimationState() {
    if (_isInTestBinding) return;
    final isDeduplicated = DarkLuxuryBackground.isActiveIn(context);
    final isStatic = (!widget.showGlow && !widget.showDust);
    final shouldStop =
        isDeduplicated || DarkLuxuryBackground.isSuspended || _reduceMotion || isStatic;
    if (shouldStop) {
      if (_ticker.isActive) _ticker.stop();
    } else {
      if (!_ticker.isActive) {
        _lastTick = Duration.zero;
        _ticker.start();
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    _checkAnimationState();
  }

  @override
  void didUpdateWidget(covariant DarkLuxuryBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    _checkAnimationState();
  }

  @override
  void dispose() {
    DarkLuxuryBackground._suspensions.removeListener(_onSuspensionChanged);
    _ticker.dispose();
    _phase.dispose();
    super.dispose();
  }

  Widget _layer(CustomPainter p) => Positioned.fill(
    child: RepaintBoundary(child: CustomPaint(painter: p)),
  );

  @override
  Widget build(BuildContext context) {
    if (DarkLuxuryBackground.isActiveIn(context)) {
      return widget.child ?? const SizedBox.shrink();
    }

    return _DarkLuxuryBackgroundScope(
      child: Material(
        color: const Color(0xFF060504),
        child: Stack(
          fit: StackFit.expand,
          children: [
            IgnorePointer(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _layer(
                    const _BgPainter(),
                  ), // Lớp 1: lụa đen + ánh sáng vàng (tĩnh)
                  if (widget.showGlow)
                    _layer(_GlowPainter(_phase)), // Lớp 2: ánh vàng "thở"
                  if (widget.showFlower)
                    _layer(const _FlowerPainter()) // Lớp 3: bông hoa + vignette
                  else if (widget.showVignette)
                    _layer(
                      const _VignettePainter(),
                    ), // Vignette độc lập nếu tắt hoa
                  if (widget.showDust)
                    _layer(_DustPainter(_phase)), // Lớp 4: hạt bụi vàng
                ],
              ),
            ),
            if (widget.child != null) widget.child!,
          ],
        ),
      ),
    );
  }
}

/// Hình nền Dark Luxury độc lập (chế độ toàn màn hình cho wallpaper / demo).
class DarkLuxuryWallpaper extends StatelessWidget {
  const DarkLuxuryWallpaper({
    super.key,
    this.child,
    this.showGlow = true,
    this.showFlower = true,
    this.showDust = true,
    this.showVignette = true,
  });

  final Widget? child;
  final bool showGlow;
  final bool showFlower;
  final bool showDust;
  final bool showVignette;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF060504),
      body: DarkLuxuryBackground(
        showGlow: showGlow,
        showFlower: showFlower,
        showDust: showDust,
        showVignette: showVignette,
        child: child,
      ),
    );
  }
}

// ---------- Hằng số & Phép chiếu tỉ lệ màn hình ----------
const double _kW = 900;
const double _kH = 2000; // Khung thiết kế tỷ lệ chuẩn 9:20

void _fit(Canvas c, Size s) {
  final k = math.max(s.width / _kW, s.height / _kH);
  c.translate((s.width - _kW * k) / 2, (s.height - _kH * k) / 2);
  c.scale(k);
}

ui.Shader _goldX(double o) => ui.Gradient.linear(
  Offset.zero,
  const Offset(_kW, 0),
  [
    0xFF6D4A18,
    0xFFF1D48B,
    0xFFB98A3A,
    0xFFF6E2A8,
    0xFF7A5420,
  ].map((v) => Color(v).withAlpha((o.clamp(0.0, 1.0) * 255).round())).toList(),
  const [0.0, .3, .55, .8, 1.0],
);

Paint _line(double w, ui.Shader sh, {double blur = 0}) => Paint()
  ..style = PaintingStyle.stroke
  ..strokeWidth = w
  ..shader = sh
  ..maskFilter = blur > 0 ? MaskFilter.blur(BlurStyle.normal, blur) : null;

void _crest(Canvas c, Path p, double glowW, double lineW) {
  c.drawPath(p, _line(glowW, _goldX(.4), blur: 9));
  c.drawPath(p, _line(lineW, _goldX(1)));
}

void _glow(Canvas c, Offset o, double r, Color a, Color b) {
  c.drawRect(
    const Rect.fromLTWH(0, 0, _kW, _kH),
    Paint()
      ..shader = ui.Gradient.radial(
        o,
        r,
        [a, b, const Color(0x00000000)],
        const [0.0, .5, 1.0],
      ),
  );
}

// ---------- Lớp 1: Nền + Lụa Đen Uốn Lượn Viền Vàng ----------
class _BgPainter extends CustomPainter {
  const _BgPainter();

  @override
  void paint(Canvas c, Size s) {
    _fit(c, s);
    c.drawRect(
      const Rect.fromLTWH(0, 0, _kW, _kH),
      Paint()..color = const Color(0xFF060504),
    );
    _glow(
      c,
      const Offset(522, 1240),
      900,
      const Color(0x997A5320),
      const Color(0x4D2B1C09),
    );
    _glow(
      c,
      const Offset(765, 200),
      650,
      const Color(0x735A3F18),
      const Color(0x335A3F18),
    );

    // Lụa phía trên
    final topCrest = Path()
      ..moveTo(-60, 560)
      ..cubicTo(160, 420, 340, 700, 560, 580)
      ..cubicTo(780, 460, 820, 420, 980, 520);
    final topBody = Path.from(topCrest)
      ..lineTo(980, 760)
      ..cubicTo(800, 640, 600, 800, 420, 760)
      ..cubicTo(240, 720, 120, 640, -60, 740)
      ..close();
    c.drawPath(
      topBody,
      Paint()
        ..shader = ui.Gradient.linear(
          const Offset(0, 420),
          const Offset(0, 800),
          const [Color(0xFF34250F), Color(0x33070504)],
        ),
    );
    _crest(c, topCrest, 10, 2.5);
    for (var j = 0; j < 12; j++) {
      final z = 580 + j * 20.0;
      final p = Path()
        ..moveTo(-60, z)
        ..cubicTo(160, z - 140 + j * 8, 340, z + 130 - j * 6, 560, z + 20)
        ..cubicTo(780, z - 90 + j * 6, 820, z - 140 + j * 5, 980, z - 30);
      c.drawPath(p, _line(1.1, _goldX(.45 - j * .035)));
    }

    // Lụa phía dưới
    final lowCrest = Path()
      ..moveTo(-60, 1420)
      ..cubicTo(140, 1290, 330, 1570, 560, 1470)
      ..cubicTo(790, 1370, 860, 1290, 980, 1390);
    final lowBody = Path.from(lowCrest)
      ..lineTo(980, 2000)
      ..lineTo(-60, 2000)
      ..close();
    c.drawPath(
      lowBody,
      Paint()
        ..shader = ui.Gradient.linear(
          const Offset(0, 1330),
          const Offset(0, 2000),
          const [Color(0xFF4A3416), Color(0xFF140F08), Color(0xFF050403)],
          const [0.0, .25, 1.0],
        ),
    );
    _crest(c, lowCrest, 12, 3);
    for (var k = 0; k < 16; k++) {
      final y = 1400 + k * 24.0;
      final p = Path()
        ..moveTo(-60, y)
        ..cubicTo(140, y - 130 + k * 7, 330, y + 150 - k * 6, 560, y + 50)
        ..cubicTo(790, y - 50 + k * 6, 860, y - 130 + k * 4, 980, y - 30);
      c.drawPath(p, _line(1.2, _goldX(.55 - k * .03)));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ---------- Lớp 2: Ánh Vàng "Thở" Sau Bông Hoa ----------
class _GlowPainter extends CustomPainter {
  _GlowPainter(this.anim) : super(repaint: anim);
  final ValueListenable<double> anim;

  static const Offset _glowCenter = Offset(420, 1430);
  static const double _glowRadius = 360.0;
  static final Paint _paint = Paint();

  @override
  void paint(Canvas c, Size s) {
    _fit(c, s);
    final b = .22 + .12 * (.5 + .5 * math.sin(2 * math.pi * anim.value));
    final alpha = (b.clamp(0.0, 1.0) * 255).round();
    _paint.shader = ui.Gradient.radial(
      _glowCenter,
      _glowRadius,
      [
        const Color(0xFFC8963E).withAlpha(alpha),
        const Color(0xFFC8963E).withAlpha((alpha * 0.58).round()),
        const Color(0xFFC8963E).withAlpha((alpha * 0.18).round()),
        const Color(0x00C8963E),
      ],
      const [0.0, 0.40, 0.75, 1.0],
    );
    // Vẽ quầng sáng quang học phần cứng trực tiếp, loại bỏ Gaussian Blur CPU/GPU
    // để giữ 60fps mượt mà cho hiệu ứng kính mờ (LiquidGlass) phía trước.
    c.drawCircle(_glowCenter, _glowRadius, _paint);
  }

  @override
  bool shouldRepaint(covariant _GlowPainter old) => old.anim != anim;
}

// ---------- Lớp 3: Bông Hoa Đen Viền Vàng + Vignette ----------
class _FlowerPainter extends CustomPainter {
  const _FlowerPainter();

  @override
  void paint(Canvas c, Size s) {
    _fit(c, s);
    c.save();
    c.translate(400, 1500);
    c.scale(1.3);

    final petal = Path()
      ..moveTo(0, 0)
      ..cubicTo(-95, -110, -85, -310, 0, -430)
      ..cubicTo(85, -310, 95, -110, 0, 0)
      ..close();
    final vein = Path()
      ..moveTo(0, -10)
      ..cubicTo(6, -140, 6, -280, 0, -405);
    final fill = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(0, -430),
        Offset.zero,
        const [
          Color(0xFFB98A3A),
          Color(0xFF3B2A12),
          Color(0xFF0C0906),
          Color(0xFF050403),
        ],
        const [0.0, .22, .6, 1.0],
      );
    final edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..shader = ui.Gradient.linear(
        const Offset(-95, -430),
        const Offset(95, 0),
        const [
          Color(0xFFF4DCA0),
          Color(0xFF6B4A1C),
          Color(0xFF2A1D0B),
          Color(0xFFB98A3A),
          Color(0xFFF4DCA0),
        ],
        const [0.0, .3, .6, .85, 1.0],
      );
    final veinP = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = const Color(0x59E8C776);

    // [góc xoay (độ), tỉ lệ]
    for (final p in const [
      [-32.0, .78],
      [118.0, .62],
      [84.0, .9],
      [6.0, .95],
      [58.0, 1.0],
      [30.0, .82],
      [-10.0, .7],
      [100.0, .7],
    ]) {
      c.save();
      c.rotate(p[0] * math.pi / 180);
      c.scale(p[1]);
      c.drawPath(petal, fill);
      c.drawPath(petal, edge);
      c.drawPath(vein, veinP);
      c.restore();
    }

    // Nhụy vàng phát sáng
    final st = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xE6F0D28A);
    for (final q in const [
      [14.0, -70.0, 30.0, -130.0, 58.0, -190.0],
      [26.0, -60.0, 60.0, -110.0, 110.0, -150.0],
      [-6.0, -80.0, -4.0, -150.0, 12.0, -215.0],
      [40.0, -40.0, 90.0, -70.0, 150.0, -80.0],
    ]) {
      c.drawPath(
        Path()
          ..moveTo(0, 0)
          ..cubicTo(q[0], q[1], q[2], q[3], q[4], q[5]),
        st,
      );
      final tip = Offset(q[4], q[5]);
      c.drawCircle(
        tip,
        9,
        Paint()
          ..color = const Color(0x80FFE9A8)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
      c.drawCircle(tip, 5, Paint()..color = const Color(0xFFFFE9A8));
    }
    c.restore();

    // Vignette tối viền
    c.drawRect(
      const Rect.fromLTWH(0, 0, _kW, _kH),
      Paint()
        ..shader = ui.Gradient.radial(
          const Offset(450, 1000),
          1100,
          const [Color(0x00000000), Color(0xBF000000)],
          const [.55, 1.0],
        ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ---------- Vignette Độc Lập Khi Tắt Hoa ----------
class _VignettePainter extends CustomPainter {
  const _VignettePainter();

  @override
  void paint(Canvas c, Size s) {
    _fit(c, s);
    c.drawRect(
      const Rect.fromLTWH(0, 0, _kW, _kH),
      Paint()
        ..shader = ui.Gradient.radial(
          const Offset(450, 1000),
          1100,
          const [Color(0x00000000), Color(0xBF000000)],
          const [.55, 1.0],
        ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ---------- Lớp 4: Hạt Bụi Vàng Lấp Lánh ----------
class _Dot {
  const _Dot(this.x, this.y, this.r, this.phase, this.speed);
  final double x, y, r, phase;
  final int speed;
}

class _DustPainter extends CustomPainter {
  _DustPainter(this.anim) : super(repaint: anim);
  final ValueListenable<double> anim;

  static final Paint _paint = Paint()..isAntiAlias = true;

  static final List<_Dot> _dots = () {
    final r = math.Random(7);
    return List.generate(
      70,
      (_) => _Dot(
        r.nextDouble() * _kW,
        r.nextDouble() * _kH,
        .6 + r.nextDouble() * 2.2,
        r.nextDouble(),
        1 + r.nextInt(2),
      ),
    );
  }();

  @override
  void paint(Canvas c, Size s) {
    _fit(c, s);
    final t = anim.value;
    for (final d in _dots) {
      final o =
          .08 +
          .87 *
              (.5 +
                  .5 *
                      math.sin(2 * math.pi * (t * d.speed + d.phase)));
      _paint.color = const Color(0xFFF3D68F)
          .withAlpha((o.clamp(0.0, 1.0) * 255).round());
      c.drawCircle(Offset(d.x, d.y), d.r, _paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DustPainter old) => old.anim != anim;
}

class _DarkLuxuryBackgroundScope extends InheritedWidget {
  const _DarkLuxuryBackgroundScope({required super.child});

  @override
  bool updateShouldNotify(_DarkLuxuryBackgroundScope oldWidget) => false;
}
