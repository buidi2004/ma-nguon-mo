import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../core/config.dart';

/// Kết quả phản hồi khi tải ảnh lên ImageKit
class ImageKitUploadResult {
  final bool success;
  final String? url;
  final String? fileId;
  final String? filePath;
  final String? thumbnailUrl;
  final String? errorMessage;

  const ImageKitUploadResult({
    required this.success,
    this.url,
    this.fileId,
    this.filePath,
    this.thumbnailUrl,
    this.errorMessage,
  });

  factory ImageKitUploadResult.failure(String message) {
    return ImageKitUploadResult(success: false, errorMessage: message);
  }
}

/// Dịch vụ tải ảnh và quản lý media đám mây qua ImageKit.io API & CDN
class ImageKitService {
  static final ImageKitService instance = ImageKitService._internal();

  ImageKitService._internal();

  /// Mock HTTP Client dùng cho Unit & Widget Test
  http.Client? testClient;

  String get publicKey => AppConfig.imageKitPublicKey;
  String get privateKey => AppConfig.imageKitPrivateKey;
  String get urlEndpoint => AppConfig.imageKitUrlEndpoint;
  String get accountId => AppConfig.imageKitId;

  /// Header Basic Authorization xác thực API ImageKit
  Map<String, String> get _authHeaders {
    final authBytes = utf8.encode('$privateKey:');
    final base64Auth = base64Encode(authBytes);
    return {'Authorization': 'Basic $base64Auth', 'Accept': 'application/json'};
  }

  /// Tải lên ảnh từ mảng byte (Uint8List) lên máy chủ ImageKit CDN
  Future<ImageKitUploadResult> uploadImageBytes({
    required Uint8List bytes,
    required String fileName,
    String folder = '/openflix/avatars',
  }) async {
    try {
      final client = testClient ?? http.Client();
      final base64Image = base64Encode(bytes);

      final uri = Uri.parse('https://upload.imagekit.io/api/v1/files/upload');
      final response = await client.post(
        uri,
        headers: _authHeaders,
        body: {
          'file': 'data:image/jpeg;base64,$base64Image',
          'fileName': fileName,
          'folder': folder,
          'useUniqueFileName': 'true',
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final url = data['url'] as String?;
        final fileId = data['fileId'] as String?;
        final filePath = data['filePath'] as String?;
        final thumbnailUrl = data['thumbnailUrl'] as String?;

        return ImageKitUploadResult(
          success: true,
          url: url,
          fileId: fileId,
          filePath: filePath,
          thumbnailUrl: thumbnailUrl,
        );
      } else {
        debugPrint(
          'Lỗi tải ảnh ImageKit: HTTP ${response.statusCode} - ${response.body}',
        );
        return ImageKitUploadResult.failure(
          'Lỗi tải ảnh ImageKit (${response.statusCode}): ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('Ngoại lệ kết nối ImageKit: $e');
      return ImageKitUploadResult.failure('Lỗi kết nối ImageKit: $e');
    }
  }

  /// Tải lên ảnh từ XFile (do ImagePicker trả về)
  Future<ImageKitUploadResult> uploadXFile(
    XFile file, {
    String folder = '/openflix/avatars',
  }) async {
    final bytes = await file.readAsBytes();
    final name = file.name.isNotEmpty
        ? file.name
        : 'img_${DateTime.now().millisecondsSinceEpoch}.jpg';
    return uploadImageBytes(bytes: bytes, fileName: name, folder: folder);
  }
}
