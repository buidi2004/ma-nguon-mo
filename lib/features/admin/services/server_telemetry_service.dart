import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:http/http.dart' as http;

import '../../../services/pocketbase_service.dart';
import 'hardware_reader.dart';
import 'server_metrics.dart';

/// Thông số **cấu hình tĩnh** của gói VPS đang thuê (CLOUDSH LOC).
///
/// Đây là dữ kiện của gói dịch vụ đã mua — KHÔNG phải số đo thời gian thực.
/// Mọi chỉ số đo lường (CPU %, RAM đã dùng, dung lượng đã dùng…) phải đến từ
/// endpoint `/metrics` của máy chủ; khi chưa có nguồn đó thì để `null`
/// (hiển thị "—"), tuyệt đối không điền số ước lượng.
class VpsPlanSpec {
  const VpsPlanSpec._();

  static const String provider = 'CLOUDSH LOC';
  static const String host = '180.93.120.246';
  static const int port = 8090;
  static const String apiBaseUrl = 'http://$host:$port';
  static const String hostLabel = '$host:$port';

  static const String os = 'Ubuntu Server 24.04 LTS';

  static const int cores = 1;
  static const String cpuLabel = '1 Core';

  static const double ramTotalGb = 2.0;
  static const String ramTotalLabel = '2 GB RAM';

  static const double diskTotalGb = 25.0;
  static const String diskTotalLabel = '25 GB SSD';

  static const String priceLabel = '59.000 ₫/tháng';
  static const String expiresOn = '07/11/2026';

  static const String summary =
      '$provider · $cpuLabel · $ramTotalLabel · $diskTotalLabel';
}

/// Giải thích hiển thị cho người quản trị khi chưa có nguồn số đo.
const String kMetricsUnavailableNote =
    'Máy chủ chưa cung cấp endpoint số liệu (/metrics), nên chưa thể đo '
    'CPU, RAM và dung lượng ổ cứng thực tế. Các chỉ số này hiển thị "—" '
    'thay vì số ước lượng.';

/// Định dạng dung lượng GB: 1 chữ số thập phân khi >= 1 GB, 2 chữ số khi nhỏ hơn.
String formatGb(double value) =>
    value >= 1 ? value.toStringAsFixed(1) : value.toStringAsFixed(2);

/// Dữ liệu cấu hình & đo lường máy chủ VPS.
///
/// Phân biệt rõ 3 nhóm:
/// 1. Cấu hình tĩnh của gói VPS ([VpsPlanSpec]) — luôn đúng, không đổi.
/// 2. Số đo thật từ mạng (ping, HTTP status, số bản ghi) — có/không tuỳ lần đo.
/// 3. Số đo tài nguyên máy chủ (CPU/RAM/disk) — `null` khi chưa có nguồn.
class ServerTelemetryData {
  // --- 1. CẤU HÌNH TĨNH CỦA GÓI VPS ---
  final String vpsHost; // Host:port THẬT của backend đang cấu hình trong app
  final String vpsOs;

  /// Kiến trúc CPU do máy chủ báo (`uname -m`); null = chưa đo được.
  final String? vpsArchitecture;
  final String vpsCpu;
  final int vpsCpuCores;
  final String vpsRamTotal;
  final double vpsRamTotalGb;
  final String vpsStorageTotal;
  final double vpsDiskTotalGb;
  final String vpsPlan;

  /// Thư mục dữ liệu PocketBase do agent xác nhận; null = chưa biết.
  final String? vpsStorageVolume;
  final String serverSoftware; // Header `Server` thật, hoặc 'Không xác định'
  final String pocketBaseStatus; // Chỉ nội dung xác minh được từ /api/health
  final String serverDate;

  // --- 2. SỐ ĐO TÀI NGUYÊN (null = CHƯA ĐO ĐƯỢC) ---
  final double? vpsCpuLoadPercent;
  final double? vpsRamUsedGb;
  final double? vpsDiskUsedGb;
  final double? vpsOsUsedGb;
  final double? vpsDbUsedGb;
  final double? vpsMediaUsedGb;

  // --- 2b. NGUỒN SỐ ĐO (/metrics) VÀ THÔNG SỐ VẬN HÀNH ---
  /// `true` khi lần đo gần nhất đọc được số liệu thật từ `/metrics`.
  final bool metricsLive;

