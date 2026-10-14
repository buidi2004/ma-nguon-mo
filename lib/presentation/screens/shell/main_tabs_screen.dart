import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../../widgets/floating_glass_bottom_bar.dart';

class MainTabsScreen extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainTabsScreen({super.key, required this.navigationShell});

  @override
  State<MainTabsScreen> createState() => _MainTabsScreenState();
}

class _MainTabsScreenState extends State<MainTabsScreen> {
  bool _isBottomBarVisible = true;

  void _onTabSelected(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
    // Khi người dùng chuyển tab, luôn đảm bảo bottom bar xuất hiện
    if (!_isBottomBarVisible) {
      setState(() {
        _isBottomBarVisible = true;
      });
    }
  }

  void _onQuickAction(BuildContext context) {
    // Điều hướng trực tiếp tới màn hình Gói thành viên (/plans)
    context.push('/plans');
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    // 1. Chỉ xử lý cuộn dọc, bỏ qua cuộn ngang (MovieRow, Carousel)
    if (notification.metrics.axis != Axis.vertical) {
      return false;
    }

    final double maxScroll = notification.metrics.maxScrollExtent;
    final double extentAfter = notification.metrics.extentAfter;

    // Trang nội dung ngắn không đủ cuộn: luôn giữ hiển thị
    if (maxScroll < 120.0) {
      if (!_isBottomBarVisible) {
        setState(() => _isBottomBarVisible = true);
      }
      return false;
    }

    if (notification is ScrollUpdateNotification) {
      final double delta = notification.scrollDelta ?? 0.0;

      // Khi vuốt ngược lên: Hiện lại ngay lập tức
      if (delta < -2.0) {
        if (!_isBottomBarVisible) {
          setState(() => _isBottomBarVisible = true);
        }
      }
      // Khi vuốt xuống VÀ chỉ khi khoảng cách tới đáy <= 80px: Ẩn thanh bar
      else if (delta > 2.0 && extentAfter <= 80.0) {
        if (_isBottomBarVisible) {
          setState(() => _isBottomBarVisible = false);
        }
      }
      // Vùng đệm trễ: Cách đáy > 140px đảm bảo luôn hiện
      else if (extentAfter > 140.0 && !_isBottomBarVisible) {
        setState(() => _isBottomBarVisible = true);
      }
    } else if (notification is OverscrollNotification) {
      // Khi kéo nảy ở đỉnh trang: luôn hiện
      if (notification.overscroll < 0.0 && !_isBottomBarVisible) {
        setState(() => _isBottomBarVisible = true);
      }
    } else if (notification is ScrollEndNotification) {
      // Dừng cuộn sát đáy: nếu còn <= 10px thì đảm bảo ẩn
      if (extentAfter <= 10.0 && _isBottomBarVisible) {
        setState(() => _isBottomBarVisible = false);
      }
      // Dừng cuộn sát đỉnh: nếu pixels <= 10px thì đảm bảo hiện
      else if (notification.metrics.pixels <= 10.0 && !_isBottomBarVisible) {
        setState(() => _isBottomBarVisible = true);
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    // Tự động phát hiện khi bàn phím ảo xuất hiện (viewInsets.bottom > 0)
    final bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    final bool shouldShowBar = _isBottomBarVisible && !isKeyboardOpen;

    return GlassScaffold(
      contentAwareBrightness: false,
      backgroundColor: Colors.transparent,
      bottomBarHeight: 88,
      resizeToAvoidBottomInset: false,
      bottomBar: PreferredSize(
        preferredSize: const Size.fromHeight(88),
        child: RepaintBoundary(
          child: AnimatedSlide(
            offset: shouldShowBar ? Offset.zero : const Offset(0, 1.25),
            duration: const Duration(milliseconds: 300),
            curve: shouldShowBar ? Curves.easeOutCubic : Curves.fastOutSlowIn,
            child: AnimatedOpacity(
              opacity: shouldShowBar ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeInOut,
              child: IgnorePointer(
                ignoring: !shouldShowBar,
                child: FloatingGlassBottomBar(
                  selectedIndex: widget.navigationShell.currentIndex,
                  onTabSelected: _onTabSelected,
                  onQuickActionPressed: () => _onQuickAction(context),
                ),
              ),
            ),
          ),
        ),
      ),
      body: RepaintBoundary(
        child: NotificationListener<ScrollNotification>(
          onNotification: _handleScrollNotification,
          child: widget.navigationShell,
        ),
      ),
    );
  }
}
