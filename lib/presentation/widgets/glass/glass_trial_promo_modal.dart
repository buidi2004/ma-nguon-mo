import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../services/theme_service.dart';
import '../brand/app_brand_logo.dart';
import 'openflix_morph_icon.dart';

/// Modal Pop-up Chiến Dịch Ưu Đãi tái tạo chuẩn 100% theo phong cách Pop-up CGV.
///
/// Các thành phần mô phỏng chính xác từ hình ảnh CGV:
/// - Nền mờ Scrim đen phía sau làm nổi bật tấm thiệp.
/// - Khung thiệp poster gradient hồng phấn rực rỡ với ánh sáng neon pastel.
/// - Logo thương hiệu góc trên bên trái: `OPENFLIX*`.
/// - Dòng chữ nghệ thuật `Tháng của Nàng`, badge 3D `DEAL GIẢM ĐẾN`, và con số khổng lồ 3D `100.000Đ`.
/// - Hình ảnh chiếc phong bì quà tặng mở nắp (Gift Envelope) với 3 thẻ voucher đa sắc vươn lên kèm nơ lụa vàng 3D.
/// - Viên thuốc thời gian: `Thời gian: 12/10 - 20/10` trên miệng phong bì.
/// - Nút bấm Oval Vàng Hoàng Kim (Golden Capsule) với chữ in hoa đậm nét `MUA NGAY`.
/// - Nút tròn đóng "X" viền trắng dày đặc trưng của CGV treo nổi tại góc trên bên phải.
/// - Bố cục responsive chống tràn tuyệt đối trên mọi kích thước màn hình.
class GlassTrialPromoModal extends StatelessWidget {
  /// Callback khi người dùng bấm "MUA NGAY".
  final VoidCallback? onSubscribe;

  /// Callback khi người dùng bấm nút đóng "X" hoặc chạm ra ngoài.
  final VoidCallback? onDismiss;

  const GlassTrialPromoModal({super.key, this.onSubscribe, this.onDismiss});

