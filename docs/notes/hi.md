Mình kiểm tra thông tin mới nhất của PocketHost, PocketBase và SDK trước, vì giao diện và gói miễn phí hay thay đổi. Không muốn bạn làm theo hướng dẫn cũ rồi gặp lỗi.Mình vừa kiểm tra lại tài liệu hiện hành và thấy hai chỗ trong kế hoạch trước đã lỗi thời. Cần sửa trước khi làm, nếu không bạn sẽ gặp lỗi ngay từ bước đầu.

**1. PocketHost không còn miễn phí như mình giả định.** Trang giá hiện tại niêm yết $9.99 mỗi PocketBase mỗi tháng, có dùng thử 7 ngày, và có truy cập SFTP. Mình không thấy gói miễn phí nào ở đó, nhưng bạn nên tự mở pockethost.io/pricing xem lại. Vì vậy cách làm dưới đây chạy PocketBase trên máy bạn trước, và chọn nơi đưa lên mạng ở bước A8.

**2. Cách đọc dữ liệu trong `Movie` ở bản trước có thể không còn dùng được.** Tài liệu SDK hiện tại hướng dẫn đọc giá trị bằng `record.get<T>()` và không còn nhắc các hàm `getStringValue`, `getIntValue`. Mình viết lại model ở bước B4 theo cách không phụ thuộc các hàm đó.

Thông tin phiên bản hiện tại: PocketBase mới nhất là v0.40.5, và SDK Dart bản 0.25.2 (phát hành ngày 1/10/2026) chỉ chạy với PocketBase từ v0.23 trở lên. Trang chủ PocketBase còn cảnh báo dự án chưa đạt v1.0 nên chưa đảm bảo tương thích ngược. Bạn nên ghi điều này vào mục hạn chế của báo cáo.

Thời gian ước tính: ngày 1 làm A1-A8, ngày 2 làm B1-B8.

---

# Phần A. Backend (PocketBase)

### A1. Chuẩn bị thư mục và công cụ

Cấu trúc repo (Flutter ở gốc, backend nằm trong):

```text
openflix/
├── backend/        # PocketBase, commit pb_migrations, KHÔNG commit pb_data
├── lib/
├── android/
└── pubspec.yaml
```

Các bước:
1. Chạy `flutter doctor`. Mục Android toolchain phải không có dấu X đỏ.
2. Tạo project: `flutter create openflix`, rồi `cd openflix` và `mkdir backend`.
3. Tải PocketBase từ pocketbase.io/docs, chọn đúng hệ điều hành (file zip khoảng 12 MB). Giải nén **vào thư mục `backend/`**.
4. macOS/Linux: chạy `chmod +x backend/pocketbase`. macOS có thể chặn vì "nhà phát triển không xác định", khi đó chạy `xattr -d com.apple.quarantine backend/pocketbase`.
5. Thêm vào `.gitignore` ở gốc repo:

```text
backend/pb_data/
backend/pocketbase
backend/pocketbase.exe
```

`pb_data` chứa dữ liệu và mật khẩu quản trị đã băm, không được đưa lên GitHub.

**Kiểm tra:** `flutter run` mở được app đếm số mặc định trên emulator hoặc máy thật. Làm bước này ngay để biết công cụ Flutter ổn, sau này lỗi nào cũng không phải do môi trường.

### A2. Chạy PocketBase và tạo tài khoản quản trị

Trong thư mục `backend/`:

```bash
./pocketbase superuser create admin@openflix.local MatKhau12345
./pocketbase serve
```

Trên Windows dùng `.\pocketbase.exe`. Tài liệu xác nhận lần chạy đầu sẽ tạo link cài đặt để lập superuser, hoặc bạn có thể tạo thủ công bằng lệnh `superuser create`. Dùng lệnh thủ công như trên để khỏi phụ thuộc link tự mở. Mật khẩu nên từ 8 ký tự trở lên. Ghi lại email và mật khẩu này, không đưa vào repo.

