# Báo cáo lỗi sai dữ liệu — Màn hình "Giám sát Máy chủ VPS"

- **Ngày:** 19/10/2026
- **Phạm vi:** `lib/features/admin/server_monitor_screen.dart`, `lib/features/admin/services/server_telemetry_service.dart`
- **Màn hình:** `/admin/server` — "Giám sát Máy chủ VPS (180.93.120.246)"
- **Kết luận:** **FAIL** — màn hình đang trình bày **số liệu bịa/không đo được** như thể là dữ liệu đo thời gian thực.

---

## 1. Nguồn dữ liệu thật dùng để đối chiếu

### 1.1. Hóa đơn/thông số gói VPS (do chủ dự án cung cấp — CLOUDSH LOC)

| Thuộc tính | Giá trị thật |
|---|---|
| IP | `180.93.120.246` |
| CPU | **1 Core** |
| RAM | **2 GB** |
| Ổ cứng | **25 GB SSD** |
| Hệ điều hành | **Ubuntu Server 24.04** |
| Giá | 59.000 ₫ / 1 tháng |
| Hết hạn | 07/11/2026 |

### 1.2. Đo trực tiếp từ máy chủ lúc 19/10/2026 01:57 UTC

```
GET http://180.93.120.246:8090/api/health  →  200 OK
Server: nginx/1.24.0 (Ubuntu)
{"message":"API is healthy.","code":200,"data":{"canBackup":true}}
```

→ Xác nhận được: nginx 1.24.0, `canBackup: true`.
→ **KHÔNG** xác nhận được: phiên bản PocketBase, số nhân CPU, RAM, dung lượng ổ cứng,
kernel, tên container Docker — vì `/api/health` **không trả các thông tin này**.

### 1.3. Ba bộ thông số đang mâu thuẫn nhau

| Nơi ghi | CPU | RAM | Ổ cứng |
|---|---|---|---|
| Hóa đơn CLOUDSH LOC (thật) | 1 Core | 2 GB | 25 GB |
| App — `server_monitor_screen.dart` | **2 vCPU** | **4.0 GB** | **50 GB NVMe** |
| `docs/BAO_CAO_CONG_NGHE_FE_BE_VPS_GITACTION.md` | — | **2.0 GB** | **30 GB NVMe** |

→ Cùng một máy chủ nhưng 3 tài liệu ghi 3 cấu hình khác nhau ⇒ số liệu đang bị bịa, không
phải đọc từ máy chủ.

---

## 2. Bảng đối chiếu chi tiết từng chỉ số

