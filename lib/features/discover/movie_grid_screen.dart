import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/movie_grid.dart';
import '../../models/movie_model.dart';
import '../../presentation/widgets/glass/glass_components.dart';
import '../../services/pocketbase_service.dart';
import '../../services/theme_service.dart';
import '../../theme/app_theme.dart';
import '../../waves_background.dart';

class MovieGridScreen extends StatefulWidget {
  final String title;
  final String? category;
  final String? rowKey;
  final String? year;
  final String? sort;

  const MovieGridScreen({
    super.key,
    required this.title,
    this.category,
    this.rowKey,
    this.year,
    this.sort,
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

  String? _buildFilter() {
    final filters = <String>[];
    if (widget.rowKey == 'new') {
      filters.add('is_new = true');
    }
    if (widget.year != null && widget.year != 'Tất cả') {
      if (widget.year == 'Trước 2020') {
        filters.add('release_year < 2020');
      } else {
        final yr = int.tryParse(widget.year!);
        if (yr != null) {
          filters.add('release_year = $yr');
        }
      }
    }
    if (filters.isEmpty) return null;
    return filters.join(' && ');
  }

  String _mapSort(String? sort) {
    switch (sort) {
      case 'Xem nhiều nhất':
        return '-rank,-created';
      case 'Thời lượng ngắn đến dài':
        return 'duration_minutes';
      case 'Tên phim A-Z':
        return 'title';
      case 'Mới nhất':
      default:
        return '-created';
    }
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
      category: (widget.category != null && widget.category != 'Tất cả')
          ? widget.category
          : null,
      filter: _buildFilter(),
      sort: _mapSort(widget.sort),
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
      category: (widget.category != null && widget.category != 'Tất cả')
          ? widget.category
          : null,
      filter: _buildFilter(),
      sort: _mapSort(widget.sort),
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
    final isBlue = ThemeService.instance.isWindowsBlue;
    return WavesBackground.wrapIfBlue(Scaffold(
      backgroundColor: isBlue ? Colors.transparent : AppColors.background,
      appBar: AppBar(
        leading: const GlassBackButton(),
        title: Text(
          widget.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
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
    ));
  }
}
