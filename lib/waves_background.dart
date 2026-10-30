import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'dark_luxury_background.dart';
import 'services/theme_service.dart';

class WavesBackground extends StatefulWidget {
  const WavesBackground({super.key, this.child});

  /// Nội dung hiển thị phía trên nền
  final Widget? child;

  /// Số yêu cầu tạm ngưng chủ động (vd: video đang phát che kín hoặc chiếm dụng GPU).
  static final ValueNotifier<int> _suspensions = ValueNotifier<int>(0);

  /// Tạm ngưng vẽ shader sóng — dùng khi lớp nền bị che kín hoàn toàn
  /// hoặc khi video đang phát, để GPU chỉ còn giải mã video.
  static void suspend() => _suspensions.value++;

  /// Bỏ một yêu cầu tạm ngưng trước đó.
  static void resume() {
    if (_suspensions.value > 0) _suspensions.value--;
  }

  /// Báo hiệu một video player bắt đầu phát
  static void notifyVideoPlaybackStarted() => suspend();

  /// Báo hiệu một video player dừng phát hoặc huỷ
  static void notifyVideoPlaybackStopped() => resume();

  /// Kiểm tra xem có video/tiến trình tạm ngưng nào đang hoạt động không
  static bool get isVideoPlaying => _suspensions.value > 0;

  /// Đăng ký lắng nghe sự kiện tạm ngưng hiệu ứng toàn cục (khi cuộn trang hoặc phát video)
  static void addSuspensionListener(VoidCallback listener) =>
      _suspensions.addListener(listener);

  /// Hủy đăng ký lắng nghe sự kiện tạm ngưng hiệu ứng toàn cục
  static void removeSuspensionListener(VoidCallback listener) =>
      _suspensions.removeListener(listener);

  /// Bọc [child] bằng nền động của theme đang chọn, nhưng **chỉ khi** phía trên
  /// chưa có nền dùng chung (xem [ThemedBackdrop]).
  ///
  /// Trước đây hàm này luôn dựng một [WavesBackground]/[DarkLuxuryBackground]
  /// mới cho mỗi màn hình. Vì mỗi nền là một fragment shader toàn màn hình chạy
  /// liên tục, app vừa trả giá 2–3 lượt shader cùng lúc (nền cấp app + nền cấp
  /// route + nền cấp shell), vừa khiến mỗi lần đổi theme phải thay widget gốc
  /// của cả màn hình — kéo theo remount toàn bộ màn hình đó (mất vị trí cuộn,
  /// dựng lại cây widget, giật rõ rệt khi "chuyển màu").
  ///
  /// Nay: nếu đã nằm trong một nền dùng chung thì trả lại đúng [child] (giữ
  /// nguyên identity ⇒ không remount), ngược lại mới tự dựng một nền.
  static Widget wrapIfBlue(Widget child) {
    return Builder(
      builder: (context) {
        if (isActiveIn(context)) return child;
        return ThemedBackdrop(child: child);
      },
    );
  }

  /// Kiểm tra phía trên [context] đã có nền động dùng chung chưa.
  ///
  /// Nền cấp app do [ThemedBackdrop] lắp đặt phía trên Navigator, nên mọi
  /// route/shell đều nhìn thấy nó; các lời gọi [wrapIfBlue] lồng bên trong vì
  /// thế trở thành no-op thay vì vẽ shader trùng lặp.
  static bool isActiveIn(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<_WavesBackgroundScope>() !=
        null;
  }

  @override
  State<WavesBackground> createState() => _WavesBackgroundState();
}

/// Nền nghệ thuật **dùng chung duy nhất** cho toàn ứng dụng.
///
/// Kiến trúc: một [Stack] hai lớp, lớp nền và lớp nội dung là hai *sibling*
/// tách biệt.
///
/// ```
/// Stack
/// ├─ _ThemedBackdropLayer   ← đổi theme chỉ dựng lại đúng lớp này
/// └─ _WavesBackgroundScope  ← child giữ nguyên identity
///    └─ child (Navigator)
/// ```
///
/// Vì lớp nền và nội dung là sibling, việc chuyển theme (Đỏ ⇄ Xanh ⇄ Vàng)
/// chỉ thay widget của lớp nền. Toàn bộ cây nội dung — 4 tab đang giữ trong
/// `IndexedStack`, mọi route trong stack, vị trí cuộn, state của từng màn —
/// được giữ nguyên tuyệt đối. Đây là điều kiện để "chuyển màu" không còn
/// remount cả app (nguyên nhân chính của cú giật khi đổi theme trước đây).
///
/// Đồng thời cả app chỉ còn **một** shader nền chạy: các màn hình gọi
/// [WavesBackground.wrapIfBlue] bên trong sẽ thấy scope này và trở thành
/// no-op, thay vì mỗi route lại dựng thêm một shader toàn màn hình.
class ThemedBackdrop extends StatefulWidget {
  const ThemedBackdrop({super.key, this.child});

