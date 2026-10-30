import 'package:flutter/material.dart';

/// Thang chữ chuẩn Apple iOS (Dynamic Type, cỡ "Large" mặc định) quy đổi sang
/// Flutter TextStyles. Nguồn: HIG Typography › Specifications (iOS Dynamic Type
/// sizes, Large). Font hệ thống: Flutter tự dùng San Francisco trên iOS và
/// Roboto trên Android, không nhúng font hệ thống.
///
/// Trên iOS, TextTheme của Material tự phản hồi textScaler (Dynamic Type);
/// chỉ cần mọi Text dùng style từ đây thay vì fontSize rời rạc.
abstract final class AppTypography {
  // Leading (height) lấy từ bảng HIG: leading/size.
  static const largeTitle = TextStyle(
    fontSize: 34,
    height: 41 / 34,
    letterSpacing: 0.40, // tracking +12/1000 em @34pt
    fontWeight: FontWeight.w400,
  );

  static const title1 = TextStyle(
    fontSize: 28,
    height: 34 / 28,
    letterSpacing: 0.38, // +14/1000 em @28pt
    fontWeight: FontWeight.w400,
  );

  static const title2 = TextStyle(
    fontSize: 22,
    height: 28 / 22,
    letterSpacing: -0.26, // -12/1000 em @22pt
    fontWeight: FontWeight.w400,
  );

  static const title3 = TextStyle(
    fontSize: 20,
    height: 25 / 20,
    letterSpacing: -0.46, // -23/1000 em @20pt
    fontWeight: FontWeight.w400,
  );

  /// Headline: Semibold 17 — tiêu đề hàng, tiêu đề mục.
  static const headline = TextStyle(
    fontSize: 17,
    height: 22 / 17,
    letterSpacing: -0.43, // -26/1000 em @17pt
    fontWeight: FontWeight.w600,
  );

  /// Body: Regular 17 — cỡ mặc định cho nội dung đọc được.
  static const body = TextStyle(
    fontSize: 17,
    height: 22 / 17,
    letterSpacing: -0.43,
    fontWeight: FontWeight.w400,
  );

  static const callout = TextStyle(
    fontSize: 16,
    height: 21 / 16,
    letterSpacing: -0.31, // -20/1000 em @16pt
    fontWeight: FontWeight.w400,
  );

  static const subhead = TextStyle(
    fontSize: 15,
    height: 20 / 15,
    letterSpacing: -0.23, // -16/1000 em @15pt
    fontWeight: FontWeight.w400,
  );

  static const footnote = TextStyle(
    fontSize: 13,
    height: 18 / 13,
    letterSpacing: -0.08, // -6/1000 em @13pt
    fontWeight: FontWeight.w400,
  );

  static const caption1 = TextStyle(
    fontSize: 12,
    height: 16 / 12,
    letterSpacing: 0,
    fontWeight: FontWeight.w400,
  );

  /// Cỡ nhỏ nhất cho phép trên mobile (HIG: minimum 11pt).
  static const caption2 = TextStyle(
    fontSize: 11,
    height: 13 / 11,
    letterSpacing: 0.06, // +6/1000 em @11pt
    fontWeight: FontWeight.w400,
  );

  /// Áp thang chữ vào TextTheme của Material. Màu được truyền riêng để dùng
  /// cho cả theme sáng và tối.
  static TextTheme applyTo(TextTheme base, Color primaryText) => base.copyWith(
    displayLarge: largeTitle,
    displayMedium: title1,
    displaySmall: title2,
    headlineMedium: title3,
    headlineSmall: headline,
    titleLarge: headline.copyWith(fontWeight: FontWeight.w600),
    titleMedium: body.copyWith(fontWeight: FontWeight.w600),
    titleSmall: callout.copyWith(fontWeight: FontWeight.w600),
    bodyLarge: body,
    bodyMedium: callout,
    bodySmall: footnote,
    labelLarge: subhead.copyWith(fontWeight: FontWeight.w600),
    labelMedium: footnote,
    labelSmall: caption2,
  ).apply(bodyColor: primaryText, displayColor: primaryText);
}
