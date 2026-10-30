import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../theme/app_theme.dart';

/// Nút bấm thao tác nguy hiểm / cảnh báo kính mờ (Optical Glass Destructive Button).
/// Chuyên dùng cho các hành động xóa vĩnh viễn, đăng xuất, hủy gói thành viên:
/// - Kính thẫm ánh đỏ cảnh báo [AppColors.red] với độ trong suốt tinh tế.
/// - Tùy chọn hộp thoại xác nhận kính mờ tự động [requiresConfirmation].
/// - Hiển thị trạng thái đang thực hiện [isLoading] ngăn bấm lặp lại.
/// - Phản hồi rung xúc giác nặng [HapticFeedback.mediumImpact].
class GlassDestructiveButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final double height;
  final double? width;
  final double borderRadius;
  final bool requiresConfirmation;
  final String? confirmationTitle;
  final String? confirmationMessage;
  final String confirmActionLabel;
  final String cancelActionLabel;
  final bool enableHaptic;

  const GlassDestructiveButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.height = 48.0,
    this.width,
    this.borderRadius = 24.0,
    this.requiresConfirmation = false,
    this.confirmationTitle,
    this.confirmationMessage,
    this.confirmActionLabel = 'Xác nhận xóa',
    this.cancelActionLabel = 'Hủy bỏ',
    this.enableHaptic = true,
  });

  /// Factory tiện ích cho thao tác Đăng xuất tài khoản
  factory GlassDestructiveButton.logout({
    Key? key,
    required VoidCallback? onPressed,
    bool isLoading = false,
    double borderRadius = 24.0,
  }) {
    return GlassDestructiveButton(
      key: key,
      text: 'Đăng xuất tài khoản',
      icon: Icons.logout_rounded,
      isLoading: isLoading,
      borderRadius: borderRadius,
      requiresConfirmation: true,
      confirmationTitle: 'Đăng xuất',
      confirmationMessage: 'Bạn có chắc chắn muốn đăng xuất khỏi tài khoản OpenFlix trên thiết bị này?',
      confirmActionLabel: 'Đăng xuất',
      onPressed: onPressed,
    );
  }

  /// Factory tiện ích cho thao tác Xóa hồ sơ người dùng
  factory GlassDestructiveButton.deleteProfile({
    Key? key,
    required String profileName,
    required VoidCallback? onPressed,
    bool isLoading = false,
    double borderRadius = 24.0,
  }) {
    return GlassDestructiveButton(
      key: key,
      text: 'Xóa hồ sơ này',
      icon: Icons.delete_forever_rounded,
      isLoading: isLoading,
      borderRadius: borderRadius,
      requiresConfirmation: true,
      confirmationTitle: 'Xóa hồ sơ $profileName',
      confirmationMessage: 'Toàn bộ lịch sử xem và danh sách phim của hồ sơ này sẽ bị xóa vĩnh viễn. Hành động này không thể hoàn tác.',
      confirmActionLabel: 'Xác nhận xóa',
      onPressed: onPressed,
    );
  }

  @override
  State<GlassDestructiveButton> createState() => _GlassDestructiveButtonState();
}

class _GlassDestructiveButtonState extends State<GlassDestructiveButton> {
  bool _isPressed = false;
  bool _isHovered = false;

  void _handleTapDown(TapDownDetails _) {
    if (widget.onPressed == null || widget.isLoading) return;
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails _) {
    setState(() => _isPressed = false);
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  Future<void> _handleTap() async {
    if (widget.onPressed == null || widget.isLoading) return;

    if (widget.enableHaptic) {
      HapticFeedback.mediumImpact();
    }

    if (widget.requiresConfirmation) {
      final bool? confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: AppColors.red.withValues(alpha: 0.40),
              width: 1.0,
            ),
          ),
          title: Text(
            widget.confirmationTitle ?? 'Xác nhận thao tác',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
          content: Text(
            widget.confirmationMessage ?? 'Hành động này có thể xóa vĩnh viễn dữ liệu. Bạn có chắc chắn muốn tiếp tục?',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
              height: 1.4,
            ),
          ),
          actionsPadding: EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(
                widget.cancelActionLabel,
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(
                widget.confirmActionLabel,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );

      if (confirmed != true) return;
    }

    widget.onPressed!();
  }

  @override
  Widget build(BuildContext context) {
    final isInteractive = widget.onPressed != null && !widget.isLoading;

    final Color backgroundColor = _isPressed
        ? AppColors.red.withValues(alpha: 0.32)
        : (_isHovered
              ? AppColors.red.withValues(alpha: 0.22)
              : AppColors.red.withValues(alpha: 0.12));

    final Color borderColor = _isHovered || _isPressed
        ? AppColors.red.withValues(alpha: 0.85)
        : AppColors.red.withValues(alpha: 0.45);

    final Color contentColor = isInteractive
        ? const Color(0xFFFF5252)
        : const Color(0xFFFF5252).withValues(alpha: 0.38);

    return Semantics(
      button: true,
      enabled: isInteractive,
      label: widget.text,
      child: FocusableActionDetector(
        onShowHoverHighlight: (v) => setState(() => _isHovered = v),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: isInteractive ? _handleTapDown : null,
          onTapUp: isInteractive ? _handleTapUp : null,
          onTapCancel: isInteractive ? _handleTapCancel : null,
          onTap: isInteractive ? _handleTap : null,
          child: AnimatedScale(
            scale: _isPressed ? 0.96 : (_isHovered ? 1.02 : 1.0),
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOutCubic,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              width: widget.width,
              height: widget.height,
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                color: backgroundColor,
                border: Border.all(color: borderColor, width: 1.0),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.red.withValues(
                      alpha: _isHovered ? 0.30 : 0.12,
                    ),
                    blurRadius: _isHovered ? 14 : 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: widget.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFFFF5252),
                          ),
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.icon != null) ...[
                            Icon(widget.icon, size: 20, color: contentColor),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            widget.text,
                            style: TextStyle(
                              color: contentColor,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
