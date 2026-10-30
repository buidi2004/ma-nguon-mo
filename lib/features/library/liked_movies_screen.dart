import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/movie_model.dart';
import '../../presentation/widgets/glass/glass_components.dart';
import '../../services/library_service.dart';
import '../../services/pocketbase_service.dart';
import '../../services/theme_service.dart';
import '../../theme/app_theme.dart';
import '../../waves_background.dart';

class LikedMoviesScreen extends StatefulWidget {
  const LikedMoviesScreen({super.key});

  @override
  State<LikedMoviesScreen> createState() => _LikedMoviesScreenState();
}

class _LikedMoviesScreenState extends State<LikedMoviesScreen> {
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
    final likedIds = _libService.likedMovieIds;
    if (!mounted) return;
    setState(() {
      _movies = all.where((m) => likedIds.contains(m.id)).toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _libService,
      builder: (context, _) {
        final likedIds = _libService.likedMovieIds;
        final activeMovies = _movies
            .where((m) => likedIds.contains(m.id))
            .toList();

        return WavesBackground.wrapIfBlue(
          Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              leading: const GlassBackButton(),
              title: Text(
                'Phim đã thích',
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
                            Icons.thumb_up_alt_outlined,
                            size: 64,
                            color: AppColors.textMuted,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Bạn chưa thích bộ phim nào',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Bấm biểu tượng Thích ở bất kỳ bộ phim nào bạn yêu thích để lưu vào bộ sưu tập này.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () => context.go('/'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  ThemeService.instance.primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            child: const Text('Khám phá phim ngay'),
                          ),
                        ],
                      ),
                    ),
                  )
                : Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 6,
                          ),
                          child: Text(
                            'Đã thích ${activeMovies.length} bộ phim',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Expanded(
                          child: GridView.builder(
                            cacheExtent: 500.0,
                            physics: const BouncingScrollPhysics(),
                            itemCount: activeMovies.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  childAspectRatio: 2 / 3,
                                  crossAxisSpacing: 6,
                                  mainAxisSpacing: 6,
                                ),
                            itemBuilder: (context, index) {
                              final movie = activeMovies[index];

                              return GestureDetector(
                                onTap: () => context.push(
                                  '/movie/${movie.id}',
                                  extra: movie,
                                ),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Hero(
                                      tag: 'movie_poster_${movie.id}',
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: CachedNetworkImage(
                                          imageUrl: movie.posterUrl,
                                          fit: BoxFit.cover,
                                          memCacheWidth: 350,
                                          memCacheHeight: 525,
                                          maxHeightDiskCache: 600,
                                          placeholder: (_, _) => ColoredBox(
                                            color: AppColors.surface,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 4,
                                      right: 4,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.black87,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.thumb_up,
                                          color: ThemeService
                                              .instance
                                              .primaryColor,
                                          size: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }
}
