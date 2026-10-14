import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/state_view.dart';
import '../../models/movie_model.dart';
import '../../services/pocketbase_service.dart';
import '../../theme/app_theme.dart';

class Top10Screen extends StatefulWidget {
  const Top10Screen({super.key});

  @override
  State<Top10Screen> createState() => _Top10ScreenState();
}

class _Top10ScreenState extends State<Top10Screen> {
  final _pbService = PocketBaseService.instance;
  List<MovieModel> _topMovies = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTop10();
  }

  Future<void> _loadTop10() async {
    setState(() => _isLoading = true);
    final top10 = await _pbService.getTop10Movies();
    if (!mounted) return;
    setState(() {
      _topMovies = top10;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Top 10 Phim Thịnh Hành',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: _isLoading
          ? StateView.loading(message: 'Đang xếp hạng Top 10...')
          : _topMovies.isEmpty
          ? StateView.empty(title: 'Chưa có bảng xếp hạng')
          : ListView.separated(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _topMovies.length,
              separatorBuilder: (context, index) =>
                  const Divider(color: Colors.white12, height: 20),
              itemBuilder: (context, index) {
                final movie = _topMovies[index];
                final rank = index + 1;

                return InkWell(
                  onTap: () => context.push('/movie/${movie.id}'),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Big Rank Number
                        SizedBox(
                          width: 50,
                          child: Text(
                            '$rank',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.w900,
                              color: rank <= 3 ? AppColors.red : Colors.white70,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withAlpha(200),
                                  blurRadius: 4,
                                  offset: const Offset(1, 1),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Poster
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: CachedNetworkImage(
                            imageUrl: movie.posterUrl,
                            width: 75,
                            height: 110,
                            fit: BoxFit.cover,
                            memCacheWidth: 250,
                            memCacheHeight: 366,
                            maxHeightDiskCache: 450,
                            placeholder: (context, url) => Container(
                              width: 75,
                              height: 110,
                              color: AppColors.surface,
                            ),
                            errorWidget: (context, url, error) => Container(
                              width: 75,
                              height: 110,
                              color: AppColors.surface,
                              child: const Icon(
                                Icons.movie,
                                color: Colors.white38,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Movie Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  if (rank <= 3) ...[
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 5,
                                        vertical: 2,
                                      ),
                                      margin: const EdgeInsets.only(right: 6),
                                      decoration: BoxDecoration(
                                        color: AppColors.red,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                      child: const Text(
                                        'HOT',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                  Expanded(
                                    child: Text(
                                      movie.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text(
                                    '${movie.releaseYear}',
                                    style: const TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 1,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.white24),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    child: Text(
                                      movie.ageRating,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    movie.category,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: AppColors.red,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                movie.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Play Button Icon
                        IconButton(
                          icon: const Icon(
                            Icons.play_circle_fill,
                            color: Colors.white,
                            size: 36,
                          ),
                          onPressed: () => context.push('/watch/${movie.id}'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
