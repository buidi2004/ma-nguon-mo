# Kế hoạch nâng cấp OpenFlix lên 42 màn hình

Kế hoạch 7 ngày ban đầu chỉ đủ cho phần lõi (khoảng 11 màn). Để làm hơn 30 màn mà vẫn chạy ổn, bạn cần hai thứ: làm theo mốc, và dùng chung một bộ khối giao diện để các màn không phải viết lại từ đầu. Tổng thời gian khoảng 16 ngày làm việc tập trung, hoặc 14 ngày với phương án rút gọn ở mục 7.

**Quy ước đếm màn hình:** một màn hình là một route riêng, tức một trang đầy đủ có nút Back. Bottom sheet, dialog, và trạng thái trống nằm trong trang không được tính. Ghi quy ước này vào báo cáo để con số 42 có căn cứ.

---

## 1. Danh sách màn hình

Ưu tiên: P0 là lõi bắt buộc, P1 là tài khoản và cá nhân hóa, P2 là mở rộng nội dung, P3 là bổ trợ. Tính từ P0 đến P2 là 34 màn, vượt mốc 30.

### Nhóm A. Khởi động và tài khoản (8 màn)

| Mã | Màn hình | Nội dung chính | Dữ liệu | Ưu tiên |
| --- | --- | --- | --- | --- |
| S01 | Splash | Wordmark đỏ nền đen, kiểm tra phiên đăng nhập rồi điều hướng | Bộ nhớ máy | P0 |
| S02 | Giới thiệu | 3 trang vuốt, chỉ hiện lần đầu | `shared_preferences` | P1 |
| S03 | Chào mừng | Đăng nhập, Đăng ký, hoặc Xem thử không cần tài khoản | Không | P1 |
| S04 | Đăng nhập | Email, mật khẩu, ẩn/hiện mật khẩu, báo lỗi rõ | `users` | P1 |
| S05 | Đăng ký | Tên, email, mật khẩu, xác nhận mật khẩu | `users` | P1 |
| S06 | Quên mật khẩu | Nhập email để gửi yêu cầu đặt lại | `users` (cần SMTP) | P3 |
| S07 | Chọn hồ sơ | "Ai đang xem?", lưới avatar | `profiles` | P2 |
| S08 | Tạo/sửa hồ sơ | Tên, màu avatar, chế độ trẻ em | `profiles` | P2 |

### Nhóm B. Khám phá (9 màn)

| Mã | Màn hình | Nội dung chính | Dữ liệu | Ưu tiên |
| --- | --- | --- | --- | --- |
| S09 | Trang chủ | Banner, chip thể loại, các hàng poster, hàng "Tiếp tục xem" | `movies` | P0 |
| S10 | Tìm kiếm | Ô tìm, lịch sử tìm, danh sách gợi ý thịnh hành | `movies`, bộ nhớ máy | P0 |
| S11 | Kết quả tìm kiếm | Lưới poster theo từ khóa | `movies` | P0 |
| S12 | Bộ lọc nâng cao | Thể loại, năm, sắp xếp | `movies` | P2 |
| S13 | Danh sách thể loại | Các thể loại dưới dạng thẻ | `movies` | P2 |
| S14 | Phim theo thể loại | Lưới poster của một thể loại | `movies` | P0 |
| S15 | Xem tất cả | Toàn bộ phim của một hàng ngang | `movies` | P0 |
| S16 | Mới và Hot | Phim mới, sắp chiếu | `movies` | P2 |
| S17 | Top 10 | Xếp hạng có số lớn | `movies` | P2 |

### Nhóm C. Xem phim (7 màn)

| Mã | Màn hình | Nội dung chính | Dữ liệu | Ưu tiên |
| --- | --- | --- | --- | --- |
| S18 | Chi tiết phim | Xem trước, thông tin, nút Phát, Thêm vào danh sách, Thích | `movies`, `my_list`, `likes` | P0 |
| S19 | Trailer | Phát đoạn giới thiệu | `movies` | P2 |
| S20 | Trình phát | Chewie, nút ±10s, thanh tiến trình đỏ, lưu tiến độ | `movies`, `watch_progress` | P0 |
| S21 | Chọn tập | Mùa và danh sách tập | `episodes` | P3 |
| S22 | Phim tương tự | Lưới phim cùng thể loại | `movies` | P2 |
| S23 | Đánh giá và bình luận | Điểm trung bình, danh sách bình luận | `reviews` | P2 |
| S24 | Viết đánh giá | Chấm sao, nhập bình luận | `reviews` | P2 |

### Nhóm D. Cá nhân (5 màn)

