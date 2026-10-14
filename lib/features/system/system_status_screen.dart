import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_theme.dart';

class SystemStatusScreen extends StatelessWidget {
  final String code;
  final String title;
  final String message;
  final IconData icon;
  final VoidCallback? onRetry;

  const SystemStatusScreen({
    super.key,
    required this.code,
    required this.title,
    required this.message,
    required this.icon,
    this.onRetry,
  });

  factory SystemStatusScreen.offline({VoidCallback? onRetry}) {
    return SystemStatusScreen(
      code: 'S39',
      title: 'Mất kết nối Internet',
      message: 'Không thể kết nối đến máy chủ OpenFlix. Vui lòng kiểm tra lại kết nối Wi-Fi hoặc dữ liệu di động của bạn.',
      icon: Icons.wifi_off_rounded,
      onRetry: onRetry,
    );
  }

  factory SystemStatusScreen.error({
    String? customMessage,
    VoidCallback? onRetry,
  }) {
    return SystemStatusScreen(
      code: 'S40',
      title: 'Đã xảy ra lỗi hệ thống',
      message: customMessage ?? 'Hệ thống đang gặp sự cố khi xử lý dữ liệu. Vui lòng thử lại hoặc khởi động lại ứng dụng.',
      icon: Icons.error_outline_rounded,
      onRetry: onRetry,
    );
  }

  factory SystemStatusScreen.notFound({
    String? attemptedPath,
    VoidCallback? onRetry,
  }) {
    return SystemStatusScreen(
      code: 'S41',
      title: 'Không tìm thấy trang (404)',
      message: attemptedPath != null
          ? 'Đường dẫn "$attemptedPath" không tồn tại hoặc nội dung đã bị thay đổi.'
          : 'Trang bạn đang tìm kiếm không tồn tại hoặc đã được gỡ bỏ.',
      icon: Icons.search_off_rounded,
      onRetry: onRetry,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white12),
                ),
                child: Icon(icon, size: 64, color: AppColors.red),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  code,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                softWrap: true,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onRetry ?? () => context.go('/'),
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  label: const Text(
                    'Thử lại kết nối',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.red,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.go('/'),
                child: const Text(
                  'Về Trang chủ',
                  style: TextStyle(color: Colors.white60),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
