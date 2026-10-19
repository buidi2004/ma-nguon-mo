# BÁO CÁO: FIX BUG ĐIỀU HƯỚNG XÁC THỰC (Đăng nhập / Đăng ký)

- **Ngày:** 2026-10-19
- **Mức độ:** High (chặn luồng hoàn tất đăng ký — người dùng mới không vào được app)
- **Phạm vi:** Điều hướng sau xác thực + guard router. **Không** đổi logic xác thực.

---

## 1. Triệu chứng

Sau khi **đăng ký** hoặc **đăng nhập** thành công, app **không vào trong** mà quay lại
màn **Đăng nhập**; phải bấm thêm một nút (Đăng nhập / Khám phá ngay) mới vào được app.

## 2. Nguyên nhân gốc

1. `LoginScreen` / `RegisterScreen` thoát màn bằng `context.pop()` (khi `context.canPop()`),
   nhưng 2 màn này **luôn bị `push`** lên trên màn trước đó (`/welcome`, tab "Của tôi",
   hoặc `AuthRequiredDialog`) → `pop()` chỉ trả về đúng màn đăng nhập cũ.
   - `lib/features/auth/register_screen.dart` (nhánh `canPop()`)
   - `lib/features/auth/login_screen.dart` (cả đăng nhập email và Google)
2. `GoRouter` **không có `redirect` guard** và **không lắng nghe** trạng thái đăng nhập
   (`lib/core/router/app_router.dart`) → khi `isLoggedIn` đổi `false → true` không có gì
   tự đưa người dùng vào app.

## 3. Kế hoạch fix (đã thực hiện)

| # | Hạng mục | Trạng thái |
|---|----------|-----------|
| 1 | Sau xác thực (email / Google / demo) điều hướng dứt khoát vào app bằng `go` (thay ngăn xếp) | ✅ |
| 2 | Thêm `redirect` guard ở `GoRouter`: phiên đã đăng nhập không được kẹt ở `/login`, `/register`, `/welcome` | ✅ |
| 3 | Thêm `refreshListenable: AuthService.instance` để guard tự chạy khi phiên đổi | ✅ |
| 4 | Guard tôn trọng tham số `?redirect=` (ví dụ `/watch/:id` sau khi mở khóa phim) | ✅ |
| 5 | Sửa `AuthRequiredDialog` dùng `context` của dialog sau khi `pop()` (lấy router trước khi đóng) | ✅ |
| 6 | Test hồi quy ở tầng **điều hướng** (phần báo cáo cũ bỏ sót) | ✅ |
| 7 | Guard **khách vãng lai** cho các màn dữ liệu cá nhân: `guest → /login?redirect=...` | ✅ |
| 8 | Tối ưu `refreshListenable`: chỉ refresh khi trạng thái đăng nhập **thực sự** đổi | ✅ |

## 4. Thay đổi mã nguồn

- `lib/features/auth/login_screen.dart`: thêm `_postAuthTarget` + `_enterApp()`; thay toàn bộ
  nhánh `pushReplacement/pop/go` bằng `_enterApp()` cho cả đăng nhập email và Google.
- `lib/features/auth/register_screen.dart`: thêm `_enterApp()`; thay nhánh `pop()` bằng `_enterApp()`.
- `lib/core/router/app_router.dart`:
  - `_guestOnlyRoutes = { '/login', '/register', '/welcome' }` + `redirect` guard cho phiên đã đăng nhập.
  - `_protectedRoutePrefixes` (khách bị chặn) + `_isProtected()` (khớp cả tuyến con):
    `/me/list`, `/me/continue`, `/me/history`, `/me/liked`, `/me/notifications`,
    `/me/downloads`, `/me/account`, `/me/password`, `/profiles` (bao gồm `/profiles/edit/:id`).
  - `_AuthGateListenable`: chỉ phát khi `isLoggedIn` đổi → dùng làm `refreshListenable`.
- `lib/presentation/widgets/dialogs/auth_required_dialog.dart`: `GoRouter.maybeOf(context)` được
  gọi **trước** khi `Navigator.pop()`; dùng `router.push` thay `context.push` sau khi pop.
- `test/auth_navigation_flow_test.dart` (mới): 9 test hồi quy BUG-01 → BUG-09.

Hành vi giữ nguyên: khách vãng lai **vẫn duyệt tự do** Trang chủ / Tìm kiếm / Mới&Hot / Rạp /
Chi tiết phim / Trailer / `/me` (có CTA đăng nhập); chỉ các màn **dữ liệu cá nhân** mới bị chặn.
`?redirect=` luôn được ưu tiên để sau đăng nhập quay lại đúng màn đang xem.

## 5. Bằng chứng

