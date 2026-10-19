import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../models/cinema/cinema_models.dart';
import '../../presentation/widgets/glass/glass_components.dart';
import '../../services/cinema/cinema_service.dart';

/// S50: Tin Tức & Blog Điện Ảnh Rạp (Cinema News & Blog Screen)
/// Nền trắng chuẩn điện ảnh phong cách CineFlix Cinema
class CinemaNewsScreen extends StatefulWidget {
  const CinemaNewsScreen({super.key});

  @override
  State<CinemaNewsScreen> createState() => _CinemaNewsScreenState();
}

class _CinemaNewsScreenState extends State<CinemaNewsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const blueColor = Color(0xFF0284C7);
    final cinemaService = CinemaService.instance;

    final reviewArticles = cinemaService.articles
        .where((a) => a.category == 'review')
        .toList();

    final blogArticles = cinemaService.articles
        .where((a) => a.category == 'blog')
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: const GlassBackButton(fallbackRoute: '/cinema'),
        title: const Text(
          'Tin Tức & Đánh Giá Rạp',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: blueColor,
          indicatorWeight: 3,
          labelColor: blueColor,
          unselectedLabelColor: const Color(0xFF64748B),
          labelStyle:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
          tabs: const [
            Tab(text: 'Bình luận phim'),
            Tab(text: 'Blog điện ảnh'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Bình luận phim (Khớp Screenshot 5)
          _buildArticleList(reviewArticles),

          // Tab 2: Blog điện ảnh
          _buildArticleList(
              blogArticles.isNotEmpty ? blogArticles : reviewArticles),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        mini: true,
        backgroundColor: Colors.white,
        elevation: 4,
        onPressed: () {
          HapticFeedback.lightImpact();
          setState(() {});
        },
        child: const Icon(Icons.sync_rounded, color: Color(0xFF0284C7)),
      ),
    );
  }

  Widget _buildArticleList(List<CinemaArticleModel> articles) {
    if (articles.isEmpty) {
      return const Center(
        child: Text(
          'Chưa có bài viết trong mục này',
          style: TextStyle(color: Color(0xFF64748B)),
        ),
      );
    }

    final featured = articles.first;
    final others = articles.skip(1).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. BÀI VIẾT NỔI BẬT NHẤT (Khớp Screenshot 5: Trại Buôn Người)
          InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              context.push(
                '/cinema/news/${featured.id}',
                extra: featured,
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      featured.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  featured.title,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 8),

                // Nút Thích & Lượt xem (Khớp Screenshot 5: [👍 Thích] [👁 5172])
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1877F2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.thumb_up_rounded,
                              color: Colors.white, size: 12),
                          SizedBox(width: 4),
                          Text(
                            'Thích',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.remove_red_eye_rounded,
                              color: Color(0xFF64748B), size: 13),
                          const SizedBox(width: 4),
                          Text(
                            '${featured.likesCount}',
                            style: const TextStyle(
                              color: Color(0xFF475569),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          Divider(color: Colors.grey.shade200, height: 1),
          const SizedBox(height: 16),

          // 2. DANH SÁCH BÀI VIẾT BÊN DƯỚI (Khớp Screenshot 5)
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: others.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final art = others[index];

              return InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.push(
                    '/cinema/news/${art.id}',
                    extra: art,
                  );
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ảnh thumbnail bên trái
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 120,
                        height: 75,
                        child: Image.network(
                          art.imageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Tiêu đề & Nút Thích bên phải
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            art.title,
                            style: const TextStyle(
                              color: Color(0xFF0F172A),
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1877F2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.thumb_up_rounded,
                                        color: Colors.white, size: 10),
                                    SizedBox(width: 3),
                                    Text(
                                      'Thích',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(4),
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.remove_red_eye_rounded,
                                        color: Color(0xFF64748B), size: 11),
                                    const SizedBox(width: 3),
                                    Text(
                                      '${art.likesCount}',
                                      style: const TextStyle(
                                        color: Color(0xFF475569),
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
