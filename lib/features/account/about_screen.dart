import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/config.dart';
import '../../presentation/widgets/glass/glass_components.dart';
import '../../services/theme_service.dart';
import '../../theme/app_theme.dart';
import '../../waves_background.dart';

/// S38 — Giới thiệu & giấy phép (P0). Route: /about
/// Hiện phiên bản, MIT, thư viện, link GitHub (copy, không cần url_launcher).
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const _libs = [
    ['Flutter Framework', 'Google • UI đa nền tảng'],
    ['PocketBase', 'BaaS + SQLite • pocketbase.io'],
    ['go_router', 'Điều hướng 42 route'],
    ['provider', 'Quản lý trạng thái'],
    ['chewie + video_player', 'Phát video MP4'],
    ['cached_network_image', 'Cache poster'],
    ['shared_preferences', 'Lưu phiên, cài đặt'],
    ['shimmer', 'Khung chờ loading'],
    ['google_fonts', 'Typography Outfit'],
  ];

  @override
  Widget build(BuildContext context) {
    return WavesBackground.wrapIfBlue(Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: const GlassBackButton(),
        title: Text(
          'Giới thiệu & Giấy phép',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Center(
            child: Column(
              children: [
                Text(
                  'OPENFLIX',
                  style: TextStyle(
                    color: ThemeService.instance.primaryColor,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 3,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Phiên bản ${AppConfig.appVersion}',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Ứng dụng xem phim trực tuyến mã nguồn mở',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _card(
            title: 'Thông tin sinh viên thực hiện',
            content:
                '• Họ và tên: Bùi Văn Dĩ\n'
                '• Mã số sinh viên (MSSV): 0023414259\n'
                '• Đề tài: Nền tảng xem phim trực tuyến OpenFlix (Flutter & Next.js)',
          ),
          const SizedBox(height: 12),
          _card(
            title: 'Giấy phép mã nguồn mở MIT',
            content:
                'Copyright (c) 2026 OpenFlix Contributors.\n\n'
                'Bạn được toàn quyền sử dụng, sao chép, chỉnh sửa và phân phối mã nguồn cho mục đích học tập, nghiên cứu (xem file LICENSE).',
          ),
          const SizedBox(height: 12),
          _card(
            title: 'Nguồn phim mẫu (Blender Foundation)',
            content:
                'Video/poster mẫu theo giấy phép Creative Commons:\n\n'
                '• Big Buck Bunny (c) 2008\n'
                '• Sintel (c) 2010\n'
                '• Tears of Steel (c) 2012\n'
                '• Elephants Dream (c) 2006\n\n'
                'Nguồn: https://studio.blender.org/films/',
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Các thư viện công nghệ chính',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                ..._libs.map(
                  (l) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 1.5),
                          child: Icon(
                            Icons.check_circle_outline,
                            color: ThemeService.instance.primaryColor,
                            size: 16,
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l[0],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                l[1],
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2.0),
                  child: Icon(Icons.code, color: Colors.white, size: 20),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mã nguồn GitHub',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'github.com/buidi2004/ma-nguon-mo',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Sao chép link',
                  icon: Icon(Icons.copy, color: AppColors.textMuted, size: 20),
                  onPressed: () {
                    Clipboard.setData(
                      const ClipboardData(
                        text: 'https://github.com/buidi2004/ma-nguon-mo',
                      ),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Đã sao chép liên kết GitHub vào bộ nhớ tạm!',
                        ),
                        backgroundColor: AppColors.success,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    ));
  }

  Widget _card({required String title, required String content}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
