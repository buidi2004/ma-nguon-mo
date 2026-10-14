import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../presentation/widgets/glass/glass_components.dart';
import '../../theme/app_theme.dart';

class PlaybackSettingsScreen extends StatefulWidget {
  const PlaybackSettingsScreen({super.key});

  @override
  State<PlaybackSettingsScreen> createState() => _PlaybackSettingsScreenState();
}

class _PlaybackSettingsScreenState extends State<PlaybackSettingsScreen> {
  bool _autoPlayNext = true;
  bool _autoPlayTrailer = true;
  bool _wifiOnly = false;
  String _videoQuality = 'Tự động (Khuyên dùng)';

  final List<String> _qualityOptions = [
    'Tự động (Khuyên dùng)',
    'Full HD (1080p)',
    'HD (720p)',
    'Tiết kiệm dữ liệu (480p)',
  ];

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
          _autoPlayNext = prefs.getBool('playback_autoplay_next') ?? true;
          _autoPlayTrailer = prefs.getBool('playback_autoplay_trailer') ?? true;
          _wifiOnly = prefs.getBool('playback_wifi_only') ?? false;
          _videoQuality =
              prefs.getString('playback_video_quality') ??
              'Tự động (Khuyên dùng)';
        });
      }
    } catch (_) {}
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (value is bool) {
        await prefs.setBool(key, value);
      } else if (value is String) {
        await prefs.setString(key, value);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Phát lại & Chất lượng',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          const Text(
            'TỰ ĐỘNG PHÁT',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),

          _buildSwitchTile(
            title: 'Tự động phát tập tiếp theo',
            subtitle:
                'Tự động chuyển sang tập kế tiếp khi tập hiện tại kết thúc',
            value: _autoPlayNext,
            onChanged: (val) {
              setState(() => _autoPlayNext = val);
              _saveSetting('playback_autoplay_next', val);
            },
          ),

          _buildSwitchTile(
            title: 'Tự động phát trailer khi cuộn',
            subtitle: 'Tự động phát đoạn giới thiệu không tiếng khi bạn lướt qua trên trang chủ',
            value: _autoPlayTrailer,
            onChanged: (val) {
              setState(() => _autoPlayTrailer = val);
              _saveSetting('playback_autoplay_trailer', val);
            },
          ),

          const SizedBox(height: 20),
          const Text(
            'CHẤT LƯỢNG VIDEO & DỮ LIỆU',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),

          _buildSwitchTile(
            title: 'Chỉ phát trực tiếp qua Wi-Fi',
            subtitle: 'Tiết kiệm dung lượng gói cước 4G/5G của điện thoại',
            value: _wifiOnly,
            onChanged: (val) {
              setState(() => _wifiOnly = val);
              _saveSetting('playback_wifi_only', val);
            },
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Chất lượng hình ảnh mặc định',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _qualityOptions.map((opt) {
                    final isSelected = _videoQuality == opt;
                    return GestureDetector(
                      onTap: () {
                        setState(() => _videoQuality = opt);
                        _saveSetting('playback_video_quality', opt);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Đã chọn: $opt'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      child: GlassSurface.capsule(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 9,
                        ),
                        tintColor: isSelected
                            ? const Color(0x38E50914)
                            : const Color(0x222A2A2A),
                        customBorder: Border.all(
                          color: isSelected
                              ? const Color(0x88E50914)
                              : Colors.white12,
                        ),
                        blur: 8.5,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isSelected
                                  ? Icons.check_circle_rounded
                                  : Icons.circle_outlined,
                              color: isSelected
                                  ? const Color(0xFF00E5FF)
                                  : AppColors.textMuted,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                opt,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.textSecondary,
                                  fontSize: 13,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(6),
        child: SwitchListTile(
          title: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          value: value,
          activeThumbColor: AppColors.red,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
