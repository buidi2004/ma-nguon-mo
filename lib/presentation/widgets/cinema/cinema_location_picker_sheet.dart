import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:openflix/services/cinema/cinema_service.dart';

class CinemaLocationPickerSheet extends StatefulWidget {
  const CinemaLocationPickerSheet({super.key});

  static Future<String?> show(BuildContext context) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CinemaLocationPickerSheet(),
    );
  }

  @override
  State<CinemaLocationPickerSheet> createState() =>
      _CinemaLocationPickerSheetState();
}

class _CinemaLocationPickerSheetState extends State<CinemaLocationPickerSheet> {
  String _searchQuery = '';
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cinemaService = CinemaService.instance;
    const primaryColor = Color(0xFFF97316); // Orange CineFlix Cinema

    final filteredCities = cinemaService.cities.where((city) {
      if (_searchQuery.isEmpty) return true;
      return city.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          city.landmark.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 30, spreadRadius: 8),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            const SizedBox(height: 10),
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Header: Title & Close Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Text(
                    'Tỉnh / Thành phố',
                    style: TextStyle(
                      color: Color(0xFF1E293B),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const Spacer(),
                  // Nút đóng tròn
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Color(0xFF64748B),
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Ô tìm kiếm địa điểm
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    const Icon(
                      Icons.search_rounded,
                      color: Color(0xFF94A3B8),
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) => setState(() => _searchQuery = val),
                        style: const TextStyle(
                          color: Color(0xFF1E293B),
                          fontSize: 15,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Tìm kiếm tỉnh, thành phố...',
                          hintStyle: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 15,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                    if (_searchQuery.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                        child: const Icon(
                          Icons.cancel_rounded,
                          color: Color(0xFF94A3B8),
                          size: 18,
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),
            Divider(color: Colors.grey.shade200, height: 1),

            // Danh sách các Tỉnh / Thành phố
            Expanded(
              child: ListView.separated(
                itemCount: filteredCities.length,
                padding: const EdgeInsets.symmetric(vertical: 8),
                separatorBuilder: (context, index) => Divider(
                  color: Colors.grey.shade100,
                  height: 1,
                  indent: 72,
                  endIndent: 20,
                ),
                itemBuilder: (context, index) {
                  final city = filteredCities[index];
                  final isSelected = city.id == cinemaService.selectedCityId;

                  return InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      cinemaService.selectCity(city.id);
                      Navigator.of(context).pop(city.id);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          // Icon tròn minh họa địa danh
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: isSelected
                                    ? [
                                        primaryColor.withValues(alpha: 0.2),
                                        primaryColor.withValues(alpha: 0.08),
                                      ]
                                    : [
                                        const Color(0xFFE2E8F0),
                                        const Color(0xFFCBD5E1),
                                      ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              border: Border.all(
                                color: isSelected
                                    ? primaryColor
                                    : Colors.grey.shade300,
                                width: 1.5,
                              ),
                            ),
                            child: Icon(
                              city.icon,
                              color: isSelected
                                  ? primaryColor
                                  : const Color(0xFF334155),
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),

                          // Tên tỉnh & Landmark
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  city.name,
                                  style: TextStyle(
                                    color: isSelected
                                        ? primaryColor
                                        : const Color(0xFF1E293B),
                                    fontSize: 15,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  city.landmark,
                                  style: const TextStyle(
                                    color: Color(0xFF64748B),
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),

                          // Dấu tick cam đã chọn (Khớp Screenshot 4)
                          if (isSelected)
                            Container(
                              width: 24,
                              height: 24,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: primaryColor,
                              ),
                              child: const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
