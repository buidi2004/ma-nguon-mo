# BÁO CÁO TỐI ƯU GIAO DIỆN & TRẢI NGHIỆM 42 MÀN HÌNH (S01 – S42) OPENFLIX

Dự án OpenFlix đã được tối ưu toàn diện từ giao diện (UI), trải nghiệm người dùng (UX) đến kiến trúc mã nguồn Flutter (Clean Component Architecture). Toàn bộ 42 màn hình đều được hiện thực hóa đầy đủ, đồng bộ tuyệt đối về ngôn ngữ thiết kế Netflix Dark Cinema, không sử dụng màn hình giữ chỗ (placeholder) tạm bợ.

---

## 1. Tối ưu thiết kế chung cho toàn bộ 42 màn hình

### 1.1. Hệ thống màu sắc & Kiểu chữ (Design System)
- **Nền chính (Background):** Màu đen điện ảnh `#141414` tạo chiều sâu tập trung vào nội dung phim.
- **Thẻ & Bề mặt (Surface / Card):** `#2A2A2A` kết hợp đường viền mảnh `Colors.white10` (0.8px) phân tách khối tinh tế.
- **Màu điểm nhấn (Accent):** Đỏ Netflix `#E50914` áp dụng đồng bộ cho các nút chính, thanh tiến trình (progress bar), tab đang chọn, nhãn "HOT" / "MỚI", và thứ hạng Top 10.
- **Chữ & Phân cấp thị giác:**
  - Tiêu đề chính: Trắng tinh `#FFFFFF`, độ đậm `w800`–`w900`.
  - Phụ đề / Mô tả: Xám nhạt `#B3B3B3` và `#808080`, cỡ chữ 11–13pt, ngắt dòng thông minh không bị tràn viền (overflow).

### 1.2. Thích ứng kích thước màn hình (Responsive Mobile Layout)
- **Điện thoại nhỏ (< 360dp):** Tự động dàn lưới 2 cột poster giúp ảnh không bị thu nhỏ quá mức, dễ chạm bấm.
- **Điện thoại tiêu chuẩn (360dp – 600dp):** Lưới 3 cột poster với tỷ lệ dọc 2:3 chuẩn điện ảnh (`childAspectRatio: 0.68`).
- **Màn hình rộng / Tablet (>= 600dp):** Tự động mở rộng 4–6 cột poster, tận dụng không gian hiển thị.
- **Tỷ lệ ảnh Poster:** Áp dụng `CachedNetworkImage` kèm hiệu ứng nền chờ (placeholder) và xử lý lỗi tải ảnh (error fallback) có tên phim dự phòng.

### 1.3. Tối ưu thao tác & Luồng điều hướng (Frictionless UX)
- **Thanh điều hướng dưới (AppBottomNav):** 4 tab cốt lõi: Trang chủ (S09), Tìm kiếm (S10), Mới & Hot (S16), Tôi (S30).
- **Phím tắt liên kết trực tiếp:**
  - Từ màn hình Chi tiết (S18) có thể mở ngay: Xem Trailer (S19), Phát phim (S20), Chọn tập (S21), Phim tương tự (S22), Đánh giá (S23) chỉ với 1 chạm.
  - Từ Trang chủ (S09) có thể mở ngay: Tiếp tục xem (S26), Top 10 (S17), Thể loại (S14).

---

## 2. Danh mục chi tiết 42 màn hình được tối ưu (S01 – S42)

