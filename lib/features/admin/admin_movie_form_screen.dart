import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/primary_button.dart';
import '../../models/movie_model.dart';
import '../../presentation/widgets/glass/glass_components.dart';
import '../../services/pocketbase_service.dart';
import '../../theme/app_theme.dart';
import '../../waves_background.dart';

class AdminMovieFormScreen extends StatefulWidget {
  final MovieModel? movie;

  const AdminMovieFormScreen({super.key, this.movie});

  @override
  State<AdminMovieFormScreen> createState() => _AdminMovieFormScreenState();
}

class _AdminMovieFormScreenState extends State<AdminMovieFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  late final TextEditingController _categoryCustomController;
  late final TextEditingController _posterUrlController;
  late final TextEditingController _videoUrlController;
  late final TextEditingController _trailerUrlController;
  late final TextEditingController _yearController;
  late final TextEditingController _durationController;
  late final TextEditingController _directorController;
  late final TextEditingController _castController;
  late final TextEditingController _rankController;

  static const List<String> _suggestedCategories = [
    'Hành động',
    'Hoạt hình',
    'Viễn tưởng',
    'Tâm lý',
    'Hài hước',
    'Kinh dị',
    'Tài liệu',
    'Phiêu lưu',
    'Khác',
  ];

  static const List<String> _ageRatings = ['P', '13+', '16+', '18+'];

  late String _selectedCategory;
  late String _ageRating;
  late bool _isFeatured;
  late bool _isNew;
  late bool _comingSoon;
  bool _isLoading = false;
  String _previewPosterUrl = '';

  bool get _isEditing => widget.movie != null;

  @override
  void initState() {
    super.initState();
    final m = widget.movie;

    _titleController = TextEditingController(text: m?.title ?? '');
    _descController = TextEditingController(text: m?.description ?? '');
    _posterUrlController = TextEditingController(text: m?.posterUrl ?? '');
    _videoUrlController = TextEditingController(text: m?.videoUrl ?? '');
    _trailerUrlController = TextEditingController(text: m?.trailerUrl ?? '');
    _yearController = TextEditingController(
      text: (m?.releaseYear ?? DateTime.now().year).toString(),
    );
    _durationController = TextEditingController(
      text: (m?.durationMinutes ?? 90).toString(),
    );
    _directorController = TextEditingController(
      text: m?.director ?? 'Blender Foundation',
    );
    _castController = TextEditingController(
      text: m?.cast ?? 'Diễn viên OpenFlix',
    );
    _rankController = TextEditingController(
      text: m?.rank != null && m!.rank! > 0 ? m.rank.toString() : '',
    );

    final existingCat = m?.category ?? 'Hành động';
    if (_suggestedCategories.contains(existingCat)) {
      _selectedCategory = existingCat;
      _categoryCustomController = TextEditingController();
    } else {
      _selectedCategory = 'Khác';
      _categoryCustomController = TextEditingController(text: existingCat);
    }

    _ageRating = m?.ageRating ?? '13+';
    _isFeatured = m?.isFeatured ?? false;
    _isNew = m?.isNew ?? (!_isEditing);
    _comingSoon = m?.comingSoon ?? false;
    _previewPosterUrl = m?.posterUrl ?? '';

    _posterUrlController.addListener(_onPosterUrlChanged);
  }

  void _onPosterUrlChanged() {
    final text = _posterUrlController.text.trim();
    if (text != _previewPosterUrl) {
      setState(() {
        _previewPosterUrl = text;
      });
    }
  }

  @override
  void dispose() {
    _posterUrlController.removeListener(_onPosterUrlChanged);
    _titleController.dispose();
    _descController.dispose();
    _categoryCustomController.dispose();
    _posterUrlController.dispose();
    _videoUrlController.dispose();
    _trailerUrlController.dispose();
    _yearController.dispose();
    _durationController.dispose();
    _directorController.dispose();
    _castController.dispose();
    _rankController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng kiểm tra lại các trường thông tin bắt buộc!'),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }

    final title = _titleController.text.trim();
    final videoUrl = _videoUrlController.text.trim();
    final posterUrl = _posterUrlController.text.trim();

    String finalCategory = _selectedCategory;
    if (_selectedCategory == 'Khác') {
      final customCat = _categoryCustomController.text.trim();
      if (customCat.isNotEmpty) {
        finalCategory = customCat;
      }
    }

    final year =
        int.tryParse(_yearController.text.trim()) ?? DateTime.now().year;
    final duration = int.tryParse(_durationController.text.trim()) ?? 90;
    final rank = int.tryParse(_rankController.text.trim());

    final data = <String, dynamic>{
      'title': title,
      'description': _descController.text.trim(),
      'category': finalCategory,
      'poster_url': posterUrl,
      'video_url': videoUrl,
      'trailer_url': _trailerUrlController.text.trim(),
      'release_year': year,
      'duration_minutes': duration,
      'age_rating': _ageRating,
      'director': _directorController.text.trim(),
      'cast': _castController.text.trim(),
      'is_featured': _isFeatured,
      'is_new': _isNew,
      'coming_soon': _comingSoon,
      'rank': rank != null && rank > 0 ? rank : 0,
    };

    setState(() => _isLoading = true);

    try {
      if (_isEditing) {
        await PocketBaseService.instance.updateMovie(widget.movie!.id, data);
      } else {
        await PocketBaseService.instance.createMovie(data);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Đã cập nhật phim "$title" thành công!'
                : 'Đã thêm phim mới "$title" thành công!',
          ),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Lỗi khi lưu dữ liệu phim: $e. Dữ liệu đã được giữ nguyên.',
          ),
          backgroundColor: AppColors.red,
        ),
      );
    }
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Colors.white10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: AppColors.red, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ...children,
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WavesBackground.wrapIfBlue(Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: const GlassBackButton(fallbackRoute: '/admin/movies'),
        title: Text(
          _isEditing ? 'Chỉnh sửa phim' : 'Thêm phim mới',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // KHỐI 1: THÔNG TIN CƠ BẢN
                      _buildSectionCard(
                        title: '1. Thông tin cơ bản',
                        icon: Icons.movie_outlined,
                        children: [
                          AppTextField(
                            controller: _titleController,
                            label: 'Tiêu đề phim *',
                            hintText: 'Nhập tên phim chính thức...',
                            prefixIcon: Icons.title_rounded,
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Tên phim không được để trống';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 14),
                          Text(
                            'Thể loại phim',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _suggestedCategories.map((cat) {
                              final isSelected = _selectedCategory == cat;
                              return ChoiceChip(
                                label: Text(cat),
                                selected: isSelected,
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() => _selectedCategory = cat);
                                  }
                                },
                                selectedColor: AppColors.red,
                                backgroundColor: AppColors.cardDark,
                                labelStyle: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.textSecondary,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: 13,
                                ),
                                side: BorderSide(
                                  color: isSelected
                                      ? AppColors.red
                                      : Colors.white12,
                                ),
                              );
                            }).toList(),
                          ),
                          if (_selectedCategory == 'Khác') ...[
                            const SizedBox(height: 12),
                            AppTextField(
                              controller: _categoryCustomController,
                              label: 'Nhập thể loại khác',
                              hintText: 'Ví dụ: Ca nhạc, Giật gân...',
                            ),
                          ],
                          const SizedBox(height: 14),
                          AppTextField(
                            controller: _descController,
                            label: 'Mô tả tóm tắt nội dung',
                            hintText:
                                'Giới thiệu cốt truyện và điểm nổi bật...',
                            maxLines: 4,
                            keyboardType: TextInputType.multiline,
                          ),
                        ],
                      ),

                      // KHỐI 2: THÔNG SỐ PHÁT HÀNH
                      _buildSectionCard(
                        title: '2. Thông số phát hành & Sản xuất',
                        icon: Icons.info_outline_rounded,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: AppTextField(
                                  controller: _yearController,
                                  label: 'Năm phát hành',
                                  hintText: '2024',
                                  keyboardType: TextInputType.number,
                                  validator: (val) {
                                    final num = int.tryParse(val ?? '');
                                    if (num == null ||
                                        num < 1900 ||
                                        num > DateTime.now().year + 3) {
                                      return 'Năm không hợp lệ';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: AppTextField(
                                  controller: _durationController,
                                  label: 'Thời lượng (phút)',
                                  hintText: '90',
                                  keyboardType: TextInputType.number,
                                  validator: (val) {
                                    final num = int.tryParse(val ?? '');
                                    if (num == null || num <= 0) {
                                      return 'Thời lượng > 0';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 14),
                          Text(
                            'Phân loại độ tuổi',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: _ageRatings.map((rating) {
                              final isSelected = _ageRating == rating;
                              return Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  child: OutlinedButton(
                                    onPressed: () {
                                      setState(() => _ageRating = rating);
                                    },
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: isSelected
                                          ? AppColors.red.withValues(alpha: 0.2)
                                          : AppColors.cardDark,
                                      side: BorderSide(
                                        color: isSelected
                                            ? AppColors.red
                                            : Colors.white12,
                                        width: isSelected ? 1.5 : 1,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                    ),
                                    child: Text(
                                      rating,
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : AppColors.textSecondary,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 14),
                          AppTextField(
                            controller: _directorController,
                            label: 'Đạo diễn',
                            hintText: 'Tên đạo diễn...',
                            prefixIcon: Icons.person_outline_rounded,
                          ),
                          const SizedBox(height: 14),
                          AppTextField(
                            controller: _castController,
                            label: 'Diễn viên chính',
                            hintText: 'Danh sách diễn viên nổi bật...',
                            prefixIcon: Icons.groups_outlined,
                          ),
                        ],
                      ),

                      // KHỐI 3: MEDIA & LIVE PREVIEW
                      _buildSectionCard(
                        title: '3. Đường dẫn Media & Poster',
                        icon: Icons.video_library_outlined,
                        children: [
                          AppTextField(
                            controller: _videoUrlController,
                            label: 'URL Video phát chính *',
                            hintText:
                                'https://example.com/video.mp4 hoặc .m3u8',
                            prefixIcon: Icons.play_circle_outline_rounded,
                            keyboardType: TextInputType.url,
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'URL Video là bắt buộc';
                              }
                              if (!val.startsWith('http://') &&
                                  !val.startsWith('https://')) {
                                return 'URL phải bắt đầu bằng http:// hoặc https://';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          AppTextField(
                            controller: _trailerUrlController,
                            label: 'URL Video Trailer (Tùy chọn)',
                            hintText: 'https://example.com/trailer.mp4',
                            prefixIcon: Icons.movie_creation_outlined,
                            keyboardType: TextInputType.url,
                          ),
                          const SizedBox(height: 14),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: AppTextField(
                                  controller: _posterUrlController,
                                  label: 'URL Ảnh Poster (Tỷ lệ 2:3)',
                                  hintText: 'https://example.com/poster.jpg',
                                  prefixIcon: Icons.image_outlined,
                                  keyboardType: TextInputType.url,
                                ),
                              ),
                              SizedBox(width: 12),
                              // KHUNG LIVE PREVIEW POSTER 2:3
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'Xem trước',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Container(
                                    width: 72,
                                    height: 108,
                                    decoration: BoxDecoration(
                                      color: AppColors.cardDark,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: Colors.white24),
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: _previewPosterUrl.isNotEmpty
                                        ? CachedNetworkImage(
                                            imageUrl: _previewPosterUrl,
                                            fit: BoxFit.cover,
                                            memCacheWidth: 200,
                                            memCacheHeight: 300,
                                            maxWidthDiskCache: 400,
                                            placeholder: (ctx, url) => Center(
                                              child: SizedBox(
                                                width: 18,
                                                height: 18,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                        Color
                                                      >(AppColors.red),
                                                ),
                                              ),
                                            ),
                                            errorWidget: (ctx, url, err) {
                                              return Center(
                                                child: Icon(
                                                  Icons.broken_image_outlined,
                                                  color: AppColors.textMuted,
                                                  size: 28,
                                                ),
                                              );
                                            },
                                          )
                                        : Center(
                                            child: Icon(
                                              Icons.image_outlined,
                                              color: AppColors.textMuted,
                                              size: 28,
                                            ),
                                          ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),

                      // KHỐI 4: CÀI ĐẶT TRẠNG THÁI PHIM
                      _buildSectionCard(
                        title: '4. Cài đặt Trạng thái & Vị trí',
                        icon: Icons.tune_rounded,
                        children: [
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            activeThumbColor: AppColors.red,
                            title: Text(
                              'Phim nổi bật (Hero Banner)',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              'Hiển thị phim trên banner lớn đầu trang chủ S09',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                            value: _isFeatured,
                            onChanged: (val) =>
                                setState(() => _isFeatured = val),
                          ),
                          Divider(color: Colors.white10),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            activeThumbColor: AppColors.red,
                            title: Text(
                              'Phim Mới & Hot',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              'Gắn nhãn mới và đưa vào tab Mới & Hot S16',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                            value: _isNew,
                            onChanged: (val) => setState(() => _isNew = val),
                          ),
                          Divider(color: Colors.white10),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            activeThumbColor: AppColors.red,
                            title: Text(
                              'Sắp chiếu (Coming Soon)',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              'Đánh dấu phim sắp phát hành, chưa mở xem ngay',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                            value: _comingSoon,
                            onChanged: (val) =>
                                setState(() => _comingSoon = val),
                          ),
                          const Divider(color: Colors.white10),
                          const SizedBox(height: 8),
                          AppTextField(
                            controller: _rankController,
                            label: 'Thứ tự Top 10 (Tùy chọn)',
                            hintText: 'Nhập số từ 1 đến 10 (để trống nếu không nằm Top 10)',
                            keyboardType: TextInputType.number,
                            prefixIcon: Icons.emoji_events_outlined,
                            validator: (val) {
                              if (val != null && val.trim().isNotEmpty) {
                                final n = int.tryParse(val.trim());
                                if (n == null || n < 1 || n > 10) {
                                  return 'Xếp hạng phải từ 1 đến 10';
                                }
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // THANH NÚT HÀNH ĐỘNG DƯỚI ĐÁY (STICKY ACTION BAR)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: Colors.white10)),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => context.pop(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.white24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        'Hủy bỏ',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: PrimaryButton(
                      text: _isEditing ? 'Lưu thay đổi' : 'Tạo phim mới',
                      isLoading: _isLoading,
                      onPressed: _handleSave,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
