import 'package:flutter/foundation.dart';

class AdminAuthService extends ChangeNotifier {
  static final AdminAuthService instance = AdminAuthService._internal();
  AdminAuthService._internal();

  static const String defaultPassword = '123';
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;

  /// Xác thực mật khẩu quản trị viên
  Future<bool> authenticate(String inputPassword) async {
    // Trì hoãn nhẹ 250ms chống brute-force và tạo cảm giác kiểm tra bảo mật
    await Future.delayed(const Duration(milliseconds: 250));
    if (inputPassword.trim() == defaultPassword) {
      _isAuthenticated = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Khóa phiên làm việc quản trị
  void logout() {
    _isAuthenticated = false;
    notifyListeners();
  }
}
