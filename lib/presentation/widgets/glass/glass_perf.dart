import 'package:flutter/foundation.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

/// Bộ điều tiết hạng chất lượng kính mờ theo năng lực thiết bị.
///
/// ## Vì sao cần
///
/// `GlassQuality.premium` dùng pipeline shader đầy đủ của `liquid_glass_widgets`
/// (khúc xạ + tán sắc + texture capture). Theo tài liệu của chính package, hạng
/// này chỉ nên dùng cho **bề mặt tĩnh, tiêu điểm** trên máy tầm iPhone 13/A15
/// hoặc Pixel 6 trở lên. Mỗi khung hình, mỗi bề mặt premium phải đọc lại
/// backdrop (nền sóng động cập nhật ~30 fps) rồi chạy vài lượt shader — nên chỉ
/// cần 6–10 chip/nút kính trên màn hình là GPU mobile vượt ngân sách khung
/// hình, đúng hiện tượng giật khi cuộn trang chủ.
///
/// Hạng [GlassQuality.standard] vẫn là kính khúc xạ thật (shader nhẹ, nhanh
/// hơn 5–10 lần BackdropFilter và nhanh hơn nhiều so với premium), nên hình
/// ảnh kính mờ — viền vát hairline, phản quang vòm cầu, độ bẻ cong nền — vẫn
/// giữ nguyên; chỉ bỏ bớt tán sắc quang sai rất nhỏ mà ở kích thước chip 34 px
/// gần như không nhìn thấy.
///
/// ## Phân cấp
///
/// * [surface] — mặc định cho mọi `GlassSurface`: mobile dùng `standard`,
///   desktop/web dùng `premium` (PC dư GPU, giữ nguyên 100% thẩm mỹ cũ).
/// * [focal]   — bề mặt tiêu điểm (thanh điều hướng, menu/sheet/dialog, nút
///   play của player): luôn `premium` trên mọi nền tảng.
///
/// Có thể ghim cứng hạng chất lượng qua [debugOverride] (dùng cho test hoặc
/// cho một màn cài đặt "hiệu ứng cao" sau này).
class GlassPerf {
  GlassPerf._();

  /// Ghim cứng hạng chất lượng — chỉ dùng cho test/kiểm thử thủ công.
  @visibleForTesting
  static GlassQuality? debugOverride;

  /// Thiết bị di động (Android/iOS) — nơi ngân sách GPU khung hình eo hẹp nhất.
  static bool get isMobileDevice {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  /// Hạng chất lượng mặc định cho bề mặt kính thông thường.
  static GlassQuality get surface {
    final override = debugOverride;
    if (override != null) return override;
    return isMobileDevice ? GlassQuality.standard : GlassQuality.premium;
  }

  /// Hạng chất lượng cho bề mặt tiêu điểm, luôn cần độ chân thực cao nhất.
  static GlassQuality get focal => debugOverride ?? GlassQuality.premium;

  /// Hạng chất lượng cho "chrome" cố định phủ lên nội dung cuộn (thanh điều
  /// hướng nổi, thanh công cụ media).
  ///
  /// Những bề mặt này nằm yên nhưng backdrop bên dưới luôn đổi (nội dung
  /// cuộn + nền động), nên shader phải chạy lại mỗi khung hình. Trên mobile
  /// chúng dùng hạng shader nhẹ — vẫn khúc xạ nền theo Snell, vẫn giữ viền
  /// vát hairline và phản quang vòm cầu của [GlassSurface], chỉ bỏ tán sắc
  /// quang sai rất nhỏ. Desktop giữ nguyên premium.
  static GlassQuality get overlayChrome => surface;

  /// `true` khi thiết bị đang dùng shader nhẹ — dùng để quyết định có nên
  /// thêm hiệu ứng phụ (glow, shimmer…) hay không.
  static bool get isLightweight => surface != GlassQuality.premium;
}