  /// Nội dung ứng dụng (thường là `Navigator` do `MaterialApp.builder` cấp).
  final Widget? child;

  @override
  State<ThemedBackdrop> createState() => _ThemedBackdropState();
}

class _ThemedBackdropState extends State<ThemedBackdrop> {
  Timer? _scrollDebounceTimer;
  bool _isScrolling = false;

  bool get _isInTest =>
      WidgetsBinding.instance.runtimeType.toString().contains('Test');

  bool _onScrollNotification(ScrollNotification notification) {
    if (_isInTest) return false;

    // Khi người dùng bắt đầu cuộn bất kỳ danh sách nào trong app:
    // Tạm dừng hoạt ảnh nền shader GPU để dành 100% tài nguyên khung hình
    // cho việc cuộn mượt mà 60/120 fps. Nền vẫn giữ nguyên hiển thị tĩnh.
    if (notification is ScrollStartNotification ||
        (notification is ScrollUpdateNotification &&
            !_isScrolling &&
            (notification.scrollDelta?.abs() ?? 0) > 1.5)) {
      _scrollDebounceTimer?.cancel();
      if (!_isScrolling) {
        _isScrolling = true;
        WavesBackground.suspend();
        DarkLuxuryBackground.suspend();
      }
    } else if (notification is ScrollEndNotification) {
      _scrollDebounceTimer?.cancel();
      _scrollDebounceTimer = Timer(const Duration(milliseconds: 140), () {
        if (!mounted) return;
        if (_isScrolling) {
          _isScrolling = false;
          WavesBackground.resume();
          DarkLuxuryBackground.resume();
        }
      });
    }
    return false;
  }

