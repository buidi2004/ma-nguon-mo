# Triển khai endpoint số liệu `/metrics` cho máy chủ VPS

> **Mục tiêu:** màn hình *Giám sát Máy chủ VPS* hiển thị **số thật** (CPU, RAM,
> dung lượng, uptime, load, kernel, phiên bản dịch vụ) thay vì `—`.
>
> **Bối cảnh:** trước Giai đoạn 2, backend chỉ có `/api/health` (trả `canBackup`)
> và `/api/collections/movies/records`. Không có nguồn nào cho số liệu hệ thống,
> nên app **không được phép** hiển thị số ước lượng (xem
> `docs/qa/BAO_CAO_LOI_DU_LIEU_GIAM_SAT_VPS.md`).

---

## 1. Kiến trúc

```
VPS Linux
├── /opt/openflix-vps-metrics/openflix-metrics.sh     ← agent (bash, đọc /proc, df, du)
├── systemd timer openflix-metrics.timer (5s)         ← chạy agent định kỳ
├── /var/www/openflix-metrics/metrics.json            ← kết quả JSON (root:www-data 640)
└── nginx: location = /metrics                        ← phục vụ file JSON (có token)
        ▲
        │ GET /metrics   (header X-Metrics-Token)
        │
   App Flutter (ServerMetricsClient → ServerTelemetryService → ServerMonitorScreen)
```

Không có số nào bị hardcode trong agent lẫn trong app: chỉ số không đọc được
sẽ là `null` và giao diện hiển thị `—`.

---

## 2. Các file đã thêm vào repo

| Đường dẫn | Nội dung |
|---|---|
| `backend/vps/metrics/openflix-metrics.sh` | Agent thu thập số liệu, xuất JSON |
| `backend/vps/metrics/openflix-metrics.service` | systemd oneshot service |
| `backend/vps/metrics/openflix-metrics.timer` | Chạy mỗi 5 giây |
| `backend/vps/metrics/nginx-openflix-metrics.conf` | Khối `location = /metrics` (token / allowlist) |
| `backend/vps/metrics/README.md` | Hướng dẫn cài đặt chi tiết |
| `lib/features/admin/services/server_metrics.dart` | Model + client đọc `/metrics` |
| `lib/features/admin/services/server_telemetry_service.dart` | Gọi `/metrics`, nạp số thật |
| `lib/features/admin/server_monitor_screen.dart` | Hiển thị số thật / `—` + mục *Thông số Vận hành* |

---

## 3. Các bước triển khai (làm trên VPS)

```bash
# --- 3.1. Agent -------------------------------------------------------------
sudo mkdir -p /opt/openflix-vps-metrics
sudo cp openflix-metrics.sh /opt/openflix-vps-metrics/
sudo chmod 755 /opt/openflix-vps-metrics/openflix-metrics.sh

sudo mkdir -p /var/www/openflix-metrics
sudo chown root:www-data /var/www/openflix-metrics

# Chạy thử
sudo OUT_FILE=/var/www/openflix-metrics/metrics.json \
     /opt/openflix-vps-metrics/openflix-metrics.sh
cat /var/www/openflix-metrics/metrics.json

# --- 3.2. systemd ----------------------------------------------------------
sudo cp openflix-metrics.service openflix-metrics.timer /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now openflix-metrics.timer
systemctl list-timers openflix-metrics.timer

# --- 3.3. nginx ------------------------------------------------------------
TOKEN="$(openssl rand -hex 32)"
echo "Token của bạn: $TOKEN"      # lưu lại để nạp vào app

sudo mkdir -p /etc/nginx/snippets
sudo cp nginx-openflix-metrics.conf /etc/nginx/snippets/
sudo sed -i "s/THAY_BANG_TOKEN_NGAU_NHIEN_CUA_BAN/$TOKEN/" \
        /etc/nginx/snippets/nginx-openflix-metrics.conf

# Chèn include vào server block cổng 80 (đặt TRƯỚC location /):
#   include snippets/nginx-openflix-metrics.conf;
sudo nginx -t && sudo systemctl reload nginx
```

---

## 4. Nạp token vào ứng dụng

Token **không** được ghi vào mã nguồn. Chọn một trong hai cách:

**Cách A — nhúng lúc build (khuyến nghị cho CI/CD):**

```bash
flutter build apk --dart-define=OPENFLIX_METRICS_TOKEN=<token>
flutter build windows --dart-define=OPENFLIX_METRICS_TOKEN=<token>
```

**Cách B — cấu hình lúc chạy:**

```dart
ServerTelemetryService.instance.configureMetrics(
  uri: Uri.parse('http://180.93.120.246/metrics'), // tuỳ chọn
  token: '<token>',
);
```

Mặc định, app gọi `http(s)://<host-của-backend>/metrics`, nên chỉ cần đặt token
là đủ.

---

## 5. Nghiệm thu

| # | Kiểm tra | Kỳ vọng |
|---|---|---|
| 5.1 | `curl -i http://180.93.120.246/metrics` | **403** (thiếu token) |
| 5.2 | `curl -s -H "X-Metrics-Token: <token>" http://180.93.120.246/metrics` | JSON đúng schema, có `cpu_percent`, `mem_used_mb`, `disk_used_gb` |
| 5.3 | `cat /var/www/openflix-metrics/metrics.json \| grep generated_at` | Cập nhật mỗi ~5 giây |
| 5.4 | App → Giám sát Máy chủ | Thẻ CPU/RAM/SSD hiện số thật; ghi chú đổi thành *"Số liệu đo trực tiếp từ …/metrics"* |
| 5.5 | App → mục *Thông số Vận hành* | Có uptime, load 1 phút, kernel, Docker, PocketBase |
| 5.6 | Đối chiếu với SSH: `nproc`, `free -m`, `df -h /`, `uptime` | Khớp với app |
| 5.7 | Dừng timer (`systemctl stop openflix-metrics.timer`) | App quay về `—` + ghi chú; **không** có số cũ hay số bịa |
| 5.8 | `flutter test test/admin_security_and_telemetry_test.dart` | All tests passed |

---

## 6. Xử lý sự cố

| Hiện tượng | Nguyên nhân thường gặp |
|---|---|
| `/metrics` trả 403 dù đã có token | Token trong nginx khác token trong app; hoặc chưa `reload nginx` |
| `/metrics` trả 404 | Chưa `include snippets/nginx-openflix-metrics.conf;` trong server block cổng 80 |
| `/metrics` trả 500 | File JSON không đọc được: kiểm tra `chmod 640`, `chgrp www-data` |
| `cpu_percent` luôn `null` | Không đọc được `/proc/stat` (hiếm) hoặc script chạy thiếu quyền |
| `disk_media_gb` luôn `null` | `MEDIA_DIR` sai → sửa `Environment=MEDIA_DIR=` trong unit file |
| App vẫn hiện `—` dù curl OK | App chưa có token (`--dart-define`) hoặc đang trỏ sai host |

---

## 7. Ghi chú vận hành

- Timer chạy mỗi 5s; app poll mỗi 2.5s nên số liệu có thể "trễ" tối đa ~5 giây —
  màn hình hiển thị `generated_at` để kiểm chứng độ mới.
- Nếu muốn số liệu mịn hơn, giảm `OnUnitActiveSec` (ví dụ `2s`) — đổi lại tốn CPU hơn.
- Nếu chuyển sang HTTPS, cập nhật `configureMetrics`/backend scheme để app gọi đúng cổng 443.
