import 'dart:convert';

import 'package:http/http.dart' as http;

/// Số liệu **đo được thật** từ endpoint `/metrics` của VPS.
///
/// Mọi trường đều nullable: `null` = máy chủ không cung cấp chỉ số đó.
/// Không bao giờ suy diễn hay điền giá trị mặc định vào đây.
class ServerMetrics {
  final DateTime? generatedAt;

  // CPU
  final double? cpuPercent;
  final double? load1;
  final int? cores;

  // RAM
  final double? memTotalGb;
  final double? memUsedGb;

  // Ổ cứng
  final double? diskTotalGb;
  final double? diskUsedGb;
  final double? diskOsGb;
  final double? diskDbGb;
  final double? diskMediaGb;

  // Hệ thống
  final int? uptimeSeconds;
  final String? kernel;
  final String? arch;
  final String? osPretty;
  final String? dockerVersion;
  final String? pocketBaseVersion;
  /// Thư mục dữ liệu PocketBase mà agent xác nhận là tồn tại trên máy chủ.
  final String? dataDir;

  // Trạng thái dịch vụ (theo agent trên máy chủ)
  final bool? pocketBaseServiceUp;
  final bool? nginxServiceUp;

  const ServerMetrics({
    this.generatedAt,
    this.cpuPercent,
    this.load1,
    this.cores,
    this.memTotalGb,
    this.memUsedGb,
    this.diskTotalGb,
    this.diskUsedGb,
    this.diskOsGb,
    this.diskDbGb,
    this.diskMediaGb,
    this.uptimeSeconds,
    this.kernel,
    this.arch,
    this.osPretty,
    this.dockerVersion,
    this.pocketBaseVersion,
    this.dataDir,
    this.pocketBaseServiceUp,
    this.nginxServiceUp,
  });

  /// Có ít nhất một chỉ số tài nguyên dùng được.
  bool get hasAnyResource =>
      cpuPercent != null ||
      memUsedGb != null ||
      diskUsedGb != null;

  factory ServerMetrics.fromJson(Map<dynamic, dynamic> json) {
    final services = json['services'];
    final servicesMap = services is Map ? services : const <String, dynamic>{};

    return ServerMetrics(
      generatedAt: _asDate(json['generated_at']),
      cpuPercent: _asDouble(json['cpu_percent']),
      load1: _asDouble(json['load1']),
      cores: _asInt(json['cores']),
      memTotalGb: _mbToGb(_asDouble(json['mem_total_mb'])),
      memUsedGb: _mbToGb(_asDouble(json['mem_used_mb'])),
      diskTotalGb: _asDouble(json['disk_total_gb']),
      diskUsedGb: _asDouble(json['disk_used_gb']),
      diskOsGb: _asDouble(json['disk_os_gb']),
      diskDbGb: _asDouble(json['disk_db_gb']),
      diskMediaGb: _asDouble(json['disk_media_gb']),
      uptimeSeconds: _asInt(json['uptime_s']),
      kernel: _asString(json['kernel']),
      arch: _asString(json['arch']),
      osPretty: _asString(json['os_pretty']),
      dockerVersion: _asString(json['docker_version']),
      pocketBaseVersion: _asString(json['pocketbase_version']),
      dataDir: _asString(json['data_dir']),
      pocketBaseServiceUp: _asBool(servicesMap['pocketbase']),
      nginxServiceUp: _asBool(servicesMap['nginx']),
    );
  }

  /// Parse an toàn: trả `null` nếu body không phải JSON object hợp lệ.
  static ServerMetrics? tryParse(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is! Map) return null;
      return ServerMetrics.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  static double? _asDouble(Object? value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value.trim());
    return null;
  }

  static int? _asInt(Object? value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      final parsed = double.tryParse(value.trim());
      return parsed?.toInt();
    }
    return null;
  }

  static bool? _asBool(Object? value) {
    if (value is bool) return value;
    if (value is String) {
      final v = value.trim().toLowerCase();
      if (v == 'true') return true;
      if (v == 'false') return false;
    }
    return null;
  }

  static String? _asString(Object? value) {
    if (value == null) return null;
    final text = value.toString().trim();
    if (text.isEmpty || text.toLowerCase() == 'null') return null;
    return text;
  }

  static DateTime? _asDate(Object? value) {
    final text = _asString(value);
    if (text == null) return null;
    return DateTime.tryParse(text)?.toUtc();
  }

  static double? _mbToGb(double? mb) => mb == null ? null : mb / 1024.0;
}

/// Gọi endpoint `/metrics` trên VPS.
///
/// Tách riêng để có thể thay bằng bản giả trong test (không cần mạng thật).
class ServerMetricsClient {
  const ServerMetricsClient();

  Future<ServerMetrics?> fetch({
    required Uri uri,
    String? token,
    Duration timeout = const Duration(milliseconds: 2500),
  }) async {
    try {
      final res = await http
          .get(
            uri,
            headers: (token == null || token.isEmpty)
                ? null
                : {'X-Metrics-Token': token},
          )
          .timeout(timeout);
      if (res.statusCode != 200) return null;
      return ServerMetrics.tryParse(res.body);
    } catch (_) {
      return null;
    }
  }
}
