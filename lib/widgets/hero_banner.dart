import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../models/movie_model.dart';
import '../services/library_service.dart';
import '../services/theme_service.dart';
import '../theme/app_theme.dart';
import '../presentation/widgets/glass/openflix_morph_icon.dart';

/// Carousel hero-banner cho trang chủ (S09).
///
/// Bố cục cụm hành động chuẩn rạp chiếu cao cấp:
/// - Nút trái: "Thêm vào DS" (Bookmark)
/// - Nút giữa: Viên thuốc trắng Capsule [ HD ] 29.000đ / 50.000đ
/// - Nút phải: "Chi tiết" (Info)
/// - Đáy: Dãy chấm chuyển trang (Dots Carousel)
/// - Chạm vào ảnh poster: Tự động mở trailer phim
class HeroBannerCarousel extends StatefulWidget {
  final List<MovieModel> movies;
  final void Function(MovieModel movie) onPlay;
  final void Function(MovieModel movie)? onInfo;
  final void Function(MovieModel movie)? onImageTap;

  /// Giới hạn số slide để tránh autoplay quá dài + tốn bộ nhớ.
  final int maxItems;

  const HeroBannerCarousel({
    super.key,
    required this.movies,
    required this.onPlay,
    this.onInfo,
    this.onImageTap,
    this.maxItems = 6,
  });

  @override
  State<HeroBannerCarousel> createState() => _HeroBannerCarouselState();
}

class _HeroBannerCarouselState extends State<HeroBannerCarousel> {
  late final CarouselSliderController _controller;
  late final ValueNotifier<int> _indexNotifier;

  @override
  void initState() {
    super.initState();
    _controller = CarouselSliderController();
    _indexNotifier = ValueNotifier<int>(0);
  }

  @override
  void dispose() {
    _indexNotifier.dispose();
    super.dispose();
  }

  void _handlePageChanged(int index, CarouselPageChangedReason reason) {
    if (!mounted) return;
    _indexNotifier.value = index;
    // Pre-cache ảnh kế tiếp để vuốt mượt, không giật.
    final items = _effectiveMovies;
    if (items.length > 1) {
      final next = items[(index + 1) % items.length];
      if (next.posterUrl.isNotEmpty) {
        // Pre-cache đúng kích thước render. Provider không có giới hạn sẽ giải
        // mã ảnh gốc ngay lúc carousel đổi slide, dễ tạo một khung hình dài
        // trên máy tầm trung dù slide chỉ hiển thị tối đa 1080px.
        precacheImage(
          CachedNetworkImageProvider(
            next.posterUrl,
            maxWidth: _cacheWidthFor(context),
          ),
          context,
        );
      }
    }
  }

  int _cacheWidthFor(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final dpr = MediaQuery.devicePixelRatioOf(context);
    return (width * dpr).toInt().clamp(720, 1080);
  }

  List<MovieModel> get _effectiveMovies {
    if (widget.movies.length <= widget.maxItems) return widget.movies;
    return widget.movies.sublist(0, widget.maxItems);
  }

