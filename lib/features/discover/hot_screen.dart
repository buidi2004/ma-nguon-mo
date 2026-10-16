import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/movie_model.dart';
import '../../presentation/widgets/glass/glass_components.dart';
import '../../services/library_service.dart';
import '../../services/pocketbase_service.dart';
import '../../theme/app_theme.dart';

/// Item mô hình phim sắp ra mắt hiển thị trên feed
class _ComingSoonItem {
  final String id;
  final String title;
  final String? subtitle;
  final String backdropUrl;
  final String tierBadge;
  final Color tierColor;
  final int releaseYear;
  final String ageRating;
  final String category;
  final String statusText;
  final String description;
  final bool isExclusive;
  final String trailerUrl;

  const _ComingSoonItem({
    required this.id,
    required this.title,
    this.subtitle,
    required this.backdropUrl,
    required this.tierBadge,
    required this.tierColor,
    required this.releaseYear,
    required this.ageRating,
    required this.category,
    required this.statusText,
    required this.description,
    this.isExclusive = true,
    this.trailerUrl = '',
  });
}

class HotScreen extends StatefulWidget {
  const HotScreen({super.key});

  @override
  State<HotScreen> createState() => _HotScreenState();
}

class _HotScreenState extends State<HotScreen>
    with AutomaticKeepAliveClientMixin {
  final PocketBaseService _pbService = PocketBaseService.instance;
  final LibraryService _libService = LibraryService.instance;

  List<_ComingSoonItem> _items = [];

  @override
  bool get wantKeepAlive => true;

  /// Danh sách phim sắp ra mắt nguyên mẫu chuẩn theo thiết kế tham chiếu
  static const List<_ComingSoonItem> _curatedComingSoon = [
    _ComingSoonItem(
      id: 'kokuho_2026',
      title: 'QUỐC BẢO',
      subtitle: 'KOKUHO',
      backdropUrl: 'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=1200&auto=format&fit=crop&q=80',
      tierBadge: 'Siêu Việt',
      tierColor: Color(0xFF0288D1),
      releaseYear: 2026,
      ageRating: 'T16',
      category: 'Tâm lý',
      statusText: 'Phim sắp ra mắt',
      description: 'Dù sinh ra trong thế giới ngầm (yakuza), Kikuo lại được nghệ sĩ kabuki nhận về nuôi dưỡng. Cùng Shunsuke - con trai sư phụ, họ dành cả đời cho kabuki với bao vinh quang, thăng trầm và cả sự phản bội.',
      isExclusive: true,
    ),
    _ComingSoonItem(
      id: 'love_in_red_dust_2026',
      title: 'Hồng Trần Tứ Hợp',
      subtitle: 'Love in Red Dust',
      backdropUrl: 'https://images.unsplash.com/photo-1547891654-e66ed7ebb968?w=1200&auto=format&fit=crop&q=80',
      tierBadge: 'Cao Cấp',
      tierColor: Color(0xFF7B1FA2),
      releaseYear: 2026,
      ageRating: 'T13',
      category: 'Cổ trang',
      statusText: 'Phim sắp ra mắt',
      description: 'Mối tình khắc cốt ghi tâm giữa chàng thư sinh tài hoa và nàng tiểu thư quyền quý giữa bối cảnh cung đình loạn lạc, vượt qua định kiến gia tộc để tìm kiếm hạnh phúc đích thực.',
      isExclusive: true,
    ),
    _ComingSoonItem(
      id: 'tears_of_steel_2026',
      title: 'TEARS OF STEEL',
      subtitle: 'Tái Sinh Kỷ Nguyên Máy',
      backdropUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e0/Tears_of_Steel_poster.jpg/1200px-Tears_of_Steel_poster.jpg',
      tierBadge: 'Siêu Việt',
      tierColor: Color(0xFF0288D1),
      releaseYear: 2026,
      ageRating: 'T16',
      category: 'Viễn tưởng',
      statusText: 'Phim sắp ra mắt',
      description: 'Lấy bối cảnh tương lai hậu tận thế tại Amsterdam, một nhóm chiến binh và nhà khoa học cố gắng cứu vãn tương lai loài người khỏi sự thống trị của người máy tàn bạo.',
      isExclusive: true,
    ),
    _ComingSoonItem(
      id: 'sintel_dragon_2026',
      title: 'SINTEL',
      subtitle: 'Trái Tim Rồng',
      backdropUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/8/8f/Sintel_poster.jpg/1200px-Sintel_poster.jpg',
      tierBadge: 'Cao Cấp',
      tierColor: Color(0xFF7B1FA2),
      releaseYear: 2026,
      ageRating: 'T13',
      category: 'Hoạt hình',
      statusText: 'Phim sắp ra mắt',
      description: 'Cuộc hành trình đơn độc và đầy trắc trở của cô gái trẻ Sintel vượt qua sa mạc băng giá để tìm lại chú rồng con Scales bị bắt cóc.',
      isExclusive: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _items = List.of(_curatedComingSoon);
    _libService.addListener(_onLibraryChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadData();
    });
  }

  @override
  void dispose() {
    _libService.removeListener(_onLibraryChanged);
    super.dispose();
  }

  void _onLibraryChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadData() async {
    final allMovies = await _pbService.getMovies();
    if (!mounted) return;

    final List<_ComingSoonItem> merged = List.of(_curatedComingSoon);

    // Bổ sung các phim có cờ comingSoon hoặc phim mới từ backend PocketBase
    for (final MovieModel m in allMovies) {
      if (m.comingSoon || m.isNew || m.releaseYear >= 2024) {
        if (!merged.any((item) => item.id == m.id || item.title == m.title)) {
          merged.add(
            _ComingSoonItem(
              id: m.id,
              title: m.title.toUpperCase(),
              subtitle: m.category,
              backdropUrl: m.posterUrl,
              tierBadge: m.isFeatured ? 'Siêu Việt' : 'Cao Cấp',
              tierColor: m.isFeatured
                  ? const Color(0xFF0288D1)
                  : const Color(0xFF7B1FA2),
              releaseYear: m.releaseYear,
              ageRating: m.ageRating.isNotEmpty ? m.ageRating : 'T13',
              category: m.category,
              statusText: 'Phim sắp ra mắt',
              description: m.description,
              isExclusive: m.isFeatured,
              trailerUrl: m.trailerUrl,
            ),
          );
        }
      }
    }

    setState(() {
      _items = merged;
    });
  }

  void _playTrailerOrDetail(_ComingSoonItem item) {
    // Ưu tiên mở Trailer nếu phim có id hợp lệ trong router, hoặc trang chi tiết phim
    if (item.id.startsWith('mock_')) {
      context.push('/movie/${item.id}/trailer');
    } else {
      context.push('/movie/${item.id}');
    }
  }

  Future<void> _toggleMyList(_ComingSoonItem item) async {
    await _libService.toggleMyList(item.id);
    if (!mounted) return;
    final isAdded = _libService.isInMyList(item.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isAdded
              ? 'Đã thêm "${item.title}" vào Danh sách của tôi'
              : 'Đã xóa "${item.title}" khỏi Danh sách của tôi',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _shareMovie(_ComingSoonItem item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã sao chép liên kết chia sẻ phim: ${item.title}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Header Kính Mờ Pinned cố định ở đỉnh
          SliverAppBar(
            backgroundColor: AppColors.background.withValues(alpha: 0.82),
            pinned: true,
            elevation: 0,
            toolbarHeight: 56,
            surfaceTintColor: Colors.transparent,
            flexibleSpace: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.background.withValues(alpha: 0.72),
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.white.withValues(alpha: 0.08),
                        width: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            titleSpacing: 16,
            title: const Text(
              'Sắp ra mắt',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: GlassIconButton.circle(
                  size: 38,
                  iconSize: 20,
                  icon: Icons.notifications_none_rounded,
                  tooltip: 'Thông báo phim mới',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Thông báo nhắc lịch phim mới đã được kích hoạt',
                        ),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          // Danh sách feed phim sắp ra mắt
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final item = _items[index];
                return _buildComingSoonCard(item);
              }, childCount: _items.length),
            ),
          ),
        ],
      ),
    );
  }

  /// Thẻ phim sắp ra mắt chuẩn ảnh tham chiếu:
  /// - Backdrop 16:9 bo góc, badge ĐỘC QUYỀN tròn vàng góc trên trái
  /// - Hàng dưới: Logo/Tiêu đề in hoa bên trái + Nút Thêm vào DS & Chia sẻ bên phải
  /// - Thẻ phân loại Siêu Việt / Cao Cấp • Năm • Độ tuổi • Thể loại
  /// - Trạng thái: "Phim sắp ra mắt"
  /// - Tóm tắt kịch bản
  Widget _buildComingSoonCard(_ComingSoonItem item) {
    final isInList = _libService.isInMyList(item.id);

    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.only(bottom: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Ảnh Backdrop 16:9 với badge ĐỘC QUYỀN
            GestureDetector(
              onTap: () => _playTrailerOrDetail(item),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.12),
                            width: 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(13),
                          child: CachedNetworkImage(
                            imageUrl: item.backdropUrl,
                            fit: BoxFit.cover,
                            alignment: Alignment.center,
                            memCacheWidth: 480,
                            memCacheHeight: 270,
                            maxHeightDiskCache: 600,
                          placeholder: (_, _) =>
                              const ColoredBox(color: AppColors.surfaceLight),
                          errorWidget: (_, _, _) => Container(
                            color: AppColors.surfaceLight,
                            child: const Center(
                              child: Icon(
                                Icons.movie_outlined,
                                color: AppColors.textMuted,
                                size: 44,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Huy hiệu ĐỘC QUYỀN dạng tròn vàng góc trên bên trái
                  if (item.isExclusive)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFFFD700),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.40),
                              blurRadius: 4,
                              offset: const Offset(0, 1.5),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'ĐỘC',
                              style: TextStyle(
                                color: Color(0xFF0D1B2A),
                                fontSize: 7.5,
                                fontWeight: FontWeight.w900,
                                height: 1.0,
                                letterSpacing: 0.3,
                              ),
                            ),
                            Text(
                              'QUYỀN',
                              style: TextStyle(
                                color: Color(0xFF0D1B2A),
                                fontSize: 7.0,
                                fontWeight: FontWeight.w900,
                                height: 1.0,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // 2. Hàng Logo/Tiêu đề in đậm & Cụm nút hành động (Thêm vào DS, Chia sẻ)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo / Tiêu đề phim
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 23,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.1,
                        height: 1.15,
                      ),
                    ),
                    if (item.subtitle != null && item.subtitle!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        item.subtitle!,
                        style: const TextStyle(
                          color: Color(0xFFE0A96D),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.8,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Nút Thêm vào DS
              GlassActionButton.bookmark(
                isBookmarked: isInList,
                onPressed: () => _toggleMyList(item),
              ),

              const SizedBox(width: 6),

              // Nút Chia sẻ
              GlassActionButton.share(
                onPressed: () => _shareMovie(item),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // 3. Metadata: Capsule Phân hạng • Năm • Giới hạn tuổi • Thể loại
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 6,
            runSpacing: 4,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 7,
                  vertical: 2.5,
                ),
                decoration: BoxDecoration(
                  color: item.tierColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  item.tierBadge,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                ),
              ),
              const Text(
                '•',
                style: TextStyle(color: Color(0xFF757575), fontSize: 13),
              ),
              Text(
                '${item.releaseYear}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Text(
                '•',
                style: TextStyle(color: Color(0xFF757575), fontSize: 13),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.35),
                    width: 0.8,
                  ),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  item.ageRating,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Text(
                '•',
                style: TextStyle(color: Color(0xFF757575), fontSize: 13),
              ),
              Text(
                item.category,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Color(0xFFCCCCCC), fontSize: 13),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // 4. Trạng thái phát hành màu Cyan nổi bật
          Text(
            item.statusText,
            style: const TextStyle(
              color: Color(0xFF29B6F6),
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),

          const SizedBox(height: 6),

          // 5. Tóm tắt nội dung kịch bản
          Text(
            item.description,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFFB3B3B3),
              fontSize: 13,
              height: 1.42,
            ),
          ),
        ],
      ),
    ),
    );
  }
}
