import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/state_view.dart';
import '../../theme/app_theme.dart';

class NotificationItem {
  final String id;
  final String title;
  final String body;
  final String timeAgo;
  final IconData icon;
  final String? targetRoute;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.timeAgo,
    required this.icon,
    this.targetRoute,
    this.isRead = false,
  });
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _filterOnlyUnread = false;

  final List<NotificationItem> _notifications = [
    NotificationItem(
      id: 'n1',
      title: 'Phim mới: Sintel - Trái Tim Rồng',
      body: 'Tuyệt tác đồ họa 3D đầy cảm xúc đã chính thức có mặt trên OpenFlix. Thưởng thức ngay hôm nay!',
      timeAgo: '15 phút trước',
      icon: Icons.movie_filter,
      targetRoute: '/movie/mock_2',
      isRead: false,
    ),
    NotificationItem(
      id: 'n2',
      title: 'Gợi ý cuối tuần dành riêng cho bạn',
      body: 'Khám phá danh sách Top 10 bộ phim thịnh hành với nhiều trải nghiệm viễn tưởng đặc sắc.',
      timeAgo: '3 giờ trước',
      icon: Icons.local_fire_department,
      targetRoute: '/top10',
      isRead: false,
    ),
    NotificationItem(
      id: 'n3',
      title: 'Cập nhật OpenFlix v1.0.0',
      body: 'Đã tối ưu hóa trải nghiệm 42 màn hình, trình phát video mượt mà và giao diện chuẩn điện ảnh.',
      timeAgo: 'Hôm qua',
      icon: Icons.system_update,
      targetRoute: '/about',
      isRead: true,
    ),
    NotificationItem(
      id: 'n4',
      title: 'Tiếp tục xem Big Buck Bunny',
      body: 'Bạn đang xem dở tại phút 06:30. Bấm vào đây để tiếp tục hành trình ngay nhé!',
      timeAgo: '2 ngày trước',
      icon: Icons.play_circle_outline,
      targetRoute: '/watch/mock_1',
      isRead: true,
    ),
  ];

  void _markAllAsRead() {
    setState(() {
      for (final n in _notifications) {
        n.isRead = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã đánh dấu tất cả thông báo là đã đọc'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _toggleNotification(NotificationItem item) {
    setState(() {
      item.isRead = true;
    });
    if (item.targetRoute != null) {
      context.push(item.targetRoute!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => !n.isRead).length;
    final displayedList = _filterOnlyUnread
        ? _notifications.where((n) => !n.isRead).toList()
        : _notifications;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Flexible(
              child: Text(
                'Thông báo',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            if (unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$unreadCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text(
                'Đọc tất cả',
                style: TextStyle(
                  color: AppColors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Tất cả'),
                  selected: !_filterOnlyUnread,
                  onSelected: (val) =>
                      setState(() => _filterOnlyUnread = false),
                  selectedColor: AppColors.red,
                  labelStyle: TextStyle(
                    color: !_filterOnlyUnread
                        ? Colors.white
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ChoiceChip(
                  label: Text('Chưa đọc ($unreadCount)'),
                  selected: _filterOnlyUnread,
                  onSelected: (val) => setState(() => _filterOnlyUnread = true),
                  selectedColor: AppColors.red,
                  labelStyle: TextStyle(
                    color: _filterOnlyUnread
                        ? Colors.white
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // List
          Expanded(
            child: displayedList.isEmpty
                ? StateView.empty(
                    icon: Icons.notifications_none,
                    title: 'Không có thông báo mới',
                    message: 'Bạn đã cập nhật tất cả thông báo hệ thống và phim ảnh mới nhất.',
                  )
                : ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: displayedList.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = displayedList[index];

                      return InkWell(
                        onTap: () => _toggleNotification(item),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: item.isRead
                                ? AppColors.surface
                                : AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: item.isRead
                                  ? Colors.white10
                                  : AppColors.red.withAlpha(128),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color:
                                      (item.isRead
                                              ? Colors.white24
                                              : AppColors.red)
                                          .withAlpha(35),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  item.icon,
                                  color: item.isRead
                                      ? Colors.white70
                                      : AppColors.red,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item.title,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: item.isRead
                                                  ? FontWeight.w600
                                                  : FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        if (!item.isRead) ...[
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: const BoxDecoration(
                                              color: AppColors.red,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item.body,
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12,
                                        height: 1.4,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      item.timeAgo,
                                      style: const TextStyle(
                                        color: AppColors.textMuted,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