  /// Lý do không có số liệu (null khi [metricsLive] là true).
  final String? metricsError;

  /// Thời điểm agent trên máy chủ ghi số liệu (ISO-8601 UTC).
  final String? metricsGeneratedAt;
  final double? load1;
  final int? uptimeSeconds;
  final String? kernelVersion;
  final String? dockerVersion;
  final String? pocketBaseVersion;
  final bool? metricsPocketBaseUp;
  final bool? metricsNginxUp;

  // --- 3. KẾT NỐI & ĐỘ TRỄ (đo thật) ---
  final bool isOnline;
  final bool hasProbed; // đã thực hiện lần đo nào chưa
  final bool? pocketBaseReachable;
  final bool? cdnReachable;
  final bool? databaseReachable;
  final int pingMs;
  final int? minPingMs;
  final int? maxPingMs;
  final int? avgPingMs;
  final int? jitterMs;
  final int totalMoviesInDb;
  final int lastPayloadBytes;
  final double? downloadSpeedKbps; // Tốc độ tải phản hồi API (kB/s)

  // --- 4. PHẦN CỨNG THIẾT BỊ CLIENT ĐANG TRUY CẬP ---
  final double processRamMb;
  final double peakRamMb;
  final double imageCacheMb;
  final int imageCacheCount;
  final int cpuCores;
  final String clientOs;
  final String osVersion;

  // --- 5. NHẬT KÝ & LỊCH SỬ ---
  final List<String> scanLogs;
  final List<double> pingHistory;
  final List<double> ramHistory;
  final DateTime timestamp;

  const ServerTelemetryData({
    required this.vpsHost,
    required this.vpsOs,
    required this.vpsArchitecture,
    required this.vpsCpu,
    required this.vpsCpuCores,
    required this.vpsRamTotal,
    required this.vpsRamTotalGb,
    required this.vpsStorageTotal,
    required this.vpsDiskTotalGb,
    required this.vpsPlan,
    required this.vpsStorageVolume,
    required this.serverSoftware,
    required this.pocketBaseStatus,
    required this.serverDate,
    required this.vpsCpuLoadPercent,
    required this.vpsRamUsedGb,
    required this.vpsDiskUsedGb,
    required this.vpsOsUsedGb,
    required this.vpsDbUsedGb,
    required this.vpsMediaUsedGb,
    required this.metricsLive,
    required this.metricsError,
    required this.metricsGeneratedAt,
    required this.load1,
    required this.uptimeSeconds,
    required this.kernelVersion,
    required this.dockerVersion,
    required this.pocketBaseVersion,
    required this.metricsPocketBaseUp,
    required this.metricsNginxUp,
    required this.isOnline,
    required this.hasProbed,
    required this.pocketBaseReachable,
    required this.cdnReachable,
    required this.databaseReachable,
    required this.pingMs,
    required this.minPingMs,
    required this.maxPingMs,
    required this.avgPingMs,
    required this.jitterMs,
    required this.totalMoviesInDb,
    required this.lastPayloadBytes,
    required this.downloadSpeedKbps,
    required this.processRamMb,
    required this.peakRamMb,
    required this.imageCacheMb,
    required this.imageCacheCount,
    required this.cpuCores,
    required this.clientOs,
    required this.osVersion,
    required this.scanLogs,
    required this.pingHistory,
    required this.ramHistory,
    required this.timestamp,
  });

  // --- Tỷ lệ phần trăm (null khi chưa đo được) ---
  double? get vpsRamUsagePercent =>
      vpsRamUsedGb == null ? null : (vpsRamUsedGb! / vpsRamTotalGb) * 100.0;

  double? get vpsDiskUsagePercent =>
      vpsDiskUsedGb == null ? null : (vpsDiskUsedGb! / vpsDiskTotalGb) * 100.0;

  double? get vpsFreeDiskGb =>
      vpsDiskUsedGb == null ? null : vpsDiskTotalGb - vpsDiskUsedGb!;

  double? get vpsFreeDiskPercent =>
      vpsFreeDiskGb == null ? null : (vpsFreeDiskGb! / vpsDiskTotalGb) * 100.0;

  /// Có ít nhất một chỉ số tài nguyên đo được từ máy chủ hay không.
  bool get hasMeasuredMetrics =>
      vpsCpuLoadPercent != null ||
      vpsRamUsedGb != null ||
      vpsDiskUsedGb != null;

