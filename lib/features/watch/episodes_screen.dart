import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/state_view.dart';
import '../../models/movie_model.dart';
import '../../services/pocketbase_service.dart';
import '../../theme/app_theme.dart';

class EpisodeItem {
  final int number;
  final String title;
  final String duration;
  final String description;
  final String thumbnailUrl;

  const EpisodeItem({
    required this.number,
    required this.title,
    required this.duration,
    required this.description,
    required this.thumbnailUrl,
  });
}

class EpisodesScreen extends StatefulWidget {
  final String movieId;

  const EpisodesScreen({super.key, required this.movieId});

  @override
  State<EpisodesScreen> createState() => _EpisodesScreenState();
}

class _EpisodesScreenState extends State<EpisodesScreen> {
  final _pbService = PocketBaseService.instance;
  MovieModel? _movie;
  bool _isLoading = true;
  int _selectedSeason = 1;

  late final List<EpisodeItem> _episodes;

  @override
  void initState() {
    super.initState();
    _loadMovie();
  }

  Future<void> _loadMovie() async {
    setState(() => _isLoading = true);
    final movie = await _pbService.getMovieById(widget.movieId);
    if (!mounted) return;

    final baseThumb =
        movie?.posterUrl ??
        'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c5/Big_buck_bunny_poster_big.jpg/600px-Big_buck_bunny_poster_big.jpg';

    _episodes = [
      EpisodeItem(
        number: 1,
        title: 'Khởi đầu mới',
        duration: '42 phút',
        description: 'Những biến cố bất ngờ xảy ra khi nhân vật chính bước vào cuộc hành trình đầy hiểm nguy và bí ẩn chưa từng có.',
        thumbnailUrl: baseThumb,
      ),
      EpisodeItem(
        number: 2,
        title: 'Lời nguyền bóng tối',
        duration: '48 phút',
        description: 'Cuộc chạm trán nảy lửa với những kẻ thù giấu mặt. Một bí mật kinh hoàng trong quá khứ dần được hé lộ.',
        thumbnailUrl: baseThumb,
      ),
      EpisodeItem(
        number: 3,
        title: 'Thử thách khắc nghiệt',
        duration: '45 phút',
        description: 'Đứng trước bờ vực thất bại, tinh thần đồng đội và ý chí quật cường trở thành chiếc chìa khóa duy nhất.',
        thumbnailUrl: baseThumb,
      ),
      EpisodeItem(
        number: 4,
        title: 'Cuộc chiến sinh tử',
        duration: '52 phút',
        description: 'Trận đối đầu định mệnh phân định thắng bại và mở ra một kỷ nguyên hoàn toàn mới cho toàn thể nhân loại.',
        thumbnailUrl: baseThumb,
      ),
    ];

    setState(() {
      _movie = movie;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          _movie != null ? 'Tập phim: ${_movie!.title}' : 'Danh sách tập',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
      ),
      body: _isLoading
          ? StateView.loading(message: 'Đang tải danh sách tập...')
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Season Selector Bar
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    border: Border(bottom: BorderSide(color: Colors.white10)),
                  ),
                  child: Row(
                    children: [
                      const Text(
                        'Chọn mùa: ',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: _selectedSeason,
                            dropdownColor: AppColors.surface,
                            icon: const Icon(
                              Icons.arrow_drop_down,
                              color: Colors.white,
                            ),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 1,
                                child: Text('Mùa 1 (4 tập)'),
                              ),
                              DropdownMenuItem(
                                value: 2,
                                child: Text('Mùa 2 (Sắp chiếu)'),
                              ),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _selectedSeason = val);
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Episode List
                Expanded(
                  child: ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: _episodes.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final ep = _episodes[index];

                      return InkWell(
                        onTap: () {
                          if (_movie != null) {
                            context.push('/watch/${_movie!.id}');
                          }
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Thumbnail with Play overlay
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: CachedNetworkImage(
                                          imageUrl: ep.thumbnailUrl,
                                          width: 110,
                                          height: 65,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: Colors.black.withAlpha(160),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.play_arrow,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 14),

                                  // Episode Title & Duration
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Tập ${ep.number}. ${ep.title}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          ep.duration,
                                          style: const TextStyle(
                                            color: AppColors.textMuted,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.download_for_offline_outlined,
                                      color: Colors.white60,
                                    ),
                                    onPressed: () {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Đang tải tập ${ep.number} để xem offline...',
                                          ),
                                          duration: const Duration(seconds: 1),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                ep.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
