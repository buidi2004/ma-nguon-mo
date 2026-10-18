import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/widgets/glass/glass_components.dart';
import '../../services/theme_service.dart';
import '../../theme/app_theme.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Nền mờ nghệ thuật
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 380,
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.4),
                  radius: 1.2,
                  colors: [
                    ThemeService.instance.primaryColor
                        .withValues(alpha: 0.25),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 20,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  Text(
                    'OPENFLIX',
                    style: TextStyle(
                      color: ThemeService.instance.primaryColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 38,
                      letterSpacing: 4.0,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Nền tảng xem phim mã nguồn mở',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Đăng nhập để lưu tiến độ xem, tạo danh sách yêu thích và đồng bộ hóa đa thiết bị.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13.5,
                      height: 1.45,
                    ),
                  ),
                  const Spacer(),

                  // Nút Đăng nhập - Kính ánh đỏ Netflix
                  GlassButton.brand(
                    text: 'Đăng nhập',
                    borderRadius: 14,
                    width: double.infinity,
                    height: 48,
                    onPressed: () => context.push('/login'),
                  ),

                  const SizedBox(height: 12),

                  // Nút Đăng ký tài khoản - Kính viên thuốc bo cong hoàn toàn
                  GlassButton.capsule(
                    text: 'Tạo tài khoản mới',
                    width: double.infinity,
                    height: 48,
                    onPressed: () => context.push('/register'),
                  ),

                  const SizedBox(height: 16),

                  // Lựa chọn Xem thử không cần tài khoản
                  TextButton(
                    onPressed: () => context.go('/'),
                    child: const Text(
                      'Khám phá ngay (Không cần đăng nhập)',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13.5,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
