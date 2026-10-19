import 'dart:async';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import '../../models/movie_model.dart';
import '../../presentation/widgets/glass/glass_components.dart';
import '../../presentation/widgets/player/fullscreen_player_overlay.dart';
import '../../services/pocketbase_service.dart';
import '../../services/theme_service.dart';
import '../../theme/app_theme.dart';

class TrailerScreen extends StatefulWidget {
  final String movieId;

  const TrailerScreen({super.key, required this.movieId});

  @override
  State<TrailerScreen> createState() => _TrailerScreenState();
}

class _TrailerScreenState extends State<TrailerScreen> {
  Movie? _movie;
  bool _isLoading = true;
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isVideoLoading = true;
  String? _videoError;

  // Zoom & Smooth Seek
  final TransformationController _transformationController =
      TransformationController();
  double _currentScale = 1.0;
  String? _hudMessage;
  Timer? _hudTimer;
  Timer? _seekDebounceTimer;
  int _accumulatedSeekSeconds = 0;

  static const List<String> _fallbackVideoMirrors = [
    'https://vjs.zencdn.net/v/oceans.mp4',
    'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
    'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
  ];

  @override
  void initState() {
    super.initState();
    // Đợi hiệu ứng chuyển màn (cinematicBars 320ms) hoàn tất 100% rồi mới load video trailer,
    // giúp hiệu ứng chuyển cảnh đạt 60/120fps mượt mà không khựng giật.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final routeAnimation = ModalRoute.of(context)?.animation;
      if (routeAnimation != null && !routeAnimation.isCompleted) {
        void statusListener(AnimationStatus status) {
          if (status == AnimationStatus.completed) {
            routeAnimation.removeStatusListener(statusListener);
            if (mounted) _loadMovie();
          }
        }

        routeAnimation.addStatusListener(statusListener);
      } else {
        _loadMovie();
      }
    });
  }

  Future<void> _loadMovie() async {
    final movie = await PocketBaseService.instance.getMovieById(widget.movieId);
    if (mounted) {
      setState(() {
        _movie = movie;
        _isLoading = false;
      });
      if (movie != null) {
        // Ưu tiên phát trailer chính thức (trailerUrl), nếu rỗng mới dùng videoUrl
        final trailerLink = movie.trailerUrl.trim().isNotEmpty
            ? movie.trailerUrl
            : movie.videoUrl;
        _initializePlayer(trailerLink);
      }
    }
  }

  Future<void> _initializePlayer(String rawUrl) async {
    setState(() {
      _isVideoLoading = true;
      _videoError = null;
    });

    try {
      String targetUrl = rawUrl.trim().isNotEmpty
          ? rawUrl
          : _fallbackVideoMirrors.first;
      if (targetUrl.contains('commondatastorage.googleapis.com')) {
        targetUrl = _fallbackVideoMirrors.first;
      }

      try {
        _videoPlayerController = VideoPlayerController.networkUrl(
          Uri.parse(targetUrl),
        );
        await _videoPlayerController!.initialize();
      } catch (err) {
        debugPrint(
          '⚠️ Link trailer lỗi: $err. Đang chuyển sang stream dự phòng...',
        );
        _videoPlayerController?.dispose();
        _videoPlayerController = VideoPlayerController.networkUrl(
          Uri.parse(_fallbackVideoMirrors.first),
        );
        await _videoPlayerController!.initialize();
      }

      if (!mounted) return;

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
                      movieTitle: _movie?.title ?? 'Trailer',
                    ),
                  );
                },
              );
            },
      );

      if (mounted) {
        setState(() {
          _isVideoLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isVideoLoading = false;
          _videoError = e.toString();
        });
      }
    }
  }

  void _showHud(String message) {
    _hudTimer?.cancel();
    setState(() {
      _hudMessage = message;
    });
    _hudTimer = Timer(const Duration(milliseconds: 1600), () {
      if (mounted) setState(() => _hudMessage = null);
    });
  }

  void _toggleDoubleTapZoom() {
    setState(() {
      if (_currentScale > 1.1) {
        _transformationController.value = Matrix4.identity();
        _currentScale = 1.0;
        _showHud('Thu nhỏ: 1.0x (Mặc định)');
      } else {
        _transformationController.value = Matrix4.diagonal3Values(
          1.8,
          1.8,
          1.0,
        );
        _currentScale = 1.8;
        _showHud('Phóng to: 1.8x');
      }
    });
  }

  void _quickSeek(int seconds) {
    if (_videoPlayerController == null ||
        !_videoPlayerController!.value.isInitialized) {
      return;
    }
    _accumulatedSeekSeconds += seconds;
    final totalDuration = _videoPlayerController!.value.duration;
    final currentPos = _videoPlayerController!.value.position;

    final sign = _accumulatedSeekSeconds >= 0 ? '+' : '';
    _showHud('Tua $sign${_accumulatedSeekSeconds}s');

    _seekDebounceTimer?.cancel();
    _seekDebounceTimer = Timer(const Duration(milliseconds: 260), () async {
      final target = currentPos + Duration(seconds: _accumulatedSeekSeconds);
      final clamped = target < Duration.zero
          ? Duration.zero
          : (target > totalDuration ? totalDuration : target);
      await _videoPlayerController!.seekTo(clamped);
      _accumulatedSeekSeconds = 0;
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoPlayerController?.dispose();
    _hudTimer?.cancel();
    _seekDebounceTimer?.cancel();
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(
            color: ThemeService.instance.primaryColor,
          ),
        ),
      );
    }

    if (_movie == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(backgroundColor: Colors.transparent),
        body: const Center(
          child: Text(
            'Không tìm thấy trailer của phim',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                children: [
                  GlassBackButton(
                    fallbackRoute: '/movie/${widget.movieId}',
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Trailer chính thức: ${_movie!.title}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 10),
                  GlassIconButton.circle(
                    size: 38,
                    iconSize: 20,
                    icon: Icons.share_outlined,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Đã sao chép liên kết trailer'),
                          backgroundColor: AppColors.surface,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            // Khung video player tinh gọn
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    color: Colors.black,
                    child: _isVideoLoading
                        ? Center(
                            child: CircularProgressIndicator(
                              color: ThemeService.instance.primaryColor,
                            ),
                          )
                        : _videoError != null
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
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
                                    'Lỗi kết nối trailer: $_videoError',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      if (_movie != null) {
                                        _initializePlayer(_movie!.videoUrl);
                                      }
                                    },
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
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : _chewieController != null
                        ? Stack(
                            alignment: Alignment.center,
                            children: [
                              GestureDetector(
                                onDoubleTapDown: (details) {
                                  final screenWidth = MediaQuery.of(context)
                                      .size
                                      .width;
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
                                    },
                                    onInteractionEnd: (details) {
                                      _currentScale = _transformationController
                                          .value
                                          .getMaxScaleOnAxis();
                                      if (_currentScale > 1.05) {
                                        _showHud(
                                          'Thu phóng: ${_currentScale.toStringAsFixed(1)}x',
                                        );
                                      }
                                    },
                                    child: RepaintBoundary(
                                      child: Chewie(
                                        controller: _chewieController!,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              if (_hudMessage != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.85),
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: Colors.white24,
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    _hudMessage!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
              ),
            ),
            // Thông tin mô tả bên dưới
            Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.background,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GlassSpecBadge.tag(label: 'TRAILER', isCapsule: true),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${_movie!.releaseYear} • ${_movie!.category}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GlassButton.primary(
                        text: 'Xem chi tiết',
                        icon: Icons.info_outline,
                        height: 38,
                        borderRadius: 19,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        onPressed: () => context.push('/movie/${widget.movieId}'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _movie!.description,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
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