| Mã | Màn hình | Nội dung chính | Dữ liệu | Ưu tiên |
| --- | --- | --- | --- | --- |
| S25 | Danh sách của tôi | Lưới phim đã thêm, bỏ thêm | `my_list` | P1 |
| S26 | Đang xem dở | Thanh tiến độ dưới poster, bấm để xem tiếp | `watch_progress` | P1 |
| S27 | Lịch sử xem | Danh sách theo thời gian | `watch_progress` | P1 |
| S28 | Phim đã thích | Lưới phim đã thích | `likes` | P1 |
| S29 | Thông báo | Danh sách thông báo, đánh dấu đã đọc | `notifications` | P3 |

### Nhóm E. Tài khoản và cài đặt (10 màn)

| Mã | Màn hình | Nội dung chính | Dữ liệu | Ưu tiên |
| --- | --- | --- | --- | --- |
| S30 | Tôi | Avatar, tên, lối vào các mục cá nhân | `users` | P1 |
| S31 | Thông tin tài khoản | Sửa tên, tải ảnh đại diện | `users` | P1 |
| S32 | Đổi mật khẩu | Mật khẩu cũ, mới, xác nhận | `users` | P1 |
| S33 | Cài đặt | Danh sách mục cài đặt | Bộ nhớ máy | P1 |
| S34 | Phát lại và chất lượng | Tự phát tập tiếp, tự phát trailer | Bộ nhớ máy | P1 |
| S35 | Ngôn ngữ | Tiếng Việt, English | Bộ nhớ máy | P3 |
| S36 | Trợ giúp | Câu hỏi thường gặp dạng xổ xuống | `faqs` | P3 |
| S37 | Liên hệ và phản hồi | Form gửi góp ý | `feedback` | P3 |
| S38 | Giới thiệu và giấy phép | Phiên bản, MIT, danh sách thư viện, link GitHub | Không | P0 |
| S42 | Gói thành viên (mô phỏng) | Giao diện chọn gói, ghi rõ là minh họa | Không | P3 |

### Nhóm F. Trạng thái toàn trang (3 màn)

| Mã | Màn hình | Nội dung chính | Ưu tiên |
| --- | --- | --- | --- |
| S39 | Mất kết nối | Biểu tượng, thông báo, nút Thử lại | P0 |
| S40 | Lỗi và thử lại | Thông điệp lỗi rõ nguyên nhân | P0 |
| S41 | Không tìm thấy | Trang dự phòng khi route hoặc phim không tồn tại | P3 |

**Tổng cộng:** P0 có 11 màn, P1 có 13, P2 có 10, P3 có 8, tổng 42 màn hình.

---

## 2. Bản đồ điều hướng

Bottom nav có 4 tab: Trang chủ, Tìm kiếm, Mới và Hot, Tôi. Tên route cho `go_router`:

```text
/splash                  S01          /movie/:id               S18
/onboarding              S02          /movie/:id/trailer       S19
/welcome                 S03          /watch/:id               S20
/login                   S04          /movie/:id/episodes      S21
/register                S05          /movie/:id/similar       S22
/forgot-password         S06          /movie/:id/reviews       S23
/profiles                S07          /movie/:id/reviews/new   S24
/profiles/edit/:id       S08          /me/list                 S25
/                        S09 (tab)    /me/continue             S26
/search                  S10 (tab)    /me/history              S27
/search/results?q=       S11          /me/liked                S28
/search/filter           S12          /me/notifications        S29
/genres                  S13          /me                      S30 (tab)
/genre/:name             S14          /me/account              S31
/see-all/:rowKey         S15          /me/password             S32
/hot                     S16 (tab)    /settings                S33
/top10                   S17          /settings/playback       S34
                                      /settings/language       S35
                                      /help                    S36
                                      /contact                 S37
                                      /about                   S38
                                      /offline                 S39
                                      /error                   S40
                                      (route không khớp)       S41
                                      /plans                   S42
```

**Quyết định về đăng nhập:** Cho phép xem thử không cần tài khoản. Các màn cần dữ liệu cá nhân (S25-S29, S31, S32) thì `go_router` tự chuyển về S04 nếu chưa đăng nhập. Làm vậy phần lõi chạy độc lập, không phải chờ xong phần tài khoản.

---

## 3. Nâng cấp backend PocketBase

### Trường mới cho `movies`

| Trường | Kiểu | Dùng ở |
| --- | --- | --- |
| `trailer_url` | URL | S19 |
| `duration_minutes` | Number (số nguyên) | S18 |
| `age_rating` | Text (ví dụ "13+") | S18 |
| `director` | Text | S18 |
| `cast` | Text, các tên cách nhau bằng dấu phẩy | S18 |
| `rank` | Number | S17 |
| `is_new` | Bool | S16 |
| `coming_soon` | Bool | S16 |

