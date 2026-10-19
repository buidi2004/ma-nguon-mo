import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:transit_kit/transit_kit.dart';

import 'core/router/app_router.dart';
import 'services/theme_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeService.instance.init();

  // Đặt thanh trạng thái trong suốt phù hợp giao diện Dark Mode Netflix
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.darkBackground,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Cấu hình chuyển cảnh toàn cục chuẩn Điện ảnh Thượng hạng (Cinematic Cinema Luxe)
  GlobalTransitionConfig.instance.setDefaults(
    const TransitionOverride(
      duration: Duration(milliseconds: 300),
      reverseDuration: Duration(milliseconds: 240),
      curve: Curves.easeInOutCubic,
      reverseCurve: Curves.easeInCubic,
    ),
  );

  // Cấu hình tối ưu riêng cho các hiệu ứng rạp chiếu phim đặc biệt
  GlobalTransitionConfig.instance.setOverrideFor(
    TransitType.cinematicReveal,
    const TransitionOverride(
      duration: Duration(milliseconds: 340),
      curve: Curves.easeInOutCubic,
    ),
  );
  GlobalTransitionConfig.instance.setOverrideFor(
    TransitType.cinematicBars,
    const TransitionOverride(
      duration: Duration(milliseconds: 320),
      curve: Curves.easeInOutCubic,
    ),
  );
  GlobalTransitionConfig.instance.setOverrideFor(
    TransitType.dollyZoomIn,
    const TransitionOverride(
      duration: Duration(milliseconds: 340),
      curve: Curves.easeOutQuart,
    ),
  );
  GlobalTransitionConfig.instance.setOverrideFor(
    TransitType.neonGlow,
    const TransitionOverride(
      duration: Duration(milliseconds: 340),
      curve: Curves.easeOutCubic,
    ),
  );

  runApp(const OpenFlixApp());
}

class OpenFlixApp extends StatelessWidget {
  const OpenFlixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeService.instance,
      builder: (context, _) {
        return MaterialApp.router(
          title: 'OpenFlix',
          debugShowCheckedModeBanner: false,
          theme: buildAppTheme(
            ThemeService.instance.primaryColor,
            ThemeService.instance.isLight,
          ),
          routerConfig: AppRouter.router,
        );
      },
    );
  }
}
