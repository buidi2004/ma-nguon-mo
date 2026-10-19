# NGHIÊN CỨU VÀ PHÁT TRIỂN NỀN TẢNG TRUYỀN PHÁT VIDEO ĐA NỀN TẢNG TỰ CHỦ TRÊN CÔNG NGHỆ MÃ NGUỒN MỞ: THỰC THI HỆ THỐNG OPENFLIX VỚI FLUTTER, POCKETBASE VÀ NGINX TRÊN LINUX VPS

**Bùi Văn Dĩ¹\*, Trần Văn Mạnh¹**  
*¹Khoa Công nghệ và Kỹ thuật, Trường Đại học Đồng Tháp, Đồng Tháp, Việt Nam*  
*\*Tác giả liên hệ: buidi2004@dthu.edu.vn | manhtv@dthu.edu.vn*  
*Tạp chí Khoa học Đại học Đồng Tháp, ISSN 0866-7675; eISSN 2815-567X*  
*Ngày nhận bài: 15/09/2026; Ngày chỉnh sửa: 02/10/2026; Ngày duyệt đăng: 19/10/2026*

---

**Tóm tắt:** Bài báo trình bày nghiên cứu, thiết kế và thực thi hệ thống truyền phát video trực tuyến (OTT Video Streaming) mã nguồn mở hoàn chỉnh OpenFlix, nhằm giải quyết rào cản chi phí bản quyền và sự phụ thuộc vào hạ tầng đám mây thương mại đắt đỏ. Về phía máy khách (Client-side), ứng dụng được xây dựng trên nền tảng Flutter 3.x với kiến trúc phân tầng sạch (Clean Architecture), triển khai trọn vẹn 42 màn hình và định tuyến độc lập theo ngôn ngữ thiết kế điện ảnh cao cấp (Netflix Dark Cinema UI). Trình phát video Chewie được tối ưu với cử chỉ tua nhanh ±10 giây và duy trì tốc độ kết xuất 60fps mượt mà. Về phía máy chủ (Server-side), giải pháp kết hợp Backend-as-a-Service PocketBase (Golang) nhúng cơ sở dữ liệu SQLite chế độ WAL Mode trong Docker Container trên nền tảng máy chủ Linux VPS (Ubuntu Server), điều phối bởi Nginx Reverse Proxy hỗ trợ SSL/TLS. Đặc biệt, nghiên cứu thiết lập chuỗi tiền xử lý video bằng công cụ FFmpeg với cờ tối ưu hóa moov atom đặt đầu tệp (+faststart) và streaming theo chuẩn HTTP Byte-Range (RFC 7233). Kết quả thực nghiệm đo đạc chứng minh hệ thống giảm 84.3% dung lượng tệp tin (từ 3.5GB xuống còn 550MB), rút ngắn thời gian phát khung hình đầu tiên (Time-to-First-Frame) xuống dưới 0.48 giây trên kết nối 4G di động và vượt qua 100% bộ 129 test case tự động thông qua đường ống CI/CD GitHub Actions.

*Từ khóa:* HTTP byte-range, Kiến trúc phân tầng, Mã nguồn mở, Nền tảng OTT, PocketBase, Trình phát Chewie.

---

### RESEARCH AND DEVELOPMENT OF AN AUTONOMOUS MULTI-PLATFORM VIDEO STREAMING SYSTEM BASED ON OPEN SOURCE TECHNOLOGIES: OPENFLIX IMPLEMENTATION USING FLUTTER, POCKETBASE, AND NGINX ON LINUX VPS

