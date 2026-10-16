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
  bool _isLoadingMore = false;
  int _currentPage = 1;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  Future<void> _loadMovies() async {
    setState(() {
      _isLoading = true;
      _currentPage = 1;
      _hasMore = true;
    });

    if (widget.rowKey == 'top10') {
      final top10 = await _pbService.getTop10Movies();
      if (!mounted) return;
      setState(() {
        _movies = top10;
        _isLoading = false;
        _hasMore = false;
      });
      return;
    }

    final pagedResult = await _pbService.getMoviesPaged(
      page: 1,
      perPage: 20,
      category: (widget.category != null && widget.category != 'Tất cả') ? widget.category : null,
      filter: widget.rowKey == 'new' ? 'is_new = true' : null,
    );

    if (!mounted) return;
    setState(() {
      _movies = pagedResult.items;
      _hasMore = pagedResult.hasMore;
      _isLoading = false;
    });
  }

  Future<void> _loadMore() async {
    if (_isLoading || _isLoadingMore || !_hasMore) return;

    setState(() => _isLoadingMore = true);
    final nextPage = _currentPage + 1;

    final pagedResult = await _pbService.getMoviesPaged(
      page: nextPage,
      perPage: 20,
      category: (widget.category != null && widget.category != 'Tất cả') ? widget.category : null,
      filter: widget.rowKey == 'new' ? 'is_new = true' : null,
    );

    if (!mounted) return;
    setState(() {
      _currentPage = nextPage;
      _movies.addAll(pagedResult.items);
      _hasMore = pagedResult.hasMore;
      _isLoadingMore = false;
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
        isLoadingMore: _isLoadingMore,
        onLoadMore: _loadMore,
        showCategory: true,
        emptyTitle: 'Chưa có phim trong "${widget.title}"',
        emptyMessage: 'Nội dung đang được tuyển chọn và cập nhật thường xuyên.',
      ),
    );
  }
}
