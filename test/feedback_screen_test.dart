import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openflix/features/account/feedback_screen.dart';
import 'package:openflix/theme/app_theme.dart';

void main() {
  testWidgets('FeedbackScreen renders form, handles inputs and displays success', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 800));

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: const FeedbackScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Liên hệ & Góp ý'), findsOneWidget);
    expect(find.text('CHỦ ĐỀ PHẢN HỒI'), findsOneWidget);
    expect(find.text('Báo lỗi phát video'), findsOneWidget);
    expect(find.text('Gửi phản hồi'), findsOneWidget);

    // Try submit empty
    await tester.tap(find.text('Gửi phản hồi'));
    await tester.pumpAndSettle();
    expect(find.text('Vui lòng nhập nội dung góp ý hoặc mô tả lỗi!'), findsOneWidget);

    // Enter content
    final textFields = find.byType(TextField);
    await tester.enterText(textFields.last, 'Trải nghiệm xem phim rất mượt mà!');
    await tester.pumpAndSettle();

    // Submit valid
    await tester.tap(find.text('Gửi phản hồi'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pumpAndSettle();

    expect(find.text('Cảm ơn bạn đã đóng góp!'), findsOneWidget);
    expect(find.text('Quay về Cài đặt'), findsOneWidget);
  });
}
