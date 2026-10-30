import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/primary_button.dart';
import '../../presentation/widgets/glass/glass_components.dart';
import '../../theme/app_theme.dart';
import 'services/admin_auth_service.dart';
import '../../waves_background.dart';

class AdminAuthGateScreen extends StatefulWidget {
  final VoidCallback? onAuthenticated;

  const AdminAuthGateScreen({super.key, this.onAuthenticated});

  @override
  State<AdminAuthGateScreen> createState() => _AdminAuthGateScreenState();
}

class _AdminAuthGateScreenState extends State<AdminAuthGateScreen> {
  final _passwordController = TextEditingController();
  bool _obscureText = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleUnlock() async {
    final pass = _passwordController.text.trim();
    if (pass.isEmpty) {
      setState(() => _errorMessage = 'Vui lòng nhập mật khẩu quản trị');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final success = await AdminAuthService.instance.authenticate(pass);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      if (widget.onAuthenticated != null) {
        widget.onAuthenticated!();
      } else {
        context.pop(true);
      }
    } else {
      setState(() {
        _errorMessage = 'Mật khẩu không chính xác! (Gợi ý: 123)';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Xác thực thất bại! Mật khẩu quản trị mặc định là: 123',
          ),
          backgroundColor: AppColors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WavesBackground.wrapIfBlue(Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: const GlassBackButton(),
        title: Text(
          'Bảo mật Quản trị',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon Khiên bảo mật nổi bật
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.red.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.red.withValues(alpha: 0.5),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.admin_panel_settings_rounded,
                      color: AppColors.red,
                      size: 40,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Xác thực Quản trị viên',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Khu vực kiểm soát kho phim và giám sát máy chủ. Vui lòng nhập mật khẩu để mở khóa.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 24),

                  // Ô nhập mật khẩu
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mật khẩu quản trị *',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 6),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscureText,
                        keyboardType: TextInputType.visiblePassword,
                        autofocus: true,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          letterSpacing: 1.5,
                        ),
                        onSubmitted: (_) => _handleUnlock(),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.cardDark,
                          hintText: 'Nhập mật khẩu (ví dụ: 123)...',
                          hintStyle: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 15,
                            letterSpacing: 0,
                          ),
                          prefixIcon: Icon(
                            Icons.lock_outline_rounded,
                            color: AppColors.textMuted,
                            size: 20,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureText
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppColors.textMuted,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() => _obscureText = !_obscureText);
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: const BorderSide(
                              color: AppColors.red,
                              width: 1.5,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Thông báo lỗi nếu có
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          color: AppColors.red,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: AppColors.red,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 12),
                  // Gợi ý mật khẩu 123
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.key_rounded,
                          color: AppColors.warning,
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Mật khẩu quản trị mặc định: 123',
                            style: TextStyle(
                              color: AppColors.warning,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24),
                  PrimaryButton(
                    text: 'Mở khóa hệ thống',
                    isLoading: _isLoading,
                    icon: Icons.lock_open_rounded,
                    onPressed: _handleUnlock,
                  ),
                  SizedBox(height: 12),
                  TextButton(
                    onPressed: () => context.pop(),
                    child: Text(
                      'Quay lại màn hình cá nhân',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ));
  }
}
