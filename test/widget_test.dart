import 'package:flutter_test/flutter_test.dart';
import 'package:openflix/main.dart';

void main() {
  testWidgets('OpenFlix smoke test', (WidgetTester tester) async {
    // Build OpenFlix app
    await tester.pumpWidget(const OpenFlixApp());

    // Verify OpenFlix title exists
    expect(find.text('OPENFLIX'), findsOneWidget);

    // Advance timer để hoàn tất chuyển hướng Splash
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pumpAndSettle();
  });
}
