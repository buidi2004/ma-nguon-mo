import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Các chế độ phối màu chủ đạo trong ứng dụng OpenFlix.
enum AppThemeMode {
  /// Đỏ Netflix kinh điển (Mặc định).
  netflixRed,

  /// Xanh tươi sáng (#00A2ED) & Trắng vi mô.
  windowsBlue,

  /// Vàng Hoàng Gia Luxury (#D4AF37) & Lụa Đen Bông Hoa Vàng.
  luxuryGold,
}

/// Dịch vụ quản lý chủ đề màu sắc hệ thống OpenFlix.
/// Hỗ trợ chuyển đổi linh hoạt giữa:
/// - Đỏ Netflix kinh điển (Đỏ & Đen mặc định)
/// - Xanh Cyan (#00A2ED & Trắng)
/// Tự động lưu lựa chọn vào SharedPreferences và đồng bộ toàn app.
class ThemeService extends ChangeNotifier {
  static final ThemeService instance = ThemeService._internal();
  static const _key = 'app_theme_mode';

  ThemeService._internal() {
    _load();
  }

  AppThemeMode _mode = AppThemeMode.netflixRed;

  /// Chế độ chủ đề hiện tại.
  AppThemeMode get mode => _mode;
  AppThemeMode get currentMode => _mode;

  /// Đang dùng chế độ Xanh (#00A2ED).
  bool get isWindowsBlue => _mode == AppThemeMode.windowsBlue;

  /// Đang dùng chế độ Đỏ Netflix (mặc định).
  bool get isNetflixRed => _mode == AppThemeMode.netflixRed;

  /// Đang dùng chế độ Vàng Hoàng Gia Luxury (Dark Luxury).
  bool get isLuxuryGold => _mode == AppThemeMode.luxuryGold;
  bool get isDarkLuxuryGold => isLuxuryGold;

  /// Giá trị uniform truyền vào Silk Shader: 0.0 (Đỏ) hoặc 1.0 (Xanh #00A2ED).
  double get shaderThemeValue => isWindowsBlue ? 1.0 : 0.0;

  /// Màu chủ đạo chính của ứng dụng (#00A2ED khi chọn xanh, #D4AF37 khi chọn vàng luxury, #E50914 khi chọn đỏ).
  Color get primaryColor => isWindowsBlue
      ? const Color(0xFF00A2ED)
      : isLuxuryGold
          ? const Color(0xFFD4AF37)
          : const Color(0xFFE50914);

  /// Màu phụ vi mô (hào quang / gradient phụ).
  Color get accentColor => isWindowsBlue
      ? const Color(0xFF66C7F4)
      : isLuxuryGold
          ? const Color(0xFFF1D48B)
          : const Color(0xFFB20710);

  /// Nền ứng dụng: Đen sâu (#0B0F17) khi theme Xanh Đen, Đen lụa sang trọng (#060504) khi theme Vàng, Đen điện ảnh (#141414) khi theme Đỏ.
  Color get backgroundColor => isWindowsBlue
      ? const Color(0xFF0B0F17)
      : isLuxuryGold
          ? const Color(0xFF060504)
          : const Color(0xFF141414);

  /// Màu nền cho Scaffold khi kết hợp với nền động (WavesBackground hoặc DarkLuxuryBackground).
  Color get scaffoldBackgroundColor =>
      (isWindowsBlue || isLuxuryGold) ? Colors.transparent : const Color(0xFF141414);

  /// Màu nền bề mặt (Surface): Đen xám xanh (#161F2E) khi theme Xanh Đen, Đen nâu ấm (#18140E) khi theme Vàng, Đen xám (#2A2A2A) khi theme Đỏ.
  Color get surfaceColor => isWindowsBlue
      ? const Color(0xFF161F2E)
      : isLuxuryGold
          ? const Color(0xFF18140E)
          : const Color(0xFF2A2A2A);

  /// Màu nền bề mặt sáng (Surface Light): (#1E293B) khi theme Xanh Đen, (#261F17) khi theme Vàng, (#333333) khi theme Đỏ.
  Color get surfaceLightColor => isWindowsBlue
      ? const Color(0xFF1E293B)
      : isLuxuryGold
          ? const Color(0xFF261F17)
          : const Color(0xFF333333);

