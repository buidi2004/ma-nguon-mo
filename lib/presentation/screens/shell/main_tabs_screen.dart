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
  /// Trạng thái ẩn/hiện của bottom bar.
  ///
  /// Dùng [ValueNotifier] thay cho `setState` để mỗi lần cuộn chỉ đúng phần
  /// thanh kính được dựng lại, không kéo theo toàn bộ `GlassScaffold` + nội
  /// dung (navigation shell) phía trên.
  final ValueNotifier<bool> _isBottomBarVisible = ValueNotifier<bool>(true);

  @override
  void dispose() {
    _isBottomBarVisible.dispose();
    super.dispose();
  }

  void _onTabSelected(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
    // Khi người dùng chuyển tab, luôn đảm bảo bottom bar xuất hiện
    _isBottomBarVisible.value = true;
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
      _isBottomBarVisible.value = true;
      return false;
    }

    if (notification is ScrollUpdateNotification) {
      final double delta = notification.scrollDelta ?? 0.0;

      // Khi vuốt ngược lên: Hiện lại ngay lập tức
      if (delta < -2.0) {
        if (!_isBottomBarVisible.value) {
          _isBottomBarVisible.value = true;
        }
      }
      // Khi vuốt xuống VÀ chỉ khi khoảng cách tới đáy <= 80px: Ẩn thanh bar
      else if (delta > 2.0 && extentAfter <= 80.0) {
        if (_isBottomBarVisible.value) {
          _isBottomBarVisible.value = false;
        }
      }
      // Vùng đệm trễ: Cách đáy > 140px đảm bảo luôn hiện
      else if (extentAfter > 140.0 && !_isBottomBarVisible.value) {
        _isBottomBarVisible.value = true;
      }
    } else if (notification is OverscrollNotification) {
      // Khi kéo nảy ở đỉnh trang: luôn hiện
      if (notification.overscroll < 0.0 && !_isBottomBarVisible.value) {
        _isBottomBarVisible.value = true;
      }
    } else if (notification is ScrollEndNotification) {
      // Dừng cuộn sát đáy: nếu còn <= 10px thì đảm bảo ẩn
      if (extentAfter <= 10.0 && _isBottomBarVisible.value) {
        _isBottomBarVisible.value = false;
      }
      // Dừng cuộn sát đỉnh: nếu pixels <= 10px thì đảm bảo hiện
      else if (notification.metrics.pixels <= 10.0 &&
          !_isBottomBarVisible.value) {
        _isBottomBarVisible.value = true;
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    // Tự động phát hiện khi bàn phím ảo xuất hiện (viewInsets.bottom > 0)
    final bool isKeyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

    return GlassScaffold(
      contentAwareBrightness: false,
      backgroundColor: Colors.transparent,
      bottomBarHeight: 88,
      resizeToAvoidBottomInset: false,
      bottomBar: PreferredSize(
        preferredSize: const Size.fromHeight(88),
        child: RepaintBoundary(
          child: ValueListenableBuilder<bool>(
            valueListenable: _isBottomBarVisible,
            // Thanh kính chỉ được dựng một lần cho mỗi build của shell và
            // truyền vào qua `child`, nên ẩn/hiện khi cuộn không phải build
            // lại cây widget kính (2 khối LiquidGlass + 4 tab + nút 3D).
            child: FloatingGlassBottomBar(
              selectedIndex: widget.navigationShell.currentIndex,
              onTabSelected: _onTabSelected,
              onQuickActionPressed: () => _onQuickAction(context),
            ),
            builder: (context, visible, child) {
              final bool shouldShowBar = visible && !isKeyboardOpen;
              return AnimatedSlide(
                offset: shouldShowBar ? Offset.zero : const Offset(0, 1.25),
                duration: const Duration(milliseconds: 300),
                curve: shouldShowBar
                    ? Curves.easeOutCubic
                    : Curves.fastOutSlowIn,
                // AnimatedOpacity không dùng được cho lớp kính: một
                // BackdropFilter không thể mờ dần qua Opacity (kính sẽ "bật"
                // trắng đục trong lúc icon mờ dần) mà lại bắt engine dựng
                // thêm một saveLayer cho toàn bộ thanh mỗi frame. Thanh đã
                // trượt hẳn ra ngoài màn hình (offset 1.25 > 1) nên bỏ lớp
                // opacity này không đổi giao diện tĩnh mà nhẹ đi rõ rệt.
                child: IgnorePointer(
                  ignoring: !shouldShowBar,
                  child: TickerMode(
                    enabled: shouldShowBar,
                    child: child ?? const SizedBox.shrink(),
                  ),
                ),
              );
            },
          ),
        ),
      ),
      body: RepaintBoundary(
        child: NotificationListener<ScrollNotification>(
          onNotification: _handleScrollNotification,
          // Nền động dùng chung đã được lắp ở cấp app (`ThemedBackdrop`), nên
          // shell không bọc thêm shader nền nữa: tránh 2 shader toàn màn hình
          // chạy song song và tránh remount cả 4 tab mỗi lần đổi theme.
          child: widget.navigationShell,
        ),
      ),
    );
  }
}
