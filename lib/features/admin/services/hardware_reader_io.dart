import 'dart:io' as io;

import 'hardware_reader.dart';

HardwareReader getHardwareReader() => IoHardwareReader();

class IoHardwareReader implements HardwareReader {
  @override
  int get currentRssBytes {
    try {
      final rss = io.ProcessInfo.currentRss;
      return rss > 0 ? rss : 128 * 1024 * 1024;
    } catch (_) {
      return 128 * 1024 * 1024;
    }
  }

  @override
  int get maxRssBytes {
    try {
      final maxRss = io.ProcessInfo.maxRss;
      return maxRss > 0 ? maxRss : currentRssBytes;
    } catch (_) {
      return currentRssBytes;
    }
  }

  @override
  int get numberOfProcessors {
    try {
      return io.Platform.numberOfProcessors;
    } catch (_) {
      return 4;
    }
  }

  @override
  String get operatingSystem {
    try {
      return io.Platform.operatingSystem;
    } catch (_) {
      return 'system';
    }
  }

  @override
  String get operatingSystemVersion {
    try {
      return io.Platform.operatingSystemVersion;
    } catch (_) {
      return '';
    }
  }
}
