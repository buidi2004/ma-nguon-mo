import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../models/cinema/cinema_models.dart';
import '../../presentation/widgets/glass/glass_components.dart';
import '../../services/cinema/cinema_service.dart';
import '../../services/theme_service.dart';
import '../../waves_background.dart';

/// S47: Thanh Toán & Xác Nhận Đặt Vé (Cinema Checkout Screen) — Nền Trắng Rạp
class CinemaCheckoutScreen extends StatefulWidget {
  final CinemaMovieModel movie;
  final CinemaTheaterModel theater;
  final CinemaShowtimeModel showtime;
  final List<String> seatLabels;
  final Map<String, int> concessions;
  final int totalAmount;

  const CinemaCheckoutScreen({
    super.key,
    required this.movie,
    required this.theater,
    required this.showtime,
    required this.seatLabels,
    required this.concessions,
    required this.totalAmount,
  });

  @override
  State<CinemaCheckoutScreen> createState() => _CinemaCheckoutScreenState();
}

class _CinemaCheckoutScreenState extends State<CinemaCheckoutScreen> {
  int _secondsRemaining = 300; // 5 phút đếm ngược giữ ghế
  Timer? _countdownTimer;

  String _selectedPaymentMethod = 'momo';
  final TextEditingController _voucherController = TextEditingController();
  int _discountAmount = 0;
  bool _isVoucherApplied = false;
  bool _agreedToTerms = true;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
        _showExpiredDialog();
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _voucherController.dispose();
    super.dispose();
  }

  void _showExpiredDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          'Hết Thời Gian Giữ Vé',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Đã hết thời gian 5 phút giữ ghế tạm thời. Vui lòng chọn lại suất chiếu.',
          style: TextStyle(color: Color(0xFF475569)),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/cinema');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC2410C),
            ),
            child: const Text(
              'Quay lại danh sách phim',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _applyVoucher() {
    final code = _voucherController.text.trim().toUpperCase();
    if (code == 'CINEFLIX20' || code == 'OPENFLIX') {
      HapticFeedback.lightImpact();
      setState(() {
        _discountAmount = 20000;
        _isVoucherApplied = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Áp dụng mã ưu đãi thành công! Giảm 20.000đ.'),
          backgroundColor: Color(0xFF16A34A),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mã giảm giá không hợp lệ hoặc đã hết hạn.'),
          backgroundColor: Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _processPayment() async {
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đồng ý với điều khoản mua vé rạp.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);
    HapticFeedback.mediumImpact();

    // Giả lập thanh toán nhanh 1.2s
    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;

    final bookingCode =
        'GLX-${(100000 + DateTime.now().millisecondsSinceEpoch % 899999)}';

    final finalTotal = widget.totalAmount - _discountAmount;

    final booking = CinemaBookingModel(
      id: 'bk_${DateTime.now().millisecondsSinceEpoch}',
      bookingCode: bookingCode,
      movieId: widget.movie.id,
      movieTitle: widget.movie.title,
      posterUrl: widget.movie.posterUrl,
      theaterName: widget.theater.name,
      theaterAddress: widget.theater.address,
      hallName: widget.showtime.hallName,
      format: widget.showtime.format,
      showtime: widget.showtime.time,
      date: widget.showtime.date,
      seatLabels: widget.seatLabels,
      concessions: widget.concessions,
      totalAmount: finalTotal,
      paymentMethod: _getPaymentMethodTitle(_selectedPaymentMethod),
      qrCodeData:
          '$bookingCode-${widget.seatLabels.join("")}-${widget.theater.id}',
      createdAt: DateTime.now(),
      isUsed: false,
    );

    CinemaService.instance.addBooking(booking);

    setState(() => _isProcessing = false);

    // Mở màn hình vé điện tử S48
    context.pushReplacement('/cinema/ticket/${booking.id}', extra: booking);
  }

  String _getPaymentMethodTitle(String method) {
    switch (method) {
      case 'momo':
        return 'Ví điện tử MoMo';
      case 'zalopay':
        return 'Ví ZaloPay';
      case 'vnpay':
        return 'Cổng VNPAY-QR';
      case 'napas':
        return 'Thẻ ATM nội địa (Napas)';
      case 'card':
      default:
        return 'Thẻ quốc tế Visa/Mastercard';
    }
  }

  @override
  Widget build(BuildContext context) {
    final minutes = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsRemaining % 60).toString().padLeft(2, '0');
    final finalPrice = widget.totalAmount - _discountAmount;

    return WavesBackground.wrapIfBlue(
      Scaffold(
      backgroundColor: ThemeService.instance.isWindowsBlue ? Colors.transparent : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: const GlassBackButton(fallbackRoute: '/cinema/concessions'),
        title: const Text(
          'Thanh Toán Đặt Vé',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. THANH ĐẾM NGƯỢC GIỮ VÉ
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFDBA74)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.timer_outlined,
                    color: Color(0xFFC2410C),
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Thời gian giữ ghế tạm thời còn lại:',
                      style: TextStyle(
                        color: Color(0xFF9A3412),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC2410C),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '$minutes:$seconds',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 2. TÓM TẮT THÔNG TIN ĐƠN ĐẶT VÉ
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
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
                  // Tên phim + Poster
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: SizedBox(
                          width: 50,
                          height: 72,
                          child: CachedNetworkImage(
                            imageUrl: widget.movie.posterUrl,
                            fit: BoxFit.cover,
                            memCacheWidth: 150,
                            memCacheHeight: 216,
                            placeholder: (_, _) => Container(color: Colors.grey.shade200),
                            errorWidget: (_, _, _) => Container(
                              color: Colors.grey.shade300,
                              child: const Icon(Icons.movie_rounded, size: 20, color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.movie.title,
                              style: const TextStyle(
                                color: Color(0xFF0F172A),
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.theater.name,
                              style: const TextStyle(
                                color: Color(0xFF0369A1),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${widget.showtime.hallName} • ${widget.showtime.format}',
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

                  const SizedBox(height: 14),
                  Divider(color: Colors.grey.shade200, height: 1),
                  const SizedBox(height: 14),

                  // Chi tiết suất chiếu & ghế
                  _buildSummaryRow(
                    'Suất chiếu',
                    '${widget.showtime.time} • Hôm nay',
                  ),
                  const SizedBox(height: 8),
                  _buildSummaryRow('Số ghế', widget.seatLabels.join(', ')),

                  // Nếu có bắp nước
                  if (widget.concessions.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _buildSummaryRow(
                      'Bắp nước',
                      '${widget.concessions.values.reduce((a, b) => a + b)} phần combo',
                    ),
                  ],

                  const SizedBox(height: 14),
                  Divider(color: Colors.grey.shade200, height: 1),
                  const SizedBox(height: 14),

                  // Tổng tiền tạm tính & Giảm giá
                  _buildSummaryRow(
                    'Tạm tính',
                    '${_formatCurrency(widget.totalAmount)} đ',
                  ),
                  if (_discountAmount > 0) ...[
                    const SizedBox(height: 6),
                    _buildSummaryRow(
                      'Mã giảm giá (CINEFLIX20)',
                      '-${_formatCurrency(_discountAmount)} đ',
                      valueColor: const Color(0xFF16A34A),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tổng thanh toán',
                        style: TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_formatCurrency(finalPrice)} đ',
                        style: const TextStyle(
                          color: Color(0xFFC2410C),
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // 3. MÃ KHUYẾN MÃI / VOUCHER
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.discount_outlined,
                    color: Color(0xFFC2410C),
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _voucherController,
                      style: const TextStyle(fontSize: 13),
                      decoration: const InputDecoration(
                        hintText: 'Nhập mã giảm giá (VD: CINEFLIX20)',
                        hintStyle: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 13,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _isVoucherApplied ? null : _applyVoucher,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0369A1),
                      disabledBackgroundColor: Colors.grey.shade300,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      _isVoucherApplied ? 'Đã áp dụng' : 'Áp dụng',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // 4. PHƯƠNG THỨC THANH TOÁN
            Text(
              'Chọn phương thức thanh toán',
              style: TextStyle(
                color: ThemeService.instance.isWindowsBlue
                    ? Colors.white
                    : const Color(0xFF0F172A),
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _buildPaymentRadio(
                    'momo',
                    'Ví MoMo',
                    'Thanh toán một chạm qua ứng dụng MoMo',
                    Icons.account_balance_wallet_rounded,
                    const Color(0xFFA50064),
                  ),
                  Divider(color: Colors.grey.shade100, height: 1),
                  _buildPaymentRadio(
                    'zalopay',
                    'Ví ZaloPay',
                    'Ưu đãi hoàn tiền với ZaloPay',
                    Icons.payments_rounded,
                    const Color(0xFF0068FF),
                  ),
                  Divider(color: Colors.grey.shade100, height: 1),
                  _buildPaymentRadio(
                    'vnpay',
                    'Cổng VNPAY-QR',
                    'Quét mã QR từ mọi ứng dụng ngân hàng',
                    Icons.qr_code_scanner_rounded,
                    const Color(0xFF005BAA),
                  ),
                  Divider(color: Colors.grey.shade100, height: 1),
                  _buildPaymentRadio(
                    'napas',
                    'Thẻ ATM nội địa (Napas)',
                    'Hỗ trợ hơn 40 ngân hàng tại Việt Nam',
                    Icons.credit_card_rounded,
                    const Color(0xFF0D9488),
                  ),
                  Divider(color: Colors.grey.shade100, height: 1),
                  _buildPaymentRadio(
                    'card',
                    'Thẻ quốc tế Visa / Mastercard',
                    'Thẻ tín dụng / ghi nợ quốc tế',
                    Icons.credit_score_rounded,
                    const Color(0xFF1E3A8A),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Điều khoản
            Row(
              children: [
                Checkbox(
                  value: _agreedToTerms,
                  activeColor: const Color(0xFFC2410C),
                  onChanged: (val) =>
                      setState(() => _agreedToTerms = val ?? true),
                ),
                Expanded(
                  child: Text(
                    'Tôi đồng ý với điều khoản đặt vé rạp và cam kết đúng độ tuổi xem phim.',
                    style: TextStyle(
                      color: ThemeService.instance.isWindowsBlue
                          ? const Color(0xFFE2F1FF)
                          : const Color(0xFF64748B),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Nút Thanh Toán
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC2410C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: _isProcessing
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        'Xác nhận & Thanh toán ${_formatCurrency(finalPrice)} đ',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? const Color(0xFF0F172A),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentRadio(
    String id,
    String title,
    String subtitle,
    IconData icon,
    Color iconColor,
  ) {
    final isSelected = _selectedPaymentMethod == id;
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _selectedPaymentMethod = id);
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF7ED) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFC2410C)
                      : Colors.grey.shade400,
                  width: isSelected ? 6 : 1.5,
                ),
              ),
            ),
          ],
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