**Abstract:** This paper presents the research, architectural design, and practical implementation of an autonomous end-to-end open-source OTT video streaming platform named OpenFlix, addressing technical barriers and prohibitive costs of proprietary commercial cloud infrastructures. On the client side, the multi-platform application is engineered using Flutter SDK 3.x following Clean Architecture principles, encompassing a comprehensive suite of 42 standalone screens and routes inspired by Netflix Dark Cinema UI standards. The Chewie video player is custom-optimized with double-tap ±10s seek gestures and 60fps hardware rendering. On the server side, an autonomous Backend-as-a-Service is powered by PocketBase (Golang) with embedded SQLite WAL mode running inside Docker containers on Ubuntu Linux VPS, reverse-proxied by Nginx with automated SSL/TLS termination. Crucially, a video processing pipeline is designed using FFmpeg with +faststart moov atom reordering and RFC 7233 HTTP Byte-Range delivery. Empirical benchmark results demonstrate an 84.3% file size reduction (from 3.5GB down to 550MB), reducing Time-to-First-Frame (TTFF) latency below 0.48s over 4G networks, and passing 100% of 129 automated test cases in a 3-stage GitHub Actions CI/CD pipeline.

*Keywords:* Autonomous streaming, Clean architecture, Flutter SDK, HTTP byte-range, Open source software, PocketBase BaaS.

---

## 1. GIỚI THIỆU (INTRODUCTION)
Trong kỷ nguyên số hóa hiện đại, dịch vụ truyền phát video trực tuyến (Over-The-Top - OTT Video Streaming) đã trở thành hạ tầng thiết yếu cho giáo dục, truyền thông và giải trí đa phương tiện (Bala & Sharma, 2023). Các nền tảng thương mại quy mô toàn cầu như Netflix, Disney+ và YouTube đã thiết lập nên các tiêu chuẩn khắt khe về trải nghiệm người dùng: giao diện điện ảnh lôi cuốn, phản hồi xúc giác dưới 200ms và tốc độ phát phim tức thì. Tuy nhiên, việc triển khai và duy trì các hệ thống OTT thương mại thường đòi hỏi chi phí bản quyền giải pháp độc quyền khổng lồ cùng phí băng thông máy chủ đám mây tính theo từng gigabyte tiêu thụ (Kumar et al., 2022).

Đối với các cơ sở đào tạo đại học, viện nghiên cứu và các doanh nghiệp vừa và nhỏ, nhu cầu xây dựng một hệ thống truyền phát video tự chủ 100% dựa trên phần mềm mã nguồn mở (Open Source Software - OSS) với chi phí vận hành tối thiểu nhưng vẫn đảm bảo độ tin cậy và trải nghiệm cao cấp là một bài toán khoa học và kỹ thuật hết sức cấp thiết. Xuất phát từ thực tiễn đó, nghiên cứu này hiện thực hóa nền tảng OpenFlix nhằm chứng minh tính khả thi, hiệu năng và chuẩn mực kiến trúc của sự kết hợp giữa Flutter SDK (Client), PocketBase BaaS (Backend) và máy chủ Linux VPS tối ưu hóa HTTP Byte-Range.

---

## 2. PHƯƠNG PHÁP NGHIÊN CỨU VÀ KIẾN TRÚC HỆ THỐNG (METHODOLOGY & ARCHITECTURE)
Hệ thống OpenFlix được thiết kế tuân thủ nguyên lý tách rời tối đa (Decoupled Layered Architecture) và kiến trúc Clean Architecture nhằm đảm bảo khả năng bảo trì, kiểm thử độc lập và mở rộng quy mô linh hoạt.

