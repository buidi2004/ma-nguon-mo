import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/widgets/glass/glass_components.dart';
import '../../theme/app_theme.dart';
import 'services/admin_auth_service.dart';
import 'services/server_telemetry_service.dart';
import '../../waves_background.dart';

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

    // Chỉ báo số thật: nếu không giải phóng được gì thì nói đúng như vậy.
    final hadMemory = freedMb > 0;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          hadMemory
              ? 'Đã giải phóng ${freedMb.toStringAsFixed(1)} MB bộ nhớ đệm ảnh.'
              : 'Không có bộ nhớ đệm ảnh nào cần giải phóng.',
        ),
        backgroundColor: hadMemory ? AppColors.success : AppColors.textMuted,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WavesBackground.wrapIfBlue(Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: const GlassBackButton(fallbackRoute: '/me'),
        // Tiêu đề lấy host THẬT từ backend đang cấu hình, không hardcode IP.
        title: ListenableBuilder(
          listenable: _telemetry,
          builder: (context, _) => Text(
            'Giám sát Máy chủ VPS (${_telemetry.currentData.vpsHost})',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
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
          final cpuLoad = data.vpsCpuLoadPercent;
          final ramUsed = data.vpsRamUsedGb;
          final diskUsed = data.vpsDiskUsedGb;
          final ramPercent = data.vpsRamUsagePercent;
          final diskPercent = data.vpsDiskUsagePercent;
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
                        'Cấu hình Phần cứng (theo gói VPS đã thuê)',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
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
                          color: const Color(0xFF22C55E).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        data.vpsHost,
                        key: const ValueKey('vps-host-badge'),
                        style: const TextStyle(
                          color: Color(0xFF22C55E),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // GRID 4 THẺ: CẤU HÌNH TĨNH CỦA GÓI VPS + SỐ ĐO (NẾU CÓ)
                Row(
                  children: [
                    Expanded(
                      child: _buildVpsConfigCard(
                        title: 'Vi xử lý VPS',
                        value: cpuLoad == null
                            ? data.vpsCpu
                            : '${cpuLoad.toStringAsFixed(1)}% Tải',
                        subtitle: cpuLoad == null
                            ? '${data.vpsCpu} • Tải CPU: chưa đo được'
                            : '${data.vpsCpu}'
                                  '${data.vpsArchitecture == null ? '' : ' • ${data.vpsArchitecture}'}',
                        percent: cpuLoad == null ? null : cpuLoad / 100.0,
                        icon: Icons.memory_rounded,
                        color: cpuLoad == null
                            ? AppColors.textMuted
                            : (cpuLoad < 50
                                  ? const Color(0xFF22C55E)
                                  : (cpuLoad < 75
                                        ? AppColors.warning
                                        : AppColors.red)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildVpsConfigCard(
                        title: 'Bộ nhớ RAM VPS',
                        value: ramUsed == null
                            ? '${formatGb(data.vpsRamTotalGb)} GB'
                            : '${formatGb(ramUsed)} / '
                                  '${formatGb(data.vpsRamTotalGb)} GB',
                        subtitle: ramUsed == null
                            ? 'Tổng RAM • Mức dùng: chưa đo được'
                            : '${ramPercent!.toStringAsFixed(1)}% • '
                                  '${data.vpsOs}',
                        percent: ramPercent == null ? null : ramPercent / 100.0,
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
                        value: diskUsed == null
                            ? '${formatGb(data.vpsDiskTotalGb)} GB'
                            : '${formatGb(diskUsed)} / '
                                  '${formatGb(data.vpsDiskTotalGb)} GB',
                        subtitle: diskUsed == null
                            ? 'Tổng SSD • Mức dùng: chưa đo được'
                            : '${diskPercent!.toStringAsFixed(1)}% đã dùng',
                        percent: diskPercent == null
                            ? null
                            : diskPercent / 100.0,
                        icon: Icons.album_outlined,
                        color: const Color(0xFFA855F7),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildVpsConfigCard(
                        title: 'Cơ sở Dữ liệu',
                        value: '${data.totalMoviesInDb} bản ghi',
                        subtitle: data.vpsDbUsedGb == null
                            ? 'Dung lượng DB: chưa đo được'
                            : 'Dung lượng DB: '
                                  '${formatGb(data.vpsDbUsedGb!)} GB',
                        percent: null,
                        icon: Icons.table_chart_rounded,
                        color: AppColors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // NGUỒN SỐ LIỆU: phân biệt cấu hình tĩnh vs số đo trực tiếp.
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        data.metricsLive
                            ? Icons.sensors_rounded
                            : Icons.info_outline_rounded,
                        size: 16,
                        color: data.metricsLive
                            ? Color(0xFF22C55E)
                            : AppColors.textMuted,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          data.metricsLive
                              ? 'Số liệu đo trực tiếp từ '
                                    '${_telemetry.metricsUri}'
                                    '${data.metricsGeneratedAt == null ? '' : ' • cập nhật ${data.metricsGeneratedAt}'}'
                              : '${data.vpsPlan}\n'
                                    '${data.metricsError ?? kMetricsUnavailableNote}',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 3. BIỂU ĐỒ PHÂN BỔ DUNG LƯỢNG Ổ CỨNG SSD TRỰC QUAN (STORAGE BREAKDOWN)
                _buildStorageAllocationBreakdown(data),
                const SizedBox(height: 16),

                // 3b. THÔNG SỐ VẬN HÀNH (uptime, load, kernel, phiên bản)
                _buildRuntimeInfoCard(data),
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
    ));
  }

  Widget _buildServerStatusBanner(ServerTelemetryData data) {
    // Ba trạng thái: chưa kiểm tra / trực tuyến / mất kết nối.
    final bool isChecking = !data.hasProbed;
    final bool isOnline = data.isOnline;
    final Color accent = isChecking
        ? AppColors.textMuted
        : (isOnline ? const Color(0xFF22C55E) : AppColors.red);
    final String title = isChecking
        ? 'ĐANG KIỂM TRA KẾT NỐI MÁY CHỦ…'
        : (isOnline
              ? 'MÁY CHỦ TRỰC TUYẾN (HTTP 200 OK)'
              : 'MẤT KẾT NỐI MÁY CHỦ (OFFLINE)');
    final String pingLabel = isChecking
        ? 'Đang đo…'
        : (isOnline
              ? '${data.pingMs} ms (TB: ${data.avgPingMs ?? data.pingMs} ms)'
              : 'Không phản hồi');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accent.withValues(alpha: 0.3)),
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
                  color: accent,
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.8),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: accent,
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
                    Icon(Icons.network_ping_rounded, size: 14, color: accent),
                    const SizedBox(width: 4),
                    Text(
                      pingLabel,
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
          SizedBox(height: 12),
          Divider(color: Colors.white10, height: 1),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Địa chỉ Host VPS',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      data.vpsHost,
                      style: TextStyle(
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
                    Text(
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
    required double? percent,
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
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                percent == null
                    ? '—'
                    : '${(percent * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  color: percent == null ? AppColors.textMuted : color,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
          SizedBox(height: 4),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: AppColors.textMuted, fontSize: 11),
          ),
          const SizedBox(height: 8),
          // THANH BIỂU ĐỒ TIẾN TRÌNH (để trống khi chưa có số đo)
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: percent == null ? 0.0 : percent.clamp(0.0, 1.0),
              minHeight: 5,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(
                percent == null ? Colors.white24 : color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStorageAllocationBreakdown(ServerTelemetryData data) {
    final diskUsed = data.vpsDiskUsedGb;
    final totalGb = data.vpsDiskTotalGb;

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
              Expanded(
                child: Text(
                  'Phân bổ Dung lượng Ổ cứng SSD VPS '
                  '(${formatGb(totalGb)} GB)',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                diskUsed == null
                    ? 'Chưa đo được'
                    : '${formatGb(diskUsed)} / '
                          '${formatGb(totalGb)} GB '
                          '(${data.vpsDiskUsagePercent!.toStringAsFixed(1)}%)',
                style: TextStyle(
                  color: Color(0xFFA855F7),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          if (diskUsed == null)
            // Không có số đo → không vẽ biểu đồ bằng số bịa.
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: AppColors.textMuted,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Chưa có dữ liệu dung lượng ổ cứng để vẽ biểu đồ. '
                    '$kMetricsUnavailableNote',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            )
          else
            ..._buildStorageSegments(data, diskUsed, totalGb),
        ],
      ),
    );
  }

  /// Thanh phân bổ + chú thích: **chỉ vẽ những phần đã đo được**.
  ///
  /// Khi agent chưa trả về chi tiết (Ubuntu/DB/Media) thì chỉ hiển thị
  /// "Đã dùng / Trống" kèm ghi chú — tuyệt đối không vẽ `0.00 GB` cho phần
  /// chưa đo, vì đó là số bịa.
  List<Widget> _buildStorageSegments(
    ServerTelemetryData data,
    double diskUsedGb,
    double totalGb,
  ) {
    final osGb = data.vpsOsUsedGb;
    final dbGb = data.vpsDbUsedGb;
    final mediaGb = data.vpsMediaUsedGb;
    final hasBreakdown = osGb != null && dbGb != null && mediaGb != null;

    final freeGb = (totalGb - diskUsedGb).clamp(0.0, totalGb);
    final measuredSum = (osGb ?? 0) + (dbGb ?? 0) + (mediaGb ?? 0);
    // Phần đã dùng nhưng chưa phân loại được (log, docker layer, file khác…).
    final otherGb = hasBreakdown
        ? (diskUsedGb - measuredSum).clamp(0.0, diskUsedGb)
        : 0.0;

    int flexOf(double gb) => (gb * 100).round().clamp(0, 1 << 20);
    String percentOf(double gb) =>
        totalGb <= 0 ? '0.0%' : '${(gb / totalGb * 100).toStringAsFixed(1)}%';

    final bars = <Widget>[];
    void addBar(Color color, double gb) {
      if (gb <= 0) return;
      if (bars.isNotEmpty) bars.add(const SizedBox(width: 1));
      bars.add(
        Flexible(
          flex: flexOf(gb),
          child: Container(color: color),
        ),
      );
    }

    const colorOs = Color(0xFF38BDF8);
    const colorMedia = Color(0xFFA855F7);
    const colorFree = Color(0x1FFFFFFF); // trắng 12%

    if (hasBreakdown) {
      addBar(colorOs, osGb);
      addBar(AppColors.red, dbGb);
      addBar(colorMedia, mediaGb);
      addBar(AppColors.warning, otherGb);
    } else {
      // Không có chi tiết → chỉ vẽ đúng 2 phần đo được.
      addBar(AppColors.red, diskUsedGb);
    }
    addBar(colorFree, freeGb);

    final legends = <Widget>[
      if (hasBreakdown) ...[
        _buildLegendDot(
          color: colorOs,
          label: 'Ubuntu & Docker: ${formatGb(osGb)} GB (${percentOf(osGb)})',
        ),
        _buildLegendDot(
          color: AppColors.red,
          label: 'SQLite DB: ${formatGb(dbGb)} GB (${percentOf(dbGb)})',
        ),
        _buildLegendDot(
          color: colorMedia,
          label: 'Media CDN: ${formatGb(mediaGb)} GB (${percentOf(mediaGb)})',
        ),
        if (otherGb > 0)
          _buildLegendDot(
            color: AppColors.warning,
            label:
                'Khác (chưa phân loại): ${formatGb(otherGb)} GB '
                '(${percentOf(otherGb)})',
          ),
      ] else
        _buildLegendDot(
          color: AppColors.red,
          label:
              'Đã dùng: ${formatGb(diskUsedGb)} GB '
              '(${percentOf(diskUsedGb)})',
        ),
      _buildLegendDot(
        color: Colors.white38,
        label: 'Trống: ${formatGb(freeGb)} GB (${percentOf(freeGb)})',
      ),
    ];

    final dataDir = data.vpsStorageVolume;

    return [
      ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: SizedBox(height: 12, child: Row(children: bars)),
      ),
      SizedBox(height: 14),
      Wrap(spacing: 16, runSpacing: 8, children: legends),
      if (!hasBreakdown) ...[
        SizedBox(height: 10),
        Text(
          'Máy chủ chưa trả về chi tiết phân bổ (Ubuntu/DB/Media), nên chỉ '
          'hiển thị phần đã dùng thật và phần trống.',
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 11,
            height: 1.4,
          ),
        ),
      ],
      if (dataDir != null) ...[
        SizedBox(height: 10),
        Text(
          'Thư mục dữ liệu PocketBase (agent xác nhận): $dataDir',
          style: TextStyle(color: AppColors.textMuted, fontSize: 11),
        ),
      ],
    ];
  }

  /// Thông số vận hành thật (uptime, load, kernel, phiên bản) từ /metrics.
  Widget _buildRuntimeInfoCard(ServerTelemetryData data) {
    final rows = <List<String>>[
      ['Uptime máy chủ', data.uptimeLabel ?? '—'],
      [
        'Load average (1 phút)',
        data.load1 == null ? '—' : data.load1!.toStringAsFixed(2),
      ],
      ['Kernel Linux', data.kernelVersion ?? '—'],
      [
        'Docker Engine',
        data.dockerVersion == null ? '—' : 'v${data.dockerVersion}',
      ],
      [
        'PocketBase',
        data.pocketBaseVersion == null ? '—' : 'v${data.pocketBaseVersion}',
      ],
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
          Row(
            children: [
              const Icon(
                Icons.speed_rounded,
                color: Color(0xFF38BDF8),
                size: 18,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Thông số Vận hành Máy chủ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          ...rows.map(
            (row) => Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      row[0],
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Text(
                    row[1],
                    style: TextStyle(
                      color: row[1] == '—' ? AppColors.textMuted : Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
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

  Widget _buildLegendDot({required Color color, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
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
                label: Text(
                  _telemetry.isScanning ? 'Đang quét...' : 'Quét Ngay',
                ),
                onPressed: _telemetry.isScanning ? null : _handleScanVps,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
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
                    fontSize: 15,
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
          SizedBox(height: 16),
          if (data.pingHistory.isEmpty)
            Container(
              height: 90,
              width: double.infinity,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.white10),
              ),
              child: Text(
                'Chưa có mẫu đo độ trễ nào.',
                style: TextStyle(color: AppColors.textMuted, fontSize: 11),
              ),
            )
          else
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
    // Trạng thái lấy từ kết quả probe thật; null = chưa từng kiểm tra.
    final services = <List<String>>[
      [
        'PocketBase (port 8090)',
        data.pocketBaseStatus,
        _statusLabel(data.pocketBaseReachable ?? data.metricsPocketBaseUp),
      ],
      [
        'Media CDN / Nginx (port 80)',
        'HTTP HEAD /posters • ${data.serverSoftware}',
        _statusLabel(data.cdnReachable ?? data.metricsNginxUp),
      ],
      [
        'Kho phim (PocketBase SQLite)',
        data.vpsDbUsedGb == null
            ? '${data.totalMoviesInDb} bản ghi'
            : '${data.totalMoviesInDb} bản ghi • '
                  '${formatGb(data.vpsDbUsedGb!)} GB đã đo',
        _statusLabel(data.databaseReachable),
      ],
      [
        'Realtime SSE (/api/realtime)',
        'Chưa có probe cho endpoint này',
        _statusLabel(null),
      ],
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
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...services.map((s) {
            final color = _statusColor(s[2]);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Row(
                children: [
                  Icon(_statusIcon(s[2]), color: color, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s[0],
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          s[1],
                          style: TextStyle(
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
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      s[2],
                      style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  String _statusLabel(bool? reachable) =>
      reachable == null ? 'CHƯA RÕ' : (reachable ? 'ONLINE' : 'LỖI');

  Color _statusColor(String status) => switch (status) {
    'ONLINE' => const Color(0xFF22C55E),
    'LỖI' => AppColors.red,
    _ => AppColors.warning,
  };

  IconData _statusIcon(String status) => switch (status) {
    'ONLINE' => Icons.check_circle_rounded,
    'LỖI' => Icons.cancel_rounded,
    _ => Icons.help_outline_rounded,
  };

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
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            'RAM ứng dụng: ${data.processRamMb} MB (Đỉnh: ${data.peakRamMb} MB) • Vi xử lý: ${data.cpuCores} Cores • Cache Poster: ${data.imageCacheMb} MB',
            style: TextStyle(color: AppColors.textMuted, fontSize: 11),
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
                  label: const Text(
                    'Kho phim Admin',
                    style: TextStyle(fontSize: 12),
                  ),
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

  TelemetrySparklinePainter({required this.pingPoints});

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