### Nhóm A — Khởi động & Tài khoản (8 màn hình)
| Mã | Tên màn hình | File thực thi | Chi tiết tối ưu giao diện & UX |
|---|---|---|---|
| **S01** | Splash Screen | `lib/features/auth/splash_screen.dart` | Logo OpenFlix đỏ nổi bật, hiệu ứng nạp mượt mà, kiểm tra phiên đăng nhập tự động điều hướng |
| **S02** | Giới thiệu (Onboarding) | `lib/features/auth/onboarding_screen.dart` | 3 trang vuốt minh họa sống động, chỉ báo trang (dot indicator), nút Bỏ qua / Bắt đầu |
| **S03** | Chào mừng (Welcome) | `lib/features/auth/welcome_screen.dart` | Hình nền điện ảnh ấn tượng, nút nổi bật Đăng nhập, Đăng ký và nút "Xem thử ngay" (Guest) |
| **S04** | Đăng nhập (Login) | `lib/features/auth/login_screen.dart` | Ô nhập email, mật khẩu có nút ẩn/hiện, bắt lỗi validate trực tiếp tại ô nhập |
| **S05** | Đăng ký (Register) | `lib/features/auth/register_screen.dart` | Sắp xếp trường nhập tên, email, mật khẩu và xác nhận mật khẩu; kiểm tra độ dài an toàn |
| **S06** | Quên mật khẩu | `lib/features/auth/forgot_password_screen.dart` | Nhập email nhận mã khôi phục, hiển thị trạng thái đã gửi thành công kèm thông báo rõ ràng |
| **S07** | Chọn hồ sơ (Profiles) | `lib/features/account/profiles_screen.dart` | Giao diện "Ai đang xem?", lưới avatar nhiều màu, phân biệt hồ sơ Người lớn / Trẻ em, nút Thêm hồ sơ |
| **S08** | Tạo / Sửa hồ sơ | `lib/features/account/profile_edit_screen.dart` | Chọn màu đại diện bảng màu Netflix, đổi tên hiển thị, công tắc bật chế độ Trẻ em (Kids Mode) |

### Nhóm B — Khám phá phim (9 màn hình)
| Mã | Tên màn hình | File thực thi | Chi tiết tối ưu giao diện & UX |
|---|---|---|---|
| **S09** | Trang chủ (Home) | `lib/screens/home_screen.dart` | Banner nổi bật (HeroBanner), hàng "Tiếp tục xem", hàng phim theo thể loại cuộn ngang tỷ lệ 3.4 peek |
| **S10** | Tìm kiếm (Search) | `lib/features/discover/search_screen.dart` | Ô tìm kiếm tức thì, danh sách xu hướng đang thịnh hành, nút truy cập bộ lọc nâng cao |
| **S11** | Kết quả tìm kiếm | `lib/features/discover/search_screen.dart` | Lưới poster co giãn thông minh, hiển thị nhãn thể loại, thông báo khi không có kết quả |
| **S12** | Bộ lọc nâng cao | `lib/features/discover/filter_screen.dart` | Bộ lọc kết hợp thể loại, năm phát hành, thứ tự sắp xếp; nút "Đặt lại" và "Áp dụng" |
| **S13** | Danh sách thể loại | `lib/features/discover/genres_screen.dart` | Thẻ danh mục phong cách gradient màu nổi bật kèm biểu tượng đại diện từng thể loại |
| **S14** | Phim theo thể loại | `lib/features/discover/movie_grid_screen.dart` | Dùng lại `MovieGrid` đáp ứng, hiển thị tên thể loại ở tiêu đề App Bar |
| **S15** | Xem tất cả (See All) | `lib/features/discover/movie_grid_screen.dart` | Lưới toàn bộ phim của hàng ngang, tránh trùng lặp code giao diện |
| **S16** | Mới và Hot | `lib/features/discover/hot_screen.dart` | Tab phân chia "Phim mới phát hành" và "Sắp chiếu / Hot", thẻ phim có nhãn NEW/HOT |
| **S17** | Top 10 thịnh hành | `lib/features/discover/top10_screen.dart` | Số thứ hạng kích thước lớn (1–10) phong cách Netflix, poster rõ ràng, nút xem ngay |

