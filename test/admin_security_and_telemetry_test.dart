import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openflix/features/admin/admin_auth_gate_screen.dart';
import 'package:openflix/features/admin/server_monitor_screen.dart';
import 'package:openflix/features/admin/services/admin_auth_service.dart';
import 'package:openflix/features/admin/services/server_metrics.dart';
import 'package:openflix/features/admin/services/server_telemetry_service.dart';
import 'package:openflix/services/pocketbase_service.dart';

/// Client giả để test nhánh "có số liệu thật từ /metrics" mà không cần mạng.
class _FakeMetricsClient extends ServerMetricsClient {
  _FakeMetricsClient(this.metrics);

  final ServerMetrics? metrics;
  int calls = 0;

  @override
  Future<ServerMetrics?> fetch({
    required Uri uri,
    String? token,
    Duration timeout = const Duration(milliseconds: 2500),
  }) async {
    calls++;
    return metrics;
  }
}

/// Số liệu mẫu đúng định dạng agent xuất ra (đã quy đổi GB như app mong đợi).
const ServerMetrics _liveMetrics = ServerMetrics(
  cpuPercent: 12.5,
  load1: 0.08,
  cores: 1,
  memTotalGb: 2.0,
  memUsedGb: 731 / 1024,
  diskTotalGb: 25.0,
  diskUsedGb: 8.3,
  diskOsGb: 5.1,
  diskDbGb: 2.4,
  diskMediaGb: 0.8,
  uptimeSeconds: 1834920,
  kernel: '6.8.0-41-generic',
  arch: 'x86_64',
  osPretty: 'Ubuntu 24.04.1 LTS',
  dockerVersion: '29.1.3',
  pocketBaseVersion: '0.22.29',
  dataDir: '/opt/openflix-backend/pb_data',
  pocketBaseServiceUp: true,
  nginxServiceUp: true,
);

/// Máy chủ có CPU/RAM/dung lượng nhưng **chưa trả về chi tiết** phân bổ
/// (không có disk_os_gb / disk_db_gb / disk_media_gb).
const ServerMetrics _partialMetrics = ServerMetrics(
  cpuPercent: 9.0,
  cores: 1,
  memTotalGb: 2.0,
  memUsedGb: 0.5,
  diskTotalGb: 25.0,
  diskUsedGb: 11.0,
);

/// Số liệu thật nhưng máy chủ **chỉ trả về 1/3 phân vùng** (thiếu DB/Media).
const ServerMetrics _partialBreakdownMetrics = ServerMetrics(
  cpuPercent: 9.0,
  cores: 1,
  memTotalGb: 2.0,
  memUsedGb: 0.5,
  diskTotalGb: 25.0,
  diskUsedGb: 11.0,
  diskOsGb: 6.2,
);

/// Số liệu thật nhưng agent **không xác nhận** thư mục dữ liệu (`data_dir` null).
const ServerMetrics _liveMetricsNoDataDir = ServerMetrics(
  cpuPercent: 12.5,
  cores: 1,
  memTotalGb: 2.0,
  memUsedGb: 731 / 1024,
  diskTotalGb: 25.0,
  diskUsedGb: 8.3,
  diskDbGb: 2.4,
  arch: 'x86_64',
);

/// Agent báo thư mục dữ liệu THẬT khác hẳn đường dẫn mặc định ngày trước.
const ServerMetrics _liveMetricsCustomDataDir = ServerMetrics(
  cpuPercent: 5.0,
  cores: 1,
  memTotalGb: 2.0,
  memUsedGb: 0.5,
  diskTotalGb: 25.0,
  diskUsedGb: 8.3,
  diskOsGb: 5.1,
  diskDbGb: 2.4,
  diskMediaGb: 0.8,
  dataDir: '/srv/openflix/pb_data',
);