  /// Dung lượng đã dùng của các phân vùng (nếu đã đo).
  double? get vpsPartitionsUsedGb {
    final parts = [
      vpsOsUsedGb,
      vpsDbUsedGb,
      vpsMediaUsedGb,
    ].whereType<double>().toList();
    if (parts.isEmpty) return null;
    return parts.fold<double>(0, (sum, v) => sum + v);
  }

  /// Uptime dạng người đọc được, null nếu chưa đo được.
  String? get uptimeLabel {
    final seconds = uptimeSeconds;
    if (seconds == null || seconds < 0) return null;
    final days = seconds ~/ 86400;
    final hours = (seconds % 86400) ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    if (days > 0) return '$days ngày $hours giờ';
    if (hours > 0) return '$hours giờ $minutes phút';
    return '$minutes phút';
  }

  // Getter tương thích ngược, giữ đúng ngữ nghĩa nullable.
  double? get cpuUsagePercent => vpsCpuLoadPercent;
  double? get ramUsedGb => vpsRamUsedGb;
  double get ramTotalGb => vpsRamTotalGb;
  double? get diskUsedGb => vpsDiskUsedGb;
  double get diskTotalGb => vpsDiskTotalGb;
  double? get ramUsagePercent => vpsRamUsagePercent;
  double? get diskUsagePercent => vpsDiskUsagePercent;
}

class ServerTelemetryService extends ChangeNotifier {
  static final ServerTelemetryService instance =
      ServerTelemetryService._internal();

  ServerTelemetryService._internal() {
    _initDefaultData();
  }

  Timer? _pollingTimer;
  bool _isAutoRefresh = true;
  bool _isScanning = false;
  bool get isScanning => _isScanning;

  final HardwareReader _hardwareReader = HardwareReader.instance;

  final List<double> _pingHistory = [];
  final List<double> _ramHistory = [];
  final List<int> _recentPings = [];
  final List<String> _scanLogs = [];

  // Kết quả probe gần nhất (null = chưa từng kiểm tra).
  bool? _cdnReachable;
  bool? _databaseReachable;

  // Giá trị thật đã từng quan sát được từ máy chủ (null = chưa từng thấy).
  String? _observedServerSoftware;
  String? _observedPocketBaseStatus;

  /// Web engine thật đã quan sát, hoặc 'Không xác định' nếu chưa từng thấy.
  String get _serverSoftwareText => _observedServerSoftware ?? 'Không xác định';

  /// Trạng thái PocketBase thật đã quan sát (không suy diễn).
  String get _pocketBaseStatusText =>
      _observedPocketBaseStatus ?? 'Chưa kiểm tra';

  /// Host:port THẬT của backend mà app đang gọi.
  ///
  /// Không hardcode: nếu người dùng đổi địa chỉ backend thì màn hình giám sát
  /// phải hiển thị đúng địa chỉ đó, không được khẳng định nhầm máy chủ.
  String get _backendAuthority {
    final uri = Uri.tryParse(PocketBaseService.instance.baseUrl);
    if (uri == null || uri.host.isEmpty) return VpsPlanSpec.hostLabel;
    return uri.hasPort ? '${uri.host}:${uri.port}' : uri.host;
  }

  // --- Nguồn số liệu tài nguyên: endpoint /metrics trên VPS ---
  /// Client gọi `/metrics`. Có thể thay bằng bản giả trong test.
  @visibleForTesting
  ServerMetricsClient metricsClient = const ServerMetricsClient();

  Uri? _metricsUriOverride;
  String _metricsToken = const String.fromEnvironment(
    'OPENFLIX_METRICS_TOKEN',
    defaultValue:
        'a5306e7306b40ef6797fe11c65c48ee618b919c33b45a059796d30eaaea9ebeb',
  );

  /// Địa chỉ endpoint số liệu. Mặc định là `/metrics` trên cùng host với backend.
  Uri get metricsUri {
    final override = _metricsUriOverride;
    if (override != null) return override;
    final base = Uri.parse(PocketBaseService.instance.baseUrl);
    return Uri.parse('${base.scheme}://${base.host}/metrics');
  }

