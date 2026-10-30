import 'dart:async';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import '../../../services/theme_service.dart';
import '../../../waves_background.dart';
import '../glass/glass_components.dart';

/// Chế độ tỉ lệ khung hình của Video Player
enum VideoFitMode {
  fit, // 16:9 Vừa khung hình (Contain - không mất chi tiết, có vệt đen 2 bên trên màn dài)
  fill, // Phóng to tràn viền (Cover - loại bỏ hoàn toàn 2 vệt đen như YouTube)
  stretch, // Kéo giãn (Fill toàn bộ khung hình)
}

/// Widget phát toàn màn hình xoay ngang (Landscape Fullscreen) cao cấp của OpenFlix.
/// Tích hợp đầy đủ hành vi cử chỉ của YouTube thế hệ mới:
/// 1. Cử chỉ 2 ngón tay kéo dãn (Pinch-out): Chuyển mượt mà từ 16:9 sang Tràn viền (Fill screen).
/// 2. Cử chỉ 2 ngón tay bóp lại (Pinch-in): Co hình về Vừa màn hình 16:9 gốc.
/// 3. Phóng to tự do liên tục (Continuous Zoom 1.0x -> 3.5x + Pan) để soi chi tiết phim.
/// 4. Đàn hồi tự động (Spring bounce-back) khi thu nhỏ dưới 1.0x.
/// 5. Chạm đúp 2 bên: Tua -10s (trái) / Tua +10s (phải); Chạm đúp ở giữa: Đặt lại tỷ lệ / Zoom.
/// 6. Bộ điều khiển kính mờ Netflix cố định độc lập không bị phóng to theo video.
class OpenFlixFullscreenPlayer extends StatefulWidget {
  final ChewieController controller;
  final String movieTitle;
  final VideoFitMode initialFitMode;
  final ValueChanged<VideoFitMode>? onFitModeChanged;
  final double playbackSpeed;
  final ValueChanged<double>? onSpeedChanged;
  final bool isMuted;
  final ValueChanged<bool>? onMuteToggled;

  const OpenFlixFullscreenPlayer({
    super.key,
    required this.controller,
    this.movieTitle = '',
    this.initialFitMode = VideoFitMode.fit,
    this.onFitModeChanged,
    this.playbackSpeed = 1.0,
    this.onSpeedChanged,
    this.isMuted = false,
    this.onMuteToggled,
  });

  @override
  State<OpenFlixFullscreenPlayer> createState() =>
      _OpenFlixFullscreenPlayerState();
}

class _OpenFlixFullscreenPlayerState extends State<OpenFlixFullscreenPlayer> {
  late VideoPlayerController _videoController;
  late VideoFitMode _fitMode;
  late double _currentSpeed;
  late bool _isMuted;

  // Ma trận thu phóng & Di chuyển (Zoom & Pan 1.0x -> 3.5x)
  final TransformationController _transformationController =
      TransformationController();
  double _currentScale = 1.0;

  // Thanh điều khiển (Controls Overlay) & Hẹn giờ tự ẩn
  bool _showControls = true;
  bool _controlsFullyHidden = false;
  Timer? _controlsHideTimer;

  // Thông báo nổi HUD (Thông báo Zoom / Tua / Tốc độ / Âm lượng)
  String? _hudMessage;
  IconData? _hudIcon;
  Timer? _hudTimer;

  // Tua mượt mà (Debounce & Seek-on-release không rebuild toàn bộ màn hình)
  final ValueNotifier<bool> _isScrubbingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<double> _scrubSecondsNotifier =
      ValueNotifier<double>(0.0);
  Timer? _seekDebounceTimer;
  int _accumulatedSeekSeconds = 0;
  Duration? _baseSeekPosition;
  bool _lastIsPlaying = false;

  // Hiệu ứng sóng lan tỏa khi chạm đúp tua
  bool _showLeftSeekRipple = false;
  bool _showRightSeekRipple = false;
  Timer? _rippleTimer;

  static const List<double> _playbackSpeeds = [1.0, 1.25, 1.5, 2.0];

  @override
  void initState() {
    super.initState();
    _videoController = widget.controller.videoPlayerController;
    _fitMode = widget.initialFitMode;
    _currentSpeed = widget.playbackSpeed;
    _isMuted = widget.isMuted;
    _lastIsPlaying = _videoController.value.isPlaying;
    if (_lastIsPlaying) {
      WavesBackground.notifyVideoPlaybackStarted();
    }
    _videoController.addListener(_onVideoControllerTick);

    _startControlsHideTimer();
  }

