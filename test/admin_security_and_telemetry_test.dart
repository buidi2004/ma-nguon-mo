import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openflix/features/admin/admin_auth_gate_screen.dart';
import 'package:openflix/features/admin/server_monitor_screen.dart';
import 'package:openflix/features/admin/services/admin_auth_service.dart';
import 'package:openflix/features/admin/services/server_telemetry_service.dart';

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

    test('currentData chứa đầy đủ thông số cấu hình VPS thực tế', () {
      final data = telemetry.currentData;
      expect(data.vpsHost, equals('180.93.120.246:8090'));
      expect(data.vpsCpu, contains('vCPU'));
      expect(data.vpsRamTotal, contains('RAM'));
      expect(data.vpsStorageTotal, contains('SSD'));
      expect(data.vpsOs, contains('Ubuntu'));
      expect(data.serverSoftware, contains('nginx'));
      expect(data.totalMoviesInDb, greaterThan(0));
      expect(data.pingMs, greaterThanOrEqualTo(0));
      expect(data.pingHistory, isNotEmpty);
      expect(data.scanLogs, isNotEmpty);
    });

    test('cleanMemoryCache giải phóng bộ nhớ RAM và trả về dung lượng thực', () async {
      final freed = await telemetry.cleanMemoryCache();
      expect(freed, greaterThan(0.0));
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
      expect(find.text('Giám sát Máy chủ VPS (180.93.120.246)'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);

      // Verify VPS hardware configuration cards
      expect(find.text('Cấu hình Phần cứng Máy chủ VPS Linux'), findsOneWidget);
      expect(find.text('Vi xử lý VPS'), findsOneWidget);
      expect(find.text('Bộ nhớ RAM VPS'), findsOneWidget);
      expect(find.text('Ổ cứng SSD VPS'), findsOneWidget);
      expect(find.text('Cơ sở Dữ liệu'), findsOneWidget);

      // Verify Live Scanner console
      expect(find.text('Nhật ký Quét Cấu hình VPS Trực tiếp'), findsOneWidget);
      expect(find.text('Quét Ngay'), findsOneWidget);

      // Verify custom painter
      expect(find.byType(CustomPaint), findsWidgets);
    });
  });
}
