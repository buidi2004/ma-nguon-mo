import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: Colors.white10, width: 0.5)),
      ),
      child: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: onTap,
        backgroundColor: AppColors.background,
        indicatorColor: Colors.transparent,
        elevation: 0,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined, color: AppColors.textMuted),
            selectedIcon: Icon(Icons.home, color: Colors.white),
            label: 'Trang chủ',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined, color: AppColors.textMuted),
            selectedIcon: Icon(Icons.search, color: Colors.white),
            label: 'Tìm kiếm',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.local_fire_department_outlined,
              color: AppColors.textMuted,
            ),
            selectedIcon: Icon(
              Icons.local_fire_department,
              color: Colors.white,
            ),
            label: 'Mới & Hot',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline, color: AppColors.textMuted),
            selectedIcon: Icon(Icons.person, color: Colors.white),
            label: 'Tôi',
          ),
        ],
      ),
    );
  }
}