  void _onVideoControllerTick() {
    if (!mounted) return;
    final isPlaying = _videoController.value.isPlaying;
    if (isPlaying != _lastIsPlaying) {
      _lastIsPlaying = isPlaying;
      if (isPlaying) {
        WavesBackground.notifyVideoPlaybackStarted();
      } else {
        WavesBackground.notifyVideoPlaybackStopped();
      }
    }
  }

  @override
  void dispose() {
    if (_lastIsPlaying) {
      WavesBackground.notifyVideoPlaybackStopped();
    }
    _videoController.removeListener(_onVideoControllerTick);
    _controlsHideTimer?.cancel();
    _hudTimer?.cancel();
    _seekDebounceTimer?.cancel();
    _rippleTimer?.cancel();
    _transformationController.dispose();
    _isScrubbingNotifier.dispose();
    _scrubSecondsNotifier.dispose();
    super.dispose();
  }

  void _startControlsHideTimer() {
    _controlsHideTimer?.cancel();
    _controlsHideTimer = Timer(const Duration(milliseconds: 3500), () {
      if (mounted &&
          _videoController.value.isPlaying &&
          !_isScrubbingNotifier.value) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
      if (_showControls) {
        _controlsFullyHidden = false;
      }
    });
    if (_showControls) {
      _startControlsHideTimer();
    } else {
      _controlsHideTimer?.cancel();
    }
  }

  void _showHud(String message, [IconData? icon]) {
    _hudTimer?.cancel();
    setState(() {
      _hudMessage = message;
      _hudIcon = icon;
    });
    _hudTimer = Timer(const Duration(milliseconds: 1700), () {
      if (mounted) {
        setState(() {
          _hudMessage = null;
          _hudIcon = null;
        });
      }
    });
  }

  void _setFitMode(VideoFitMode mode, {bool showHudMessage = true}) {
    setState(() {
      _fitMode = mode;
      _transformationController.value = Matrix4.identity();
      _currentScale = 1.0;
    });
    widget.onFitModeChanged?.call(mode);

    if (showHudMessage) {
      switch (mode) {
        case VideoFitMode.fill:
          _showHud('Phóng to để vừa màn hình', Icons.fullscreen_rounded);
          break;
        case VideoFitMode.fit:
          _showHud('Vừa màn hình (Gốc)', Icons.fullscreen_exit_rounded);
          break;
        case VideoFitMode.stretch:
          _showHud('Kéo giãn toàn màn hình', Icons.fit_screen_rounded);
          break;
      }
    }
  }

  void _cycleFitMode() {
    switch (_fitMode) {
      case VideoFitMode.fit:
        _setFitMode(VideoFitMode.fill);
        break;
      case VideoFitMode.fill:
        _setFitMode(VideoFitMode.stretch);
        break;
      case VideoFitMode.stretch:
        _setFitMode(VideoFitMode.fit);
        break;
    }
  }

  void _resetZoom() {
    setState(() {
      _transformationController.value = Matrix4.identity();
      _currentScale = 1.0;
    });
    _showHud('Đã đặt lại: 1.0x', Icons.zoom_out_rounded);
  }

  void _cyclePlaybackSpeed() {
    final currentIndex = _playbackSpeeds.indexOf(_currentSpeed);
    final nextIndex = (currentIndex + 1) % _playbackSpeeds.length;
    final nextSpeed = _playbackSpeeds[nextIndex];
    setState(() {
      _currentSpeed = nextSpeed;
    });
    _videoController.setPlaybackSpeed(nextSpeed);
    widget.onSpeedChanged?.call(nextSpeed);
    _showHud('Tốc độ: ${nextSpeed}x', Icons.speed_rounded);
    _startControlsHideTimer();
  }

  void _toggleMute() {
    final newMuted = !_isMuted;
    setState(() {
      _isMuted = newMuted;
    });
    _videoController.setVolume(newMuted ? 0.0 : 1.0);
    widget.onMuteToggled?.call(newMuted);
    _showHud(
      newMuted ? 'Đã tắt tiếng' : 'Đã bật âm thanh',
      newMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
    );
    _startControlsHideTimer();
  }

  void _togglePlayPause() {
    if (!_videoController.value.isInitialized) return;
    if (_videoController.value.isPlaying) {
      _videoController.pause();
      setState(() {
        _showControls = true;
        _controlsFullyHidden = false;
      });
      _controlsHideTimer?.cancel();
    } else {
      _videoController.play();
      _startControlsHideTimer();
    }
    setState(() {});
  }