  /// Màu nền thẻ phim (Card): (#111827) khi theme Xanh Đen, (#14100B) khi theme Vàng, Đen (#1E1E1E) khi theme Đỏ.
  Color get cardColor => isWindowsBlue
      ? const Color(0xFF111827)
      : isLuxuryGold
          ? const Color(0xFF14100B)
          : const Color(0xFF1E1E1E);

  /// Màu chữ chính: Luôn là trắng sáng (#FFFFFF) trên nền đen điện ảnh.
  Color get textPrimary => const Color(0xFFFFFFFF);

  /// Màu chữ phụ: Xám sáng (#94A3B8) khi theme Xanh Đen, Ánh cát vàng (#D8C7A5) khi theme Vàng, Xám (#B3B3B3) khi theme Đỏ.
  Color get textSecondary => isWindowsBlue
      ? const Color(0xFF94A3B8)
      : isLuxuryGold
          ? const Color(0xFFD8C7A5)
          : const Color(0xFFB3B3B3);

  /// Màu chữ mờ: (#64748B) khi theme Xanh Đen, (#8A7A65) khi theme Vàng, (#808080) khi theme Đỏ.
  Color get textMuted => isWindowsBlue
      ? const Color(0xFF64748B)
      : isLuxuryGold
          ? const Color(0xFF8A7A65)
          : const Color(0xFF808080);

  /// Đường kẻ phân cách: (#1E293B) khi theme Xanh Đen, Ánh vàng (#33B98A3A) khi theme Vàng, (#2A2A2A) khi theme Đỏ.
  Color get dividerColor => isWindowsBlue
      ? const Color(0xFF1E293B)
      : isLuxuryGold
          ? const Color(0x33B98A3A)
          : const Color(0xFF2A2A2A);

  /// Kiểm tra có đang ở giao diện nền sáng không (cả 3 đều là dark cinema).
  bool get isLight => false;

  /// Tên hiển thị người dùng.
  String get name => isWindowsBlue
      ? 'Xanh Đen Điện Ảnh (#00A2ED)'
      : isLuxuryGold
          ? 'Vàng Hoàng Gia Luxury (#D4AF37)'
          : 'Đỏ Netflix (Mặc định)';

  /// Mô tả ngắn về phối màu.
  String get description => isWindowsBlue
      ? 'Phong cách Xanh (#00A2ED) kết hợp nền sóng biển Waves Shader động'
      : isLuxuryGold
          ? 'Phong cách Dark Luxury (Lụa đen, hoa viền vàng và bụi vàng lấp lánh)'
          : 'Phong cách Dark Cinema nguyên bản Netflix (Đỏ & Đen)';

  /// Khởi tạo và nạp chủ đề đã lưu trước đó.
  Future<void> init() async => await _load();

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final val = prefs.getString(_key);
      if (val == 'windowsBlue' || val == 'blue') {
        _mode = AppThemeMode.windowsBlue;
      } else if (val == 'luxuryGold' || val == 'gold' || val == 'darkLuxury') {
        _mode = AppThemeMode.luxuryGold;
      } else {
        _mode = AppThemeMode.netflixRed;
      }
      notifyListeners();
    } catch (_) {}
  }

  /// Cập nhật chế độ chủ đề và lưu trữ dài hạn.
  Future<void> setThemeMode(AppThemeMode mode) async {
    if (_mode == mode) return;
    _mode = mode;
    notifyListeners();
    try {
      SharedPreferences.getInstance().then((prefs) {
        prefs.setString(
          _key,
          mode == AppThemeMode.windowsBlue
              ? 'windowsBlue'
              : mode == AppThemeMode.luxuryGold
                  ? 'luxuryGold'
                  : 'netflixRed',
        );
      }).catchError((_) {});
    } catch (_) {}
  }

  /// Chuyển đổi nhanh qua lại giữa Đỏ Netflix và Xanh #00A2ED.
  Future<void> toggleTheme() async {
    final next = isWindowsBlue
        ? AppThemeMode.netflixRed
        : AppThemeMode.windowsBlue;
    await setThemeMode(next);
  }
}
