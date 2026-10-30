import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/movie_model.dart';
import '../../presentation/widgets/glass/glass_components.dart';
import '../../services/auth_guard.dart';
import '../../services/pocketbase_service.dart';
import '../../services/theme_service.dart';
import '../../theme/app_theme.dart';
import '../../waves_background.dart';

class DownloadsScreen extends StatefulWidget {
  const DownloadsScreen({super.key});

  @override
  State<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen> {
  List<Movie> _downloadedMovies = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDownloaded();
  }

  Future<void> _loadDownloaded() async {
    final all = await PocketBaseService.instance.getMovies();
    if (mounted) {
      setState(() {
        // Lấy 3 phim làm mẫu nội dung đã tải xuống offline
        _downloadedMovies = all.take(3).toList();
        _isLoading = false;
      });
    }
  }

  void _removeDownload(String movieId) {
    setState(() {
      _downloadedMovies.removeWhere((m) => m.id == movieId);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã xóa phim khỏi bộ nhớ thiết bị'),
        backgroundColor: AppColors.surface,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _clearAll() {
    showGlassDialog(
      context: context,
      title: 'Xóa tất cả tải xuống?',
      content: Text(
        'Tất cả video ngoại tuyến và bộ nhớ đệm cache sẽ được giải phóng hoàn toàn.',
        style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
      ),
      actions: [
        GlassButton.neutral(
          text: 'Hủy',
          onPressed: () => Navigator.of(context).pop(),
        ),
        GlassButton.brand(
          text: 'Xóa tất cả',
          onPressed: () {
            Navigator.of(context).pop();
            setState(() {
              _downloadedMovies.clear();
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Đã giải phóng 1.4 GB bộ nhớ đệm'),
                backgroundColor: AppColors.surface,
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return WavesBackground.wrapIfBlue(Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: const GlassBackButton(fallbackRoute: '/me'),
        title: Text(
          'Tệp tải xuống & Bộ nhớ',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        actions: [
          if (_downloadedMovies.isNotEmpty)
            IconButton(
              icon: const Icon(
                Icons.delete_sweep_outlined,
                color: Colors.white70,
              ),
              tooltip: 'Xóa toàn bộ',
              onPressed: _clearAll,
            ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: ThemeService.instance.primaryColor,
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Khối thông tin bộ nhớ
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Bộ nhớ thiết bị',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Trống 38.4 GB',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 14,
                              child: Container(
                                height: 8,
                                color: ThemeService.instance.primaryColor,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Expanded(
                              flex: 36,
                              child: Container(
                                height: 8,
                                color: Colors.blueGrey,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Expanded(
                              flex: 50,
                              child: Container(
                                height: 8,
                                color: Colors.white12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 6,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: ThemeService.instance.primaryColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 6),
                              Text(
                                'OpenFlix (1.4 GB)',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Khác (24.2 GB)',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Colors.white24,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Còn trống',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'VIDEO ĐÃ TẢI XUỐNG',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: ThemeService.instance.primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      '${_downloadedMovies.length} mục',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_downloadedMovies.isEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        Icon(
                          Icons.file_download_off_outlined,
                          size: 56,
                          color: AppColors.textMuted.withValues(alpha: 0.6),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Chưa có video tải xuống',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Tải các bộ phim yêu thích để xem ngoại tuyến mọi lúc mọi nơi.',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        GlassButton.primary(
                          text: 'Tìm thêm phim để tải',
                          icon: Icons.download_rounded,
                          height: 44,
                          onPressed: () => context.go('/'),
                        ),
                      ],
                    ),
                  )
                else
                  ..._downloadedMovies.map((movie) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: InkWell(
                        onTap: () {
                          AuthGuard.runWithAuth(
                            context,
                            movieId: movie.id,
                            movieTitle: movie.title,
                            hasTrailer: true,
                            onWatchTrailer: () =>
                                context.push('/movie/${movie.id}/trailer'),
                            onAuthorized: () =>
                                context.push('/watch/${movie.id}'),
                          );
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width < 360
                                      ? 72
                                      : 96,
                                  height:
                                      MediaQuery.of(context).size.width < 360
                                      ? 46
                                      : 56,
                                  child: movie.thumbnailUrl.isNotEmpty
                                      ? CachedNetworkImage(
                                          imageUrl: movie.thumbnailUrl,
                                          fit: BoxFit.cover,
                                          memCacheWidth: 220,
                                          memCacheHeight: 130,
                                          maxHeightDiskCache: 250,
                                          errorWidget: (_, _, _) =>
                                              Container(color: Colors.white10),
                                        )
                                      : Container(color: Colors.white10),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      movie.title,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 4),
                                    Wrap(
                                      spacing: 6,
                                      children: [
                                        Text(
                                          '1080p FHD',
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 11,
                                          ),
                                        ),
                                        Text(
                                          '• 450 MB',
                                          style: TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              GlassIconButton.circle(
                                size: 34,
                                iconSize: 18,
                                icon: Icons.delete_outline_rounded,
                                tooltip: 'Xóa',
                                onPressed: () => _removeDownload(movie.id),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                const SizedBox(height: 24),
                // Tùy chọn cài đặt tải xuống nhanh
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.wifi, color: Colors.white70),
                  title: Text(
                    'Chỉ tải qua Wi-Fi',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 15,
                    ),
                  ),
                  trailing: Switch(
                    value: true,
                    activeThumbColor: ThemeService.instance.primaryColor,
                    onChanged: (val) {},
                  ),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.high_quality_outlined,
                    color: Colors.white70,
                  ),
                  title: Text(
                    'Chất lượng video tải xuống',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 15,
                    ),
                  ),
                  subtitle: Text(
                    'Tiêu chuẩn (1080p)',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: AppColors.textMuted,
                  ),
                  onTap: () => context.push('/settings/playback'),
                ),
              ],
            ),
    ));
  }
}