  void _quickSeek(int seconds) {
    if (_seekDebounceTimer == null || !_seekDebounceTimer!.isActive) {
      _baseSeekPosition = _videoController.value.isInitialized
          ? _videoController.value.position
          : Duration.zero;
    }
    _accumulatedSeekSeconds += seconds;
    _showHud(
      'Tua ${_accumulatedSeekSeconds > 0 ? "+$_accumulatedSeekSeconds" : "$_accumulatedSeekSeconds"}s',
      _accumulatedSeekSeconds > 0
          ? Icons.fast_forward_rounded
          : Icons.fast_rewind_rounded,
    );
    final totalDuration = _videoController.value.isInitialized
        ? _videoController.value.duration
        : const Duration(minutes: 90);

    final isForward = _accumulatedSeekSeconds >= 0;

    _rippleTimer?.cancel();
    setState(() {
      _showLeftSeekRipple = !isForward;
      _showRightSeekRipple = isForward;
    });
    _rippleTimer = Timer(const Duration(milliseconds: 650), () {
      if (mounted) {
        setState(() {
          _showLeftSeekRipple = false;
          _showRightSeekRipple = false;
        });
      }
    });

    _seekDebounceTimer?.cancel();
    _seekDebounceTimer = Timer(const Duration(milliseconds: 260), () async {
      if (_videoController.value.isInitialized) {
        final base = _baseSeekPosition ?? _videoController.value.position;
        final target = base + Duration(seconds: _accumulatedSeekSeconds);
        final clamped = target < Duration.zero
            ? Duration.zero
            : (target > totalDuration ? totalDuration : target);
        await _videoController.seekTo(clamped);
      }
      _accumulatedSeekSeconds = 0;
      _baseSeekPosition = null;
      if (mounted) setState(() {});
    });

    _startControlsHideTimer();
  }

  void _handleDoubleTapDown(TapDownDetails details) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final tapX = details.globalPosition.dx;

