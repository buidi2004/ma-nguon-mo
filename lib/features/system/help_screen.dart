import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_theme.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final _searchController = TextEditingController();
  String _searchKeyword = '';

  final List<Map<String, String>> _faqList = [
    {
      'question': 'Tôi có thể tải phim về xem khi không có kết nối mạng không?',
      'answer': 'Hoàn toàn được! Bạn có thể nhấn vào biểu tượng Tải về tại trang chi tiết phim hoặc danh sách tập phim. Các nội dung đã tải sẽ có sẵn trong mục "Tải xuống" của bạn và có thể phát mượt mà không cần Internet.',
    },
    {
      'question': 'Tại sao video đôi khi bị giật lag hoặc giảm độ phân giải?',
      'answer': 'OpenFlix sử dụng công nghệ truyền phát thích ứng theo tốc độ đường truyền. Nếu kết nối mạng không ổn định, chất lượng sẽ tự động điều chỉnh để tránh ngắt quãng. Bạn có thể vào Cài đặt > Phát & Tải về để chọn mức chất lượng cố định.',
    },
    {
      'question': 'Làm thế nào để đổi mật khẩu tài khoản?',
      'answer': 'Bạn hãy vào tab "Tôi" > chọn "Đổi mật khẩu" hoặc vào "Tài khoản". Nhập mật khẩu hiện tại cùng mật khẩu mới tối thiểu 6 ký tự để hoàn tất cập nhật.',
    },
    {
      'question': 'OpenFlix có thu phí hàng tháng không?',
      'answer': 'OpenFlix là dự án xem phim mã nguồn mở hướng tới cộng đồng. Tất cả các bộ phim nguồn mở tiêu chuẩn (Blender Studio, Creative Commons) đều được xem hoàn toàn miễn phí mà không cần trả bất kỳ chi phí nào.',
    },
    {
      'question':
          'Làm sao để xem OpenFlix trên Smart TV hoặc trình duyệt máy tính?',
      'answer': 'OpenFlix được phát triển đa nền tảng Flutter. Bạn có thể mở phiên bản Web trên bất kỳ trình duyệt nào (Chrome, Safari, Edge) hoặc dùng tính năng Cast không dây lên TV hỗ trợ Chromecast / AirPlay.',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredFaqs = _searchKeyword.isEmpty
        ? _faqList
        : _faqList.where((f) {
            final q = f['question']!.toLowerCase();
            final a = f['answer']!.toLowerCase();
            final k = _searchKeyword.toLowerCase();
            return q.contains(k) || a.contains(k);
          }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/me');
            }
          },
        ),
        title: const Text(
          'Trung tâm trợ giúp',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.red.withValues(alpha: 0.8),
                  AppColors.surface,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.help_center_outlined,
                      color: Colors.white,
                      size: 28,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Chúng tôi có thể giúp gì cho bạn?',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) {
                      setState(() {
                        _searchKeyword = val.trim();
                      });
                    },
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm câu hỏi trợ giúp...',
                      hintStyle: const TextStyle(color: AppColors.textMuted),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.textSecondary,
                      ),
                      suffixIcon: _searchKeyword.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.clear,
                                color: AppColors.textMuted,
                                size: 18,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchKeyword = '';
                                });
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'HỖ TRỢ TRỰC TIẾP',
            style: TextStyle(
              color: AppColors.red,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => context.push('/contact'),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: const Column(
                      children: [
                        Icon(
                          Icons.mail_outline,
                          color: AppColors.red,
                          size: 26,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Gửi phản hồi',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Phản hồi trong 24h',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: AppColors.surface,
                        title: const Row(
                          children: [
                            Icon(Icons.headset_mic, color: Colors.blueAccent),
                            SizedBox(width: 8),
                            Text(
                              'Tổng đài 24/7',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),
                          ],
                        ),
                        content: const Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '1800 6868',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Miễn phí 100% cước gọi từ mọi mạng viễn thông. Đội ngũ kỹ thuật hỗ trợ 24/7.',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text(
                              'Đóng',
                              style: TextStyle(color: Colors.white60),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(ctx);
                              Clipboard.setData(
                                const ClipboardData(text: '18006868'),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Đã sao chép số tổng đài 1800 6868!',
                                  ),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            },
                            icon: const Icon(Icons.copy, size: 16),
                            label: const Text('Sao chép số'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.red,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: const Column(
                      children: [
                        Icon(
                          Icons.headset_mic_outlined,
                          color: Colors.blueAccent,
                          size: 26,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Tổng đài 24/7',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          '1800 6868',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          const Text(
            'CÂU HỎI THƯỜNG GẶP (FAQ)',
            style: TextStyle(
              color: AppColors.red,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          if (filteredFaqs.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'Không tìm thấy câu hỏi phù hợp với "$_searchKeyword"',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ),
            )
          else
            ...filteredFaqs.map((faq) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: Material(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  child: Theme(
                    data: Theme.of(context)
                        .copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      title: Text(
                        faq['question']!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      iconColor: AppColors.red,
                      collapsedIconColor: Colors.white70,
                      childrenPadding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        bottom: 16,
                      ),
                      children: [
                        Text(
                          faq['answer']!,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
