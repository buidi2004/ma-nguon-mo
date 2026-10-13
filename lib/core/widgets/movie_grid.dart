import 'package:flutter/material.dart';

import '../../models/movie_model.dart';
import '../../widgets/movie_card.dart';
import 'state_view.dart';

class MovieGrid extends StatelessWidget {
  final List<MovieModel> movies;
  final bool isLoading;
  final String emptyTitle;
  final String emptyMessage;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final void Function(MovieModel movie)? onMovieTap;
  final bool showCategory;
  final bool showRanks;
  final double? Function(MovieModel movie)? progressGetter;
  final EdgeInsetsGeometry padding;

  const MovieGrid({
    super.key,
    required this.movies,
    this.isLoading = false,
    this.emptyTitle = 'Chưa có phim',
    this.emptyMessage =
        'Không tìm thấy bộ phim nào phù hợp trong danh mục này.',
    this.errorMessage,
    this.onRetry,
    this.onMovieTap,
    this.showCategory = false,
    this.showRanks = false,
    this.progressGetter,
    this.padding = const EdgeInsets.all(12),
  });

  int _calculateCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) return 2;
    if (width < 600) return 3;
    if (width < 900) return 4;
    return 6;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return StateView.loading();
    }

    if (errorMessage != null) {
      return StateView.error(message: errorMessage!, onRetry: onRetry);
    }

    if (movies.isEmpty) {
      return StateView.empty(title: emptyTitle, message: emptyMessage);
    }

    final crossAxisCount = _calculateCrossAxisCount(context);

    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: padding,
      itemCount: movies.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.68,
        crossAxisSpacing: 10,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        final movie = movies[index];
        final rank = showRanks ? index + 1 : null;
        final progress = progressGetter != null ? progressGetter!(movie) : null;

        return MovieCard(
          movie: movie,
          showCategory: showCategory,
          rank: rank,
          progressRatio: progress,
          onTap: onMovieTap != null ? () => onMovieTap!(movie) : null,
        );
      },
    );
  }
}
