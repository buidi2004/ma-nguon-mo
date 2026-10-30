# Danh mục thành phần

## Frontend App Router

- Trách nhiệm: điều phối trang chủ, danh mục, chi tiết, tìm kiếm, danh sách đã lưu; dùng server/client components theo nhu cầu.
- Phụ thuộc: fetch helpers, UI components và layout gốc.

## RootLayout

- Trách nhiệm: tải font Inter, metadata, Header, SaveProvider, nút lưu nhanh, nội dung route và Footer.
- Phụ thuộc: Next font, Header, Footer, SaveProvider, SavedButton.

## HomePage

- Trách nhiệm: lấy payload phim trang chủ và render hero carousel cùng năm rail phim.
- Phụ thuộc: `getHomePageMovies`, CarouselThumbnails, MovieSlide.

## CategoryPages

- Trách nhiệm: render lưới phim và phân trang cho năm loại danh mục.
- Phụ thuộc: `getPageMovies`, MovieCard, PageButtons.

## MovieDetailPage

- Trách nhiệm: tải dữ liệu theo slug và chọn màn hình thông tin hoặc phát tập theo query.
- Phụ thuộc: `getMovie`, MovieInfoSection, MovieMediaSection.

## SearchPage

- Trách nhiệm: quản lý input/query, tìm kiếm phim và hiển thị spinner, kết quả hoặc thông báo không thấy kết quả.
- Phụ thuộc: `searchMovies`, MovieCard, Next router.

## SavedMoviesPage

- Trách nhiệm: trình bày danh sách được lưu trong browser context.
- Phụ thuộc: SaveProvider, MovieCard.

## Header

- Trách nhiệm: logo, điều hướng, tìm kiếm desktop và menu tìm kiếm/điều hướng trên màn hình nhỏ.
- Phụ thuộc: Next Link/Image, BlurBox.

## Footer

- Trách nhiệm: logo và liên kết giới thiệu, GitHub, API và liên hệ.
- Phụ thuộc: Next Link/Image.

## CarouselThumbnails

- Trách nhiệm: hiển thị hero carousel với bốn mục được khai báo tĩnh, CTA xem phim và lưu phim; CSS thay đổi layout dưới 768px.
- Phụ thuộc: Carousel3, CarouselSaveBtn, Next Link.

## MovieSlide

- Trách nhiệm: hiển thị rail phim có vuốt, chấm trạng thái và nút tiến/lùi.
- Phụ thuộc: Slider3, MovieCard, react-slick.

## MovieCard

- Trách nhiệm: poster tỷ lệ dọc, tên phim và liên kết sang trang chi tiết.
- Phụ thuộc: Next Link/Image.

## MovieInfoSection

- Trách nhiệm: poster nền, metadata, phân loại, CTA phát/lưu, nội dung và trailer.
- Phụ thuộc: SaveProvider, ContentInfo, TrailerPlayer, BlurBox, Next Link/Image.

## MovieMediaSection

- Trách nhiệm: nhúng player, đổi player, chọn server/tập và lưu phim.
- Phụ thuộc: SaveProvider, ReactPlayer, Next Link, BlurBox.

## ContentInfo

- Trách nhiệm: thu gọn/mở rộng mô tả phim.
- Phụ thuộc: client state.

## TrailerPlayer

- Trách nhiệm: hiển thị video trailer theo URL.
- Phụ thuộc: ReactPlayer.

## SaveProvider

- Trách nhiệm: giữ danh sách đã lưu, kiểm tra tồn tại và đồng bộ JSON vào localStorage.
- Phụ thuộc: React context/state/effect và browser localStorage.

## SavedButton

- Trách nhiệm: mở trang danh sách đã lưu và hiển thị số lượng.
- Phụ thuộc: SaveProvider, BlurBox, Next Link.

## CarouselSaveBtn

- Trách nhiệm: bật/tắt lưu cho mục đang ở hero carousel.
- Phụ thuộc: SaveProvider.

## PageButtons

- Trách nhiệm: tạo dải liên kết phân trang có giới hạn số trang xung quanh trang hiện tại.
- Phụ thuộc: Next Link.

## BlurBox

- Trách nhiệm: wrapper nền mờ/blur dùng trong header và control nổi.
- Phụ thuộc: CSS/Tailwind backdrop filter.

## Carousel3

- Trách nhiệm: tái xuất carousel `react-responsive-carousel`.
- Phụ thuộc: react-responsive-carousel.

## Slider3

- Trách nhiệm: tái xuất slider `react-slick`.
- Phụ thuộc: react-slick.

## Data Fetch Helpers

- Trách nhiệm: gọi API cho trang chủ, danh mục, chi tiết phim và tìm kiếm.
- Phụ thuộc: Fetch API và hai dịch vụ từ xa JoyFilm Server/OPhim.

## useTitle

- Trách nhiệm: cập nhật `document.title` trong client.
- Phụ thuộc: React `useEffect`.
