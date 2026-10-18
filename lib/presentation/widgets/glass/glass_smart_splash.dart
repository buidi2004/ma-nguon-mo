import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_splash_kit/smart_splash_kit.dart';

import '../../../services/theme_service.dart';
import '../../../theme/app_theme.dart';
import '../brand/v_movie_brand_asset.dart';
import 'glass_button.dart';
import 'silk_background.dart';

/// Thành phần Smart Splash Screen chuẩn điện ảnh OpenFlix kết hợp Smart Splash Kit.
///
/// Hỗ trợ đầy đủ:
/// - Smart Routing qua [onInit] callback trả về [SplashRoute] (home, login, onboarding, custom).
/// - 9 kiểu hiệu ứng hoạt cảnh mượt mà (fadeScale, fadeIn, scaleUp, slideUp,...).
/// - API Loader tải trước dữ liệu phim với timeout, retry và fallback an toàn.
/// - Giao diện Dark Cinema (#141414) và lớp hào quang kính đỏ (#E50914).
/// - Tự động dọn dẹp Timer khi dispose, đảm bảo an toàn tuyệt đối trong unit test.
/// - Tương thích liền mạch với GoRouter và Navigator tiêu chuẩn.
class GlassSmartSplash extends StatefulWidget {
  /// Cấu hình giao diện và hoạt ảnh Splash.
  final SplashConfig? config;

  /// Async callback khởi tạo ứng dụng và trả về đích đến điều hướng.
  final Future<SplashRoute> Function()? onInit;

  /// Theme ghi đè giao diện Splash (mặc định Dark Cinema).
  final SplashTheme? theme;

  /// Route fallback khi khởi tạo gặp lỗi nghiêm trọng.
  final SplashRoute? errorFallbackRoute;

  /// Custom UI builder cho trạng thái lỗi kết nối.
  final Widget Function(VoidCallback retry, SplashTheme theme)? errorBuilder;

  /// Callback điều hướng tùy biến (ưu tiên trước khi gọi context.go).
  final void Function(SplashRoute route)? onNavigate;

  const GlassSmartSplash({
    super.key,
    this.config,
    this.onInit,
    this.theme,
    this.errorFallbackRoute,
    this.errorBuilder,
    this.onNavigate,
  });

  @override
  State<GlassSmartSplash> createState() => _GlassSmartSplashState();
}

