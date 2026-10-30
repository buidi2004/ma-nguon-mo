import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/widgets/glass/glass_components.dart';
import '../../services/theme_service.dart';
import '../../theme/app_theme.dart';
import '../../waves_background.dart';

class FilterScreen extends StatefulWidget {
  final String? initialCategory;
  final String? initialYear;
  final String? initialSort;

  const FilterScreen({
    super.key,
    this.initialCategory,
    this.initialYear,
    this.initialSort,
  });

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  late String _selectedCategory;
  late String _selectedYear;
  late String _selectedSort;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory ?? 'Tất cả';
    _selectedYear = widget.initialYear ?? 'Tất cả';
    _selectedSort = widget.initialSort ?? 'Mới nhất';
  }

  final List<String> _categories = [
    'Tất cả',
    'Hoạt hình',
    'Viễn tưởng',
    'Hành động',
    'Hài hước',
    'Phiêu lưu',
    'Tài liệu',
  ];

  final List<String> _years = ['Tất cả', '2024', '2023', '2022', 'Trước 2020'];

  final List<String> _sortOptions = [
    'Mới nhất',
    'Xem nhiều nhất',
    'Thời lượng ngắn đến dài',
    'Tên phim A-Z',
  ];

  void _applyFilter() {
    final queryParams = <String, String>{};
    if (_selectedYear != 'Tất cả') {
      queryParams['year'] = _selectedYear;
    }
    if (_selectedSort != 'Mới nhất') {
      queryParams['sort'] = _selectedSort;
    }

    final categoryPath = _selectedCategory;
    final uri = Uri(
      path: '/genre/$categoryPath',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );
    context.pushReplacement(uri.toString());
  }

  @override
  Widget build(BuildContext context) {
    return WavesBackground.wrapIfBlue(Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: const GlassBackButton(),
        title: const Text(
          'Bộ lọc nâng cao',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedCategory = 'Tất cả';
                _selectedYear = 'Tất cả';
                _selectedSort = 'Mới nhất';
              });
            },
            child: const Text(
              'Đặt lại',
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'THỂ LOẠI PHIM',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return GlassChipButton(
                  label: cat,
                  isSelected: isSelected,
                  onSelected: (_) => setState(() => _selectedCategory = cat),
                );
              }).toList(),
            ),

            const SizedBox(height: 28),
            Text(
              'NĂM PHÁT HÀNH',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _years.map((year) {
                final isSelected = _selectedYear == year;
                return GlassChipButton(
                  label: year,
                  isSelected: isSelected,
                  onSelected: (_) => setState(() => _selectedYear = year),
                );
              }).toList(),
            ),

            const SizedBox(height: 28),
            Text(
              'SẮP XẾP KẾT QUẢ',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                children: _sortOptions.map((opt) {
                  final isSelected = _selectedSort == opt;
                  return InkWell(
                    onTap: () => setState(() => _selectedSort = opt),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off,
                            color: isSelected
                                ? ThemeService.instance.primaryColor
                                : AppColors.textMuted,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              opt,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            GlassButton.primary(
              text: 'Áp dụng bộ lọc',
              borderRadius: 14,
              height: 48,
              width: double.infinity,
              onPressed: _applyFilter,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    ));
  }
}