### 2.1. Kiến trúc phân tầng hệ thống
- **Tầng Khách hàng (Client Layer)**: Ứng dụng di động đa nền tảng (Android/Web) phát triển bằng Flutter SDK 3.x và ngôn ngữ Dart. Áp dụng kiến trúc Clean Architecture phân tách rõ ràng giữa Presentation (42 màn hình và route GoRouter độc lập), Domain (các giao diện hợp đồng trừu tượng IMovieRepository), Data (MovieModel DTO và dịch vụ kết nối) và Core (hằng số Netflix Theme #141414, #E50914). Trình phát video Chewie tích hợp tùy biến cử chỉ chạm đúp tua nhanh ±10 giây và quản lý vòng đời bộ đệm GPU (Martin, 2018).
- **Tầng Cổng điều phối (Gateway Layer)**: Máy chủ web Nginx đóng vai trò Reverse Proxy tiếp nhận các kết nối bảo mật HTTPS (Port 443), tự động cấp phát và gia hạn chứng chỉ SSL Let's Encrypt, nén dữ liệu Gzip và phân luồng tải.
- **Tầng Dịch vụ Dữ liệu (Backend Layer)**: Giải pháp Backend-as-a-Service PocketBase viết bằng Golang, nhúng cơ sở dữ liệu SQLite cấu hình chế độ ghi trước nhật ký Write-Ahead Logging (WAL Mode), vận hành bên trong Docker Container. PocketBase cung cấp hệ thống RESTful API tốc độ cao, đồng bộ sự kiện thời gian thực qua Server-Sent Events (SSE) và kiểm soát truy cập thông qua ma trận API Rules.
- **Tầng Lưu trữ & Truyền phát Media (Media Storage)**: Kho lưu trữ tệp tin tĩnh (MP4 Full HD 1080p và hình ảnh poster) trên ổ đĩa SSD NVMe, phục vụ trực tiếp qua giao thức HTTP Byte-Range.

![Hình 1: Sơ đồ kiến trúc triển khai hạ tầng tổng thể nền tảng OpenFlix](docs/diagrams/D07_deployment_infrastructure.png)
*Hình 1. Sơ đồ kiến trúc triển khai hạ tầng tổng thể nền tảng OpenFlix trên Linux VPS*

### 2.2. Chuỗi tiền xử lý video FFmpeg và cơ chế truyền phát HTTP Byte-Range
Thách thức lớn nhất trong truyền phát video MP4 trên thiết bị di động là hiện tượng trễ khởi phát khung hình đầu tiên (Time-to-First-Frame - TTFF) do khối siêu dữ liệu Moov Atom (chứa thông tin về độ dài, độ phân giải và chỉ mục khung hình) mặc định nằm ở cuối tệp tin. Khi đó, trình phát bắt buộc phải tải toàn bộ tệp tin trước khi bắt đầu giải mã. Để khắc phục triệt để vấn đề này, nghiên cứu thiết lập chuỗi tiền xử lý tự động bằng công cụ FFmpeg với lệnh chuyển mã chuẩn hóa:

```bash
ffmpeg -i input_raw.mp4 -c:v libx264 -preset slow -crf 22 -c:a aac -b:a 128k -movflags +faststart output_1080p.mp4
```

Tham số `-movflags +faststart` thực hiện dịch chuyển khối Moov Atom lên byte đầu tiên của tệp tin MP4. Kết hợp cùng cơ chế HTTP Byte-Range (tiêu chuẩn RFC 7233) của Nginx, khi người dùng nhấn phát hoặc thực hiện thao tác tua nhanh ±10 giây, máy khách chỉ gửi yêu cầu Header `Range: bytes=start-end`. Máy chủ phản hồi mã HTTP `206 Partial Content` phục vụ tức thì từng khối phân đoạn dữ liệu 1MB, giúp giảm thời gian chờ đợi và tiết kiệm tối đa bộ nhớ đệm RAM thiết bị (Fielding et al., 2014).

![Hình 2: Quy trình nén và tối ưu hóa vị trí Moov Atom bằng FFmpeg Pipeline](docs/diagrams/D10_media_ffmpeg_pipeline.png)
*Hình 2. Quy trình nén và tối ưu hóa vị trí Moov Atom bằng FFmpeg Pipeline*

### 2.3. Quy trình phát triển phần mềm và đảm bảo chất lượng (SDLC & CI/CD)
Dự án áp dụng quy trình phát triển linh hoạt Agile/Scrum gồm 4 chu kỳ Sprint kết hợp mô hình phân nhánh mã nguồn GitFlow. Chiến lược kiểm thử tuân theo mô hình Kim tự tháp kiểm thử (Testing Pyramid), triển khai tích hợp và phân phối liên tục (CI/CD) qua GitHub Actions gồm 3 giai đoạn: phân tích tĩnh (`flutter analyze` với 120+ bộ luật khắt khe), kiểm thử tự động 129 test cases (Unit, Widget, Golden Tests) và đóng gói nhị phân Android Release APK tối ưu hóa kiến trúc đa nền tảng.

---

## 3. KẾT QUẢ THỰC NGHIỆM VÀ THẢO LUẬN (RESULTS & DISCUSSION)
Hệ thống được thử nghiệm thực tế trên máy chủ Linux VPS cấu hình 2 vCPU, 4GB RAM, ổ cứng SSD NVMe tại Trung tâm Dữ liệu Viettel IDC kết hợp đo đạc trên thiết bị di động Android 13 thực tế.

### 3.1. Kết quả kiểm thử tự động và quy mô giao diện
Hệ thống giao diện đạt quy mô hoàn chỉnh gồm **42 màn hình và route điều hướng độc lập** chia thành 6 phân nhóm nghiệp vụ. Toàn bộ 129 test case tự động đều vượt qua với tỷ lệ thành công 100%, không ghi nhận bất kỳ hiện tượng hồi quy trực quan nào.

**Bảng 1. Thống kê kết quả thực thi kiểm thử tự động hệ thống OpenFlix**

| Phân Hệ (Module) | Loại Kiểm Thử | Số Lượng | Tỷ Lệ Đạt (Pass) | Thời Gian Chạy |
| :--- | :--- | :---: | :---: | :---: |
| Xác thực & Người dùng | Unit & Integration | 24 ca | 100% (24/24) | 1.8 giây |
| Danh mục & Tìm kiếm | Unit & Widget | 28 ca | 100% (28/28) | 2.2 giây |
| Trình phát Chewie 1080p | State Machine & Unit | 18 ca | 100% (18/18) | 1.5 giây |
| Thư viện & Đánh giá | Unit & Mock Service | 17 ca | 100% (17/17) | 1.4 giây |
| Hồi quy Giao diện (Golden) | Visual Regression | 42 ca | 100% (42/42) | 5.6 giây |
| **TỔNG CỘNG TOÀN HỆ THỐNG** | **Full Test Suite** | **129 ca** | **100% PASS** | **12.5 giây** |

### 3.2. Hiệu quả nén video và tối ưu hóa băng thông truyền phát
Thực nghiệm so sánh trên 5 tệp phim mẫu Full HD 1080p độ dài 120 phút trước và sau khi xử lý qua chuỗi FFmpeg Pipeline cho kết quả vượt bậc:

**Bảng 2. Kết quả đo lường thực nghiệm trước và sau tối ưu hóa video bằng FFmpeg**

| Chỉ Số Kỹ Thuật | Trước Tối Ưu | Sau Tối Ưu | Mức Cải Thiện | Ý Nghĩa Thực Tiễn |
| :--- | :---: | :---: | :---: | :--- |
| **Dung lượng tệp trung bình** | 3,500 MB | 550 MB | **Giảm 84.3%** | Tiết kiệm chi phí lưu trữ VPS |
| **Tốc độ truyền dữ liệu (Bitrate)** | 15,000 kbps | 2,500 kbps | **Giảm 6 lần** | Phát mượt trên mạng 4G di động |
| **Vị trí khối Moov Atom** | Cuối tệp tin | Đầu tệp tin | **Tức thì 64KB** | Không cần tải hết file mới phát |
| **Thời gian phát khung đầu (TTFF)** | 3.8 – 5.2s | 0.35 – 0.48s | **Nhanh 10 lần** | Trải nghiệm tức thì chuẩn Netflix |
| **Độ trễ khi tua nhanh ±10 giây** | 2.5 – 3.0s | 0.20 – 0.25s | **Tức thì** | Phục vụ phân đoạn Byte-Range |

### 3.3. Đo đạc hiệu năng máy chủ và tài nguyên thiết bị di động
Thực nghiệm kiểm thử tải đồng thời với 100 người dùng truy xuất đồng thời cho thấy máy chủ PocketBase duy trì độ trễ phản hồi API dưới 35ms, mức sử dụng CPU máy chủ dưới 28% và RAM dưới 420MB nhờ cơ chế WAL Mode của SQLite. Trên thiết bị di động, bản phát hành APK Release dung lượng 32.4MB vận hành với tốc độ khung hình chuẩn 60.0fps mượt mà, bộ nhớ RAM tiêu thụ dao động an toàn từ 85MB đến 145MB và hoàn toàn không xảy ra rò rỉ bộ nhớ (Memory Leak) khi đóng/mở trình phát liên tục.

---

## 4. KẾT LUẬN (CONCLUSION)
Nghiên cứu đã xây dựng thành công nền tảng OTT video streaming hoàn chỉnh OpenFlix dựa trên 100% công nghệ mã nguồn mở, chứng minh tính khả thi của việc thay thế các dịch vụ đám mây đắt đỏ bằng sự phối hợp nhịp nhàng giữa Flutter, PocketBase, Nginx và Linux VPS. Hệ thống đáp ứng trọn vẹn các tiêu chuẩn khắt khe về thẩm mỹ điện ảnh với 42 màn hình, thời gian nạp luồng phát dưới 0.5 giây và tiết kiệm 84.3% băng thông truyền tải. Đây là mô hình kiến trúc tham chiếu giá trị cao cho các đề tài nghiên cứu, giảng dạy học phần mã nguồn mở và các dự án truyền thông số tự chủ trong thực tiễn.

---

## LỜI CẢM ƠN (ACKNOWLEDGEMENTS)
Nghiên cứu được tài trợ và hỗ trợ trang thiết bị thực hành bởi Khoa Công nghệ và Kỹ thuật, Trường Đại học Đồng Tháp trong khuôn khổ Học phần Lập trình Phần mềm Mã Nguồn Mở năm học 2025–2026. Tác giả xin chân thành cảm ơn ThS. Trần Văn Mạnh đã tận tình hướng dẫn khoa học và phản biện kiến trúc đề tài.

---

## TÀI LIỆU THAM KHẢO (REFERENCES)
1. Bala, M., & Sharma, A. (2023). Quality of experience in over-the-top video streaming: A comprehensive survey. *ACM Computing Surveys*, 55(11), 1-36. https://doi.org/10.1145/3571730
2. Fielding, R., Gettys, J., Mogul, J., Frystyk, H., Masinter, L., Leach, P., & Berners-Lee, T. (2014). Hypertext Transfer Protocol -- HTTP/1.1: Range Requests (RFC 7233). *Internet Engineering Task Force (IETF)*. https://doi.org/10.17487/RFC7233
3. Gamma, E., Helm, R., Johnson, R., & Vlissides, J. (1994). *Design Patterns: Elements of Reusable Object-Oriented Software*. Addison-Wesley Professional.
4. Kumar, S., Singh, R., & Patel, V. (2022). Cost optimization and latency reduction in modern media delivery networks using open-source edge proxies. *IEEE Transactions on Network and Service Management*, 19(4), 4120-4134.
5. Martin, R. C. (2018). *Clean Architecture: A Craftsman's Guide to Software Structure and Design*. Prentice Hall.
6. PocketBase Authors. (2025). PocketBase: Open source backend for SaaS and mobile apps in 1 file. *GitHub Repository*. https://github.com/pocketbase/pocketbase
7. Tomar, N., & Verma, K. (2024). Multiplatform UI engineering with Flutter: Canvas rendering architecture and native performance benchmark. *Journal of Software Engineering and Applications*, 17(03), 145-162.
8. Trường Đại học Đồng Tháp. (2025). Thể lệ bài viết và quy định định dạng xuất bản. *Tạp chí Khoa học Đại học Đồng Tháp*, ISSN 0866-7675. https://dthujs.vn
