import 'package:flutter/material.dart';

import '../../presentation/widgets/glass/glass_components.dart';
import '../../theme/app_theme.dart';

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
            style: const TextStyle(
              color: AppColors.red,
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Gói Thành Viên OpenFlix',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
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
                border: Border.all(color: AppColors.red.withAlpha(128)),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 1.0),
                    child: Icon(
                      Icons.verified_user_outlined,
                      color: AppColors.red,
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
            const SizedBox(height: 20),

            const Text(
              'Chọn gói xem phim phù hợp nhất với bạn',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Xem phim không quảng cáo, hủy bất cứ lúc nào.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 16),

            // Plan Cards
            for (final plan in _plans) ...[
              GestureDetector(
                onTap: () => setState(() => _selectedPlanId = plan.id),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _selectedPlanId == plan.id
                        ? AppColors.surfaceLight
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _selectedPlanId == plan.id
                          ? AppColors.red
                          : Colors.white12,
                      width: _selectedPlanId == plan.id ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                    ),
                                  ),
                                ),
                                if (plan.isPopular) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.red,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'PHỔ BIẾN NHẤT',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            _selectedPlanId == plan.id
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            color: _selectedPlanId == plan.id
                                ? AppColors.red
                                : Colors.white38,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        plan.price,
                        style: const TextStyle(
                          color: AppColors.red,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Divider(color: Colors.white10),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.high_quality,
                            size: 18,
                            color: Colors.white70,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Độ phân giải: ${plan.resolution}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.devices,
                            size: 18,
                            color: Colors.white70,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              plan.devices,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      for (final perk in plan.perks) ...[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 1.5),
                                child: Icon(
                                  Icons.check,
                                  size: 14,
                                  color: AppColors.success,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  perk,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      _selectedPlanId == plan.id
                          ? GlassButton.brand(
                              text: 'Chọn ${plan.name}',
                              height: 42,
                              borderRadius: 10,
                              width: double.infinity,
                              onPressed: () => _choosePlan(plan),
                            )
                          : GlassButton.neutral(
                              text: 'Xem chi tiết gói',
                              height: 42,
                              borderRadius: 10,
                              width: double.infinity,
                              onPressed: () => _choosePlan(plan),
                            ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
