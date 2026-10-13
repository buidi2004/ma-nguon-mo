Mockup trên là bố cục đích cho hai màn hình quan trọng nhất. Dưới đây là phần phân tích: giống ở đâu, giống bằng cách nào trong Flutter, và đâu là chỗ không nên copy.

## 1. Ngôn ngữ thiết kế của Netflix mobile

Giao diện Netflix dựa trên 5 nguyên tắc. Bạn cần giữ đủ 5 nguyên tắc này thì app mới cho cảm giác giống:

1. Nền gần đen, poster là phần sáng nhất màn hình. Người dùng nhìn vào hình trước, chữ sau.
2. Rất ít chrome: không card có viền, không đổ bóng, không đường kẻ. Nội dung nằm thẳng trên nền.
3. Màu đỏ chỉ xuất hiện ở hai chỗ: thương hiệu và thanh tiến trình/tab đang chọn. Nút chính (Phát) màu trắng chứ không phải đỏ.
4. Bo góc nhỏ (khoảng 4px) cho poster và nút. Bo tròn lớn kiểu Material mặc định sẽ làm app trông "Google" hơn "Netflix".
5. Bố cục theo hàng cuộn ngang, luôn để lộ một phần poster thứ 4 để gợi ý người dùng vuốt.

## 2. Design tokens

Các giá trị dưới đây là xấp xỉ, đủ để cho cảm giác giống, không phải thông số chính thức của Netflix.

| Token | Giá trị | Dùng cho |
| --- | --- | --- |
| `background` | `#141414` | Nền mọi màn hình |
| `surface` | `#2A2A2A` | Ô tìm kiếm, nút phụ, placeholder poster |
| `red` | `#E50914` | Wordmark, thanh tiến trình, gạch trên tab |
| `textPrimary` | `#FFFFFF` | Tiêu đề, nút Phát |
| `textSecondary` | `#B3B3B3` | Mô tả, năm, thể loại |
| `textMuted` | `#808080` | Icon tab chưa chọn, chú thích |

| Kiểu chữ | Cỡ và độ đậm | Dùng cho |
| --- | --- | --- |
| Tiêu đề hero | 22, `w700` | Tên phim ở banner và trang chi tiết |
| Tiêu đề hàng | 16, `w700` | "Phổ biến", "Hoạt hình" |
| Thân | 14, `w400`, màu secondary | Mô tả phim |
| Chú thích | 12, màu secondary | Năm, thể loại, nhãn tab |

Font gốc của Netflix (Netflix Sans) là font độc quyền, nên dùng `Roboto` mặc định của Android. Bạn không cần cài thêm gói nào mà vẫn đủ gần. Mockup phía trên chỉ minh họa bố cục, còn trong code hãy dùng `w700` cho tiêu đề.

Kích thước và khoảng cách:

| Thành phần | Giá trị |
| --- | --- |
| Tỷ lệ poster | 2:3 |
| Chiều rộng poster trong hàng | `screenWidth / 3.4` (hiện 3 poster và lộ khoảng 40% poster thứ 4) |
| Khoảng cách giữa poster | 6 |
| Lề hai bên | 12 |
| Bo góc poster và nút | 4 |
| Chiều cao hero | khoảng 55% chiều cao màn hình, dùng poster dọc với `BoxFit.cover` |

Một điểm có lợi cho bạn: hero của Netflix mobile là ảnh dọc. Vì vậy cùng một trường `poster_url` trong database dùng được cho cả banner lẫn poster trong hàng, không cần thêm trường `banner_url`.

## 3. Phân tích từng màn hình

| Màn hình | Điểm đặc trưng cần bắt chước | Widget Flutter gợi ý |
| --- | --- | --- |
| Home | App bar trong suốt đè lên hero, hàng chip thể loại, hero có lớp mờ dần xuống nền, nút Phát (trắng) và Thông tin (xám), các hàng poster | `Stack`, `LinearGradient`, `ListView` ngang |
| Tìm kiếm | Ô nhập nền xám đậm. Khi chưa gõ, hiện danh sách dọc "Phim đang thịnh hành" (ảnh 16:9 bên trái, tên giữa, nút play tròn bên phải). Khi gõ, hiện lưới 3 cột poster | `TextField`, `ListView`, `GridView` 3 cột |
| Chi tiết | Vùng xem trước 16:9 có nút play tròn lớn, tên phim, năm, nhãn HD, nút Phát trắng full chiều ngang, mô tả, tab "Phim tương tự" có gạch đỏ phía trên | `Hero` animation từ poster, `CustomScrollView` |
| Player | Ép xoay ngang, nền đen, ẩn thanh trạng thái, điều khiển tự ẩn sau vài giây, nút tua ±10s ở giữa, thanh tiến trình đỏ | `Chewie`, `SystemChrome` |
| Giới thiệu | Màn hình thêm cho bài môn học: giấy phép MIT, danh sách thư viện mở, link GitHub | `ListView` đơn giản |