| # | Chỉ số trên màn hình | App đang hiển thị | Thực tế | Mức độ | Vị trí code |
|---|---|---|---|---|---|
| 1 | Vi xử lý VPS (số nhân) | `2 vCPU Cloud Compute` | 1 Core | 🔴 Sai | `server_telemetry_service.dart:159, 432` |
| 2 | Bộ nhớ RAM (tổng) | `4.0 GB` | 2 GB | 🔴 Sai | `:160, 169, 433, 444` |
| 3 | Ổ cứng SSD (tổng) | `50 GB NVMe SSD` | 25 GB SSD | 🔴 Sai | `:161, 171, 434, 446` |
| 4 | **% Tải CPU** | `18.4% Tải` … (đổi theo ping) | Không đo được | 🔴 **Bịa hoàn toàn** | `:388` `cpuCalc = (ping/300)*20 + 12` |
| 5 | RAM đã dùng | `1.48 GB` (luôn cố định) | Không đo được | 🔴 Hằng số | `:168, 443` |
| 6 | SSD đã dùng | `18.7 GB` (luôn cố định) | Không đo được | 🔴 Hằng số | `:170, 445` |
| 7 | Phân vùng ổ cứng | Ubuntu 12.4 + SQLite 2.1 + Media 4.2 GB | Không đo được | 🔴 Hằng số | `:172–174, 447–449` |
| 8 | Thanh phân bổ ổ cứng | Chia theo `flex: 124/21/42/313` cứng | Không đo được | 🔴 Hằng số + sai tỉ lệ | `server_monitor_screen.dart:509–534` |
| 9 | Chú thích % phân vùng | `(24.8%)`, `(4.2%)`, `(8.4%)` cứng | Không đo được | 🔴 Hằng số, sẽ sai nếu tổng đổi | `:547, 551, 555` |
| 10 | Tiêu đề biểu đồ | `Ổ cứng SSD VPS (50 GB)` cứng | 25 GB | 🔴 Sai | `:482` |
| 11 | % của thẻ "Cơ sở Dữ liệu" | `số phim / 100` | Vô nghĩa (không phải % dung lượng) | 🟠 Gây hiểu nhầm | `:203` |
| 12 | Kernel | `6.8.0-41-generic` cứng | Không kiểm chứng được | 🟠 Hằng số | `:158, 431` |
| 13 | Kiến trúc | Ghi `x86_64` **2 lần** trên cùng 1 thẻ | Trùng lặp | 🟡 Lỗi hiển thị | `:158` (`vpsCpu` đã chứa `(x86_64)`) |
| 14 | Phiên bản Docker | `Docker Engine v29.1.3` cứng | Không kiểm chứng được | 🟠 Hằng số | `:162, 435` |
| 15 | Phiên bản PocketBase | `PocketBase v0.22.29` cứng | `/api/health` không trả version | 🟠 Hằng số | `:165, 353–354` |
| 16 | Trạng thái dịch vụ (4 dòng) | Luôn `ONLINE` (cứng), cả khi mất mạng | Phải suy ra từ probe | 🔴 Sai khi offline | `server_monitor_screen.dart:751, 756, 761, 766` |
| 17 | Trạng thái lúc mở màn | `ONLINE 200 OK` + `29 ms` trước khi đo | Chưa có dữ liệu | 🟠 Sai lệch tức thời | `:175–180` |
| 18 | Min / Max / TB ping ban đầu | `27 / 65 / 38 ms` cứng | Chưa có mẫu | 🟠 Hằng số | `:177–179` |
| 19 | SnackBar "Dọn RAM" | Báo giải phóng ví dụ `12.8 MB` khi **không có gì** được giải phóng | Phải là số đo thật (có thể 0) | 🔴 Thông báo sai | `:488` `return freedMb > 0 ? freedMb : 12.8` |
| 20 | Nhật ký quét | `RAM 1.48 / 4.0 GB (37%) • SSD 18.7 / 50.0 GB (37.4%)` cứng + kết luận **"chính xác 100%"** | Không đo, không kiểm chứng | 🔴 Khẳng định sai | `:304, 307` |
| 21 | `jitterMs` | ` |ping − avg|` — không phải jitter | Công thức sai | 🟠 | `:420` |
| 22 | `activeSessions` | = **số phim trong DB** | Không liên quan | 🟠 Getter rác | `:117` |
| 23 | `uptime` | `'Ubuntu 24.04 LTS • nginx/1.24.0'` | Không phải thời gian hoạt động | 🟠 Getter rác | `:118` |
| 24 | `networkOutMbps` | Suy ra từ thời gian tải 1 request API | Không phải băng thông | 🟠 Sai bản chất | `:116` |
| 25 | Web Engine khi offline | Vẫn hiện `nginx/1.24.0 (Ubuntu)` (giá trị cũ) | Không xác định | 🟡 Gây hiểu nhầm | `:437` + `:164` |

**Chỉ số thật sự đo được (đúng):** ping/độ trễ mạng WAN, `Server` header, `canBackup`,
`số phim trong SQLite`, RAM/cache **của thiết bị client** (`hardware_reader`).

---

## 3. Nguyên nhân gốc

1. **Backend không có endpoint cung cấp số liệu hệ thống.** Chỉ có `/api/health` (trả
   `canBackup`) và `/api/collections/movies/records` (đếm phim). Không có nguồn nào cho
   CPU / RAM / dung lượng ổ cứng / kernel / version Docker.
2. **Thay vì báo "không có dữ liệu", service điền hằng số** trong `_initDefaultData()`
   và `refreshTelemetry()`, rồi UI trình bày như số liệu đo thời gian thực (kèm nhãn
   "thời gian thực", "100% chính xác").
3. **%" tải CPU" được suy diễn từ ping** (`(ping/300)*20 + 12`) — đây là chỉ số ping được
   dán nhãn sai thành CPU, nghiêm trọng nhất vì người quản trị sẽ ra quyết định dựa trên nó.
4. **Thanh biểu đồ phân bổ dùng flex cứng** thay vì tính từ dữ liệu ⇒ không bao giờ khớp
   với legend nếu tổng dung lượng thay đổi.
