# Tài liệu API

## API phim trang chủ

- **Phương thức/đường dẫn**: `GET https://joyfilm-server.netlify.app/.netlify/functions/actions`
- **Mã gọi**: `src/functions/getHomePageMovies.js`
- **Dùng tại**: `src/app/page.jsx`
- **Cache**: Next revalidate sau 18.000 giây.
- **Payload được dùng**: `data.newMovies`, `data.theaterMovies`, `data.singleMovies`, `data.seriesMovies`, `data.cartoonMovies`.
- **Lỗi**: ném `Error('Failed to fetch data')` khi response không OK; không có retry trong helper.

## API danh mục

- **Phương thức/đường dẫn**: `GET https://joyfilm-server.netlify.app/.netlify/functions/actions/{type}/{page}`
- **Mã gọi**: `src/functions/getPageMovies.js`
- **Loại hiện dùng**: `theater`, `cartoon`, `series`, `single`, `new`.
- **Payload được dùng**: `data` là danh sách phim; `totalPages` cho phân trang.
- **Cache**: Next revalidate sau 18.000 giây.

## API tìm kiếm

- **Phương thức/đường dẫn**: `GET https://joyfilm-server.netlify.app/.netlify/functions/actions/search?name={name}`
- **Mã gọi**: `src/functions/searchMovies.js`
- **Payload được dùng**: `data` là danh sách kết quả.
- **Lưu ý**: query được nối trực tiếp, chưa mã hóa bằng `URLSearchParams`/`encodeURIComponent`.

## API chi tiết phim

- **Phương thức/đường dẫn**: `GET https://ophim1.com/phim/{slug}`
- **Mã gọi**: `src/functions/getMovie.js`; trang dùng trong client effect.
- **Payload được dùng**: `movie`, `episodes`; thông tin tập có `server_data`, `link_embed`, `link_m3u8`.
- **Lỗi**: helper ném lỗi chung khi response không OK; component không thể hiện trạng thái lỗi.

## Hợp đồng và xác thực

Không có OpenAPI schema, route backend, kiểm soát xác thực, hay rate limit configuration trong repo frontend. Hợp đồng trên được suy ra từ thuộc tính mà component đọc; backend mới là nguồn chính thức cho schema.
