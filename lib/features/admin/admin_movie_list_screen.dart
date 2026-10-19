import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/state_view.dart';
import '../../models/movie_model.dart';
import '../../presentation/widgets/glass/glass_components.dart';
import '../../services/pocketbase_service.dart';
import '../../theme/app_theme.dart';
import 'admin_movie_form_screen.dart';
import 'services/admin_auth_service.dart';
import 'widgets/admin_movie_tile.dart';
import 'widgets/confirm_delete_dialog.dart';

/// Màn hình Quản lý Kho Phim (AdminMovieListScreen)
/// Trung tâm quản trị phim: tìm kiếm nhanh, lọc trạng thái, cập nhật tức thì (Optimistic update)
class AdminMovieListScreen extends StatefulWidget {
  const AdminMovieListScreen({super.key});

  @override
  State<AdminMovieListScreen> createState() => _AdminMovieListScreenState();
}

class _AdminMovieListScreenState extends State<AdminMovieListScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<MovieModel> _movies = [];
  List<MovieModel> _filteredMovies = [];
  bool _isLoading = true;
  String? _errorMessage;

  String _searchQuery = '';
  String _selectedFilter = 'Tất cả';

  static const List<String> _baseFilters = [
    'Tất cả',
    '⭐ Nổi bật',
    '🔥 Mới & Hot',
    '⏳ Sắp chiếu',
    'Hành động',
    'Hoạt hình',
    'Viễn tưởng',
    'Tâm lý',
    'Hài hước',
    'Kinh dị',
    'Phiêu lưu',
    'Tài liệu',
    'Khác',
  ];

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> get _allFilters {
    final filters = List<String>.from(_baseFilters);
    for (final m in _movies) {
      final cat = m.category.trim();
      if (cat.isNotEmpty && !filters.contains(cat)) {
        filters.add(cat);
      }
    }
    return filters;
  }

  Future<void> _loadMovies({bool forceRefresh = false}) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final list = await PocketBaseService.instance.getMovies(
        forceRefresh: forceRefresh,
      );
      if (!mounted) return;
      setState(() {
        _movies = List<MovieModel>.from(list);
        _isLoading = false;
        _applyFilters();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Không thể tải danh sách phim: $e';
      });
    }
  }

  void _applyFilters() {
    final query = _searchQuery.trim().toLowerCase();

    _filteredMovies = _movies.where((movie) {
      // 1. Lọc theo từ khóa tìm kiếm (tên phim, đạo diễn hoặc diễn viên)
      final matchesSearch =
          query.isEmpty ||
          movie.title.toLowerCase().contains(query) ||
          movie.director.toLowerCase().contains(query) ||
          movie.cast.toLowerCase().contains(query);

      if (!matchesSearch) return false;

      // 2. Lọc theo chip trạng thái hoặc thể loại
      switch (_selectedFilter) {
        case 'Tất cả':
          return true;
        case '⭐ Nổi bật':
          return movie.isFeatured;
        case '🔥 Mới & Hot':
          return movie.isNew;
        case '⏳ Sắp chiếu':
          return movie.comingSoon;
        default:
          return movie.category.trim().toLowerCase() ==
              _selectedFilter.trim().toLowerCase();
      }
    }).toList();
  }

  void _resetFilters() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _selectedFilter = 'Tất cả';
      _applyFilters();
    });
  }

  Future<void> _navigateToAddMovie() async {
    bool? shouldReload;
    try {
      shouldReload = await context.push<bool>('/admin/movies/create');
    } catch (_) {
      if (!mounted) return;
      shouldReload = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => const AdminMovieFormScreen()),
      );
    }

    if (shouldReload == true && mounted) {
      _loadMovies(forceRefresh: true);
    }
  }

  Future<void> _navigateToEdit(MovieModel movie) async {
    bool? shouldReload;
    try {
      shouldReload = await context.push<bool>(
        '/admin/movies/${movie.id}/edit',
        extra: movie,
      );
    } catch (_) {
      if (!mounted) return;
      shouldReload = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => AdminMovieFormScreen(movie: movie)),
      );
    }

    if (shouldReload == true && mounted) {
      _loadMovies(forceRefresh: true);
    }
  }

  Future<void> _handleDelete(MovieModel movie) async {
    final confirmed = await ConfirmDeleteDialog.show(
      context,
      movieTitle: movie.title,
      onConfirm: () async {
        final success = await PocketBaseService.instance.deleteMovie(movie.id);
        if (!success) {
          throw Exception('Không thể xóa phim khỏi hệ thống');
        }
      },
    );

    if (confirmed == true && mounted) {
      setState(() {
        _movies.removeWhere((m) => m.id == movie.id);
        _applyFilters();
      });

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã xóa phim "${movie.title}" thành công'),
          backgroundColor: AppColors.surface,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _handleToggleStatus(
    MovieModel movie, {
    bool? isFeatured,
    bool? isNew,
    bool? comingSoon,
  }) async {
    final index = _movies.indexWhere((m) => m.id == movie.id);
    if (index == -1) return;

    final oldMovie = _movies[index];
    final updatedMovie = MovieModel(
      id: oldMovie.id,
      title: oldMovie.title,
      description: oldMovie.description,
      category: oldMovie.category,
      posterUrl: oldMovie.posterUrl,
      videoUrl: oldMovie.videoUrl,
      trailerUrl: oldMovie.trailerUrl,
      releaseYear: oldMovie.releaseYear,
      durationMinutes: oldMovie.durationMinutes,
      ageRating: oldMovie.ageRating,
      director: oldMovie.director,
      cast: oldMovie.cast,
      rank: oldMovie.rank,
      isFeatured: isFeatured ?? oldMovie.isFeatured,
      isNew: isNew ?? oldMovie.isNew,
      comingSoon: comingSoon ?? oldMovie.comingSoon,
    );

    // 1. Optimistic update: cập nhật state ngay lập tức
    setState(() {
      _movies[index] = updatedMovie;
      _applyFilters();
    });

    String statusLabel = '';
    if (isFeatured != null) {
      statusLabel = isFeatured ? 'Nổi bật: BẬT' : 'Nổi bật: TẮT';
    } else if (isNew != null) {
      statusLabel = isNew ? 'Mới: BẬT' : 'Mới: TẮT';
    } else if (comingSoon != null) {
      statusLabel = comingSoon ? 'Sắp chiếu: BẬT' : 'Sắp chiếu: TẮT';
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã cập nhật "$statusLabel" cho "${movie.title}"'),
        backgroundColor: AppColors.surface,
        duration: const Duration(milliseconds: 1500),
      ),
    );

    // 2. Gửi yêu cầu cập nhật lên server
    try {
      final success = await PocketBaseService.instance.updateMovieStatus(
        movie.id,
        isFeatured: isFeatured,
        isNew: isNew,
        comingSoon: comingSoon,
      );

      if (!success && mounted) {
        // Rollback nếu thất bại
        setState(() {
          _movies[index] = oldMovie;
          _applyFilters();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể cập nhật trạng thái cho "${movie.title}"'),
            backgroundColor: AppColors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        // Rollback nếu có ngoại lệ
        setState(() {
          _movies[index] = oldMovie;
          _applyFilters();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi cập nhật: $e'),
            backgroundColor: AppColors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final titleText = _isLoading
        ? 'Quản lý nội dung phim'
        : 'Quản lý nội dung phim (${_filteredMovies.length} phim)';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: const GlassBackButton(fallbackRoute: '/home'),
        title: Text(
          titleText,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.speed_rounded, color: Color(0xFF22C55E)),
            tooltip: 'Giám sát Máy chủ VPS',
            onPressed: () => context.push('/admin/server'),
          ),
          IconButton(
            icon: const Icon(Icons.lock_outline_rounded, color: Colors.white70),
            tooltip: 'Khóa trang quản trị',
            onPressed: () {
              AdminAuthService.instance.logout();
              context.pop();
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton(
              onPressed: _navigateToAddMovie,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                elevation: 0,
                minimumSize: const Size(0, 36),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, size: 16, color: Colors.white),
                  SizedBox(width: 4),
                  Text(
                    '+ Thêm phim',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          const SizedBox(height: 6),
          _buildFilterChips(),
          const SizedBox(height: 10),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  /// Ô tìm kiếm phim tức thì có nút xóa nhanh (x)
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.divider, width: 0.8),
        ),
        child: TextField(
          controller: _searchController,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          cursorColor: AppColors.red,
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
              _applyFilters();
            });
          },
          decoration: InputDecoration(
            hintText: 'Tìm theo tên phim, đạo diễn...',
            hintStyle: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 13,
            ),
            prefixIcon: const Icon(
              Icons.search,
              color: AppColors.textMuted,
              size: 20,
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(
                      Icons.clear,
                      color: AppColors.textSecondary,
                      size: 18,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                        _applyFilters();
                      });
                    },
                    tooltip: 'Xóa tìm kiếm',
                  )
                : null,
            border: InputBorder.none,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
          ),
        ),
      ),
    );
  }

  /// Thanh cuộn ngang Filter Chips
  Widget _buildFilterChips() {
    final filters = _allFilters;
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = filter == _selectedFilter;
          return ChoiceChip(
            label: Text(
              filter,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
            selected: isSelected,
            onSelected: (selected) {
              if (selected) {
                setState(() {
                  _selectedFilter = filter;
                  _applyFilters();
                });
              }
            },
            selectedColor: AppColors.red,
            backgroundColor: AppColors.surface,
            showCheckmark: false,
            side: BorderSide(
              color: isSelected ? AppColors.red : AppColors.divider,
              width: 0.8,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          );
        },
      ),
    );
  }

  /// Phần hiển thị danh sách phim hoặc các StateView (Loading / Error / Empty)
  Widget _buildBody() {
    if (_isLoading) {
      return StateView.loading(message: 'Đang tải danh sách phim...');
    }

    if (_errorMessage != null) {
      return StateView.error(
        title: 'Lỗi tải danh sách',
        message: _errorMessage!,
        onRetry: () => _loadMovies(forceRefresh: true),
      );
    }

    if (_filteredMovies.isEmpty) {
      final isFiltered = _searchQuery.isNotEmpty || _selectedFilter != 'Tất cả';

      return RefreshIndicator(
        color: AppColors.red,
        backgroundColor: AppColors.surface,
        onRefresh: () => _loadMovies(forceRefresh: true),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 48),
            child: isFiltered
                ? StateView.empty(
                    title: 'Không tìm thấy phim phù hợp',
                    message:
                        'Thử thay đổi từ khóa tìm kiếm hoặc bộ lọc trạng thái.',
                    actionText: 'Xóa bộ lọc',
                    onAction: _resetFilters,
                  )
                : StateView.empty(
                    title: 'Kho phim trống',
                    message: 'Hiện chưa có bộ phim nào trong hệ thống. Hãy thêm phim mới ngay!',
                    actionText: '+ Thêm phim',
                    onAction: _navigateToAddMovie,
                  ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.red,
      backgroundColor: AppColors.surface,
      onRefresh: () => _loadMovies(forceRefresh: true),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 4, bottom: 24),
        itemCount: _filteredMovies.length,
        itemBuilder: (context, index) {
          final movie = _filteredMovies[index];
          return AdminMovieTile(
            movie: movie,
            onTap: () => _navigateToEdit(movie),
            onEdit: () => _navigateToEdit(movie),
            onDelete: () => _handleDelete(movie),
            onToggleFeatured: (val) =>
                _handleToggleStatus(movie, isFeatured: val),
            onToggleNew: (val) => _handleToggleStatus(movie, isNew: val),
            onToggleComingSoon: (val) =>
                _handleToggleStatus(movie, comingSoon: val),
          );
        },
      ),
    );
  }
}
