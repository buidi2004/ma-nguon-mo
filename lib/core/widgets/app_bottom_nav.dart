import 'package:flutter/material.dart';

import '../../services/theme_service.dart';
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
    return ListenableBuilder(
      listenable: ThemeService.instance,
      builder: (context, _) {
        final isWin11 = ThemeService.instance.isWindowsBlue;
        final isGold = ThemeService.instance.isLuxuryGold;
        final homePalette = Theme.of(context).extension<HomeScreenPalette>();
        final bg =
            homePalette?.background ?? ThemeService.instance.backgroundColor;
        final primary =
            homePalette?.action ?? ThemeService.instance.primaryColor;
        final textMuted =
            homePalette?.textMuted ?? ThemeService.instance.textMuted;
        final activeColor = (isWin11 || isGold) ? primary : Colors.white;

        return Container(
          decoration: BoxDecoration(
            color: bg,
            border: Border(
              top: BorderSide(
                color:
                    homePalette?.divider ??
                    (isWin11 ? const Color(0xFFE2E8F0) : Colors.white10),
                width: 0.5,
              ),
            ),
          ),
          child: NavigationBar(
            selectedIndex: currentIndex,
            onDestinationSelected: onTap,
            backgroundColor: bg,
            indicatorColor: primary.withValues(alpha: 0.15),
            elevation: 0,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: [
              NavigationDestination(
                icon: Icon(Icons.home_outlined, color: textMuted),
                selectedIcon: Icon(Icons.home, color: activeColor),
                label: 'Trang chủ',
              ),
              NavigationDestination(
                icon: Icon(Icons.search_outlined, color: textMuted),
                selectedIcon: Icon(Icons.search, color: activeColor),
                label: 'Tìm kiếm',
              ),
              NavigationDestination(
                icon: Icon(
                  Icons.local_fire_department_outlined,
                  color: textMuted,
                ),
                selectedIcon: Icon(
                  Icons.local_fire_department,
                  color: activeColor,
                ),
                label: 'Mới & Hot',
              ),
              NavigationDestination(
                icon: Icon(
                  Icons.confirmation_number_outlined,
                  color: textMuted,
                ),
                selectedIcon: Icon(
                  Icons.confirmation_number,
                  color: activeColor,
                ),
                label: 'Đặt vé',
              ),
            ],
          ),
        );
      },
    );
  }
}
