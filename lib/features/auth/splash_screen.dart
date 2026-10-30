import 'package:flutter/material.dart';
import 'package:smart_splash_kit/smart_splash_kit.dart';

import '../../presentation/widgets/brand/v_movie_brand_asset.dart';
import '../../presentation/widgets/glass/glass_smart_splash.dart';
import '../../services/auth_service.dart';
import '../../services/theme_service.dart';

/// Màn hình khởi động S01 của OpenFlix tích hợp Smart Splash Kit chuẩn điện ảnh.
///
/// Hỗ trợ:
/// - Smart Routing: Định tuyến thông minh sau khi kiểm tra phiên đăng nhập và prefetch dữ liệu.
/// - Không chặn splash chờ mạng: Home tự tải + skeleton (giảm treo đầu giờ).
/// - Hoạt cảnh mượt mà: `fadeScale` phối hợp phóng to nhẹ và độ mờ kính vi mô.
/// - Giao diện Dark Cinema: Nền #141414, hào quang đỏ điện ảnh #E50914.
class SplashScreen extends StatelessWidget {
  /// Cấu hình Splash tùy biến (nếu truyền vào).
  final SplashConfig? config;

  /// Async callback khởi tạo ứng dụng tùy biến.
  final Future<SplashRoute> Function()? onInit;

  const SplashScreen({super.key, this.config, this.onInit});

  Future<SplashRoute> _defaultStartupFlow() async {
    // Không chặn splash chờ mạng/timer: Home đã có skeleton + RAM-cache,
    // nên vào home ngay sau animation (~800ms) thay vì treo nhiều giây
    // khi server chậm. Không timer, không request ở đây (không đổi giao diện).
    // 2. Kiểm tra phiên đăng nhập người dùng
    final isLoggedIn = AuthService.instance.isLoggedIn;
    if (isLoggedIn) {
      return SplashRoute.home();
    }
    // Mặc định OpenFlix chuyển thẳng vào Catalog phim cho trải nghiệm tức thì
    return SplashRoute.home();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeService.instance,
      builder: (context, _) {
        final brandColor = ThemeService.instance.primaryColor;
        final bgColor = ThemeService.instance.backgroundColor;
        final taglineColor = Colors.white.withAlpha(200);

        return GlassSmartSplash(
          config:
              config ??
              SplashConfig(
                durationMs: 5000, // 5 giây loang lụa chuyển động mượt mà trước khi vào app
                animation: SplashAnimation.fadeScale(
                  durationMs: 900,
                  curve: Curves.easeOutCubic,
                ),
                layoutType: SplashLayoutType.logoWithText,
                backgroundColor: bgColor,
                appName: 'OPENFLIX',
                appNameStyle: TextStyle(
                  color: brandColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 34,
                  letterSpacing: 4.0,
                ),
                tagline: 'Điện ảnh không giới hạn',
                taglineStyle: TextStyle(
                  color: taglineColor,
                  fontSize: 13,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w500,
                ),
                showLoader: true,
                logo: SizedBox(
                  width: 104,
                  height: 104,
                  child: Image.memory(
                    kVMovie3dIconBytes,
                    width: 104,
                    height: 104,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                    errorBuilder: (_, _, _) => Image.asset(
                      'web/icons/Biểu tượng V xem phim 3D điện ảnh.png',
                      width: 104,
                      height: 104,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => Image.asset(
                        'assets/icons/app_icon.png',
                        width: 104,
                        height: 104,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) =>
                            const SizedBox(width: 104, height: 104),
                      ),
                    ),
                  ),
                ),
              ),
          onInit: onInit ?? _defaultStartupFlow,
        );
      },
    );
  }
}
