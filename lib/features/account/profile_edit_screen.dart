import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/primary_button.dart';
import '../../presentation/widgets/brand/user_avatar_circle.dart';
import '../../presentation/widgets/dialogs/user_avatar_dialog.dart';
import '../../presentation/widgets/glass/glass_components.dart';
import '../../services/theme_service.dart';
import '../../theme/app_theme.dart';
import '../../waves_background.dart';

class ProfileEditScreen extends StatefulWidget {
  final String profileId;

  const ProfileEditScreen({super.key, required this.profileId});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _nameController = TextEditingController();
  Color _selectedColor = ThemeService.instance.primaryColor;
  bool _isKids = false;

  late final List<Color> _palette = [
    ThemeService.instance.primaryColor,
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

    return WavesBackground.wrapIfBlue(Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: const GlassBackButton(),
        title: Text(
          isNew ? 'Thêm hồ sơ' : 'Chỉnh sửa hồ sơ',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar xem trước (Chạm để mở hộp thoại đổi avatar)
            GestureDetector(
              onTap: () => UserAvatarDialog.show(context),
              behavior: HitTestBehavior.opaque,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  if (widget.profileId == 'p1' || !isNew)
                    const UserAvatarCircle(size: 96, showGlow: true)
                  else
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: _selectedColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.5),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Center(
                        child: OpenFlixMorphIcon.snappy(
                          icon: _isKids ? Icons.child_care : Icons.person,
                          color: Colors.white,
                          size: 52,
                        ),
                      ),
                    ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.85),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white38, width: 1.2),
                      ),
                      child: const Icon(
                        Icons.edit_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            InkWell(
              onTap: () => UserAvatarDialog.show(context),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                child: Text(
                  'Chạm để đổi avatar (Chibi / Link ảnh / Đặt lại)',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.white24,
                  ),
                ),
              ),
            ),
            SizedBox(height: 24),

            // Chọn màu đại diện
            Text(
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

            SizedBox(height: 20),

            // Chế độ trẻ em
            Material(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              child: SwitchListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                title: Text(
                  'Chế độ trẻ em',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 15,
                  ),
                ),
                subtitle: Text(
                  'Chỉ hiển thị các nội dung hoạt hình và phim phù hợp mọi lứa tuổi',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                value: _isKids,
                activeThumbColor: ThemeService.instance.primaryColor,
                onChanged: (val) => setState(() => _isKids = val),
              ),
            ),

            SizedBox(height: 32),

            PrimaryButton.white(
              text: isNew ? 'Tạo hồ sơ' : 'Lưu thay đổi',
              onPressed: _save,
            ),

            if (!isNew) ...[
              SizedBox(height: 14),
              TextButton(
                onPressed: () {
                  context.pop();
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text('Đã xóa hồ sơ!')));
                },
                child: Text(
                  'Xóa hồ sơ này',
                  style: TextStyle(color: AppColors.textMuted),
                ),
              ),
            ],
          ],
        ),
      ),
    ));
  }
}
