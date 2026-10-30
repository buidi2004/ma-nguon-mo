import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/widgets/brand/user_avatar_circle.dart';
import '../../presentation/widgets/dialogs/user_avatar_dialog.dart';
import '../../presentation/widgets/glass/glass_components.dart';
import '../../services/auth_service.dart';
import '../../services/theme_service.dart';
import '../../theme/app_theme.dart';
import '../../waves_background.dart';
import '../admin/services/admin_auth_service.dart';

class MeScreen extends StatefulWidget {
  const MeScreen({super.key});

  @override
  State<MeScreen> createState() => _MeScreenState();
}

class _MeScreenState extends State<MeScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final scaffold = Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        leading: const GlassBackButton(fallbackRoute: '/'),
        title: Text(
          'Tài khoản & Cá nhân',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GlassIconButton.circle(
              size: 38,
              iconSize: 20,
              icon: Icons.settings_outlined,
              tooltip: 'Cài đặt',
              onPressed: () => context.push('/settings'),
            ),
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
              final isBlue = ThemeService.instance.isWindowsBlue;
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isBlue ? const Color(0xCC0A2433) : AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isBlue ? const Color(0x335AD2F4) : Colors.white10,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => UserAvatarDialog.show(context),
                      behavior: HitTestBehavior.opaque,
                      child: Tooltip(
                        message: 'Chạm để đổi ảnh đại diện',
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            const UserAvatarCircle(size: 52, showGlow: true),
                            Positioned(
                              bottom: -2,
                              right: -2,
                              child: IgnorePointer(
                                child: Container(
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.75),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white30,
                                      width: 1,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.edit_rounded,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
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
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              auth.isLoggedIn
                                  ? auth.userEmail
                                  : 'Chưa đăng nhập • Chạm để đăng nhập',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
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

          SizedBox(height: 24),
          Text(
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

          SizedBox(height: 24),
          Text(
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

          SizedBox(height: 24),
          Text(
            'QUẢN TRỊ HỆ THỐNG',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          _buildTile(
            icon: Icons.movie_filter_rounded,
            iconColor: ThemeService.instance.primaryColor,
            title: 'Quản lý nội dung phim',
            subtitle: 'Thêm, sửa, xóa và kiểm soát trạng thái phát hành',
            onTap: () {
              if (AdminAuthService.instance.isAuthenticated) {
                context.push('/admin/movies');
              } else {
                context.push('/admin/auth', extra: '/admin/movies');
              }
            },
          ),
          _buildTile(
            icon: Icons.speed_rounded,
            iconColor: Color(0xFF22C55E),
            title: 'Giám sát máy chủ (Real-time)',
            subtitle: 'Theo dõi RAM, CPU, Storage, Ping máy chủ VPS',
            onTap: () {
              if (AdminAuthService.instance.isAuthenticated) {
                context.push('/admin/server');
              } else {
                context.push('/admin/auth', extra: '/admin/server');
              }
            },
          ),

          SizedBox(height: 24),
          Text(
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
            icon: Icons.support_agent_outlined,
            title: 'Liên hệ & Hỗ trợ kỹ thuật',
            onTap: () => context.push('/contact'),
          ),
          _buildTile(
            icon: Icons.feedback_outlined,
            title: 'Báo lỗi phát phim & Góp ý',
            onTap: () => context.push('/feedback'),
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
                return GlassButton.capsule(
                  text: 'Đăng nhập tài khoản',
                  icon: Icons.login_rounded,
                  style: GlassButtonStyle.brandRed,
                  height: 48,
                  onPressed: () => context.push('/welcome'),
                );
              }
              return GlassDestructiveButton.logout(
                borderRadius: 24,
                onPressed: () async {
                  await AuthService.instance.logout();
                  if (context.mounted) {
                    context.go('/welcome');
                  }
                },
              );
            },
          ),
          const SizedBox(height: 36),
        ],
      ),
    );
    return WavesBackground.wrapIfBlue(scaffold);
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? iconColor,
    required VoidCallback onTap,
  }) {
    final isBlue = ThemeService.instance.isWindowsBlue;
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      decoration: BoxDecoration(
        color: isBlue ? const Color(0xCC0A2433) : AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isBlue ? const Color(0x265AD2F4) : Colors.white10,
          width: 0.8,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: ListTile(
          dense: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          leading: Icon(
            icon,
            color: iconColor ?? (isBlue ? const Color(0xFF66C7F4) : Colors.white),
            size: 22,
          ),
          title: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isBlue
                  ? const Color(0xFFE2F1FF)
                  : Theme.of(context).colorScheme.onSurface,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: subtitle != null
              ? Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isBlue ? const Color(0xFF94A3B8) : AppColors.textSecondary,
                    fontSize: 12,
                  ),
                )
              : null,
          trailing: Icon(
            Icons.chevron_right,
            color: isBlue ? const Color(0x805AD2F4) : AppColors.textMuted,
            size: 20,
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