**Kiểm tra:**
1. Terminal in ra địa chỉ server (mặc định `http://127.0.0.1:8090`).
2. Mở `http://127.0.0.1:8090/_/`, đăng nhập được và thấy trang Collections.

**Nếu lỗi:** báo cổng 8090 đang bị dùng thì chạy `./pocketbase serve --http="127.0.0.1:8091"` và dùng cổng 8091 ở mọi bước sau.

### A3. Tạo collection `movies` bằng migration

Dùng file migration thay vì bấm tay trong Dashboard, vì file này commit lên GitHub được và dựng lại backend chỉ bằng một lệnh. Migration trong thư mục `pb_migrations` được tự áp dụng khi `serve` khởi động, và chạy trong một transaction, nên nếu có lỗi thì không để lại dữ liệu dở dang.

Dừng server (Ctrl+C), rồi tạo file migration trống:

```bash
./pocketbase migrate create "create_movies"
```

Lệnh này sinh file `pb_migrations/<số>_create_movies.js`. Mở file đó, thay toàn bộ nội dung bằng:

```js
migrate((app) => {
  const collection = new Collection({
    type: "base",
    name: "movies",
    listRule: "",
    viewRule: "",
    createRule: null,
    updateRule: null,
    deleteRule: null,
    fields: [
      { type: "text",   name: "title",        required: true },
      { type: "text",   name: "description" },
      { type: "text",   name: "category",     required: true },
      { type: "url",    name: "poster_url",   required: true },
      { type: "url",    name: "video_url",    required: true },
      { type: "number", name: "release_year", onlyInt: true },
      { type: "bool",   name: "is_featured" },
      { type: "autodate", name: "created", onCreate: true, onUpdate: false },
      { type: "autodate", name: "updated", onCreate: true, onUpdate: true },
    ],
  })
  app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("movies")
  app.delete(collection)
})
```

Ý nghĩa quy tắc API: chuỗi rỗng `""` là ai cũng đọc được, `null` là chỉ superuser mới được thao tác. Vì vậy người dùng chỉ đọc, còn thêm/sửa/xóa bị khóa.

### A4. Nạp 9 phim mẫu bằng migration thứ hai

```bash
./pocketbase migrate create "seed_movies"
```

Thay nội dung file mới sinh bằng:

```js
migrate((app) => {
  const movies = app.findCollectionByNameOrId("movies")
  const video = "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/"
  const poster = video + "images/"

  const data = [
    { t: "Big Buck Bunny", d: "Một chú thỏ khổng lồ hiền lành bị ba con thú nghịch ngợm trêu chọc và quyết định đáp trả.", c: "Hoạt hình", f: "BigBuckBunny", y: 2008, star: true },
    { t: "Sintel", d: "Cô gái Sintel băng qua những vùng đất xa xôi để tìm lại chú rồng con bị thất lạc.", c: "Hoạt hình", f: "Sintel", y: 2010, star: true },
    { t: "Elephants Dream", d: "Hai người đàn ông khám phá một cỗ máy khổng lồ kỳ lạ trong thế giới siêu thực.", c: "Viễn tưởng", f: "ElephantsDream", y: 2006, star: false },
    { t: "Tears of Steel", d: "Một nhóm chiến binh và nhà khoa học tìm cách ngăn robot hủy diệt thế giới.", c: "Viễn tưởng", f: "TearsOfSteel", y: 2012, star: false },
    { t: "For Bigger Blazes", d: "Đoạn video mẫu ngắn dùng để thử nghiệm trình phát.", c: "Hành động", f: "ForBiggerBlazes", y: 2013, star: false },
    { t: "For Bigger Escapes", d: "Đoạn video mẫu ngắn dùng để thử nghiệm trình phát.", c: "Hành động", f: "ForBiggerEscapes", y: 2013, star: false },
    { t: "For Bigger Fun", d: "Đoạn video mẫu ngắn dùng để thử nghiệm trình phát.", c: "Hành động", f: "ForBiggerFun", y: 2013, star: false },
    { t: "For Bigger Joyrides", d: "Đoạn video mẫu ngắn dùng để thử nghiệm trình phát.", c: "Hành động", f: "ForBiggerJoyrides", y: 2013, star: false },
    { t: "For Bigger Meltdowns", d: "Đoạn video mẫu ngắn dùng để thử nghiệm trình phát.", c: "Hành động", f: "ForBiggerMeltdowns", y: 2013, star: false },
  ]

  data.forEach((m) => {
    const r = new Record(movies)
    r.set("title", m.t)
    r.set("description", m.d)
    r.set("category", m.c)
    r.set("poster_url", poster + m.f + ".jpg")
    r.set("video_url", video + m.f + ".mp4")
    r.set("release_year", m.y)
    r.set("is_featured", m.star)
    app.save(r)
  })
})
```

