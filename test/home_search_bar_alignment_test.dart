import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openflix/presentation/widgets/brand/app_brand_logo.dart';
import 'package:openflix/presentation/widgets/brand/user_avatar_circle.dart';
import 'package:openflix/screens/home_screen.dart';
import 'package:openflix/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildTestableHome() {
    return MaterialApp(
      theme: buildAppTheme(),
      home: const HomeScreen(enableTrialPromo: false),
    );
  }

  group('HomeScreen Clean Cinema AppBar Tests', () {
    testWidgets(
      'Removes search icon and cloud status button, renders clean brand header with UserAvatarButton',
      (tester) async {
        await tester.pumpWidget(buildTestableHome());
        await tester.pump(const Duration(milliseconds: 300));

        // 1. Verify brand logo is present on the top left
        expect(find.byType(AppBrandLogo), findsOneWidget);

        // 2. Verify search icon button is REMOVED from AppBar
        expect(find.byTooltip('Tìm kiếm'), findsNothing);
        expect(find.byIcon(Icons.search), findsNothing);
        expect(find.byIcon(Icons.search_rounded), findsNothing);

        // 3. Verify cloud status icon button is REMOVED from AppBar
        expect(find.byTooltip('Kết nối máy chủ'), findsNothing);
        expect(find.byIcon(Icons.cloud_done_rounded), findsNothing);

        // 4. Verify user avatar is PRESENT in AppBar actions
        expect(find.byType(UserAvatarButton), findsOneWidget);
        expect(find.byTooltip('Tài khoản & Cá nhân'), findsOneWidget);

        // 5. Verify orange cinema booking banner is REMOVED/HIDDEN from HomeScreen
        expect(find.text('ĐẶT VÉ PHIM RẠP TOÀN QUỐC'), findsNothing);
      },
    );
  });
}
