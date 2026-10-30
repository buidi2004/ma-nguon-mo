import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/widgets/cinema/cinema_location_picker_sheet.dart';
import '../../presentation/widgets/glass/glass_components.dart';
import '../../services/cinema/cinema_service.dart';
import '../../services/theme_service.dart';
import '../../waves_background.dart';

/// S44: Chi Tiết Phim Rạp & Lịch Chiếu (Cinema Movie Detail & Showtimes Screen)
/// Giao diện nền trắng, chuẩn phong cách CineFlix Cinema.
class CinemaMovieDetailScreen extends StatefulWidget {
  final String movieId;

  const CinemaMovieDetailScreen({super.key, required this.movieId});

  @override
  State<CinemaMovieDetailScreen> createState() =>
      _CinemaMovieDetailScreenState();
}

class _CinemaMovieDetailScreenState extends State<CinemaMovieDetailScreen> {
  int _selectedDateIndex = 0;
  String _selectedChainFilter =
      'all'; // 'all', 'CineFlix Cinema', 'CGV Cinemas'
  bool _isExpandedSynopsis = false;

  late final List<DateTime> _dates;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _dates = List.generate(7, (i) => now.add(Duration(days: i)));
  }

  String _formatWeekday(DateTime date, int index) {
    if (index == 0) return 'Hôm Nay';
    switch (date.weekday) {
      case DateTime.monday:
        return 'Thứ Hai';
      case DateTime.tuesday:
        return 'Thứ Ba';
      case DateTime.wednesday:
        return 'Thứ Tư';
      case DateTime.thursday:
        return 'Thứ Năm';
      case DateTime.friday:
        return 'Thứ Sáu';
      case DateTime.saturday:
        return 'Thứ Bảy';
      case DateTime.sunday:
      default:
        return 'Chủ Nhật';
    }
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
    ); // CineFlix Blue, tương phản trên nền sáng

    final movie = cinemaService.movies.firstWhere(
      (m) => m.id == widget.movieId,
      orElse: () => cinemaService.movies.first,
    );

    final theaters = cinemaService.getTheatersByCity(
      cinemaService.selectedCityId,
    );

    return WavesBackground.wrapIfBlue(
      Scaffold(
      backgroundColor: ThemeService.instance.isWindowsBlue ? Colors.transparent : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: const GlassBackButton(fallbackRoute: '/cinema'),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: blueColor, width: 1.5),
              ),
              child: const Icon(
                Icons.theaters_rounded,
                color: blueColor,
                size: 16,
              ),
            ),
            const SizedBox(width: 6),
            RichText(
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: 'Cine',
                    style: TextStyle(
                      color: Color(0xFF0284C7),
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  TextSpan(
                    text: 'Flix',
                    style: TextStyle(
                      color: Color(0xFFF97316),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.close_rounded,
              color: Color(0xFF0284C7),
              size: 24,
            ),
            tooltip: 'Đóng',
            onPressed: () => context.pop(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. VIDEO TEASER TRAILER PREVIEW (Khớp Screenshot 2)
            Stack(
              alignment: Alignment.center,
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: CachedNetworkImage(
                    imageUrl: movie.backdropUrl,
                    fit: BoxFit.cover,
                    memCacheWidth: 720,
                    maxWidthDiskCache: 1080,
                    placeholder: (ctx, url) => Container(
                      color: const Color(0xFF1E293B),
                    ),
                    errorWidget: (ctx, url, err) => Container(
                      color: const Color(0xFF1E293B),
                      child: const Center(
                        child: Icon(
                          Icons.videocam_rounded,
                          color: Colors.white30,
                          size: 48,
                        ),
                      ),
                    ),
                  ),
                ),
                // Nút Play tròn (Khớp Screenshot 2)
                InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    context.push(
                      '/trailer',
                      extra: {
                        'title': movie.title,
                        'videoUrl': movie.trailerUrl,
                      },
                    );
                  },
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Color(0xFF1E293B),
                      size: 36,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 2. THÔNG TIN PHIM: POSTER + METADATA (Khớp Screenshot 2)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Poster nhỏ bên trái
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 105,
                      height: 150,
                      child: CachedNetworkImage(
                        imageUrl: movie.posterUrl,
                        fit: BoxFit.cover,
                        memCacheWidth: 240,
                        memCacheHeight: 360,
                        maxWidthDiskCache: 600,
                        placeholder: (ctx, url) => Container(
                          color: const Color(0xFF1E293B),
                        ),
                        errorWidget: (ctx, url, err) => Container(
                          color: const Color(0xFF1E293B),
                          child: const Center(
                            child: Icon(
                              Icons.movie_rounded,
                              color: Colors.white38,
                              size: 32,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 14),

                  // Metadata bên phải
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tên phim + Badge tuổi cam T18
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                movie.title,
                                style: TextStyle(
                                  color: ThemeService.instance.isWindowsBlue
                                      ? Colors.white
                                      : const Color(0xFF0F172A),
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFC2410C),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                movie.ageRating,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Thời lượng & Khởi chiếu
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time_rounded,
                              color: Color(0xFFC2410C),
                              size: 15,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${movie.durationMinutes} Phút',
                              style: TextStyle(
                                color: ThemeService.instance.isWindowsBlue
                                    ? const Color(0xFFE2F1FF)
                                    : const Color(0xFF334155),
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Icon(
                              Icons.calendar_today_rounded,
                              color: Color(0xFFC2410C),
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              movie.releaseDate,
                              style: TextStyle(
                                color: ThemeService.instance.isWindowsBlue
                                    ? const Color(0xFFE2F1FF)
                                    : const Color(0xFF334155),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 6),

                        // Đánh giá sao vàng (Khớp Screenshot 2: ⭐ 8.3 (122 votes))
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: Color(0xFFF59E0B),
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              movie.rating.toStringAsFixed(1),
                              style: TextStyle(
                                color: ThemeService.instance.isWindowsBlue
                                    ? Colors.white
                                    : const Color(0xFF0F172A),
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(${movie.voteCount} votes)',
                              style: TextStyle(
                                color: ThemeService.instance.isWindowsBlue
                                    ? const Color(0xFFD6EBFC)
                                    : const Color(0xFF64748B),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 6),

                        // Quốc gia
                        Row(
                          children: [
                            Text(
                              'Quốc gia:   ',
                              style: TextStyle(
                                color: ThemeService.instance.isWindowsBlue
                                    ? const Color(0xFFD6EBFC)
                                    : const Color(0xFF64748B),
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              movie.country,
                              style: TextStyle(
                                color: ThemeService.instance.isWindowsBlue
                                    ? Colors.white
                                    : const Color(0xFF0F172A),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Nhà sản xuất
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    'Nhà sản xuất:  ',
                    style: TextStyle(
                      color: ThemeService.instance.isWindowsBlue
                          ? const Color(0xFFD6EBFC)
                          : const Color(0xFF64748B),
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    movie.productionStudio,
                    style: TextStyle(
                      color: ThemeService.instance.isWindowsBlue
                          ? Colors.white
                          : const Color(0xFF0F172A),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Thể loại Chips (Khớp Screenshot 2: [Hài] [Tâm Lý])
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    'Thể loại:          ',
                    style: TextStyle(
                      color: ThemeService.instance.isWindowsBlue
                          ? const Color(0xFFD6EBFC)
                          : const Color(0xFF64748B),
                      fontSize: 13,
                    ),
                  ),
                  Wrap(
                    spacing: 8,
                    children: movie.genres
                        .map(
                          (genre) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Text(
                              genre,
                              style: const TextStyle(
                                color: Color(0xFF334155),
                                fontSize: 13,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Đạo diễn (Khớp Screenshot 2: [Đức Nguyễn])
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    'Đạo diễn:        ',
                    style: TextStyle(
                      color: ThemeService.instance.isWindowsBlue
                          ? const Color(0xFFD6EBFC)
                          : const Color(0xFF64748B),
                      fontSize: 13,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Text(
                      movie.director,
                      style: const TextStyle(
                        color: Color(0xFF334155),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Diễn viên Chips (Khớp Screenshot 2: [Anh Tú] [DJ Mie] [Vũ Ngọc Anh]...)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      'Diễn viên:       ',
                      style: TextStyle(
                        color: ThemeService.instance.isWindowsBlue
                            ? const Color(0xFFD6EBFC)
                            : const Color(0xFF64748B),
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: movie.cast
                          .map(
                            (actor) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Text(
                                actor,
                                style: const TextStyle(
                                  color: Color(0xFF334155),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 3. TÓM TẮT NỘI DUNG (Khớp Screenshot 3)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.synopsis,
                    style: TextStyle(
                      color: ThemeService.instance.isWindowsBlue
                          ? const Color(0xFFE2F1FF)
                          : const Color(0xFF334155),
                      fontSize: 13,
                      height: 1.5,
                    ),
                    maxLines: _isExpandedSynopsis ? null : 4,
                    overflow: _isExpandedSynopsis
                        ? TextOverflow.visible
                        : TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  InkWell(
                    onTap: () => setState(
                      () => _isExpandedSynopsis = !_isExpandedSynopsis,
                    ),
                    child: Text(
                      _isExpandedSynopsis ? 'Thu gọn' : 'Xem thêm >',
                      style: TextStyle(
                        color: ThemeService.instance.isWindowsBlue
                            ? const Color(0xFF5AD2F4)
                            : const Color(0xFF0369A1),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // 4. SECTION HEADER: "Lịch Chiếu" (Khớp Screenshot 3)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: ThemeService.instance.isWindowsBlue
                          ? const Color(0xFF5AD2F4)
                          : const Color(0xFF0284C7),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Lịch Chiếu',
                    style: TextStyle(
                      color: ThemeService.instance.isWindowsBlue
                          ? Colors.white
                          : const Color(0xFF0F172A),
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Dropdowns: [Toàn quốc v] [Tất cả rạp v] (Khớp Screenshot 3)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // Dropdown 1: Tỉnh / Thành phố
                  Expanded(
                    child: InkWell(
                      onTap: _openLocationPicker,
                      child: Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ListenableBuilder(
                              listenable: cinemaService,
                              builder: (context, _) => Text(
                                cinemaService.selectedCityName,
                                style: const TextStyle(
                                  color: Color(0xFF334155),
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.arrow_drop_down_rounded,
                              color: Color(0xFF64748B),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Dropdown 2: Tất cả rạp
                  Expanded(
                    child: Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedChainFilter,
                          isExpanded: true,
                          icon: const Icon(
                            Icons.arrow_drop_down_rounded,
                            color: Color(0xFF64748B),
                          ),
                          style: const TextStyle(
                            color: Color(0xFF334155),
                            fontSize: 13,
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'all',
                              child: Text('Tất cả rạp'),
                            ),
                            DropdownMenuItem(
                              value: 'CineFlix Cinema',
                              child: Text('CineFlix Cinema'),
                            ),
                            DropdownMenuItem(
                              value: 'CGV Cinemas',
                              child: Text('CGV Cinemas'),
                            ),
                            DropdownMenuItem(
                              value: 'BHD Star',
                              child: Text('BHD Star'),
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedChainFilter = val);
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // DẢI CHỌN NGÀY NGANG: [Hôm Nay 19/10] [Thứ Ba 20/10]... (Khớp Screenshot 3)
            SizedBox(
              height: 68,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _dates.length,
                itemBuilder: (context, index) {
                  final date = _dates[index];
                  final isSelected = _selectedDateIndex == index;
                  final dayStr =
                      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
                  final weekdayStr = _formatWeekday(date, index);

                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() => _selectedDateIndex = index);
                    },
                    child: Container(
                      width: 86,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF0284C7)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: isSelected
                            ? null
                            : Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            weekdayStr,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF334155),
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dayStr,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF0F172A),
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),
            Divider(color: Colors.grey.shade200, height: 1),
            const SizedBox(height: 14),

            // 5. DANH SÁCH CỤM RẠP & CÁC NÚT GIỜ CHIẾU (Khớp Screenshot 3)
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: theaters.length,
              separatorBuilder: (context, index) => const SizedBox(height: 18),
              itemBuilder: (context, index) {
                final theater = theaters[index];
                if (_selectedChainFilter != 'all' &&
                    theater.chain != _selectedChainFilter) {
                  return const SizedBox.shrink();
                }

                final selectedDate = _dates[_selectedDateIndex];
                final showtimes = cinemaService.getShowtimes(
                  movieId: movie.id,
                  theaterId: theater.id,
                  date: selectedDate,
                );

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tên cụm rạp (CineFlix Cinema...)
                      Text(
                        theater.name,
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        theater.address,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Format & Phòng chiếu (Khớp: VIP - LAURUS 2D Phụ Đề)
                      Text(
                        '${showtimes.first.hallName} ${showtimes.first.format}',
                        style: const TextStyle(
                          color: Color(0xFF475569),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Nút giờ chiếu (Khớp: [16:15], [14:45], [10:00])
                      Wrap(
                        spacing: 12,
                        runSpacing: 10,
                        children: showtimes.map((st) {
                          return InkWell(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              // Mở màn hình chọn ghế S45
                              context.push(
                                '/cinema/seat-selection',
                                extra: {
                                  'movie': movie,
                                  'theater': theater,
                                  'showtime': st,
                                },
                              );
                            },
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              width: 78,
                              height: 38,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  st.time,
                                  style: const TextStyle(
                                    color: Color(0xFF0F172A),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 50),
          ],
        ),
      ),
    ),
    );
  }
}