Mình không kiểm tra được các link ảnh poster từ đây, nên bước A6 bắt buộc phải thử từng link. Năm phát hành của 5 video "For Bigger" là ước chừng, bạn sửa tùy ý. Thể loại cũng sửa được.

Giờ khởi động lại:

```bash
./pocketbase serve
```

**Kiểm tra:**
1. Terminal không có dòng lỗi màu đỏ.
2. Vào `http://127.0.0.1:8090/_/`, mở Collections, thấy `movies` có 9 bản ghi.
3. Mở tab API Rules của `movies`: List/Search và View ở trạng thái mở (ổ khóa mở), ba quy tắc còn lại bị khóa.

**Nếu lỗi:**
- Console báo lỗi ở hai field `autodate`: xóa hai dòng đó trong file migration thứ nhất. API vẫn chạy bình thường, chỉ thiếu `created` và `updated`.
- Muốn làm lại từ đầu: dừng server, xóa thư mục `pb_data`, chạy lại `serve`. Nhớ tạo lại superuser bằng lệnh ở A2. Sửa file migration đã áp dụng thì sẽ không chạy lại, phải xóa `pb_data` như vậy.

Commit bước này: `add pocketbase backend migrations`.

### A5. Kiểm thử API bằng trình duyệt và terminal

Server đang chạy, thử lần lượt:

| Kiểm tra | Cách làm | Kết quả đúng |
| --- | --- | --- |
| Server sống | Mở `http://127.0.0.1:8090/api/health` | JSON có chữ "API is healthy" |
| Danh sách phim | Mở `http://127.0.0.1:8090/api/collections/movies/records?sort=-release_year&perPage=50` | JSON có mảng `items` gồm 9 phim, phim 2013 đứng trước |
| Một phim | Lấy `id` từ kết quả trên, mở `.../records/<id>` | JSON của đúng phim đó |
| Quyền ghi bị khóa | Lệnh dưới | Mã 403 |

```bash
curl -i -X POST http://127.0.0.1:8090/api/collections/movies/records \
  -H "Content-Type: application/json" \
  -d '{"title":"hack"}'
```

Kết quả 403 chứng minh người dùng thường không ghi được dữ liệu. Chụp ảnh màn hình này cho báo cáo.

**Nếu lỗi:** `404` ở danh sách nghĩa là sai tên collection hoặc migration chưa chạy. `403` ở danh sách nghĩa là `listRule` đang là `null`.

### A6. Kiểm tra từng link video và poster

Với mỗi bản ghi, mở `video_url` và `poster_url` trên trình duyệt. Hoặc dùng terminal:

```bash
curl -I "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"
curl -I "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/BigBuckBunny.jpg"
```

Kết quả đúng là dòng đầu có `200` (hoặc `206`). Link nào trả `404` thì lập danh sách. Cách thay poster hỏng: tải ảnh poster về (nguồn nên là poster phim Blender trên Wikimedia Commons, ghi rõ giấy phép), đặt vào thư mục `posters/` trong repo GitHub, rồi sửa `poster_url` thành dạng `https://raw.githubusercontent.com/<user>/<repo>/main/posters/<tên>.jpg`. Cách này miễn phí, có HTTPS, và hợp chủ đề mã nguồn mở. Sửa bản ghi trong Dashboard là được, không cần sửa migration.

