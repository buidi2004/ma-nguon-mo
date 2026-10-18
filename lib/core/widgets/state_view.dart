import 'package:flutter/material.dart';

import '../../services/theme_service.dart';
import '../../theme/app_theme.dart';
import 'primary_button.dart';

class StateView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionText;
  final VoidCallback? onAction;
  final bool isLoading;

  const StateView({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionText,
    this.onAction,
    this.isLoading = false,
  });

  factory StateView.loading({String message = 'Đang tải dữ liệu...'}) {
    return StateView(
      icon: Icons.hourglass_empty_rounded,
      title: 'Vui lòng chờ giây lát',
      message: message,
      isLoading: true,
    );
  }

  factory StateView.empty({
    String title = 'Chưa có nội dung',
    String message =
        'Danh sách hiện đang trống. Hãy khám phá và thêm các bộ phim hấp dẫn!',
    IconData icon = Icons.movie_outlined,
    String? actionText,
    VoidCallback? onAction,
  }) {
    return StateView(
      icon: icon,
      title: title,
      message: message,
      actionText: actionText,
      onAction: onAction,
    );
  }

  factory StateView.error({
    String title = 'Không thể tải dữ liệu',
    String message =
        'Đã có lỗi xảy ra trong quá trình xử lý. Vui lòng thử lại sau.',
    VoidCallback? onRetry,
  }) {
    return StateView(
      icon: Icons.error_outline_rounded,
      title: title,
      message: message,
      actionText: 'Thử lại',
      onAction: onRetry,
    );
  }

  factory StateView.offline({VoidCallback? onRetry}) {
    return StateView(
      icon: Icons.wifi_off_rounded,
      title: 'Mất kết nối Internet',
      message: 'Vui lòng kiểm tra lại kết nối mạng hoặc chuyển sang xem các bộ phim đã tải.',
      actionText: 'Thử kết nối lại',
      onAction: onRetry,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 38,
                  height: 38,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      ThemeService.instance.primaryColor,
                    ),
                    strokeWidth: 3,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white12),
                ),
                child: Icon(
                  icon,
                  size: 54,
                  color: ThemeService.instance.primaryColor,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  height: 1.45,
                ),
              ),
              if (actionText != null && onAction != null) ...[
                const SizedBox(height: 24),
                SizedBox(
                  width: 180,
                  child: PrimaryButton(
                    text: actionText!,
                    onPressed: onAction,
                    height: 42,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
