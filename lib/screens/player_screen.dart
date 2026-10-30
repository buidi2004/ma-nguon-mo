import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

import '../models/movie_model.dart';
import '../presentation/widgets/glass/glass_components.dart';
import '../presentation/widgets/player/fullscreen_player_overlay.dart';
import '../services/library_service.dart';
import '../services/pocketbase_service.dart';
import '../services/theme_service.dart';
import '../theme/app_theme.dart';
import '../widgets/movie_card.dart';
import '../waves_background.dart';

export '../presentation/widgets/player/fullscreen_player_overlay.dart'
    show VideoFitMode;

class PlayerScreen extends StatefulWidget {
  final MovieModel? movie;
  final String? movieId;

  const PlayerScreen({super.key, this.movie, this.movieId})
    : assert(
        movie != null || movieId != null,
        'Either movie or movieId must be provided',
      );

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isLoading = true;
  String? _errorMessage;
  MovieModel? _activeMovie;
  List<MovieModel> _similarMovies = [];

  // Chế độ khung hình & Phóng to / Thu nhỏ (Zoom & Fit)
  VideoFitMode _fitMode = VideoFitMode.fit;
  final TransformationController _transformationController =
      TransformationController();
  double _currentScale = 1.0;

  // Trạng thái âm lượng & Tốc độ phát (Glass Media Toolbar)
  double _currentSpeed = 1.0;
  static const List<double> _playbackSpeeds = [1.0, 1.25, 1.5, 2.0];
  bool _isMuted = false;

  // Thông báo nổi HUD (khi Tua hoặc Phóng to/Thu nhỏ)
  String? _hudMessage;
  IconData? _hudIcon;
  Timer? _hudTimer;

  // Thanh tua mượt mà (Seek-on-Release & Debounce không rebuild toàn màn hình)
  final ValueNotifier<bool> _isScrubbingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<double> _scrubSecondsNotifier = ValueNotifier<double>(0.0);
  Timer? _seekDebounceTimer;
  int _accumulatedSeekSeconds = 0;

  // Trạng thái Yêu thích & Danh sách cá nhân
  bool _isBookmarked = false;
  bool _isLiked = false;

  void _checkLibraryState() {
    final mId = _activeMovie?.id ?? widget.movieId;
    if (mId != null && mounted) {
      setState(() {
        _isBookmarked = LibraryService.instance.isInMyList(mId);
        _isLiked = LibraryService.instance.isLiked(mId);
      });
    }
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    bool isActive = false,
    required VoidCallback onTap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GlassIconButton.rounded(
          size: 46,
          iconSize: 22,
          icon: icon,
          iconColor: isActive
              ? ThemeService.instance.primaryColor
              : Colors.white,
          hasGlow: isActive,
          glowColor: ThemeService.instance.primaryColor,
          onPressed: onTap,
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : AppColors.textSecondary,
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _cyclePlaybackSpeed() {
    final currentIndex = _playbackSpeeds.indexOf(_currentSpeed);
    final nextIndex = (currentIndex + 1) % _playbackSpeeds.length;
    final nextSpeed = _playbackSpeeds[nextIndex];
    setState(() {
      _currentSpeed = nextSpeed;
    });
    _videoPlayerController?.setPlaybackSpeed(nextSpeed);
    _showHud('Tốc độ: ${nextSpeed}x', Icons.speed_rounded);
  }

  void _toggleMute() {
    final newMuted = !_isMuted;
    setState(() {
      _isMuted = newMuted;
    });
    _videoPlayerController?.setVolume(newMuted ? 0.0 : 1.0);
    _showHud(
      newMuted ? 'Đã tắt tiếng' : 'Đã bật âm thanh',
      newMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
    );
  }

  void _togglePlayPause() {
    if (_videoPlayerController == null ||
        !_videoPlayerController!.value.isInitialized) {
      return;
    }
    if (_videoPlayerController!.value.isPlaying) {
      _videoPlayerController!.pause();
    } else {
      _videoPlayerController!.play();
    }
    setState(() {});
  }

  void _toggleFullscreen() {
    if (_chewieController == null) return;
    if (_chewieController!.isFullScreen) {
      _chewieController!.exitFullScreen();
    } else {
      _chewieController!.enterFullScreen();
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _activeMovie = widget.movie;
    _checkLibraryState();
    // Đợi hiệu ứng chuyển màn hoàn tất rồi mới khởi tạo Video Player
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final routeAnimation = ModalRoute.of(context)?.animation;
      if (routeAnimation != null && !routeAnimation.isCompleted) {
        void statusListener(AnimationStatus status) {
          if (status == AnimationStatus.completed) {
            routeAnimation.removeStatusListener(statusListener);
            if (mounted) {
              _initializePlayer();
              _loadSimilarMovies();
            }
          }
        }

        routeAnimation.addStatusListener(statusListener);
      } else {
        _initializePlayer();
        _loadSimilarMovies();
      }
    });
  }

  static const List<String> _fallbackVideoMirrors = [
    'https://vjs.zencdn.net/v/oceans.mp4',
    'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
    'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
  ];

  Future<void> _initializePlayer() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_activeMovie == null && widget.movieId != null) {
        _activeMovie = await PocketBaseService.instance.getMovieById(
          widget.movieId!,
        );
        _checkLibraryState();
      }