  /// Ghi đè địa chỉ/token của endpoint `/metrics` (dùng khi triển khai khác).
  void configureMetrics({Uri? uri, String? token}) {
    _metricsUriOverride = uri;
    if (token != null) _metricsToken = token;
  }

  late ServerTelemetryData _currentData;
  ServerTelemetryData get currentData => _currentData;
  bool get isAutoRefresh => _isAutoRefresh;

  void _initDefaultData() {
    final ramMb = _hardwareReader.currentRssBytes / (1024 * 1024);
    _ramHistory.add(ramMb);

    _scanLogs.clear();
    _scanLogs.add(
      '[Sẵn sàng] Bấm "Quét Ngay" để kiểm tra kết nối máy chủ '
      '$_backendAuthority.',
    );

    _currentData = ServerTelemetryData(
      // Cấu hình tĩnh theo gói CLOUDSH LOC đã mua.
      vpsHost: _backendAuthority,
      vpsOs: VpsPlanSpec.os,
      vpsArchitecture: null,
      vpsCpu: VpsPlanSpec.cpuLabel,
      vpsCpuCores: VpsPlanSpec.cores,
      vpsRamTotal: '${formatGb(VpsPlanSpec.ramTotalGb)} GB RAM',
      vpsRamTotalGb: VpsPlanSpec.ramTotalGb,
      vpsStorageTotal: '${formatGb(VpsPlanSpec.diskTotalGb)} GB SSD',
      vpsDiskTotalGb: VpsPlanSpec.diskTotalGb,
      vpsPlan:
          '${VpsPlanSpec.provider} · ${VpsPlanSpec.priceLabel} '
          '· HH ${VpsPlanSpec.expiresOn}',
      vpsStorageVolume: null,
      serverSoftware: 'Không xác định',
      pocketBaseStatus: 'Chưa kiểm tra',
      serverDate: DateTime.now().toUtc().toIso8601String(),
      // Chưa đo được chỉ số tài nguyên nào.
      vpsCpuLoadPercent: null,
      vpsRamUsedGb: null,
      vpsDiskUsedGb: null,
      vpsOsUsedGb: null,
      vpsDbUsedGb: null,
      vpsMediaUsedGb: null,
      metricsLive: false,
      metricsError: kMetricsUnavailableNote,
      metricsGeneratedAt: null,
      load1: null,
      uptimeSeconds: null,
      kernelVersion: null,
      dockerVersion: null,
      pocketBaseVersion: null,
      metricsPocketBaseUp: null,
      metricsNginxUp: null,
      // Chưa thực hiện lần đo kết nối nào.
      isOnline: false,
      hasProbed: false,
      pocketBaseReachable: null,
      cdnReachable: null,
      databaseReachable: null,
      pingMs: 0,
      minPingMs: null,
      maxPingMs: null,
      avgPingMs: null,
      jitterMs: null,
      totalMoviesInDb: 0,
      lastPayloadBytes: 0,
      downloadSpeedKbps: null,
      processRamMb: double.parse(ramMb.toStringAsFixed(1)),
      peakRamMb: double.parse(
        (_hardwareReader.maxRssBytes / (1024 * 1024)).toStringAsFixed(1),
      ),
      imageCacheMb: 0.0,
      imageCacheCount: 0,
      cpuCores: _hardwareReader.numberOfProcessors,
      clientOs: _hardwareReader.operatingSystem,
      osVersion: _hardwareReader.operatingSystemVersion,
      scanLogs: List<String>.from(_scanLogs),
      pingHistory: const <double>[],
      ramHistory: [ramMb],
      timestamp: DateTime.now(),
    );
  }

  /// Bắt đầu lắng nghe tự động.
  ///
  /// [interval] mặc định là 2500ms (giữ nguyên hành vi cũ); test có thể truyền
  /// giá trị nhỏ hơn để không phải chờ timer thật.
  void startMonitoring({
    Duration interval = const Duration(milliseconds: 2500),
  }) {
    refreshTelemetry();
    _pollingTimer?.cancel();
    if (_isAutoRefresh) {
      _pollingTimer = Timer.periodic(interval, (_) => refreshTelemetry());
    }
  }

  /// Dừng lắng nghe.
  void stopMonitoring() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  /// Bật/tắt tự động làm mới.
  void toggleAutoRefresh(bool enable) {
    _isAutoRefresh = enable;
    if (_isAutoRefresh) {
      startMonitoring();
    } else {
      stopMonitoring();
    }
    notifyListeners();
  }

