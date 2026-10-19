// Mock tầng HTTP cho test widget: mọi request ảnh trả về PNG 1x1 nhúng sẵn.
//
// Mục đích: test visual/capture không phụ thuộc mạng, không chờ timeout DNS,
// và không còn khác nhau giữa các lần chạy (deterministic).
//
// Cách dùng:
//   void main() {
//     TestWidgetsFlutterBinding.ensureInitialized();
//     mockNetworkImages();
//     ...
//   }
//
// Lưu ý: `CachedNetworkImage` -> `flutter_cache_manager` -> `package:http` ->
// `IOClient` -> `HttpClient()`, nên `HttpOverrides.global` là điểm chặn đúng.
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

/// Ảnh PNG 1x1 trong suốt (67 byte), mã hoá base64 — không cần asset ngoài.
const String kTransparent1x1PngBase64 =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8'
    'z8DwHwAFBQIAX8jx0gAAAABJRU5ErkJggg==';

/// Bytes của ảnh PNG 1x1 dùng cho mọi response giả lập.
final Uint8List kTransparent1x1Png = base64Decode(kTransparent1x1PngBase64);

HttpOverrides? _previousOverrides;
bool _installed = false;

/// Bật chế độ "ảnh giả lập": mọi request HTTP trả 200 + PNG 1x1.
///
/// Gọi sau `TestWidgetsFlutterBinding.ensureInitialized()` (thường trong
/// `setUpAll`) để ghi đè HttpOverrides mặc định của flutter_test.
void mockNetworkImages() {
  if (_installed) return;
  _previousOverrides = HttpOverrides.current;
  HttpOverrides.global = _FakeImageHttpOverrides();
  _installed = true;
}

/// Khôi phục HttpOverrides trước khi mock (dùng trong `tearDownAll`).
void restoreNetworkImages() {
  if (!_installed) return;
  HttpOverrides.global = _previousOverrides;
  _previousOverrides = null;
  _installed = false;
}

class _FakeImageHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => _FakeHttpClient();
}

/// HttpClient giả: mọi request đều thành công và trả PNG 1x1.
///
/// Chỉ implement những thành viên mà `package:http`'s `IOClient` thực sự
/// dùng; phần còn lại rơi vào `noSuchMethod`.
class _FakeHttpClient implements HttpClient {
  @override
  bool autoUncompress = true;

  @override
  Duration? connectionTimeout;

  @override
  Duration idleTimeout = const Duration(seconds: 15);

  @override
  int? maxConnectionsPerHost;

  @override
  String? userAgent;

  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _FakeHttpClientRequest(url);

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async =>
      _FakeHttpClientRequest(url);

  @override
  Future<HttpClientRequest> postUrl(Uri url) async =>
      _FakeHttpClientRequest(url);

  @override
  Future<HttpClientRequest> putUrl(Uri url) async => _FakeHttpClientRequest(url);

  @override
  Future<HttpClientRequest> deleteUrl(Uri url) async =>
      _FakeHttpClientRequest(url);

  @override
  Future<HttpClientRequest> patchUrl(Uri url) async =>
      _FakeHttpClientRequest(url);

  @override
  Future<HttpClientRequest> headUrl(Uri url) async =>
      _FakeHttpClientRequest(url);

  @override
  Future<HttpClientRequest> open(
    String method,
    String host,
    int port,
    String path,
  ) async =>
      _FakeHttpClientRequest(Uri.parse('http://$host:$port$path'));

  @override
  void close({bool force = false}) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Request nào được coi là "tải ảnh"?
///
/// - `/api/files/...` của PocketBase: file đính kèm -> ảnh.
/// - `/api/...` khác (JSON API): KHÔNG phải ảnh -> trả 400 giống mặc định
///   của flutter_test, để app rơi vào đúng nhánh fallback như trước.
/// - Mọi URL còn lại (CDN ảnh: unsplash, v.v.): coi là ảnh.
bool _looksLikeImageRequest(Uri uri) {
  final path = uri.path.toLowerCase();
  if (path.startsWith('/api/files/')) return true;
  if (path.startsWith('/api/')) return false;
  return true;
}

class _FakeHttpClientRequest implements HttpClientRequest {
  _FakeHttpClientRequest(this.uri);

  @override
  final Uri uri;

  @override
  final HttpHeaders headers = _FakeHttpHeaders();

  @override
  bool bufferOutput = true;

  @override
  int contentLength = -1;

  @override
  Encoding encoding = utf8;

  @override
  bool followRedirects = true;

  @override
  int maxRedirects = 5;

  @override
  bool persistentConnection = true;

  @override
  void add(List<int> data) {}

  @override
  void write(Object? object) {}

  @override
  Future<void> addStream(Stream<List<int>> stream) async {
    await stream.drain<void>();
  }

  @override
  Future<void> flush() async {}

  @override
  Future<HttpClientResponse> close() async =>
      _FakeHttpClientResponse._forUri(uri);

  @override
  Future<HttpClientResponse> get done async =>
      _FakeHttpClientResponse._forUri(uri);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeHttpClientResponse extends Stream<List<int>>
    implements HttpClientResponse {
  _FakeHttpClientResponse._forUri(Uri uri)
      : _isImage = _looksLikeImageRequest(uri);

  final bool _isImage;

  @override
  int get statusCode => _isImage ? HttpStatus.ok : HttpStatus.badRequest;

  @override
  String get reasonPhrase => _isImage ? 'OK' : 'Bad Request';

  @override
  int get contentLength => _isImage ? kTransparent1x1Png.length : 0;

  @override
  bool get isRedirect => false;

  @override
  bool get persistentConnection => false;

  @override
  List<Cookie> get cookies => const <Cookie>[];

  @override
  List<RedirectInfo> get redirects => const <RedirectInfo>[];

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  HttpHeaders get headers => _FakeHttpHeaders()
    ..set(
      HttpHeaders.contentTypeHeader,
      _isImage ? 'image/png' : 'text/plain',
    )
    ..set(HttpHeaders.contentLengthHeader, '$contentLength');

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) =>
      (_isImage
              ? Stream<List<int>>.value(kTransparent1x1Png)
              : const Stream<List<int>>.empty())
          .listen(
        onData,
        onError: onError,
        onDone: onDone,
        cancelOnError: cancelOnError,
      );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeHttpHeaders implements HttpHeaders {
  _FakeHttpHeaders();

  final Map<String, List<String>> _values = <String, List<String>>{};

  @override
  void forEach(void Function(String name, List<String> values) action) =>
      _values.forEach(action);

  @override
  List<String>? operator [](String name) => _values[name.toLowerCase()];

  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {
    _values[name.toLowerCase()] = <String>[value.toString()];
  }

  @override
  void add(String name, Object value, {bool preserveHeaderCase = false}) {
    _values.putIfAbsent(name.toLowerCase(), () => <String>[])
        .add(value.toString());
  }

  @override
  void removeAll(String name) => _values.remove(name.toLowerCase());

  @override
  void clear() => _values.clear();

  @override
  ContentType? get contentType {
    final value = _values[HttpHeaders.contentTypeHeader];
    if (value == null || value.isEmpty) return null;
    return ContentType.parse(value.join(','));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
