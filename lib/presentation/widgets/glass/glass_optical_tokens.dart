import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

/// Bộ thông số quang học tập trung (Design Tokens) cho các thành phần kính mờ OpenFlix.
/// Cung cấp cấu hình khúc xạ quang học theo định luật Snell (Snell's Law)
/// với độ trong suốt pha lê, viền vát siêu mảnh (Hairline Rim) và tán sắc nhẹ.
class GlassOpticalTokens {
  GlassOpticalTokens._();

  // ==========================================
  // THÔNG SỐ QUANG HỌC NÚT BẤM (BUTTON TOKENS)
  // ==========================================
  /// Khúc xạ cao cho nút bấm nhỏ gọn để bẻ cong viền rõ rệt (~1.82)
  static const double buttonRefractiveIndex = 1.82;
  static const double buttonThickness = 56.0;
  static const double buttonBlur = 8.5;
  static const Color buttonTint = Color(0x18FFFFFF);
  static const double buttonChromaticAberration = 0.04;
  static const double buttonAmbientStrength = 0.22;
  static const double buttonFresnelStrength = 1.65;
  static const double buttonSaturation = 1.35;
  static const double buttonLightIntensity = 1.25;

  // ==========================================
  // QUY CHUẨN QUANG HỌC TỪNG THÀNH PHẦN (STAGES 1 - 4)
  // ==========================================
  // 1. GlassActionButton (56 x 48 px)
  static const double actionButtonWidth = 56.0;
  static const double actionButtonHeight = 48.0;
  static const double actionButtonBlur = 12.0;
  static const double actionButtonSnell = 1.35;
  static const double actionButtonRadius = 10.0;
  static const Color actionButtonRim = Color(
    0x1FFFFFFF,
  ); // rgba(255,255,255, 0.12)

  // 2. GlassChipButton (34 px Capsule)
  static const double chipButtonHeight = 34.0;
  static const double chipButtonBlur = 8.0;
  static const double chipButtonSnell = 1.25;
  static const double chipButtonRadius = 17.0;
  static const Color chipButtonRim = Color(
    0x26FFFFFF,
  ); // rgba(255,255,255, 0.15)

  // 3. GlassDestructiveButton (44-48 px)
  static const double destructiveButtonHeight = 48.0;
  static const double destructiveButtonBlur = 14.0;
  static const double destructiveButtonSnell = 1.40;
  static const double destructiveButtonRadius = 12.0;
  static const Color destructiveButtonRim = Color(
    0x59E50914,
  ); // rgba(229,9,20, 0.35)

  // 4. GlassSegmentedControl (42 px Capsule)
  static const double segmentedControlHeight = 42.0;
  static const double segmentedControlBlur = 16.0;
  static const double segmentedControlSnell = 1.45;
  static const double segmentedControlRadius = 21.0;
  static const Color segmentedControlRim = Color(
    0x1AFFFFFF,
  ); // rgba(255,255,255, 0.10)

  // 5. GlassFAB (56 x 56 px Circle)
  static const double fabSize = 56.0;
  static const double fabBlur = 18.0;
  static const double fabSnell = 1.42;
  static const double fabRadius = 28.0;
  static const Color fabRim = Color(0x33FFFFFF); // rgba(255,255,255, 0.20)

  // 6. GlassPlayerPlayButton (68 x 68 px Circle)
  static const double playerPlayButtonSize = 68.0;
  static const double playerPlayButtonBlur = 20.0;
  static const double playerPlayButtonSnell = 1.48;
  static const double playerPlayButtonRadius = 34.0;
  static const Color playerPlayButtonRim = Color(
    0x33FFFFFF,
  ); // rgba(255,255,255, 0.20)

  // 7. GlassMediaToolbar (48 px Capsule)
  static const double mediaToolbarHeight = 48.0;
  static const double mediaToolbarBlur = 16.0;
  static const double mediaToolbarSnell = 1.45;
  static const double mediaToolbarRadius = 24.0;
  static const Color mediaToolbarRim = Color(
    0x26FFFFFF,
  ); // rgba(255,255,255, 0.15)

