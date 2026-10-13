import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/primary_button.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import 'reviews_screen.dart';

class WriteReviewScreen extends StatefulWidget {
  final String movieId;

  const WriteReviewScreen({super.key, required this.movieId});

  @override
  State<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends State<WriteReviewScreen> {
  int _selectedStars = 5;
  final _commentController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submitReview() {
    final text = _commentController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập nội dung đánh giá của bạn!'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      final newReview = ReviewItem(
        author: AuthService.instance.userName,
        rating: _selectedStars,
        comment: text,
        timeAgo: 'Vừa xong',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cảm ơn bạn đã đóng góp đánh giá!'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop(newReview);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Viết đánh giá',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Bạn cảm thấy bộ phim này thế nào?',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Chạm vào ngôi sao để chấm điểm mức độ yêu thích',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 24),

            // Dãy 5 sao tương tác
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starValue = index + 1;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedStars = starValue);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Icon(
                      starValue <= _selectedStars
                          ? Icons.star
                          : Icons.star_border,
                      color: Colors.amber,
                      size: 38,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 12),
            Text(
              '$_selectedStars / 5 sao',
              style: const TextStyle(
                color: Colors.amber,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 32),

            // Ô nhập nhận xét
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(6),
              ),
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _commentController,
                maxLines: 5,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Chia sẻ cảm nhận chi tiết của bạn về kỹ xảo, diễn xuất, âm nhạc...',
                  hintStyle: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),

            const SizedBox(height: 28),

            PrimaryButton.white(
              text: 'Gửi đánh giá',
              isLoading: _isLoading,
              onPressed: _submitReview,
            ),
          ],
        ),
      ),
    );
  }
}
