import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';

class MeScreen extends StatelessWidget {
  const MeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Tài khoản & Cá nhân',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Hồ sơ người dùng
          ListenableBuilder(
            listenable: AuthService.instance,
            builder: (context, _) {
              final auth = AuthService.instance;
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.push('/profiles'),
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppColors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (auth.isLoggedIn) {
                            context.push('/me/account');
                          } else {
                            context.push('/welcome');
                          }
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              auth.userName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              auth.isLoggedIn
                                  ? auth.userEmail
                                  : 'Chưa đăng nhập • Chạm để đăng nhập',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.chevron_right,
                        color: AppColors.textMuted,
                      ),
                      onPressed: () {
                        if (auth.isLoggedIn) {
                          context.push('/me/account');
                        } else {
                          context.push('/welcome');
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 24),
          const Text(
            'NỘI DUNG CỦA TÔI',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          _buildTile(
            icon: Icons.bookmark_border,
            title: 'Danh sách của tôi',
            onTap: () => context.push('/me/list'),
          ),
          _buildTile(
            icon: Icons.play_circle_outline,
            title: 'Đang xem dở',
            onTap: () => context.push('/me/continue'),
          ),
          _buildTile(
            icon: Icons.history,
            title: 'Lịch sử xem phim',
            onTap: () => context.push('/me/history'),
          ),
          _buildTile(
            icon: Icons.thumb_up_alt_outlined,
            title: 'Phim đã thích',
            onTap: () => context.push('/me/liked'),
          ),
          _buildTile(
            icon: Icons.notifications_none,
            title: 'Thông báo hệ thống',
            onTap: () => context.push('/me/notifications'),
          ),
          _buildTile(
            icon: Icons.download_for_offline_outlined,
            title: 'Tệp tải xuống & Offline',
            onTap: () => context.push('/me/downloads'),
          ),

          const SizedBox(height: 24),
          const Text(
            'TÀI KHOẢN & DỊCH VỤ',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          _buildTile(
            icon: Icons.manage_accounts_outlined,
            title: 'Thông tin tài khoản',
            onTap: () => context.push('/me/account'),
          ),
          _buildTile(
            icon: Icons.lock_outline,
            title: 'Đổi mật khẩu',
            onTap: () => context.push('/me/password'),
          ),
          _buildTile(
            icon: Icons.card_membership_outlined,
            title: 'Gói thành viên OpenFlix',
            onTap: () => context.push('/plans'),
          ),
          _buildTile(
            icon: Icons.tune,
            title: 'Cài đặt phát lại & chất lượng',
            onTap: () => context.push('/settings/playback'),
          ),
          _buildTile(
            icon: Icons.language,
            title: 'Ngôn ngữ hiển thị',
            onTap: () => context.push('/settings/language'),
          ),

          const SizedBox(height: 24),
          const Text(
            'HỖ TRỢ & HỆ THỐNG',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          _buildTile(
            icon: Icons.help_outline,
            title: 'Trợ giúp & Câu hỏi thường gặp',
            onTap: () => context.push('/help'),
          ),
          _buildTile(
            icon: Icons.feedback_outlined,
            title: 'Liên hệ & Góp ý',
            onTap: () => context.push('/contact'),
          ),
          _buildTile(
            icon: Icons.info_outline,
            title: 'Giới thiệu & Giấy phép MIT',
            onTap: () => context.push('/about'),
          ),
          _buildTile(
            icon: Icons.wifi_off_outlined,
            title: 'Màn hình mất kết nối (S39)',
            onTap: () => context.push('/offline'),
          ),
          _buildTile(
            icon: Icons.error_outline,
            title: 'Màn hình báo lỗi hệ thống (S40)',
            onTap: () => context.push('/error'),
          ),
          _buildTile(
            icon: Icons.search_off_rounded,
            title: 'Màn hình không tìm thấy (404 - S41)',
            onTap: () => context.push('/404'),
          ),

          const SizedBox(height: 24),

          // Đăng xuất hoặc Đăng nhập
          ListenableBuilder(
            listenable: AuthService.instance,
            builder: (context, _) {
              final auth = AuthService.instance;
              if (!auth.isLoggedIn) {
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => context.push('/welcome'),
                    icon: const Icon(Icons.login, color: Colors.white),
                    label: const Text(
                      'Đăng nhập tài khoản',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.red,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                );
              }
              return SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _confirmLogout(context),
                  icon: const Icon(Icons.logout, color: AppColors.red, size: 20),
                  label: const Text(
                    'Đăng xuất khỏi thiết bị',
                    style: TextStyle(
                      color: AppColors.red,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.red),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 36),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Đăng xuất tài khoản',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Bạn có chắc chắn muốn đăng xuất khỏi ứng dụng OpenFlix không?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await AuthService.instance.logout();
              if (context.mounted) {
                context.go('/welcome');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.red),
            child: const Text(
              'Đăng xuất',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(6),
        child: ListTile(
          leading: Icon(icon, color: Colors.white, size: 22),
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: const Icon(
            Icons.chevron_right,
            color: AppColors.textMuted,
            size: 20,
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