    if (tapX < screenWidth * 0.35) {
      // Mép trái 35%: Tua lùi 10s
      _quickSeek(-10);
    } else if (tapX > screenWidth * 0.65) {
      // Mép phải 35%: Tua tới 10s
      _quickSeek(10);
    } else {
      // Khu vực trung tâm: Đặt lại Zoom hoặc chuyển đổi nhanh Fit/Fill
      if (_currentScale > 1.05) {
        _resetZoom();
      } else {
        _cycleFitMode();
      }
    }
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final videoSize = _videoController.value.size;
    final videoWidth = videoSize.width > 0 ? videoSize.width : 1920.0;
    final videoHeight = videoSize.height > 0 ? videoSize.height : 1080.0;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          widget.controller.exitFullScreen();
        }
      },
      child: Scaffold(
        backgroundColor: ThemeService.instance.backgroundColor,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // 1. LỚP VIDEO + CỬ CHỈ THU PHÓNG YOUTUBE (Pinch-to-Fill & 1.0x - 3.5x Zoom)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _toggleControls,
                onDoubleTapDown: _handleDoubleTapDown,
                child: ClipRect(
                  child: InteractiveViewer(
                    transformationController: _transformationController,
                    minScale: 1.0,
                    maxScale: 3.5,
                    panAxis: PanAxis.free,
                    onInteractionStart: (details) {
                      _startControlsHideTimer();
                    },
                    onInteractionUpdate: (details) {
                      _currentScale = _transformationController.value
                          .getMaxScaleOnAxis();

                      // Cử chỉ 2 ngón tay kéo dãn (Pinch-to-Fill) kiểu YouTube:
                      if (details.pointerCount >= 2) {
                        // Kéo dãn 2 ngón ra ngoài khi đang ở chế độ 16:9 gốc
                        if (_fitMode == VideoFitMode.fit &&
                            details.scale > 1.12) {
                          HapticFeedback.selectionClick();
                          _setFitMode(VideoFitMode.fill);
                        }
                        // Bóp 2 ngón vào trong khi đang ở chế độ Tràn viền
                        else if (_fitMode == VideoFitMode.fill &&
                            details.scale < 0.88) {
                          HapticFeedback.selectionClick();
                          _setFitMode(VideoFitMode.fit);
                        }
                      }
                    },
                    onInteractionEnd: (details) {
                      _currentScale = _transformationController.value
                          .getMaxScaleOnAxis();
                      if (_currentScale > 1.05) {
                        _showHud(
                          'Thu phóng: ${_currentScale.toStringAsFixed(1)}x',
                          Icons.zoom_in_rounded,
                        );
                      }
                    },
                    child: Center(
                      child: FittedBox(
                        fit: _fitMode == VideoFitMode.fill
                            ? BoxFit.cover
                            : (_fitMode == VideoFitMode.stretch
                                  ? BoxFit.fill
                                  : BoxFit.contain),
                        child: SizedBox(
                          width: videoWidth,
                          height: videoHeight,
                          child: RepaintBoundary(
                            child: VideoPlayer(_videoController),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 2. HIỆU ỨNG SÓNG LAN TỎA (SEEK RIPPLE) KHI CHẠM ĐÚP TUA
            if (_showLeftSeekRipple)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: MediaQuery.sizeOf(context).width * 0.35,
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.22),
                          Colors.transparent,
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.replay_10_rounded,
                            color: Colors.white,
                            size: 44,
                          ),
                          SizedBox(height: 6),
                          Text(
                            '-10 giây',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            if (_showRightSeekRipple)
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                width: MediaQuery.sizeOf(context).width * 0.35,
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.white.withValues(alpha: 0.22),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.forward_10_rounded,
                            color: Colors.white,
                            size: 44,
                          ),
                          SizedBox(height: 6),
                          Text(
                            '+10 giây',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // 3. THÔNG BÁO NỔI HUD KÍNH MỜ QUANG HỌC PHÍA TRÊN (TOP-CENTER HUD PILL)
            if (_hudMessage != null)
              Positioned(
                top: 56,
                left: 0,
                right: 0,
                child: Center(
                  child: IgnorePointer(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                          width: 1,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black87,
                            blurRadius: 16,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_hudIcon != null) ...[
                            Icon(
                              _hudIcon,
                              color: ThemeService.instance.primaryColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            _hudMessage!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // 4. LỚP ĐIỀU KHIỂN CỐ ĐỊNH (CONTROLS OVERLAY - KHÔNG BỊ ZOOM THEO VIDEO)
            AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 250),
              onEnd: () {
                if (!_showControls && mounted) {
                  setState(() {
                    _controlsFullyHidden = true;
                  });
                }
              },
              child: (_controlsFullyHidden && !_showControls)
                  ? const SizedBox.shrink()
                  : IgnorePointer(
                      ignoring: !_showControls,
                      child: RepaintBoundary(
                        child: _buildControlsOverlay(context),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlsOverlay(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.75),
            Colors.transparent,
            Colors.transparent,
            Colors.black.withValues(alpha: 0.85),
          ],
          stops: const [0.0, 0.22, 0.70, 1.0],
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // TOP BAR: Nút Back, Tiêu đề phim, Nút Tỷ lệ, Nút Zoom Reset, Nút Tốc độ
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  // Nút Trở về / Thoát Fullscreen kính mờ tròn chuẩn OpenFlix
                  GlassBackButton(
                    onPressed: () {
                      widget.controller.exitFullScreen();
                    },
                  ),
                  const SizedBox(width: 10),

                  // Tên phim
                  Expanded(
                    child: Text(
                      widget.movieTitle.isNotEmpty
                          ? widget.movieTitle
                          : 'Đang phát phim',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),

                  // Chip chỉ số Zoom & Đặt lại 1.0x (nếu đang zoom > 1.05x)
                  if (_currentScale > 1.05) ...[
                    InkWell(
                      onTap: _resetZoom,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: ThemeService.instance.primaryColor.withValues(
                            alpha: 0.85,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.zoom_out_rounded,
                              color: Colors.white,
                              size: 15,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${_currentScale.toStringAsFixed(1)}x (Đặt lại)',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  // Chip chuyển đổi tỉ lệ khung hình (16:9 / Tràn viền / Kéo giãn)
                  InkWell(
                    onTap: _cycleFitMode,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white30, width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          OpenFlixMorphIcon.smooth(
                            icon: _fitMode == VideoFitMode.fill
                                ? Icons.fullscreen_rounded
                                : (_fitMode == VideoFitMode.stretch
                                      ? Icons.fit_screen_rounded
                                      : Icons.fullscreen_exit_rounded),
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _fitMode == VideoFitMode.fill
                                ? 'Tràn viền'
                                : (_fitMode == VideoFitMode.stretch
                                      ? 'Kéo giãn'
                                      : '16:9'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Chip Tốc độ phát video
                  InkWell(
                    onTap: _cyclePlaybackSpeed,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white30, width: 1),
                      ),
                      child: Text(
                        '${_currentSpeed}x',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // CENTER AREA: Nút Phát / Tạm dừng kính mờ quang học tinh gọn chuẩn Netflix
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _toggleControls,
                onDoubleTapDown: _handleDoubleTapDown,
                child: Center(
                  child: ValueListenableBuilder<VideoPlayerValue>(
                    valueListenable: _videoController,
                    builder: (context, value, _) => GlassPlayerPlayButton(
                      isPlaying: value.isPlaying,
                      isLoading: value.isBuffering,
                      size: 68,
                      onPressed: _togglePlayPause,
                    ),
                  ),
                ),
              ),
            ),

            // BOTTOM BAR: Thanh tua Slider, Bộ đếm thời gian, Nút Mute, Nút Thoát Fullscreen
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Slider tua tiến trình mượt mà
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 4.0,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 7,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 14,
                      ),
                      activeTrackColor: ThemeService.instance.primaryColor,
                      inactiveTrackColor: Colors.white24,
                      thumbColor: ThemeService.instance.primaryColor,
                      overlayColor: ThemeService.instance.primaryColor
                          .withValues(alpha: 0.25),
                    ),
                    child: ListenableBuilder(
                      listenable: Listenable.merge([
                        _videoController,
                        _isScrubbingNotifier,
                        _scrubSecondsNotifier,
                      ]),
                      builder: (context, _) {
                        final totalDuration =
                            _videoController.value.isInitialized
                                ? _videoController.value.duration
                                : Duration.zero;
                        final currentPosition =
                            _videoController.value.isInitialized
                                ? _videoController.value.position
                                : Duration.zero;
                        final maxSec = (totalDuration.inSeconds > 0
                                ? totalDuration.inSeconds
                                : 1)
                            .toDouble();
                        final isScrubbing = _isScrubbingNotifier.value;
                        final currentSec = isScrubbing
                            ? _scrubSecondsNotifier.value.clamp(0.0, maxSec)
                            : currentPosition.inSeconds.toDouble().clamp(
                                0.0,
                                maxSec,
                              );
                        return Slider(
                          min: 0.0,
                          max: maxSec,
                          value: currentSec,
                          onChangeStart: (val) {
                            _isScrubbingNotifier.value = true;
                            _scrubSecondsNotifier.value = val;
                            _controlsHideTimer?.cancel();
                          },
                          onChanged: (val) {
                            _scrubSecondsNotifier.value = val;
                          },
                          onChangeEnd: (val) async {
                            final target = Duration(seconds: val.toInt());
                            await _videoController.seekTo(target);
                            if (mounted) {
                              _isScrubbingNotifier.value = false;
                              _startControlsHideTimer();
                            }
                          },
                        );
                      },
                    ),
                  ),

                  // Hàng hiển thị Thời lượng, Nút Mute, Nút Thoát Fullscreen
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        ListenableBuilder(
                          listenable: Listenable.merge([
                            _videoController,
                            _isScrubbingNotifier,
                            _scrubSecondsNotifier,
                          ]),
                          builder: (context, _) {
                            final totalDuration =
                                _videoController.value.isInitialized
                                    ? _videoController.value.duration
                                    : Duration.zero;
                            final isScrubbing = _isScrubbingNotifier.value;
                            final currentPosition = isScrubbing
                                ? Duration(
                                    seconds:
                                        _scrubSecondsNotifier.value.toInt(),
                                  )
                                : (_videoController.value.isInitialized
                                    ? _videoController.value.position
                                    : Duration.zero);
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _formatDuration(currentPosition),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  ' / ${_formatDuration(totalDuration)}',
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        const Spacer(),

                        // Nút Bật / Tắt âm thanh
                        IconButton(
                          icon: OpenFlixMorphIcon.smooth(
                            icon: _isMuted
                                ? Icons.volume_off_rounded
                                : Icons.volume_up_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                          tooltip: _isMuted ? 'Bật âm thanh' : 'Tắt tiếng',
                          onPressed: _toggleMute,
                        ),

                        // Nút Thoát Fullscreen
                        IconButton(
                          icon: const Icon(
                            Icons.fullscreen_exit_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                          tooltip: 'Thu nhỏ màn hình',
                          onPressed: () {
                            widget.controller.exitFullScreen();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
