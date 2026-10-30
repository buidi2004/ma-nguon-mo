import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/app_text_field.dart';
import '../../presentation/widgets/glass/glass_components.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../waves_background.dart';

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

  /// Đích đến sau khi xác thực thành công.
  ///
  /// Ưu tiên tham số `redirect` (ví dụ `/watch/:id` sau khi mở khóa phim),
  /// mặc định đưa thẳng về Trang chủ của ứng dụng.
  String get _postAuthTarget {
    final redirect = widget.redirect;
    if (redirect != null && redirect.isNotEmpty) return redirect;
    return '/';
  }

  /// Vào thẳng app sau khi xác thực thành công.
  ///
  /// Dùng `go` để thay thế toàn bộ ngăn xếp điều hướng, đảm bảo các màn hình
  /// xác thực (Đăng nhập / Đăng ký / Chào mừng) bị loại bỏ hoàn toàn — không
  /// còn hiện tượng đăng nhập xong lại quay về màn đăng nhập cũ.
  void _enterApp() {
    if (!mounted) return;
    context.go(_postAuthTarget);
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
      _enterApp();
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

  void _showGoogleError10Dialog() {
    const sha1 = '28:32:8A:1F:30:8F:CB:B9:69:97:03:F7:91:CF:C3:44:C3:8A:FA:33';
    const pkg = 'com.openflix.app';

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.amber,
                  size: 28,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Lỗi Google Sign-In (Mã 10: DEVELOPER_ERROR)',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              'Nguyên nhân: Google Play Services từ chối vì chứng chỉ SHA-1 của thiết bị này chưa được khai báo trên Google Cloud Console.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.dynamicBackground,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Package Name:',
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                  const SelectableText(
                    pkg,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'SHA-1 Fingerprint của máy:',
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                  const SelectableText(
                    sha1,
                    style: TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 36,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Clipboard.setData(const ClipboardData(text: sha1));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Đã sao chép SHA-1 vào clipboard!'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.copy,
                        size: 16,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Sao chép mã SHA-1',
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white24),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton.icon(
                onPressed: () async {
                  Navigator.pop(ctx);
                  await AuthService.instance.loginWithGoogleDemo();
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Đăng nhập Google Demo thành công! Chào ${AuthService.instance.userName}',
                      ),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  _enterApp();
                },
                icon: const Icon(Icons.account_circle, color: Colors.white),
                label: Text(
                  'Đăng nhập bằng Google Demo (Vào ngay)',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.red),
              ),
            ),
          ],
        ),
      ),
    );
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
            duration: Duration(seconds: 2),
          ),
        );
        _enterApp();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã hủy đăng nhập Google.'),
            backgroundColor: AppColors.surfaceLight,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      if (e.toString().contains('10') ||
          e.toString().contains('DEVELOPER_ERROR')) {
        _showGoogleError10Dialog();
      } else if (e.toString().contains('12500')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Lỗi OAuth (12500): Cần thêm email vào mục Test Users trên Google Cloud Console.',
            ),
            backgroundColor: AppColors.red,
            duration: Duration(seconds: 5),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi đăng nhập Google: $e'),
            backgroundColor: AppColors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WavesBackground.wrapIfBlue(Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: const GlassBackButton(fallbackRoute: '/'),
        title: Text(
          'Đăng nhập',
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
                  'Chào mừng trở lại',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Đăng nhập để tiếp tục xem phim và quản lý danh sách',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
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

                SizedBox(height: 10),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.push('/forgot-password'),
                    child: Text(
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

                SizedBox(height: 28),

                Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'Chưa có tài khoản? ',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          final registerUrl =
                              (widget.redirect != null &&
                                  widget.redirect!.isNotEmpty)
                              ? '/register?redirect=${Uri.encodeComponent(widget.redirect!)}'
                              : '/register';
                          context.push(registerUrl);
                        },
                        child: const Text(
                          'Đăng ký ngay',
                          style: TextStyle(
                            color: Colors.white,
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
