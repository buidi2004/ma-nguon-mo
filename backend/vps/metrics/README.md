# OpenFlix — Agent số liệu VPS (`/metrics`)

Bộ file này cung cấp **số liệu hệ thống thật** của VPS cho màn hình
**Giám sát Máy chủ** trong ứng dụng OpenFlix.

Trước khi triển khai bộ này, ứng dụng chỉ hiển thị cấu hình tĩnh của gói VPS
(1 Core · 2 GB RAM · 25 GB SSD) và để `—` cho mọi chỉ số đo lường, vì máy chủ
**không có nguồn số liệu nào để đọc**.

## Thành phần

| File | Vai trò |
|---|---|
| `openflix-metrics.sh` | Đọc `/proc`, `df`, `du`, `uptime` → ghi JSON. Không hardcode số nào. |
| `openflix-metrics.service` | systemd unit chạy script một lần (oneshot). |
| `openflix-metrics.timer` | Chạy lại mỗi 5 giây. |
| `nginx-openflix-metrics.conf` | Khối `location = /metrics` cho nginx (có token/allowlist). |

## Định dạng JSON xuất ra

```json
{"generated_at":"2026-10-19T02:00:00Z",
 "cpu_percent":7.4,"load1":0.08,"load5":0.05,"load15":0.04,"cores":1,
 "mem_total_mb":2048,"mem_used_mb":731,"mem_available_mb":1250,
 "swap_total_mb":2048,"swap_used_mb":0,
 "disk_total_gb":25.00,"disk_used_gb":8.30,"disk_avail_gb":16.70,
 "disk_os_gb":5.12,"disk_db_gb":2.40,"disk_media_gb":0.78,
 "uptime_s":1834920,"kernel":"6.8.0-41-generic","os_pretty":"Ubuntu 24.04.1 LTS",
 "docker_version":"29.1.3","pocketbase_version":"0.22.29",
 "services":{"pocketbase":true,"nginx":true,"docker":true}}
```

Chỉ số nào không đọc được sẽ là `null` (ví dụ chưa cài Docker).
**Agent không bao giờ điền số ước lượng.**

## Cài đặt

```bash
# 1. Copy agent lên VPS
sudo mkdir -p /opt/openflix-vps-metrics
sudo cp openflix-metrics.sh /opt/openflix-vps-metrics/
sudo chmod 755 /opt/openflix-vps-metrics/openflix-metrics.sh

# 2. Thư mục web chứa file JSON
sudo mkdir -p /var/www/openflix-metrics
sudo chown root:www-data /var/www/openflix-metrics

# 3. Chạy thử 1 lần
sudo OUT_FILE=/var/www/openflix-metrics/metrics.json \
     /opt/openflix-vps-metrics/openflix-metrics.sh
cat /var/www/openflix-metrics/metrics.json

# 4. systemd
sudo cp openflix-metrics.service openflix-metrics.timer /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now openflix-metrics.timer
systemctl list-timers openflix-metrics.timer

# 5. nginx — dán khối location = /metrics vào server block cổng 80
sudo cp nginx-openflix-metrics.conf /etc/nginx/snippets/
sudo nano /etc/nginx/sites-available/openflix.conf   # include snippets/nginx-openflix-metrics.conf;
sudo nginx -t && sudo systemctl reload nginx
```

## Cấu hình app

`/metrics` **mặc định** được suy ra từ host của backend (cổng 80/443 theo scheme).

**Đổi token (khuyến nghị)** — token được nhúng lúc build:

```bash
flutter build apk --dart-define=OPENFLIX_METRICS_TOKEN=<token-ngẫu-nhiên>
```

hoặc đổi địa chỉ/token lúc chạy:

```dart
ServerTelemetryService.instance.configureMetrics(
  uri: Uri.parse('http://180.93.120.246/metrics'),
  token: '<token-ngẫu-nhiên>',
);
```

## Kiểm tra

```bash
# Không token → 403
curl -i http://180.93.120.246/metrics

# Có token → JSON
curl -s -H "X-Metrics-Token: <token>" http://180.93.120.246/metrics | python3 -m json.tool
```

Trên app: mở **Giám sát Máy chủ** → thẻ *Vi xử lý VPS* / *RAM* / *Ổ cứng* hiện số
thật, khối ghi chú chuyển thành *"Số liệu đo trực tiếp từ …/metrics"*, và mục
**Thông số Vận hành** hiện uptime, load, kernel, Docker, PocketBase.

## Bảo mật & lưu ý

- Endpoint lộ %CPU, RAM và dung lượng ổ cứng → **luôn** bật token hoặc allowlist IP.
- Nếu tên miền có HTTPS, dùng `https://.../metrics` (app tự theo scheme của backend).
- Đổi `MEDIA_DIR` trong unit file nếu thư mục poster/video nằm ở đường dẫn khác;
  nếu không tồn tại, `disk_media_gb` sẽ là `null` (an toàn, không bịa số).
- `POCKETBASE_VERSION` là tuỳ chọn — chỉ đặt nếu muốn ghim phiên bản hiển thị.
