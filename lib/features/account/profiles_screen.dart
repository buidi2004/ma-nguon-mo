import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';

class ProfileItem {
  final String id;
  final String name;
  final Color color;
  final bool isKids;

  ProfileItem({
    required this.id,
    required this.name,
    required this.color,
    this.isKids = false,
  });
}

class ProfilesScreen extends StatefulWidget {
  const ProfilesScreen({super.key});

  @override
  State<ProfilesScreen> createState() => _ProfilesScreenState();
}

class _ProfilesScreenState extends State<ProfilesScreen> {
  bool _isEditing = false;

  final List<ProfileItem> _profiles = [
    ProfileItem(id: 'p1', name: 'Tôi (Mặc định)', color: AppColors.red),
    ProfileItem(id: 'p2', name: 'Gia đình', color: Colors.blueAccent),
    ProfileItem(
      id: 'p3',
      name: 'Trẻ em',
      color: Colors.greenAccent,
      isKids: true,
    ),
    ProfileItem(id: 'p4', name: 'Bạn bè', color: Colors.purpleAccent),
  ];

  void _selectProfile(ProfileItem profile) {
    if (_isEditing) {
      context.push('/profiles/edit/${profile.id}');
    } else {
      AuthService.instance.updateProfile(profile.name);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã chuyển sang hồ sơ "${profile.name}"'),
          duration: const Duration(seconds: 1),
        ),
      );
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Ai đang xem?',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => _isEditing = !_isEditing);
            },
            child: Text(
              _isEditing ? 'Xong' : 'Quản lý',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _isEditing
                    ? 'Chạm vào hồ sơ để chỉnh sửa'
                    : 'Chọn hồ sơ của bạn để cá nhân hóa nội dung',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 32),

              // Lưới các hồ sơ (Avatar 2 cột)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _profiles.length + 1, // +1 cho nút Tạo mới
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 24,
                  childAspectRatio: 0.8,
                ),
                itemBuilder: (context, index) {
                  // Nút Tạo hồ sơ mới
                  if (index == _profiles.length) {
                    return GestureDetector(
                      onTap: () => context.push('/profiles/edit/new'),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.white24,
                                width: 1.5,
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.add,
                                color: Colors.white70,
                                size: 40,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Thêm hồ sơ',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final profile = _profiles[index];

                  return GestureDetector(
                    onTap: () => _selectProfile(profile),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 88,
                              height: 88,
                              decoration: BoxDecoration(
                                color: profile.color,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.white12,
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  profile.isKids
                                      ? Icons.child_care
                                      : Icons.person,
                                  color: Colors.white,
                                  size: 48,
                                ),
                              ),
                            ),
                            if (_isEditing)
                              Container(
                                width: 88,
                                height: 88,
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          profile.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
