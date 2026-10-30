# Tổng quan nghiệp vụ

## Mục đích

JoyFilm là giao diện web tiếng Việt để khám phá và xem phim. Người dùng có thể duyệt phim mới, phim chiếu rạp, phim lẻ, phim bộ và hoạt hình; xem thông tin phim, tìm kiếm, lưu phim vào danh sách cá nhân và phát nội dung.

## Chức năng chính

- Trang chủ tải dữ liệu danh mục từ backend JoyFilm, trình bày carousel phim nổi bật và các dải phim theo nhóm.
- Các trang danh mục có lưới poster và phân trang.
- Trang phim hiển thị thông tin, trailer, danh sách tập và lựa chọn trình phát.
- Tìm kiếm gọi API bên ngoài; danh sách đã lưu được giữ trong `localStorage` của trình duyệt.

## Đối tượng sử dụng và ranh giới

Người xem sử dụng frontend Next.js. Backend, dữ liệu phim và nhà cung cấp media ở ngoài repo `fe-web`; đây không phải ứng dụng Flutter trong thư mục workspace cha.
