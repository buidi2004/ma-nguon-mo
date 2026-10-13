# 🎬 OpenFlix - Nền Tảng Xem Phim Trực Tuyến Mã Nguồn Mở

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.47+-02569B?logo=flutter&logoColor=white" alt="Flutter">
  <img src="https://img.shields.io/badge/PocketBase-v0.25+-B8DBE4?logo=pocketbase&logoColor=black" alt="PocketBase">
  <img src="https://img.shields.io/badge/Dart-3.13+-0175C2?logo=dart&logoColor=white" alt="Dart">
  <img src="https://img.shields.io/badge/License-MIT-brightgreen.svg" alt="License: MIT">
  <img src="https://img.shields.io/badge/Theme-Netflix_Dark_Mode-E50914" alt="Dark Mode">
</p>

**OpenFlix** là dự án ứng dụng xem phim trực tuyến mã nguồn mở được phát triển bằng **Flutter** và backend BaaS tốc độ cao **PocketBase**. Ứng dụng mang phong cách giao diện điện ảnh cao cấp (Netflix Dark Red Theme), hỗ trợ phát video luồng cao, tìm kiếm theo từ khóa, lọc danh mục thông minh và kết nối API linh hoạt.

---

## 🏛️ Kiến Trúc Hệ Thống (System Architecture)

```
┌────────────────────────────────────────────────────────┐
│                   OpenFlix Client                      │
│                  (Flutter Framework)                   │
├────────────────────┬───────────────────────────────────┤
│  UI / UX Layer     │ • HomeScreen (Hero Banner, Lists) │
│                    │ • PlayerScreen (Chewie + Video)   │
│                    │ • MovieCard & Custom Widgets      │
├────────────────────┼───────────────────────────────────┤
│  Data / Logic      │ • MovieModel (JSON & Record)      │
│                    │ • PocketBaseService (REST & SDK)  │
│                    │ • Offline Cache / Fallback Mock   │
└─────────▲──────────┴───────────────────────────────────┘
          │
          │ HTTP / RESTful API (JSON)
          ▼
┌────────────────────────────────────────────────────────┐
│                   PocketBase Server                    │
│             (PocketHost.io / Self-hosted)              │
├────────────────────────────────────────────────────────┤
│  • Collection: `movies`                                │
│  • Public Read API Rules (Unlock List/View)            │
│  • SQLite Embedded Database & File Storage             │
└────────────────────────────────────────────────────────┘
```

---

## ✨ Tính Năng Nổi Bật

- 🔴 **Giao diện Netflix Dark Mode**: Tông màu đen - đỏ chuẩn điện ảnh, poster đổ bóng mượt mà, typography hiện đại từ Google Fonts.
- ⭐ **Hero Banner Nổi Bật**: Hiển thị tác phẩm tiêu biểu kèm tóm tắt và nút phát tức thì.
- 📂 **Danh mục cuộn ngang linh hoạt**: Phim Thịnh Hành, Hoạt Hình, Viễn Tưởng, Hành Động, Hài Hước.
- 🔍 **Tìm kiếm thời gian thực**: Lọc phim ngay khi gõ tên hoặc từ khóa mô tả.
- 🎥 **Trình phát Video chuẩn Cinema (Chewie)**:
  - Play / Pause, tua tới/lùi 10 giây.
  - Thanh tiến trình thời gian thực.
  - Hỗ trợ xoay ngang toàn màn hình (Landscape Fullscreen).
  - Tự động gợi ý các phim liên quan cùng thể loại bên dưới trình phát.
- 🌐 **Hỗ trợ kết nối kép linh hoạt**:
  - Tích hợp sẵn bộ phim mẫu Offline giúp app luôn chạy mượt mà ngay cả khi chưa mở server.
  - Nút cài đặt Server trực tiếp trên App: Nhập URL PocketHost và bấm **1-Click Seed** để nạp toàn bộ phim lên server chỉ trong 2 giây!

---

## 📊 Cấu Trúc Bảng Dữ Liệu (`movies`)

| Trường (Field) | Kiểu (Type) | Mô tả |
| :--- | :--- | :--- |
| `id` | Plain Text | Mã định danh duy nhất của bộ phim |
| `title` | Plain Text | Tên bộ phim |
| `description` | Plain Text | Tóm tắt nội dung phim |
| `category` | Plain Text | Thể loại: *Hành động*, *Hoạt hình*, *Viễn tưởng*, *Hài hước* |
| `poster_url` | URL / Text | Đường dẫn hình ảnh poster dọc (tỷ lệ 2:3) |
| `video_url` | URL / Text | Đường dẫn file video trực tiếp (`.mp4`) |
| `release_year` | Number | Năm phát hành bộ phim |
| `is_featured` | Bool | `true` nếu được ghim lên Hero Banner đầu trang |

---

## 🚀 Hướng Dẫn Cài Đặt & Chạy Ứng Dụng

### 1. Chuẩn bị môi trường
- Đã cài đặt [Flutter SDK](https://docs.flutter.dev/get-started/install) (phiên bản 3.x trở lên).
- Thiết bị thử nghiệm: Android Device, Máy ảo Android Emulator, hoặc Windows Desktop.

### 2. Tải mã nguồn & Cài đặt gói thư viện
```bash
git clone https://github.com/your-username/openflix.git
cd openflix
flutter pub get
```

### 3. Nạp dữ liệu vào PocketBase (PocketHost hoặc Local)
- **Cách 1 (Nhanh nhất - Qua CLI)**:
  ```bash
  dart run backend/seed_data.dart https://your-instance.pockethost.io
  ```
- **Cách 2 (Import Schema qua Admin UI)**:
  Vào `/_/` -> **Settings** -> **Sync collections** -> Nhập nội dung file `backend/pb_schema.json`.
- **Cách 3 (Trực tiếp trong App)**:
  Mở app -> Nhấn biểu tượng icon máy chủ (góc trên phải) -> Nhập URL PocketHost -> Nhấn **"1-Click: Nạp 8 phim mẫu lên Server"**.

### 4. Chạy ứng dụng
```bash
# Chạy trên thiết bị kết nối hoặc máy ảo
flutter run

# Xuất file APK cài đặt độc lập
flutter build apk --release
```
File APK cài đặt sẽ nằm tại: `build/app/outputs/flutter-apk/app-release.apk`.

---

## 📦 Các Gói Thư Viện Sử Dụng (Open Source Dependencies)

- [`pocketbase`](https://pub.dev/packages/pocketbase): SDK kết nối và đồng bộ dữ liệu với máy chủ PocketBase.
- [`video_player`](https://pub.dev/packages/video_player): Plugin phát video chính thức từ Flutter.
- [`chewie`](https://pub.dev/packages/chewie): Bộ điều khiển giao diện video phong cách cao cấp với hỗ trợ Fullscreen.
- [`cached_network_image`](https://pub.dev/packages/cached_network_image): Tải và lưu bộ nhớ đệm ảnh poster nhanh chóng.
- [`google_fonts`](https://pub.dev/packages/google_fonts): Phông chữ Outfit hiện đại.

---

## 📜 Giấy Phép Bản Quyền

Dự án được phát hành theo giấy phép **[MIT License](LICENSE)**. Hoàn toàn tự do sử dụng cho mục đích học tập, nghiên cứu và phát triển.
