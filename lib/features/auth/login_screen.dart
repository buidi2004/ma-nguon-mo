import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/app_text_field.dart';
import '../../presentation/widgets/glass/glass_components.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  final String? redirect;

  const LoginScreen({super.key, this.redirect});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final success = await AuthService.instance.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đăng nhập thành công! Chào mừng trở lại OpenFlix.'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 2),
        ),
      );
      if (widget.redirect != null && widget.redirect!.isNotEmpty) {
        context.pushReplacement(widget.redirect!);
      } else if (context.canPop()) {
        context.pop();
      } else {
        context.go('/');
      }
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage =
            'Email hoặc mật khẩu không chính xác. Mật khẩu phải từ 6 ký tự.';
      });
    }
  }

  void _fillDemoAccount() {
    _emailController.text = 'demo@openflix.vn';
    _passwordController.text = '123456';
    _handleLogin();
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);
    try {
      final success = await AuthService.instance.signInWithGoogle();
      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Đăng nhập Google thành công! Chào ${AuthService.instance.userName}',
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
        if (widget.redirect != null && widget.redirect!.isNotEmpty) {
          context.pushReplacement(widget.redirect!);
        } else if (context.canPop()) {
          context.pop();
        } else {
          context.go('/');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã hủy đăng nhập Google.'),
            backgroundColor: AppColors.surfaceLight,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      String message = 'Lỗi đăng nhập Google: $e';
      if (e.toString().contains('10') || e.toString().contains('DEVELOPER_ERROR')) {
        message = 'Lỗi xác thực Google (Mã 10): Cần thêm mã SHA-1 của máy/keystore vào Google Cloud Console.';
      } else if (e.toString().contains('12500')) {
        message = 'Lỗi OAuth: Cần thêm email vào mục Test Users trên Google Cloud Console (OAuth Consent Screen).';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: const GlassBackButton(fallbackRoute: '/'),
        title: const Text(
          'Đăng nhập',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Chào mừng trở lại',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Đăng nhập để tiếp tục xem phim và quản lý danh sách',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13.5,
                  ),
                ),
                const SizedBox(height: 28),

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
                  controller: _emailController,
                  label: 'Email',
                  hintText: 'name@example.com',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Vui lòng nhập email';
                    }
                    if (!val.contains('@')) {
                      return 'Email không hợp lệ';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 18),

                AppTextField(
                  controller: _passwordController,
                  label: 'Mật khẩu',
                  hintText: 'Nhập mật khẩu của bạn',
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

                const SizedBox(height: 10),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.push('/forgot-password'),
                    child: const Text(
                      'Quên mật khẩu?',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                GlassButton.brand(
                  text: 'Đăng nhập',
                  isLoading: _isLoading,
                  height: 48,
                  borderRadius: 10,
                  onPressed: _handleLogin,
                ),

                const SizedBox(height: 14),

                // Nút đăng nhập nhanh Demo kính mờ
                Center(
                  child: GlassButton.capsule(
                    text: '1-Click Đăng nhập Demo',
                    icon: Icons.bolt_rounded,
                    style: GlassButtonStyle.neutralDark,
                    height: 42,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    onPressed: _isLoading ? null : _fillDemoAccount,
                  ),
                ),

                const SizedBox(height: 20),

                // Phân cách hoặc tiếp tục với
                Row(
                  children: [
                    const Expanded(child: Divider(color: Colors.white12)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'Hoặc đăng nhập với',
                        style: TextStyle(
                          color: AppColors.textMuted.withValues(alpha: 0.8),
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider(color: Colors.white12)),
                  ],
                ),

                const SizedBox(height: 16),

                // Cặp nút kính mờ đăng nhập Google / Apple
                Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      GlassButton.capsule(
                        text: 'Google',
                        icon: Icons.g_mobiledata_rounded,
                        style: GlassButtonStyle.neutralDark,
                        height: 38,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        onPressed: _isLoading ? null : _handleGoogleLogin,
                      ),
                      GlassButton.capsule(
                        text: 'Apple',
                        icon: Icons.apple_rounded,
                        style: GlassButtonStyle.neutralDark,
                        height: 38,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Đang kết nối Apple ID...'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const Text(
                        'Chưa có tài khoản? ',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13.5,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          final registerUrl = (widget.redirect != null &&
                                  widget.redirect!.isNotEmpty)
                              ? '/register?redirect=${Uri.encodeComponent(widget.redirect!)}'
                              : '/register';
                          context.push(registerUrl);
                        },
                        child: const Text(
                          'Đăng ký ngay',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13.5,
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
    );
  }
}