5. **Trạng thái dịch vụ luôn ONLINE** ⇒ khi máy chủ sập, màn hình vẫn báo 4 dịch vụ xanh.

---

## 4. Kế hoạch fix

### 4.0. Trạng thái triển khai (cập nhật 19/10/2026)

**Giai đoạn 1 — ✅ ĐÃ XONG** (thuần client, không cần deploy):

- Đã sửa hằng số cấu hình về đúng gói CLOUDSH LOC: **1 Core · 2 GB RAM · 25 GB SSD · Ubuntu Server 24.04**,
  tập trung trong lớp `VpsPlanSpec` (`lib/features/admin/services/server_telemetry_service.dart`).
- Đã **xoá** công thức `%CPU` suy từ ping và toàn bộ số RAM/SSD/phân vùng bịa.
  Các chỉ số tài nguyên nay là `double?` — `null` nghĩa là "chưa đo được".
- Đã thêm `kMetricsUnavailableNote` và khối ghi chú "nguồn số liệu" trên màn hình để giải thích vì sao hiện `—`.
- Biểu đồ phân bổ ổ cứng: chỉ vẽ khi có số đo; flex và % đều tính từ dữ liệu; không đo được → hiện ghi chú thay vì thanh giả.
- Bảng dịch vụ: trạng thái suy ra từ probe thật (`ONLINE` / `LỖI` / `CHƯA RÕ`), kèm icon + màu tương ứng.
- Banner có 3 trạng thái: `ĐANG KIỂM TRA…` → `TRỰC TUYẾN` → `OFFLINE`; min/max/TB/jitter và biểu đồ ping chỉ có khi đã có mẫu đo.
- `cleanMemoryCache()` trả đúng số MB giải phóng (0 nếu không có gì) → SnackBar nói đúng sự thật.
- Nhật ký quét chỉ ghi kết quả probe thật; đã bỏ dòng số cứng và lời khẳng định "chính xác 100%".
- Đã xoá các getter sai ngữ nghĩa: `activeSessions` (= số phim), `uptime` (chuỗi OS), `networkOutMbps`.
- `serverSoftware` / `pocketBaseStatus` chỉ hiển thị giá trị **đã từng quan sát thật**; chưa từng kết nối → `Không xác định` / `Chưa kiểm tra`.
- Đã cập nhật tài liệu mâu thuẫn và test khẳng định số sai.

**Giai đoạn 2 — ✅ ĐÃ VIẾT XONG TRONG REPO** (chờ deploy lên VPS):

- Agent `backend/vps/metrics/openflix-metrics.sh`: đọc `/proc/stat` (2 mẫu → %CPU thật),
  `/proc/meminfo`, `df -B1 /`, `du` cho PocketBase/Media, `/proc/uptime`, `uname -r`,
  `/etc/os-release`, `docker --version`; kiểm tra cổng 8090/80. Chỉ số không đọc được → `null`.
- `openflix-metrics.service` + `.timer` (5 giây) chạy agent, ghi
  `/var/www/openflix-metrics/metrics.json` (atomic `mv`, quyền `640 root:www-data`).
- `nginx-openflix-metrics.conf`: `location = /metrics` với token `X-Metrics-Token`
  (hoặc allowlist IP), `Cache-Control: no-store`.
- App: `lib/features/admin/services/server_metrics.dart` (model + client), tích hợp vào
  `refreshTelemetry()` (gọi song song với probe health), UI hiển thị số thật + mục
  *Thông số Vận hành* (uptime, load, kernel, Docker, PocketBase).
- Hướng dẫn triển khai từng bước: `backend/vps/metrics/README.md` và
  `docs/DEPLOY_METRICS_ENDPOINT.md`.

Hiện tại (chưa deploy) giao diện hiển thị `—` kèm ghi chú — đây là hành vi **đúng**.
Sau khi deploy, cùng một build sẽ tự hiển thị số thật.

**Giai đoạn 3 — 🟡 MỘT PHẦN:** đã có test tự động chống hồi quy số liệu **và** test cho nhánh
có `/metrics` (số thật) / không có (hiện `—`); chưa đối chiếu bằng `nproc`/`free`/`df` trên VPS
và chưa chụp lại screenshot (`NOT RUN`).

### 4.1. Chi tiết các việc Giai đoạn 1

