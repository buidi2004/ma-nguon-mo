import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends ChangeNotifier {
  static final AuthService instance = AuthService._internal();

  AuthService._internal() {
    _loadSession();
  }

  bool _isLoggedIn = false;
  String _userName = 'Khách Demo';
  String _userEmail = 'demo@openflix.vn';
  String _userId = 'user_demo_1';
  String _avatarType = 'preset'; // 'preset', 'emoji', 'url'
  String _avatarValue = '🐼'; // Mặc định Gấu trúc Panda như ảnh người dùng
  int _avatarBgColor = 0xFF7C83FD; // Màu nền tím nhạt phát sáng

  bool get isLoggedIn => _isLoggedIn;
  String get userName => _userName;
  String get userEmail => _userEmail;
  String get userId => _userId;
  String get avatarType => _avatarType;
  String get avatarValue => _avatarValue;
  int get avatarBgColor => _avatarBgColor;

  Future<void> _loadSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isLoggedIn = prefs.getBool('auth_logged_in') ?? false;
      _userName = prefs.getString('auth_user_name') ?? 'Khách Demo';
      _userEmail = prefs.getString('auth_user_email') ?? 'demo@openflix.vn';
      _userId = prefs.getString('auth_user_id') ?? 'user_demo_1';
      _avatarType = prefs.getString('auth_avatar_type') ?? 'preset';
      _avatarValue = prefs.getString('auth_avatar_val') ?? '🐼';
      _avatarBgColor = prefs.getInt('auth_avatar_bg') ?? 0xFF7C83FD;
      notifyListeners();
    } catch (e) {
      debugPrint('Lỗi tải phiên đăng nhập: $e');
    }
  }

  Future<bool> login(String email, String password) async {
    // Giả lập hoặc xác thực PocketBase
    await Future.delayed(const Duration(milliseconds: 700));

    if (password.length < 6) {
      return false;
    }

    _isLoggedIn = true;
    _userEmail = email;
    _userName = email.split('@').first.toUpperCase();
    _userId = 'usr_${email.hashCode.abs()}';

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auth_logged_in', true);
    await prefs.setString('auth_user_email', _userEmail);
    await prefs.setString('auth_user_name', _userName);
    await prefs.setString('auth_user_id', _userId);

    notifyListeners();
    return true;
  }

  Future<bool> register(String name, String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 800));

    if (password.length < 6 || email.isEmpty || name.isEmpty) {
      return false;
    }

    _isLoggedIn = true;
    _userName = name;
    _userEmail = email;
    _userId = 'usr_${email.hashCode.abs()}';

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auth_logged_in', true);
    await prefs.setString('auth_user_email', _userEmail);
    await prefs.setString('auth_user_name', _userName);
    await prefs.setString('auth_user_id', _userId);

    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    _userName = 'Khách Demo';
    _userEmail = 'demo@openflix.vn';

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auth_logged_in', false);
    await prefs.remove('auth_user_email');
    await prefs.remove('auth_user_name');
    await prefs.remove('auth_user_id');

    notifyListeners();
  }

  Future<void> updateProfile(String newName) async {
    _userName = newName;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_user_name', newName);
    notifyListeners();
  }

  Future<void> updateAvatar({
    required String type,
    required String value,
    int? bgColor,
  }) async {
    _avatarType = type;
    _avatarValue = value;
    if (bgColor != null) _avatarBgColor = bgColor;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_avatar_type', _avatarType);
    await prefs.setString('auth_avatar_val', _avatarValue);
    await prefs.setInt('auth_avatar_bg', _avatarBgColor);

    notifyListeners();
  }

  Future<void> removeAvatar() async {
    _avatarType = 'preset';
    _avatarValue = '🐼';
    _avatarBgColor = 0xFF7C83FD;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_avatar_type');
    await prefs.remove('auth_avatar_val');
    await prefs.remove('auth_avatar_bg');

    notifyListeners();
  }

  Future<bool> changePassword(String oldPassword, String newPassword) async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (newPassword.length < 6) return false;
    return true;
  }
}