Ảnh thumbnail của bộ mẫu này là ảnh ngang. App dùng `BoxFit.cover` nên sẽ bị cắt thành dọc, chấp nhận được cho bản demo.

### A7. Kiểm tra dữ liệu có đủ trường

Trong Dashboard, mở lần lượt vài bản ghi và xác nhận:
1. Không có trường nào trống ở `title`, `category`, `poster_url`, `video_url`.
2. Có đúng 2 phim `is_featured = true`.
3. Số thể loại là 3 (Hoạt hình, Viễn tưởng, Hành động). Viết **đúng cùng một chính tả** ở mọi bản ghi, vì app dùng chuỗi này để gom hàng. Gõ khác một dấu là tách thành hàng riêng.

### A8. Chọn nơi chạy server cho APK và buổi báo cáo

Cho đến giờ server chỉ chạy trên laptop. Điện thoại của người khác không truy cập được `127.0.0.1` của bạn. Bạn có 5 lựa chọn:

| Cách | Chi phí | Điều kiện | Nhược điểm |
| --- | --- | --- | --- |
| Local + `adb reverse` | Miễn phí | Điện thoại cắm USB, bật gỡ lỗi USB | Chỉ để phát triển, không dùng để demo |
| Local + IP mạng LAN | Miễn phí | Cùng Wi-Fi, cần chạy server với `--http="0.0.0.0:8090"` | Wi-Fi trường có thể chặn kết nối giữa các máy, mở firewall |
| Local + tunnel HTTPS (Cloudflare Tunnel, ngrok) | Miễn phí (kiểm tra điều kiện hiện hành) | Laptop phải bật suốt buổi demo | Địa chỉ có thể đổi mỗi lần chạy, phải build lại APK |
| PocketBase Cloud, gói Free | $0 | Một bài hướng dẫn nói cần tạo subscription Stripe miễn phí để xác minh thanh toán, và việc cấp phát có thể mất đến 48 giờ | Dung lượng nhỏ: 1 instance với 50 MB là đủ cho 9 bản ghi |
| PocketHost | Có dùng thử 7 ngày, sau đó $9.99/tháng | Thẻ thanh toán | Phải hủy trước khi hết hạn nếu không muốn bị tính phí |

Khuyến nghị:
- Trong lúc phát triển: dùng local.
- Cho APK nộp bài: nếu có phương thức thanh toán quốc tế thì đăng ký PocketBase Cloud Free **ngay ngày 1** vì thời gian cấp phát không chắc chắn. Nếu không có thì dùng tunnel hoặc LAN, và demo từ laptop của bạn.
- Dù chọn cách nào, đặt địa chỉ server làm biến lúc build (bước B3) để đổi bằng một tham số mà không sửa code.

Đưa dữ liệu lên server thật bằng một trong hai cách:
- **Cách 1, tải migration lên:** PocketHost cho upload qua SFTP, và khi server khởi động lại thì migration tự chạy. Với host khác thì xem tài liệu của họ.
- **Cách 2, làm tay trong Dashboard:** tạo collection `movies` với 7 trường đúng tên, đúng kiểu như migration ở A3, mở quy tắc List và View, rồi nhập 9 bản ghi bằng form (khoảng 15 phút). Chọn phiên bản PocketBase trên host từ v0.23 trở lên, tốt nhất cùng bản 0.40.x với máy bạn.

---

# Phần B. Frontend (Flutter) kết nối backend

### B1. Cài thư viện

```bash
flutter pub add pocketbase video_player chewie cached_network_image
flutter pub get
```

Lệnh `pub add` tự lấy bản mới nhất, không ghim version từ trí nhớ.

**Kiểm tra:** `pubspec.yaml` có 4 dòng mới dưới `dependencies`, `flutter pub get` không báo lỗi xung đột.

### B2. Quyền Internet và tên app

Mở `android/app/src/main/AndroidManifest.xml`. Thêm dòng quyền **trước** thẻ `<application>` và đổi nhãn:

