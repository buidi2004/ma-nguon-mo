import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/primary_button.dart';
import '../../services/auth_service.dart';
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
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Chọn biểu tượng đại diện',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildAvatarOption(ctx, Icons.person, AppColors.red),
                    _buildAvatarOption(ctx, Icons.movie_outlined, Colors.blue),
                    _buildAvatarOption(ctx, Icons.star_border, Colors.amber),
                    _buildAvatarOption(ctx, Icons.face, Colors.purple),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAvatarOption(BuildContext ctx, IconData icon, Color color) {
    return InkWell(
      onTap: () {
        Navigator.pop(ctx);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã cập nhật ảnh đại diện hồ sơ!'),
            backgroundColor: AppColors.success,
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white, size: 32),
      ),
    );
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
        title: const Text(
          'Thông tin tài khoản',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // Avatar lớn
          Center(
            child: GestureDetector(
              onTap: _showAvatarPicker,
              child: Stack(
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: AppColors.red,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(Icons.person, color: Colors.white, size: 52),
                    ),
                  ),
                  Positioned(
                    bottom: -2,
                    right: -2,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Center(
            child: Text(
              'Chạm để đổi biểu tượng đại diện',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              _authService.userEmail,
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
              icon: const Icon(Icons.logout, color: AppColors.red, size: 20),
              label: const Text(
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
