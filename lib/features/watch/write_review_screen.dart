import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/widgets/glass/glass_components.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import 'reviews_screen.dart';
import '../../waves_background.dart';

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
    return WavesBackground.wrapIfBlue(Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: const GlassBackButton(),
        title: Text(
          'Viết đánh giá',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Bạn cảm thấy bộ phim này thế nào?',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Chạm vào ngôi sao để chấm điểm mức độ yêu thích',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 24),

            // Dãy 5 sao tương tác bọc trong GlassSurface
            GlassSurface(
              borderRadius: 20,
              tintColor: const Color(0x352A2A2A),
              blur: 8.5,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final starValue = index + 1;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedStars = starValue);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: OpenFlixMorphIcon.snappy(
                        icon: starValue <= _selectedStars
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.amber,
                        size: 38,
                      ),
                    ),
                  );
                }),
              ),
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

            SizedBox(height: 32),

            // Ô nhập nhận xét
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(6),
              ),
              padding: EdgeInsets.all(12),
              child: TextField(
                controller: _commentController,
                maxLines: 5,
                style: TextStyle(color: AppColors.textPrimary, fontSize: 15),
                decoration: InputDecoration(
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

            GlassButton.primary(
              text: 'Gửi đánh giá',
              isLoading: _isLoading,
              height: 48,
              width: double.infinity,
              borderRadius: 12,
              onPressed: _submitReview,
            ),
          ],
        ),
      ),
    ));
  }
}
