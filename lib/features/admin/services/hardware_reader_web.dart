import 'hardware_reader.dart';

HardwareReader getHardwareReader() => WebHardwareReader();

class WebHardwareReader implements HardwareReader {
  @override
  int get currentRssBytes => 128 * 1024 * 1024;

  @override
  int get maxRssBytes => 256 * 1024 * 1024;

  @override
  int get numberOfProcessors => 4;

  @override
  String get operatingSystem => 'web';

  @override
  String get operatingSystemVersion => 'Browser';
}
