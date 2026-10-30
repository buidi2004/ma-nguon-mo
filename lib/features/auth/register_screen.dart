import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/app_text_field.dart';
import '../../presentation/widgets/glass/glass_components.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../waves_background.dart';

class RegisterScreen extends StatefulWidget {
  final String? redirect;

  const RegisterScreen({super.key, this.redirect});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Đích đến sau khi đăng ký thành công.
  ///
  /// Ưu tiên tham số `redirect` (ví dụ `/watch/:id`), mặc định về Trang chủ.
  String get _postAuthTarget {
    final redirect = widget.redirect;
    if (redirect != null && redirect.isNotEmpty) return redirect;
    return '/';
  }

  /// Vào thẳng app sau khi đăng ký thành công.
  ///
  /// Trước đây dùng `context.pop()` nên khi màn Đăng ký được mở từ màn Đăng
  /// nhập, người dùng bị đẩy ngược về chính màn Đăng nhập. Dùng `go` để thay
  /// thế toàn bộ ngăn xếp và loại bỏ các màn hình xác thực.
  void _enterApp() {
    if (!mounted) return;
    context.go(_postAuthTarget);
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Mật khẩu xác nhận không trùng khớp';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final success = await AuthService.instance.register(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đăng ký tài khoản thành công!'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 2),
        ),
      );
      _enterApp();
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage =
            'Không thể tạo tài khoản. Vui lòng kiểm tra lại thông tin.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WavesBackground.wrapIfBlue(Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: const GlassBackButton(fallbackRoute: '/'),
        title: Text(
          'Đăng ký tài khoản',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tạo tài khoản OpenFlix',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Chỉ mất 30 giây để bắt đầu trải nghiệm xem phim hoàn toàn miễn phí',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 24),

                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.red.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.red),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: AppColors.red,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                AppTextField(
                  controller: _nameController,
                  label: 'Tên của bạn',
                  hintText: 'Ví dụ: Nguyễn Văn A',
                  prefixIcon: Icons.person_outline,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Vui lòng nhập tên của bạn';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                AppTextField(
                  controller: _emailController,
                  label: 'Địa chỉ Email',
                  hintText: 'name@example.com',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Vui lòng nhập email';
                    }
                    if (!val.contains('@')) {
                      return 'Email không đúng định dạng';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                AppTextField(
                  controller: _passwordController,
                  label: 'Mật khẩu',
                  hintText: 'Tối thiểu 6 ký tự',
                  prefixIcon: Icons.lock_outline,
                  isPassword: true,
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Vui lòng nhập mật khẩu';
                    }
                    if (val.length < 6) {
                      return 'Mật khẩu tối thiểu 6 ký tự';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                AppTextField(
                  controller: _confirmPasswordController,
                  label: 'Xác nhận mật khẩu',
                  hintText: 'Nhập lại mật khẩu ở trên',
                  prefixIcon: Icons.lock_reset_outlined,
                  isPassword: true,
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Vui lòng xác nhận mật khẩu';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                GlassButton.brand(
                  text: 'Hoàn tất đăng ký',
                  isLoading: _isLoading,
                  height: 48,
                  borderRadius: 10,
                  onPressed: _handleRegister,
                ),

                SizedBox(height: 24),

                Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'Đã có tài khoản? ',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.pushReplacement('/login'),
                        child: Text(
                          'Đăng nhập ngay',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}
