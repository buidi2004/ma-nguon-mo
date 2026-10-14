import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/movie_model.dart';
import '../../presentation/widgets/glass/glass_components.dart';
import '../../services/library_service.dart';
import '../../services/pocketbase_service.dart';
import '../../theme/app_theme.dart';

class WatchHistoryScreen extends StatefulWidget {
  const WatchHistoryScreen({super.key});

  @override
  State<WatchHistoryScreen> createState() => _WatchHistoryScreenState();
}

class _WatchHistoryScreenState extends State<WatchHistoryScreen> {
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

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} lúc ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
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

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text(
              'Lịch sử xem phim',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
            actions: [
              if (activeMovies.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: GlassButton.capsule(
                    text: 'Xóa tất cả',
                    icon: Icons.delete_sweep_outlined,
                    style: GlassButtonStyle.neutralDark,
                    height: 34,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    onPressed: () {
                      showGlassDialog(
                        context: context,
                        title: 'Xóa lịch sử xem?',
                        content: const Text(
                          'Bạn có chắc chắn muốn xóa toàn bộ lịch sử xem phim?',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        actions: [
                          GlassButton.neutral(
                            text: 'Hủy',
                            onPressed: () => Navigator.pop(context),
                          ),
                          GlassButton.brand(
                            text: 'Xóa tất cả',
                            onPressed: () {
                              _libService.clearAll();
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ),
            ],
          ),
          body: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.red),
                  ),
                )
              : activeMovies.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.history,
                          size: 64,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Chưa có lịch sử xem phim',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Những bộ phim bạn từng thưởng thức sẽ được lưu lại theo mốc thời gian tại đây.',
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
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  itemCount: activeMovies.length,
                  itemBuilder: (context, index) {
                    final movie = activeMovies[index];
                    final item = progressMap[movie.id]!;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: CachedNetworkImage(
                            imageUrl: movie.posterUrl,
                            width: 50,
                            height: 75,
                            fit: BoxFit.cover,
                            memCacheWidth: 150,
                            memCacheHeight: 225,
                            maxHeightDiskCache: 300,
                            placeholder: (_, _) =>
                                const ColoredBox(color: AppColors.surfaceLight),
                          ),
                        ),
                        title: Text(
                          movie.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            'Đã xem: ${_formatDate(item.updatedAt)}\nThể loại: ${movie.category}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              height: 1.3,
                            ),
                          ),
                        ),
                        trailing: GlassIconButton.circle(
                          size: 36,
                          iconSize: 20,
                          icon: Icons.play_arrow_rounded,
                          onPressed: () => context.push('/movie/${movie.id}'),
                        ),
                        onTap: () => context.push('/movie/${movie.id}'),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}
