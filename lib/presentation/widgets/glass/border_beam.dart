import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Kích thước độ dài của chùm sáng (Beam Size)
enum BorderBeamSize {
  /// Ngắn (khoảng 80px)
  sm,

  /// Tiêu chuẩn / Trung bình (khoảng 140px)
  md,

  /// Dài (khoảng 220px)
  lg,

  /// Bao phủ 35% chu vi viền
  relative,
}

/// Các biến thể màu sắc có sẵn cho BorderBeam
enum BorderBeamColorVariant {
  /// OpenFlix / Netflix Brand (Đỏ #E50914 -> Cam Hồng Neon #FF5252)
  brand,

  /// Dải màu cực quang Rainbow nhiều sắc độ
  rainbow,

  /// Xanh Neon Điện tử / Cyber Cyan (#00F2FE -> #4FACFE)
  neonBlue,

  /// Hổ phách / Vàng Gold sang trọng (#F6D365 -> #FDA085)
  amberGold,

  /// Ngọc lục bảo Emerald (#00F5A0 -> #00D9F5)
  emerald,

  /// Tím mộng mơ Purple Haze (#B057FF -> #FF5E97)
  purpleHaze,

  /// Đơn sắc trắng bạc tối giản Monochrome
  monochrome,
}

/// Theme nền cho BorderBeam
enum BorderBeamTheme {
  dark,
  light,
  cyber,
}

/// Thuộc tính cấu hình cho BorderBeam tương đương TypeScript BorderBeamProps
class BorderBeamProps {
  final double duration;
  final double borderWidth;
  final BorderRadiusGeometry borderRadius;
  final BorderBeamSize size;
  final double? customSize;
  final BorderBeamColorVariant colorVariant;
  final List<Color>? customColors;
  final Color? trackColor;
  final double glowRadius;
  final bool showGlow;
  final bool reverse;
  final double initialProgress;
  final bool active;

  const BorderBeamProps({
    this.duration = 6.0,
    this.borderWidth = 1.8,
    this.borderRadius = const BorderRadius.all(Radius.circular(24.0)),
    this.size = BorderBeamSize.md,
    this.customSize,
    this.colorVariant = BorderBeamColorVariant.brand,
    this.customColors,
    this.trackColor,
    this.glowRadius = 7.0,
    this.showGlow = true,
    this.reverse = false,
    this.initialProgress = 0.0,
    this.active = true,
  });
}

/// Widget hiệu ứng chùm sáng chạy dọc viền container (BorderBeam),
/// lấy cảm hứng từ Magic UI Border Beam & tương thích hoàn toàn trên Flutter Mobile.
class BorderBeam extends StatefulWidget {
  final Widget? child;
  final double duration;
  final double borderWidth;
  final BorderRadiusGeometry borderRadius;
  final BorderBeamSize size;
  final double? customSize;
  final BorderBeamColorVariant colorVariant;
  final List<Color>? customColors;
  final Color? trackColor;
  final double glowRadius;
  final bool showGlow;
  final bool reverse;
  final double initialProgress;
  final bool active;

  const BorderBeam({
    super.key,
    this.child,
    this.duration = 6.0,
    this.borderWidth = 1.8,
    this.borderRadius = const BorderRadius.all(Radius.circular(24.0)),
    this.size = BorderBeamSize.md,
    this.customSize,
    this.colorVariant = BorderBeamColorVariant.brand,
    this.customColors,
    this.trackColor,
    this.glowRadius = 7.0,
    this.showGlow = true,
    this.reverse = false,
    this.initialProgress = 0.0,
    this.active = true,
  });

  /// Khởi tạo BorderBeam từ `BorderBeamProps`
  factory BorderBeam.fromProps({
    Key? key,
    required BorderBeamProps props,
    Widget? child,
  }) {
    return BorderBeam(
      key: key,
      duration: props.duration,
      borderWidth: props.borderWidth,
      borderRadius: props.borderRadius,
      size: props.size,
      customSize: props.customSize,
      colorVariant: props.colorVariant,
      customColors: props.customColors,
      trackColor: props.trackColor,
      glowRadius: props.glowRadius,
      showGlow: props.showGlow,
      reverse: props.reverse,
      initialProgress: props.initialProgress,
      active: props.active,
      child: child,
    );
  }

  @override
  State<BorderBeam> createState() => _BorderBeamState();
}