### Nhóm C — Xem phim (7 màn hình)
| Mã | Tên màn hình | File thực thi | Chi tiết tối ưu giao diện & UX |
|---|---|---|---|
| **S18** | Chi tiết phim (Detail) | `lib/features/watch/detail_screen.dart` | Ảnh nền điện ảnh, badge độ tuổi/năm/thời lượng, nút Phát, Trailer, Tập phim, Thích, Danh sách |
| **S19** | Trailer phim | `lib/features/watch/trailer_screen.dart` | Dùng `VideoScaffold`, phát video trailer độc lập, thanh thông tin và nút quay lại chi tiết |
| **S20** | Trình phát (Player) | `lib/screens/player_screen.dart` | Trình phát toàn màn hình (Chewie), tua ±10s, thanh tiến trình đỏ, ghi nhớ vị trí xem dở |
| **S21** | Chọn tập phim | `lib/features/watch/episodes_screen.dart` | Hộp chọn mùa (Season dropdown), danh sách tập có số thứ tự, thời lượng, ảnh trích đoạn |
| **S22** | Phim tương tự | `lib/features/watch/similar_movies_screen.dart` | Lưới poster đồng bộ với kết quả tìm kiếm, gợi ý phim cùng thể loại và đạo diễn |
| **S23** | Đánh giá & Bình luận | `lib/features/watch/reviews_screen.dart` | Thống kê điểm trung bình ở đầu trang, danh sách bình luận cộng đồng kèm thời gian |
| **S24** | Viết đánh giá | `lib/features/watch/write_review_screen.dart` | Chấm sao tương tác (1–5 sao), ô nhận xét cảm nghĩ và nút Gửi đánh giá cố định |

### Nhóm D — Thư viện cá nhân (5 màn hình)
| Mã | Tên màn hình | File thực thi | Chi tiết tối ưu giao diện & UX |
|---|---|---|---|
| **S25** | Danh sách của tôi | `lib/features/library/my_list_screen.dart` | Lưới các bộ phim đã lưu, cập nhật trạng thái tức thì, có thao tác xóa hoặc phát ngay |
| **S26** | Đang xem dở | `lib/features/library/continue_watching_screen.dart` | Thanh tiến độ đỏ dưới mỗi poster phim, bấm để xem tiếp đúng giây đã dừng lại |
| **S27** | Lịch sử xem | `lib/features/library/watch_history_screen.dart` | Sắp xếp phim theo mốc thời gian xem, có thao tác xóa từng phim hoặc xóa toàn bộ lịch sử |
| **S28** | Phim đã thích | `lib/features/library/liked_movies_screen.dart` | Danh sách các phim người dùng đã bấm Like, đồng bộ dữ liệu qua `LibraryService` |
| **S29** | Thông báo hệ thống | `lib/features/account/notifications_screen.dart` | Phân biệt thông báo đã đọc / chưa đọc bằng dấu chấm đỏ, có nút "Đọc tất cả" |

### Nhóm E — Tài khoản & Cài đặt (10 màn hình)
| Mã | Tên màn hình | File thực thi | Chi tiết tối ưu giao diện & UX |
|---|---|---|---|
| **S30** | Tôi (Me Center) | `lib/features/account/me_screen.dart` | Avatar lớn, tên tài khoản, phân nhóm các lối vào thư viện, cài đặt, trợ giúp và đăng xuất |
| **S31** | Thông tin tài khoản | `lib/features/account/account_screen.dart` | Form chỉnh sửa tên hiển thị, xem email tài khoản, chọn avatar |
| **S32** | Đổi mật khẩu | `lib/features/account/password_screen.dart` | Nhập mật khẩu hiện tại, mật khẩu mới, kiểm tra khớp mật khẩu xác nhận |
| **S33** | Cài đặt ứng dụng | `lib/features/account/settings_screen.dart` | Nhóm cài đặt phát lại, ngôn ngữ, dọn bộ nhớ đệm (cache), trung tâm hỗ trợ |
| **S34** | Phát lại & Chất lượng | `lib/features/account/playback_settings_screen.dart` | Công tắc tự phát tập tiếp, tự phát trailer, chọn chất lượng video (Tự động, 1080p, 720p) |
| **S35** | Cài đặt ngôn ngữ | `lib/features/account/language_screen.dart` | Hai lựa chọn Tiếng Việt và English, dấu tích đỏ đánh dấu ngôn ngữ đang chọn |
| **S36** | Trợ giúp & FAQ | `lib/features/system/help_screen.dart` | Ô tìm kiếm câu hỏi, danh sách câu hỏi dạng xổ xuống (`ExpansionTile`) mượt mà |
| **S37** | Liên hệ & Góp ý | `lib/features/system/contact_screen.dart` | Chọn chủ đề phản hồi, nhập nội dung chi tiết và hiển thị modal kết quả gửi thành công |
| **S38** | Giới thiệu & Giấy phép | `lib/features/account/about_screen.dart` | Logo OpenFlix, phiên bản v1.0.0, điều khoản giấy phép MIT, danh sách thư viện mã nguồn mở |
| **S42** | Gói thành viên | `lib/features/account/plans_screen.dart` | Các thẻ gói Cơ bản, Tiêu chuẩn, Cao cấp; bảng so sánh quyền lợi; ghi chú mô phỏng đồ án |

