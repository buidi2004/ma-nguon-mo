import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../models/cinema/cinema_models.dart';
import '../../presentation/widgets/cinema/cinema_location_picker_sheet.dart';
import '../../presentation/widgets/glass/glass_components.dart';
import '../../services/cinema/cinema_service.dart';
import '../../services/theme_service.dart';
import '../../waves_background.dart';

/// S43: Khám Phá Phim Rạp (Cinema Hub Screen) — Phong cách Nền Trắng Rạp Chuẩn CineFlix Cinema
class CinemaHubScreen extends StatefulWidget {
  const CinemaHubScreen({super.key});

  @override
  State<CinemaHubScreen> createState() => _CinemaHubScreenState();
}

class _CinemaHubScreenState extends State<CinemaHubScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final PageController _bannerController;
  int _activeBannerIndex = 0;
  Timer? _bannerTimer;
  bool _showTopPromoBanner = true;
  String _selectedCountryFilter = 'all'; // 'all', 'Việt Nam', 'Thái Lan'

  final List<Map<String, String>> _promoBanners = [
    {
      'tag': 'CINEFLIX PREMIER AN LẠC',
      'title': 'ƯU ĐÃI HẤP DẪN ĐỘC QUYỀN TẠI CINEFLIX',
      'subtitle': 'MIỄN PHÍ 01 THÙNG NƯỚC NGỌT KHI XEM ĐỦ 3 PHIM VIỆT',
      'image':
          'https://images.unsplash.com/photo-1517604931442-7e0c8ed2963c?w=1000',
    },
    {
      'tag': 'ĐIỆN ẢNH VIỆT 2026',
      'title': 'ĐAM MÊ ĐIỆN ẢNH — BỨT TOP RINH QUÀ SYM',
      'subtitle': 'Xem phim bom tấn rinh ngay xe tay ga và hàng ngàn voucher',
      'image':
          'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?w=1000',
    },
    {
      'tag': 'SUẤT CHIẾU SỚM ĐẶC BIỆT',
      'title': 'Án Mạng Xém Hoàn Hảo — Khởi Chiếu Toàn Quốc',
      'subtitle': 'Đặt vé ngay hôm nay để nhận quà tặng giới hạn',
      'image':
          'https://images.unsplash.com/photo-1536440136628-849c177e76a1?w=1000',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _bannerController = PageController();

    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted || !_bannerController.hasClients) return;
      final nextIndex = (_activeBannerIndex + 1) % _promoBanners.length;
      _bannerController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _openLocationPicker() async {
    await CinemaLocationPickerSheet.show(context);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final cinemaService = CinemaService.instance;
    const blueColor = Color(
      0xFF0369A1,
    ); // Xanh CineFlix, tương phản tốt trên nền trắng

    return WavesBackground.wrapIfBlue(
      Scaffold(
      backgroundColor: ThemeService.instance.isWindowsBlue ? Colors.transparent : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 1. BANNER TRÊN CÙNG: "Tải Ứng Dụng CineFlix Cinema"
            if (_showTopPromoBanner)
              Container(
                height: 52,
                color: const Color(0xFF1E3A8A),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    // Icon app vuông
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.theaters_rounded,
                          color: Color(0xFF0284C7),
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Tiêu đề banner
                    const Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tải Ứng Dụng CineFlix Cinema',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Tra cứu lịch chiếu và đặt vé siêu nhanh',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Nút Mở
                    InkWell(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Bạn đang trải nghiệm trực tiếp trên CineFlix Cinema!',
                            ),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white70),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          'Mở',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Nút đóng
                    IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white60,
                        size: 18,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () =>
                          setState(() => _showTopPromoBanner = false),
                    ),
                  ],
                ),
              ),

            // 2. HEADER: Nút Back + Logo CineFlix Cinema + Nút Mua Vé + Menu
            Container(
              height: 58,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade200, width: 1),
                ),
              ),
              child: Row(
                children: [
                  // Nút quay lại GlassBackButton chuẩn
                  const GlassBackButton(fallbackRoute: '/'),
                  const SizedBox(width: 8),

                  // Logo CineFlix Cinema phong cách thương hiệu
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: blueColor, width: 2),
                        ),
                        child: const Icon(
                          Icons.theaters_rounded,
                          color: blueColor,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: const TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Cine',
                                  style: TextStyle(
                                    color: Color(0xFF0284C7),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Flix',
                                  style: TextStyle(
                                    color: Color(0xFFF97316),
                                    fontSize: 16,
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

                  const Spacer(),

                  // Nút Mua Vé (Hình vé răng cưa màu cam, khớp Screenshot 1)
                  InkWell(
                    onTap: () {
                      final firstMovie = cinemaService.movies.first;
                      context.push('/cinema/movie/${firstMovie.id}');
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFB923C), Color(0xFFEA580C)],
                        ),
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            color: Colors.white,
                            size: 15,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Mua Vé',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Nút Tin tức / Blog rạp
                  IconButton(
                    icon: const Icon(
                      Icons.newspaper_rounded,
                      color: Color(0xFF334155),
                    ),
                    tooltip: 'Bình luận & Blog điện ảnh',
                    onPressed: () => context.push('/cinema/news'),
                  ),

                  // Nút Vé của tôi
                  IconButton(
                    icon: const Icon(
                      Icons.receipt_long_rounded,
                      color: Color(0xFF334155),
                    ),
                    tooltip: 'Vé đã đặt',
                    onPressed: () => context.push('/cinema/my-tickets'),
                  ),
                ],
              ),
            ),

            // 3. THÂN TRANG CUỘN
            Expanded(
              child: NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    // Carousel Banner Vàng Rực Rỡ (Khớp Screenshot 1)
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          SizedBox(
                            height: 180,
                            child: Stack(
                              children: [
                                PageView.builder(
                                  controller: _bannerController,
                                  onPageChanged: (i) =>
                                      setState(() => _activeBannerIndex = i),
                                  itemCount: _promoBanners.length,
                                  itemBuilder: (context, index) {
                                    final banner = _promoBanners[index];
                                    return Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        CachedNetworkImage(
                                          imageUrl: banner['image']!,
                                          fit: BoxFit.cover,
                                          memCacheWidth: 720,
                                          maxWidthDiskCache: 1080,
                                          placeholder: (ctx, url) => Container(
                                            color: const Color(0xFFFEF3C7),
                                          ),
                                          errorWidget: (ctx, url, err) =>
                                              Container(
                                                color: const Color(0xFFFEF3C7),
                                                child: const Icon(
                                                  Icons.movie_creation_rounded,
                                                  color: Colors.orange,
                                                  size: 48,
                                                ),
                                              ),
                                        ),
                                        // Gradient overlay màu vàng/cam nghệ thuật
                                        Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                Colors.orange.withValues(
                                                  alpha: 0.15,
                                                ),
                                                Colors.black.withValues(
                                                  alpha: 0.75,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 16,
                                          left: 16,
                                          right: 16,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: const Color(
                                                    0xFFEF4444,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  banner['tag']!,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                banner['title']!,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w900,
                                                  letterSpacing: 0.3,
                                                ),
                                              ),
                                              Text(
                                                banner['subtitle']!,
                                                style: const TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 12,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),

                                // Indicator Dots tròn nhỏ (Khớp Screenshot 1)
                                Positioned(
                                  bottom: 8,
                                  left: 0,
                                  right: 0,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(
                                      _promoBanners.length + 8,
                                      (index) {
                                        final isRealIndex =
                                            index < _promoBanners.length;
                                        final isActive =
                                            isRealIndex &&
                                            _activeBannerIndex == index;
                                        return Container(
                                          margin: const EdgeInsets.symmetric(
                                            horizontal: 2.5,
                                          ),
                                          width: 7,
                                          height: 7,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: isActive
                                                ? Colors.white
                                                : Colors.white.withValues(
                                                    alpha: 0.4,
                                                  ),
                                            border: Border.all(
                                              color: Colors.black26,
                                              width: 0.5,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 4. THANH ĐIỀU HƯỚNG TABS & BỘ LỌC ĐỊA ĐIỂM (Khớp Screenshot 1)
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _WhiteCinemaTabBarDelegate(
                        TabBar(
                          controller: _tabController,
                          indicatorColor: const Color(0xFF0369A1),
                          indicatorWeight: 3,
                          indicatorSize: TabBarIndicatorSize.label,
                          labelColor: const Color(0xFF0369A1),
                          unselectedLabelColor: const Color(0xFF64748B),
                          labelStyle: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                          unselectedLabelStyle: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                          tabs: const [
                            Tab(text: 'Đang chiếu'),
                            Tab(text: 'Sắp chiếu'),
                            Tab(text: 'Phim IMAX'),
                          ],
                        ),
                        // Nút chọn địa điểm bên phải
                        InkWell(
                          onTap: _openLocationPicker,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.explore_outlined,
                                  color: Color(0xFF0284C7),
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                ListenableBuilder(
                                  listenable: cinemaService,
                                  builder: (context, _) => Text(
                                    cinemaService.selectedCityName,
                                    style: const TextStyle(
                                      color: Color(0xFF0284C7),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ];
                },
                body: TabBarView(
                  controller: _tabController,
                  children: [
                    // Tab 1: Đang chiếu
                    _buildMovieGrid(
                      cinemaService.movies
                          .where(
                            (m) => m.status == CinemaMovieStatus.nowShowing,
                          )
                          .toList(),
                    ),
                    // Tab 2: Sắp chiếu
                    _buildMovieGrid(
                      cinemaService.movies
                          .where(
                            (m) => m.status == CinemaMovieStatus.comingSoon,
                          )
                          .toList(),
                    ),
                    // Tab 3: IMAX (Hiển thị các phim chiếu định dạng IMAX bom tấn)
                    _buildMovieGrid(
                      cinemaService.movies
                          .where(
                            (m) =>
                                m.status == CinemaMovieStatus.imax ||
                                m.formats.any(
                                  (f) => f.toUpperCase().contains('IMAX'),
                                ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // Nút tròn góc phải dưới (Khớp Screenshot 1)
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
    ),
    );
  }

  Widget _buildMovieGrid(List<CinemaMovieModel> rawList) {
    // Lọc theo quốc gia (Tất cả, Việt Nam, Thái Lan)
    final movieList = rawList.where((m) {
      if (_selectedCountryFilter == 'all') return true;
      return m.country.contains(_selectedCountryFilter);
    }).toList();

    return Column(
      children: [
        // Thanh bộ lọc Quốc gia nhỏ gọn, hiện đại
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          color: Colors.white,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildCountryChip(
                label: 'Tất cả',
                countryValue: 'all',
                icon: Icons.auto_awesome_rounded,
              ),
              const SizedBox(width: 8),
              _buildCountryChip(
                label: 'Phim Việt Nam 🇻🇳',
                countryValue: 'Việt Nam',
                icon: Icons.flag_rounded,
              ),
              const SizedBox(width: 8),
              _buildCountryChip(
                label: 'Phim Thái Lan 🇹🇭',
                countryValue: 'Thái Lan',
                icon: Icons.temple_buddhist_rounded,
              ),
            ],
          ),
        ),

        // Lưới phim và Chân trang rạp chiếu phim (Cinema Footer)
        Expanded(
          child: movieList.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.movie_filter_rounded,
                        size: 52,
                        color: ThemeService.instance.isWindowsBlue
                            ? Colors.white70
                            : Colors.grey.shade300,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _selectedCountryFilter == 'all'
                            ? 'Chưa có phim trong mục này'
                            : 'Không tìm thấy phim $_selectedCountryFilter phù hợp',
                        style: TextStyle(
                          color: ThemeService.instance.isWindowsBlue
                              ? Colors.white
                              : const Color(0xFF64748B),
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                )
              : CustomScrollView(
                  cacheExtent: 600.0,
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(14, 8, 14, 20),
                      sliver: SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.58,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 16,
                            ),
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final movie = movieList[index];
                          return _buildCinemaMovieCard(movie);
                        }, childCount: movieList.length),
                      ),
                    ),

                    // CHÂN TRANG RẠP CHIẾU PHIM (CINEMA FOOTER ĐỒ SỘ)
                    SliverToBoxAdapter(child: _buildCinemaFooter()),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildCountryChip({
    required String label,
    required String countryValue,
    required IconData icon,
  }) {
    final isSelected = _selectedCountryFilter == countryValue;
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedCountryFilter = countryValue);
      },
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0369A1) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF0369A1)
                : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? Colors.white : const Color(0xFF475569),
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF334155),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Card phim nền trắng sắc nét (Khớp Screenshot 1)
  Widget _buildCinemaMovieCard(CinemaMovieModel movie) {
    return RepaintBoundary(
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          context.push('/cinema/movie/${movie.id}');
        },
        borderRadius: BorderRadius.circular(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster 2:3 với nhãn tuổi & rating
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: movie.posterUrl,
                      fit: BoxFit.cover,
                      memCacheWidth: 320,
                      memCacheHeight: 480,
                      maxWidthDiskCache: 600,
                      placeholder: (ctx, url) => Container(
                        color: const Color(0xFFF1F5F9),
                        child: const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFFEF4444),
                              ),
                            ),
                          ),
                        ),
                      ),
                      errorWidget: (ctx, url, err) => Container(
                        color: const Color(0xFFF1F5F9),
                        child: const Center(
                          child: Icon(
                            Icons.movie_rounded,
                            color: Colors.grey,
                            size: 36,
                          ),
                        ),
                      ),
                    ),
                  ),

                // Viền mỏng
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.black.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                  ),
                ),

                // Badge Quốc Gia (VN / THÁI LAN)
                Positioned(
                  top: 6,
                  left: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2.5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          movie.country.contains('Việt Nam')
                              ? Icons.flag_rounded
                              : Icons.public_rounded,
                          size: 11,
                          color: movie.country.contains('Việt Nam')
                              ? const Color(0xFFEF4444)
                              : const Color(0xFF38BDF8),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          movie.country.contains('Việt Nam')
                              ? 'VN'
                              : (movie.country.contains('Thái Lan')
                                    ? 'THÁI'
                                    : movie.country),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Badge IMAX nổi bật nếu phim hỗ trợ IMAX
                if (movie.formats.any((f) => f.toUpperCase().contains('IMAX')))
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0369A1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'IMAX',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ),

                // Rating sao vàng (Khớp Screenshot 1: ⭐ 8.1 / ⭐ 8.3)
                Positioned(
                  right: 6,
                  bottom: 38,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Colors.amber,
                          size: 14,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          movie.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Badge tuổi cam T18 (Khớp Screenshot 1)
                Positioned(
                  right: 6,
                  bottom: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC2410C),
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 3,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Text(
                      movie.ageRating,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 6),

          // Tên phim
          Text(
            movie.title,
            style: TextStyle(
              color: ThemeService.instance.isWindowsBlue
                  ? Colors.white
                  : const Color(0xFF0F172A),
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 2),

          // Thời lượng & Khởi chiếu
          Text(
            '${movie.durationMinutes} Phút • Khởi chiếu ${movie.releaseDate}',
            style: TextStyle(
              color: ThemeService.instance.isWindowsBlue
                  ? const Color(0xFFD6EBFC)
                  : const Color(0xFF64748B),
              fontSize: 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ),
  );
}

  // ==========================================
  // CHÂN TRANG ĐIỆN ẢNH (CINEMA FOOTER ĐỒ SỘ)
  // ==========================================
  Widget _buildCinemaFooter() {
    return Container(
      color: const Color(0xFFF8FAFC),
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Logo rạp & Giới thiệu thương hiệu
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF0369A1),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.theaters_rounded,
                  color: Color(0xFF0369A1),
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'Cine',
                      style: TextStyle(
                        color: Color(0xFF0369A1),
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.3,
                      ),
                    ),
                    TextSpan(
                      text: 'Flix',
                      style: TextStyle(
                        color: Color(0xFFF97316),
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF0369A1).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'CINEMA VIỆT NAM',
                  style: TextStyle(
                    color: Color(0xFF0369A1),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          const Text(
            'Hệ thống rạp chiếu phim hiện đại hàng đầu Việt Nam mang đến trải nghiệm điện ảnh chuẩn quốc tế với công nghệ hình ảnh IMAX Laser và âm thanh Dolby Atmos đỉnh cao.',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 12,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 20),
          Divider(color: Colors.grey.shade300, height: 1),
          const SizedBox(height: 20),

          // 2. Các liên kết danh mục hữu ích
          Wrap(
            spacing: 24,
            runSpacing: 18,
            children: [
              // Cột 1: Về CineFlix
              _buildFooterColumn(
                title: 'VỀ CINEFLIX',
                links: const [
                  'Giới thiệu hệ thống',
                  'Cụm rạp toàn quốc',
                  'Tuyển dụng nhân sự',
                  'Thuê rạp & Sự kiện',
                  'Liên hệ hợp tác',
                ],
              ),

              // Cột 2: Góc Điện Ảnh
              _buildFooterColumn(
                title: 'GÓC ĐIỆN ẢNH',
                links: const [
                  'Phim Việt Nam chiếu rạp',
                  'Phim Thái Lan ăn khách',
                  'Trải nghiệm suất chiếu IMAX',
                  'Tin tức & Bình luận phim',
                  'Lịch khởi chiếu 2026',
                ],
              ),

              // Cột 3: Hỗ Trợ Khách Hàng
              _buildFooterColumn(
                title: 'HỖ TRỢ & ĐIỀU KHOẢN',
                links: const [
                  'Điều khoản sử dụng',
                  'Chính sách thanh toán',
                  'Chính sách bảo mật',
                  'Quy định đổi/trả vé',
                  'Câu hỏi thường gặp (FAQ)',
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),
          Divider(color: Colors.grey.shade300, height: 1),
          const SizedBox(height: 20),

          // 3. Khối Chăm sóc khách hàng & Hotline
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF97316).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.headset_mic_rounded,
                    color: Color(0xFFC2410C),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'TỔNG ĐÀI HỖ TRỢ ĐẶT VÉ (8:00 - 22:00)',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        '1900 2224 • 028 7300 2224',
                        style: TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Email: cskh@cineflix.vn | Khiếu nại dịch vụ rạp',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 4. Đối tác thanh toán & Công nghệ chiếu rạp
          const Text(
            'ĐỐI TÁC THANH TOÁN & CÔNG NGHỆ',
            style: TextStyle(
              color: Color(0xFF475569),
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildPartnerBadge('VISA', Icons.credit_card_rounded),
              _buildPartnerBadge('Mastercard', Icons.credit_card_rounded),
              _buildPartnerBadge('MoMo', Icons.account_balance_wallet_rounded),
              _buildPartnerBadge('ZaloPay', Icons.payment_rounded),
              _buildPartnerBadge('VNPAY-QR', Icons.qr_code_scanner_rounded),
              _buildPartnerBadge('IMAX Laser', Icons.theaters_rounded),
              _buildPartnerBadge('Dolby Atmos', Icons.surround_sound_rounded),
            ],
          ),

          const SizedBox(height: 20),

          // 5. Kết nối mạng xã hội
          Row(
            children: [
              const Text(
                'KẾT NỐI VỚI CINEFLIX:',
                style: TextStyle(
                  color: Color(0xFF475569),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(width: 10),
              _buildSocialIcon(Icons.public_rounded, const Color(0xFF1877F2)),
              const SizedBox(width: 8),
              _buildSocialIcon(
                Icons.smart_display_rounded,
                const Color(0xFFEF4444),
              ),
              const SizedBox(width: 8),
              _buildSocialIcon(
                Icons.music_note_rounded,
                const Color(0xFF0F172A),
              ),
              const SizedBox(width: 8),
              _buildSocialIcon(
                Icons.camera_alt_rounded,
                const Color(0xFFE1306C),
              ),
            ],
          ),

          const SizedBox(height: 24),
          Divider(color: Colors.grey.shade300, height: 1),
          const SizedBox(height: 16),

          // 6. Thông tin công ty & Giấy phép đăng ký
          const Text(
            'CÔNG TY CỔ PHẦN ĐIỆN ẢNH CINEFLIX VIỆT NAM (CINEFLIX CINEMA VIETNAM)',
            style: TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Giấy CNĐKDN: 0312489201 do Sở Kế hoạch và Đầu tư TP. Hồ Chí Minh cấp ngày 15/06/2014.\n'
            'Trụ sở chính: Tòa nhà CineFlix Tower, 116 Nguyễn Du, P. Bến Thành, Quận 1, TP.HCM.\n'
            'Chi nhánh Hà Nội: Tầng 6, Hanoi Centerpoint, 27 Lê Văn Lương, Q. Thanh Xuân, Hà Nội.\n'
            'Chi nhánh Đà Nẵng: Tầng 4, AEON Mall Thanh Khê, Q. Thanh Khê, TP. Đà Nẵng.',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 11,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),

          // Badge thông báo Bộ Công Thương
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFDC2626).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: const Color(0xFFDC2626).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.verified_rounded,
                      color: Color(0xFFDC2626),
                      size: 16,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'ĐÃ THÔNG BÁO BỘ CÔNG THƯƠNG',
                      style: TextStyle(
                        color: Color(0xFFDC2626),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              const Text(
                '© 2026 CineFlix Entertainment',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooterColumn({
    required String title,
    required List<String> links,
  }) {
    return SizedBox(
      width: 145,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          ...links.map(
            (link) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Đang mở: $link'),
                      duration: const Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: Text(
                  link,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartnerBadge(String name, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF475569)),
          const SizedBox(width: 5),
          Text(
            name,
            style: const TextStyle(
              color: Color(0xFF334155),
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 16, color: color),
    );
  }
}

class _WhiteCinemaTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final Widget trailing;
  _WhiteCinemaTabBarDelegate(this.tabBar, this.trailing);

  @override
  double get minExtent => 46;
  @override
  double get maxExtent => 46;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Expanded(child: tabBar),
          trailing,
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_WhiteCinemaTabBarDelegate oldDelegate) => false;
}
