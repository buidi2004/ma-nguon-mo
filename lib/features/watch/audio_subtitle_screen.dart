import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/primary_button.dart';
import '../../theme/app_theme.dart';

class AudioSubtitleScreen extends StatefulWidget {
  final String movieId;

  const AudioSubtitleScreen({super.key, required this.movieId});

  @override
  State<AudioSubtitleScreen> createState() => _AudioSubtitleScreenState();
}

class _AudioSubtitleScreenState extends State<AudioSubtitleScreen> {
  String _selectedAudio = 'vi_dub';
  String _selectedSubtitle = 'vi';
  double _subtitleSize = 1.0;

  final List<Map<String, String>> _audioOptions = [
    {'id': 'vi_dub', 'title': 'Tiếng Việt', 'desc': 'Thuyết minh chuẩn HD'},
    {'id': 'en_orig', 'title': 'Tiếng Anh (Gốc)', 'desc': 'Dolby Digital 5.1'},
    {'id': 'ja_dub', 'title': 'Tiếng Nhật', 'desc': 'Lồng tiếng Studio'},
  ];

  final List<Map<String, String>> _subtitleOptions = [
    {'id': 'off', 'title': 'Tắt phụ đề', 'desc': ''},
    {'id': 'vi', 'title': 'Tiếng Việt', 'desc': 'Dịch đầy đủ ngữ nghĩa'},
    {
      'id': 'en',
      'title': 'Tiếng Anh [CC]',
      'desc': 'Kèm mô tả âm thanh môi trường',
    },
    {'id': 'ja', 'title': 'Tiếng Nhật', 'desc': 'Phụ đề Kanji chuẩn'},
  ];

  void _applySettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã cập nhật cài đặt âm thanh & phụ đề cho video'),
        backgroundColor: AppColors.surface,
        duration: Duration(seconds: 2),
      ),
    );
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/movie/${widget.movieId}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/movie/${widget.movieId}');
            }
          },
        ),
        title: const Text(
          'Âm thanh & Phụ đề',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                children: [
                  const Text(
                    'ÂM THANH',
                    style: TextStyle(
                      color: AppColors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._audioOptions.map((opt) {
                    final isSelected = _selectedAudio == opt['id'];
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedAudio = opt['id']!;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 8,
                        ),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: AppColors.divider,
                              width: 0.5,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    opt['title']!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      fontSize: 14,
                                    ),
                                  ),
                                  if (opt['desc']!.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      opt['desc']!,
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check,
                                color: AppColors.red,
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 24),
                  const Text(
                    'PHỤ ĐỀ',
                    style: TextStyle(
                      color: AppColors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._subtitleOptions.map((opt) {
                    final isSelected = _selectedSubtitle == opt['id'];
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedSubtitle = opt['id']!;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 8,
                        ),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: AppColors.divider,
                              width: 0.5,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    opt['title']!,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      fontSize: 14,
                                    ),
                                  ),
                                  if (opt['desc']!.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      opt['desc']!,
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check,
                                color: AppColors.red,
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 24),
                  const Text(
                    'KÍCH THƯỚC CHỮ PHỤ ĐỀ',
                    style: TextStyle(
                      color: AppColors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildSizeOption('Nhỏ (75%)', 0.75),
                      _buildSizeOption('Chuẩn (100%)', 1.0),
                      _buildSizeOption('Lớn (125%)', 1.25),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Xem trước: "Mẫu chữ phụ đề hiển thị khi đang xem phim."',
                      style: TextStyle(
                        color: Colors.yellowAccent,
                        fontSize: 14 * _subtitleSize,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: PrimaryButton.white(
                text: 'Áp dụng cài đặt',
                onPressed: _applySettings,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSizeOption(String label, double scale) {
    final isSelected = (_subtitleSize - scale).abs() < 0.05;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.red,
      backgroundColor: AppColors.surface,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      onSelected: (_) {
        setState(() {
          _subtitleSize = scale;
        });
      },
    );
  }
}
