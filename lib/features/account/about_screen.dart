import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/config.dart';
import '../../theme/app_theme.dart';

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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Giới thiệu & Giấy phép',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Column(
              children: [
                const Text(
                  'OPENFLIX',
                  style: TextStyle(
                    color: AppColors.red,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Phiên bản ${AppConfig.appVersion}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Ứng dụng xem phim trực tuyến mã nguồn mở',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
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
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          color: AppColors.red,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l[0],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                l[1],
                                style: const TextStyle(
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
                const Icon(Icons.code, color: Colors.white, size: 22),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mã nguồn GitHub',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'github.com/your-username/openflix',
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
                  icon: const Icon(
                    Icons.copy,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                  onPressed: () {
                    Clipboard.setData(
                      const ClipboardData(
                        text: 'https://github.com/openflix/openflix',
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
    );
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
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
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