  @override
  void dispose() {
    _scrollDebounceTimer?.cancel();
    if (_isScrolling) {
      _isScrolling = false;
      WavesBackground.resume();
      DarkLuxuryBackground.resume();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Bọc RepaintBoundary để cô lập hoàn toàn chu kỳ vẽ lại của lớp nền
        // động khỏi cây widget ứng dụng phía trên (Navigator / Shell / Tabs).
        const RepaintBoundary(child: _ThemedBackdropLayer()),
        _WavesBackgroundScope(
          route: ModalRoute.of(context),
          child: NotificationListener<ScrollNotification>(
            onNotification: _onScrollNotification,
            child: widget.child ?? const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}

/// Lớp nền duy nhất, tự chọn shader theo theme hiện tại.
class _ThemedBackdropLayer extends StatelessWidget {
  const _ThemedBackdropLayer();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeService.instance,
      builder: (context, _) {
        if (ThemeService.instance.isWindowsBlue) {
          return const WavesBackground();
        }
        if (ThemeService.instance.isLuxuryGold) {
          return const DarkLuxuryBackground();
        }
        // Theme Đỏ Netflix: nền đen điện ảnh chuẩn rạp, không tốn GPU shader
        return const ColoredBox(color: Color(0xFF141414));
      },
    );
  }
}

class _WavesBackgroundState extends State<WavesBackground>
    with SingleTickerProviderStateMixin {
  static const double _timeScale = -0.727;

  /// Shader sóng chỉ cần ~30 fps: đây là một dải gradient chuyển động rất
  /// chậm nên mắt không phân biệt được với 60 fps, nhưng mỗi lần shader vẽ lại
  /// là một lượt full-screen fragment shader — đồng thời làm "nền" của bottom
  /// bar kính thay đổi, buộc mọi lớp BackdropFilter phía trên phải lấy lại
  /// backdrop. Giảm một nửa tần số này là giảm một nửa chi phí nền của toàn app.
  static const Duration _frameStep = Duration(milliseconds: 33);

  static Future<ui.FragmentProgram>? _programFuture;
  static Future<ui.FragmentProgram> _loadProgram() {
    return _programFuture ??= ui.FragmentProgram.fromAsset(
      'shaders/waves.frag',
    );
  }

  ui.FragmentShader? _shader;
  late final Ticker _ticker;
  final ValueNotifier<double> _time = ValueNotifier<double>(0);
  Duration _lastTick = Duration.zero;
  double _accumulatedSeconds = 0.0;

  bool get _isInTestBinding =>
      WidgetsBinding.instance.runtimeType.toString().contains('Test');

  @override
  void initState() {
    super.initState();
    try {
      _loadProgram().then((program) {
        if (!mounted) return;
        setState(() => _shader = program.fragmentShader());
      }, onError: (_) {});
    } catch (_) {}

    _ticker = createTicker((elapsed) {
      if (_lastTick == Duration.zero) {
        _lastTick = elapsed;
        return;
      }
      final delta = elapsed - _lastTick;
      if (delta < _frameStep) return;
      _lastTick = elapsed;
      _accumulatedSeconds += delta.inMicroseconds / 1e6;
      _time.value = _accumulatedSeconds * _timeScale;
    });
    if (!_isInTestBinding && !WavesBackground.isVideoPlaying) {
      _ticker.start();
    }
    WavesBackground._suspensions.addListener(_handleVideoPlaybackChange);
  }

  void _handleVideoPlaybackChange() {
    if (_isInTestBinding) return;
    if (WavesBackground.isActiveIn(context)) {
      if (_ticker.isActive) _ticker.stop();
      return;
    }
    if (WavesBackground.isVideoPlaying) {
      if (_ticker.isActive) _ticker.stop();
    } else {
      final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
      if (!reduce && !_ticker.isActive) {
        _lastTick = Duration.zero;
        _ticker.start();
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInTestBinding) return;
    if (WavesBackground.isActiveIn(context)) {
      if (_ticker.isActive) _ticker.stop();
      return;
    }
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (reduce || WavesBackground.isVideoPlaying) {
      if (_ticker.isActive) _ticker.stop();
    } else if (!_ticker.isActive) {
      _lastTick = Duration.zero;
      _ticker.start();
    }
  }

  @override
  void dispose() {
    WavesBackground._suspensions.removeListener(_handleVideoPlaybackChange);
    _ticker.dispose();
    _time.dispose();
    _shader?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Nếu trong cùng route/shell đã có WavesBackground đang hiển thị thì không vẽ đè lần 2
    if (WavesBackground.isActiveIn(context)) {
      return widget.child ?? const SizedBox.shrink();
    }

    final shader = _shader;
    final currentRoute = ModalRoute.of(context);
    return _WavesBackgroundScope(
      route: currentRoute,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (shader == null)
            const ColoredBox(color: Color(0xFF031C26)) // màu nền khi đang tải
          else
            IgnorePointer(
              child: RepaintBoundary(
                child: SizedBox.expand(
                  child: CustomPaint(painter: _WavesPainter(shader, _time)),
                ),
              ),
            ),
          // Lớp phủ cân bằng độ tương phản (Contrast Scrim) ở vùng đỉnh sóng sáng
          // giúp chữ trắng, icon và thẻ kính luôn đạt chuẩn tương phản WCAG AA trên nền sóng xanh.
          const IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x8C031B28),
                    Color(0x66031B28),
                    Color(0x45031C26),
                    Color(0x33031C26),
                  ],
                  stops: [0.0, 0.38, 0.72, 1.0],
                ),
              ),
              child: SizedBox.expand(),
            ),
          ),
          if (widget.child != null) widget.child!,
        ],
      ),
    );
  }
}

class _WavesBackgroundScope extends InheritedWidget {
  const _WavesBackgroundScope({required this.route, required super.child});

  final ModalRoute<dynamic>? route;

  @override
  bool updateShouldNotify(_WavesBackgroundScope oldWidget) =>
      !identical(oldWidget.route, route);
}

class _WavesPainter extends CustomPainter {
  _WavesPainter(this.shader, this.time) : super(repaint: time);

  final ui.FragmentShader shader;
  final ValueListenable<double> time;
  static final Paint _paint = Paint();

  @override
  void paint(Canvas canvas, Size size) {
    shader
      ..setFloat(0, size.width)
      ..setFloat(1, size.height)
      ..setFloat(2, time.value);
    _paint.shader = shader;
    canvas.drawRect(Offset.zero & size, _paint);
  }

  @override
  bool shouldRepaint(_WavesPainter old) => old.shader != shader;
}
