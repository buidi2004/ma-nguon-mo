import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/movie_grid.dart';
import '../../models/movie_model.dart';
import '../../services/pocketbase_service.dart';
import '../../theme/app_theme.dart';

class SearchScreen extends StatefulWidget {
  final String initialQuery;

  const SearchScreen({super.key, this.initialQuery = ''});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final PocketBaseService _pbService = PocketBaseService.instance;
  late final TextEditingController _searchController;
  List<MovieModel> _allMovies = [];
  List<MovieModel> _searchResults = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery);
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final movies = await _pbService.getMovies();
    if (!mounted) return;
    setState(() {
      _allMovies = movies;
      _isLoading = false;
    });
    if (_searchController.text.isNotEmpty) {
      _onSearchChanged(_searchController.text);
    }
  }

  void _onSearchChanged(String query) {
    final lower = query.trim().toLowerCase();
    setState(() {
      if (lower.isEmpty) {
        _searchResults = [];
      } else {
        _searchResults = _allMovies.where((m) {
          return m.title.toLowerCase().contains(lower) ||
              m.description.toLowerCase().contains(lower) ||
              m.category.toLowerCase().contains(lower) ||
              m.director.toLowerCase().contains(lower) ||
              m.cast.toLowerCase().contains(lower);
        }).toList();
      }
    });
  }

  void _playMovie(MovieModel movie) {
    context.push('/watch/${movie.id}');
  }

  @override
  Widget build(BuildContext context) {
    final isSearching = _searchController.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        titleSpacing: 12,
        backgroundColor: AppColors.background,
        title: Container(
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(4),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Tìm kiếm phim, diễn viên, thể loại...',
              hintStyle: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 13,
              ),
              border: InputBorder.none,
              prefixIcon: const Icon(
                Icons.search,
                color: AppColors.textMuted,
                size: 20,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(
                        Icons.clear,
                        color: Colors.white70,
                        size: 18,
                      ),
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white70),
            tooltip: 'Bộ lọc nâng cao (S12)',
            onPressed: () => context.push('/search/filter'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.red),
              ),
            )
          : isSearching
          ? _buildSearchResultsGrid()
          : _buildTrendingList(),
    );
  }

  /// Khi chưa gõ: Danh sách dọc "Phim đang thịnh hành" chuẩn Netflix (ảnh 16:9, tên giữa, nút play tròn bên phải)
  Widget _buildTrendingList() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Text(
            'Phim đang thịnh hành',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ..._allMovies.map((movie) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(4),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(4),
              onTap: () => context.push('/movie/${movie.id}'),
              child: Row(
                children: [
                  // Ảnh thumbnail 16:9
                  ClipRRect(
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(4),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: movie.posterUrl,
                      width: 110,
                      height: 68,
                      fit: BoxFit.cover,
                      placeholder: (_, _) =>
                          const ColoredBox(color: AppColors.surfaceLight),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Tên phim và thông tin
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          movie.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${movie.category} • ${movie.releaseYear}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Nút Play tròn bên phải
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white60, width: 1.2),
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    onPressed: () => _playMovie(movie),
                  ),
                  const SizedBox(width: 6),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  /// Khi gõ: Lưới poster kết quả tìm kiếm thích ứng (S11)
  Widget _buildSearchResultsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Text(
            'Kết quả tìm kiếm (${_searchResults.length})',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: MovieGrid(
            movies: _searchResults,
            showCategory: true,
            emptyTitle: 'Không tìm thấy phim phù hợp',
            emptyMessage:
                'Hãy thử tìm kiếm với tên phim, đạo diễn hoặc thể loại khác.',
          ),
        ),
      ],
    );
  }
}