  /// Hiển thị modal ưu đãi với hiệu ứng Fade + Scale mượt mà.
  static Future<void> show(
    BuildContext context, {
    VoidCallback? onSubscribe,
    VoidCallback? onDismiss,
  }) async {
    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'GlassTrialPromoModal',
      barrierColor: Colors.black.withAlpha(190), // Làm tối trang chủ 75%
      transitionDuration: const Duration(milliseconds: 220),
      transitionBuilder: (context, anim1, anim2, child) {
        final curved = CurvedAnimation(
          parent: anim1,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.88, end: 1.0).animate(curved),
            child: child,
          ),
        );
      },
      pageBuilder: (context, anim1, anim2) {
        return GlassTrialPromoModal(
          onSubscribe: onSubscribe,
          onDismiss: onDismiss,
        );
      },
    );
  }

  void _handleDismiss(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
    if (onDismiss != null) {
      onDismiss!();
    }
  }

  void _handleSubscribe(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
    if (onSubscribe != null) {
      onSubscribe!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    // Kích thước chuẩn thiệp banner CGV, chống tràn layout trên máy nhỏ
    final modalWidth = math.min(screenWidth * 0.88, 336.0);
    final modalMaxHeight = math.min(screenHeight * 0.85, 520.0);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 1. Chạm ra ngoài vùng nền scrim để đóng pop-up
          Positioned.fill(
            child: GestureDetector(
              onTap: () => _handleDismiss(context),
              behavior: HitTestBehavior.opaque,
              child: const SizedBox.expand(),
            ),
          ),

          // 2. Tấm thiệp quà tặng CGV chính ở trung tâm
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: modalWidth,
                maxHeight: modalMaxHeight,
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Thẻ thiệp quà tặng chính
                  _buildCgvCard(context),

                  // Nút đóng tròn "X" viền trắng dày treo nổi đặc trưng của CGV
                  Positioned(
                    top: -14,
                    right: -10,
                    child: _buildCgvCloseButton(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Nút đóng tròn viền trắng dày, nền tối mờ, dấu X trắng đậm như hình CGV
  Widget _buildCgvCloseButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _handleDismiss(context),
        borderRadius: BorderRadius.circular(24.0),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xCC111111), // Nền đen mờ 80%
            border: Border.all(
              color: Colors.white,
              width: 2.8, // Viền trắng nổi bật đặc trưng CGV
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(140),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Center(
            child: Icon(Icons.close_rounded, color: Colors.white, size: 24),
          ),
        ),
      ),
    );
  }

  /// Thẻ thiệp đồ họa rực rỡ chuẩn 100% theo phong cách banner CGV
  Widget _buildCgvCard(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.0),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFF7F9), // Hồng phấn siêu sáng ở đỉnh
              Color(0xFFFFEBF1), // Hồng pastel dịu ngọt
              Color(0xFFFFD2E1), // Hồng phấn san hô ở chân
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(180),
              blurRadius: 28,
              offset: const Offset(0, 14),
            ),
            BoxShadow(
              color: const Color(0xFFE91E63).withAlpha(45),
              blurRadius: 36,
              spreadRadius: 2,
            ),
          ],
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Logo FLIX* với Icon 3D điện ảnh ở góc trên bên trái
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const AppBrandLogo.small(iconSize: 22, fontSize: 16),
                  Text(
                    '*',
                    style: TextStyle(
                      color: ThemeService.instance.primaryColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 17,
                      height: 1.0,
                    ),
                  ),
                  const Spacer(),
                  // Ngôi sao lấp lánh ✨
                  const Icon(
                    Icons.auto_awesome,
                    color: Color(0xFFFF80AB),
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // 2. Tiêu đề uốn lượn nghệ thuật "Tháng của Nàng"
              const Text(
                'Tháng của Nàng',
                style: TextStyle(
                  color: Color(0xFFE91E63),
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  fontStyle: FontStyle.italic,
                  letterSpacing: 0.5,
                  shadows: [
                    Shadow(
                      color: Colors.white,
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),

              // 3. Badge 3D nổi "DEAL GIẢM ĐẾN"
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF4081), Color(0xFFE91E63)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE91E63).withAlpha(100),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Text(
                  'DEAL GIẢM ĐẾN',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 4),

              // 4. Số tiền ưu đãi khổng lồ 3D "100.000Đ"
              _build3dAmountText(),
              const SizedBox(height: 8),

              // 5. Hình ảnh Chiếc Phong Bì Quà Tặng Mở Nắp & 3 Thẻ Voucher Đa Sắc
              _buildGiftEnvelopeArtwork(),
              const SizedBox(height: 12),

              // 6. Nút Oval Vàng Hoàng Kim "MUA NGAY"
              _buildGoldenCtaButton(context),
              const SizedBox(height: 8),

              // 7. Ghi chú điều kiện in nghiêng dưới chân thiệp
              const Text(
                '*Áp dụng khi mua Gói thành viên hoặc Thẻ Quà Tặng OpenFlix',
                style: TextStyle(
                  color: Color(0xFFC2185B),
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  letterSpacing: 0.2,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Con số 100.000Đ tạo khối bóng bẩy 3D màu hồng neon
  Widget _build3dAmountText() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Lớp bóng đổ đậm sâu tạo khối 3D
        Text(
          '100.000Đ',
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.0,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3.5
              ..color = const Color(0xFFC2185B).withAlpha(190),
          ),
        ),
        // Lớp gradient chữ hồng sáng bóng
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFFFFFFFF), Color(0xFFFF80AB), Color(0xFFE91E63)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(bounds),
          child: const Text(
            '100.000Đ',
            style: TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.0,
              shadows: [
                Shadow(
                  color: Color(0xFFFF4081),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Tác phẩm đồ họa Phong bì quà tặng mở nắp, 3 thẻ voucher và nơ lụa vàng
  Widget _buildGiftEnvelopeArtwork() {
    return SizedBox(
      width: 260,
      height: 165,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          // 3 Thẻ Voucher quà tặng cắm nghiêng vươn ra khỏi phong bì
          // Thẻ 1: Thẻ vàng kẻ sọc bên trái (nghiêng -14 độ)
          Positioned(
            left: 20,
            bottom: 40,
            child: Transform.rotate(
              angle: -0.22,
              child: _buildVoucherCard(
                color1: const Color(0xFFFFB300),
                color2: const Color(0xFFFF8F00),
                title: 'VIP PASS',
                subtitle: 'CINEMA',
                patternColor: Colors.white.withAlpha(50),
              ),
            ),
          ),

          // Thẻ 2: Thẻ hồng "HAPPY" ở chính giữa (nghiêng nhẹ)
          Positioned(
            bottom: 44,
            child: Transform.rotate(
              angle: 0.05,
              child: _buildVoucherCard(
                color1: const Color(0xFFFF4081),
                color2: const Color(0xFFC2185B),
                title: 'HAPPY',
                subtitle: 'OPENFLIX',
                patternColor: Colors.white.withAlpha(70),
                hasHearts: true,
              ),
            ),
          ),

          // Thẻ 3: Thẻ xanh ngọc "YES!" bên phải (nghiêng +16 độ)
          Positioned(
            right: 18,
            bottom: 38,
            child: Transform.rotate(
              angle: 0.25,
              child: _buildVoucherCard(
                color1: const Color(0xFF00B0FF),
                color2: const Color(0xFF2979FF),
                title: 'YES!',
                subtitle: 'MOVIE',
                patternColor: Colors.white.withAlpha(60),
              ),
            ),
          ),

          // Thân chiếc phong bì quà tặng mở nắp (Coral Pink Envelope)
          Positioned(
            bottom: 0,
            child: Container(
              width: 250,
              height: 92,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(6),
                ),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFFF80AB), Color(0xFFF06292)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFC2185B).withAlpha(90),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Nắp phong bì mở gập hình tam giác
                  Positioned(
                    top: 0,
                    child: CustomPaint(
                      size: const Size(250, 40),
                      painter: _EnvelopeFlapPainter(),
                    ),
                  ),

                  // Nơ ruy-băng lụa vàng thắt ở góc phải
                  Positioned(right: 8, top: 14, child: _buildYellowRibbonBow()),

                  // Viên thuốc thời gian sự kiện: Thời gian: 12/10 - 20/10
                  Positioned(
                    bottom: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE91E63).withAlpha(50),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Text(
                        'Thời gian: 12/10 - 20/10',
                        style: TextStyle(
                          color: Color(0xFFE91E63),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Thẻ voucher quà tặng nhỏ cắm trong phong bì
  Widget _buildVoucherCard({
    required Color color1,
    required Color color2,
    required String title,
    required String subtitle,
    required Color patternColor,
    bool hasHearts = false,
  }) {
    return Container(
      width: 76,
      height: 105,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color1, color2],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(70),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.white.withAlpha(120), width: 1.0),
      ),
      child: Stack(
        children: [
          // Họa tiết trang trí chấm bi / trái tim
          Positioned(
            top: 6,
            right: 6,
            child: OpenFlixMorphIcon.snappy(
              icon: hasHearts ? Icons.favorite_rounded : Icons.star_rounded,
              color: patternColor,
              size: 14,
            ),
          ),
          Positioned(
            bottom: 6,
            left: 6,
            child: Icon(
              Icons.confirmation_number_outlined,
              color: patternColor,
              size: 14,
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withAlpha(220),
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Nơ ruy-băng lụa vàng 3D buộc ở mép phải phong bì
  Widget _buildYellowRibbonBow() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFFFF9C4), // Vàng pastel
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFB300).withAlpha(120),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      child: const Center(
        child: Icon(
          Icons.card_giftcard_rounded,
          color: Color(0xFFFFA000),
          size: 18,
        ),
      ),
    );
  }

  /// Nút bấm Oval Vàng Hoàng Kim "MUA NGAY" rực rỡ như trong ảnh CGV
  Widget _buildGoldenCtaButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _handleSubscribe(context),
        borderRadius: BorderRadius.circular(26),
        child: Ink(
          width: 226,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFFFDE7), // Vàng sáng kem ở đỉnh
                Color(0xFFFFEE58), // Vàng tươi
                Color(0xFFFFC107), // Vàng hoàng kim ở đáy
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF8F00).withAlpha(130),
                blurRadius: 14,
                spreadRadius: 1,
                offset: const Offset(0, 5),
              ),
            ],
            border: Border.all(color: Colors.white, width: 1.8),
          ),
          child: const Center(
            child: Text(
              'MUA NGAY',
              style: TextStyle(
                color: Color(0xFFC2185B), // Đỏ hồng đậm tương phản hoàn hảo
                fontSize: 17,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.0,
                shadows: [
                  Shadow(
                    color: Colors.white,
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Painter vẽ nắp gập phong bì tam giác mở nắp
class _EnvelopeFlapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFF48FB1)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);

    // Viền sáng cho nắp
    final strokePaint = Paint()
      ..color = Colors.white.withAlpha(90)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