### Nhóm F — Trạng thái hệ thống (3 màn hình)
| Mã | Tên màn hình | File thực thi | Chi tiết tối ưu giao diện & UX |
|---|---|---|---|
| **S39** | Mất kết nối | `lib/features/system/system_status_screen.dart` | Biểu tượng Wi-Fi mất kết nối, giải thích ngắn gọn và nút "Thử lại" |
| **S40** | Báo lỗi hệ thống | `lib/features/system/system_status_screen.dart` | Thông báo sự cố thân thiện, không làm lộ lỗi kỹ thuật phức tạp cho người dùng |
| **S41** | Không tìm thấy (404) | `lib/features/system/not_found_screen.dart` | Icon cuộn phim điện ảnh cách điệu, báo đường dẫn không tồn tại kèm nút "Về Trang chủ" |

---

## 3. Kiến trúc các Widget dùng chung (Reusable Shared Components)

Để đảm bảo nguyên tắc DRY (Don't Repeat Yourself) và tính đồng bộ trên cả 42 màn hình, hệ thống được cấu trúc lại xung quanh các widget dùng chung tại thư mục `lib/core/widgets/`:

1. **`MovieGrid` & `MovieCard` (`lib/core/widgets/movie_grid.dart`, `lib/widgets/movie_card.dart`):**
   - Tự động đo bề rộng màn hình (`MediaQuery`) để chia 2 cột (màn nhỏ), 3 cột (điện thoại chuẩn) hoặc 4–6 cột (tablet).
   - Tích hợp sẵn `rank` (hiển thị số thứ tự lớn cho S17 Top 10), `progressRatio` (thanh tiến trình đỏ cho S26 Đang xem dở) và nhãn "MỚI".
   - Tái sử dụng trên: S09, S11, S14, S15, S17, S22, S25, S26, S28.

2. **`AppTextField` & `PrimaryButton` (`lib/core/widgets/app_text_field.dart`, `lib/core/widgets/primary_button.dart`):**
   - `AppTextField`: Định hình input viền bo cong, nền tối `#2A2A2A`, hỗ trợ ẩn/hiện mật khẩu, icon prefix và kiểm tra lỗi.
   - `PrimaryButton`: Nút bấm đỏ Netflix bo góc 4px, có hiệu ứng `isLoading` xoay vòng và icon bổ trợ.
   - Tái sử dụng trên: S03, S04, S05, S06, S08, S24, S31, S32, S37, S42.

3. **`SettingsTile` & `SettingsSection` (`lib/core/widgets/settings_tile.dart`):**
   - Hộp nhóm giao diện cài đặt với viền bo tròn 12px, phân chia divider tự động thụt lề, trailing tùy biến (chevron, switch, badge, checkmark).
   - Tái sử dụng trên: S30, S31, S33, S34, S35, S36, S38.

4. **`StateView` (`lib/core/widgets/state_view.dart`):**
   - Gom toàn bộ trạng thái Loading, Empty (danh sách trống), Error (lỗi nạp), Offline (mất mạng) vào 1 component dùng chung có nút hành động Call-To-Action.

5. **`AppBottomNav` (`lib/core/widgets/app_bottom_nav.dart`):**
   - Thanh điều hướng chân trang 4 tab chuẩn Netflix, tích hợp trực tiếp vào `MainShell` với `StatefulShellRoute`.

6. **`VideoScaffold` (`lib/core/widgets/video_scaffold.dart`):**
   - Quản lý vòng đời `VideoPlayerController` và `ChewieController`, tự động giải phóng bộ nhớ khi rời màn hình để tránh rò rỉ RAM (memory leak).
   - Tái sử dụng trên: S19 (Trailer) và S20 (Player).
