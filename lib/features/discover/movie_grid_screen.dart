import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/movie_grid.dart';
import '../../models/movie_model.dart';
import '../../services/pocketbase_service.dart';
import '../../theme/app_theme.dart';

class MovieGridScreen extends StatefulWidget {
  final String title;
  final String? category;
  final String? rowKey;

  const MovieGridScreen({
    super.key,
    required this.title,
    this.category,
    this.rowKey,
  });

  @override
  State<MovieGridScreen> createState() => _MovieGridScreenState();
}

class _MovieGridScreenState extends State<MovieGridScreen> {
  final PocketBaseService _pbService = PocketBaseService.instance;
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
    List<MovieModel> filtered = all;

    if (widget.category != null &&
        widget.category!.isNotEmpty &&
        widget.category != 'Tất cả') {
      filtered = all
          .where(
            (m) => m.category.toLowerCase().contains(
              widget.category!.toLowerCase(),
            ),
          )
          .toList();
    } else if (widget.rowKey != null) {
      if (widget.rowKey == 'top10') {
        filtered = all.take(10).toList();
      } else if (widget.rowKey == 'new') {
        filtered = all.where((m) => m.isNew).toList();
        if (filtered.isEmpty) filtered = all.take(6).toList();
      }
    }

    if (!mounted) return;
    setState(() {
      _movies = filtered;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/search'),
          ),
        ],
      ),
      body: MovieGrid(
        movies: _movies,
        isLoading: _isLoading,
        showCategory: true,
        emptyTitle: 'Chưa có phim trong "${widget.title}"',
        emptyMessage: 'Nội dung đang được tuyển chọn và cập nhật thường xuyên.',
      ),
    );
  }
}
