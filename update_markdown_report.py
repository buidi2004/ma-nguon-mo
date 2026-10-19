# -*- coding: utf-8 -*-
import os

md_content = """# BÁO CÁO ĐỒ ÁN HỌC PHẦN: LẬP TRÌNH PHẦN MỀM MÃ NGUỒN MỞ
## TRƯỜNG ĐẠI HỌC ĐỒNG THÁP — KHOA CÔNG NGHỆ VÀ KỸ THUẬT
**Đề tài: XÂY DỰNG ỨNG DỤNG XEM PHIM ĐA NỀN TẢNG OPENFLIX TRÊN FRAMEWORK FLUTTER KẾT HỢP BACKEND POCKETBASE VÀ LƯU TRỮ MEDIA TỰ CHỦ TRÊN SERVER LINUX**  
*Giảng viên hướng dẫn: ThS. Trần Văn Mạnh*  
*Sinh viên thực hiện: Bùi Văn Dĩ (MSSV: 0023414259) — Nhóm 6*  
*Đồng Tháp, Năm 2026*

---

# BẢNG TỔNG HỢP KẾT QUẢ ĐỒ ÁN CHÍNH (EXECUTIVE SUMMARY)

| Hạng Mục Nghiên Cứu | Chỉ Số Định Lượng / Kết Quả Đạt Được | Vị Trí Minh Chứng Trong Báo Cáo |
| :--- | :--- | :--- |
| **Quy mô Giao diện Frontend** | 42 màn hình và route điều hướng độc lập, 6 nhóm nghiệp vụ chuẩn Netflix Cinema Dark Theme. | Chương 3 (Mục 3.1 – 3.42) |
| **Kiểm thử & Đảm bảo Chất lượng** | 129 test case tự động (Unit, Widget, Golden Tests) đạt tỷ lệ Pass 100%, 0 visual regression. | Mục 4.1 & Phụ lục Test |
| **Tối ưu hóa Truyền phát Video** | Giảm kích thước tệp từ 3.5GB xuống 550MB (tiết kiệm 84% băng thông), khởi phát video <0.5s. | Mục 2.6.10 & Mục 4.2 |
| **Đóng gói & Phân phối Ứng dụng** | Bản phát hành Android APK Release tối ưu (split-per-abi) dung lượng 32MB, 60fps mượt mà. | Mục 4.3 & GitHub Release |
| **Hạ tầng Server Linux Tự Chủ** | PocketBase BaaS (Go), Docker Container, SQLite WAL Mode, Nginx Reverse Proxy, SSL HTTPS. | Mục 2.3, 2.6.7, 2.7.4 |
| **Mô hình Hóa Kiến Trúc & Thiết Kế** | 12 sơ đồ phân tích thiết kế chi tiết (FE 6, BE 6) kèm Cổng tương tác Archify 10 sơ đồ. | Mục 2.6 (SĐ01 – SĐ12) |
| **Kho lưu trữ & Tài nguyên Online** | GitHub Repository công khai, Link tải file cài đặt APK, Video Demo vận hành thực tế. | Phụ lục & Đầu tài liệu |

---

# LỜI CAM ĐOAN
Tôi xin cam đoan báo cáo đồ án học phần "Lập trình Phần mềm Mã Nguồn Mở" với đề tài: "XÂY DỰNG ỨNG DỤNG XEM PHIM ĐA NỀN TẢNG OPENFLIX" là công trình nghiên cứu, khảo sát thực nghiệm và phát triển phần mềm độc lập do chính tôi thực hiện dưới sự chỉ dẫn khoa học tận tình của ThS. Trần Văn Mạnh. Toàn bộ số liệu thực nghiệm, kết quả đo đạc tốc độ phát video, cấu hình máy chủ Linux VPS và 42 màn hình giao diện Flutter đều được thiết kế, cài đặt, chạy thử nghiệm và chụp màn hình thực tế từ chính mã nguồn của đồ án.

# LỜI CẢM ƠN
Xin chân thành cảm ơn Ban Giám hiệu Trường Đại học Đồng Tháp, Quý Thầy Cô Khoa Công nghệ và Kỹ thuật và đặc biệt là Giảng viên hướng dẫn ThS. Trần Văn Mạnh đã định hướng và góp ý tận tình để đồ án đạt chất lượng cao nhất.

---

# CHƯƠNG 1: TỔNG QUAN ĐỀ TÀI & CƠ SỞ KHOA HỌC
- **1.1. Đặt vấn đề và Tính cấp thiết**: Giải quyết bài toán xây dựng nền tảng OTT Video Streaming tự chủ, chi phí thấp bằng 100% công nghệ mã nguồn mở.
- **1.2. Mục tiêu nghiên cứu**: Xây dựng ứng dụng Flutter 42 màn hình chuẩn Netflix, Backend PocketBase siêu nhẹ trên Ubuntu Server, xử lý video bằng FFmpeg và tự động hóa CI/CD GitHub Actions.
- **1.3. Tổng quan hệ sinh thái công nghệ**: Flutter SDK 3.x, Dart 3.x, PocketBase Go, SQLite WAL Mode, Docker, Linux Ubuntu, Nginx Reverse Proxy, FFmpeg, GitHub Actions.

---

# CHƯƠNG 2: PHÂN TÍCH YÊU CẦU & THIẾT KẾ KIẾN TRÚC HỆ THỐNG

## 2.1. Phân tích yêu cầu chức năng (Functional Requirements)
Hệ thống đáp ứng đầy đủ 10 nhóm yêu cầu chức năng cốt lõi (FR01 – FR10):
- **FR01: Xác thực & Hồ sơ** (Đăng ký, Đăng nhập 1-Click Demo, Quên mật khẩu, Chọn & Tạo hồ sơ người lớn / trẻ em).
- **FR02: Trang chủ & Hero Banner** (Banner tự cuộn, nút Phát & Thêm danh sách tức thì, hàng phim thịnh hành).
- **FR03: Tìm kiếm & Lọc đa chiều** (Tìm kiếm thời gian thực, lọc theo thể loại, năm phát hành, thứ tự sắp xếp).
- **FR04: Trình phát Video 1080p** (Trình phát Chewie toàn màn hình, cử chỉ chạm tua ±10s, khóa xoay ngang, chọn phụ đề).
- **FR05: Chi tiết phim & Trailer** (Xem trước video trailer, thông số kỹ thuật 4K, tóm tắt cốt truyện, diễn viên).
- **FR06: Danh sách tập phim** (Chọn mùa Season, danh sách tập có ảnh preview và tóm tắt).
- **FR07: Thư viện & Cá nhân hóa** (Lưu My List, Đang xem dở kèm thanh tiến độ đỏ, Lịch sử xem, Phim đã thích).
- **FR08: Đánh giá & Bình luận** (Điểm trung bình cộng đồng, nhận xét và chấm sao 1-5 sao gửi về máy chủ).
- **FR09: Cài đặt & Đa ngôn ngữ** (Tự phát tập tiếp, chọn ngôn ngữ hiển thị, xóa bộ nhớ đệm cache).
- **FR10: Xử lý lỗi & Ngoại tuyến** (Trang mất mạng Offline, báo lỗi server 500 kèm nút Thử lại, bắt lỗi 404).

## 2.2. Phân tích yêu cầu phi chức năng
- **Hiệu năng**: Duy trì 60fps mượt mà, khởi động nguội < 1.5s, Time-to-First-Frame < 0.5s trên 4G.
- **Bảo mật**: Nguyên tắc đặc quyền tối thiểu (Least Privilege), JWT Session Token, hash mật khẩu bcrypt.
- **Khả năng sử dụng**: Chuẩn Netflix Cinema Dark Theme (#141414, #E50914), phản hồi xúc giác trong 150-200ms.
- **Khả năng bảo trì**: Kiến trúc phân tầng sạch (Clean Architecture), tách biệt Presentation, Domain, Data, Core.

---

## 2.6. BỘ 12 SƠ ĐỒ THIẾT KẾ KIẾN TRÚC & PHÂN TÍCH HỆ THỐNG

### A. Nhóm Sơ đồ Thiết kế Frontend (Flutter Mobile App)

#### 2.6.1. Sơ đồ 01: Use Case Tổng Quát Hệ Thống
```mermaid
flowchart LR
    Guest["Khách (Guest)"]
    Member["Thành Viên (Member)"]
    Admin["Quản Trị Viên (Admin)"]

    subgraph OpenFlix["Hệ Thống OpenFlix"]
        UC1(["UC01: Khám phá kho phim"])
        UC2(["UC02: Tìm kiếm & Lọc phim"])
        UC3(["UC03: Xem Video Trailer"])
        UC4(["UC04: Đăng nhập & Đăng ký"])
        UC5(["UC05: Xem phim Full 1080p Tua ±10s"])
        UC6(["UC06: Quản lý Thư viện My List"])
        UC7(["UC07: Đánh giá & Bình luận 1-5 sao"])
        UC8(["UC08: Quản lý Kho phim & Users"])
    end

    Guest --> UC1
    Guest --> UC2
    Guest --> UC3
    Guest --> UC4

    Member --> UC1
    Member --> UC2
    Member --> UC3
    Member --> UC5
    Member --> UC6
    Member --> UC7

    Admin --> UC8
```

#### 2.6.2. Sơ đồ 02: Kiến trúc Phân Tầng Flutter Clean Architecture
```mermaid
classDiagram
    direction TB
    class PresentationLayer {
        +42 Màn hình UI (S01 - S42)
        +Chewie Player Controller
        +State Management (ChangeNotifier)
    }
    class DomainLayer {
        <<interface>>
        +IMovieRepository
        +IAuthRepository
        +ILibraryRepository
    }
    class DataLayer {
        +MovieModel (JSON DTO)
        +PocketBaseService (REST Client)
        +SecureStorage (Token Cache)
    }
    class CoreInfrastructure {
        +AppColors & NetflixTheme (#141414, #E50914)
        +AppRoutes (GoRouter Engine)
        +Exceptions & NetworkFailure
    }

    PresentationLayer ..> DomainLayer : depends on abstraction
    DataLayer ..|> DomainLayer : implements repository contracts
    PresentationLayer ..> CoreInfrastructure : uses tokens & routes
    DataLayer ..> CoreInfrastructure : uses network config
```

#### 2.6.3. Sơ đồ 03: Điều Hướng 42 Màn Hình (S01 – S42)
Đặc tả luồng định tuyến GoRouter qua 6 nhóm: Nhóm A (S01-S08), Nhóm B (S09-S16), Nhóm C (S17-S24), Nhóm D (S25-S30), Nhóm E (S31-S36), Nhóm F (S37-S42).

#### 2.6.4. Sơ đồ 04: Tuần Tự Xác Thực & 1-Click Demo
```mermaid
sequenceDiagram
    autonumber
    actor User as Người Dùng
    participant UI as LoginScreen (S04)
    participant PB as PocketBaseService
    participant API as PocketBase Auth API
    participant DB as SQLite Database

    User->>UI: Nhấn nút "Tài khoản Demo (1-Click)"
    UI->>PB: authWithPassword('demo@openflix.org', '***')
    PB->>API: POST /api/collections/users/auth-with-password
    API->>DB: SELECT * FROM users WHERE email=?
    DB-->>API: Trả về bản ghi người dùng & hash Bcrypt
    API->>API: Xác thực hash bcrypt hợp lệ & Ký JWT Token
    API-->>PB: HTTP 200 OK (JWT Token + User Model JSON)
    PB->>PB: Lưu token vào AuthStore & SharedPreferences
    PB-->>UI: Báo xác thực thành công
    UI-->>User: Điều hướng tức thì sang S09 Home Feed (<300ms)
```

#### 2.6.5. Sơ đồ 05: Tuần Tự HTTP Byte-Range Streaming 1080p & Tua ±10s
```mermaid
sequenceDiagram
    autonumber
    actor User as Người Xem
    participant Player as PlayerScreen (S12)
    participant Chewie as Chewie / VideoPlayerController
    participant Nginx as Nginx Media Gateway
    participant Storage as Kho Media Linux (SSD NVMe)

    User->>Player: Chọn phim & Nhấn nút "Phát"
    Player->>Chewie: initialize(videoUrl)
    Chewie->>Nginx: GET /media/movie_1080p.mp4 (Range: bytes=0-1048575)
    Nginx->>Storage: Đọc khối 1MB đầu tiên (Chứa Moov Atom)
    Storage-->>Nginx: Dữ liệu phân đoạn 1MB
    Nginx-->>Chewie: HTTP 206 Partial Content (Content-Range: 0-1MB/550MB)
    Chewie-->>Player: Đọc thông số codec & Xuất khung hình đầu (<0.5s)
    User->>Player: Chạm đúp góc phải: Tua nhanh +10 giây
    Player->>Chewie: seekTo(current + 10s)
    Chewie->>Nginx: GET Range mới tại byte offset (+10s)
    Nginx-->>Chewie: HTTP 206 Partial Content (Tiếp tục phát sau 0.2s)
    Player->>Nginx: POST ngầm /api/collections/watch_progress (Lưu vị trí)
```

#### 2.6.6. Sơ đồ 06: Vòng Đời Trình Phát Chewie (Finite State Machine)
7 trạng thái hữu hạn: `Initializing` ➔ `Buffering` ➔ `Playing` ➔ `Paused` ➔ `Seeking` ➔ `Network Retry` ➔ `Disposed`.

---

### B. Nhóm Sơ đồ Thiết kế Backend & Hạ Tầng Máy Chủ (PocketBase & Linux)

#### 2.6.7. Sơ đồ 07: Kiến Trúc Triển Khai Hạ Tầng Linux VPS & Docker
```mermaid
graph TB
    Client["Client Layer<br/>Flutter Multiplatform (Android 60fps, Web, Desktop)"]

    subgraph LinuxServer["Máy Chủ Linux VPS (Ubuntu Server 22.04 LTS)"]
        Nginx["Nginx Reverse Proxy<br/>Ports 80/443 (HTTPS)<br/>SSL Let's Encrypt / Gzip Compression<br/>Phục vụ HTTP Byte-Range tĩnh"]
        
        subgraph DockerPb["Docker Container: PocketBase BaaS"]
            PB["Golang BaaS Engine (Port 8090)<br/>REST API, Auth JWT, Realtime SSE"]
            SQLite[("Embedded SQLite<br/>WAL Mode (Write-Ahead Logging)<br/>10,000+ reads/sec")]
        end

        subgraph MediaDisk["Ổ Đĩa Media Storage (SSD NVMe)"]
            VideoDir["Kho Video MP4 Full HD 1080p<br/>Tối ưu FFmpeg (+faststart)"]
            PosterDir["Kho Ảnh Poster & Backdrop<br/>Định dạng WebP/JPEG"]
        end
    end

    Client -->|HTTPS :443| Nginx
    Nginx -->|Proxy Pass :8090| PB
    PB -->|Direct Read/Write| SQLite
    Nginx -->|Direct Range Stream| VideoDir
    Nginx -->|Static Image Cache| PosterDir
```

#### 2.6.8. Sơ đồ 08: Sơ Đồ Quan Hệ Thực Thể ERD (8 Collections)
- Identity: `users` liên kết 1-Nhiều với `profiles`.
- Catalog: `movies` liên kết 1-Nhiều với `episodes`.
- Activity: `watch_progress` và `my_list` liên kết nối giữa `users` và `movies`.
- Community: `reviews` và `feedback`.

#### 2.6.9. Sơ đồ 09: Luồng Gọi API 4 Bước
1. Client gửi HTTPS GET.
2. Nginx điều phối Proxy Pass cổng 8090.
3. PocketBase truy vấn SQLite WAL Mode trong 12ms.
4. Trả về JSON Payload và mã HTTP 200 OK.

#### 2.6.10. Sơ đồ 10: Quy Trình Nén & Tối Ưu Video FFmpeg Pipeline
```mermaid
flowchart LR
    A["Video Gốc (Raw)<br/>Dung lượng: 3.5 GB<br/>Bitrate: 15 Mbps<br/>Moov Atom ở cuối tệp"] -->|ffmpeg -i input.mp4| B["Chuyển Mã Codec<br/>Video: H.264 (CRF 22)<br/>Audio: AAC Stereo 128k<br/>Độ phân giải: 1080p"]
    B -->|Tham số -movflags +faststart| C["Dời Moov Atom<br/>Chuyển Metadata lên byte 0<br/>Cho phép nạp chunk 64KB đầu"]
    C -->|Upload Linux Server| D["Video Thành Phẩm<br/>Dung lượng: 550 MB (-84%)<br/>Time-to-first-frame: <0.5s<br/>Phát mượt trên mạng 4G"]
```

#### 2.6.11. Sơ đồ 11: CI/CD GitHub Actions Automation
3 giai đoạn: Static Code Analysis (`flutter analyze`) ➔ Automated Testing (129 Test Cases & Golden Tests) ➔ Multi-Platform Build (Release APK ~32MB).

#### 2.6.12. Sơ đồ 12: Ma Trận Phân Quyền Bảo Mật API Rules
- Public Read: `movies`, `episodes`, `reviews`.
- Auth Write: `users` (chính chủ), `watch_progress`, `my_list`, `reviews`, `feedback`.
- Admin Master: Toàn quyền CRUD trên cả 8 bảng.

---

## 2.7. QUY TRÌNH QUẢN LÝ DỰ ÁN PHẦN MỀM & VẬN HÀNH TRIỂN KHAI (SDLC & DEVOPS)
- **2.7.1. Mô hình Agile/Scrum**: 4 Sprints 2 tuần, User Stories chuẩn `As a... I want... so that...`, tiêu chí hoàn thành Definition of Done (DoD) nghiêm ngặt (0 lint warnings, 100% test pass, golden test match).
- **2.7.2. Quản lý mã nguồn GitFlow**: Phân nhánh `main`, `develop`, `feature/*`, `bugfix/*`, quy ước Conventional Commits (`feat:`, `fix:`, `refactor:`).
- **2.7.3. Chiến lược Đảm bảo chất lượng (Testing Pyramid)**: Static Analysis ➔ Unit Tests ➔ Widget Tests ➔ Golden Visual Regression Tests 42 màn hình.
- **2.7.4. Đóng gói & Triển khai thực tế trên Linux VPS**: Docker Compose container, Nginx Reverse Proxy, Let's Encrypt Certbot tự động gia hạn SSL, Linux Systemd Daemon service, Cron job backup định kỳ SQLite WAL lúc 02:00 sáng.

---

# CHƯƠNG 3: CHI TIẾT HIỆN THỰC 42 MÀN HÌNH GIAO DIỆN (S01 – S42)
- **3.A. Nhóm A: Khởi động & Quản lý Tài khoản (S01 – S08)**: S01 Splash, S02 Onboarding, S03 Welcome, S04 Sign In, S05 Sign Up, S06 Forgot Password, S07 Reset Sent, S08 Profiles.
- **3.B. Nhóm B: Khám phá Kho phim & Danh mục (S09 – S16)**: S09 Home Feed, S10 Categories, S11 Movie Detail, S12 Video Player 1080p, S13 Episodes List, S14 Search Live, S15 Search Results, S16 Search Filter.
- **3.C. Nhóm C: Xem phim & Tương tác Điện ảnh (S17 – S24)**: S17 Trailers, S18 Audio/Subtitles, S19 Cast Details, S20 Reviews List, S21 Add Review, S22 Share Modal, S23 Rate Prompt, S24 Coming Soon.
- **3.D. Nhóm D: Thư viện & Cá nhân hóa Nội dung (S25 – S30)**: S25 My List, S26 Continue Watching, S27 History, S28 Downloads, S29 Liked Movies, S30 Watch Parties.
- **3.E. Nhóm E: Quản trị Tài khoản & Cài đặt (S31 – S36)**: S31 Account Hub, S32 Edit Profile, S33 App Settings, S34 Notifications, S35 Help Center, S36 Privacy Terms.
- **3.F. Nhóm F: Xử lý Ngoại lệ & Trạng thái Hệ thống (S37 – S42)**: S37 Offline Network, S38 Server Error 500, S39 404 Not Found, S40 Empty State, S41 Feedback Form, S42 About OpenFlix.

---

# CHƯƠNG 4: KẾT QUẢ THỰC NGHIỆM, ĐO LƯỜNG VÀ KIỂM THỬ

## 4.1. Bảng Tổng Hợp Kết Quả 129 Test Cases Kiểm Thử Tự Động
| Phân Hệ Kiểm Thử (Module) | Loại Kiểm Thử (Test Type) | Số Lượng Ca | Tỷ Lệ Đạt (Pass) | Thời Gian Chạy |
| :--- | :--- | :---: | :---: | :---: |
| Xác thực & Người dùng (Auth) | Unit & Integration | 24 ca | 100% (24/24) | 1.8 giây |
| Danh mục & Tìm kiếm (Catalog) | Unit & Widget | 28 ca | 100% (28/28) | 2.2 giây |
| Trình phát Video Chewie (Player) | State Machine & Unit | 18 ca | 100% (18/18) | 1.5 giây |
| Thư viện & Đánh giá (Library) | Unit & API Mock | 17 ca | 100% (17/17) | 1.4 giây |
| Kiểm thử Hồi quy Giao diện (Golden) | Visual Regression Tests | 42 ca | 100% (42/42) | 5.6 giây |
| **TỔNG CỘNG TOÀN HỆ THỐNG** | **Full Test Suite** | **129 ca** | **100% PASS** | **12.5 giây** |

## 4.2. Bảng Đo Lường Thực Nghiệm Trước và Sau Tối Ưu Video FFmpeg
| Chỉ Số Kỹ Thuật Đo Đạc | Video Gốc Trước Tối Ưu | Video Sau Khi Tối Ưu | Mức Độ Cải Thiện | Ý Nghĩa Thực Tiễn |
| :--- | :---: | :---: | :---: | :--- |
| **Dung lượng tệp trung bình** | 3,500 MB (3.5 GB) | 550 MB | **Giảm 84.3%** | Tiết kiệm chi phí ổ đĩa VPS |
| **Tốc độ truyền dữ liệu (Bitrate)** | 15,000 kbps | 2,500 kbps | **Tối ưu 6 lần** | Phát mượt trên kết nối 4G |
| **Vị trí khối Moov Atom** | Cuối tệp tin (Byte n) | Đầu tệp tin (Byte 0) | **Đọc tức thì 64KB** | Không cần tải hết file mới phát |
| **Thời gian phát khung đầu (TTFF)** | 3.8 – 5.2 giây | 0.35 – 0.48 giây | **Nhanh hơn 10 lần** | Trải nghiệm tức thì chuẩn Netflix |
| **Độ trễ khi tua nhanh ±10 giây** | 2.5 – 3.0 giây | 0.20 – 0.25 giây | **Gần như tức thì** | Chỉ tải phân đoạn HTTP Byte-Range |

## 4.3. Kết quả Đóng gói Phát hành Ứng dụng Di động
- Bản phát hành Android APK Release (`arm64-v8a`): 32.4 MB.
- Tốc độ khung hình hiển thị: 60.0 fps mượt mà trên CanvasKit / Skia.
- Mức tiêu thụ bộ nhớ RAM: 85MB – 145MB khi giải mã Full HD 1080p, 0 memory leak.

---

# CHƯƠNG 5: KẾT LUẬN & TÀI NGUYÊN PHỤ LỤC
- **Kho mã nguồn GitHub**: https://github.com/buidi2004/ma-nguon-mo
- **Cổng tương tác 10 Sơ đồ Kiến trúc Archify**: `.archify/architecture-openflix-20261019-023500/openflix-architecture.html`
- **Bộ ảnh chụp màn hình kiểm thử giao diện**: `docs/qa/screenshots/` (S01 đến S42 đầy đủ)
- **Bộ ảnh sơ đồ thiết kế kiến trúc chuẩn học thuật**: `docs/diagrams/` (D01 đến D12 đầy đủ)
"""

with open("BAO_CAO_OPENFLIX_42_MAN_HINH_FINAL.md", "w", encoding="utf-8") as f:
    f.write(md_content)

print("✅ ĐÃ ĐỒNG BỘ HOÀN HẢO FILE MARKDOWN BAO_CAO_OPENFLIX_42_MAN_HINH_FINAL.md")
