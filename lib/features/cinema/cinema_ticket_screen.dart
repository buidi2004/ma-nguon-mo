import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../models/cinema/cinema_models.dart';
import '../../presentation/widgets/glass/glass_components.dart';
import '../../services/cinema/cinema_service.dart';

/// S48: Vé Điện Tử / Thẻ Vào Rạp (Cinema E-Ticket & Digital Pass Screen)
/// Thiết kế vé đục lỗ điện ảnh (Perforated Ticket) sắc nét trên nền trắng
class CinemaTicketScreen extends StatelessWidget {
  final CinemaBookingModel? booking;
  final String bookingId;

  const CinemaTicketScreen({
    super.key,
    this.booking,
    required this.bookingId,
  });

  @override
  Widget build(BuildContext context) {
    // Tìm booking nếu được truyền qua ID
    final actualBooking = booking ??
        CinemaService.instance.userBookings.firstWhere(
          (b) => b.id == bookingId,
          orElse: () => CinemaService.instance.userBookings.first,
        );

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: const GlassBackButton(fallbackRoute: '/cinema'),
        title: const Text(
          'Vé Điện Tử Vào Rạp',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded, color: Color(0xFF0284C7)),
            tooltip: 'Chia sẻ vé',
            onPressed: () {
              HapticFeedback.lightImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã sao chép liên kết vé để chia sẻ cho bạn bè!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            // Thông báo thành công
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF86EFAC)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle_rounded,
                      color: Color(0xFF16A34A), size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Đặt vé thành công! Vui lòng quét mã QR tại cổng soát vé.',
                      style: TextStyle(
                        color: Color(0xFF14532D),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // THẺ VÉ ĐỤC LỖ ĐIỆN ẢNH (PERFORATED TICKET CARD)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // PHẦN TRÊN VÉ: POSTER & THÔNG TIN PHIM
                    Container(
                      padding: const EdgeInsets.all(18),
                      color: const Color(0xFF0284C7),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: SizedBox(
                              width: 60,
                              height: 85,
                              child: Image.network(
                                actualBooking.posterUrl,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  actualBooking.movieTitle,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  actualBooking.theaterName,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '${actualBooking.hallName} • ${actualBooking.format}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // VẠCH PHÂN TÁCH ĐỤC LỖ RĂNG CƯA
                    _buildPerforationDivider(),

                    // PHẦN DƯỚI VÉ: SUẤT CHIẾU, SỐ GHẾ, QR CODE
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // Hàng Ngày & Giờ & Ghế
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildTicketInfoCol(
                                  'NGÀY', 'Hôm nay'),
                              _buildTicketInfoCol(
                                  'GIỜ CHIẾU', actualBooking.showtime),
                              _buildTicketInfoCol('SỐ GHẾ',
                                  actualBooking.seatLabels.join(', ')),
                            ],
                          ),

                          const SizedBox(height: 20),
                          Divider(color: Colors.grey.shade200, height: 1),
                          const SizedBox(height: 20),

                          // MÃ QR CODE SOÁT VÉ RẠP
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Column(
                              children: [
                                // Icon QR Code tiêu chuẩn Flutter
                                const Icon(
                                  Icons.qr_code_2_rounded,
                                  size: 150,
                                  color: Color(0xFF0F172A),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'MÃ ĐẶT CHỖ: ${actualBooking.bookingCode}',
                                  style: const TextStyle(
                                    color: Color(0xFF0F172A),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Vạch quét mã Barcode tiêu chuẩn với Icon
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.barcode_reader,
                                size: 30,
                                color: Color(0xFF475569),
                              ),
                              SizedBox(width: 8),
                              Text(
                                'QUÉT MÃ TẠI CỬA SOÁT VÉ',
                                style: TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          Text(
                            'Tổng thanh toán: ${_formatCurrency(actualBooking.totalAmount)} đ (${actualBooking.paymentMethod})',
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // NÚT LƯU VÉ & VỀ TRANG CHỦ
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.download_rounded,
                        color: Color(0xFF0284C7)),
                    label: const Text('Lưu ảnh vé',
                        style: TextStyle(color: Color(0xFF0284C7))),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Đã lưu hình ảnh vé vào thư viện máy.'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: Color(0xFF0284C7)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => context.go('/cinema'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF97316),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Về trang chủ rạp',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketInfoCol(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _buildPerforationDivider() {
    return SizedBox(
      height: 24,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Đường đứt nét ở giữa
          Row(
            children: List.generate(
              32,
              (index) => Expanded(
                child: Container(
                  color: index.isEven ? Colors.grey.shade300 : Colors.transparent,
                  height: 1.5,
                ),
              ),
            ),
          ),
          // Hai vết đục lỗ tròn 2 bên cạnh
          Positioned(
            left: -12,
            child: Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: -12,
            child: Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }
}
