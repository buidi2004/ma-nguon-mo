import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import 'glass_button.dart';
import 'glass_spec_badge.dart';

/// Modal Pop-up Dùng Thử VIP (Trial Promo Modal) phong cách kính mờ điện ảnh OpenFlix.
///
/// Lấy cảm hứng từ banner chiến dịch In-App CGV nhưng nâng tầm theo ngôn ngữ Dark Cinema:
/// - Lớp phủ làm mờ hậu cảnh BackdropFilter (sigma 14.0).
/// - Khung thẻ kính bo góc 20px với hiệu ứng khúc xạ quang học và quầng sáng đỏ neon vi mô.
/// - Nút đóng tròn "X" treo nổi tại góc trên bên phải (vùng chạm chuẩn >= 44x44 px).
/// - Bố cục responsive, cuộn mượt mà không bao giờ bị overflow trên mọi kích cỡ màn hình.
/// - Nút CTA chính màu đỏ thương hiệu chuyển hướng trực tiếp đến màn hình Gói thành viên (/plans).
class GlassTrialPromoModal extends StatelessWidget {
  /// Callback khi người dùng bấm "DÙNG THỬ NGAY".
  final VoidCallback? onSubscribe;

  /// Callback khi người dùng bấm đóng hoặc bấm ra ngoài.
  final VoidCallback? onDismiss;

  const GlassTrialPromoModal({
    super.key,
    this.onSubscribe,
    this.onDismiss,
  });

  /// Hiển thị modal dùng thử với hiệu ứng chuyển động Fade + Scale mượt mà.
  static Future<void> show(
    BuildContext context, {
    VoidCallback? onSubscribe,
    VoidCallback? onDismiss,
  }) async {
    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'GlassTrialPromoModal',
      barrierColor: Colors.black.withAlpha(190), // ~75% opacity
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

    // Giới hạn chiều rộng và chiều cao linh hoạt, chống tràn layout
    final modalWidth = math.min(screenWidth * 0.88, 360.0);
    final modalMaxHeight = math.min(screenHeight * 0.84, 560.0);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Bấm ra ngoài vùng nền để đóng pop-up
          Positioned.fill(
            child: GestureDetector(
              onTap: () => _handleDismiss(context),
              behavior: HitTestBehavior.opaque,
              child: const SizedBox.expand(),
            ),
          ),
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: modalWidth,
                maxHeight: modalMaxHeight,
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Thẻ kính chính
                  _buildModalCard(context),

                  // Nút đóng tròn "X" treo nổi tại góc trên bên phải
                  Positioned(
                    top: -14,
                    right: -10,
                    child: _buildCloseButton(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCloseButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _handleDismiss(context),
        borderRadius: BorderRadius.circular(24.0),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF1E1E1E).withAlpha(240),
            border: Border.all(
              color: Colors.white.withAlpha(70),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(160),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.close_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModalCard(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF181818).withAlpha(240),
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(
              color: Colors.white.withAlpha(35),
              width: 1.2,
            ),
            boxShadow: [
              // Hào quang đỏ thương hiệu OpenFlix tỏa nhẹ
              BoxShadow(
                color: AppColors.red.withAlpha(45),
                blurRadius: 40,
                spreadRadius: 2,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: Colors.black.withAlpha(200),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 1. Huy hiệu vương miện VIP với ánh sáng neon đỏ
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.red,
                        Color(0xFF8B0000),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.red.withAlpha(110),
                        blurRadius: 18,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.workspace_premium_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // 2. Spec Badge phân loại
                GlassSpecBadge.tag(
                  label: 'ƯU ĐÃI ĐẶC QUYỀN',
                  accentColor: AppColors.red,
                  isCapsule: true,
                  height: 22.0,
                ),
                const SizedBox(height: 8),

                // 3. Tiêu đề chính
                const Text(
                  '7 NGÀY DÙNG THỬ VIP',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),

                // 4. Khẩu hiệu phụ
                const Text(
                  'Trọn vẹn rạp chiếu tại gia 4K Ultra HD & Dolby Atmos miễn phí.',
                  style: TextStyle(
                    color: Color(0xFFCCCCCC),
                    fontSize: 12.0,
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // 5. Khung kính liệt kê các quyền lợi nổi bật
                _buildBenefitsCard(),
                const SizedBox(height: 14),

                // 6. Nút CTA Kính đỏ thương hiệu
                GlassButton.brand(
                  text: 'DÙNG THỬ NGAY (0Đ)',
                  icon: Icons.arrow_forward_rounded,
                  height: 46,
                  width: double.infinity,
                  onPressed: () => _handleSubscribe(context),
                ),
                const SizedBox(height: 6),

                // 7. Ghi chú điều kiện
                const Text(
                  '0đ trong 7 ngày đầu. Tự do hủy bất cứ lúc nào.',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 10.5,
                    letterSpacing: 0.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),

                // 8. Nút phụ "Để sau"
                TextButton(
                  onPressed: () => _handleDismiss(context),
                  style: TextButton.styleFrom(
                    minimumSize: const Size(80, 44),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  ),
                  child: const Text(
                    'Để sau',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

          ),
        ),
      ),
    );
  }

  Widget _buildBenefitsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: const Color(0xFF121212).withAlpha(180),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: Colors.white.withAlpha(20),
          width: 1.0,
        ),
      ),
      child: Column(
        children: [
          _buildBenefitRow(
            icon: Icons.movie_filter_rounded,
            iconColor: AppColors.red,
            text: 'Kho 1.000+ bom tấn & series độc quyền',
          ),
          const SizedBox(height: 8),
          _buildBenefitRow(
            icon: Icons.high_quality_rounded,
            iconColor: const Color(0xFFFFD700), // Gold
            text: 'Chất lượng 4K HDR & âm thanh Dolby Atmos',
          ),
          const SizedBox(height: 8),
          _buildBenefitRow(
            icon: Icons.block_rounded,
            iconColor: const Color(0xFF00E5FF), // Cyan
            text: 'Không quảng cáo, tải xem offline không giới hạn',
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitRow({
    required IconData icon,
    required Color iconColor,
    required String text,
  }) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