### Các collection mới

| Collection | Trường chính | Giai đoạn |
| --- | --- | --- |
| `users` (có sẵn) | `name`, `avatar` (file), `email` | G2 |
| `my_list` | `user`, `movie` | G3 |
| `watch_progress` | `user`, `movie`, `position_seconds`, `duration_seconds` | G3 |
| `likes` | `user`, `movie`, `value` (like/dislike) | G3 |
| `profiles` | `user`, `name`, `color`, `is_kids` | G4 |
| `reviews` | `user`, `movie`, `rating` (1-5), `comment` | G4 |
| `episodes` | `movie`, `season`, `number`, `title`, `video_url` | G5 |
| `notifications` | `user` (để trống nghĩa là gửi chung), `title`, `body`, `is_read` | G5 |
| `faqs` | `question`, `answer`, `order` | G5 |
| `feedback` | `user`, `email`, `message` | G5 |

### Quy tắc API

| Collection | List/View | Create | Update | Delete |
| --- | --- | --- | --- | --- |
| `movies`, `episodes`, `faqs` | Mở cho mọi người | Khóa | Khóa | Khóa |
| `my_list`, `watch_progress`, `likes`, `profiles` | `user = @request.auth.id` | `@request.auth.id != '' && @request.body.user = @request.auth.id` | `user = @request.auth.id` (`my_list` thì khóa) | `user = @request.auth.id` |
| `reviews` | Mở cho mọi người | Như trên | `user = @request.auth.id` | `user = @request.auth.id` |
| `notifications` | `user = @request.auth.id \|\| user = ''` | Khóa | `user = @request.auth.id` | Khóa |
| `feedback` | Khóa | `@request.auth.id != ''` | Khóa | Khóa |

---

## 4. Nâng cấp kiến trúc Flutter

```text
lib/
├── core/
│   ├── theme/            # AppColors, buildTheme
│   ├── router/           # go_router, route guard
│   ├── widgets/          # khối giao diện dùng chung
│   └── config.dart
├── data/
│   ├── models/           # Movie, Review, ...
│   └── repositories/     # MovieRepository, LibraryRepository, AuthRepository...
├── features/
│   ├── auth/             # S01-S06
│   ├── discover/         # S09-S17
│   ├── watch/            # S18-S24
│   ├── library/          # S25-S29
│   ├── account/          # S07, S08, S30-S38, S42
│   └── system/           # S39-S41
└── main.dart
```

### Thư viện bổ sung
```bash
flutter pub add go_router provider shared_preferences shimmer connectivity_plus image_picker url_launcher package_info_plus
```

### Khối UI dùng chung
- `AppTextField` + `PrimaryButton`
- `MovieGrid`
- `SettingsTile`
- `ProfileAvatar`
- `RatingStars`
- `MovieRow` + `SectionHeader`
- `VideoScaffold`
- `StateView`

---

## 5. Lộ trình theo mốc

| Giai đoạn | Số ngày | Màn hình | Backend | Xong khi |
| --- | --- | --- | --- | --- |
| G0 Nền tảng | 1 | Khung 42 route với màn hình placeholder | Không | Bấm qua mọi route không crash, 4 tab hoạt động |
| G1 Lõi | 3 | S01, S09, S10, S11, S14, S15, S18, S20, S38, S39, S40 | Thêm trường `movies`, tăng dữ liệu lên ~24 bản ghi | Bảng kiểm kết nối đạt, mọi màn có loading và lỗi |
| G2 Tài khoản | 3 | S02, S03, S04, S05, S30, S31, S32, S33, S34 | Cấu hình `users`, quy tắc API | Đăng ký, đăng nhập, giữ phiên |
| G3 Thư viện | 2 | S25, S26, S27, S28 | `my_list`, `watch_progress`, `likes` | Hai tài khoản phân tách dữ liệu rõ ràng |
| G4 Mở rộng | 3 | S07, S08, S12, S13, S16, S17, S19, S22, S23, S24 | `profiles`, `reviews` | Đánh giá, lọc nâng cao hoạt động |
| G5 Bổ trợ | 2 | S06, S21, S29, S35, S36, S37, S41, S42 | `episodes`, `notifications`, `faqs`, `feedback` | Gửi feedback, FAQs hoạt động |
| G6 Hoàn thiện | 2 | Không | Không | Test máy thật, báo cáo & slide hoàn tất |
