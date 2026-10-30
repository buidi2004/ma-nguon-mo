import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/movie_model.dart';
import '../../presentation/widgets/glass/glass_components.dart';
import '../../services/auth_guard.dart';
import '../../services/library_service.dart';
import '../../services/pocketbase_service.dart';
import '../../services/theme_service.dart';
import '../../theme/app_theme.dart';
import '../../waves_background.dart';

class ContinueWatchingScreen extends StatefulWidget {
  const ContinueWatchingScreen({super.key});

  @override
  State<ContinueWatchingScreen> createState() => _ContinueWatchingScreenState();
}

class _ContinueWatchingScreenState extends State<ContinueWatchingScreen> {
  final _pbService = PocketBaseService.instance;
  final _libService = LibraryService.instance;
  List<MovieModel> _movies = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  Future<void> _loadMovies() async {
    setState(() => _isLoading = true);
    final all = await _pbService.getMovies();
    final progressMap = _libService.progressMap;
    if (!mounted) return;
    setState(() {
      _movies = all.where((m) => progressMap.containsKey(m.id)).toList();
      _isLoading = false;
    });
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _libService,
      builder: (context, _) {
        final progressMap = _libService.progressMap;
        final activeMovies = _movies
            .where((m) => progressMap.containsKey(m.id))
            .toList();

        return WavesBackground.wrapIfBlue(Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            leading: const GlassBackButton(),
            title: Text(
              'Đang xem dở',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
          ),
          body: _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      ThemeService.instance.primaryColor,
                    ),
                  ),
                )
              : activeMovies.isEmpty
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.play_circle_outline,
                          size: 64,
                          color: AppColors.textMuted,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Không có bộ phim nào đang xem dở',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Khi bạn dừng xem giữa chừng, tiến độ phim sẽ tự động lưu lại tại đây để phát tiếp.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 24),
                        GlassButton.primary(
                          text: 'Khám phá phim ngay',
                          icon: Icons.explore_outlined,
                          height: 44,
                          onPressed: () => context.go('/'),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  cacheExtent: 500.0,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  itemCount: activeMovies.length,
                  itemBuilder: (context, index) {
                    final movie = activeMovies[index];
                    final item = progressMap[movie.id]!;
                    final ratio = item.progressRatio;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(6),
                        onTap: () {
                          AuthGuard.runWithAuth(
                            context,
                            movieId: movie.id,
                            movieTitle: movie.title,
                            hasTrailer: true,
                            onWatchTrailer: () =>
                                context.push('/movie/${movie.id}/trailer'),
                            onAuthorized: () =>
                                context.push('/watch/${movie.id}'),
                          );
                        },
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Ảnh thu nhỏ kính mờ tích hợp nút Play & tiến trình
                                IgnorePointer(
                                  child: GlassPlayThumbnailOverlay(
                                    imageUrl: movie.posterUrl,
                                    width: 120,
                                    height: 80,
                                    progressRatio: ratio,
                                    borderRadius: 6,
                                    onTap: () {},
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        movie.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Đã xem: ${_formatTime(item.positionSeconds)} / ${_formatTime(item.durationSeconds)}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Tiến độ: ${(ratio * 100).toInt()}%',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: ThemeService
                                              .instance
                                              .primaryColor,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: GlassIconButton.circle(
                                    size: 32,
                                    iconSize: 16,
                                    icon: Icons.close_rounded,
                                    tooltip: 'Xóa khỏi danh sách xem dở',
                                    onPressed: () =>
                                        _libService.removeProgress(movie.id),
                                  ),
                                ),
                              ],
                            ),
                            // Thanh tiến độ chuẩn theme
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(6),
                              ),
                              child: LinearProgressIndicator(
                                value: ratio,
                                backgroundColor: Colors.white12,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  ThemeService.instance.primaryColor,
                                ),
                                minHeight: 4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ));
      },
    );
  }
}