```xml
<uses-permission android:name="android.permission.INTERNET"/>

<application
    android:label="OpenFlix"
    ...>
```

Đây là file `main`, nên áp dụng cho cả bản debug lẫn bản release. Bản release thiếu dòng này sẽ không tải được gì trên máy thật. Đây là lỗi hay gặp nhất khi "chạy được trên máy tôi mà APK thì không".

Chỉ khi chạy local bằng địa chỉ `http://`, mở thêm `android/app/src/debug/AndroidManifest.xml` và thêm vào trong thẻ `<manifest>`:

```xml
<application android:usesCleartextTraffic="true"/>
```

Dòng này chỉ có trong bản debug, nên bản release vẫn buộc dùng HTTPS. Điều đó đúng ý, vì APK nộp bài phải trỏ tới địa chỉ `https://`.

### B3. Địa chỉ server theo từng môi trường

Tạo `lib/config.dart`:

```dart
class AppConfig {
  static const pbUrl = String.fromEnvironment(
    'PB_URL',
    defaultValue: 'http://10.0.2.2:8090',
  );
}
```

Chọn giá trị `PB_URL` theo cách bạn đang chạy:

| Tình huống | Giá trị `PB_URL` |
| --- | --- |
| Emulator Android | `http://10.0.2.2:8090` (mặc định ở trên) |
| Máy thật cắm USB, đã chạy `adb reverse tcp:8090 tcp:8090` | `http://127.0.0.1:8090` |
| Máy thật cùng Wi-Fi | `http://<IP laptop>:8090` (xem IP bằng `ipconfig` hoặc `ipconfig getifaddr en0`) |
| Server trên mạng | `https://<địa chỉ của bạn>` |

Truyền khi chạy:

```bash
flutter run --dart-define=PB_URL=http://192.168.1.10:8090
```

Hai điểm dễ sai: trong emulator, `localhost` và `127.0.0.1` là chính emulator chứ không phải laptop của bạn. Và đổi `--dart-define` thì phải **dừng hẳn rồi chạy lại**, hot reload không áp dụng.

### B4. Model (viết lại, an toàn với mọi kiểu dữ liệu)

`lib/models/movie_model.dart`:

```dart
import 'package:pocketbase/pocketbase.dart';

class Movie {
  final String id, title, description, category, posterUrl, videoUrl;
  final int releaseYear;
  final bool isFeatured;

  const Movie({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.posterUrl,
    required this.videoUrl,
    required this.releaseYear,
    required this.isFeatured,
  });

  factory Movie.fromRecord(RecordModel record) {
    final j = record.toJson();
    String s(dynamic v) => v?.toString() ?? '';
    return Movie(
      id: record.id,
      title: s(j['title']),
      description: s(j['description']),
      category: s(j['category']),
      posterUrl: s(j['poster_url']),
      videoUrl: s(j['video_url']),
      releaseYear: (j['release_year'] as num?)?.toInt() ?? 0,
      isFeatured: j['is_featured'] == true,
    );
  }
}
```

Dùng `toJson()` vì tài liệu SDK dùng đúng hàm này để chuyển bản ghi thành đối tượng của bạn. Nó trả các trường ở cấp ngoài cùng nên không phụ thuộc bất kỳ hàm đọc nào có thể đổi tên. Các hàm đọc phòng sẵn trường rỗng nên không bị crash khi dữ liệu thiếu.

### B5. Service có báo lỗi rõ ràng

`lib/services/pocketbase_service.dart`:

