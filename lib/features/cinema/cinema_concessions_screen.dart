import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../models/cinema/cinema_models.dart';
import '../../presentation/widgets/glass/glass_components.dart';
import '../../services/cinema/cinema_service.dart';

/// S46: Chọn Bắp Nước & Combo (Cinema Concessions Screen) — Nền Trắng Rạp
class CinemaConcessionsScreen extends StatefulWidget {
  final CinemaMovieModel movie;
  final CinemaTheaterModel theater;
  final CinemaShowtimeModel showtime;
  final List<String> seatLabels;
  final int seatsPrice;

  const CinemaConcessionsScreen({
    super.key,
    required this.movie,
    required this.theater,
    required this.showtime,
    required this.seatLabels,
    required this.seatsPrice,
  });

  @override
  State<CinemaConcessionsScreen> createState() =>
      _CinemaConcessionsScreenState();
}

class _CinemaConcessionsScreenState extends State<CinemaConcessionsScreen> {
  final Map<String, int> _selectedQuantities = {};
  String _activeCategory = 'all';

  int get _concessionsPrice {
    int total = 0;
    final concessions = CinemaService.instance.concessions;
    for (final entry in _selectedQuantities.entries) {
      final item = concessions.firstWhere((c) => c.id == entry.key);
      total += item.price * entry.value;
    }
    return total;
  }

  int get _totalPrice => widget.seatsPrice + _concessionsPrice;

  void _changeQuantity(String concessionId, int delta) {
    HapticFeedback.lightImpact();
    setState(() {
      final current = _selectedQuantities[concessionId] ?? 0;
      final next = current + delta;
      if (next <= 0) {
        _selectedQuantities.remove(concessionId);
      } else if (next <= 10) {
        _selectedQuantities[concessionId] = next;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFF97316);
    final concessions = CinemaService.instance.concessions;

    final filteredList = _activeCategory == 'all'
        ? concessions
        : concessions.where((c) => c.category == _activeCategory).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: const GlassBackButton(fallbackRoute: '/cinema/seat-selection'),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chọn Bắp Nước & Combo',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Tiết kiệm tới 25% khi đặt trước cùng vé',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 11.5,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // 1. THANH CHỌN DANH MỤC
          Container(
            height: 48,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildCategoryChip('all', 'Tất cả'),
                _buildCategoryChip('combo', 'Combo Ưu Đãi'),
                _buildCategoryChip('popcorn', 'Bắp Rang'),
                _buildCategoryChip('drink', 'Nước Ngọt'),
                _buildCategoryChip('merch', 'Ly Nhân Vật'),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // 2. DANH SÁCH BẮP NƯỚC
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              itemCount: filteredList.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = filteredList[index];
                final qty = _selectedQuantities[item.id] ?? 0;

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Ảnh minh họa món
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: 80,
                          height: 80,
                          child: Image.network(
                            item.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, err, stack) => Container(
                              color: const Color(0xFFFEF3C7),
                              child: const Icon(Icons.fastfood_rounded,
                                  color: Colors.orange, size: 32),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 14),

                      // Thông tin chi tiết
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: const TextStyle(
                                color: Color(0xFF0F172A),
                                fontSize: 14.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              item.description,
                              style: const TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 11.5,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${_formatCurrency(item.price)} đ',
                              style: const TextStyle(
                                color: Color(0xFFEA580C),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Bộ đếm (+ / -)
                      Row(
                        children: [
                          if (qty > 0) ...[
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline_rounded,
                                  color: Color(0xFF64748B), size: 26),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () => _changeQuantity(item.id, -1),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                '$qty',
                                style: const TextStyle(
                                  color: Color(0xFF0F172A),
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                          IconButton(
                            icon: const Icon(Icons.add_circle_rounded,
                                color: primaryColor, size: 28),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () => _changeQuantity(item.id, 1),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // 3. THANH ĐÁY CỐ ĐỊNH (BOTTOM BAR)
          Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Ghế: ${widget.seatLabels.join(", ")}',
                        style: const TextStyle(
                          color: Color(0xFF475569),
                          fontSize: 12.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${_formatCurrency(_totalPrice)} đ',
                        style: const TextStyle(
                          color: Color(0xFFF97316),
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),

                ElevatedButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    context.push(
                      '/cinema/checkout',
                      extra: {
                        'movie': widget.movie,
                        'theater': widget.theater,
                        'showtime': widget.showtime,
                        'seatLabels': widget.seatLabels,
                        'concessions': _selectedQuantities,
                        'totalAmount': _totalPrice,
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF97316),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 26, vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Thanh toán >',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.5,
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

  Widget _buildCategoryChip(String catId, String label) {
    final isSelected = _activeCategory == catId;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _activeCategory = catId);
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0284C7) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF475569),
              fontSize: 12.5,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
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