  // ==========================================
  // THÔNG SỐ QUANG HỌC MENU & POPUP (MENU TOKENS)
  // ==========================================
  /// Khúc xạ vừa phải cho Menu/Sheet diện tích lớn để giữ độ nét cho văn bản
  static const double menuRefractiveIndex = 1.68;
  static const double menuThickness = 36.0;
  static const double menuBlur = 12.0;
  static const Color menuTint = Color(0x361E1E1E);
  static const double menuChromaticAberration = 0.02;

  // ==========================================
  // THÔNG SỐ QUANG HỌC THẺ NỔI (CARD TOKENS)
  // ==========================================
  static const double cardRefractiveIndex = 1.55;
  static const double cardThickness = 28.0;
  static const double cardBlur = 10.0;
  static const Color cardTint = Color(0x261E1E1E);

  // ==========================================
  // VIỀN VÁT SIÊU MẢNH & ÁNH KIM (HAIRLINE RIM)
  // ==========================================
  static const double hairlineRimWidth = 0.6;
  static const double subtleRimWidth = 0.5;

  /// Gradient viền sáng giả lập vát cạnh kim cương phản xạ ánh sáng từ góc trên-trái
  static const LinearGradient hairlineBorderGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x66FFFFFF), // 40% sáng ở góc đón sáng
      Color(0x1AFFFFFF), // 10%
      Color(0x05FFFFFF), // 2%
      Color(0x33FFFFFF), // 20% phản chiếu nhẹ ở góc đối
    ],
    stops: [0.0, 0.35, 0.70, 1.0],
  );

  /// Lớp vòm phản quang hình cầu (Specular Sheen) ở nửa trên bề mặt kính
  static const LinearGradient specularSheenGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x24FFFFFF), Color(0x06FFFFFF), Colors.transparent],
    stops: [0.0, 0.45, 1.0],
  );

  /// Shadow mềm tạo cảm giác bề mặt kính nổi tách biệt khỏi nền phim
  static const List<BoxShadow> elevationShadow = [
    BoxShadow(
      color: Color(0x55000000),
      offset: Offset(0, 8),
      blurRadius: 24,
      spreadRadius: -4,
    ),
    BoxShadow(color: Color(0x33000000), offset: Offset(0, 2), blurRadius: 6),
  ];

  // ==========================================
  // BUILDERS TẠO SETTINGS CHO SHADER
  // ==========================================
  /// Tạo cấu hình LiquidGlassSettings cho nút bấm
  static LiquidGlassSettings createButtonSettings({
    Color tint = buttonTint,
    double blur = buttonBlur,
    double refractiveIndex = buttonRefractiveIndex,
    double thickness = buttonThickness,
  }) {
    return LiquidGlassSettings(
      thickness: thickness,
      blur: blur,
      glassColor: tint,
      lightIntensity: buttonLightIntensity,
      refractiveIndex: refractiveIndex,
      chromaticAberration: buttonChromaticAberration,
      ambientStrength: buttonAmbientStrength,
      fresnelStrength: buttonFresnelStrength,
      saturation: buttonSaturation,
      edgeAbsorption: 0.10,
      lensModel: GlassLensModel.paraxial,
      glowIntensity: 0.60,
      shadowElevation: 1.5,
    );
  }

  /// Tạo cấu hình LiquidGlassSettings cho Menu / Popup / Sheet
  static LiquidGlassSettings createMenuSettings({
    Color tint = menuTint,
    double blur = menuBlur,
    double refractiveIndex = menuRefractiveIndex,
    double thickness = menuThickness,
  }) {
    return LiquidGlassSettings(
      thickness: thickness,
      blur: blur,
      glassColor: tint,
      lightIntensity: 1.15,
      refractiveIndex: refractiveIndex,
      chromaticAberration: menuChromaticAberration,
      ambientStrength: 0.25,
      fresnelStrength: 1.40,
      saturation: 1.25,
      edgeAbsorption: 0.15,
      lensModel: GlassLensModel.paraxial,
      glowIntensity: 0.40,
      shadowElevation: 3.0,
    );
  }
}
