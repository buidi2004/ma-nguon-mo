import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../models/cinema/cinema_models.dart';
import '../../presentation/widgets/glass/glass_components.dart';
import '../../services/cinema/cinema_service.dart';
import '../../services/theme_service.dart';
import '../../waves_background.dart';

/// S51: Chi Tiết Bài Viết Review & Blog Điện Ảnh (Cinema Article Detail Screen) — Nền Trắng
class CinemaArticleDetailScreen extends StatefulWidget {
  final CinemaArticleModel? article;
  final String articleId;

  const CinemaArticleDetailScreen({
    super.key,
    this.article,
    required this.articleId,
  });

  @override
  State<CinemaArticleDetailScreen> createState() =>
      _CinemaArticleDetailScreenState();
}

class _CinemaArticleDetailScreenState extends State<CinemaArticleDetailScreen> {
  late CinemaArticleModel _currentArticle;
  bool _isLiked = false;
  late int _likesCount;

  @override
  void initState() {
    super.initState();
    _currentArticle =
        widget.article ??
        CinemaService.instance.articles.firstWhere(
          (a) => a.id == widget.articleId,
          orElse: () => CinemaService.instance.articles.first,
        );
    _likesCount = _currentArticle.likesCount;
  }

  void _toggleLike() {
    HapticFeedback.lightImpact();
    setState(() {
      _isLiked = !_isLiked;
      _likesCount += _isLiked ? 1 : -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WavesBackground.wrapIfBlue(
      Scaffold(
      backgroundColor: ThemeService.instance.isWindowsBlue ? Colors.transparent : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: const GlassBackButton(fallbackRoute: '/cinema/news'),
        title: Text(
          _currentArticle.category == 'review'
              ? 'Bình Luận Phim'
              : 'Blog Điện Ảnh',
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Color(0xFF0369A1)),
            tooltip: 'Chia sẻ bài viết',
            onPressed: () {
              HapticFeedback.lightImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã sao chép liên kết bài viết!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tiêu đề bài viết
            Text(
              _currentArticle.title,
              style: TextStyle(
                color: ThemeService.instance.isWindowsBlue
                    ? Colors.white
                    : const Color(0xFF0F172A),
                fontSize: 20,
                fontWeight: FontWeight.w900,
                height: 1.35,
                letterSpacing: -0.4,
              ),
            ),

            const SizedBox(height: 10),

            // Tác giả & Ngày đăng & Lượt xem
            Row(
              children: [
                const CircleAvatar(
                  radius: 12,
                  backgroundColor: Color(0xFF0369A1),
                  child: Icon(Icons.person, color: Colors.white, size: 14),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _currentArticle.author,
                    style: TextStyle(
                      color: ThemeService.instance.isWindowsBlue
                          ? const Color(0xFFE2F1FF)
                          : const Color(0xFF334155),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '${_currentArticle.viewsCount} lượt xem',
                  style: TextStyle(
                    color: ThemeService.instance.isWindowsBlue
                        ? const Color(0xFFD6EBFC)
                        : const Color(0xFF64748B),
                    fontSize: 12,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Ảnh bìa bài viết
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: CachedNetworkImage(
                  imageUrl: _currentArticle.imageUrl,
                  fit: BoxFit.cover,
                  memCacheWidth: 720,
                  maxWidthDiskCache: 1080,
                  placeholder: (ctx, url) => Container(color: const Color(0xFF1E293B)),
                  errorWidget: (ctx, url, err) => Container(
                    color: const Color(0xFF1E293B),
                    child: const Center(
                      child: Icon(
                        Icons.article_rounded,
                        color: Colors.white38,
                        size: 40,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Đoạn trích dẫn tóm tắt
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: const Border(
                  left: BorderSide(color: Color(0xFF0369A1), width: 4),
                ),
              ),
              child: Text(
                _currentArticle.excerpt,
                style: const TextStyle(
                  color: Color(0xFF334155),
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  height: 1.45,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Nội dung chi tiết bài viết
            Text(
              _currentArticle.content,
              style: TextStyle(
                color: ThemeService.instance.isWindowsBlue
                    ? Colors.white
                    : const Color(0xFF1E293B),
                fontSize: 15,
                height: 1.65,
              ),
            ),

            const SizedBox(height: 24),
            Divider(
              color: ThemeService.instance.isWindowsBlue
                  ? Colors.white24
                  : Colors.grey.shade200,
              height: 1,
            ),
            const SizedBox(height: 16),

            // Nút Thích bài viết
            Row(
              children: [
                InkWell(
                  onTap: _toggleLike,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _isLiked
                          ? const Color(0xFF1877F2)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _isLiked
                            ? const Color(0xFF1877F2)
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.thumb_up_rounded,
                          color: _isLiked
                              ? Colors.white
                              : const Color(0xFF64748B),
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _isLiked
                              ? 'Đã thích ($_likesCount)'
                              : 'Thích ($_likesCount)',
                          style: TextStyle(
                            color: _isLiked
                                ? Colors.white
                                : const Color(0xFF334155),
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
      // THANH ĐẶT VÉ PHIM NÀY NGAY DƯỚI ĐÁY
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 46,
          child: ElevatedButton.icon(
            icon: const Icon(
              Icons.confirmation_num_rounded,
              color: Colors.white,
              size: 20,
            ),
            label: const Text(
              'ĐẶT VÉ PHIM NÀY NGAY',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              final movieId =
                  _currentArticle.relatedMovieId ??
                  CinemaService.instance.movies.first.id;
              context.push('/cinema/movie/$movieId');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC2410C),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
          ),
        ),
      ),
    ),
    );
  }
}
