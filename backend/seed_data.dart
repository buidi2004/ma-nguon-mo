// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// Script nap nhanh 8 bo phim mau vao PocketBase
/// Cach dung:
/// `dart run backend/seed_data.dart [POCKETBASE_URL]`
/// Vi du:
/// `dart run backend/seed_data.dart https://openflix-demo.pockethost.io`
void main(List<String> args) async {
  String baseUrl = args.isNotEmpty ? args[0] : 'http://127.0.0.1:8090';
  baseUrl = baseUrl.replaceAll(RegExp(r'/+$'), '');

  print('====================================================');
  print('🎬 OpenFlix PocketBase Auto-Seeder');
  print('🎯 Server target: $baseUrl');
  print('====================================================');

  final file = File('backend/sample_movies.json');
  if (!await file.exists()) {
    print('❌ Khong tim thay file backend/sample_movies.json!');
    return;
  }

  final movies = jsonDecode(await file.readAsString()) as List<dynamic>;
  final apiUrl = Uri.parse('$baseUrl/api/collections/movies/records');

  int successCount = 0;
  for (var movie in movies) {
    try {
      print('🚀 Dang day: ${movie['title']}...');
      final response = await http.post(
        apiUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(movie),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('  ✅ Thanh cong!');
        successCount++;
      } else {
        print('  ⚠️ That bai (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      print('  ❌ Loi ket noi: $e');
    }
  }

  print('\n🎉 Hoan thanh! Da nap thanh cong $successCount / ${movies.length} bo phim.');
  print('Kiem tra API tai: $baseUrl/api/collections/movies/records?sort=-created');
}
