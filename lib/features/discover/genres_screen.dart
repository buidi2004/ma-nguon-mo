import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/widgets/glass/glass_components.dart';
import '../../services/theme_service.dart';
import '../../theme/app_theme.dart';

class GenresScreen extends StatelessWidget {
  const GenresScreen({super.key});

  List<Map<String, dynamic>> _getGenres() => [
    {
      'name': 'Hoạt hình',
      'icon': Icons.animation,
      'gradient': ThemeService.instance.isWindowsBlue
          ? const [Color(0xFF00A2ED), Color(0xFF005A87)]
          : const [Color(0xFFE50914), Color(0xFF8B0000)],
      'desc': 'Phim 3D thế giới mở kinh điển',
    },
    {
      'name': 'Viễn tưởng',
      'icon': Icons.rocket_launch_outlined,
      'gradient': [Color(0xFF1E3C72), Color(0xFF2A5298)],
      'desc': 'Thế giới tương lai & Không gian',
    },
    {
      'name': 'Hành động',
      'icon': Icons.flash_on,
      'gradient': [Color(0xFFD31027), Color(0xFFEA384D)],
      'desc': 'Rượt đuổi & Đua xe tốc độ cao',
    },
    {
      'name': 'Hài hước',
      'icon': Icons.sentiment_very_satisfied,
      'gradient': [Color(0xFFF7971E), Color(0xFFFFD200)],
      'desc': 'Tiếng cười sảng khoái & Hài hước',
    },
    {
      'name': 'Phiêu lưu',
      'icon': Icons.explore_outlined,
      'gradient': [Color(0xFF11998E), Color(0xFF38EF7D)],
      'desc': 'Khám phá những vùng đất kỳ bí',
    },
    {
      'name': 'Tài liệu',
      'icon': Icons.nature_people_outlined,
      'gradient': [Color(0xFF4B6CB7), Color(0xFF182848)],
      'desc': 'Thiên nhiên hoang dã & Cực quang',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final genres = _getGenres();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: const GlassBackButton(),
        title: const Text(
          'Danh mục thể loại',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: GridView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: genres.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.2,
        ),
        itemBuilder: (context, index) {
          final g = genres[index];
          final List<Color> colors = g['gradient'];

          return GestureDetector(
            onTap: () => context.push('/genre/${g['name']}'),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: LinearGradient(
                  colors: colors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors.first.withValues(alpha: 0.35),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          g['name'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        g['icon'] as IconData,
                        color: Colors.white70,
                        size: 22,
                      ),
                    ],
                  ),
                  Text(
                    g['desc'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
