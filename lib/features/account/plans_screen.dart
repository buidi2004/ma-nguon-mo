import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../presentation/widgets/glass/glass_components.dart';
import '../../services/theme_service.dart';
import '../../theme/app_theme.dart';
import '../../waves_background.dart';

class PlanOption {
  final String id;
  final String name;
  final String price;
  final String resolution;
  final String devices;
  final bool isPopular;
  final List<String> perks;

  const PlanOption({
    required this.id,
    required this.name,
    required this.price,
    required this.resolution,
    required this.devices,
    this.isPopular = false,
    required this.perks,
  });
}

class PlansScreen extends StatefulWidget {
  const PlansScreen({super.key});

  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> {
  String _selectedPlanId = 'standard';

  final List<PlanOption> _plans = const [
    PlanOption(
      id: 'basic',
      name: 'Gói Cơ Bản',
      price: '70.000đ / tháng',
      resolution: 'HD 720p',
      devices: '1 thiết bị xem cùng lúc',
      perks: [
        'Xem không giới hạn kho phim OpenFlix',
        'Tải phim xem offline trên 1 thiết bị',
        'Không có quảng cáo làm phiền',
      ],
    ),
    PlanOption(
      id: 'standard',
      name: 'Gói Tiêu Chuẩn',
      price: '130.000đ / tháng',
      resolution: 'Full HD 1080p',
      devices: '2 thiết bị xem cùng lúc',
      isPopular: true,
      perks: [
        'Hình ảnh sắc nét chuẩn 1080p',
        'Tải offline trên 2 thiết bị di động',
        'Hỗ trợ âm thanh nổi sống động',
        'Xem phim cùng lúc trên TV và Điện thoại',
      ],
    ),
    PlanOption(
      id: 'premium',
      name: 'Gói Cao Cấp',
      price: '190.000đ / tháng',
      resolution: 'Ultra HD 4K + HDR',
      devices: '4 thiết bị xem cùng lúc',
      perks: [
        'Độ phân giải Ultra HD 4K cực đỉnh',
        'Công nghệ HDR và Âm thanh vòm Dolby Atmos',
        'Tải offline trên tối đa 6 thiết bị',
        'Ưu tiên trải nghiệm phim mới ra mắt sớm nhất',
      ],
    ),
  ];

  BorderBeamColorVariant _getColorVariant(String planId) {
    if (ThemeService.instance.isWindowsBlue) {
      return BorderBeamColorVariant.neonBlue;
    }
    switch (planId) {
      case 'premium':
        return BorderBeamColorVariant.amberGold;
      case 'standard':
        return BorderBeamColorVariant.brand;
      case 'basic':
        return BorderBeamColorVariant.neonBlue;
      default:
        return BorderBeamColorVariant.brand;
    }
  }

  void _choosePlan(PlanOption plan) {
    showGlassDialog(
      context: context,
      title: 'Đăng ký ${plan.name}',
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Đóng', style: TextStyle(color: Colors.white60)),
        ),
        const SizedBox(width: 8),
        GlassButton.brand(
          text: 'Xác nhận kích hoạt',
          height: 38,
          borderRadius: 10,
          onPressed: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Đã kích hoạt mô phỏng ${plan.name} thành công!'),
                backgroundColor: AppColors.success,
              ),
            );
          },
        ),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Giá gói: ${plan.price}',
            style: TextStyle(
              color: ThemeService.instance.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Độ phân giải: ${plan.resolution}',
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black38,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.amber, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Đây là giao diện mô phỏng đồ án. Tài khoản của bạn được cấp quyền trải nghiệm đầy đủ miễn phí!',
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedPlan = _plans.firstWhere(
      (p) => p.id == _selectedPlanId,
      orElse: () => _plans[1],
    );

    return WavesBackground.wrapIfBlue(Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: const GlassBackButton(),
        title: Text(
          'Gói Thành Viên OpenFlix',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Simulation banner disclaimer
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: ThemeService.instance.primaryColor.withAlpha(128),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 1.0),
                    child: Icon(
                      Icons.verified_user_outlined,
                      color: ThemeService.instance.primaryColor,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mô phỏng đồ án học tập',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'OpenFlix là dự án mã nguồn mở phi lợi nhuận. Màn hình thanh toán này thiết kế để hoàn thiện đủ 42 màn hình theo đặc tả.',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            Text(
              'Chọn gói xem phim phù hợp nhất với bạn',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Xem phim không quảng cáo, hủy bất cứ lúc nào.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 16),

            // Plan Cards với hiệu ứng BorderBeam quang học cao cấp
            for (final plan in _plans) ...[
              Builder(
                builder: (context) {
                  final isSelected = _selectedPlanId == plan.id;
                  final primaryColor = ThemeService.instance.primaryColor;
                  final colorVariant = _getColorVariant(plan.id);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Semantics(
                      label:
                          '${plan.name}, giá ${plan.price}, độ phân giải ${plan.resolution}',
                      selected: isSelected,
                      button: true,
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _selectedPlanId = plan.id);
                        },
                        behavior: HitTestBehavior.opaque,
                        child: BorderBeam(
                          duration: isSelected ? 5.0 : 8.0,
                          borderWidth: isSelected ? 2.0 : 1.0,
                          borderRadius: BorderRadius.circular(14),
                          colorVariant: colorVariant,
                          glowRadius: isSelected ? 10.0 : 0.0,
                          showGlow: isSelected,
                          active: isSelected,
                          trackColor: isSelected
                              ? primaryColor.withValues(alpha: 0.35)
                              : Colors.white.withValues(alpha: 0.08),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 240),
                            curve: Curves.easeOutCubic,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: isSelected
                                  ? const Color(0xFF1E1E1E)
                                  : const Color(0xFF151515),
                              gradient: isSelected
                                  ? LinearGradient(
                                      colors: [
                                        (plan.id == 'premium'
                                                ? const Color(0xFFFFB300)
                                                : primaryColor)
                                            .withValues(alpha: 0.14),
                                        const Color(0xFF1B1B1B),
                                        const Color(0xFF141414),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    )
                                  : null,
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: (plan.id == 'premium'
                                                ? const Color(0xFFFFB300)
                                                : primaryColor)
                                            .withValues(alpha: 0.26),
                                        blurRadius: 18,
                                        offset: const Offset(0, 4),
                                      ),
                                      const BoxShadow(
                                        color: Color(0x66000000),
                                        blurRadius: 10,
                                        offset: Offset(0, 2),
                                      ),
                                    ]
                                  : const [
                                      BoxShadow(
                                        color: Color(0x33000000),
                                        blurRadius: 6,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header: Tên gói, Badges và Icon Radio
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              plan.name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 17,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: -0.2,
                                              ),
                                            ),
                                          ),
                                          if (plan.isPopular) ...[
                                            const SizedBox(width: 8),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 7,
                                                vertical: 3,
                                              ),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    primaryColor,
                                                    primaryColor.withValues(
                                                        alpha: 0.85),
                                                  ],
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: primaryColor
                                                        .withValues(alpha: 0.35),
                                                    blurRadius: 6,
                                                    offset:
                                                        const Offset(0, 1.5),
                                                  ),
                                                ],
                                              ),
                                              child: const Row(
                                                mainAxisSize:
                                                    MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.auto_awesome,
                                                    size: 11,
                                                    color: Colors.white,
                                                  ),
                                                  SizedBox(width: 3),
                                                  Text(
                                                    'PHỔ BIẾN NHẤT',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10.5,
                                                      fontWeight: FontWeight.w800,
                                                      letterSpacing: 0.3,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ] else if (plan.id == 'premium') ...[
                                            const SizedBox(width: 8),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 7,
                                                vertical: 3,
                                              ),
                                              decoration: BoxDecoration(
                                                gradient: const LinearGradient(
                                                  colors: [
                                                    Color(0xFFFFB300),
                                                    Color(0xFFF57C00),
                                                  ],
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color:
                                                        const Color(0xFFFFB300)
                                                            .withValues(
                                                                alpha: 0.35),
                                                    blurRadius: 6,
                                                    offset:
                                                        const Offset(0, 1.5),
                                                  ),
                                                ],
                                              ),
                                              child: const Row(
                                                mainAxisSize:
                                                    MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons
                                                        .workspace_premium_rounded,
                                                    size: 12,
                                                    color: Colors.black87,
                                                  ),
                                                  SizedBox(width: 3),
                                                  Text(
                                                    '4K HDR VIP',
                                                    style: TextStyle(
                                                      color: Colors.black87,
                                                      fontSize: 10.5,
                                                      fontWeight: FontWeight.w900,
                                                      letterSpacing: 0.3,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    AnimatedSwitcher(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      transitionBuilder: (child, anim) =>
                                          ScaleTransition(
                                              scale: anim, child: child),
                                      child: Icon(
                                        isSelected
                                            ? Icons.check_circle_rounded
                                            : Icons
                                                .radio_button_unchecked_rounded,
                                        key: ValueKey<bool>(isSelected),
                                        color: isSelected
                                            ? (plan.id == 'premium'
                                                ? const Color(0xFFFFB300)
                                                : primaryColor)
                                            : Colors.white30,
                                        size: 24,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  plan.price,
                                  style: TextStyle(
                                    color: isSelected
                                        ? (plan.id == 'premium'
                                            ? const Color(0xFFFFC107)
                                            : primaryColor)
                                        : Colors.white
                                            .withValues(alpha: 0.85),
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Divider(
                                  color: Colors.white.withValues(alpha: 0.08),
                                  height: 1,
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.high_quality_rounded,
                                      size: 18,
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.white70,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Độ phân giải: ${plan.resolution}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.white70,
                                          fontSize: 13,
                                          fontWeight: isSelected
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.devices_rounded,
                                      size: 18,
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.white70,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        plan.devices,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.white70,
                                          fontSize: 13,
                                          fontWeight: isSelected
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                for (final perk in plan.perks) ...[
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 6),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          margin:
                                              const EdgeInsets.only(top: 2),
                                          width: 17,
                                          height: 17,
                                          decoration: BoxDecoration(
                                            color: AppColors.success
                                                .withValues(alpha: 0.16),
                                            shape: BoxShape.circle,
                                          ),
                                          alignment: Alignment.center,
                                          child: const Icon(
                                            Icons.check_rounded,
                                            size: 12,
                                            color: AppColors.success,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            perk,
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: isSelected
                                                  ? Colors.white
                                                      .withValues(alpha: 0.88)
                                                  : AppColors.textSecondary,
                                              fontSize: 12.5,
                                              height: 1.35,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: const Border(
            top: BorderSide(color: Colors.white12, width: 0.8),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 12,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        padding: EdgeInsets.fromLTRB(
          16,
          10,
          16,
          MediaQuery.paddingOf(context).bottom + 10,
        ),
        child: GlassButton.brand(
          text: 'Tiếp tục với ${selectedPlan.name}',
          height: 48,
          borderRadius: 12,
          width: double.infinity,
          onPressed: () => _choosePlan(selectedPlan),
        ),
      ),
    ));
  }
}
