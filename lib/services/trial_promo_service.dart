import 'package:shared_preferences/shared_preferences.dart';

/// Dịch vụ quản lý tần suất và trạng thái hiển thị của Pop-up dùng thử VIP (Trial Promo).
///
/// Đảm bảo không spam người dùng, tuân thủ nguyên tắc UX của OpenFlix:
/// - Tối đa hiển thị 1 lần / ngày hoặc 1 lần / phiên làm việc.
/// - Ghi nhớ khi người dùng đã đóng hoặc đã bấm tham gia.
class TrialPromoService {
  static final TrialPromoService instance = TrialPromoService._internal();
  TrialPromoService._internal();

  static const String _prefKeyLastShown = 'trial_promo_last_shown_date';
  static const String _prefKeyNeverShowAgain = 'trial_promo_never_show_again';

  bool _sessionDismissed = false;

  /// Kiểm tra xem có nên hiển thị pop-up dùng thử khi người dùng vào Trang chủ hay không.
  Future<bool> shouldShowPromo() async {
    if (_sessionDismissed) return false;

    try {
      final prefs = await SharedPreferences.getInstance();

      // Nếu người dùng đã chọn không nhắc lại
      final neverShow = prefs.getBool(_prefKeyNeverShowAgain) ?? false;
      if (neverShow) return false;

      final lastDateStr = prefs.getString(_prefKeyLastShown);
      if (lastDateStr == null) return true;

      final lastDate = DateTime.tryParse(lastDateStr);
      if (lastDate == null) return true;

      final now = DateTime.now();
      // Nếu đã hiển thị trong cùng ngày thì không hiển thị lại
      final isSameDay = now.year == lastDate.year &&
          now.month == lastDate.month &&
          now.day == lastDate.day;

      return !isSameDay;
    } catch (_) {
      // Fallback an toàn nếu lỗi storage: chỉ chặn trong phiên hiện tại
      return !_sessionDismissed;
    }
  }

  /// Đánh dấu đã đóng pop-up trong phiên hiện tại hoặc lưu theo ngày.
  Future<void> markDismissed({bool neverShowAgain = false}) async {
    _sessionDismissed = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKeyLastShown, DateTime.now().toIso8601String());
      if (neverShowAgain) {
        await prefs.setBool(_prefKeyNeverShowAgain, true);
      }
    } catch (_) {}
  }

  /// Reset cờ phiên (phục vụ testing hoặc gỡ lỗi).
  void resetSession() {
    _sessionDismissed = false;
  }
}
