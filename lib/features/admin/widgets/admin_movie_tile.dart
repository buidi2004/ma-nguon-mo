import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../models/movie_model.dart';
import '../../../theme/app_theme.dart';

/// Thẻ hiển thị phim dùng trong danh sách Quản trị (Admin)
/// Tuân thủ chuẩn Netflix-inspired và AGENTS.md
class AdminMovieTile extends StatelessWidget {
  final MovieModel movie;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final ValueChanged<bool>? onToggleFeatured;
  final ValueChanged<bool>? onToggleNew;
  final ValueChanged<bool>? onToggleComingSoon;
  final VoidCallback? onTap;
  final bool showOnlyActiveBadges;

  const AdminMovieTile({
    super.key,
    required this.movie,
    this.onEdit,
    this.onDelete,
    this.onToggleFeatured,
    this.onToggleNew,
    this.onToggleComingSoon,
    this.onTap,
    this.showOnlyActiveBadges = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.divider, width: 0.8),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPoster(),
                    const SizedBox(width: 12),
                    Expanded(child: _buildMiddleInfo()),
                    const SizedBox(width: 8),
                    _buildActionButtons(),
                  ],
                ),
                const SizedBox(height: 10),
                _buildQuickSwitchRow(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Cột trái: Poster 2:3 (60x90 dp), bo góc 6px, có placeholder và fallback
  Widget _buildPoster() {
    final hasValidUrl =
        movie.posterUrl.trim().isNotEmpty &&
        (movie.posterUrl.startsWith('http://') ||
            movie.posterUrl.startsWith('https://'));

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 60,
        height: 90,
        color: AppColors.surfaceLight,
        child: hasValidUrl
            ? CachedNetworkImage(
                imageUrl: movie.posterUrl,
                width: 60,
                height: 90,
                fit: BoxFit.cover,
                memCacheWidth: 120,
                memCacheHeight: 180,
                placeholder: (context, url) => Container(
                  color: AppColors.surfaceLight,
                  child: const Center(
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.red,
                        ),
                      ),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => _buildFallbackPoster(),
              )
            : _buildFallbackPoster(),
      ),
    );
  }

  Widget _buildFallbackPoster() {
    return Container(
      width: 60,
      height: 90,
      color: AppColors.surfaceLight,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.movie_outlined, color: AppColors.textMuted, size: 26),
            SizedBox(height: 2),
            Text(
              'Không có ảnh',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Cột giữa: Tiêu đề (tối đa 2 dòng), thông tin phụ và 3 status badges
  Widget _buildMiddleInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          movie.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.bold,
            height: 1.25,
          ),
        ),
        SizedBox(height: 4),
        Text(
          _buildSubtitleText(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: [
            if (!showOnlyActiveBadges || movie.isFeatured)
              _buildStatusBadge(
                label: '⭐ Nổi bật',
                isActive: movie.isFeatured,
                activeColor: AppColors.warning,
              ),
            if (!showOnlyActiveBadges || movie.isNew)
              _buildStatusBadge(
                label: '🔥 Mới',
                isActive: movie.isNew,
                activeColor: AppColors.red,
              ),
            if (!showOnlyActiveBadges || movie.comingSoon)
              _buildStatusBadge(
                label: '⏳ Sắp chiếu',
                isActive: movie.comingSoon,
                activeColor: AppColors.info,
              ),
          ],
        ),
      ],
    );
  }

  String _buildSubtitleText() {
    final parts = <String>[];
    if (movie.releaseYear > 0) {
      parts.add('${movie.releaseYear}');
    }
    if (movie.durationMinutes > 0) {
      parts.add('${movie.durationMinutes} phút');
    }
    if (movie.category.trim().isNotEmpty) {
      parts.add(movie.category.trim());
    }
    return parts.isEmpty ? 'Chưa có thông tin' : parts.join(' • ');
  }

  Widget _buildStatusBadge({
    required String label,
    required bool isActive,
    required Color activeColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isActive
            ? activeColor.withValues(alpha: 0.18)
            : AppColors.surfaceLight.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isActive
              ? activeColor.withValues(alpha: 0.5)
              : AppColors.surfaceLight,
          width: 0.8,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? activeColor : AppColors.textMuted,
          fontSize: 11,
          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  /// Cột phải: Nút Sửa và Nút Xóa
  Widget _buildActionButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            Icons.edit_outlined,
            color: AppColors.textSecondary,
            size: 20,
          ),
          onPressed: onEdit,
          tooltip: 'Sửa phim',
          constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          padding: EdgeInsets.zero,
        ),
        IconButton(
          icon: const Icon(
            Icons.delete_outline_rounded,
            color: AppColors.red,
            size: 20,
          ),
          onPressed: onDelete,
          tooltip: 'Xóa phim',
          constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          padding: EdgeInsets.zero,
        ),
      ],
    );
  }

  /// Hàng công tắc nhanh (Quick Switch Toggles)
  Widget _buildQuickSwitchRow() {
    return Container(
      padding: EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.divider, width: 0.8)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildQuickToggle(
            label: 'Nổi bật',
            value: movie.isFeatured,
            activeColor: AppColors.warning,
            onChanged: onToggleFeatured,
          ),
          _buildQuickToggle(
            label: 'Mới',
            value: movie.isNew,
            activeColor: AppColors.red,
            onChanged: onToggleNew,
          ),
          _buildQuickToggle(
            label: 'Sắp chiếu',
            value: movie.comingSoon,
            activeColor: AppColors.info,
            onChanged: onToggleComingSoon,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickToggle({
    required String label,
    required bool value,
    required Color activeColor,
    required ValueChanged<bool>? onChanged,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onChanged != null ? () => onChanged(!value) : null,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: value
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: value ? FontWeight.w600 : FontWeight.normal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 2),
              Transform.scale(
                scale: 0.7,
                child: SizedBox(
                  height: 24,
                  width: 36,
                  child: Switch(
                    value: value,
                    onChanged: onChanged,
                    activeTrackColor: activeColor,
                    activeThumbColor: AppColors.textPrimary,
                    inactiveTrackColor: AppColors.surfaceLight,
                    inactiveThumbColor: AppColors.textMuted,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
