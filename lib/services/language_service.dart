import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// S35 — Lưu lựa chọn ngôn ngữ hiển thị (vi / en).
/// Tự viết bảng chuỗi thay cho ARB để nhanh, đúng kế hoạch G5.
class LanguageService extends ChangeNotifier {
  static final LanguageService instance = LanguageService._internal();
  static const _key = 'app_locale';

  LanguageService._internal() {
    _load();
  }

  String _code = 'vi';
  String get code => _code;
  bool get isVietnamese => _code == 'vi';

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _code = prefs.getString(_key) ?? 'vi';
      notifyListeners();
    } catch (e) {
      debugPrint('Lỗi tải ngôn ngữ: $e');
    }
  }

  Future<void> setLocale(String code) async {
    if (code != 'vi' && code != 'en') return;
    _code = code;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, code);
    } catch (e) {
      debugPrint('Lỗi lưu ngôn ngữ: $e');
    }
    notifyListeners();
  }

  /// Bảng chuỗi mẫu dùng để preview trong S35.
  String t(String key) => _strings[_code]?[key] ?? _strings['vi']![key] ?? key;

  static const Map<String, Map<String, String>> _strings = {
    'vi': {
      'home': 'Trang chủ',
      'search': 'Tìm kiếm',
      'my_list': 'Danh sách của tôi',
      'play': 'Phát',
      'settings': 'Cài đặt',
      'hello': 'Xin chào, bạn muốn xem gì tối nay?',
    },
    'en': {
      'home': 'Home',
      'search': 'Search',
      'my_list': 'My List',
      'play': 'Play',
      'settings': 'Settings',
      'hello': 'Hi, what do you want to watch tonight?',
    },
  };
}