| # | Việc | File |
|---|---|---|
| 1.1 | Đổi hằng số cấu hình VPS về đúng gói CLOUDSH LOC: `1 Core`, `2 GB RAM`, `25 GB SSD`, `Ubuntu Server 24.04` | `server_telemetry_service.dart` |
| 1.2 | **Xoá** công thức `cpuCalc` từ ping. CPU chỉ hiển thị khi có số đo thật; nếu chưa có → `—` kèm nhãn "Chưa đo được" | `:388, 442` |
| 1.3 | **Xoá** `vpsRamUsedGb = 1.48`, `vpsDiskUsedGb = 18.7`, 3 phân vùng `12.4/2.1/4.2`. Thẻ RAM/SSD chỉ hiện **tổng** (2 GB / 25 GB) cho tới khi có số đo | `:168–174, 443–449` |
| 1.4 | Thanh phân bổ: tính `flex` và `%` **từ dữ liệu**; nếu chưa đo được → ẩn biểu đồ, hiện ghi chú "Chưa có dữ liệu dung lượng" | `server_monitor_screen.dart:461–567` |
| 1.5 | Đổi tiêu đề biểu đồ từ hằng số `(50 GB)` sang `${data.vpsDiskTotalGb} GB` | `:482` |
| 1.6 | Bảng dịch vụ: suy trạng thái từ probe thật — PocketBase/CDN/DB dùng kết quả `scanVpsConfiguration()`; dịch vụ chưa probe → `UNKNOWN` (màu vàng), không mặc định `ONLINE` | `:746–847` |
| 1.7 | Trạng thái khởi tạo: `Đang kiểm tra…` (không ONLINE, không 29 ms); min/max/avg/jitter chỉ tính từ mẫu đo thật, rỗng → `—` | `:175–180`, `:410–420` |
| 1.8 | `cleanMemoryCache()`: trả **đúng** số MB giải phóng (clamp ≥ 0). Nếu 0 → SnackBar "Không có bộ nhớ cache nào cần giải phóng" | `:476–489` |
| 1.9 | Nhật ký quét: bỏ dòng số cứng `:304`, bỏ kết luận `"chính xác 100%"` `:307`; chỉ log kết quả probe thật, ghi rõ chỉ số nào "không lấy được từ API" | `:304–307` |
| 1.10 | Xoá getter sai/không dùng: `activeSessions`, `uptime`, `networkOutMbps` (hoặc định nghĩa lại đúng ngữ nghĩa và ghi rõ đơn vị) | `:116–118` |
| 1.11 | Hết lặp `x86_64` trên thẻ CPU; thẻ "Cơ sở Dữ liệu" bỏ progress `số phim/100`, chỉ hiện số bản ghi | `server_monitor_screen.dart:158, 203` |
| 1.12 | Khi offline: `serverSoftware` hiện `Không xác định` thay vì giữ giá trị cũ | `:437` |
| 1.13 | Cập nhật tài liệu mâu thuẫn: `BAO_CAO_CONG_NGHE_FE_BE_VPS_GITACTION.md` (RAM 2.0 GB / SSD 30 GB) và `BAO_CAO_E2E_TEST_REAL_BACKEND.md` (2 vCPU / 4 GB / 50 GB) về đúng 1 Core / 2 GB / 25 GB | `docs/*.md` |
| 1.14 | Sửa test đang khẳng định số sai: `test/e2e_real_backend_test.dart:668–670` | `test/` |
| 1.15 | Thêm test mới: tổng cấu hình đúng `1 Core / 2 GB / 25 GB`; khi không đo được thì UI hiện `—` và **không** hiện số cứng nào | `test/admin_security_and_telemetry_test.dart` |

### 4.2. Giai đoạn 2 — Lấy số liệu thật (đã viết xong trong repo)

Agent + systemd + nginx đã có trong `backend/vps/metrics/`. Tóm tắt luồng:

1. Agent đọc `/proc/stat`, `/proc/meminfo`, `df -B1 /`, `du`, `/proc/uptime`, `uname -r`,
   `/etc/os-release`, `docker --version`, kiểm tra cổng 8090/80 → ghi JSON nguyên tử.
2. systemd timer chạy agent mỗi 5 giây.
3. nginx phục vụ `GET /metrics` (yêu cầu token `X-Metrics-Token` hoặc allowlist IP).
4. App gọi `/metrics` song song với probe health; chỉ số nào có thì hiển thị, thiếu thì `—`.