  @override
  Widget build(BuildContext context) {
    final items = _effectiveMovies;
    if (items.isEmpty) return const SizedBox.shrink();

    final screenSize = MediaQuery.sizeOf(context);
    final heroHeight = (screenSize.height * 0.58)
        .clamp(420.0, 660.0)
        .toDouble();
    // Trần 1080px: đủ nét trên điện thoại, nhẹ hơn ảnh gốc rất lớn mà mắt
    // thường không phân biệt được. Dùng chung với provider preload để cache
    // được tái sử dụng ngay khi slide xuất hiện.
    final cacheWidth = _cacheWidthFor(context);
    final isSingle = items.length == 1;

    return Semantics(
      container: true,
      label: 'Phim nổi bật',
      child: SizedBox(
        height: heroHeight,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CarouselSlider.builder(
              carouselController: _controller,
              itemCount: items.length,
              itemBuilder: (context, index, pageViewIndex) {
                final movie = items[index];
                return RepaintBoundary(
                  child: _HeroSlide(
                    movie: movie,
                    cacheWidth: cacheWidth,
                    reserveIndicatorSpace: !isSingle,
                    onPlay: () => widget.onPlay(movie),
                    onInfo: widget.onInfo == null
                        ? null
                        : () => widget.onInfo!(movie),
                    onImageTap: () {
                      if (widget.onImageTap != null) {
                        widget.onImageTap!(movie);
                      } else {
                        context.push('/movie/${movie.id}/trailer');
                      }
                    },
                  ),
                );
              },
              options: CarouselOptions(
                height: heroHeight,
                viewportFraction: 1.0,
                enlargeCenterPage: false,
                enableInfiniteScroll: !isSingle,
                autoPlay: !isSingle,
                autoPlayInterval: const Duration(seconds: 6),
                autoPlayAnimationDuration: const Duration(milliseconds: 650),
                autoPlayCurve: Curves.fastOutSlowIn,
                pauseAutoPlayOnTouch: true,
                pauseAutoPlayOnManualNavigate: true,
                scrollDirection: Axis.horizontal,
                padEnds: false,
                onPageChanged: _handlePageChanged,
              ),
            ),

            // Indicator dãy chấm chuyển trang, nằm gọn ở đáy (dưới cụm 3 nút hành động)
            if (!isSingle)
              Positioned(
                left: 16,
                right: 16,
                bottom: 8,
                child: IgnorePointer(
                  child: Center(
                    child: ValueListenableBuilder<int>(
                      valueListenable: _indexNotifier,
                      builder: (context, current, _) {
                        if (items.length > 7) {
                          return _PageCounter(
                            current: current + 1,
                            total: items.length,
                          );
                        }
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(items.length, (i) {
                            final isActive = i == current;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              curve: Curves.easeOutCubic,
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              width: isActive ? 24 : 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: isActive
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.38),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            );
                          }),
                        );
                      },
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Slide hero đơn: ảnh + 2 lớp gradient + title/meta + cụm 3 nút.
class _HeroSlide extends StatelessWidget {
  final MovieModel movie;
  final int cacheWidth;
  final VoidCallback onPlay;
  final VoidCallback? onInfo;
  final VoidCallback? onImageTap;
  final bool reserveIndicatorSpace;

  const _HeroSlide({
    required this.movie,
    required this.cacheWidth,
    required this.onPlay,
    this.onInfo,
    this.onImageTap,
    this.reserveIndicatorSpace = true,
  });

  @override
  Widget build(BuildContext context) {
    final title = movie.title.trim().isEmpty ? 'Chưa có tiêu đề' : movie.title;

    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. Ảnh nền (chạm vào ảnh để mở trailer phim) với hiệu ứng hòa tan quang học (Alpha Dissolve Feathering)
        ShaderMask(
          shaderCallback: (bounds) {
            return const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.0, 0.45, 0.70, 0.88, 1.0],
              colors: [
                Colors.white,
                Colors.white,
                Color(0xCCFFFFFF),
                Color(0x33FFFFFF),
                Colors.transparent,
              ],
            ).createShader(bounds);
          },
          blendMode: BlendMode.dstIn,
          child: movie.posterUrl.isEmpty
              ? ColoredBox(
                  color: AppColors.surface,
                  child: const Center(
                    child: Icon(
                      Icons.movie_filter_outlined,
                      size: 64,
                      color: Colors.white24,
                      semanticLabel: 'Không có ảnh phim',
                    ),
                  ),
                )
              : GestureDetector(
                  onTap:
                      onImageTap ??
                      () => context.push('/movie/${movie.id}/trailer'),
                  behavior: HitTestBehavior.opaque,
                  child: CachedNetworkImage(
                    imageUrl: movie.posterUrl,
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                    memCacheWidth: cacheWidth,
                    maxWidthDiskCache: cacheWidth,
                    fadeInDuration: const Duration(milliseconds: 180),
                    fadeOutDuration: const Duration(milliseconds: 150),
                    placeholder: (_, _) => ColoredBox(color: AppColors.surface),
                    errorWidget: (_, _, _) => ColoredBox(
                      color: AppColors.surface,
                      child: const Center(
                        child: Icon(
                          Icons.movie_filter_outlined,
                          size: 64,
                          color: Colors.white24,
                          semanticLabel: 'Tải ảnh thất bại',
                        ),
                      ),
                    ),
                  ),
                ),
        ),

        // 2. Gradient đỉnh: hòa vào status bar / app bar trong suốt.
        const Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 170,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.25, 0.55, 0.80, 1.0],
                  colors: [
                    Color(0xF2000000),
                    Color(0xB8000000),
                    Color(0x60000000),
                    Color(0x18000000),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),

        // 3. Gradient đáy: hòa trộn quang học đa tầng (Multi-stop Oceanic Blend)
        // Trong chế độ Windows Blue, dải gradient kết thúc ở Colors.transparent tại 1.0
        // để hòa tan triệt để 100% vào nền sóng động mà không để lại bất kỳ đường gờ nào.
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.20, 0.45, 0.68, 0.82, 0.92, 1.0],
                  colors: ThemeService.instance.isWindowsBlue
                      ? const [
                          Colors.transparent,
                          Color(0x2E011420),
                          Color(0x7A021826),
                          Color(0xB8031C26),
                          Color(0x55031C26),
                          Colors.transparent,
                        ]
                      : (ThemeService.instance.isLuxuryGold
                          ? const [
                              Colors.transparent,
                              Color(0x2E060504),
                              Color(0x7A060504),
                              Color(0xB8060504),
                              Color(0x55060504),
                              Colors.transparent,
                            ]
                          : [
                              Colors.transparent,
                              AppColors.background.withValues(alpha: 0.20),
                              AppColors.background.withValues(alpha: 0.55),
                              AppColors.background.withValues(alpha: 0.82),
                              AppColors.background.withValues(alpha: 0.96),
                              AppColors.background,
                            ]),
                ),
              ),
            ),
          ),
        ),

        // Lớp ánh sáng xanh lơ lan tỏa nhẹ (Cyan Ambient Luminescence) ở vùng chân banner
        if (ThemeService.instance.isWindowsBlue)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 120,
            child: const IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.0, 0.5, 1.0],
                    colors: [
                      Colors.transparent,
                      Color(0x1400A2ED),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

        // 4. Nội dung đáy: title + meta + cụm 3 nút hành động.
        Positioned(
          left: 12,
          right: 12,
          bottom: reserveIndicatorSpace ? 28 : 14,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                  shadows: [Shadow(color: Colors.black, blurRadius: 6)],
                ),
              ),
              const SizedBox(height: 6),
              _MetaRow(movie: movie),
              const SizedBox(height: 16),
              // Cụm 3 nút hành động chuẩn mẫu ảnh (Thêm vào DS - [HD] 29.000đ - Chi tiết)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 1. Nút bên trái: Thêm vào DS (kết nối LibraryService)
                  ListenableBuilder(
                    listenable: LibraryService.instance,
                    builder: (context, _) {
                      final isInList = LibraryService.instance.isInMyList(
                        movie.id,
                      );
                      return _ActionColumnButton(
                        icon: isInList
                            ? Icons.bookmark
                            : Icons.bookmark_outline,
                        label: isInList ? 'Đã thêm' : 'Thêm vào DS',
                        iconColor: isInList
                            ? ThemeService.instance.primaryColor
                            : Colors.white,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          LibraryService.instance.toggleMyList(movie.id);
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isInList
                                    ? 'Đã xóa "${movie.title}" khỏi danh sách'
                                    : 'Đã thêm "${movie.title}" vào danh sách',
                              ),
                              duration: const Duration(seconds: 2),
                              backgroundColor: AppColors.surface,
                            ),
                          );
                        },
                      );
                    },
                  ),

                  // 2. Nút chính giữa: Viên thuốc trắng [ HD ] 29.000đ
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: SizedBox(
                        height: 46,
                        child: ElevatedButton(
                          onPressed: onPlay,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            elevation: 4,
                            shadowColor: Colors.black.withValues(alpha: 0.35),
                            shape: const StadiumBorder(),
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 5,
                                    vertical: 1.5,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.black,
                                      width: 1.3,
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'HD',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  movie.isFeatured ? '50.000đ' : '29.000đ',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 3. Nút bên phải: Chi tiết
                  _ActionColumnButton(
                    icon: Icons.info_outline,
                    label: 'Chi tiết',
                    iconColor: Colors.white,
                    onTap:
                        onInfo ??
                        () => context.push('/movie/${movie.id}', extra: movie),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Nút dạng cột đứng (Icon phía trên, nhãn chữ phía dưới)
class _ActionColumnButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final VoidCallback onTap;

  const _ActionColumnButton({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 58,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OpenFlixMorphIcon.snappy(icon: icon, color: iconColor, size: 24),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final MovieModel movie;

  const _MetaRow({required this.movie});

  @override
  Widget build(BuildContext context) {
    final isTrailer = movie.comingSoon || movie.durationMinutes <= 5;
    final vipTag = isTrailer ? 'TRAILER' : 'Cinema VIP';
    final category = movie.category.isNotEmpty ? movie.category : 'Phim';
    final rating = movie.ageRating.isNotEmpty ? movie.ageRating : 'T13';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              vipTag,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              '•',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ),
          Flexible(
            child: Text(
              category,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              '•',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ),
          Text(
            rating,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _PageCounter extends StatelessWidget {
  final int current;
  final int total;

  const _PageCounter({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$current / $total',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Banner đơn (giữ tương thích ngược).
class HeroBanner extends StatelessWidget {
  final MovieModel movie;
  final VoidCallback onPlay;
  final VoidCallback? onInfo;
  final VoidCallback? onImageTap;

  const HeroBanner({
    super.key,
    required this.movie,
    required this.onPlay,
    this.onInfo,
    this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final heroHeight = (screenHeight * 0.58).clamp(420.0, 660.0).toDouble();
    final cacheWidth =
        (MediaQuery.sizeOf(context).width *
                MediaQuery.devicePixelRatioOf(context))
            .toInt()
            .clamp(720, 1080)
            .toInt();

    return SizedBox(
      height: heroHeight,
      width: double.infinity,
      child: RepaintBoundary(
        child: _HeroSlide(
          movie: movie,
          cacheWidth: cacheWidth,
          reserveIndicatorSpace: false,
          onPlay: onPlay,
          onInfo: onInfo,
          onImageTap:
              onImageTap ?? () => context.push('/movie/${movie.id}/trailer'),
        ),
      ),
    );
  }
}