```dart
import 'dart:async';
import 'package:pocketbase/pocketbase.dart';
import '../config.dart';
import '../models/movie_model.dart';

class PocketBaseService {
  static final PocketBase pb = PocketBase(AppConfig.pbUrl);

  static Future<List<Movie>> fetchMovies() async {
    try {
      final records = await pb
          .collection('movies')
          .getFullList(sort: '-release_year')
          .timeout(const Duration(seconds: 10));
      return records.map(Movie.fromRecord).toList();
    } on TimeoutException {
      throw Exception('Server không phản hồi sau 10 giây (${AppConfig.pbUrl}).');
    } on ClientException catch (e) {
      throw Exception(_explain(e));
    }
  }

  static String _explain(ClientException e) {
    switch (e.statusCode) {
      case 0:
        return 'Không kết nối được tới ${AppConfig.pbUrl}. '
            'Kiểm tra server, địa chỉ và quyền INTERNET.';
      case 403:
        return 'Server từ chối đọc dữ liệu. Kiểm tra quy tắc List của collection movies.';
      case 404:
        return 'Không tìm thấy collection movies. Kiểm tra tên collection và địa chỉ server.';
      default:
        return 'Lỗi server (${e.statusCode}).';
    }
  }
}
```

Khi mất mạng hoặc sai địa chỉ, SDK trả `ClientException` với `statusCode` bằng 0, nên nhánh `case 0` bắt đúng lỗi kết nối. Hàm này giúp màn hình hiện thông điệp dễ hiểu thay vì một chuỗi lỗi khó đọc.

### B6. Smoke test: kiểm tra API và video trước khi làm giao diện

Thay tạm `lib/main.dart` bằng đoạn sau. Nó liệt kê các phim và cho bạn bấm vào từng phim để thử phát video:

```dart
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'models/movie_model.dart';
import 'services/pocketbase_service.dart';

void main() => runApp(const MaterialApp(home: SmokeTest()));

class SmokeTest extends StatelessWidget {
  const SmokeTest({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Smoke test')),
      body: FutureBuilder<List<Movie>>(
        future: PocketBaseService.fetchMovies(),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('${snap.error}'),
              ),
            );
          }
          return ListView(
            children: [
              for (final m in snap.data!)
                ListTile(
                  title: Text(m.title),
                  subtitle: Text('${m.category} • ${m.releaseYear}'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => VideoTest(url: m.videoUrl)),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class VideoTest extends StatefulWidget {
  final String url;
  const VideoTest({super.key, required this.url});

  @override
  State<VideoTest> createState() => _VideoTestState();
}

class _VideoTestState extends State<VideoTest> {
  late final VideoPlayerController _c;
  String? _error;

  @override
  void initState() {
    super.initState();
    _c = VideoPlayerController.networkUrl(Uri.parse(widget.url));
    _c.initialize().then((_) {
      if (!mounted) return;
      setState(() {});
      _c.play();
    }).catchError((e) {
      if (mounted) setState(() => _error = '$e');
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Video test')),
      body: Center(
        child: _error != null
            ? Text(_error!)
            : _c.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _c.value.aspectRatio,
                    child: VideoPlayer(_c),
                  )
                : const CircularProgressIndicator(),
      ),
    );
  }
}
```

### B7. Chạy app

Thứ tự bắt buộc:
1. Backend đang chạy. Nếu dùng máy thật qua LAN, chạy server bằng `./pocketbase serve --http="0.0.0.0:8090"`. Mặc định server chỉ nghe ở `127.0.0.1` nên điện thoại không vào được.
2. `flutter devices` thấy thiết bị của bạn.
3. `flutter run --dart-define=PB_URL=<địa chỉ từ bảng B3>`.

### B8. Bảng kiểm tra kết nối (làm đủ rồi mới qua giao diện)

1. Màn hình liệt kê đủ 9 phim, phim mới nhất đứng đầu.
2. Mở 3 phim bất kỳ, video có hình và có tiếng.
3. Tắt PocketBase (Ctrl+C), mở lại app: thấy thông báo lỗi rõ ràng chứ không treo hay crash.
4. Bật lại PocketBase, chạy lại app: dữ liệu về lại bình thường.
5. Sửa tên một phim trong Dashboard, chạy lại app: thấy tên mới. Điều này chứng minh dữ liệu đến từ server chứ không phải được ghi cứng trong code.

Khi cả 5 mục đạt thì hạ tầng đã ổn. Commit: `add movie model and pocketbase service`.

