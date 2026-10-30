import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../presentation/widgets/glass/glass_components.dart';
import '../../services/language_service.dart';
import '../../services/pocketbase_service.dart';
import '../../services/theme_service.dart';
import '../../theme/app_theme.dart';
import '../../waves_background.dart';

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
          _notificationsEnabled =
              prefs.getBool('setting_notifications') ?? true;
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
        title: Text(
          'Dọn dẹp bộ nhớ đệm',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
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
              // Thực sự giải phóng toàn bộ bộ nhớ đệm bitmap trong RAM & cache PocketBase
              PaintingBinding.instance.imageCache.clear();
              PaintingBinding.instance.imageCache.clearLiveImages();
              PocketBaseService.instance.clearCache();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã dọn dẹp bộ nhớ đệm RAM và dữ liệu tạm thành công!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeService.instance.primaryColor,
            ),
            child: const Text('Xác nhận xóa'),
          ),
        ],
      ),
    );
  }

  void _showThemeSelectionSheet() {
    final screenContext = context;
    showModalBottomSheet(
      context: screenContext,
      backgroundColor: ThemeService.instance.cardColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return ListenableBuilder(
          listenable: ThemeService.instance,
          builder: (context, _) {
            final currentMode = ThemeService.instance.mode;
            final isWin11 = currentMode == AppThemeMode.windowsBlue;
            final isLuxury = currentMode == AppThemeMode.luxuryGold;

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
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
                    SizedBox(height: 16),
                    Text(
                      'Màu sắc ứng dụng & Sóng lụa Silk',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Tùy chỉnh tông màu nhận diện và nền hiệu ứng Silk Shader khi khởi động app',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Option 1: Đỏ Netflix (Mặc định)
                    _buildThemeOptionCard(
                      title: 'Đỏ Netflix (Mặc định)',
                      subtitle: 'Đỏ điện ảnh kinh điển nguyên bản (Đỏ & Đen)',
                      tag: 'MẶC ĐỊNH',
                      tagColor: AppColors.red,
                      isSelected: !isWin11 && !isLuxury,
                      activeColor: AppColors.red,
                      colors: const [
                        Color(0xFF02010A),
                        Color(0xFF2A0408),
                        Color(0xFFB20710),
                        Color(0xFFE50914),
                      ],
                      onTap: () async {
                        final messenger = ScaffoldMessenger.of(screenContext);
                        final nav = Navigator.of(ctx);
                        nav.pop();
                        // Chờ bottom sheet trượt xuống mượt mà trước khi chuyển shader/theme
                        await Future.delayed(const Duration(milliseconds: 140));
                        await ThemeService.instance.setThemeMode(
                          AppThemeMode.netflixRed,
                        );
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Đã chọn phong cách Đỏ Netflix (Mặc định)',
                            ),
                            backgroundColor: AppColors.red,
                            duration: Duration(milliseconds: 1500),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 12),

                    // Option 2: Xanh Hiện Đại (#00A2ED) & Trắng Mờ
                    _buildThemeOptionCard(
                      title: 'Xanh Hiện Đại (#00A2ED) & Trắng Mờ',
                      subtitle: 'Sắc xanh #00A2ED thay thế toàn bộ màu đỏ kết hợp nền trắng mờ ngọc trai',
                      tag: '#00A2ED',
                      tagColor: AppColors.cyanBlue,
                      isSelected: isWin11,
                      activeColor: AppColors.cyanBlue,
                      colors: const [
                        Color(0xFFF0F4F8),
                        Color(0xFFD6EBFC),
                        Color(0xFF00A2ED),
                        Color(0xFFFFFFFF),
                      ],
                      onTap: () async {
                        final messenger = ScaffoldMessenger.of(screenContext);
                        final nav = Navigator.of(ctx);
                        nav.pop();
                        // Chờ bottom sheet trượt xuống mượt mà trước khi chuyển shader/theme
                        await Future.delayed(const Duration(milliseconds: 140));
                        await ThemeService.instance.setThemeMode(
                          AppThemeMode.windowsBlue,
                        );
                        messenger.showSnackBar(
                          SnackBar(
                            content: const Text(
                              'Đã kích hoạt phong cách Xanh #00A2ED & Nền Trắng Mờ!',
                            ),
                            backgroundColor: AppColors.cyanBlue,
                            duration: const Duration(milliseconds: 1500),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 12),

                    // Option 3: Vàng Hoàng Gia Luxury (Chế độ màu vàng)
                    _buildThemeOptionCard(
                      title: 'Vàng Hoàng Gia Luxury (Chế độ màu vàng)',
                      subtitle: 'Lụa đen viền vàng, hoa nghệ thuật và hạt bụi vàng lấp lánh (Dark Luxury)',
                      tag: 'Gold Luxury',
                      tagColor: AppColors.gold,
                      isSelected: isLuxury,
                      activeColor: AppColors.gold,
                      colors: const [
                        Color(0xFF060504),
                        Color(0xFF6D4A18),
                        Color(0xFFB98A3A),
                        Color(0xFFF1D48B),
                      ],
                      onTap: () async {
                        final messenger = ScaffoldMessenger.of(screenContext);
                        final nav = Navigator.of(ctx);
                        nav.pop();
                        // Chờ bottom sheet trượt xuống mượt mà trước khi chuyển shader/theme
                        await Future.delayed(const Duration(milliseconds: 140));
                        await ThemeService.instance.setThemeMode(
                          AppThemeMode.luxuryGold,
                        );
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Đã kích hoạt phong cách Vàng Hoàng Gia Luxury!',
                            ),
                            backgroundColor: Color(0xFFB98A3A),
                            duration: Duration(milliseconds: 1500),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 12),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildThemeOptionCard({
    required String title,
    required String subtitle,
    required String tag,
    required Color tagColor,
    required bool isSelected,
    required Color activeColor,
    required List<Color> colors,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isSelected
          ? activeColor.withValues(alpha: 0.12)
          : AppColors.surfaceLight,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? activeColor : AppColors.divider,
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            children: [
              // Radio indicator
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? activeColor : AppColors.textMuted,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: activeColor,
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 14),
              // Information
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: tagColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: tagColor.withValues(alpha: 0.6),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              color: tagColor,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Palette dots
                    Row(
                      children: colors.map((c) {
                        return Container(
                          width: 18,
                          height: 18,
                          margin: const EdgeInsets.only(right: 6),
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white24, width: 1),
                            boxShadow: [
                              BoxShadow(
                                color: c.withValues(alpha: 0.3),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeService.instance,
      builder: (context, _) {
        final currentPrimary = ThemeService.instance.primaryColor;

        final scaffold = Scaffold(
          backgroundColor: AppColors.scaffoldBackground,
          appBar: AppBar(
            leading: GlassBackButton(),
            title: Text(
              'Cài đặt ứng dụng',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: ListView(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            children: [
              Text(
                'TRẢI NGHIỆM PHÁT LẠI',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              SizedBox(height: 8),

              _buildTile(
                icon: Icons.tune,
                title: 'Phát lại & Chất lượng video',
                subtitle: 'Tự động phát tập, chất lượng video, chỉ dùng Wi-Fi',
                onTap: () => context.push('/settings/playback'),
              ),

              SizedBox(height: 20),
              Text(
                'TÙY CHỈNH HỆ THỐNG',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),

              // Tùy chọn Màu sắc giao diện (Theme & Sóng lụa Silk)
              _buildTile(
                icon: Icons.palette_outlined,
                iconColor: currentPrimary,
                title: 'Màu sắc giao diện & Sóng lụa Silk',
                subtitle: ThemeService.instance.name,
                trailingWidget: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: currentPrimary,
                        border: Border.all(color: Colors.white30, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: currentPrimary.withValues(alpha: 0.5),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.chevron_right,
                      color: AppColors.textMuted,
                      size: 20,
                    ),
                  ],
                ),
                onTap: _showThemeSelectionSheet,
              ),

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
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: ThemeService.instance.isWindowsBlue
                      ? const Color(0xCC0A2433)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: ThemeService.instance.isWindowsBlue
                        ? const Color(0x265AD2F4)
                        : Colors.white10,
                    width: 0.8,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                  child: SwitchListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    secondary: Icon(
                      Icons.notifications_active_outlined,
                      color: Colors.white,
                      size: 22,
                    ),
                    title: Text(
                      'Nhận thông báo phim mới',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      'Gợi ý phim thịnh hành và phim mới cập nhật hàng tuần',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    activeThumbColor: currentPrimary,
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

              SizedBox(height: 20),
              Text(
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
        // Nền động thật nằm ở cấp app. Helper chỉ tự tạo nền khi màn này được
        // dựng độc lập trong preview/test, nên không remount nội dung khi đổi
        // màu trong ứng dụng.
        return WavesBackground.wrapIfBlue(scaffold);
      },
    );
  }

  Widget _buildTile({
    required IconData icon,
    Color? iconColor,
    required String title,
    String? subtitle,
    Widget? trailingWidget,
    required VoidCallback onTap,
  }) {
    final isBlue = ThemeService.instance.isWindowsBlue;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          leading: Icon(icon, color: iconColor ?? Colors.white, size: 22),
          title: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: subtitle != null
              ? Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                )
              : null,
          trailing:
              trailingWidget ??
              Icon(Icons.chevron_right, color: AppColors.textMuted, size: 20),
          onTap: onTap,
        ),
      ),
    );
  }
}
