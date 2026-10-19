import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../services/auth_service.dart';

/// Widget hiển thị biểu tượng chân dung / ảnh đại diện hình tròn phát sáng
/// Lấy cảm hứng từ avatar thú cưng / nhân vật dễ thương (Panda, Cat, Fox, URL, Ảnh thiết bị...)
/// Hỗ trợ cả preset emoji, ảnh từ thiết bị (Base64 / Memory), ảnh mạng (URL) và màu nền gradient phát sáng.
class UserAvatarCircle extends StatelessWidget {
  final double size;
  final String? avatarType;
  final String? avatarValue;
  final Uint8List? imageBytes;
  final int? bgColor;
  final bool showGlow;
  final Border? border;

  const UserAvatarCircle({
    super.key,
    this.size = 36,
    this.avatarType,
    this.avatarValue,
    this.imageBytes,
    this.bgColor,
    this.showGlow = true,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AuthService.instance,
      builder: (context, _) {
        final auth = AuthService.instance;
        final type = avatarType ?? auth.avatarType;
        final value = avatarValue ?? auth.avatarValue;
        final colorInt = bgColor ?? auth.avatarBgColor;
        final baseColor = Color(colorInt);

        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              center: Alignment.topLeft,
              radius: 0.95,
              colors: [
                baseColor.withValues(alpha: 0.90),
                baseColor.withValues(alpha: 0.55),
              ],
            ),
            boxShadow: showGlow
                ? [
                    BoxShadow(
                      color: baseColor.withValues(alpha: 0.45),
                      blurRadius: size * 0.25,
                      spreadRadius: size * 0.04,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
            border: border ??
                Border.all(
                  color: Colors.white.withValues(alpha: 0.35),
                  width: (size * 0.04).clamp(1.0, 2.0),
                ),
          ),
          clipBehavior: Clip.antiAlias,
          child: _buildAvatarContent(type, value, size),
        );
      },
    );
  }

  Widget _buildAvatarContent(String type, String value, double dimension) {
    // 1. Nếu có dữ liệu byte ảnh trực tiếp trong bộ nhớ
    if (imageBytes != null && imageBytes!.isNotEmpty) {
      return Image.memory(
        imageBytes!,
        width: dimension,
        height: dimension,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Center(
          child: Text(
            '🐼',
            style: TextStyle(fontSize: dimension * 0.55),
          ),
        ),
      );
    }

    // 2. Ảnh từ thiết bị hoặc chuỗi Base64
    final isBase64 = (type == 'file' ||
            type == 'base64' ||
            type == 'device' ||
            value.startsWith('data:image') ||
            (value.length > 200 && !value.startsWith('http'))) &&
        value.length >= 20 &&
        !value.contains('🐼');

    if (isBase64) {
      try {
        final cleanBase64 =
            value.contains(',') ? value.split(',').last.trim() : value.trim();
        final bytes = base64Decode(cleanBase64);
        return Image.memory(
          bytes,
          width: dimension,
          height: dimension,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => Center(
            child: Text(
              '🐼',
              style: TextStyle(fontSize: dimension * 0.55),
            ),
          ),
        );
      } catch (e) {
        debugPrint('Lỗi giải mã ảnh đại diện Base64: $e');
        return Center(
          child: Text(
            '🐼',
            style: TextStyle(fontSize: dimension * 0.55),
          ),
        );
      }
    }

    // 3. Ảnh mạng trực tuyến (URL)
    if (type == 'url' && value.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: value,
        width: dimension,
        height: dimension,
        fit: BoxFit.cover,
        placeholder: (_, _) => const Center(
          child: SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
            ),
          ),
        ),
        errorWidget: (_, _, _) => Center(
          child: Text(
            '🐼',
            style: TextStyle(fontSize: dimension * 0.55),
          ),
        ),
      );
    }

    // 4. Mặc định hoặc preset Emoji (Gấu trúc Panda, Mèo con, v.v.)
    final displayChar = value.isNotEmpty ? value : '🐼';
    return Center(
      child: Text(
        displayChar,
        style: TextStyle(
          fontSize: dimension * 0.56,
          height: 1.05,
        ),
      ),
    );
  }
}

/// Nút bấm Avatar chân dung chuẩn kích thước chạm (touch target >= 44px)
/// Đảm bảo căn chỉnh thẳng hàng tuyệt đối trong AppBar
class UserAvatarButton extends StatelessWidget {
  final double size;
  final VoidCallback onPressed;
  final VoidCallback? onLongPress;
  final String? tooltip;

  const UserAvatarButton({
    super.key,
    this.size = 36,
    required this.onPressed,
    this.onLongPress,
    this.tooltip = 'Tài khoản & Cá nhân',
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: tooltip,
      child: Tooltip(
        message: tooltip ?? '',
        child: InkWell(
          onTap: onPressed,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(size),
          splashColor: Colors.white10,
          highlightColor: Colors.white.withValues(alpha: 0.05),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: UserAvatarCircle(size: size),
          ),
        ),
      ),
    );
  }
}
