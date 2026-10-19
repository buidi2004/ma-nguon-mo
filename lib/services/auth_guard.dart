import 'package:flutter/material.dart';

import '../presentation/widgets/dialogs/auth_required_dialog.dart';
import 'auth_service.dart';

/// Lớp bảo vệ xác thực tập trung cho OpenFlix.
///
/// Quản lý phân quyền giữa người dùng đã đăng nhập và khách vãng lai:
/// - Khách vẫn được trải nghiệm toàn bộ app, duyệt danh mục, đọc thông tin chi tiết và xem Trailer.
/// - Khi thực hiện hành động yêu cầu đăng nhập (ví dụ: phát phim chính, xem trọn bộ tập),
///   [runWithAuth] sẽ chặn lại và hiển thị [AuthRequiredDialog] kèm thông báo thân thiện.
class AuthGuard {
  /// Kiểm tra trạng thái đăng nhập trước khi thực thi hành động xem phim.
  ///
  /// - Nếu đã đăng nhập: Chạy [onAuthorized] ngay lập tức.
  /// - Nếu chưa đăng nhập: Hiển thị Pop-up chuẩn Netflix Dark Cinema yêu cầu đăng nhập.
  ///   Người dùng có thể chọn đăng nhập (kèm redirect về phim), xem Trailer thay thế hoặc bỏ qua.
  static void runWithAuth(
    BuildContext context, {
    required VoidCallback onAuthorized,
    String? movieId,
    String? movieTitle,
    bool hasTrailer = true,
    VoidCallback? onWatchTrailer,
  }) {
    final bool isLoggedIn = AuthService.instance.isLoggedIn;

    if (isLoggedIn) {
      onAuthorized();
      return;
    }

    // Hiển thị Pop-up chặn khách và gợi ý đăng nhập / xem trailer
    AuthRequiredDialog.show(
      context,
      movieId: movieId,
      movieTitle: movieTitle,
      hasTrailer: hasTrailer,
      onWatchTrailer: onWatchTrailer,
    );
  }
}
