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

  bool get isLoggedIn => _isLoggedIn;
  String get userName => _userName;
  String get userEmail => _userEmail;
  String get userId => _userId;

  Future<void> _loadSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isLoggedIn = prefs.getBool('auth_logged_in') ?? false;
      _userName = prefs.getString('auth_user_name') ?? 'Khách Demo';
      _userEmail = prefs.getString('auth_user_email') ?? 'demo@openflix.vn';
      _userId = prefs.getString('auth_user_id') ?? 'user_demo_1';
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

  Future<bool> changePassword(String oldPassword, String newPassword) async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (newPassword.length < 6) return false;
    return true;
  }
}
