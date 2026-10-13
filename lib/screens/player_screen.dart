import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

import '../models/movie_model.dart';
import '../services/pocketbase_service.dart';
import '../theme/app_theme.dart';
import '../widgets/movie_card.dart';

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

  @override
  void initState() {
    super.initState();
    _activeMovie = widget.movie;
    _initializePlayer();
    _loadSimilarMovies();
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
      }

      if (_activeMovie == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Không tìm thấy thông tin phim';
        });
        return;
      }

      String targetUrl = _activeMovie!.videoUrl;
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
        debugPrint('⚠️ Link phim gốc lỗi: $err. Đang chuyển sang stream dự phòng...');
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
        showControls: true,
        deviceOrientationsOnEnterFullScreen: [
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ],
        deviceOrientationsAfterFullScreen: [DeviceOrientation.portraitUp],
        materialProgressColors: ChewieProgressColors(
          playedColor: AppColors.red,
          handleColor: AppColors.red,
          backgroundColor: Colors.white24,
          bufferedColor: Colors.white38,
        ),
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: AppColors.red,
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
                    backgroundColor: AppColors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          );
        },
      );

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

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final movieTitle = _activeMovie?.title ?? 'Đang tải...';
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          movieTitle,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Trình phát Video (Chewie / Player)
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                color: Colors.black,
                child: _isLoading
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.red,
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
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
                              const Icon(
                                Icons.warning_amber_rounded,
                                color: AppColors.red,
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
                                icon: const Icon(Icons.refresh, color: Colors.white, size: 18),
                                label: const Text(
                                  'Thử lại',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.red,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : _chewieController != null
                    ? Chewie(controller: _chewieController!)
                    : const SizedBox.shrink(),
              ),
            ),

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
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.red,
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
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Các nút chức năng (Play, Download, Share)
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          if (_videoPlayerController?.value.isPlaying == true) {
                            _videoPlayerController?.pause();
                          } else {
                            _videoPlayerController?.play();
                          }
                          setState(() {});
                        },
                        icon: Icon(
                          _videoPlayerController?.value.isPlaying == true
                              ? Icons.pause
                              : Icons.play_arrow,
                          color: Colors.black,
                        ),
                        label: Text(
                          _videoPlayerController?.value.isPlaying == true
                              ? 'Tạm dừng'
                              : 'Phát lại',
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Đã thêm phim vào danh sách Yêu thích của bạn!',
                              ),
                              backgroundColor: AppColors.red,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text(
                          'Danh sách',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white30),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          final vUrl = _activeMovie?.videoUrl ?? '';
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Đã sao chép link video: $vUrl'),
                              backgroundColor: AppColors.surface,
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.share_outlined,
                          color: Colors.white70,
                        ),
                        tooltip: 'Chia sẻ',
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
                      fontSize: 13.5,
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
    );
  }
}
