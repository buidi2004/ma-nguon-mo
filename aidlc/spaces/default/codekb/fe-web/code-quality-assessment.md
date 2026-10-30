# Đánh giá chất lượng mã

## Tổng quan

- **Độ rõ tên gọi: Khá** — route và component chủ yếu mang tên theo chức năng.
- **Kích thước/trách nhiệm: Trung bình** — một số component trang chi tiết gộp nhiều presentation/control.
- **Xử lý lỗi: Cần cải thiện** — fetch helper ném lỗi chung; client effect không bắt lỗi hoặc có giao diện thử lại.
- **Kiểm thử: Yếu/không có** — không tìm thấy test hoặc test framework trong `fe-web`.
- **Tính lặp: Trung bình** — các route danh mục lặp cấu trúc lưới, loading và metadata.
- **Dead code/tĩnh: Chưa xác minh toàn diện** — không chạy phân tích tĩnh trong scan.

## Bảo trì và vận hành

- Có README tiếng Việt cùng loading component; trang tìm kiếm có trạng thái đang tải và rỗng.
- Không thấy pipeline CI, coverage hoặc cấu hình ESLint chuyên biệt; script `next lint` có trong package manifest.
- Dữ liệu nhạy cảm không được thấy trong cấu hình, nhưng API URLs được hard-code trong fetch helpers.
- `localStorage` parse không được bảo vệ; query tìm kiếm không được encode; nội dung phim được render bằng `dangerouslySetInnerHTML`.

## Khả năng đáp ứng ý định hiện tại

Trang chủ hỗ trợ layout mobile bằng CSS carousel responsive và các rail. Tuy vậy không tìm thấy biến thể theme, nút chọn xanh hay trạng thái theme trong frontend này; chỉ có token màu accent xanh và nền xám đen. Nếu người dùng nói tới mobile app Flutter ở workspace cha thì cần chuyển việc sang repo đó.