class _BorderBeamState extends State<BorderBeam>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (widget.duration * 1000).toInt()),
      value: widget.initialProgress.clamp(0.0, 1.0),
    );

    if (widget.active) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant BorderBeam oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration =
          Duration(milliseconds: (widget.duration * 1000).toInt());
      if (widget.active && !_controller.isAnimating) {
        _controller.repeat();
      }
    }

    if (oldWidget.active != widget.active) {
      if (widget.active) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Color> _resolveColors() {
    if (widget.customColors != null && widget.customColors!.isNotEmpty) {
      return widget.customColors!;
    }
    switch (widget.colorVariant) {
      case BorderBeamColorVariant.brand:
        return const [
          Color(0xFFE50914), // Netflix Red
          Color(0xFFFF334B),
          Color(0xFFFF758C),
        ];
      case BorderBeamColorVariant.rainbow:
        return const [
          Color(0xFFFF007A),
          Color(0xFF7928CA),
          Color(0xFF0070F3),
          Color(0xFF00DFD8),
          Color(0xFFFF007A),
        ];
      case BorderBeamColorVariant.neonBlue:
        return const [
          Color(0xFF00C6FF),
          Color(0xFF0072FF),
          Color(0xFF4FACFE),
        ];
      case BorderBeamColorVariant.amberGold:
        return const [
          Color(0xFFFFB300),
          Color(0xFFF6D365),
          Color(0xFFFDA085),
        ];
      case BorderBeamColorVariant.emerald:
        return const [
          Color(0xFF00F5A0),
          Color(0xFF00D9F5),
          Color(0xFF0575E6),
        ];
      case BorderBeamColorVariant.purpleHaze:
        return const [
          Color(0xFFB057FF),
          Color(0xFFFF5E97),
          Color(0xFFDA22FF),
        ];
      case BorderBeamColorVariant.monochrome:
        return [
          Colors.white.withValues(alpha: 0.95),
          Colors.white.withValues(alpha: 0.50),
          Colors.white.withValues(alpha: 0.20),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = _resolveColors();
    final defaultTrackColor =
        widget.trackColor ?? Colors.white.withValues(alpha: 0.08);

    return RepaintBoundary(
      child: CustomPaint(
        foregroundPainter: _BorderBeamPainter(
          progress: _controller,
          borderWidth: widget.borderWidth,
          borderRadius: widget.borderRadius.resolve(
            Directionality.maybeOf(context) ?? TextDirection.ltr,
          ),
          size: widget.size,
          customSize: widget.customSize,
          colors: colors,
          trackColor: defaultTrackColor,
          glowRadius: widget.glowRadius,
          showGlow: widget.showGlow,
          reverse: widget.reverse,
          active: widget.active,
        ),
        child: widget.child,
      ),
    );
  }
}

class _BorderBeamPainter extends CustomPainter {
  final Animation<double> progress;
  final double borderWidth;
  final BorderRadius borderRadius;
  final BorderBeamSize size;
  final double? customSize;
  final List<Color> colors;
  final Color trackColor;
  final double glowRadius;
  final bool showGlow;
  final bool reverse;
  final bool active;

  _BorderBeamPainter({
    required this.progress,
    required this.borderWidth,
    required this.borderRadius,
    required this.size,
    required this.customSize,
    required this.colors,
    required this.trackColor,
    required this.glowRadius,
    required this.showGlow,
    required this.reverse,
    required this.active,
  }) : super(repaint: progress);

  @override
  void paint(Canvas canvas, Size canvasSize) {
    if (canvasSize.width <= 0 || canvasSize.height <= 0) return;

    // Deflate nửa strokeWidth để viền nằm gọn bên trong ranh giới container
    final halfStroke = borderWidth / 2.0;
    final strokeRect = Rect.fromLTWH(
      halfStroke,
      halfStroke,
      math.max(0.0, canvasSize.width - borderWidth),
      math.max(0.0, canvasSize.height - borderWidth),
    );

    // Điều chỉnh bán kính bo góc tương ứng
    final innerRadius = BorderRadius.only(
      topLeft: Radius.circular(math.max(0.0, borderRadius.topLeft.x - halfStroke)),
      topRight: Radius.circular(math.max(0.0, borderRadius.topRight.x - halfStroke)),
      bottomLeft: Radius.circular(math.max(0.0, borderRadius.bottomLeft.x - halfStroke)),
      bottomRight: Radius.circular(math.max(0.0, borderRadius.bottomRight.x - halfStroke)),
    );

    final rrect = innerRadius.toRRect(strokeRect);
    final path = Path()..addRRect(rrect);

    // 1. Vẽ đường viền rãnh tĩnh (track)
    if (trackColor.a > 0 && borderWidth > 0) {
      final trackPaint = Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth;
      canvas.drawRRect(rrect, trackPaint);
    }

    // Nếu không kích hoạt hoạt ảnh beam thì dừng tại đây (chỉ giữ viền rãnh tĩnh)
    if (!active) return;

    // 2. Tính toán chu vi hình học bằng PathMetric
    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return;
    final metric = metrics.first;
    final totalLength = metric.length;
    if (totalLength <= 0) return;

    // 3. Xác định độ dài chùm sáng beamLength
    double beamLength;
    if (customSize != null && customSize! > 0) {
      beamLength = customSize!;
    } else {
      switch (size) {
        case BorderBeamSize.sm:
          beamLength = math.min(85.0, totalLength * 0.22);
          break;
        case BorderBeamSize.md:
          beamLength = math.min(145.0, totalLength * 0.32);
          break;
        case BorderBeamSize.lg:
          beamLength = math.min(220.0, totalLength * 0.48);
          break;
        case BorderBeamSize.relative:
          beamLength = totalLength * 0.35;
          break;
      }
    }

    final currentProgress = progress.value;
    final effectiveProgress =
        reverse ? (1.0 - currentProgress) : currentProgress;
    final startDistance = (effectiveProgress * totalLength) % totalLength;

    // Phân tích thành 32 phân đoạn nhỏ để tạo dải màu mượt mà tuyệt đối dọc theo đường cong
    const int segmentsCount = 32;
    final stepLength = beamLength / segmentsCount;
    final segments = <({Path path, Color color, double alphaFactor})>[];
    for (int i = 0; i < segmentsCount; i++) {
      final t2 = (i + 1) / segmentsCount;
      final dist1 = (startDistance + i * stepLength) % totalLength;
      final dist2 = (startDistance + (i + 1) * stepLength) % totalLength;
      final segmentPath = dist1 <= dist2
          ? metric.extractPath(dist1, dist2)
          : (Path()
            ..addPath(metric.extractPath(dist1, totalLength), Offset.zero)
            ..addPath(metric.extractPath(0, dist2), Offset.zero));

      segments.add((
        path: segmentPath,
        color: _sampleColor(t2),
        alphaFactor: math.pow(t2, 2.2).toDouble().clamp(0.0, 1.0),
      ));
    }

    // Lớp 1: Hiệu ứng ánh sáng toả rộng ngoài viền (Outer Glow)
    if (showGlow && glowRadius > 0) {
      final glowPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth + 2.0
        ..strokeCap = StrokeCap.round
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, glowRadius);
      for (final segment in segments) {
        glowPaint.color = segment.color.withValues(
          alpha: segment.color.a * (segment.alphaFactor * 0.50),
        );
        canvas.drawPath(segment.path, glowPaint);
      }
    }

    // Lớp 2: Lõi sáng sắc nét chạy chính xác trên viền (Sharp Core)
    final corePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..strokeCap = StrokeCap.round;
    for (final segment in segments) {
      corePaint.color = segment.color.withValues(alpha: segment.color.a * segment.alphaFactor);
      canvas.drawPath(segment.path, corePaint);
    }

    // Lớp 3: Đầu chùm sáng (Spark Head) tạo cảm giác nguồn sáng dẫn đường
    final headDist = (startDistance + beamLength) % totalLength;
    final headTangent = metric.getTangentForOffset(headDist);
    if (headTangent != null) {
      final headColor = colors.last;
      final sparkPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.90)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(headTangent.position, borderWidth * 0.85, sparkPaint);

      if (showGlow) {
        final sparkGlow = Paint()
          ..color = headColor.withValues(alpha: 0.65)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, glowRadius * 0.8);
        canvas.drawCircle(headTangent.position, borderWidth * 1.8, sparkGlow);
      }
    }
  }

  Color _sampleColor(double t) {
    if (colors.isEmpty) return Colors.white;
    if (colors.length == 1) return colors.first;

    final scaled = t * (colors.length - 1);
    final index = scaled.floor().clamp(0, colors.length - 2);
    final remainder = scaled - index;

    return Color.lerp(colors[index], colors[index + 1], remainder)!;
  }

  @override
  bool shouldRepaint(covariant _BorderBeamPainter old) {
    return old.progress != progress ||
        old.borderWidth != borderWidth ||
        old.borderRadius != borderRadius ||
        old.size != size ||
        old.customSize != customSize ||
        old.trackColor != trackColor ||
        old.glowRadius != glowRadius ||
        old.showGlow != showGlow ||
        old.reverse != reverse ||
        old.active != active;
  }
}
