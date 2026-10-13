import 'package:flutter/material.dart';

import '../../core/widgets/settings_tile.dart';
import '../../services/language_service.dart';
import '../../theme/app_theme.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  final _langService = LanguageService.instance;

  Future<void> _selectLanguage(String code, String name) async {
    await _langService.setLocale(code);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã cập nhật ngôn ngữ ứng dụng: $name'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Ngôn ngữ / Language',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: ListenableBuilder(
        listenable: _langService,
        builder: (context, _) {
          final currentCode = _langService.code;
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: [
              SettingsSection(
                title: 'Ngôn ngữ hiển thị',
                children: [
                  SettingsTile(
                    icon: Icons.language,
                    title: 'Tiếng Việt',
                    subtitle: 'Mặc định (Việt Nam)',
                    trailing: currentCode == 'vi'
                        ? const Icon(
                            Icons.check_circle,
                            color: AppColors.red,
                            size: 22,
                          )
                        : null,
                    onTap: () => _selectLanguage('vi', 'Tiếng Việt'),
                  ),
                  SettingsTile(
                    icon: Icons.public,
                    title: 'English',
                    subtitle: 'United States / Global',
                    trailing: currentCode == 'en'
                        ? const Icon(
                            Icons.check_circle,
                            color: AppColors.red,
                            size: 22,
                          )
                        : null,
                    onTap: () => _selectLanguage('en', 'English'),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Live Preview Container
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.visibility_outlined,
                            color: AppColors.red,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              currentCode == 'vi'
                                  ? 'Xem trước giao diện'
                                  : 'Interface Preview',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildPreviewBadge(
                            Icons.home_outlined,
                            _langService.t('home'),
                          ),
                          _buildPreviewBadge(
                            Icons.search,
                            _langService.t('search'),
                          ),
                          _buildPreviewBadge(
                            Icons.bookmark_border,
                            _langService.t('my_list'),
                          ),
                          _buildPreviewBadge(
                            Icons.play_arrow,
                            _langService.t('play'),
                          ),
                          _buildPreviewBadge(
                            Icons.settings_outlined,
                            _langService.t('settings'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'Lưu ý: Thay đổi ngôn ngữ sẽ áp dụng cho toàn bộ các tiêu đề, nút điều hướng và phụ đề ưu tiên trong trình phát.',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPreviewBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 14),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
