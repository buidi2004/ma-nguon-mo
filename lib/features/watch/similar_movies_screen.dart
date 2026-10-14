import 'package:flutter/material.dart';

import '../../core/widgets/movie_grid.dart';
import '../../core/widgets/state_view.dart';
import '../../models/movie_model.dart';
import '../../services/pocketbase_service.dart';
import '../../theme/app_theme.dart';

class SimilarMoviesScreen extends StatefulWidget {
  final String movieId;

  const SimilarMoviesScreen({super.key, required this.movieId});

  @override
  State<SimilarMoviesScreen> createState() => _SimilarMoviesScreenState();
}

class _SimilarMoviesScreenState extends State<SimilarMoviesScreen> {
  final _pbService = PocketBaseService.instance;
  MovieModel? _currentMovie;
  List<MovieModel> _similarMovies = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSimilar();
  }

  Future<void> _loadSimilar() async {
    setState(() => _isLoading = true);
    final movie = await _pbService.getMovieById(widget.movieId);
    final all = await _pbService.getMovies();

    if (!mounted) return;
    if (movie != null) {
      final matches = all
          .where((m) => m.id != movie.id && m.category == movie.category)
          .toList();
      _similarMovies = matches.isNotEmpty
          ? matches
          : all.where((m) => m.id != movie.id).toList();
    } else {
      _similarMovies = all;
    }

    setState(() {
      _currentMovie = movie;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          _currentMovie != null
              ? 'Tương tự: ${_currentMovie!.title}'
              : 'Phim tương tự',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
      ),
      body: _isLoading
          ? StateView.loading(message: 'Đang tìm kiếm phim tương tự...')
          : MovieGrid(
              movies: _similarMovies,
              showCategory: true,
              emptyTitle: 'Chưa có phim tương tự',
              emptyMessage:
                  'Hệ thống đang cập nhật thêm các tựa phim cùng thể loại.',
            ),
    );
  }
}
