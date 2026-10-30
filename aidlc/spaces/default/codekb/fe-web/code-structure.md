# Cấu trúc mã nguồn

## Các vùng chính

- `src/app/`: App Router, layout gốc, trang chủ, danh mục, chi tiết, tìm kiếm, phim đã lưu và các loading boundary.
- `src/components/`: thành phần UI dùng lại, carousel, thẻ phim, thông tin/phát phim, điều hướng và footer.
- `src/functions/`: fetch helper cho home, danh mục, chi tiết phim và tìm kiếm.
- `src/contexts/`: context danh sách đã lưu.
- `src/hooks/`: hook cập nhật tiêu đề trang.
- `public/`: logo, biểu tượng đánh dấu, poster carousel và ảnh giao diện.

## Phân loại

- **Trang/điều phối route**: `src/app/**/page.jsx` — lấy dữ liệu hoặc kết nối các component theo route.
- **Giao diện**: `src/components/**` — JSX; `MovieSlide.css` và `CarouselThumbnails.css` cung cấp kiểu riêng.
- **Dịch vụ dữ liệu**: `src/functions/*.js` — fetch API, không có lớp repository hay model riêng.
- **State và tiện ích**: `src/contexts/saveContext.jsx`, `src/hooks/useTitle.js`.
- **Cấu hình**: manifest npm, Next, Tailwind, PostCSS, alias `@/*`.
- **Kiểm thử**: không có thư mục hoặc file test trong repo.

## Phụ thuộc nội bộ

- RootLayout → Header, Footer, SaveProvider, SavedButton.
- Trang chủ → `getHomePageMovies`, CarouselThumbnails, MovieSlide.
- Trang danh mục → `getPageMovies`, MovieCard, PageButtons.
- Chi tiết phim → `getMovie`, MovieInfoSection, MovieMediaSection.
- Thành phần lưu → `saveContext`; MovieInfoSection và MovieMediaSection dùng thêm ContentInfo/TrailerPlayer.

## Mẫu mã

App Router kết hợp server route components cho danh mục/trang chủ và client components cho state trình duyệt. UI dùng Tailwind utility classes; một số layout carousel cần CSS tùy chỉnh. Alias `@/*` trỏ đến `src/*`.
