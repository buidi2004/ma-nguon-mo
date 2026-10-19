import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/movie_model.dart';
import '../../presentation/widgets/glass/glass_components.dart';
import '../../services/library_service.dart';
import '../../services/pocketbase_service.dart';
import '../../services/theme_service.dart';
import '../../theme/app_theme.dart';

class MyListScreen extends StatefulWidget {
  const MyListScreen({super.key});

  @override
  State<MyListScreen> createState() => _MyListScreenState();
}

class _MyListScreenState extends State<MyListScreen> {
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
    final ids = _libService.myListIds;
    if (!mounted) return;
    setState(() {
      _movies = all.where((m) => ids.contains(m.id)).toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _libService,
      builder: (context, _) {
        final ids = _libService.myListIds;
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            leading: const GlassBackButton(),
            title: const Text(
              'Danh sách của tôi',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
            actions: [
              if (ids.isNotEmpty && _movies.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: GlassButton.capsule(
                    text: 'Xóa tất cả',
                    icon: Icons.delete_outline_rounded,
                    style: GlassButtonStyle.neutralDark,
                    height: 34,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    onPressed: () {
                      showGlassDialog(
                        context: context,
                        title: 'Xóa toàn bộ danh sách?',
                        child: const Text(
                          'Bạn có chắc chắn muốn xóa toàn bộ các bộ phim đã lưu trong danh sách của bạn?',
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
                              for (final id in List<String>.from(ids)) {
                                _libService.toggleMyList(id);
                              }
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
              ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      ThemeService.instance.primaryColor,
                    ),
                  ),
                )
              : _movies.isEmpty || ids.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.bookmark_border,
                          size: 64,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Danh sách của bạn chưa có phim nào',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Hãy bấm nút "Danh sách" ở trang chi tiết bất kỳ bộ phim nào để lưu lại xem sau.',
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
              : Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 6,
                        ),
                        child: Text(
                          'Đã lưu ${_movies.where((m) => ids.contains(m.id)).length} bộ phim',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Builder(
                        builder: (context) {
                          final savedMovies = _movies
                              .where((m) => ids.contains(m.id))
                              .toList();
                          return Expanded(
                            child: GridView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: savedMovies.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    childAspectRatio: 2 / 3,
                                    crossAxisSpacing: 6,
                                    mainAxisSpacing: 6,
                                  ),
                              itemBuilder: (context, index) {
                                final movie = savedMovies[index];

                                return GestureDetector(
                                  onTap: () =>
                                      context.push('/movie/${movie.id}'),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: CachedNetworkImage(
                                          imageUrl: movie.posterUrl,
                                          fit: BoxFit.cover,
                                          memCacheWidth: 350,
                                          memCacheHeight: 525,
                                          maxHeightDiskCache: 600,
                                          placeholder: (_, _) =>
                                              const ColoredBox(
                                                color: AppColors.surface,
                                              ),
                                        ),
                                      ),
                                      // Nút xóa nhanh góc trên - Kính mờ quang học
                                      Positioned(
                                        top: 4,
                                        right: 4,
                                        child: GlassIconButton.circle(
                                          size: 28,
                                          iconSize: 14,
                                          icon: Icons.close_rounded,
                                          onPressed: () => _libService
                                              .toggleMyList(movie.id),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}
