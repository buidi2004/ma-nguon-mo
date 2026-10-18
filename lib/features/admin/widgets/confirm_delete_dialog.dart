import 'dart:async';

import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

/// Dialog xác nhận xóa phim dùng chung cho phân hệ quản trị
/// Tuân thủ chuẩn Netflix-inspired và AGENTS.md
class ConfirmDeleteDialog extends StatefulWidget {
  final String movieTitle;
  final FutureOr<void> Function()? onConfirm;
  final VoidCallback? onCancel;
  final bool isLoading;

  const ConfirmDeleteDialog({
    super.key,
    required this.movieTitle,
    this.onConfirm,
    this.onCancel,
    this.isLoading = false,
  });

  /// Phương thức static thuận tiện để hiển thị dialog xác nhận xóa
  static Future<bool?> show(
    BuildContext context, {
    required String movieTitle,
    FutureOr<void> Function()? onConfirm,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) =>
          ConfirmDeleteDialog(movieTitle: movieTitle, onConfirm: onConfirm),
    );
  }

  @override
  State<ConfirmDeleteDialog> createState() => _ConfirmDeleteDialogState();
}

class _ConfirmDeleteDialogState extends State<ConfirmDeleteDialog> {
  bool _internalLoading = false;

  bool get _isBusy => widget.isLoading || _internalLoading;

  Future<void> _handleConfirm() async {
    if (_isBusy) return;

    if (widget.onConfirm != null) {
      setState(() => _internalLoading = true);
      try {
        await widget.onConfirm!();
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        if (mounted) {
          setState(() => _internalLoading = false);
        }
        rethrow;
      }
    } else {
      Navigator.of(context).pop(true);
    }
  }

  void _handleCancel() {
    if (_isBusy) return;
    if (widget.onCancel != null) {
      widget.onCancel!();
    } else {
      Navigator.of(context).pop(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      actionsPadding: const EdgeInsets.fromLTRB(16, 16, 20, 20),
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.red.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: AppColors.red,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Xác nhận xóa phim?',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: Text.rich(
        TextSpan(
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            height: 1.5,
          ),
          children: [
            const TextSpan(text: 'Bạn có chắc chắn muốn xóa phim '),
            TextSpan(
              text: '"${widget.movieTitle}"',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const TextSpan(
              text: ' khỏi hệ thống? Hành động này không thể hoàn tác.',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isBusy ? null : _handleCancel,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textSecondary,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            minimumSize: const Size(44, 44),
          ),
          child: const Text(
            'Hủy',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _isBusy ? null : _handleConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.red,
            disabledBackgroundColor: AppColors.red.withValues(alpha: 0.5),
            foregroundColor: AppColors.textPrimary,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            minimumSize: const Size(44, 44),
          ),
          child: _isBusy
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.textPrimary,
                    ),
                  ),
                )
              : const Text(
                  'Xác nhận xóa',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
        ),
      ],
    );
  }
}