      if (_activeMovie == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Không tìm thấy thông tin phim';
        });
        return;
      }

      String targetUrl = _activeMovie!.videoUrl;
      if (targetUrl.isEmpty && _activeMovie!.trailerUrl.isNotEmpty) {
        targetUrl = _activeMovie!.trailerUrl;
      }
      // Nếu link Google Storage bị lỗi 403 Forbidden, tự động chuyển sang CDN mirror
      if (targetUrl.contains('commondatastorage.googleapis.com')) {
        targetUrl = _fallbackVideoMirrors.first;
      }

      try {
        _videoPlayerController = VideoPlayerController.networkUrl(
          Uri.parse(targetUrl),
        );
        await _videoPlayerController!.initialize();
      } catch (err) {
        // Fallback sang mirror dự phòng nếu link ban đầu không thể phát
        debugPrint(
          '⚠️ Link phim gốc lỗi: $err. Đang chuyển sang stream dự phòng...',
        );
        _videoPlayerController?.dispose();
        _videoPlayerController = VideoPlayerController.networkUrl(
          Uri.parse(_fallbackVideoMirrors.first),
        );
        await _videoPlayerController!.initialize();
      }

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        looping: false,
        aspectRatio: _videoPlayerController!.value.aspectRatio > 0
            ? _videoPlayerController!.value.aspectRatio
            : 16 / 9,
        allowFullScreen: true,
        allowMuting: true,
        showControls: false,
        deviceOrientationsOnEnterFullScreen: [
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ],
        deviceOrientationsAfterFullScreen: [DeviceOrientation.portraitUp],
        materialProgressColors: ChewieProgressColors(
          playedColor: ThemeService.instance.primaryColor,
          handleColor: ThemeService.instance.primaryColor,
          backgroundColor: Colors.white24,
          bufferedColor: Colors.white38,
        ),
        routePageBuilder:
            (context, animation, secondaryAnimation, controllerProvider) {
              return AnimatedBuilder(
                animation: animation,
                builder: (context, child) {
                  return ChewieControllerProvider(
                    controller: controllerProvider.controller,
                    child: OpenFlixFullscreenPlayer(
                      controller: controllerProvider.controller,
                      movieTitle: _activeMovie?.title ?? '',
                      initialFitMode: _fitMode,
                      onFitModeChanged: (mode) {
                        if (mounted) setState(() => _fitMode = mode);
                      },
                      playbackSpeed: _currentSpeed,
                      onSpeedChanged: (speed) {
                        if (mounted) setState(() => _currentSpeed = speed);
                      },
                      isMuted: _isMuted,
                      onMuteToggled: (muted) {
                        if (mounted) setState(() => _isMuted = muted);
                      },
                    ),
                  );
                },
              );
            },
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  color: ThemeService.instance.primaryColor,
                  size: 48,
                ),
                const SizedBox(height: 12),
                Text(
                  'Không thể phát video: $errorMessage',
                  style: const TextStyle(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _initializePlayer,
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  label: const Text(
                    'Thử lại',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeService.instance.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          );
        },
      );

      _videoPlayerController!.addListener(_onVideoTick);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _loadSimilarMovies() async {
    final all = await PocketBaseService.instance.getMovies();
    if (!mounted) return;
    setState(() {
      final currentId = _activeMovie?.id ?? widget.movieId ?? '';
      final currentCategory = _activeMovie?.category ?? '';
      _similarMovies = all
          .where((m) => m.id != currentId && m.category == currentCategory)
          .toList();
      if (_similarMovies.isEmpty) {
        _similarMovies = all.where((m) => m.id != currentId).take(4).toList();
      }
    });
  }

  bool _lastIsPlaying = false;
  bool _lastIsBuffering = false;

  void _onVideoTick() {
    if (!mounted || _videoPlayerController == null) return;
    final val = _videoPlayerController!.value;
    if (val.isPlaying != _lastIsPlaying) {
      if (val.isPlaying) {
        WavesBackground.notifyVideoPlaybackStarted();
      } else {
        WavesBackground.notifyVideoPlaybackStopped();
      }
      _lastIsPlaying = val.isPlaying;
      setState(() {});
    }
    if (val.isBuffering != _lastIsBuffering) {
      _lastIsBuffering = val.isBuffering;
      setState(() {});
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

  void _showHud(String message, [IconData? icon]) {
    _hudTimer?.cancel();
    setState(() {
      _hudMessage = message;
      _hudIcon = icon;
    });
    _hudTimer = Timer(const Duration(milliseconds: 1600), () {
      if (mounted) {
        setState(() {
          _hudMessage = null;
          _hudIcon = null;
        });
      }
    });
  }

  void _cycleFitMode() {
    setState(() {
      switch (_fitMode) {
        case VideoFitMode.fit:
          _fitMode = VideoFitMode.fill;
          _showHud('Phóng to tràn viền (Zoom to Fill)', Icons.fullscreen);
          break;
        case VideoFitMode.fill:
          _fitMode = VideoFitMode.stretch;
          _showHud('Kéo giãn toàn màn hình (Stretch)', Icons.fit_screen);
          break;
        case VideoFitMode.stretch:
          _fitMode = VideoFitMode.fit;
          _showHud('Vừa màn hình 16:9 (Fit)', Icons.fullscreen_exit);
          break;
      }
    });
  }

  void _toggleDoubleTapZoom() {
    setState(() {
      if (_currentScale > 1.1) {
        _transformationController.value = Matrix4.identity();
        _currentScale = 1.0;
        _showHud('Thu nhỏ: 1.0x (Mặc định)', Icons.zoom_out);
      } else {
        _transformationController.value = Matrix4.diagonal3Values(
          1.8,
          1.8,
          1.0,
        );
        _currentScale = 1.8;
        _showHud('Phóng to: 1.8x', Icons.zoom_in);
      }
    });
  }

  Duration? _baseSeekPosition;

  void _quickSeek(int seconds) {
    if (_videoPlayerController == null ||
        !_videoPlayerController!.value.isInitialized) {
      return;
    }
    if (_seekDebounceTimer == null || !_seekDebounceTimer!.isActive) {
      _baseSeekPosition = _videoPlayerController!.value.position;
    }
    _accumulatedSeekSeconds += seconds;
    final totalDuration = _videoPlayerController!.value.duration;

    final sign = _accumulatedSeekSeconds >= 0 ? '+' : '';
    final icon = _accumulatedSeekSeconds >= 0
        ? Icons.forward_10_rounded
        : Icons.replay_10_rounded;
    _showHud('Tua $sign${_accumulatedSeekSeconds}s', icon);

    _seekDebounceTimer?.cancel();
    _seekDebounceTimer = Timer(const Duration(milliseconds: 260), () async {
      final base = _baseSeekPosition ?? _videoPlayerController!.value.position;
      final target = base + Duration(seconds: _accumulatedSeekSeconds);
      final clamped = target < Duration.zero
          ? Duration.zero
          : (target > totalDuration ? totalDuration : target);
      await _videoPlayerController!.seekTo(clamped);
      _accumulatedSeekSeconds = 0;
      _baseSeekPosition = null;
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    if (_lastIsPlaying) {
      WavesBackground.notifyVideoPlaybackStopped();
    }
    _videoPlayerController?.removeListener(_onVideoTick);
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    _seekDebounceTimer?.cancel();
    _hudTimer?.cancel();
    _transformationController.dispose();
    _isScrubbingNotifier.dispose();
    _scrubSecondsNotifier.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final movieTitle = _activeMovie?.title ?? 'Đang tải...';
    return WavesBackground.wrapIfBlue(Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GlassBackButton(
          fallbackRoute: widget.movieId != null && widget.movieId!.isNotEmpty
              ? '/movie/${widget.movieId}'
              : '/',
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else if (widget.movieId != null && widget.movieId!.isNotEmpty) {
              context.go('/movie/${widget.movieId}');
            } else {
              context.go('/');
            }
          },
        ),
        title: Text(
          movieTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Trình phát Video (Chewie / Player) với Phóng to / Thu nhỏ & Cử chỉ mượt mà
            AspectRatio(
              aspectRatio: _fitMode == VideoFitMode.stretch ? 16 / 9 : 16 / 9,
              child: Container(
                color: ThemeService.instance.isLight
                    ? AppColors.surfaceLight
                    : Colors.black,
                child: _isLoading
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                ThemeService.instance.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Đang tải video luồng cao...',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      )
                    : _errorMessage != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: ThemeService.instance.primaryColor,
                                size: 40,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Lỗi kết nối video: $_errorMessage',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                onPressed: _initializePlayer,
                                icon: const Icon(
                                  Icons.refresh,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                label: const Text(
                                  'Thử lại',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      ThemeService.instance.primaryColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Stack(
                        alignment: Alignment.center,
                        children: [
                          // 1. Tầng tương tác chạm để Phát/Dừng, chạm đúp và thu phóng 2 ngón tay
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: _togglePlayPause,
                            onDoubleTapDown: (details) {
                              final screenWidth = MediaQuery.sizeOf(context).width;
                              if (details.localPosition.dx <
                                  screenWidth * 0.35) {
                                _quickSeek(-10);
                              } else if (details.localPosition.dx >
                                  screenWidth * 0.65) {
                                _quickSeek(10);
                              } else {
                                _toggleDoubleTapZoom();
                              }
                            },
                            child: ClipRect(
                              child: InteractiveViewer(
                                transformationController:
                                    _transformationController,
                                minScale: 1.0,
                                maxScale: 3.5,
                                panAxis: PanAxis.free,
                                onInteractionUpdate: (details) {
                                  _currentScale = _transformationController
                                      .value
                                      .getMaxScaleOnAxis();
                                  if (details.pointerCount >= 2) {
                                    if (_fitMode == VideoFitMode.fit &&
                                        details.scale > 1.12) {
                                      HapticFeedback.selectionClick();
                                      setState(() {
                                        _fitMode = VideoFitMode.fill;
                                        _transformationController.value =
                                            Matrix4.identity();
                                        _currentScale = 1.0;
                                      });
                                      _showHud(
                                        'Phóng to để vừa màn hình',
                                        Icons.fullscreen,
                                      );
                                    } else if (_fitMode == VideoFitMode.fill &&
                                        details.scale < 0.88) {
                                      HapticFeedback.selectionClick();
                                      setState(() {
                                        _fitMode = VideoFitMode.fit;
                                        _transformationController.value =
                                            Matrix4.identity();
                                        _currentScale = 1.0;
                                      });
                                      _showHud(
                                        'Vừa màn hình 16:9 (Gốc)',
                                        Icons.fullscreen_exit,
                                      );
                                    }
                                  }
                                },
                                onInteractionEnd: (details) {
                                  _currentScale = _transformationController
                                      .value
                                      .getMaxScaleOnAxis();
                                  if (_currentScale > 1.05) {
                                    _showHud(
                                      'Thu phóng: ${_currentScale.toStringAsFixed(1)}x',
                                      Icons.zoom_in,
                                    );
                                  }
                                },
                                child: FittedBox(
                                  fit: _fitMode == VideoFitMode.fill
                                      ? BoxFit.cover
                                      : (_fitMode == VideoFitMode.stretch
                                            ? BoxFit.fill
                                            : BoxFit.contain),
                                  child: SizedBox(
                                    width:
                                        (_videoPlayerController
                                                    ?.value
                                                    .size
                                                    .width ??
                                                0) >
                                            0
                                        ? _videoPlayerController!
                                              .value
                                              .size
                                              .width
                                        : 1600,
                                    height:
                                        (_videoPlayerController
                                                    ?.value
                                                    .size
                                                    .height ??
                                                0) >
                                            0
                                        ? _videoPlayerController!
                                              .value
                                              .size
                                              .height
                                        : 900,
                                    child: _chewieController != null
                                        ? RepaintBoundary(
                                            child: Chewie(
                                              controller: _chewieController!,
                                            ),
                                          )
                                        : const SizedBox.shrink(),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // 2. Chip đặt lại thu phóng (chỉ hiện khi người dùng zoom > 1.05x)
                          if (_currentScale > 1.05)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _transformationController.value =
                                        Matrix4.identity();
                                    _currentScale = 1.0;
                                    _showHud(
                                      'Đã đặt lại: 1.0x',
                                      Icons.zoom_out,
                                    );
                                  });
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black87,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: ThemeService.instance.primaryColor,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.zoom_out,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${_currentScale.toStringAsFixed(1)}x (Đặt lại)',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                          // 3. Nút tròn phát video kính mờ quang học (GlassPlayerPlayButton - 68x68 px, Snell 1.48)
                          if (_videoPlayerController != null &&
                              _videoPlayerController!.value.isInitialized &&
                              (!_videoPlayerController!.value.isPlaying ||
                                  _videoPlayerController!.value.isBuffering))
                            GlassPlayerPlayButton(
                              isPlaying:
                                  _videoPlayerController!.value.isPlaying,
                              isLoading:
                                  _videoPlayerController!.value.isBuffering,
                              onPressed: _togglePlayPause,
                            ),

                          // 4. Thông báo nổi HUD phía trên (tránh đè nút tròn Play/Pause)
                          if (_hudMessage != null)
                            Positioned(
                              top: 14,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 7,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.85),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.white24,
                                      width: 1,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black54,
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (_hudIcon != null) ...[
                                        Icon(
                                          _hudIcon,
                                          color: ThemeService
                                              .instance
                                              .primaryColor,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 6),
                                      ],
                                      Text(
                                        _hudMessage!,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
              ),
            ),

            // Thanh tua mượt mà (Seek-on-Release & Không giật lag)
            if (_videoPlayerController != null &&
                _videoPlayerController!.value.isInitialized) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
                child: Column(
                  children: [
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 3.5,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 6,
                        ),
                        overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 12,
                        ),
                        activeTrackColor: ThemeService.instance.primaryColor,
                        inactiveTrackColor: Colors.white24,
                        thumbColor: ThemeService.instance.primaryColor,
                        overlayColor: ThemeService.instance.primaryColor
                            .withValues(alpha: 0.25),
                      ),
                      child: ListenableBuilder(
                        listenable: Listenable.merge([
                          _videoPlayerController!,
                          _isScrubbingNotifier,
                          _scrubSecondsNotifier,
                        ]),
                        builder: (context, _) {
                          final maxSec =
                              (_videoPlayerController!.value.duration.inSeconds > 0
                                      ? _videoPlayerController!
                                          .value
                                          .duration
                                          .inSeconds
                                      : 1)
                                  .toDouble();
                          final isScrubbing = _isScrubbingNotifier.value;
                          final currentSec = isScrubbing
                              ? _scrubSecondsNotifier.value.clamp(0.0, maxSec)
                              : _videoPlayerController!
                                  .value
                                  .position
                                  .inSeconds
                                  .toDouble()
                                  .clamp(0.0, maxSec);
                          return Slider(
                            min: 0.0,
                            max: maxSec,
                            value: currentSec,
                            onChangeStart: (val) {
                              _isScrubbingNotifier.value = true;
                              _scrubSecondsNotifier.value = val;
                            },
                            onChanged: (val) {
                              _scrubSecondsNotifier.value = val;
                            },
                            onChangeEnd: (val) async {
                              final target = Duration(seconds: val.toInt());
                              await _videoPlayerController!.seekTo(target);
                              if (mounted) {
                                _isScrubbingNotifier.value = false;
                              }
                            },
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: ListenableBuilder(
                        listenable: Listenable.merge([
                          _videoPlayerController!,
                          _isScrubbingNotifier,
                          _scrubSecondsNotifier,
                        ]),
                        builder: (context, _) {
                          final isScrubbing = _isScrubbingNotifier.value;
                          final currentPos = isScrubbing
                              ? Duration(
                                  seconds: _scrubSecondsNotifier.value.toInt(),
                                )
                              : _videoPlayerController!.value.position;
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDuration(currentPos),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                _formatDuration(
                                  _videoPlayerController!.value.duration,
                                ),
                                style: const TextStyle(
                                  color: Colors.white38,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Thanh công cụ kính mờ quang học tinh gọn (Glass Media Toolbar)
                    // Nằm độc lập ngoài ListenableBuilder vị trí để không bị vẽ lại mỗi nhịp phát video
                    Center(
                      child: GlassMediaToolbar(
                        onFitModeToggle: _cycleFitMode,
                        fitModeLabel: _fitMode == VideoFitMode.fill
                            ? 'Tràn viền'
                            : (_fitMode == VideoFitMode.stretch
                                  ? 'Kéo giãn'
                                  : '16:9'),
                        fitModeIcon: _fitMode == VideoFitMode.fill
                            ? Icons.fullscreen
                            : (_fitMode == VideoFitMode.stretch
                                  ? Icons.fit_screen
                                  : Icons.fullscreen_exit),
                        onSpeedToggle: _cyclePlaybackSpeed,
                        currentSpeed: _currentSpeed,
                        onMuteToggle: _toggleMute,
                        isMuted: _isMuted,
                        onFullscreenToggle: _toggleFullscreen,
                        isFullscreen:
                            _chewieController?.isFullScreen ?? false,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Thông tin chi tiết phim
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tiêu đề phim
                  Text(
                    _activeMovie?.title ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Metadata tags (Năm, Phân loại, HD, 1080p)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: ThemeService.instance.primaryColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _activeMovie?.category ?? 'Phim',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${_activeMovie?.releaseYear ?? 2024}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white38),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: const Text(
                          'FULL HD 1080p',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Hàng nút hành động chuẩn điện ảnh Netflix tinh gọn (Danh sách, Thích, Phụ đề, Chia sẻ)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // 1. Nút Danh sách của tôi
                      _buildActionButton(
                        icon: _isBookmarked ? Icons.check : Icons.add,
                        label: 'Danh sách',
                        isActive: _isBookmarked,
                        onTap: () async {
                          final mId = _activeMovie?.id ?? widget.movieId;
                          if (mId == null) return;
                          await LibraryService.instance.toggleMyList(mId);
                          setState(() {
                            _isBookmarked = LibraryService.instance.isInMyList(
                              mId,
                            );
                          });
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  _isBookmarked
                                      ? 'Đã thêm "${_activeMovie?.title ?? 'phim'}" vào Danh sách'
                                      : 'Đã xóa khỏi Danh sách của tôi',
                                ),
                                backgroundColor:
                                    ThemeService.instance.primaryColor,
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          }
                        },
                      ),
                      // 2. Nút Thích
                      _buildActionButton(
                        icon: _isLiked
                            ? Icons.thumb_up
                            : Icons.thumb_up_alt_outlined,
                        label: 'Thích',
                        isActive: _isLiked,
                        onTap: () async {
                          final mId = _activeMovie?.id ?? widget.movieId;
                          if (mId == null) return;
                          await LibraryService.instance.toggleLike(mId);
                          setState(() {
                            _isLiked = LibraryService.instance.isLiked(mId);
                          });
                        },
                      ),
                      // 3. Nút Âm thanh & Phụ đề
                      _buildActionButton(
                        icon: Icons.subtitles_outlined,
                        label: 'Phụ đề',
                        onTap: () {
                          final mId = _activeMovie?.id ?? widget.movieId;
                          if (mId != null) {
                            context.push('/movie/$mId/audio');
                          }
                        },
                      ),
                      // 4. Nút Chia sẻ
                      _buildActionButton(
                        icon: Icons.share_outlined,
                        label: 'Chia sẻ',
                        onTap: () {
                          final vUrl = _activeMovie?.videoUrl ?? '';
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Đã sao chép link video: $vUrl'),
                              backgroundColor: AppColors.surface,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Tóm tắt nội dung
                  const Text(
                    'Nội dung phim',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _activeMovie?.description ?? '',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Phim cùng thể loại / Đề xuất tương tự
                  if (_similarMovies.isNotEmpty) ...[
                    const Text(
                      'Phim cùng thể loại & Đề xuất',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 190,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _similarMovies.length,
                        itemBuilder: (context, index) {
                          return MovieCard(
                            movie: _similarMovies[index],
                            width: 120,
                            height: 180,
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