Về thanh điều hướng dưới: Material 3 mặc định có viền bầu dục quanh icon đang chọn, còn Netflix thì không. Chỉ cần đặt `indicatorColor: Colors.transparent` và đổi màu icon (trắng khi chọn, xám khi không chọn) là đủ giống.

Về player, cấu hình để giống:
- Thanh tiến trình đỏ: truyền `materialProgressColors` cho `ChewieController`, với `playedColor` và `handleColor` màu đỏ, `bufferedColor` trắng mờ.
- Ép xoay ngang khi vào toàn màn hình: `deviceOrientationsOnEnterFullScreen`.
- Ẩn thanh trạng thái và thanh điều hướng của Android: `SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky)`. Nhớ khôi phục chế độ cũ trong `dispose`.

Tên tham số có thể khác chút tùy phiên bản `chewie` bạn cài, nên kiểm tra lại trong tài liệu trên pub.dev.

## 4. Các chi tiết nhỏ tạo nên cảm giác "giống"

Xếp theo hiệu quả trên công sức, nên làm từ trên xuống:

| Chi tiết | Cách làm | Công sức |
| --- | --- | --- |
| Nền đen và chữ trắng toàn app | Theme ở mục 5 | Thấp |
| Lớp mờ dần dưới hero | `DecoratedBox` với `LinearGradient` từ `Colors.transparent` xuống `AppColors.background`, `stops: [0.5, 1.0]` | Thấp |
| App bar trong suốt đè lên hero | `extendBodyBehindAppBar: true` | Thấp |
| Hàng poster lộ một phần poster thứ 4 | `screenWidth / 3.4` | Thấp |
| Placeholder xám khi ảnh đang tải | `CachedNetworkImage` với `placeholder` màu `#2A2A2A` và `fadeInDuration` ngắn | Thấp |
| Poster bay sang trang chi tiết | `Hero(tag: movie.id)` bọc poster ở cả hai màn hình | Thấp |
| Thanh nav không có viền bầu dục | `indicatorColor: Colors.transparent` | Thấp |
| Điều khiển player tự ẩn | Chewie có sẵn, chỉnh `hideControlsTimer` | Thấp |
| Splash đen với wordmark đỏ | Gói `flutter_native_splash` | Trung bình |
| Hero tự phát trailer ngắn (Netflix có làm) | `video_player` im lặng, lặp lại | Cao, để làm nếu còn thời gian |

## 5. Code nền: theme và hàng poster

Tạo file `lib/theme/app_theme.dart`:

```dart
import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFF141414);
  static const surface = Color(0xFF2A2A2A);
  static const red = Color(0xFFE50914);
  static const textSecondary = Color(0xFFB3B3B3);
  static const textMuted = Color(0xFF808080);
}

ThemeData buildTheme() => ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.red,
        surface: AppColors.background,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.background,
        indicatorColor: Colors.transparent,
        iconTheme: WidgetStateProperty.resolveWith((s) => IconThemeData(
              color: s.contains(WidgetState.selected)
                  ? Colors.white
                  : AppColors.textMuted,
            )),
        labelTextStyle: WidgetStateProperty.resolveWith((s) => TextStyle(
              fontSize: 11,
              color: s.contains(WidgetState.selected)
                  ? Colors.white
                  : AppColors.textMuted,
            )),
      ),
    );
```

Tạo file `lib/widgets/movie_row.dart`:

```dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/movie_model.dart';
import '../theme/app_theme.dart';

class MovieRow extends StatelessWidget {
  final String title;
  final List<Movie> movies;
  final void Function(Movie) onTap;

  const MovieRow({
    super.key,
    required this.title,
    required this.movies,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final posterWidth = MediaQuery.sizeOf(context).width / 3.4;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
          child: Text(title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        ),
        SizedBox(
          height: posterWidth * 1.5,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: movies.length,
            separatorBuilder: (_, __) => const SizedBox(width: 6),
            itemBuilder: (_, i) => GestureDetector(
              onTap: () => onTap(movies[i]),
              child: Hero(
                tag: movies[i].id,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: CachedNetworkImage(
                    imageUrl: movies[i].posterUrl,
                    width: posterWidth,
                    fit: BoxFit.cover,
                    placeholder: (_, __) =>
                        const ColoredBox(color: AppColors.surface),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
```

Trong `main.dart`, đặt `theme: buildTheme()` cho `MaterialApp`.

## 6. Cập nhật cấu trúc thư mục

Bản trước có `home_screen.dart` chứa cả tìm kiếm. Để giống Netflix hơn, tách thêm vài file:

```text
lib/
├── theme/app_theme.dart          # màu, theme tối
├── models/movie_model.dart
├── services/pocketbase_service.dart
├── screens/
│   ├── main_shell.dart           # thanh nav dưới + IndexedStack
│   ├── home_screen.dart          # hero + các hàng
│   ├── search_screen.dart        # ô tìm kiếm + lưới kết quả
│   ├── detail_screen.dart        # chi tiết phim
│   ├── player_screen.dart
│   └── about_screen.dart         # giấy phép, thư viện, GitHub
├── widgets/
│   ├── hero_banner.dart
│   ├── movie_row.dart
│   └── movie_card.dart
└── main.dart
```

Nếu muốn giữ đơn giản, bạn vẫn có thể để tìm kiếm trong Home như kế hoạch cũ, chỉ mất phần tab tìm kiếm riêng. Tách ra thì giống Netflix hơn nhưng thêm khoảng nửa ngày công.

## 7. Cái gì nên và không nên copy

Nên copy: bố cục, nhịp màu, kiểu tương tác. Đây là những thứ làm nên "cảm giác giống".

Không nên copy:
- Logo chữ N, tên "Netflix", font Netflix Sans và các tagline. Đây là tài sản thương hiệu, dùng trong báo cáo mã nguồn mở sẽ phản tác dụng. Dùng wordmark "OpenFlix" của riêng bạn bằng chữ đỏ.
- Poster hay ảnh phim thương mại. Hãy dùng poster của phim Blender (Big Buck Bunny, Sintel, Elephants Dream, Tears of Steel) và ghi nguồn cùng giấy phép trong README.

Nên bỏ qua vì nằm ngoài phạm vi 7 ngày: chọn hồ sơ người dùng, tải offline, bảng xếp hạng Top 10, đề xuất cá nhân hóa.

## 8. Thứ tự làm trong lộ trình

Phần này thay cho ngày 3-5 của kế hoạch trước:

| Ngày | Việc UI | Xong khi |
| --- | --- | --- |
| 3 | `app_theme.dart`, `HeroBanner`, `MovieRow`, ghép thành Home | Mở app thấy nền đen, banner và các hàng cuộn ngang |
| 4 | `MainShell` với nav dưới, `SearchScreen`, `DetailScreen` có `Hero` | Chạm poster sang trang chi tiết mượt, tìm kiếm ra lưới poster |
| 5 | Player: thanh đỏ, ép xoay ngang, ẩn system UI, nút ±10s | Xem phim toàn màn hình, thoát ra app về lại dọc |
| 6 | Placeholder tải ảnh, splash, `AboutScreen`, test máy thật | Không còn khung trắng nhấp nháy khi mạng chậm |

## 9. Tự kiểm tra "đã giống Netflix chưa"

1. Mở app lên, nền có đen gần như đồng nhất, không còn viền hay đổ bóng nào của Material?
2. Màu đỏ chỉ xuất hiện ở wordmark, thanh tiến trình và gạch tab?
3. Nút Phát là nút trắng, nổi nhất màn hình?
4. Mỗi hàng poster lộ một phần poster thứ 4?
5. Banner có lớp mờ dần xuống nền thay vì cắt cứng?
6. Bấm poster thì poster bay sang trang chi tiết?
7. Trong player, điều khiển tự ẩn và thanh tiến trình màu đỏ?
8. Thanh nav dưới không có viền bầu dục quanh icon đang chọn?

Bạn muốn mình viết luôn code hoàn chỉnh cho `HeroBanner` và `HomeScreen` (banner, chip thể loại, các hàng, trạng thái loading/lỗi) để bạn dán vào chạy ngay không?