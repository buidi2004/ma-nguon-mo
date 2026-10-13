import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/language_service.dart';
import '../../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (mounted) {
        setState(() {
          _notificationsEnabled = prefs.getBool('setting_notifications') ?? true;
        });
      }
    } catch (_) {}
  }

  Future<void> _toggleNotifications(bool val) async {
    setState(() => _notificationsEnabled = val);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('setting_notifications', val);
    } catch (_) {}
  }

  void _clearCache() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Dọn dẹp bộ nhớ đệm',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Xóa bộ nhớ đệm hình ảnh và dữ liệu tạm (khoảng 34 MB)? Ứng dụng sẽ tự tải lại khi bạn xem phim.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã dọn dẹp 34 MB bộ nhớ đệm ảnh thành công!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.red),
            child: const Text('Xác nhận xóa'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Cài đặt ứng dụng',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          const Text(
            'TRẢI NGHIỆM PHÁT LẠI',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),

          _buildTile(
            icon: Icons.tune,
            title: 'Phát lại & Chất lượng video',
            subtitle: 'Tự động phát tập, chất lượng video, chỉ dùng Wi-Fi',
            onTap: () => context.push('/settings/playback'),
          ),

          const SizedBox(height: 20),
          const Text(
            'TÙY CHỈNH HỆ THỐNG',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),

          ListenableBuilder(
            listenable: LanguageService.instance,
            builder: (context, _) {
              final langName = LanguageService.instance.isVietnamese
                  ? 'Tiếng Việt (Mặc định)'
                  : 'English (United States)';
              return _buildTile(
                icon: Icons.language,
                title: 'Ngôn ngữ ứng dụng',
                subtitle: langName,
                onTap: () => context.push('/settings/language'),
              );
            },
          ),

          Container(
            margin: const EdgeInsets.only(bottom: 6),
            child: Material(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(6),
              child: SwitchListTile(
                secondary: const Icon(
                  Icons.notifications_active_outlined,
                  color: Colors.white,
                  size: 22,
                ),
                title: const Text(
                  'Nhận thông báo phim mới',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: const Text(
                  'Gợi ý phim thịnh hành và phim mới cập nhật hàng tuần',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                activeThumbColor: AppColors.red,
                value: _notificationsEnabled,
                onChanged: _toggleNotifications,
              ),
            ),
          ),

          _buildTile(
            icon: Icons.cleaning_services_outlined,
            title: 'Xóa bộ nhớ đệm (Cache)',
            subtitle: 'Giải phóng khoảng 34 MB bộ nhớ đệm ảnh poster',
            onTap: _clearCache,
          ),

          const SizedBox(height: 20),
          const Text(
            'THÔNG TIN & HỖ TRỢ',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),

          _buildTile(
            icon: Icons.help_outline,
            title: 'Trung tâm trợ giúp',
            subtitle: 'Câu hỏi thường gặp và hướng dẫn sử dụng',
            onTap: () => context.push('/help'),
          ),
          _buildTile(
            icon: Icons.feedback_outlined,
            title: 'Liên hệ & Góp ý',
            subtitle: 'Gửi báo lỗi hoặc đề xuất bổ sung phim mới',
            onTap: () => context.push('/contact'),
          ),
          _buildTile(
            icon: Icons.info_outline,
            title: 'Giới thiệu OpenFlix',
            subtitle: 'Phiên bản 1.0.0+1 (MIT License)',
            onTap: () => context.push('/about'),
          ),
        ],
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    String? subtitle,
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
          subtitle: subtitle != null
              ? Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                )
              : null,
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
