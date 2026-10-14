import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/primary_button.dart';
import '../../theme/app_theme.dart';

class ProfileEditScreen extends StatefulWidget {
  final String profileId;

  const ProfileEditScreen({super.key, required this.profileId});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _nameController = TextEditingController();
  Color _selectedColor = AppColors.red;
  bool _isKids = false;

  final List<Color> _palette = [
    AppColors.red,
    Colors.blueAccent,
    Colors.purpleAccent,
    Colors.tealAccent,
    Colors.amber,
    Colors.pinkAccent,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.profileId == 'new') {
      _nameController.text = 'Hồ sơ mới';
      _selectedColor = Colors.tealAccent;
    } else {
      _nameController.text = 'Hồ sơ #${widget.profileId}';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã lưu hồ sơ "${_nameController.text.trim()}"!'),
        backgroundColor: AppColors.success,
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.profileId == 'new';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          isNew ? 'Thêm hồ sơ' : 'Chỉnh sửa hồ sơ',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar xem trước
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: _selectedColor,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  _isKids ? Icons.child_care : Icons.person,
                  color: Colors.white,
                  size: 56,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Chọn màu đại diện
            const Text(
              'Chọn màu đại diện',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 10,
              children: _palette.map((color) {
                final isSelected = _selectedColor == color;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = color),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.transparent,
                        width: 2.5,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 28),

            AppTextField(
              controller: _nameController,
              label: 'Tên hồ sơ',
              hintText: 'Nhập tên hồ sơ',
              prefixIcon: Icons.badge_outlined,
            ),

            const SizedBox(height: 20),

            // Chế độ trẻ em
            Material(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(6),
              child: SwitchListTile(
                title: const Text(
                  'Chế độ trẻ em',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
                subtitle: const Text(
                  'Chỉ hiển thị các nội dung hoạt hình và phim phù hợp mọi lứa tuổi',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                value: _isKids,
                activeThumbColor: AppColors.red,
                onChanged: (val) => setState(() => _isKids = val),
              ),
            ),

            const SizedBox(height: 32),

            PrimaryButton.white(
              text: isNew ? 'Tạo hồ sơ' : 'Lưu thay đổi',
              onPressed: _save,
            ),

            if (!isNew) ...[
              const SizedBox(height: 14),
              TextButton(
                onPressed: () {
                  context.pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã xóa hồ sơ!')),
                  );
                },
                child: const Text(
                  'Xóa hồ sơ này',
                  style: TextStyle(color: AppColors.textMuted),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