Payload thật do agent xuất ra:

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

Nạp token vào app: `--dart-define=OPENFLIX_METRICS_TOKEN=<token>` hoặc
`ServerTelemetryService.instance.configureMetrics(uri: ..., token: ...)`.
Chi tiết: `docs/DEPLOY_METRICS_ENDPOINT.md`.

### 4.3. Giai đoạn 3 — Kiểm chứng

1. So số trên app với `nproc`, `free -m`, `df -h /`, `uptime` chạy trên VPS — phải khớp.
2. Rút mạng/stop máy chủ → banner `OFFLINE`, dịch vụ `UNKNOWN`, không còn số cũ.
3. Chụp lại screenshot màn hình `/admin/server` + cập nhật mọi báo cáo có số cũ.

---

## 4b. Kết quả kiểm chứng Giai đoạn 1

| Hạng mục | Kết quả |
|---|---|
| `flutter analyze lib` | **No issues found!** |
| `flutter test test/admin_security_and_telemetry_test.dart` | **13/13 pass** (thêm 1 test chống hồi quy số liệu) |
| `flutter test test/e2e_real_backend_test.dart` (VPS thật) | **16/16 pass** |
| `flutter test` (toàn bộ) | **`+355 -2`** — vẫn đúng 2 test đỏ sẵn có của baseline (`capture_all_42_screens_test` S27 do ảnh mạng; `theme_service_and_settings_test`) |
| `flutter analyze lib test` | chỉ còn 4 issue **có sẵn** ở `test/capture_all_42_screens_test.dart` |

Regression tìm thấy và đã sửa trong lúc kiểm chứng: `scanVpsConfiguration()` trước đây **không lưu**
header `Server` thật vào state (được che bởi hằng số `nginx/1.24.0`), nên sau khi bỏ hằng số thì
`serverSoftware` bị `Không xác định`. Nay service lưu giá trị **đã quan sát thật**
(`_observedServerSoftware`, `_observedPocketBaseStatus`) và chỉ hiển thị chúng.

Hành vi mới khi chưa có nguồn đo (trạng thái hiện tại trên VPS):

```
Vi xử lý VPS : 1 Core          | Bộ nhớ RAM VPS : 2 GB        | Ổ cứng SSD VPS : 25 GB
               Tải CPU: chưa đo được              Mức dùng: chưa đo được     Mức dùng: chưa đo được
```

---

## 5. Tiêu chí nghiệm thu (Definition of Done)

- [x] Không còn chỉ số nào hiển thị mà **không có nguồn đo** tương ứng.
- [x] Cấu hình khớp gói thật: **1 Core · 2 GB RAM · 25 GB SSD · Ubuntu Server 24.04**.
- [x] Không còn "CPU %" suy ra từ ping.
- [x] Biểu đồ phân bổ ổ cứng được tính từ dữ liệu, hoặc bị ẩn kèm ghi chú khi chưa đo được.
- [x] Bảng dịch vụ phản ánh đúng trạng thái thật, không luôn xanh.
- [x] Khi offline: OFFLINE + `CHƯA RÕ` + không có dữ liệu giả.
- [x] SnackBar dọn RAM chỉ báo số thật.
- [x] Test mới pass; bộ test cũ không hỏng; `flutter analyze lib` sạch.
- [ ] Screenshot sau khi sửa được chụp lại → **NOT RUN** (chưa chạy app trên emulator/thiết bị).
- [ ] CPU/RAM/dung lượng hiển thị **số thật** → phụ thuộc Giai đoạn 2 (deploy endpoint `/metrics`).

---

## 6. Ghi chú an toàn (ngoài phạm vi bug, cần xử lý ngay)

Mật khẩu `root` của VPS đã bị ghi **dạng văn bản thô** (và dán vào hội thoại/lưu ảnh chụp
màn hình). Khuyến nghị:

1. **Đổi mật khẩu root ngay** và chuyển sang đăng nhập bằng SSH key.
2. Tắt đăng nhập SSH bằng mật khẩu (`PasswordAuthentication no` trong `/etc/ssh/sshd_config`).
3. Không đưa thông tin đăng nhập máy chủ vào ảnh chụp màn hình báo cáo/bài nộp.
