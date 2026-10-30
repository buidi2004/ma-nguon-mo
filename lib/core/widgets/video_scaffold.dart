import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import '../../presentation/widgets/glass/glass_components.dart';
import '../../presentation/widgets/player/fullscreen_player_overlay.dart';
import '../../services/theme_service.dart';
import '../../theme/app_theme.dart';
import '../../waves_background.dart';

class VideoScaffold extends StatefulWidget {
  final String videoUrl;
  final String title;
  final String? subtitle;
  final int initialPositionSeconds;
  final void Function(int positionSeconds, int durationSeconds)? onProgress;

  const VideoScaffold({
    super.key,
    required this.videoUrl,
    required this.title,
    this.subtitle,
    this.initialPositionSeconds = 0,
    this.onProgress,
  });

  @override
  State<VideoScaffold> createState() => _VideoScaffoldState();
}

class _VideoScaffoldState extends State<VideoScaffold> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    try {
      final uri = Uri.parse(widget.videoUrl);
      _videoPlayerController = VideoPlayerController.networkUrl(uri);
      await _videoPlayerController!.initialize();

      if (widget.initialPositionSeconds > 0) {
        await _videoPlayerController!.seekTo(
          Duration(seconds: widget.initialPositionSeconds),
        );
      }

      _videoPlayerController!.addListener(_videoListener);

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        looping: false,
        aspectRatio: _videoPlayerController!.value.aspectRatio > 0
            ? _videoPlayerController!.value.aspectRatio
            : 16 / 9,
        materialProgressColors: ChewieProgressColors(
          playedColor: ThemeService.instance.primaryColor,
          handleColor: ThemeService.instance.primaryColor,
          backgroundColor: Colors.white24,
          bufferedColor: Colors.white54,
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
                      movieTitle: widget.title,
                    ),
                  );
                },
              );
            },
        placeholder: Container(
          color: ThemeService.instance.isLight
              ? AppColors.surfaceLight
              : Colors.black,
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                ThemeService.instance.primaryColor,
              ),
            ),
          ),
        ),
        autoInitialize: true,
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: AppColors.red,
                    size: 48,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Không thể tải nguồn video',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    errorMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Lỗi khởi tạo trình phát video: $e';
        });
      }
    }
  }

  void _videoListener() {
    if (_videoPlayerController != null &&
        _videoPlayerController!.value.isInitialized &&
        widget.onProgress != null) {
      final pos = _videoPlayerController!.value.position.inSeconds;
      final dur = _videoPlayerController!.value.duration.inSeconds;
      widget.onProgress!(pos, dur);
    }
  }

  @override
  void dispose() {
    _videoPlayerController?.removeListener(_videoListener);
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WavesBackground.wrapIfBlue(Scaffold(
      backgroundColor: ThemeService.instance.isWindowsBlue
          ? Colors.transparent
          : Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Video Area
            Center(
              child: _isLoading
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            ThemeService.instance.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Đang tải luồng phát...',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    )
                  : _errorMessage != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.videocam_off_outlined,
                            color: AppColors.red,
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    )
                  : _chewieController != null
                  ? RepaintBoundary(
                      child: Chewie(controller: _chewieController!),
                    )
                  : const SizedBox.shrink(),
            ),

            // Top Header Bar
            Positioned(
              top: 8,
              left: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black.withAlpha(200), Colors.transparent],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 8, right: 8),
                      child: GlassBackButton(fallbackRoute: '/'),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (widget.subtitle != null) ...[
                            Text(
                              widget.subtitle!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
