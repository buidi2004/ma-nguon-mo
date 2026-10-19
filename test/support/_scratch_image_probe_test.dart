// File TẠM: kiểm chứng mock ảnh thật sự load được qua CachedNetworkImage.
// Sẽ bị xoá trước khi bàn giao (không thuộc phạm vi).
// ignore_for_file: avoid_print
import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_image_mock.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  mockNetworkImages();

  testWidgets('CachedNetworkImage load được ảnh từ mock (không cần mạng)',
      (tester) async {
    final loaded = Completer<void>();
    var errored = false;

    await tester.pumpWidget(
      MaterialApp(
        home: CachedNetworkImage(
          imageUrl:
              'https://images.unsplash.com/photo-1536440136628-849c177e76a1?w=800',
          imageBuilder: (context, imageProvider) {
            if (!loaded.isCompleted) loaded.complete();
            return Image(image: imageProvider);
          },
          placeholder: (context, url) => const Text('PLACEHOLDER'),
          errorWidget: (context, url, error) {
            errored = true;
            print('PROBE image error: $error');
            return const Text('ERROR');
          },
        ),
      ),
    );

    await tester.runAsync(() async {
      try {
        await loaded.future.timeout(const Duration(seconds: 10));
      } catch (e) {
        print('PROBE timeout: $e');
      }
    });
    await tester.pump();

    print('PROBE loaded=${loaded.isCompleted} errored=$errored '
        'placeholder=${find.text('PLACEHOLDER').evaluate().length} '
        'error=${find.text('ERROR').evaluate().length}');

    expect(errored, isFalse);
    expect(loaded.isCompleted, isTrue);
  });
}