  /// Quét chẩn đoán cấu hình VPS bằng các probe thật.
  ///
  /// Chỉ ghi vào nhật ký những gì thực sự kiểm tra được: HTTP status,
  /// header `Server`, số bản ghi. Không suy diễn CPU/RAM/dung lượng.
  Future<void> scanVpsConfiguration() async {
    _isScanning = true;
    _scanLogs.clear();
    String nowStr() {
      final now = DateTime.now();
      return '${now.hour.toString().padLeft(2, '0')}:'
          '${now.minute.toString().padLeft(2, '0')}:'
          '${now.second.toString().padLeft(2, '0')}';
    }

    _scanLogs.add(
      '[${nowStr()}] 📡 Bắt đầu kiểm tra máy chủ ${VpsPlanSpec.host}...',
    );
    notifyListeners();

    final baseUrl = PocketBaseService.instance.baseUrl;
    final healthUri = Uri.parse('$baseUrl/api/health');
    final dbCountUri = Uri.parse(
      '$baseUrl/api/collections/movies/records?page=1&perPage=1&skipTotal=false',
    );
    final cdnUri = Uri.parse(
      'http://${VpsPlanSpec.host}/posters/big_buck_bunny.jpg?v=4',
    );

    int ping = 0;
    bool healthOk = false;
    String? nginxServer;
    String serverDate = '';

    // Bước 1: Health & Port 8090.
    try {
      final sw = Stopwatch()..start();
      final res = await http
          .get(healthUri)
          .timeout(const Duration(milliseconds: 3500));
      sw.stop();
      ping = sw.elapsedMilliseconds;
      if (res.statusCode == 200) {
        healthOk = true;
        nginxServer = res.headers['server'];
        serverDate = res.headers['date'] ?? '';
        if (nginxServer != null && nginxServer.isNotEmpty) {
          _observedServerSoftware = nginxServer;
        }
        try {
          final decoded = jsonDecode(res.body);
          if (decoded is Map && decoded['data'] is Map) {
            final canBackup = decoded['data']['canBackup'] == true;
            _observedPocketBaseStatus =
                'SQLite • canBackup: ${canBackup ? 'true' : 'false'}';
          }
        } catch (_) {}
        _scanLogs.add(
          '[${nowStr()}] ✅ PocketBase (port ${VpsPlanSpec.port}): '
          'HTTP 200 OK ($ping ms)',
        );
        _scanLogs.add(
          '[${nowStr()}] 🌐 Web Server: ${nginxServer ?? 'không có header Server'}',
        );
      } else {
        _scanLogs.add(
          '[${nowStr()}] ⚠️ Port ${VpsPlanSpec.port} trả về mã '
          '${res.statusCode}',
        );
      }
    } catch (e) {
      _scanLogs.add('[${nowStr()}] ❌ Lỗi kết nối port ${VpsPlanSpec.port}: $e');
    }
    notifyListeners();

    // Bước 2: CDN media port 80.
    try {
      final swMedia = Stopwatch()..start();
      final mediaRes = await http
          .head(cdnUri)
          .timeout(const Duration(milliseconds: 2500));
      swMedia.stop();
      if (mediaRes.statusCode == 200) {
        _cdnReachable = true;
        final cLength = mediaRes.headers['content-length'];
        _scanLogs.add(
          '[${nowStr()}] ✅ Media CDN (port 80): HTTP 200 '
          '(${swMedia.elapsedMilliseconds} ms'
          '${cLength != null ? ' • $cLength bytes' : ''})',
        );
      } else {
        _cdnReachable = false;
        _scanLogs.add(
          '[${nowStr()}] ⚠️ Media CDN (port 80): HTTP ${mediaRes.statusCode}',
        );
      }
    } catch (e) {
      _cdnReachable = false;
      _scanLogs.add('[${nowStr()}] ❌ Media CDN (port 80): không kết nối được');
    }
    notifyListeners();

    // Bước 3: Đếm bản ghi trong SQLite.
    int totalMovies = _currentData.totalMoviesInDb;
    if (healthOk) {
      try {
        final dbRes = await http
            .get(dbCountUri)
            .timeout(const Duration(milliseconds: 2500));
        if (dbRes.statusCode == 200) {
          final dbJson = jsonDecode(dbRes.body);
          if (dbJson is Map && dbJson['totalItems'] is int) {
            totalMovies = dbJson['totalItems'] as int;
            _databaseReachable = true;
            _scanLogs.add(
              '[${nowStr()}] 🗄️ SQLite: $totalMovies bản ghi phim '
              '(WAL mode)',
            );
          } else {
            _databaseReachable = false;
            _scanLogs.add(
              '[${nowStr()}] ⚠️ SQLite: phản hồi không có trường totalItems',
            );
          }
        } else {
          _databaseReachable = false;
          _scanLogs.add('[${nowStr()}] ⚠️ SQLite: HTTP ${dbRes.statusCode}');
        }
      } catch (e) {
        _databaseReachable = false;
        _scanLogs.add('[${nowStr()}] ❌ SQLite: không truy vấn được');
      }
    } else {
      _databaseReachable = false;
      _scanLogs.add(
        '[${nowStr()}] ⏭️ Bỏ qua kiểm tra SQLite vì PocketBase không phản hồi',
      );
    }
    notifyListeners();

    // Ghi rõ giới hạn của lần quét — không khẳng định điều chưa đo được.
    _scanLogs.add(
      '[${nowStr()}] ℹ️ Cấu hình tĩnh theo gói: ${VpsPlanSpec.summary} '
      '(${VpsPlanSpec.os}).',
    );

    // Bước 4: đọc số liệu tài nguyên thật từ endpoint /metrics.
    final metrics = await metricsClient.fetch(
      uri: metricsUri,
      token: _metricsToken,
    );
    if (metrics != null && metrics.hasAnyResource) {
      _scanLogs.add(
        '[${nowStr()}] 📊 /metrics: CPU ${metrics.cpuPercent ?? '—'}% • '
        'RAM ${metrics.memUsedGb == null ? '—' : formatGb(metrics.memUsedGb!)}'
        '/${metrics.memTotalGb == null ? '—' : formatGb(metrics.memTotalGb!)} GB • '
        'SSD ${metrics.diskUsedGb == null ? '—' : formatGb(metrics.diskUsedGb!)}'
        '/${metrics.diskTotalGb == null ? '—' : formatGb(metrics.diskTotalGb!)} GB',
      );
    } else {
      _scanLogs.add(
        '[${nowStr()}] ⚠️ Không đọc được số liệu tài nguyên từ $metricsUri. '
        '$kMetricsUnavailableNote',
      );
    }
    notifyListeners();

    await refreshTelemetry(
      explicitPing: ping > 0 ? ping : null,
      explicitServerDate: serverDate,
      explicitTotalMovies: totalMovies,
    );
    _isScanning = false;
    notifyListeners();
  }

