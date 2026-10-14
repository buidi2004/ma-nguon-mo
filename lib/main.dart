import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:transit_kit/transit_kit.dart';

import 'core/router/app_router.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Đặt thanh trạng thái trong suốt phù hợp giao diện Dark Mode Netflix
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Cấu hình chuyển cảnh toàn cục chuẩn điện ảnh Netflix (Bản V2)
  GlobalTransitionConfig.instance.setDefaults(
    const TransitionOverride(
      duration: Duration(milliseconds: 220),
      reverseDuration: Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    ),
  );

  runApp(const OpenFlixApp());
}

class OpenFlixApp extends StatelessWidget {
  const OpenFlixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'OpenFlix',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      routerConfig: AppRouter.router,
    );
  }
}