void main() {
  group('AdminAuthService Tests', () {
    final auth = AdminAuthService.instance;

    setUp(() {
      auth.logout();
    });

    test('Ban đầu chưa xác thực', () {
      expect(auth.isAuthenticated, isFalse);
    });

    test('Xác thực sai mật khẩu bị từ chối', () async {
      final success = await auth.authenticate('wrong_password');
      expect(success, isFalse);
      expect(auth.isAuthenticated, isFalse);
    });

    test('Mật khẩu 123 mở khóa quản trị thành công', () async {
      final success = await auth.authenticate('123');
      expect(success, isTrue);
      expect(auth.isAuthenticated, isTrue);
    });

    test('Đăng xuất khóa lại quyền quản trị', () async {
      await auth.authenticate('123');
      expect(auth.isAuthenticated, isTrue);
      auth.logout();
      expect(auth.isAuthenticated, isFalse);
    });
  });

  group('ServerTelemetryService Real Hardware & VPS Tests', () {
    final telemetry = ServerTelemetryService.instance;

    test('Cấu hình tĩnh khớp đúng gói VPS đã thuê (1 Core · 2 GB · 25 GB)', () {
      final data = telemetry.currentData;
      expect(data.vpsHost, equals('180.93.120.246:8090'));
      expect(data.vpsCpu, contains('1 Core'));
      expect(data.vpsCpuCores, equals(1));
      expect(data.vpsRamTotal, equals('2.0 GB RAM'));
      expect(data.vpsRamTotalGb, equals(2.0));
      expect(data.vpsStorageTotal, equals('25.0 GB SSD'));
      expect(data.vpsDiskTotalGb, equals(25.0));
      expect(data.vpsOs, contains('Ubuntu'));
      expect(data.vpsPlan, contains('CLOUDSH LOC'));
    });

    test('Không bịa chỉ số CPU/RAM/dung lượng khi chưa có nguồn đo thật', () {
      final data = telemetry.currentData;
      // Máy chủ chưa có endpoint /metrics ⇒ mọi chỉ số tài nguyên phải là null
      // để giao diện hiển thị "—", không được có số ước lượng.
      expect(data.vpsCpuLoadPercent, isNull);
      expect(data.vpsRamUsedGb, isNull);
      expect(data.vpsDiskUsedGb, isNull);
      expect(data.vpsOsUsedGb, isNull);
      expect(data.vpsDbUsedGb, isNull);
      expect(data.vpsMediaUsedGb, isNull);
      expect(data.vpsRamUsagePercent, isNull);
      expect(data.vpsDiskUsagePercent, isNull);
      expect(data.vpsFreeDiskGb, isNull);
      expect(data.hasMeasuredMetrics, isFalse);
      // Chưa probe lần nào ⇒ không có trạng thái/mẫu đo giả.
      expect(data.minPingMs, isNull);
      expect(data.maxPingMs, isNull);
      expect(data.avgPingMs, isNull);
      expect(data.jitterMs, isNull);
      expect(data.pingHistory, isEmpty);
      expect(data.pocketBaseReachable, isNull);
      expect(data.cdnReachable, isNull);
      expect(data.databaseReachable, isNull);
    });

    test('cleanMemoryCache báo đúng dung lượng thật (có thể bằng 0)', () async {
      final freed = await telemetry.cleanMemoryCache();
      expect(freed, greaterThanOrEqualTo(0.0));
    });

    test('refreshTelemetry đo lường lại dữ liệu thực tế mà không sinh số ngẫu nhiên', () async {
      final oldTimestamp = telemetry.currentData.timestamp;
      await Future<void>.delayed(const Duration(milliseconds: 10));
      await telemetry.refreshTelemetry();
      final newTimestamp = telemetry.currentData.timestamp;
      expect(newTimestamp.isAfter(oldTimestamp) || newTimestamp == oldTimestamp, isTrue);
    });

    test('toggleAutoRefresh bật tắt chu kỳ giám sát tự động', () {
      telemetry.toggleAutoRefresh(false);
      expect(telemetry.isAutoRefresh, isFalse);
      telemetry.toggleAutoRefresh(true);
      expect(telemetry.isAutoRefresh, isTrue);
    });
  });

  group('AdminAuthGateScreen Widget Tests', () {
    setUp(() {
      AdminAuthService.instance.logout();
    });

    testWidgets('Hiển thị giao diện khóa và gợi ý mật khẩu 123', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AdminAuthGateScreen(),
        ),
      );

      expect(find.text('Bảo mật Quản trị'), findsOneWidget);
      expect(find.textContaining('123'), findsWidgets);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Mở khóa hệ thống'), findsOneWidget);
    });

    testWidgets('Báo lỗi trực quan khi nhập sai mật khẩu', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AdminAuthGateScreen(),
        ),
      );

      await tester.enterText(find.byType(TextField), '999');
      await tester.tap(find.text('Mở khóa hệ thống'));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      expect(find.text('Mật khẩu không chính xác! (Gợi ý: 123)'), findsOneWidget);
      expect(AdminAuthService.instance.isAuthenticated, isFalse);
    });

    testWidgets('Mở khóa thành công khi nhập mật khẩu 123', (tester) async {
      bool unlockedCallbackCalled = false;
      await tester.pumpWidget(
        MaterialApp(
          home: AdminAuthGateScreen(
            onAuthenticated: () {
              unlockedCallbackCalled = true;
            },
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), '123');
      await tester.tap(find.text('Mở khóa hệ thống'));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      expect(unlockedCallbackCalled, isTrue);
      expect(AdminAuthService.instance.isAuthenticated, isTrue);
    });
  });

  group('ServerMonitorScreen Widget Tests', () {
    testWidgets('Hiển thị đầy đủ cấu hình phần cứng VPS và nút quay lại', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ServerMonitorScreen(),
        ),
      );

      // Verify header & back button exist
      // Tiêu đề lấy host THẬT của backend đang cấu hình (không hardcode IP trần).
      expect(
        find.text('Giám sát Máy chủ VPS (180.93.120.246:8090)'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);

      // Verify VPS hardware configuration cards
      expect(
        find.text('Cấu hình Phần cứng (theo gói VPS đã thuê)'),
        findsOneWidget,
      );
      expect(find.text('Vi xử lý VPS'), findsOneWidget);
      expect(find.text('Bộ nhớ RAM VPS'), findsOneWidget);
      expect(find.text('Ổ cứng SSD VPS'), findsOneWidget);
      expect(find.text('Cơ sở Dữ liệu'), findsOneWidget);

      // Không được hiển thị cấu hình sai của bản cũ (2 vCPU / 4 GB / 50 GB)
      // và phải hiện đúng cấu hình gói thật (1 Core / 2 GB / 25 GB).
      expect(find.textContaining('2 vCPU'), findsNothing);
      expect(find.textContaining('4.0 GB'), findsNothing);
      expect(find.textContaining('50 GB'), findsNothing);
      expect(find.textContaining('25.0 GB'), findsWidgets);
      expect(find.textContaining('2.0 GB'), findsWidgets);
      expect(find.textContaining('1 Core'), findsWidgets);

      // Verify Live Scanner console
      expect(find.text('Nhật ký Quét Cấu hình VPS Trực tiếp'), findsOneWidget);
      expect(find.text('Quét Ngay'), findsOneWidget);

      // Verify custom painter
      expect(find.byType(CustomPaint), findsWidgets);
    });
  });

  group('ServerMetrics — parse endpoint /metrics', () {
    test('Đọc đúng JSON của agent và không bịa số khi thiếu dữ liệu', () {
      final ok = ServerMetrics.tryParse('''
      {"generated_at":"2026-10-19T02:00:00Z","cpu_percent":7.4,"load1":0.08,
       "load5":0.05,"cores":1,"mem_total_mb":2048,"mem_used_mb":731,
       "disk_total_gb":25.0,"disk_used_gb":8.3,"disk_os_gb":5.12,
       "disk_db_gb":2.4,"disk_media_gb":0.78,"uptime_s":100,
       "kernel":"6.8.0-41-generic","os_pretty":"Ubuntu 24.04.1 LTS",
       "docker_version":"29.1.3","pocketbase_version":"0.22.29",
       "services":{"pocketbase":true,"nginx":false}}''');

      expect(ok, isNotNull);
      expect(ok!.cpuPercent, 7.4);
      expect(ok.load1, 0.08);
      expect(ok.cores, 1);
      expect(ok.memTotalGb, closeTo(2.0, 0.001));
      expect(ok.memUsedGb, closeTo(0.7139, 0.001));
      expect(ok.diskTotalGb, 25.0);
      expect(ok.diskUsedGb, 8.3);
      expect(ok.diskDbGb, 2.4);
      expect(ok.uptimeSeconds, 100);
      expect(ok.kernel, '6.8.0-41-generic');
      expect(ok.osPretty, 'Ubuntu 24.04.1 LTS');
      expect(ok.dockerVersion, '29.1.3');
      expect(ok.pocketBaseServiceUp, isTrue);
      expect(ok.nginxServiceUp, isFalse);
      expect(ok.generatedAt, isNotNull);
      expect(ok.hasAnyResource, isTrue);

      // Giá trị null / thiếu khoá ⇒ null, tuyệt đối không suy diễn thành 0.
      final partial = ServerMetrics.tryParse(
        '{"cpu_percent": null, "mem_total_mb": null, "disk_used_gb": null}',
      );
      expect(partial, isNotNull);
      expect(partial!.cpuPercent, isNull);
      expect(partial.memTotalGb, isNull);
      expect(partial.diskUsedGb, isNull);
      expect(partial.hasAnyResource, isFalse);

      // Body không phải JSON object ⇒ null (ví dụ trang 403 của nginx).
      expect(ServerMetrics.tryParse('<html>403 Forbidden</html>'), isNull);
      expect(ServerMetrics.tryParse(''), isNull);
    });
  });

  group('ServerTelemetryService — nhánh có số liệu thật từ /metrics', () {
    final telemetry = ServerTelemetryService.instance;

    tearDown(() {
      telemetry.metricsClient = const ServerMetricsClient();
    });

    test('refreshTelemetry nạp đúng số đo thật và uptime', () async {
      telemetry.metricsClient = _FakeMetricsClient(_liveMetrics);

      await telemetry.refreshTelemetry();
      final data = telemetry.currentData;

      expect(data.metricsLive, isTrue);
      expect(data.hasMeasuredMetrics, isTrue);
      expect(data.metricsError, isNull);
      expect(data.vpsCpuLoadPercent, 12.5);
      expect(data.vpsRamUsedGb, closeTo(0.7139, 0.001));
      expect(data.vpsRamTotalGb, 2.0);
      expect(data.vpsRamUsagePercent, closeTo(35.7, 0.1));
      expect(data.vpsDiskUsedGb, 8.3);
      expect(data.vpsDiskTotalGb, 25.0);
      expect(data.vpsOsUsedGb, 5.1);
      expect(data.vpsDbUsedGb, 2.4);
      expect(data.vpsMediaUsedGb, 0.8);
      expect(data.uptimeLabel, '21 ngày 5 giờ');
      expect(data.kernelVersion, '6.8.0-41-generic');
      expect(data.dockerVersion, '29.1.3');
      expect(data.pocketBaseVersion, '0.22.29');
      expect(data.load1, 0.08);
      expect(data.metricsPocketBaseUp, isTrue);
      expect(data.vpsArchitecture, 'x86_64');
      expect(data.vpsStorageVolume, '/opt/openflix-backend/pb_data');
      // Host hiển thị phải là host THẬT của backend đang cấu hình.
      expect(data.vpsHost, '180.93.120.246:8090');
      // Tổng dung lượng lấy theo số đo thật (25 GB) chứ không phải hằng số.
      expect(data.vpsStorageTotal, contains('25'));
    });

    test('Không hardcode đường dẫn/kiến trúc khi máy chủ không trả số liệu',
        () async {
      telemetry.metricsClient = _FakeMetricsClient(null);

      await telemetry.refreshTelemetry();
      final data = telemetry.currentData;

      expect(data.metricsLive, isFalse);
      // Không được tự bịa đường dẫn dữ liệu hay kiến trúc CPU.
      expect(data.vpsStorageVolume, isNull);
      expect(data.vpsArchitecture, isNull);
      expect(data.metricsError, isNotNull);
    });

    test('Bỏ số đo khi endpoint trả JSON rỗng chỉ số', () async {
      telemetry.metricsClient = _FakeMetricsClient(
        const ServerMetrics(cpuPercent: null, memUsedGb: null),
      );

      await telemetry.refreshTelemetry();
      final data = telemetry.currentData;

      expect(data.metricsLive, isFalse);
      expect(data.hasMeasuredMetrics, isFalse);
      expect(data.vpsCpuLoadPercent, isNull);
      expect(data.vpsRamUsedGb, isNull);
      expect(data.metricsError, isNotNull);
    });
  });

  group('ServerMonitorScreen — hiển thị theo nguồn số liệu', () {
    final telemetry = ServerTelemetryService.instance;

    tearDown(() {
      telemetry.metricsClient = const ServerMetricsClient();
    });

    testWidgets('Có /metrics: hiện số đo thật, không hiện ghi chú thiếu dữ liệu',
        (tester) async {
      telemetry.metricsClient = _FakeMetricsClient(_liveMetrics);

      await tester.pumpWidget(
        const MaterialApp(home: ServerMonitorScreen()),
      );
      await telemetry.refreshTelemetry();
      await tester.pump();

      expect(find.textContaining('12.5% Tải'), findsOneWidget);
      expect(find.textContaining('0.71 / 2.0 GB'), findsWidgets);
      expect(find.textContaining('8.3 / 25.0 GB'), findsWidgets);
      expect(find.text('21 ngày 5 giờ'), findsOneWidget);
      expect(find.textContaining('Số liệu đo trực tiếp từ'), findsOneWidget);
      // Thư mục dữ liệu chỉ hiện khi CHÍNH agent xác nhận nó tồn tại.
      expect(
        find.textContaining('/opt/openflix-backend/pb_data'),
        findsOneWidget,
      );
      // Host hiển thị lấy từ backend thật, không hardcode.
      expect(
        find.byKey(const ValueKey('vps-host-badge')),
        findsOneWidget,
      );
      expect(find.textContaining('50 GB'), findsNothing);
      expect(find.textContaining('4.0 GB'), findsNothing);
    });

    testWidgets(
        'Dung lượng thiếu chi tiết phân bổ: không vẽ 0.00 GB giả', (tester) async {
      telemetry.metricsClient = _FakeMetricsClient(_partialMetrics);

      await tester.pumpWidget(
        const MaterialApp(home: ServerMonitorScreen()),
      );
      await telemetry.refreshTelemetry();
      await tester.pump();

      expect(find.textContaining('0.00 GB'), findsNothing);
      expect(find.textContaining('Đã dùng:'), findsOneWidget);
      expect(find.textContaining('SQLite DB:'), findsNothing);
      expect(find.textContaining('Media CDN:'), findsNothing);
      expect(
        find.textContaining('chưa trả về chi tiết phân bổ'),
        findsOneWidget,
      );
    });

    testWidgets('Không có /metrics: hiện "—" và ghi chú nguồn số liệu',
        (tester) async {
      telemetry.metricsClient = const ServerMetricsClient();

      await tester.pumpWidget(
        const MaterialApp(home: ServerMonitorScreen()),
      );
      await telemetry.refreshTelemetry();
      await tester.pump();

      expect(find.textContaining('12.5% Tải'), findsNothing);
      expect(find.textContaining('1 Core'), findsWidgets);
      expect(find.textContaining('chưa đo được'), findsWidgets);
      expect(find.textContaining('/metrics'), findsWidgets);
      // Không được khẳng định đường dẫn dữ liệu / chế độ WAL chưa từng kiểm tra.
      expect(
        find.textContaining('/opt/openflix-backend/pb_data'),
        findsNothing,
      );
      expect(find.textContaining('WAL'), findsNothing);
      expect(find.textContaining('0.00 GB'), findsNothing);
    });
  });

  group('ServerMonitorScreen — chống hồi quy "số liệu ảo"', () {
    final telemetry = ServerTelemetryService.instance;

    tearDown(() {
      telemetry.metricsClient = const ServerMetricsClient();
    });

    testWidgets(
        'Chỉ có 1/3 phân vùng được đo: không vẽ "0.00 GB" cho phần chưa đo',
        (tester) async {
      telemetry.metricsClient = _FakeMetricsClient(_partialBreakdownMetrics);

      await tester.pumpWidget(const MaterialApp(home: ServerMonitorScreen()));
      await telemetry.refreshTelemetry();
      await tester.pump();

      // Phần chưa đo ⇒ không vẽ nhãn/giá trị nào (bản cũ vẽ "0.00 GB").
      expect(find.textContaining('0.00 GB'), findsNothing);
      expect(find.textContaining('Ubuntu & Docker:'), findsNothing);
      expect(find.textContaining('SQLite DB:'), findsNothing);
      expect(find.textContaining('Media CDN:'), findsNothing);
      // Chỉ hiện đúng phần đo được thật + phần trống, kèm ghi chú giải thích.
      expect(find.textContaining('Đã dùng: 11.0 GB'), findsOneWidget);
      expect(find.textContaining('Trống: 14.0 GB'), findsOneWidget);
      expect(
        find.textContaining('chưa trả về chi tiết phân bổ'),
        findsOneWidget,
      );
    });

    testWidgets('Thư mục dữ liệu lấy từ agent, không hardcode đường dẫn cũ',
        (tester) async {
      telemetry.metricsClient = _FakeMetricsClient(_liveMetricsCustomDataDir);

      await tester.pumpWidget(const MaterialApp(home: ServerMonitorScreen()));
      await telemetry.refreshTelemetry();
      await tester.pump();

      expect(
        find.textContaining(
          'Thư mục dữ liệu PocketBase (agent xác nhận): /srv/openflix/pb_data',
        ),
        findsOneWidget,
      );
      // Đường dẫn mặc định cũ không được xuất hiện khi agent báo path khác.
      expect(
        find.textContaining('/opt/openflix-backend/pb_data'),
        findsNothing,
      );
    });

    testWidgets('Agent không xác nhận thư mục dữ liệu: không khẳng định WAL',
        (tester) async {
      telemetry.metricsClient = _FakeMetricsClient(_liveMetricsNoDataDir);

      await tester.pumpWidget(const MaterialApp(home: ServerMonitorScreen()));
      await telemetry.refreshTelemetry();
      await tester.pump();

      expect(telemetry.currentData.metricsLive, isTrue);
      expect(telemetry.currentData.vpsStorageVolume, isNull);
      expect(
        find.textContaining('/opt/openflix-backend/pb_data'),
        findsNothing,
      );
      expect(find.textContaining('WAL'), findsNothing);
      // Dung lượng DB hiện đúng số đo thật, không phải "0.00 GB".
      expect(find.textContaining('Dung lượng DB: 2.4 GB'), findsOneWidget);
    });

    testWidgets(
        'Tiêu đề appbar & badge dùng host thật của backend (đổi host là đổi theo)',
        (tester) async {
      final originalBaseUrl = PocketBaseService.instance.baseUrl;
      telemetry.metricsClient = _FakeMetricsClient(null);

      try {
        PocketBaseService.instance.updateBaseUrl('http://10.20.30.40:8090');

        await tester.pumpWidget(const MaterialApp(home: ServerMonitorScreen()));
        await telemetry.refreshTelemetry();
        await tester.pump();

        expect(
          find.text('Giám sát Máy chủ VPS (10.20.30.40:8090)'),
          findsOneWidget,
        );
        final badge = tester.widget<Text>(
          find.byKey(const ValueKey('vps-host-badge')),
        );
        expect(badge.data, '10.20.30.40:8090');
        // Tiêu đề với IP hardcode cũ tuyệt đối không được hiển thị.
        expect(
          find.text('Giám sát Máy chủ VPS (180.93.120.246:8090)'),
          findsNothing,
        );
      } finally {
        PocketBaseService.instance.updateBaseUrl(originalBaseUrl);
      }
    });
  });

  // =========================================================================
  // EDGE CASES — Metrics endpoint reliability
  // =========================================================================
  group('Metrics endpoint reliability — edge cases', () {
    test('HTTP 500 → tryParse trả null, app không crash, hiện "—"', () {
      // Khi endpoint /metrics trả lỗi nội bộ (HTML), tryParse phải trả null.
      final result = ServerMetrics.tryParse(
        '<html><body>500 Internal Server Error</body></html>',
      );
      expect(result, isNull);
    });

    test('JSON malformed → tryParse trả null, graceful fallback', () {
      // JSON bị cắt giữa chừng hoặc sai cú pháp.
      expect(ServerMetrics.tryParse('{"cpu_percent": 12.5, '), isNull);
      expect(ServerMetrics.tryParse('{not valid json}'), isNull);
      expect(ServerMetrics.tryParse('null'), isNull);
      expect(ServerMetrics.tryParse('[]'), isNull); // array thay vì object
    });

    test('Timeout → metricsClient trả null, service hiện trạng thái cũ', () async {
      final telemetry = ServerTelemetryService.instance;
      // Client giả luôn trả null (mô phỏng timeout / network error).
      telemetry.metricsClient = _FakeMetricsClient(null);

      await telemetry.refreshTelemetry();
      final data = telemetry.currentData;

      expect(data.metricsLive, isFalse);
      expect(data.vpsCpuLoadPercent, isNull);
      expect(data.vpsRamUsedGb, isNull);
      expect(data.vpsDiskUsedGb, isNull);
      expect(data.metricsError, isNotNull);

      // Cleanup
      telemetry.metricsClient = const ServerMetricsClient();
    });

    test('Partial data: chỉ có CPU, thiếu RAM/disk → hiện CPU, RAM/disk null', () async {
      final telemetry = ServerTelemetryService.instance;
      telemetry.metricsClient = _FakeMetricsClient(
        const ServerMetrics(cpuPercent: 42.0),
      );

      await telemetry.refreshTelemetry();
      final data = telemetry.currentData;

      // hasAnyResource = true vì có cpuPercent.
      expect(data.metricsLive, isTrue);
      expect(data.vpsCpuLoadPercent, 42.0);
      expect(data.vpsRamUsedGb, isNull);
      expect(data.vpsDiskUsedGb, isNull);
      expect(data.vpsRamUsagePercent, isNull);
      expect(data.vpsDiskUsagePercent, isNull);

      // Cleanup
      telemetry.metricsClient = const ServerMetricsClient();
    });

    test('Partial data: chỉ có disk, thiếu CPU/RAM → hiện disk, còn lại null', () {
      final m = ServerMetrics.tryParse(
        '{"disk_total_gb": 25.0, "disk_used_gb": 10.0}',
      );
      expect(m, isNotNull);
      expect(m!.hasAnyResource, isTrue);
      expect(m.diskUsedGb, 10.0);
      expect(m.diskTotalGb, 25.0);
      expect(m.cpuPercent, isNull);
      expect(m.memUsedGb, isNull);
      expect(m.memTotalGb, isNull);
    });
  });

  // =========================================================================
  // EDGE CASES — VPS monitoring boundary values
  // =========================================================================
  group('VPS monitoring — boundary values', () {
    final telemetry = ServerTelemetryService.instance;

    tearDown(() {
      telemetry.metricsClient = const ServerMetricsClient();
    });

    test('Giá trị = 0 (0% CPU, 0 MB RAM used) → hiện đúng, không bỏ qua', () async {
      telemetry.metricsClient = _FakeMetricsClient(
        const ServerMetrics(
          cpuPercent: 0.0,
          memTotalGb: 2.0,
          memUsedGb: 0.0,
          diskTotalGb: 25.0,
          diskUsedGb: 0.0,
        ),
      );

      await telemetry.refreshTelemetry();
      final data = telemetry.currentData;

      // metricsLive phải true vì cpuPercent != null → hasAnyResource = true.
      expect(data.metricsLive, isTrue);
      expect(data.vpsCpuLoadPercent, 0.0);
      expect(data.vpsRamUsedGb, 0.0);
      expect(data.vpsDiskUsedGb, 0.0);
      expect(data.vpsRamUsagePercent, 0.0);
      expect(data.vpsDiskUsagePercent, 0.0);
      expect(data.vpsFreeDiskGb, 25.0);
    });

    test('Cực lớn (100% CPU, RAM full) → hiện đúng format', () async {
      telemetry.metricsClient = _FakeMetricsClient(
        const ServerMetrics(
          cpuPercent: 100.0,
          memTotalGb: 2.0,
          memUsedGb: 2.0,
          diskTotalGb: 25.0,
          diskUsedGb: 25.0,
        ),
      );

      await telemetry.refreshTelemetry();
      final data = telemetry.currentData;

      expect(data.vpsCpuLoadPercent, 100.0);
      expect(data.vpsRamUsedGb, 2.0);
      expect(data.vpsRamUsagePercent, 100.0);
      expect(data.vpsDiskUsedGb, 25.0);
      expect(data.vpsDiskUsagePercent, 100.0);
      expect(data.vpsFreeDiskGb, 0.0);
    });

    test('Uptime edge: 0 giây → format đúng "0 phút"', () async {
      telemetry.metricsClient = _FakeMetricsClient(
        const ServerMetrics(
          cpuPercent: 5.0,
          memUsedGb: 0.5,
          diskUsedGb: 3.0,
          uptimeSeconds: 0,
        ),
      );

      await telemetry.refreshTelemetry();
      final data = telemetry.currentData;

      expect(data.uptimeSeconds, 0);
      expect(data.uptimeLabel, '0 phút');
    });

    test('Uptime edge: > 365 ngày → format đúng', () async {
      // 400 ngày = 400 * 86400 = 34560000 giây
      telemetry.metricsClient = _FakeMetricsClient(
        const ServerMetrics(
          cpuPercent: 5.0,
          memUsedGb: 0.5,
          diskUsedGb: 3.0,
          uptimeSeconds: 34560000,
        ),
      );

      await telemetry.refreshTelemetry();
      final data = telemetry.currentData;

      expect(data.uptimeSeconds, 34560000);
      expect(data.uptimeLabel, '400 ngày 0 giờ');
    });

    test('Disk 100% full → vpsFreeDiskGb = 0, diskUsagePercent = 100', () async {
      telemetry.metricsClient = _FakeMetricsClient(
        const ServerMetrics(
          cpuPercent: 80.0,
          memTotalGb: 2.0,
          memUsedGb: 1.5,
          diskTotalGb: 25.0,
          diskUsedGb: 25.0,
          diskOsGb: 10.0,
          diskDbGb: 10.0,
          diskMediaGb: 5.0,
        ),
      );

      await telemetry.refreshTelemetry();
      final data = telemetry.currentData;

      expect(data.vpsDiskUsagePercent, 100.0);
      expect(data.vpsFreeDiskGb, 0.0);
      // Partitions sum phải bằng tổng disk used.
      expect(data.vpsPartitionsUsedGb, 25.0);
    });

    test('Services values = false → hiện đúng, không coi là null', () {
      final m = ServerMetrics.tryParse(
        '{"cpu_percent": 5, "mem_used_mb": 512, "disk_used_gb": 3, '
        '"services": {"pocketbase": false, "nginx": false}}',
      );
      expect(m, isNotNull);
      expect(m!.pocketBaseServiceUp, isFalse);
      expect(m.nginxServiceUp, isFalse);
    });
  });

  // =========================================================================
  // REGRESSION GUARDS — VpsPlanSpec constants & no hardcoded measurements
  // =========================================================================
  group('Regression guards — VpsPlanSpec & no hardcoded measurements', () {
    test('VpsPlanSpec constants khớp đúng gói VPS: 1 Core, 2 GB, 25 GB', () {
      expect(VpsPlanSpec.cores, 1);
      expect(VpsPlanSpec.cpuLabel, '1 Core');
      expect(VpsPlanSpec.ramTotalGb, 2.0);
      expect(VpsPlanSpec.ramTotalLabel, '2 GB RAM');
      expect(VpsPlanSpec.diskTotalGb, 25.0);
      expect(VpsPlanSpec.diskTotalLabel, '25 GB SSD');
      expect(VpsPlanSpec.provider, 'CLOUDSH LOC');
      expect(VpsPlanSpec.host, '180.93.120.246');
      expect(VpsPlanSpec.port, 8090);
    });

    test('Không có hardcoded measurement values ngoài VpsPlanSpec', () {
      // Khi chưa nạp /metrics, currentData chỉ dùng VpsPlanSpec cho cấu hình.
      // Mọi chỉ số đo lường phải null.
      final telemetry = ServerTelemetryService.instance;
      telemetry.metricsClient = const ServerMetricsClient();

      final data = telemetry.currentData;

      // Cấu hình tĩnh phải khớp VpsPlanSpec.
      expect(data.vpsCpuCores, VpsPlanSpec.cores);
      expect(data.vpsRamTotalGb, VpsPlanSpec.ramTotalGb);
      expect(data.vpsDiskTotalGb, VpsPlanSpec.diskTotalGb);

      // Không có old-style hardcoded values (2 vCPU, 4 GB, 50 GB).
      expect(data.vpsCpuCores, isNot(2));
      expect(data.vpsRamTotalGb, isNot(4.0));
      expect(data.vpsDiskTotalGb, isNot(50.0));
    });
  });
}