---

# Phần C. Bảng lỗi thường gặp

| Triệu chứng | Nguyên nhân thường gặp | Cách sửa |
| --- | --- | --- |
| "Không kết nối được" trên emulator | Dùng `localhost` hoặc `127.0.0.1` | Dùng `http://10.0.2.2:8090` hoặc `adb reverse` |
| "Không kết nối được" trên máy thật qua LAN | Server chỉ nghe `127.0.0.1`, firewall chặn, hoặc Wi-Fi cô lập thiết bị | Chạy `serve --http="0.0.0.0:8090"`, cho phép trong firewall, thử `adb reverse` |
| Debug chạy được, APK release thì không | Thiếu quyền INTERNET trong manifest `main`, hoặc APK trỏ tới địa chỉ `http://` | Làm lại B2, build lại với `PB_URL` là `https://` |
| 404 ở danh sách | Sai tên collection hoặc sai địa chỉ gốc | Collection phải tên đúng `movies`, `PB_URL` không có đuôi `/api` |
| 403 ở danh sách | Quy tắc List đang bị khóa | Mở lại quy tắc List/View trong API Rules |
| 200 nhưng danh sách rỗng | Chưa có bản ghi, hoặc migration seed chưa chạy | Xem Dashboard, xóa `pb_data` rồi chạy lại nếu cần |
| 400 khi gọi danh sách | Sai tên trường trong `sort` | Tên trường là `release_year`, kiểm tra lại chính tả |
| Lỗi "Null is not a subtype of String" | Dữ liệu thiếu và code đọc thẳng | Dùng model ở B4 |
| Ô poster trống | Link ảnh chết | Làm lại A6 |
| Video đen hoặc lỗi "Source error" | Link không phải file `.mp4` trực tiếp, link chết, hoặc dùng `http://` mà thiếu cấu hình | Mở link trên trình duyệt để thử, đảm bảo video dùng `https://` |
| Đổi `--dart-define` mà app vẫn dùng địa chỉ cũ | Hot reload không nạp lại biến | Dừng hẳn và chạy lại |
| Tunnel đổi địa chỉ làm app không kết nối | Địa chỉ trong APK là địa chỉ cũ | Build lại APK với địa chỉ mới |
| macOS chặn chạy `pocketbase` | Gatekeeper | Chạy `xattr -d com.apple.quarantine` như ở A1 |

---

# Phần D. Kiểm thử bản release trước khi nộp

Bắt buộc làm trên điện thoại thật, vì lỗi quyền Internet chỉ lộ ra ở bản release:

```bash
flutter build apk --release --dart-define=PB_URL=https://<địa chỉ server>
flutter install
```

Sau đó thử:
1. Mở app khi bật Wi-Fi: dữ liệu và video chạy bình thường.
2. Tắt Wi-Fi, dùng dữ liệu di động: vẫn chạy. Việc này loại trừ khả năng app chỉ chạy được nhờ mạng LAN của bạn.
3. Bật chế độ máy bay rồi mở app: thấy thông báo lỗi, không crash.
4. Nhờ một người khác cài APK từ link tải và mở thử trên máy của họ.

---

# Phần E. Bằng chứng nên chụp lại cho báo cáo

1. Dashboard hiện collection `movies` với 7 trường.
2. Tab API Rules cho thấy List/View mở, các quy tắc ghi bị khóa.
3. Kết quả JSON của danh sách phim.
4. Kết quả lệnh `curl` ghi dữ liệu trả 403.
5. Màn hình app hiển thị dữ liệu thật từ server (smoke test).
6. Ảnh APK release chạy trên máy thật.
7. Lịch sử commit trên GitHub, trong đó có thư mục `backend/pb_migrations`.

Bạn muốn mình tiếp tục với bước nào: viết chi tiết cách deploy lên host bạn chọn (tunnel, PocketBase Cloud hay PocketHost), hay gom toàn bộ hướng dẫn này thành file hướng dẫn để bạn lưu lại?