# Phụ thuộc

## Phụ thuộc nội bộ

- `src/app/page.jsx` → `getHomePageMovies`, `CarouselThumbnails`, `MovieSlide`.
- Trang danh mục → `getPageMovies`, `MovieCard`, `PageButtons`.
- Trang chi tiết → `getMovie`, `MovieInfoSection`, `MovieMediaSection`.
- Header/SavedButton/MovieInfoSection/MovieMediaSection/CarouselSaveBtn → `saveContext` trực tiếp hoặc qua RootLayout.
- MovieInfoSection → ContentInfo, TrailerPlayer, BlurBox.
- MovieSlide → Slider3 và MovieCard.

## Dịch vụ bên ngoài

- JoyFilm Server Netlify Functions: dữ liệu trang chủ, danh mục, tìm kiếm.
- OPhim: chi tiết phim/tập và ảnh poster từ các host `img.ophim*.cc`.
- Nhà cung cấp embed/HLS do dữ liệu trả về chỉ định.
- Google Fonts qua Next `next/font/google` cho Inter.

## Tương quan gói

- Next phụ thuộc React; Tailwind chạy qua PostCSS/Autoprefixer.
- React Slick dựa vào slick-carousel styles.
- React Responsive Carousel, React Player và Sharp là thư viện UI/media/image độc lập.
- Không thấy package workspace hoặc package nội bộ khác trong repo `fe-web`.
