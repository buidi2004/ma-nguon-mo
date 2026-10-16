import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/state_view.dart';
import '../../models/movie_model.dart';
import '../../presentation/widgets/glass/glass_components.dart';
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
          ? StateView.loading(message: 'Đang tải danh sách tập...')
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Season Selector Bar
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
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
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GlassSegmentedControl<int>(
                          height: 38,
                          items: const [
                            GlassSegmentItem<int>(
                              value: 1,
                              label: 'Mùa 1',
                              badgeCount: 4,
                            ),
                            GlassSegmentItem<int>(
                              value: 2,
                              label: 'Mùa 2',
                            ),
                          ],
                          selectedValue: _selectedSeason,
                          onValueChanged: (val) {
                            setState(() => _selectedSeason = val);
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Episode List
                Expanded(
                  child: ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                    itemCount: _episodes.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
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
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Thumbnail with Play overlay
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: CachedNetworkImage(
                                          imageUrl: ep.thumbnailUrl,
                                          width: 96,
                                          height: 56,
                                          fit: BoxFit.cover,
                                          memCacheWidth: 220,
                                          memCacheHeight: 130,
                                          maxHeightDiskCache: 250,
                                        ),
                                      ),
                                      IgnorePointer(
                                        child: GlassIconButton.circle(
                                          size: 30,
                                          iconSize: 16,
                                          icon: Icons.play_arrow_rounded,
                                          onPressed: () {},
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 10),

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
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
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
                                  const SizedBox(width: 6),
                                  GlassIconButton.circle(
                                    size: 34,
                                    iconSize: 18,
                                    icon: Icons.download_for_offline_outlined,
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
