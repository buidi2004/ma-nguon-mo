import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../models/cinema/cinema_models.dart';
import '../../presentation/widgets/glass/glass_components.dart';
import '../../services/cinema/cinema_service.dart';

/// S45: Sơ Đồ Chọn Ghế Ngồi Rạp (Cinema Seat Selection Screen) — Nền Trắng Sắc Nét
class CinemaSeatSelectionScreen extends StatefulWidget {
  final CinemaMovieModel movie;
  final CinemaTheaterModel theater;
  final CinemaShowtimeModel showtime;

  const CinemaSeatSelectionScreen({
    super.key,
    required this.movie,
    required this.theater,
    required this.showtime,
  });

  @override
  State<CinemaSeatSelectionScreen> createState() =>
      _CinemaSeatSelectionScreenState();
}

class _CinemaSeatSelectionScreenState extends State<CinemaSeatSelectionScreen> {
  late final List<CinemaSeatModel> _seats;
  final Set<String> _selectedSeatIds = {};

  @override
  void initState() {
    super.initState();
    _seats = CinemaService.instance
        .generateSeatsForShowtime(widget.showtime.id);
  }

  int get _totalPrice {
    int sum = 0;
    for (final seatId in _selectedSeatIds) {
      final seat = _seats.firstWhere((s) => s.id == seatId);
      sum += seat.price;
    }
    return sum;
  }

  List<String> get _selectedSeatLabels {
    final labels = <String>[];
    for (final seatId in _selectedSeatIds) {
      final seat = _seats.firstWhere((s) => s.id == seatId);
      labels.add(seat.label);
    }
    labels.sort();
    return labels;
  }

  void _toggleSeat(CinemaSeatModel seat) {
    if (seat.status == SeatStatus.reserved) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ghế ${seat.label} đã có khán giả đặt trước.'),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    HapticFeedback.lightImpact();
    setState(() {
      if (_selectedSeatIds.contains(seat.id)) {
        _selectedSeatIds.remove(seat.id);
      } else {
        if (_selectedSeatIds.length >= 8) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Mỗi giao dịch đặt tối đa 8 ghế.'),
              duration: Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }
        _selectedSeatIds.add(seat.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFF97316); // Cam CineFlix

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: const GlassBackButton(fallbackRoute: '/cinema'),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.movie.title,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '${widget.theater.name} • ${widget.showtime.time} • ${widget.showtime.hallName}',
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 11.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // 1. MÔ PHỎNG MÀN HÌNH CHIẾU
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            color: Colors.white,
            child: Column(
              children: [
                // Thanh viền màn hình hiện đại với gradient và shadow
                Container(
                  width: 260,
                  height: 6,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Colors.transparent,
                        Color(0xFF0284C7),
                        Color(0xFF0284C7),
                        Colors.transparent,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0284C7).withValues(alpha: 0.35),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.tv_rounded, size: 14, color: Color(0xFF0284C7)),
                    SizedBox(width: 6),
                    Text(
                      'MÀN HÌNH / SCREEN',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 2. MA TRẬN GHẾ NGỒI (ZOOM & PAN)
          Expanded(
            child: InteractiveViewer(
              minScale: 0.7,
              maxScale: 2.2,
              boundaryMargin: const EdgeInsets.all(40),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildSeatGrid(),
                ),
              ),
            ),
          ),

          // 3. CHÚ THÍCH LOẠI GHẾ (LEGEND)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLegendItem('Thường', const Color(0xFFE2E8F0), '95k'),
                _buildLegendItem('VIP', const Color(0xFFFDE68A), '115k'),
                _buildLegendItem('Đôi', const Color(0xFFFBCFE8), '240k'),
                _buildLegendItem('Đang chọn', primaryColor, null),
                _buildLegendItem('Đã bán', const Color(0xFF94A3B8), null),
              ],
            ),
          ),

          // 4. THANH ĐÁY CỐ ĐỊNH (BOTTOM BAR)
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
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
            child: Row(
              children: [
                // Thông tin ghế & tổng tiền
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _selectedSeatIds.isEmpty
                            ? 'Vui lòng chọn ghế'
                            : 'Ghế: ${_selectedSeatLabels.join(", ")}',
                        style: TextStyle(
                          color: _selectedSeatIds.isEmpty
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF0F172A),
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${_formatCurrency(_totalPrice)} đ',
                        style: const TextStyle(
                          color: Color(0xFFF97316),
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),

                // Nút Tiếp tục chọn bắp nước
                ElevatedButton(
                  onPressed: _selectedSeatIds.isEmpty
                      ? null
                      : () {
                          HapticFeedback.lightImpact();
                          context.push(
                            '/cinema/concessions',
                            extra: {
                              'movie': widget.movie,
                              'theater': widget.theater,
                              'showtime': widget.showtime,
                              'seatLabels': _selectedSeatLabels,
                              'seatsPrice': _totalPrice,
                            },
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF97316),
                    disabledBackgroundColor: Colors.grey.shade300,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Tiếp tục >',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, String? price) {
    return Column(
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.black12),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Color(0xFF475569), fontSize: 11),
        ),
        if (price != null)
          Text(
            price,
            style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }

  Widget _buildSeatGrid() {
    final rows = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'J', 'K'];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: rows.map((rowLetter) {
        final rowSeats = _seats.where((s) => s.row == rowLetter).toList();

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Chữ cái đầu hàng
              SizedBox(
                width: 20,
                child: Text(
                  rowLetter,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 4),

              // Dãy ghế trong hàng
              ...rowSeats.map((seat) {
                final isSelected = _selectedSeatIds.contains(seat.id);
                final isReserved = seat.status == SeatStatus.reserved;

                Color seatColor;
                if (isSelected) {
                  seatColor = const Color(0xFFF97316); // Cam nổi bật
                } else if (isReserved) {
                  seatColor = const Color(0xFFCBD5E1); // Đã bán xám
                } else if (seat.type == SeatType.vip) {
                  seatColor = const Color(0xFFFDE68A); // VIP Vàng
                } else if (seat.type == SeatType.sweetbox) {
                  seatColor = const Color(0xFFFBCFE8); // Sweetbox Hồng
                } else {
                  seatColor = const Color(0xFFFFFFFF); // Standard Trắng
                }

                final isSweetbox = seat.type == SeatType.sweetbox;
                final seatWidth = isSweetbox ? 32.0 : 20.0;

                return GestureDetector(
                  onTap: () => _toggleSeat(seat),
                  child: Container(
                    width: seatWidth,
                    height: 20,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: seatColor,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFEA580C)
                            : isReserved
                                ? Colors.transparent
                                : const Color(0xFF94A3B8),
                        width: isSelected ? 1.5 : 0.8,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: const Color(0xFFF97316)
                                    .withValues(alpha: 0.4),
                                blurRadius: 4,
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: isReserved
                          ? const Icon(Icons.close_rounded,
                              size: 13, color: Colors.white)
                          : isSweetbox
                              ? const Icon(Icons.favorite_rounded,
                                  size: 11, color: Color(0xFFEC4899))
                              : Text(
                                  '${seat.number}',
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : const Color(0xFF334155),
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                    ),
                  ),
                );
              }),

              const SizedBox(width: 4),
              // Chữ cái cuối hàng
              SizedBox(
                width: 20,
                child: Text(
                  rowLetter,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }
}
