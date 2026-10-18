import 'hardware_reader.dart';

HardwareReader getHardwareReader() => StubHardwareReader();

class StubHardwareReader implements HardwareReader {
  @override
  int get currentRssBytes => 64 * 1024 * 1024;

  @override
  int get maxRssBytes => 128 * 1024 * 1024;

  @override
  int get numberOfProcessors => 4;

  @override
  String get operatingSystem => 'generic';

  @override
  String get operatingSystemVersion => '1.0.0';
}
