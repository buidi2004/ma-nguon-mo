import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/primary_button.dart';
import '../../presentation/widgets/glass/glass_components.dart';
import '../../theme/app_theme.dart';
import '../../waves_background.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _emailController = TextEditingController(text: 'demo@openflix.vn');
  final _contentController = TextEditingController();
  String _selectedCategory = 'Báo lỗi phát video';
  bool _isLoading = false;
  bool _isSubmitted = false;

  final List<String> _categories = [
    'Báo lỗi phát video',
    'Gợi ý phim mới',
    'Góp ý giao diện / UX',
    'Vấn đề tài khoản',
    'Khác',
  ];

  @override
  void dispose() {
    _emailController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final content = _contentController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập nội dung góp ý hoặc mô tả lỗi!'),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _isSubmitted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isSubmitted) {
      return WavesBackground.wrapIfBlue(Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          leading: const GlassBackButton(),
          title: const Text('Gửi phản hồi'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.success.withAlpha(30),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.success, width: 2),
                  ),
                  child: const Icon(
                    Icons.check_circle_outline,
                    color: AppColors.success,
                    size: 64,
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  'Cảm ơn bạn đã đóng góp!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Text(
                  'Phản hồi của bạn đã được ghi nhận vào hệ thống OpenFlix. Đội ngũ phát triển sẽ xem xét và phản hồi sớm nhất.',
                  softWrap: true,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: 200,
                  child: PrimaryButton.white(
                    text: 'Quay về Cài đặt',
                    onPressed: () => context.pop(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ));
    }

    return WavesBackground.wrapIfBlue(Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: const GlassBackButton(),
        title: Text(
          'Liên hệ & Góp ý',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chúng tôi luôn lắng nghe trải nghiệm của bạn',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Hãy gửi phản hồi để giúp OpenFlix hoàn thiện hơn mỗi ngày.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            SizedBox(height: 20),

            // Category Selector
            Text(
              'CHỦ ĐỀ PHẢN HỒI',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _selectedCategory,
                  dropdownColor: AppColors.surface,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  items: _categories.map((c) {
                    return DropdownMenuItem(value: c, child: Text(c));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedCategory = val);
                  },
                ),
              ),
            ),
            SizedBox(height: 18),

            // Email Field
            Text(
              'EMAIL LIÊN HỆ',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(color: Colors.white, fontSize: 15),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(
                  Icons.email_outlined,
                  color: AppColors.textMuted,
                  size: 20,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
            ),
            SizedBox(height: 18),

            // Content Textarea
            Text(
              'NỘI DUNG CHI TIẾT',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _contentController,
              maxLines: 6,
              style: TextStyle(color: Colors.white, fontSize: 15),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.surface,
                hintText: 'Mô tả chi tiết sự cố bạn gặp phải hoặc gợi ý tính năng mới...',
                hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 13),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(14),
              ),
            ),
            const SizedBox(height: 28),

            // Submit Button
            PrimaryButton.white(
              text: 'Gửi phản hồi',
              isLoading: _isLoading,
              icon: Icons.send_rounded,
              onPressed: _handleSubmit,
            ),
          ],
        ),
      ),
    ));
  }
}