  /// Làm mới telemetry định kỳ.
  Future<void> refreshTelemetry({
    int? explicitPing,
    String? explicitServerDate,
    int? explicitTotalMovies,
  }) async {
    final baseUrl = PocketBaseService.instance.baseUrl;
    final healthUri = Uri.parse('$baseUrl/api/health');
    final dbCountUri = Uri.parse(
      '$baseUrl/api/collections/movies/records?page=1&perPage=1&skipTotal=false',
    );

    // Gọi /metrics song song với probe health để không cộng dồn độ trễ.
    final metricsFuture = metricsClient.fetch(
      uri: metricsUri,
      token: _metricsToken,
    );

    int ping = explicitPing ?? 0;
    bool online = false;
    bool healthProbed = false;
    bool? pocketBaseReachable;
    String? pbStatusOverride;
    String serverDate = explicitServerDate ?? _currentData.serverDate;
    int totalDbMovies = explicitTotalMovies ?? _currentData.totalMoviesInDb;
    int payloadBytes = 0;
    double? throughputKbps = _currentData.downloadSpeedKbps;

    if (explicitPing != null) {
      // Kết quả đến từ scanVpsConfiguration() — đã probe thật.
      online = true;
      healthProbed = true;
      pocketBaseReachable = true;
    } else {
      try {
        final sw = Stopwatch()..start();
        final healthRes = await http
            .get(healthUri)
            .timeout(const Duration(milliseconds: 3000));
        sw.stop();
        healthProbed = true;
        ping = sw.elapsedMilliseconds;
        payloadBytes += healthRes.bodyBytes.length;

        if (healthRes.statusCode == 200) {
          online = true;
          pocketBaseReachable = true;
          final header = healthRes.headers['server'];
          if (header != null && header.isNotEmpty) {
            _observedServerSoftware = header;
          }
          if (healthRes.headers['date'] != null) {
            serverDate = healthRes.headers['date']!;
          }
          final decoded = jsonDecode(healthRes.body);
          if (decoded is Map && decoded['data'] is Map) {
            final canBackup = decoded['data']['canBackup'] == true;
            _observedPocketBaseStatus =
                'SQLite • canBackup: ${canBackup ? 'true' : 'false'}';
          }
        } else {
          pocketBaseReachable = false;
          pbStatusOverride = 'HTTP ${healthRes.statusCode}';
        }
      } catch (_) {
        online = false;
        healthProbed = true;
        pocketBaseReachable = false;
        ping = 0;
      }
    }

    if (online && explicitTotalMovies == null && explicitPing == null) {
      try {
        final swDb = Stopwatch()..start();
        final dbRes = await http
            .get(dbCountUri)
            .timeout(const Duration(milliseconds: 2500));
        swDb.stop();
        final bytesCount = dbRes.bodyBytes.length;
        payloadBytes += bytesCount;

        if (swDb.elapsedMilliseconds > 0) {
          throughputKbps =
              (bytesCount / 1024.0) / (swDb.elapsedMilliseconds / 1000.0);
        }

        if (dbRes.statusCode == 200) {
          final dbJson = jsonDecode(dbRes.body);
          if (dbJson is Map && dbJson['totalItems'] is int) {
            totalDbMovies = dbJson['totalItems'] as int;
            _databaseReachable = true;
          }
        }
      } catch (_) {
        _databaseReachable = false;
      }
    }

    // Đọc phần cứng client app (số đo thật của thiết bị đang chạy).
    final currentRss = _hardwareReader.currentRssBytes;
    final maxRss = _hardwareReader.maxRssBytes;
    final ramMb = currentRss / (1024 * 1024);
    final peakMb = maxRss / (1024 * 1024);

    int imageBytes = 0;
    int imageCount = 0;
    try {
      final cache = PaintingBinding.instance.imageCache;
      imageBytes = cache.currentSizeBytes;
      imageCount = cache.currentSize;
    } catch (_) {}
    final imageCacheMb = imageBytes / (1024 * 1024);

    if (online && ping > 0) {
      _recentPings.add(ping);
      if (_recentPings.length > 20) _recentPings.removeAt(0);
    }

    final int? minP = _recentPings.isEmpty
        ? null
        : _recentPings.reduce((a, b) => a < b ? a : b);
    final int? maxP = _recentPings.isEmpty
        ? null
        : _recentPings.reduce((a, b) => a > b ? a : b);
    final int? avgP = _recentPings.isEmpty
        ? null
        : _recentPings.reduce((a, b) => a + b) ~/ _recentPings.length;

    // Jitter = trung bình độ lệch tuyệt đối giữa các mẫu liên tiếp.
    int? jitter;
    if (_recentPings.length >= 2) {
      var totalDelta = 0;
      for (var i = 1; i < _recentPings.length; i++) {
        totalDelta += (_recentPings[i] - _recentPings[i - 1]).abs();
      }
      jitter = totalDelta ~/ (_recentPings.length - 1);
    }

    if (online && ping > 0) {
      _pingHistory.add(ping.toDouble());
      if (_pingHistory.length > 25) _pingHistory.removeAt(0);
    }

    _ramHistory.add(ramMb);
    if (_ramHistory.length > 25) _ramHistory.removeAt(0);

    // --- Số liệu tài nguyên thật từ /metrics (null nếu không đọc được) ---
    final metrics = await metricsFuture;
    final metricsLive = metrics != null && metrics.hasAnyResource;
    final ramTotalGb = metrics?.memTotalGb ?? VpsPlanSpec.ramTotalGb;
    final diskTotalGb = metrics?.diskTotalGb ?? VpsPlanSpec.diskTotalGb;
    final cores = metrics?.cores ?? VpsPlanSpec.cores;
    final cpuLabel = cores == 1 ? '1 Core' : '$cores Cores';

    _currentData = ServerTelemetryData(
      // --- Cấu hình: tổng dung lượng/cpu ưu tiên số đo thật, nếu không có thì
      // dùng cấu hình của gói VPS đã mua ---
      vpsHost: _backendAuthority,
      vpsOs: metrics?.osPretty ?? VpsPlanSpec.os,
      vpsArchitecture: metrics?.arch,
      vpsCpu: cpuLabel,
      vpsCpuCores: cores,
      vpsRamTotal: '${formatGb(ramTotalGb)} GB RAM',
      vpsRamTotalGb: ramTotalGb,
      vpsStorageTotal: '${formatGb(diskTotalGb)} GB SSD',
      vpsDiskTotalGb: diskTotalGb,
      vpsPlan:
          '${VpsPlanSpec.provider} · ${VpsPlanSpec.priceLabel} '
          '· HH ${VpsPlanSpec.expiresOn}',
      vpsStorageVolume: metrics?.dataDir,
      serverSoftware: _serverSoftwareText,
      pocketBaseStatus: pbStatusOverride ?? _pocketBaseStatusText,
      serverDate: serverDate.isNotEmpty
          ? serverDate
          : DateTime.now().toUtc().toIso8601String(),
      // --- Chỉ số tài nguyên: chỉ lấy từ /metrics, không suy diễn ---
      vpsCpuLoadPercent: metrics?.cpuPercent,
      vpsRamUsedGb: metrics?.memUsedGb,
      vpsDiskUsedGb: metrics?.diskUsedGb,
      vpsOsUsedGb: metrics?.diskOsGb,
      vpsDbUsedGb: metrics?.diskDbGb,
      vpsMediaUsedGb: metrics?.diskMediaGb,
      metricsLive: metricsLive,
      metricsError: metricsLive ? null : kMetricsUnavailableNote,
      metricsGeneratedAt: metrics?.generatedAt?.toIso8601String(),
      load1: metrics?.load1,
      uptimeSeconds: metrics?.uptimeSeconds,
      kernelVersion: metrics?.kernel,
      dockerVersion: metrics?.dockerVersion,
      pocketBaseVersion: metrics?.pocketBaseVersion,
      metricsPocketBaseUp: metrics?.pocketBaseServiceUp,
      metricsNginxUp: metrics?.nginxServiceUp,
      // --- Kết nối (đo thật) ---
      isOnline: online,
      hasProbed: healthProbed || _currentData.hasProbed,
      pocketBaseReachable: pocketBaseReachable,
      cdnReachable: _cdnReachable,
      databaseReachable: _databaseReachable,
      pingMs: online ? ping : 0,
      minPingMs: minP,
      maxPingMs: maxP,
      avgPingMs: avgP,
      jitterMs: jitter,
      totalMoviesInDb: totalDbMovies,
      lastPayloadBytes: payloadBytes,
      downloadSpeedKbps: throughputKbps == null
          ? null
          : double.parse(throughputKbps.toStringAsFixed(1)),
      processRamMb: double.parse(ramMb.toStringAsFixed(1)),
      peakRamMb: double.parse(peakMb.toStringAsFixed(1)),
      imageCacheMb: double.parse(imageCacheMb.toStringAsFixed(2)),
      imageCacheCount: imageCount,
      cpuCores: _hardwareReader.numberOfProcessors,
      clientOs: _hardwareReader.operatingSystem,
      osVersion: _hardwareReader.operatingSystemVersion,
      scanLogs: List<String>.from(_scanLogs),
      pingHistory: List<double>.from(_pingHistory),
      ramHistory: List<double>.from(_ramHistory),
      timestamp: DateTime.now(),
    );

    notifyListeners();
  }

  /// Dọn cache ảnh trong RAM của **ứng dụng client**.
  ///
  /// Trả về đúng số MB thực sự giải phóng (0 nếu không giải phóng được gì).
  Future<double> cleanMemoryCache() async {
    final beforeBytes = _hardwareReader.currentRssBytes;
    try {
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();
    } catch (_) {}

    await Future<void>.delayed(const Duration(milliseconds: 150));

    final afterBytes = _hardwareReader.currentRssBytes;
    final freedMb = (beforeBytes - afterBytes) / (1024 * 1024);
    return freedMb > 0 ? freedMb : 0.0;
  }
}