class _GlassSmartSplashState extends State<GlassSmartSplash>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;
  late Animation<Offset> _slideAnim;
  late Animation<double> _rotateAnim;

  Timer? _minDisplayTimer;
  Timer? _maxTimer;
  Timer? _animDelayTimer;

  bool _isInitializing = true;
  bool _hasError = false;
  Object? _errorObject;
  SplashRoute? _resolvedRoute;
  bool _navigationTriggered = false;
  bool _tapContinueReady = false;
  int? _loadTimeMs;

  late SplashConfig _effectiveConfig;
  late SplashTheme _effectiveTheme;

  @override
  void initState() {
    super.initState();
    ThemeService.instance.addListener(_onThemeChanged);
    _effectiveConfig = widget.config ?? _buildDefaultConfig();
    final brandColor = ThemeService.instance.primaryColor;
    _effectiveTheme = widget.theme ??
        SplashTheme.custom(
          backgroundColor: ThemeService.instance.backgroundColor,
          loaderColor: brandColor,
          textColor: ThemeService.instance.textPrimary,
        );

    final anim = _effectiveConfig.animation;
    final animDuration = Duration(
      milliseconds: anim.durationMs > 0 ? anim.durationMs : 700,
    );

    _animController = AnimationController(
      vsync: this,
      duration: animDuration,
    );

    _setupAnimations(anim);

    if (anim.delayMs > 0) {
      _animDelayTimer = Timer(Duration(milliseconds: anim.delayMs), () {
        if (mounted) _animController.forward();
      });
    } else {
      _animController.forward();
    }

    _runStartupFlow();
  }

  SplashConfig _buildDefaultConfig() {
    return SplashConfig(
      durationMs: 5000,
      animation: SplashAnimation.fadeScale(
        durationMs: 900,
        curve: Curves.easeOutCubic,
      ),
      layoutType: SplashLayoutType.logoWithText,
      backgroundColor: ThemeService.instance.backgroundColor,
      appName: 'OPENFLIX',
      appNameStyle: TextStyle(
        color: ThemeService.instance.primaryColor,
        fontWeight: FontWeight.w900,
        fontSize: 34,
        letterSpacing: 4.0,
      ),
      tagline: 'Điện ảnh không giới hạn',
      taglineStyle: TextStyle(
        color: ThemeService.instance.isWindowsBlue
            ? const Color(0xFF475569)
            : Colors.white.withAlpha(200),
        fontSize: 13,
        letterSpacing: 1.5,
        fontWeight: FontWeight.w500,
      ),
      showLoader: true,
      logo: SizedBox(
        width: 104,
        height: 104,
        child: Image.memory(
          kVMovie3dIconBytes,
          width: 104,
          height: 104,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
          errorBuilder: (_, _, _) => Image.asset(
            'web/icons/Biểu tượng V xem phim 3D điện ảnh.png',
            width: 104,
            height: 104,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => Image.asset(
              'assets/icons/app_icon.png',
              width: 104,
              height: 104,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => const SizedBox(width: 104, height: 104),
            ),
          ),
        ),
      ),
    );
  }

  void _setupAnimations(SplashAnimation anim) {
    final curved = CurvedAnimation(
      parent: _animController,
      curve: anim.curve,
    );

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(curved);
    _scaleAnim = Tween<double>(begin: 0.78, end: 1.0).animate(curved);
    _rotateAnim = Tween<double>(begin: 0.0, end: 1.0).animate(curved);

    Offset slideBegin;
    switch (anim.type) {
      case SplashAnimationType.slideUp:
        slideBegin = const Offset(0.0, 0.35);
        break;
      case SplashAnimationType.slideDown:
        slideBegin = const Offset(0.0, -0.35);
        break;
      case SplashAnimationType.slideLeft:
        slideBegin = const Offset(0.35, 0.0);
        break;
      case SplashAnimationType.slideRight:
        slideBegin = const Offset(-0.35, 0.0);
        break;
      default:
        slideBegin = Offset.zero;
    }
    _slideAnim = Tween<Offset>(begin: slideBegin, end: Offset.zero).animate(curved);
  }

  Future<void> _runStartupFlow() async {
    _minDisplayTimer?.cancel();
    _maxTimer?.cancel();

    final stopwatch = _effectiveConfig.enablePerformanceMonitoring ? (Stopwatch()..start()) : null;
    final minMs = _effectiveConfig.durationMs;

    // Timer trần tối đa dự phòng (luôn lớn hơn thời gian loang tối thiểu)
    final maxTimeoutMs = math.max(6500, minMs + 2500);
    _maxTimer = Timer(Duration(milliseconds: maxTimeoutMs), () {
      if (mounted && _isInitializing) {
        _finishAndNavigate(widget.errorFallbackRoute ?? SplashRoute.home());
      }
    });

    final minDisplayCompleter = Completer<void>();
    if (minMs > 0) {
      _minDisplayTimer = Timer(Duration(milliseconds: minMs), () {
        if (!minDisplayCompleter.isCompleted) {
          minDisplayCompleter.complete();
        }
      });
    } else {
      minDisplayCompleter.complete();
    }

    try {
      final onInitFuture = (widget.onInit != null)
          ? widget.onInit!()
          : Future.value(SplashRoute.home());

      final results = await Future.wait([onInitFuture, minDisplayCompleter.future]);
      stopwatch?.stop();
      _loadTimeMs = stopwatch?.elapsedMilliseconds;

      if (_effectiveConfig.enablePerformanceMonitoring && kDebugMode) {
        debugPrint('[SmartSplashKit] OpenFlix initialized in ${_loadTimeMs}ms');
      }

      final route = results[0] as SplashRoute;
      _finishAndNavigate(route);
    } catch (e) {
      stopwatch?.stop();
      _minDisplayTimer?.cancel();
      _maxTimer?.cancel();
      _errorObject = e;
      if (kDebugMode) {
        debugPrint('[SmartSplashKit] Khởi tạo gặp lỗi: $e');
      }

      if (widget.errorFallbackRoute != null) {
        _finishAndNavigate(widget.errorFallbackRoute!);
      } else {
        if (mounted) {
          setState(() {
            _isInitializing = false;
            _hasError = true;
          });
        }
      }
    }
  }

  void _finishAndNavigate(SplashRoute route) {
    if (!mounted) return;
    _minDisplayTimer?.cancel();
    _maxTimer?.cancel();
    _isInitializing = false;
    _resolvedRoute = route;

    if (_effectiveConfig.tapToContinue) {
      setState(() => _tapContinueReady = true);
    } else {
      _triggerNavigation();
    }
  }


  void _triggerNavigation() {
    if (!mounted || _navigationTriggered) return;
    _navigationTriggered = true;

    _minDisplayTimer?.cancel();
    _maxTimer?.cancel();
    _animDelayTimer?.cancel();

    final targetRoute = _resolvedRoute ?? SplashRoute.home();

    // Thông báo cho Native bridge tắt splash native nếu có
    SmartSplashKitPlatform.instance.removeSplash().catchError((_) {});

    if (widget.onNavigate != null) {
      widget.onNavigate!(targetRoute);
      return;
    }

    // Điều hướng tương thích song song cả GoRouter và Navigator chuẩn
    final targetPath = (targetRoute.route == '/home') ? '/' : targetRoute.route;
    try {
      context.go(targetPath);
    } catch (_) {
      try {
        Navigator.of(context).pushReplacementNamed(
          targetRoute.route,
          arguments: targetRoute.arguments,
        );
      } catch (_) {
        // Dự phòng an toàn cho Unit Test không có Navigator/Router
      }
    }
  }

  void _onThemeChanged() {
    if (!mounted) return;
    setState(() {
      final brandColor = ThemeService.instance.primaryColor;
      _effectiveTheme = widget.theme ??
          SplashTheme.custom(
            backgroundColor: ThemeService.instance.backgroundColor,
            loaderColor: brandColor,
            textColor: ThemeService.instance.textPrimary,
          );
    });
  }

  @override
  void dispose() {
    ThemeService.instance.removeListener(_onThemeChanged);
    _minDisplayTimer?.cancel();
    _maxTimer?.cancel();
    _animDelayTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      if (widget.errorBuilder != null) {
        return Scaffold(
          backgroundColor: _effectiveTheme.backgroundColor,
          body: widget.errorBuilder!(() {
            setState(() {
              _hasError = false;
              _isInitializing = true;
            });
            _runStartupFlow();
          }, _effectiveTheme),
        );
      }
      return _buildDefaultErrorUi();
    }

    final cfg = _effectiveConfig;
    Widget content = _buildLayoutContent(cfg);
    Widget animatedContent = _applyAnimation(content, cfg.animation.type);

    Widget bodyContent = GestureDetector(
      onTap: (_tapContinueReady && cfg.tapToContinue) ? _triggerNavigation : null,
      behavior: HitTestBehavior.opaque,
      child: SizedBox.expand(
        child: SafeArea(
          child: Stack(
            children: [
              Center(child: animatedContent),
              if (cfg.showSkipButton)
                Positioned(
                  top: 16,
                  right: 16,
                  child: TextButton(
                    onPressed: _triggerNavigation,
                    child: Text(
                      cfg.skipButtonLabel,
                      style: TextStyle(
                        color: _effectiveTheme.textColor.withAlpha(200),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              if (_tapContinueReady && cfg.tapToContinue)
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      'Chạm để tiếp tục',
                      style: TextStyle(
                        color: _effectiveTheme.textColor.withAlpha(190),
                        fontSize: 13,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ),
              if (cfg.enablePerformanceMonitoring && kDebugMode && _loadTimeMs != null)
                Positioned(
                  bottom: 16,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: SplashWidgets.performanceBadge(
                      loadTimeMs: _loadTimeMs!,
                      color: _effectiveTheme.loaderColor,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    if (cfg.backgroundGradient != null) {
      return Scaffold(
        backgroundColor: cfg.backgroundColor ?? _effectiveTheme.backgroundColor,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(gradient: cfg.backgroundGradient),
          child: bodyContent,
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SilkBackground(
        speed: 0.45,
        themeMode: ThemeService.instance.mode,
        child: bodyContent,
      ),
    );
  }

  Widget _buildLayoutContent(SplashConfig cfg) {
    if (cfg.layoutType == SplashLayoutType.custom && cfg.customContent != null) {
      return cfg.customContent!;
    }

    final brandColor = ThemeService.instance.primaryColor;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (cfg.logo != null) ...[
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: brandColor.withAlpha(50),
                  blurRadius: 32,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: cfg.logo!,
          ),
          const SizedBox(height: 18),
        ],
        if (cfg.appName != null)
          Text(
            cfg.appName!,
            style: cfg.appNameStyle ??
                TextStyle(
                  color: brandColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 34,
                  letterSpacing: 4.0,
                ),
            textAlign: TextAlign.center,
          ),
        if (cfg.tagline != null) ...[
          const SizedBox(height: 8),
          Text(
            cfg.tagline!,
            style: cfg.taglineStyle ??
                TextStyle(
                  color: _effectiveTheme.textColor.withAlpha(190),
                  fontSize: 13,
                  letterSpacing: 1.2,
                ),
            textAlign: TextAlign.center,
          ),
        ],
        if (cfg.showLoader) ...[
          const SizedBox(height: 28),
          cfg.customLoader ??
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(brandColor),
                  strokeWidth: 2.5,
                ),
              ),
        ],
      ],
    );
  }

  Widget _applyAnimation(Widget child, SplashAnimationType type) {
    switch (type) {
      case SplashAnimationType.none:
        return child;
      case SplashAnimationType.fadeIn:
        return FadeTransition(opacity: _fadeAnim, child: child);
      case SplashAnimationType.scaleUp:
      case SplashAnimationType.scaleDown:
        return ScaleTransition(scale: _scaleAnim, child: child);
      case SplashAnimationType.slideUp:
      case SplashAnimationType.slideDown:
      case SplashAnimationType.slideLeft:
      case SplashAnimationType.slideRight:
        return SlideTransition(position: _slideAnim, child: child);
      case SplashAnimationType.rotate:
        return RotationTransition(turns: _rotateAnim, child: child);
      case SplashAnimationType.fadeScale:
      default:
        return FadeTransition(
          opacity: _fadeAnim,
          child: ScaleTransition(scale: _scaleAnim, child: child),
        );
    }
  }

  Widget _buildDefaultErrorUi() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.wifi_off_rounded,
                size: 52,
                color: ThemeService.instance.primaryColor,
              ),
              const SizedBox(height: 16),
              const Text(
                'Không thể tải dữ liệu khởi động',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '${_errorObject ?? "Vui lòng kiểm tra kết nối mạng và thử lại."}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              GlassButton.primary(
                text: 'Thử lại',
                icon: Icons.refresh_rounded,
                onPressed: () {
                  setState(() {
                    _hasError = false;
                    _isInitializing = true;
                  });
                  _runStartupFlow();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
