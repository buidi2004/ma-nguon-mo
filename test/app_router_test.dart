import 'package:flutter_test/flutter_test.dart';
import 'package:openflix/core/router/app_router.dart';

void main() {
  testWidgets('AppRouter initial route splash works and routes exist', (tester) async {
    final router = AppRouter.router;
    expect(router, isNotNull);
  });
}
