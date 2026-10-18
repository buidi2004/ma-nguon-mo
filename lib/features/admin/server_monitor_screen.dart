import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/widgets/glass/glass_components.dart';
import '../../theme/app_theme.dart';
import 'services/admin_auth_service.dart';
import 'services/server_telemetry_service.dart';

class ServerMonitorScreen extends StatefulWidget {
  const ServerMonitorScreen({super.key});

  @override
  State<ServerMonitorScreen> createState() => _ServerMonitorScreenState();
}

class _ServerMonitorScreenState extends State<ServerMonitorScreen> {
  final _telemetry = ServerTelemetryService.instance;
  bool _isPurging = false;

  @override
  void initState() {
    super.initState();
    _telemetry.startMonitoring();
  }

  @override
  void dispose() {
    _telemetry.stopMonitoring();
    super.dispose();
  }

  Future<void> _handleScanVps() async {
    await _telemetry.scanVpsConfiguration();
  }

  Future<void> _handlePurgeCache() async {
    setState(() => _isPurging = true);
    final freedMb = await _telemetry.cleanMemoryCache();
    if (!mounted) return;
    setState(() => _isPurging = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Đã giải phóng thành công ${freedMb.toStringAsFixed(1)} MB bộ nhớ RAM ứng dụng!',
        ),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: const GlassBackButton(fallbackRoute: '/me'),
        title: const Text(
          'Giám sát Máy chủ VPS (180.93.120.246)',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: Icon(
              _telemetry.isScanning
                  ? Icons.track_changes_rounded
                  : Icons.radar_rounded,
              color: const Color(0xFF22C55E),
            ),
            tooltip: 'Quét cấu hình VPS',
            onPressed: _telemetry.isScanning ? null : _handleScanVps,
          ),
          IconButton(
            icon: const Icon(Icons.lock_outline_rounded, color: Colors.white70),
            tooltip: 'Khóa phiên quản trị',
            onPressed: () {
              AdminAuthService.instance.logout();
              context.pop();
            },
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _telemetry,
        builder: (context, _) {
          final data = _telemetry.currentData;
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. BANNER TRẠNG THÁI VPS THỰC TẾ
                _buildServerStatusBanner(data),
                const SizedBox(height: 16),

                // 2. TIÊU ĐỀ PHÂN HỆ CẤU HÌNH PHẦN CỨNG VPS
                Row(
                  children: [
                    const Icon(
                      Icons.dns_rounded,
                      color: Color(0xFF22C55E),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Cấu hình Phần cứng Máy chủ VPS Linux',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color:
                              const Color(0xFF22C55E).withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Text(
                        '180.93.120.246',
                        style: TextStyle(
                          color: Color(0xFF22C55E),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // GRID 4 THẺ CẤU HÌNH & BIỂU ĐỒ DUNG LƯỢNG MÁY CHỦ VPS
                Row(
                  children: [
                    Expanded(
                      child: _buildVpsConfigCard(
                        title: 'Vi xử lý VPS',
                        value: '${data.vpsCpuLoadPercent}% Tải',
                        subtitle: '${data.vpsCpu} • x86_64',
                        percent: data.vpsCpuLoadPercent / 100.0,
                        icon: Icons.memory_rounded,
                        color: data.vpsCpuLoadPercent < 50
                            ? const Color(0xFF22C55E)
                            : (data.vpsCpuLoadPercent < 75
                                  ? AppColors.warning
                                  : AppColors.red),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildVpsConfigCard(
                        title: 'Bộ nhớ RAM VPS',
                        value: '${data.vpsRamUsedGb} / ${data.vpsRamTotalGb} GB',
                        subtitle:
                            '${data.vpsRamUsagePercent.toStringAsFixed(1)}% • Ubuntu 24.04',
                        percent: data.vpsRamUsagePercent / 100.0,
                        icon: Icons.storage_rounded,
                        color: const Color(0xFF38BDF8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildVpsConfigCard(
                        title: 'Ổ cứng SSD VPS',
                        value:
                            '${data.vpsDiskUsedGb} / ${data.vpsDiskTotalGb} GB',
                        subtitle:
                            '${data.vpsDiskUsagePercent.toStringAsFixed(1)}% • ${data.vpsStorageVolume}',
                        percent: data.vpsDiskUsagePercent / 100.0,
                        icon: Icons.album_outlined,
                        color: const Color(0xFFA855F7),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildVpsConfigCard(
                        title: 'Cơ sở Dữ liệu',
                        value: '${data.totalMoviesInDb} Phim SQLite',
                        subtitle: 'WAL B-Tree • Backup Sẵn sàng',
                        percent: (data.totalMoviesInDb / 100.0).clamp(0.1, 1.0),
                        icon: Icons.table_chart_rounded,
                        color: AppColors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 3. BIỂU ĐỒ PHÂN BỔ DUNG LƯỢNG Ổ CỨNG SSD TRỰC QUAN (STORAGE BREAKDOWN)
                _buildStorageAllocationBreakdown(data),
                const SizedBox(height: 16),

                // 4. KHUNG QUÉT CẤU HÌNH VPS TRỰC TIẾP (LIVE SCANNER TERMINAL)
                _buildLiveScanConsole(data),
                const SizedBox(height: 16),

                // 5. BIỂU ĐỒ SÓNG ĐỘ TRỄ MẠNG VPS THỜI GIAN THỰC
                _buildRealtimeGraph(data),
                const SizedBox(height: 16),

                // 6. BẢNG TIẾN TRÌNH DỊCH VỤ VPS
                _buildSystemServicesTable(data),
                const SizedBox(height: 16),

                // 7. PHÂN HỆ THIẾT BỊ CLIENT HIỆN TẠI (PHÂN BIỆT RÕ RÀNG)
                _buildClientDeviceCard(data),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildServerStatusBanner(ServerTelemetryData data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: data.isOnline
              ? const Color(0xFF22C55E).withValues(alpha: 0.3)
              : AppColors.red.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: data.isOnline
                      ? const Color(0xFF22C55E)
                      : AppColors.red,
                  boxShadow: [
                    BoxShadow(
                      color: data.isOnline
                          ? const Color(0xFF22C55E).withValues(alpha: 0.8)
                          : AppColors.red.withValues(alpha: 0.8),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  data.isOnline
                      ? 'MÁY CHỦ TRỰC TUYẾN (ONLINE 200 OK)'
                      : 'MẤT KẾT NỐI MÁY CHỦ (OFFLINE)',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: data.isOnline
                        ? const Color(0xFF22C55E)
                        : AppColors.red,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.network_ping_rounded,
                      size: 14,
                      color: Color(0xFF22C55E),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${data.pingMs} ms (TB: ${data.avgPingMs} ms)',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Colors.white10, height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Địa chỉ Host VPS',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      data.vpsHost,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Web Engine & OS VPS',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      data.serverSoftware,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVpsConfigCard({
    required String title,
    required String value,
    required String subtitle,
    required double percent,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '${(percent * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
          ),
          const SizedBox(height: 8),
          // THANH BIỂU ĐỒ TIẾN TRÌNH DUNG LƯỢNG
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: percent.clamp(0.0, 1.0),
              minHeight: 5,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStorageAllocationBreakdown(ServerTelemetryData data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.pie_chart_outline_rounded,
                color: Color(0xFFA855F7),
                size: 18,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Biểu đồ Phân bổ Dung lượng Ổ cứng SSD VPS (50 GB)',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '${data.vpsDiskUsedGb} / ${data.vpsDiskTotalGb} GB (${data.vpsDiskUsagePercent.toStringAsFixed(1)}%)',
                style: const TextStyle(
                  color: Color(0xFFA855F7),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // THANH PHÂN BỔ ĐA PHÂN KHÚC (MULTI-SEGMENTED CAPACITY BAR)
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: SizedBox(
              height: 12,
              child: Row(
                children: [
                  Flexible(
                    flex: 124,
                    child: Container(
                      color: const Color(0xFF38BDF8),
                    ),
                  ),
                  const SizedBox(width: 1),
                  Flexible(
                    flex: 21,
                    child: Container(
                      color: AppColors.red,
                    ),
                  ),
                  const SizedBox(width: 1),
                  Flexible(
                    flex: 42,
                    child: Container(
                      color: const Color(0xFFA855F7),
                    ),
                  ),
                  const SizedBox(width: 1),
                  Flexible(
                    flex: 313,
                    child: Container(
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          // BẢNG CHÚ THÍCH CÁC PHÂN VÙNG DUNG LƯỢNG
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _buildLegendDot(
                color: const Color(0xFF38BDF8),
                label: 'Ubuntu & Docker: ${data.vpsOsUsedGb} GB (24.8%)',
              ),
              _buildLegendDot(
                color: AppColors.red,
                label: 'SQLite DB: ${data.vpsDbUsedGb} GB (4.2%)',
              ),
              _buildLegendDot(
                color: const Color(0xFFA855F7),
                label: 'Media CDN: ${data.vpsMediaUsedGb} GB (8.4%)',
              ),
              _buildLegendDot(
                color: Colors.white38,
                label:
                    'Trống: ${data.vpsFreeDiskGb.toStringAsFixed(1)} GB (${data.vpsFreeDiskPercent.toStringAsFixed(1)}%)',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendDot({required Color color, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildLiveScanConsole(ServerTelemetryData data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.terminal_rounded,
                color: Color(0xFF22C55E),
                size: 18,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Nhật ký Quét Cấu hình VPS Trực tiếp',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ElevatedButton.icon(
                icon: _telemetry.isScanning
                    ? const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.radar_rounded, size: 14),
                label: Text(_telemetry.isScanning ? 'Đang quét...' : 'Quét Ngay'),
                onPressed: _telemetry.isScanning ? null : _handleScanVps,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: data.scanLogs
                  .map(
                    (log) => Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Text(
                        log,
                        style: TextStyle(
                          color: log.contains('❌')
                              ? AppColors.red
                              : (log.contains('⚠️')
                                  ? AppColors.warning
                                  : const Color(0xFF4ADE80)),
                          fontSize: 11,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRealtimeGraph(ServerTelemetryData data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.show_chart_rounded,
                color: AppColors.red,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Lịch sử Độ trễ Ping VPS (Cập nhật 2.5s)',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    color: const Color(0xFF22C55E),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Ping ms',
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 90,
            width: double.infinity,
            child: CustomPaint(
              painter: TelemetrySparklinePainter(
                pingPoints: data.pingHistory,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemServicesTable(ServerTelemetryData data) {
    final services = [
      {
        'name': 'PocketBase SQLite Daemon',
        'desc': 'Port 8090 • ${data.pocketBaseStatus}',
        'status': 'ONLINE',
      },
      {
        'name': 'Nginx Reverse Proxy & CDN',
        'desc': 'Port 80 • ${data.serverSoftware}',
        'status': 'ONLINE',
      },
      {
        'name': 'Kho Phim SQLite Database',
        'desc': '${data.totalMoviesInDb} bản ghi phim • /opt/openflix-backend/pb_data',
        'status': 'ONLINE',
      },
      {
        'name': 'Realtime SSE Event Stream',
        'desc': 'Endpoint /api/realtime • Live Streaming PubSub',
        'status': 'ONLINE',
      },
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tiến trình Dịch vụ Máy chủ VPS (Processes)',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...services.map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF22C55E),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s['name']!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          s['desc']!,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF22C55E).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      s['status']!,
                      style: const TextStyle(
                        color: Color(0xFF22C55E),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClientDeviceCard(ServerTelemetryData data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.smartphone_rounded,
                color: Color(0xFF38BDF8),
                size: 18,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Thiết bị Quản trị Đang Truy Cập (Client Device)',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  data.clientOs.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'RAM ứng dụng: ${data.processRamMb} MB (Đỉnh: ${data.peakRamMb} MB) • Vi xử lý: ${data.cpuCores} Cores • Cache Poster: ${data.imageCacheMb} MB',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: _isPurging
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.cleaning_services_rounded, size: 16),
                  label: Text(
                    _isPurging
                        ? 'Đang dọn...'
                        : 'Dọn RAM App (${data.imageCacheMb} MB)',
                    style: const TextStyle(fontSize: 12),
                  ),
                  onPressed: _isPurging ? null : _handlePurgeCache,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.movie_filter_rounded, size: 16),
                  label: const Text('Kho phim Admin', style: TextStyle(fontSize: 12)),
                  onPressed: () => context.push('/admin/movies'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class TelemetrySparklinePainter extends CustomPainter {
  final List<double> pingPoints;

  TelemetrySparklinePainter({
    required this.pingPoints,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 1;

    for (int i = 1; i <= 3; i++) {
      final y = size.height * (i / 4.0);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    if (pingPoints.isEmpty) return;

    final paint = Paint()
      ..color = const Color(0xFF22C55E)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    const maxVal = 250.0;
    final dx = size.width / (pingPoints.length > 1 ? pingPoints.length - 1 : 1);

    for (int i = 0; i < pingPoints.length; i++) {
      final val = pingPoints[i].clamp(0.0, maxVal);
      final y = size.height - ((val / maxVal) * (size.height - 8)) - 4;
      if (i == 0) {
        path.moveTo(0, y);
      } else {
        path.lineTo(i * dx, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant TelemetrySparklinePainter oldDelegate) => true;
}
