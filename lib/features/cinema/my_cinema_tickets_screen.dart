import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../models/cinema/cinema_models.dart';
import '../../presentation/widgets/glass/glass_components.dart';
import '../../services/cinema/cinema_service.dart';
import '../../services/theme_service.dart';
import '../../waves_background.dart';

/// S49: Quản Lý Vé Rạp Của Tôi (My Cinema Tickets Screen) — Nền Trắng Rạp
class MyCinemaTicketsScreen extends StatefulWidget {
  const MyCinemaTicketsScreen({super.key});

  @override
  State<MyCinemaTicketsScreen> createState() => _MyCinemaTicketsScreenState();
}

class _MyCinemaTicketsScreenState extends State<MyCinemaTicketsScreen>
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
    final cinemaService = CinemaService.instance;
    const blueColor = Color(0xFF0369A1);

    return WavesBackground.wrapIfBlue(
      Scaffold(
      backgroundColor: ThemeService.instance.isWindowsBlue ? Colors.transparent : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: const GlassBackButton(fallbackRoute: '/cinema'),
        title: const Text(
          'Vé Rạp Của Tôi',
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
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
          tabs: const [
            Tab(text: 'Vé sắp xem'),
            Tab(text: 'Lịch sử vé đã xem'),
          ],
        ),
      ),
      body: ListenableBuilder(
        listenable: cinemaService,
        builder: (context, _) {
          final activeBookings = cinemaService.userBookings
              .where((b) => !b.isUsed)
              .toList();
          final pastBookings = cinemaService.userBookings
              .where((b) => b.isUsed)
              .toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildTicketList(activeBookings, isActive: true),
              _buildTicketList(pastBookings, isActive: false),
            ],
          );
        },
      ),
    ),
    );
  }

  Widget _buildTicketList(
    List<CinemaBookingModel> list, {
    required bool isActive,
  }) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.confirmation_num_outlined,
              size: 64,
              color: ThemeService.instance.isWindowsBlue
                  ? Colors.white70
                  : Colors.grey.shade300,
            ),
            const SizedBox(height: 12),
            Text(
              isActive
                  ? 'Bạn chưa có vé phim sắp xem nào'
                  : 'Chưa có lịch sử vé đã xem',
              style: TextStyle(
                color: ThemeService.instance.isWindowsBlue
                    ? Colors.white
                    : const Color(0xFF64748B),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/cinema'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC2410C),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 11,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Khám phá phim rạp ngay',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: list.length,
      separatorBuilder: (context, index) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final booking = list[index];

        return InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            context.push('/cinema/ticket/${booking.id}', extra: booking);
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 70,
                    height: 100,
                    child: CachedNetworkImage(
                      imageUrl: booking.posterUrl,
                      fit: BoxFit.cover,
                      memCacheWidth: 210,
                      memCacheHeight: 300,
                      placeholder: (_, _) => Container(color: Colors.grey.shade200),
                      errorWidget: (_, _, _) => Container(
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.movie_rounded, size: 24, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? const Color(0xFFDCFCE7)
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              isActive ? 'Sẵn sàng quét' : 'Đã sử dụng',
                              style: TextStyle(
                                color: isActive
                                    ? const Color(0xFF16A34A)
                                    : Colors.grey,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            booking.bookingCode,
                            style: const TextStyle(
                              color: Color(0xFF0369A1),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        booking.movieTitle,
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        booking.theaterName,
                        style: const TextStyle(
                          color: Color(0xFF475569),
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${booking.showtime} • Hôm nay • Ghế: ${booking.seatLabels.join(", ")}',
                        style: const TextStyle(
                          color: Color(0xFFC2410C),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF64748B),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
