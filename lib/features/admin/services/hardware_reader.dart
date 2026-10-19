import 'hardware_reader_stub.dart'
    if (dart.library.io) 'hardware_reader_io.dart'
    if (dart.library.html) 'hardware_reader_web.dart';

abstract class HardwareReader {
  static HardwareReader get instance => getHardwareReader();

  int get currentRssBytes;
  int get maxRssBytes;
  int get numberOfProcessors;
  String get operatingSystem;
  String get operatingSystemVersion;
}
