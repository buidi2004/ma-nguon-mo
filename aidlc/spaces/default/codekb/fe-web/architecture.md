# Phân tích kiến trúc

## Architecture Analysis

### System Overview

Ứng dụng Next.js 13 dùng App Router. Route server components gọi các hàm trong `src/functions/` để lấy dữ liệu JSON từ dịch vụ bên ngoài; các phần cần tương tác trình duyệt được đánh dấu client component. `RootLayout` bao quanh route bằng Header, SaveProvider, nút danh sách đã lưu và Footer.

### Architectural Style

Frontend web đơn khối, render kết hợp server/client, dữ liệu phim do dịch vụ HTTP bên ngoài cung cấp. Không tìm thấy server/API backend trong repo `fe-web`.

### Component Relationships

```mermaid
flowchart TD
  Browser[Trình duyệt] --> Layout[Next.js RootLayout]
  Layout --> Header[Header và điều hướng]
  Layout --> Save[SaveProvider / localStorage]
  Layout --> Routes[App Router]
  Routes --> Home[Trang chủ]
  Routes --> Category[Trang danh mục]
  Routes --> Detail[Trang phim]
  Home --> HomeAPI[getHomePageMovies]
  Category --> PageAPI[getPageMovies]
  Detail --> MovieAPI[getMovie]
  HomeAPI --> JoyAPI[JoyFilm Server API]
  PageAPI --> JoyAPI
  MovieAPI --> OPhim[OPhim API]
  Home --> Carousel[Carousel và MovieSlide]
  Category --> Cards[MovieCard và PageButtons]
  Detail --> Info[MovieInfoSection]
  Detail --> Player[MovieMediaSection / TrailerPlayer]
```

Văn bản thay thế: route Next.js gọi các fetch helper tương ứng; dữ liệu đi từ JoyFilm Server hoặc OPhim đến các trang, còn danh sách đã lưu đi qua context và `localStorage`.

### Data Flow

- Trang chủ lấy một payload danh mục qua `getHomePageMovies`, sau đó truyền từng mảng phim xuống carousel và các `MovieSlide`.
- Trang danh mục lấy dữ liệu theo loại/trang qua `getPageMovies`, rồi render `MovieCard` và `PageButtons`.
- Trang chi tiết client tải phim theo slug qua `getMovie`; query `sv`/`tap` quyết định hiển thị thông tin hay phát tập.
- SaveProvider đọc/ghi danh sách phim trong `localStorage` và cung cấp thao tác lưu cho các component.

### Key Design Decisions

- Route danh mục dùng segment động `[page]`; chi tiết dùng `[slug]`.
- Tailwind token đặt trong `tailwind.config.js`; màu nền hiện tại là `#1a1a1a`, accent đỏ `#e50914`, accent phụ xanh `#0ea5e9`.
- Frontend gọi backend từ xa thay vì có API proxy nội bộ.

### Improvement Opportunities

- Bổ sung trạng thái lỗi và thử lại cho các yêu cầu dữ liệu phía client; chuẩn hóa thông báo lỗi fetch.
- Mã hóa query tìm kiếm và bảo vệ dữ liệu `localStorage` không hợp lệ.
- Không có cơ chế chọn theme/màu xanh trong repo này; phần nền cần tích hợp vào hệ thống theme nếu đó là mục tiêu của sản phẩm.

## Interaction Diagrams

### Tải trang chủ

```mermaid
sequenceDiagram
  participant U as Người xem
  participant N as Next.js Home Route
  participant F as getHomePageMovies
  participant A as JoyFilm Server API
  participant C as Carousel và MovieSlide
  U->>N: Mở /
  N->>F: Lấy danh sách trang chủ
  F->>A: GET actions
  A-->>F: Dữ liệu phim JSON
  F-->>N: Payload danh mục
  N->>C: Truyền dữ liệu từng nhóm
  C-->>U: Hiển thị carousel và các rail
```

Văn bản thay thế: yêu cầu trang chủ kích hoạt fetch helper, backend trả payload phim, rồi route truyền dữ liệu cho carousel và các dải phim.

### Lưu phim

```mermaid
sequenceDiagram
  participant U as Người xem
  participant B as Nút lưu phim
  participant S as SaveProvider
  participant L as localStorage
  U->>B: Chọn lưu hoặc bỏ lưu
  B->>S: toggleSaveMovie(movie)
  S->>S: Kiểm tra movie đã tồn tại
  S->>L: Ghi danh sách JSON mới
  S-->>B: Cập nhật context
  B-->>U: Hiển thị trạng thái đã lưu
```

Văn bản thay thế: nút gửi phim tới context; context cập nhật state và localStorage rồi UI phản ánh trạng thái mới.
