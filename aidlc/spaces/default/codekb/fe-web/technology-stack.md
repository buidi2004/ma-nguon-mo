# Công nghệ sử dụng

## Runtime và framework

- JavaScript, JSX.
- Next.js 13.4.19 với App Router; React và React DOM 18.2.0.
- Node.js/npm là runtime/package manager ngầm định bởi scripts npm.

## UI và media

- Tailwind CSS 3.3.3, PostCSS 8.4.29, Autoprefixer 10.4.15.
- `react-responsive-carousel` ^3.2.23 và `react-slick` ^0.29.0 cùng `slick-carousel` ^1.8.1.
- `react-player` ^2.13.0 và `sharp` ^0.32.5.
- Next Image tối ưu ảnh; cấu hình cho phép host ảnh `img.ophim1.cc` đến `img.ophim9.cc`.

## Chất lượng và triển khai

- Script kiểm tra: `next lint`; không thấy cấu hình hoặc bộ test được khai báo.
- README mô tả deploy frontend lên Vercel và backend lên Netlify.
- Không thấy TypeScript, database client, API server, hoặc công cụ CI trong repo này.