### 5.1. Test hồi quy mới — FAIL trên code cũ, PASS trên code mới

Chạy `test/auth_navigation_flow_test.dart` với `lib/` được `git stash` (code trước fix):

| Test | Kỳ vọng | Thực tế (code cũ) |
|------|---------|-------------------|
| BUG-01 Đăng nhập (Welcome → Login) | `/` | ❌ `/welcome` |
| BUG-02 Đăng ký (Login → Register) | `/` | ❌ `/login`  ← **đúng triệu chứng** |
| BUG-03 Mở `/login` khi đã đăng nhập | `/` | ❌ `/login` |
| BUG-04 `/login?redirect=/hot` khi đã đăng nhập | `/hot` | ❌ `/login` |
| BUG-05 Mở `/welcome` khi đã đăng nhập | `/` | ❌ `/welcome` |
| BUG-06 Khách mở `/me/list` | `/login?redirect=/me/list` | ❌ mở luôn `/me/list` |
| BUG-07 Khách mở `/me` | `/me` (không chặn) | ✅ `/me` |
| BUG-08 Khách mở `/profiles/edit/new` | `/login?redirect=/profiles/edit/new` | ❌ mở luôn |
| BUG-09 Đăng nhập từ redirect của guard | quay lại `/me/list` | ❌ không có guard |

→ Code cũ: BUG-01→06, 08, 09 fail (BUG-07 pass vì vốn không chặn). Sau fix: **9/9 pass**.

### 5.2. Kiểm thử hồi quy bộ liên quan

`flutter test test/app_router_test.dart test/screens_test.dart test/auth_guard_and_dialog_test.dart test/auth_required_dialog_test.dart test/widget_test.dart`
→ **All tests passed (57/57)**.

### 5.3. Toàn bộ test suite

`flutter test` → **`+354 -2`** (tăng 4 test mới; vẫn đúng 2 test đỏ sẵn có của baseline).

Hai test đỏ **không liên quan** và **đã đỏ sẵn trên baseline**:

| Test | Nguyên nhân |
|------|-------------|
| `capture_all_42_screens_test.dart` → S27 Watch History | Ảnh mạng (Unsplash/remote) không tải được trong môi trường test |
| `theme_service_and_settings_test.dart` → "Displays Theme Option tile..." | Lỗi sẵn có, không liên quan auth/navigation |

Đã đối chứng bằng cách chạy lại đúng 2 file này trên code cũ (`git stash lib/`): vẫn `+46 -2` —
tức **không phải do thay đổi của bản fix này**.

### 5.4. Phân tích tĩnh

`flutter analyze lib` → **No issues found!**
(`flutter analyze lib test` chỉ còn 3 `unused_import` + 1 `avoid_print` **có sẵn** trong
`test/capture_all_42_screens_test.dart`, không thuộc file đã sửa.)

## 6. Ghi chú kỹ thuật

- **Không có race điều hướng:** `AuthService.notifyListeners()` kích hoạt guard, nhưng lệnh
  `context.go(target)` trong màn hình tạo *transaction* mới hơn trong `Router` của Flutter,
  nên kết quả parse cũ (từ guard) bị loại bỏ. Cả hai đường đều đi tới cùng đích → idempotent.
- **Không loop:** guard một chiều theo trạng thái phiên —
  khách thì bỏ qua `/login` (trừ khi đích `redirect` lại là màn bảo vệ), phiên đã đăng nhập thì
  bỏ qua các màn auth. Hai nhánh loại trừ nhau nên không thể lặp vô hạn.
- `GoRouter.maybeOf(...)` được dùng để an toàn khi widget chạy ngoài router (ví dụ unit test).

## 7. Ghi chú & việc còn lại

- **Đã xử lý 2 hạng mục trước đây để mở:**
  - ✅ Guard khách cho màn dữ liệu cá nhân (`/me/*` liên quan dữ liệu, `/profiles*`) với
    `guest → /login?redirect=...`; khách vẫn vào được `/me` và các màn công khai.
  - ✅ `refreshListenable` giờ là `_AuthGateListenable` — chỉ phát khi `isLoggedIn` đổi, nên
    đổi avatar/tên **không** còn kích hoạt đánh giá lại điều hướng.
- **Chưa làm (cần rà soát riêng):**
  - `/cinema/my-tickets` (Vé của tôi) là dữ liệu cá nhân nhưng nằm trong module rạp riêng
    (`CinemaService`) — chưa đưa vào guard để tránh đổi hành vi đặt vé ngoài phạm vi.
  - Chưa chạy trên emulator/thiết bị thật ⇒ chưa có screenshot xác nhận UI sau fix
    (theo checklist `AGENTS.md`: `NOT RUN`).
