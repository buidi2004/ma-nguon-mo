import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/movie_model.dart';
import '../../presentation/widgets/glass/glass_components.dart';
import '../../services/pocketbase_service.dart';
import '../../services/theme_service.dart';
import '../../theme/app_theme.dart';
import '../../waves_background.dart';

class ReviewItem {
  final String author;
  final int rating;
  final String comment;
  final String timeAgo;

  ReviewItem({
    required this.author,
    required this.rating,
    required this.comment,
    required this.timeAgo,
  });
}

class ReviewsScreen extends StatefulWidget {
  final String movieId;

  const ReviewsScreen({super.key, required this.movieId});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  final _pbService = PocketBaseService.instance;
  MovieModel? _movie;
  bool _isLoading = true;

  final List<ReviewItem> _reviews = [
    ReviewItem(
      author: 'Trần Minh Quân',
      rating: 5,
      comment: 'Kỹ xảo 3D của Blender thực sự đỉnh cao! Cốt truyện ngắn gọn nhưng rất xúc động và nhân văn.',
      timeAgo: '2 giờ trước',
    ),
    ReviewItem(
      author: 'Lê Hoàng Nam',
      rating: 5,
      comment: 'Âm thanh vòm sống động, nhịp phim cuốn hút. Rất thích các phân cảnh hành động mạo hiểm.',
      timeAgo: '1 ngày trước',
    ),
    ReviewItem(
      author: 'Nguyễn Thị Mai',
      rating: 4,
      comment: 'Phim rất hay và phù hợp cho cả gia đình cùng xem vào dịp cuối tuần. Đánh giá 4 sao!',
      timeAgo: '3 ngày trước',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final movie = await _pbService.getMovieById(widget.movieId);
    if (!mounted) return;
    setState(() {
      _movie = movie;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = _movie?.title ?? 'Đánh giá phim';

    return WavesBackground.wrapIfBlue(Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: const GlassBackButton(),
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
      ),
      floatingActionButton: GlassFAB.extended(
        label: 'Viết đánh giá',
        icon: Icons.rate_review_rounded,
        backgroundColor: ThemeService.instance.primaryColor.withValues(
          alpha: 0.9,
        ),
        glowColor: ThemeService.instance.primaryColor.withValues(alpha: 0.5),
        onPressed: () async {
          final res = await context.push<ReviewItem>(
            '/movie/${widget.movieId}/reviews/new',
          );
          if (res != null) {
            setState(() {
              _reviews.insert(0, res);
            });
          }
        },
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  ThemeService.instance.primaryColor,
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Khung tổng quan điểm số
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          const Text(
                            '4.8',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Row(
                            children: List.generate(
                              5,
                              (i) => Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 16,
                              ),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '${_reviews.length} đánh giá',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 24),
                      Expanded(
                        child: Text(
                          'Đa số khán giả đánh giá tác phẩm này rất xuất sắc về mặt hình ảnh và kỹ xảo điện ảnh.',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24),
                Text(
                  'BÌNH LUẬN NỔI BẬT TỪ CỘNG ĐỒNG',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 12),

                ..._reviews.map((rev) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: ThemeService
                                  .instance
                                  .primaryColor
                                  .withValues(alpha: 0.2),
                              child: Text(
                                rev.author[0],
                                style: TextStyle(
                                  color: ThemeService.instance.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                rev.author,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            Text(
                              rev.timeAgo,
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: List.generate(
                            5,
                            (i) => Icon(
                              i < rev.rating ? Icons.star : Icons.star_border,
                              color: Colors.amber,
                              size: 15,
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          rev.comment,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 60),
              ],
            ),
    ));
  }
}
