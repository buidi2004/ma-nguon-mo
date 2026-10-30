import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/primary_button.dart';
import '../../services/theme_service.dart';
import '../../theme/app_theme.dart';
import '../../waves_background.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<Map<String, String>> _pages = [
    {
      'title': 'Xem phim không giới hạn',
      'desc': 'Khám phá thế giới phim hoạt hình 3D và khoa học viễn tưởng mã nguồn mở hoàn toàn miễn phí.',
      'icon': 'movie_creation_outlined',
    },
    {
      'title': 'Tốc độ cao & Trực tiếp',
      'desc': 'Truyền phát video chất lượng cao trực tiếp từ CDN, không cần chờ đợi tải xuống.',
      'icon': 'speed_outlined',
    },
    {
      'title': 'Trải nghiệm chuẩn Netflix',
      'desc': 'Giao diện Dark Mode sang trọng, không quảng cáo phiền toái, tối ưu hóa cho di động.',
      'icon': 'tv_outlined',
    },
  ];

  IconData _getIcon(String name) {
    switch (name) {
      case 'movie_creation_outlined':
        return Icons.movie_creation_outlined;
      case 'speed_outlined':
        return Icons.speed_outlined;
      default:
        return Icons.tv_outlined;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WavesBackground.wrapIfBlue(Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        actions: [
          TextButton(
            onPressed: () => context.go('/welcome'),
            child: Text(
              'Bỏ qua',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                },
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.divider),
                          ),
                          child: Icon(
                            _getIcon(page['icon']!),
                            size: 80,
                            color: ThemeService.instance.primaryColor,
                          ),
                        ),
                        SizedBox(height: 36),
                        Text(
                          page['title']!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 14),
                        Text(
                          page['desc']!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 15,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Dấu chấm chỉ báo trang (Dot indicators)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentIndex == i ? 24 : 8,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _currentIndex == i
                        ? ThemeService.instance.primaryColor
                        : Colors.white24,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 36),

            // Nút bấm tiếp tục
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16,
              ),
              child: PrimaryButton(
                text: _currentIndex == _pages.length - 1
                    ? 'Bắt đầu ngay'
                    : 'Tiếp theo',
                onPressed: () {
                  if (_currentIndex < _pages.length - 1) {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  } else {
                    context.go('/welcome');
                  }
                },
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
