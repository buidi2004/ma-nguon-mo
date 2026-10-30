import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../presentation/widgets/glass/glass_components.dart';
import '../../services/theme_service.dart';
import '../../theme/app_theme.dart';
import '../../waves_background.dart';

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
    return WavesBackground.wrapIfBlue(Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: GlassBackButton(),
        title: Text(
          'Phát lại & Chất lượng',
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

          SizedBox(height: 20),
          Text(
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
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                GlassRadioTileGroup.fromStrings(
                  options: _qualityOptions,
                  selectedOption: _videoQuality,
                  onChanged: (opt) {
                    setState(() => _videoQuality = opt);
                    _saveSetting('playback_video_quality', opt);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Đã chọn: $opt'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    ));
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
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          value: value,
          activeThumbColor: ThemeService.instance.primaryColor,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
