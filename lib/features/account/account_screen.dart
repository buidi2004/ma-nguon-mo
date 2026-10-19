import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/primary_button.dart';
import '../../presentation/widgets/brand/user_avatar_circle.dart';
import '../../presentation/widgets/dialogs/user_avatar_dialog.dart';
import '../../presentation/widgets/glass/glass_components.dart';
import '../../services/auth_service.dart';
import '../../services/theme_service.dart';
import '../../theme/app_theme.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final _nameController = TextEditingController();
  final _authService = AuthService.instance;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = _authService.userName;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Họ và tên hiển thị không được để trống!'),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    await _authService.updateProfile(newName);
    if (!mounted) return;
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã cập nhật thông tin tài khoản thành công!'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _showAvatarPicker() {
    UserAvatarDialog.show(context);
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text(
            'Đăng xuất tài khoản',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Bạn có chắc chắn muốn đăng xuất khỏi ứng dụng OpenFlix không?',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _authService.logout();
                if (context.mounted) {
                  context.go('/welcome');
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.red),
              child: const Text('Đăng xuất'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: const GlassBackButton(),
        title: const Text(
          'Thông tin tài khoản',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // Avatar lớn người dùng (Chibi dễ thương / Link ảnh / Hào quang phát sáng)
          Center(
            child: GestureDetector(
              onTap: _showAvatarPicker,
              behavior: HitTestBehavior.opaque,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  const UserAvatarCircle(
                    size: 96,
                    showGlow: true,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.85),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white38,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.5),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: InkWell(
              onTap: _showAvatarPicker,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.edit_outlined,
                      size: 14,
                      color: ThemeService.instance.primaryColor,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Đổi ảnh đại diện',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: ThemeService.instance.primaryColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              _authService.userEmail,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13.5,
              ),
            ),
          ),
          const SizedBox(height: 28),

          AppTextField(
            controller: _nameController,
            label: 'Họ và tên hiển thị',
            prefixIcon: Icons.badge_outlined,
          ),

          const SizedBox(height: 16),

          // Địa chỉ Email (không cho sửa trực tiếp)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Địa chỉ Email',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _authService.userEmail,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Email liên kết tài khoản dùng để đăng nhập và bảo mật',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
            ],
          ),

          const SizedBox(height: 24),

          PrimaryButton.white(
            text: 'Lưu thay đổi',
            isLoading: _isLoading,
            onPressed: _handleSave,
          ),

          const SizedBox(height: 16),

          OutlinedButton.icon(
            onPressed: () => context.push('/me/password'),
            icon: const Icon(Icons.lock_outline, size: 18),
            label: const Text('Đổi mật khẩu tài khoản'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white24),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),

          const SizedBox(height: 36),

          // Nút Đăng xuất
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: _handleLogout,
              icon: Icon(Icons.logout, color: AppColors.red, size: 20),
              label: Text(
                'Đăng xuất khỏi thiết bị',
                style: TextStyle(
                  color: AppColors.red,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
