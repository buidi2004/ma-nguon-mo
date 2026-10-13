import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/primary_button.dart';
import '../../theme/app_theme.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _selectedCategory = 'Báo lỗi phát phim';
  bool _isLoading = false;
  bool _isSuccess = false;

  final List<String> _categories = [
    'Báo lỗi phát phim',
    'Yêu cầu bổ sung phim',
    'Góp ý trải nghiệm giao diện',
    'Vấn đề tài khoản & bảo mật',
    'Khác',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng điền đầy đủ tiêu đề và nội dung góp ý'),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 800));

    if (mounted) {
      setState(() {
        _isLoading = false;
        _isSuccess = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
              context.go('/help');
            }
          },
        ),
        title: const Text(
          'Liên hệ & Góp ý',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: _isSuccess
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),
                    Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.success,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 48,
                          color: AppColors.success,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Cảm ơn đóng góp của bạn!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Ý kiến của bạn đã được gửi đến đội ngũ phát triển OpenFlix. Chúng tôi sẽ phản hồi qua email nếu cần thêm thông tin.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 36),
                    PrimaryButton.white(
                      text: 'Hoàn tất',
                      onPressed: () {
                        setState(() {
                          _titleController.clear();
                          _contentController.clear();
                          _isSuccess = false;
                        });
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/me');
                        }
                      },
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'CHỦ ĐỀ GÓP Ý',
                      style: TextStyle(
                        color: AppColors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCategory,
                          isExpanded: true,
                          dropdownColor: AppColors.surface,
                          icon: const Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.white,
                          ),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedCategory = val;
                              });
                            }
                          },
                          items: _categories.map((cat) {
                            return DropdownMenuItem(
                              value: cat,
                              child: Text(cat),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    AppTextField(
                      controller: _titleController,
                      label: 'Tiêu đề phản hồi',
                      hintText: 'Ví dụ: Video tập 2 không có phụ đề tiếng Việt',
                      prefixIcon: Icons.title,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'NỘI DUNG CHI TIẾT',
                      style: TextStyle(
                        color: AppColors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: TextField(
                        controller: _contentController,
                        maxLines: 5,
                        maxLength: 500,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Mô tả chi tiết vấn đề hoặc ý tưởng của bạn để chúng tôi hỗ trợ tốt nhất...',
                          hintStyle: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 13,
                          ),
                          counterStyle: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    PrimaryButton.white(
                      text: 'Gửi phản hồi',
                      isLoading: _isLoading,
                      onPressed: _handleSubmit,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
