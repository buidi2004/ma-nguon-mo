#!/usr/bin/env bash
# =============================================================================
# OpenFlix — Cài đặt endpoint số liệu /metrics trên VPS (một lệnh, idempotent)
# -----------------------------------------------------------------------------
# Việc script làm:
#   1. Kiểm tra chạy bằng root (hoặc tự nâng quyền bằng sudo).
#   2. Copy agent + validator + README vào /opt/openflix-vps-metrics/.
#   3. Tạo thư mục web /var/www/openflix-metrics (root:<group-web>).
#   4. Chạy thử agent 1 lần và kiểm chứng JSON đúng schema (validate-metrics-json.sh).
#   5. Cài openflix-metrics.service + .timer vào /etc/systemd/system/,
#      daemon-reload, enable --now timer (chạy mỗi 5 giây).
#   6. Sinh token (hoặc dùng --token), cài snippet nginx vào /etc/nginx/snippets/.
#   7. Chèn `include ...;` vào server block cổng 80 (nếu tìm được) và kiểm tra
#      `nginx -t`; nếu cấu hình hỏng thì TỰ KHÔI PHỤC file gốc và báo lỗi.
#   8. In token + hướng dẫn nạp token vào app bằng --dart-define.
#
# Chạy lại nhiều lần vẫn an toàn (idempotent): không sinh token mới nếu snippet
# đã có token, không chèn include hai lần, không ghi đè backup gốc.
#
# Ví dụ:
#   sudo ./install.sh --dry-run
#   sudo ./install.sh
#   sudo ./install.sh --token "$(openssl rand -hex 32)"
#   sudo ./install.sh --out-file /var/www/openflix-metrics/metrics.json
# =============================================================================
set -euo pipefail

# ---------------------------------------------------------------------------
# Hằng số / giá trị mặc định
# ---------------------------------------------------------------------------
SELF_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

AGENT_DIR="/opt/openflix-vps-metrics"
OUT_FILE="/var/www/openflix-metrics/metrics.json"
PB_DATA_DIR="/opt/openflix-backend/pb_data"
MEDIA_DIR="/var/www/openflix-media"
CPU_SAMPLE_MS="500"
PB_VERSION=""

SYSTEMD_DIR="/etc/systemd/system"
SERVICE_NAME="openflix-metrics.service"
TIMER_NAME="openflix-metrics.timer"

NGINX_ETC="/etc/nginx"
SNIPPET_DIR="${NGINX_ETC}/snippets"
SNIPPET_NAME="nginx-openflix-metrics.conf"
SNIPPET_TARGET="${SNIPPET_DIR}/${SNIPPET_NAME}"
SNIPPET_BACKUP="${SNIPPET_TARGET}.openflix-metrics.bak"
TOKEN_PLACEHOLDER="THAY_BANG_TOKEN_NGAU_NHIEN_CUA_BAN"

TOKEN=""
TOKEN_SOURCE=""
DRY_RUN=0
DO_NGINX=1
DO_NGINX_INCLUDE=1
PB_VER_FLAG=0

WEB_GROUP="root"
HAVE_SYSTEMCTL=0
HAVE_NGINX=0
HAVE_VALIDATOR=0

SNIPPET_CREATED=0
SNIPPET_BACKED_UP=0
SERVER_FILE=""
SERVER_FILE_REAL=""
SERVER_BACKUP=""
INCLUDE_ADDED=0

# ---------------------------------------------------------------------------
# Log
# ---------------------------------------------------------------------------
log()  { printf '[install] %s\n' "$*"; }
step() { printf '\n[install] === %s ===\n' "$*"; }
warn() { printf '[install] CẢNH BÁO: %s\n' "$*" >&2; }
err()  { printf '[install] LỖI: %s\n' "$*" >&2; }
die()  { err "$*"; exit 1; }

run() {
  if [[ "$DRY_RUN" == "1" ]]; then
    printf '[dry-run] %s\n' "$(printf '%q ' "$@")"
    return 0
  fi
  "$@"
}

usage() {
  cat <<'EOF'
Cách dùng: sudo ./install.sh [tuỳ chọn]

  --dry-run                  In các bước sẽ làm, KHÔNG thực thi gì cả.
  --token <t>                Dùng token có sẵn thay vì sinh mới.
                             (chỉ cho phép ký tự A-Z a-z 0-9 . _ -)
  --out-file <path>          Đường dẫn file JSON (mặc định:
                             /var/www/openflix-metrics/metrics.json).
  --data-dir <path>          Thư mục pb_data của PocketBase (mặc định:
                             /opt/openflix-backend/pb_data).
  --media-dir <path>         Thư mục poster/video (mặc định:
                             /var/www/openflix-media).
  --cpu-sample-ms <ms>       Khoảng lấy 2 mẫu /proc/stat (mặc định: 500).
  --pocketbase-version <v>   Ghim phiên bản PocketBase hiển thị (tuỳ chọn).
  --no-nginx                 Bỏ qua toàn bộ bước nginx (snippet/include/reload).
  --no-nginx-include         Cài snippet nhưng KHÔNG tự chèn include vào
                             server block (tự làm thủ công).
  -h, --help                 In hướng dẫn này.

Script idempotent: chạy lại không sinh token mới, không chèn include 2 lần,
không ghi đè backup cấu hình nginx gốc.
EOF
}

# ---------------------------------------------------------------------------
# Phân tích tham số
# ---------------------------------------------------------------------------
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=1; shift ;;
    --token)
      [[ $# -ge 2 ]] || die "--token cần một giá trị."
      TOKEN="$2"
      TOKEN_SOURCE="do người dùng truyền vào (--token)"
      shift 2
      ;;
    --token=*) TOKEN="${1#--token=}"; TOKEN_SOURCE="do người dùng truyền vào (--token)"; shift ;;
    --out-file)
      [[ $# -ge 2 ]] || die "--out-file cần một giá trị."
      OUT_FILE="$2"; shift 2
      ;;
    --out-file=*) OUT_FILE="${1#--out-file=}"; shift ;;
    --data-dir)
      [[ $# -ge 2 ]] || die "--data-dir cần một giá trị."
      PB_DATA_DIR="$2"; shift 2
      ;;
    --data-dir=*) PB_DATA_DIR="${1#--data-dir=}"; shift ;;
    --media-dir)
      [[ $# -ge 2 ]] || die "--media-dir cần một giá trị."
      MEDIA_DIR="$2"; shift 2
      ;;
    --media-dir=*) MEDIA_DIR="${1#--media-dir=}"; shift ;;
    --cpu-sample-ms)
      [[ $# -ge 2 ]] || die "--cpu-sample-ms cần một giá trị."
      CPU_SAMPLE_MS="$2"; shift 2
      ;;
    --cpu-sample-ms=*) CPU_SAMPLE_MS="${1#--cpu-sample-ms=}"; shift ;;
    --pocketbase-version)
      [[ $# -ge 2 ]] || die "--pocketbase-version cần một giá trị."
      PB_VERSION="$2"; PB_VER_FLAG=1; shift 2
      ;;
    --pocketbase-version=*) PB_VERSION="${1#--pocketbase-version=}"; PB_VER_FLAG=1; shift ;;
    --no-nginx) DO_NGINX=0; DO_NGINX_INCLUDE=0; shift ;;
    --no-nginx-include) DO_NGINX_INCLUDE=0; shift ;;
    -h|--help) usage; exit 0 ;;
    *) die "Tham số không nhận ra: $1 (dùng --help để xem hướng dẫn)." ;;
  esac
done

WEB_DIR="$(dirname "$OUT_FILE")"

if [[ -n "$TOKEN" ]] && ! printf '%s' "$TOKEN" | grep -Eq '^[A-Za-z0-9._-]+$'; then
  die "--token chỉ được chứa ký tự A-Z a-z 0-9 . _ - (để không phá file cấu hình nginx)."
fi
if ! printf '%s' "$CPU_SAMPLE_MS" | grep -Eq '^[0-9]+$'; then
  die "--cpu-sample-ms phải là số nguyên (mili giây)."
fi

print_plan() {
  log "Kế hoạch cài đặt (dry-run=${DRY_RUN}, uid=${EUID:-?}, group-web=${WEB_GROUP}):"
  log "  Agent dir   : ${AGENT_DIR}"
  log "  File JSON   : ${OUT_FILE}"
  log "  Thư mục web : ${WEB_DIR}  (root:${WEB_GROUP:-?})"
  log "  pb_data     : ${PB_DATA_DIR}"
  log "  media dir   : ${MEDIA_DIR}"
  log "  CPU sample  : ${CPU_SAMPLE_MS} ms"
  log "  systemd     : ${SYSTEMD_DIR}/${SERVICE_NAME} + ${TIMER_NAME}"
  log "  nginx       : ${SNIPPET_TARGET}  (include=${DO_NGINX_INCLUDE}, bật=${DO_NGINX})"
}

# ---------------------------------------------------------------------------
# Tiện ích
# ---------------------------------------------------------------------------
copy_file() { # copy_file <src> <mode> <dst>
  local src="$1" mode="$2" dst="$3"
  if command -v install >/dev/null 2>&1; then
    run install -m "$mode" "$src" "$dst"
  else
    run cp -f "$src" "$dst"
    run chmod "$mode" "$dst"
  fi
}

find_web_group() {
  local cand
  for cand in www-data nginx; do
    if grep -q "^${cand}:" /etc/group 2>/dev/null; then
      printf '%s' "$cand"
      return 0
    fi
  done
  printf 'root'
}

gen_token() {
  if command -v openssl >/dev/null 2>&1; then
    openssl rand -hex 32
    return 0
  fi
  # Dự phòng: 32 byte ngẫu nhiên từ /dev/urandom (64 ký tự hex)
  od -An -tx1 -N32 /dev/urandom | tr -d ' \n'
}

# Tìm file cấu hình nginx có server block đang listen cổng 80.
server_listens_80() {
  awk '
    /^[[:space:]]*listen[[:space:]]/ {
      line = $0
      sub(/^[[:space:]]*listen[[:space:]]+/, "", line)
      sub(/;.*$/, "", line)
      n = split(line, parts, /[[:space:]]+/)
      for (i = 1; i <= n; i++) {
        p = parts[i]
        sub(/^.*:/, "", p)
        if (p == "80") found = 1
      }
    }
    END { exit(found ? 0 : 1) }
  ' "$1"
}

find_server_file() {
  local f
  for f in "${NGINX_ETC}"/sites-enabled/* "${NGINX_ETC}"/conf.d/*.conf "${NGINX_ETC}"/nginx.conf; do
    [[ -f "$f" ]] || continue
    grep -Eq '^[[:space:]]*server[[:space:]]*\{' "$f" || continue
    if server_listens_80 "$f"; then
      printf '%s' "$f"
      return 0
    fi
  done
  return 1
}

include_already_present() {
  local f
  for f in "${NGINX_ETC}"/sites-enabled/* "${NGINX_ETC}"/conf.d/*.conf "${NGINX_ETC}"/nginx.conf; do
    [[ -f "$f" ]] || continue
    if grep -Eq "^[[:space:]]*include[[:space:]]+snippets/${SNIPPET_NAME}[[:space:]]*;" "$f"; then
      printf '%s' "$f"
      return 0
    fi
  done
  return 1
}

rollback_nginx() {
  warn "Cấu hình nginx mới KHÔNG hợp lệ → khôi phục trạng thái trước khi cài."
  if [[ "$INCLUDE_ADDED" == "1" && -n "$SERVER_BACKUP" && -f "$SERVER_BACKUP" ]]; then
    cp -f "$SERVER_BACKUP" "$SERVER_FILE_REAL"
    rm -f "$SERVER_BACKUP"
    log "Đã khôi phục ${SERVER_FILE_REAL}"
  fi
  if [[ "$SNIPPET_CREATED" == "1" ]]; then
    rm -f "$SNIPPET_TARGET"
    log "Đã xoá snippet mới ${SNIPPET_TARGET}"
  elif [[ "$SNIPPET_BACKED_UP" == "1" && -f "$SNIPPET_BACKUP" ]]; then
    cp -f "$SNIPPET_BACKUP" "$SNIPPET_TARGET"
    rm -f "$SNIPPET_BACKUP"
    log "Đã khôi phục snippet ${SNIPPET_TARGET}"
  fi
  if nginx -t >/dev/null 2>&1; then
    log "nginx -t sau khi khôi phục: OK (cấu hình cũ vẫn chạy được, chưa reload)."
  else
    err "nginx -t vẫn lỗi sau khi khôi phục — kiểm tra tay: nginx -t"
  fi
}

# ---------------------------------------------------------------------------
# 0. Quyền root
# ---------------------------------------------------------------------------
if [[ "$DRY_RUN" == "1" ]]; then
  log "--dry-run: bỏ qua kiểm tra quyền root (không ghi gì lên máy)."
elif [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
  if command -v sudo >/dev/null 2>&1; then
    log "Chưa phải root — chạy lại bằng sudo…"
    exec sudo -E bash "$SELF_PATH" "$@"
  fi
  die "Script cần chạy bằng root (hoặc cài sudo rồi chạy lại)."
fi

step "1/8 Kiểm tra tiên quyết"
for f in openflix-metrics.sh "${SERVICE_NAME}" "${TIMER_NAME}" "${SNIPPET_NAME}" README.md; do
  [[ -f "${SRC_DIR}/${f}" ]] || die "Thiếu file nguồn: ${SRC_DIR}/${f}"
done
if [[ -f "${SRC_DIR}/validate-metrics-json.sh" ]]; then
  HAVE_VALIDATOR=1
else
  warn "Không thấy validate-metrics-json.sh → bỏ qua bước kiểm chứng schema chặt chẽ."
fi
if command -v systemctl >/dev/null 2>&1; then HAVE_SYSTEMCTL=1; else
  warn "Không có systemctl (không phải systemd) — bỏ qua bước cài service/timer."
fi
if command -v nginx >/dev/null 2>&1; then HAVE_NGINX=1; else
  warn "Không có nginx trong PATH — bỏ qua bước nginx, xem hướng dẫn thủ công ở README."
fi
if command -v openssl >/dev/null 2>&1; then
  log "openssl: có (dùng để sinh token ngẫu nhiên)."
else
  warn "Không có openssl — sẽ sinh token bằng /dev/urandom."
fi
WEB_GROUP="$(find_web_group)"
[[ -d "$WEB_DIR" ]] || log "Thư mục web ${WEB_DIR} chưa có — sẽ tạo."
[[ -d "$PB_DATA_DIR" ]] || warn "Thư mục pb_data ${PB_DATA_DIR} không tồn tại — disk_db_gb sẽ là null."
[[ -d "$MEDIA_DIR" ]] || warn "Thư mục media ${MEDIA_DIR} không tồn tại — disk_media_gb sẽ là null."
print_plan

# ---------------------------------------------------------------------------
# 2. Copy agent vào /opt/openflix-vps-metrics
# ---------------------------------------------------------------------------
step "2/8 Copy agent vào ${AGENT_DIR}"
run mkdir -p "$AGENT_DIR"
copy_file "${SRC_DIR}/openflix-metrics.sh" 755 "${AGENT_DIR}/openflix-metrics.sh"
copy_file "${SRC_DIR}/README.md" 644 "${AGENT_DIR}/README.md"
if [[ "$HAVE_VALIDATOR" == "1" ]]; then
  copy_file "${SRC_DIR}/validate-metrics-json.sh" 755 "${AGENT_DIR}/validate-metrics-json.sh"
  if [[ -d "${SRC_DIR}/fixtures" ]]; then
    run mkdir -p "${AGENT_DIR}/fixtures"
    run cp -rf "${SRC_DIR}/fixtures"/* "${AGENT_DIR}/fixtures/" 2>/dev/null || true
    run chmod 644 "${AGENT_DIR}/fixtures"/* 2>/dev/null || true
  fi
fi

# ---------------------------------------------------------------------------
# 3. Thư mục web chứa JSON
# ---------------------------------------------------------------------------
step "3/8 Tạo thư mục web ${WEB_DIR} (root:${WEB_GROUP}, 755)"
run mkdir -p "$WEB_DIR"
run chown "root:${WEB_GROUP}" "$WEB_DIR"
run chmod 755 "$WEB_DIR"

# ---------------------------------------------------------------------------
# 4. Chạy thử agent + kiểm chứng schema
# ---------------------------------------------------------------------------
step "4/8 Chạy thử agent và kiểm chứng JSON"
if [[ "$DRY_RUN" == "1" ]]; then
  printf '[dry-run] OUT_FILE=%q PB_DATA_DIR=%q MEDIA_DIR=%q CPU_SAMPLE_MS=%q %q\n' \
    "$OUT_FILE" "$PB_DATA_DIR" "$MEDIA_DIR" "$CPU_SAMPLE_MS" "${AGENT_DIR}/openflix-metrics.sh"
  if [[ "$HAVE_VALIDATOR" == "1" ]]; then
    printf '[dry-run] %q %q %q\n' "bash" "${AGENT_DIR}/validate-metrics-json.sh" "$OUT_FILE"
  else
    printf '[dry-run] (không có validator) kiểm tra file JSON không rỗng\n'
  fi
else
  OUT_FILE="$OUT_FILE" PB_DATA_DIR="$PB_DATA_DIR" MEDIA_DIR="$MEDIA_DIR" \
    CPU_SAMPLE_MS="$CPU_SAMPLE_MS" POCKETBASE_VERSION="$PB_VERSION" \
    bash "${AGENT_DIR}/openflix-metrics.sh"
  [[ -s "$OUT_FILE" ]] || die "Agent không ghi được ${OUT_FILE} (kiểm tra quyền/đường dẫn)."
  chmod 640 "$OUT_FILE" || true
  chown "root:${WEB_GROUP}" "$OUT_FILE" || true
  if [[ "$HAVE_VALIDATOR" == "1" ]]; then
    if bash "${AGENT_DIR}/validate-metrics-json.sh" "$OUT_FILE"; then
      log "JSON do agent xuất ra ĐÚNG schema."
    else
      die "JSON do agent xuất ra SAI schema — dừng trước khi đụng vào systemd/nginx."
    fi
  elif ! grep -q '"generated_at"' "$OUT_FILE"; then
    die "File JSON không chứa \"generated_at\" — agent có vấn đề."
  fi
fi

# ---------------------------------------------------------------------------
# 5. systemd
# ---------------------------------------------------------------------------
step "5/8 Cài systemd service + timer (mỗi 5 giây)"
if [[ "$HAVE_SYSTEMCTL" == "0" ]]; then
  warn "Bỏ qua systemd (không có systemctl)."
else
  copy_file "${SRC_DIR}/${SERVICE_NAME}" 644 "${SYSTEMD_DIR}/${SERVICE_NAME}"
  copy_file "${SRC_DIR}/${TIMER_NAME}" 644 "${SYSTEMD_DIR}/${TIMER_NAME}"
  if [[ "$DRY_RUN" == "0" ]]; then
    sed -i -E \
      -e "s|^Environment=OUT_FILE=.*|Environment=OUT_FILE=${OUT_FILE}|" \
      -e "s|^Environment=PB_DATA_DIR=.*|Environment=PB_DATA_DIR=${PB_DATA_DIR}|" \
      -e "s|^Environment=MEDIA_DIR=.*|Environment=MEDIA_DIR=${MEDIA_DIR}|" \
      -e "s|^Environment=CPU_SAMPLE_MS=.*|Environment=CPU_SAMPLE_MS=${CPU_SAMPLE_MS}|" \
      "${SYSTEMD_DIR}/${SERVICE_NAME}"
    if [[ "$PB_VER_FLAG" == "1" ]]; then
      if grep -q '^# Environment=POCKETBASE_VERSION=' "${SYSTEMD_DIR}/${SERVICE_NAME}"; then
        sed -i -E "s|^# Environment=POCKETBASE_VERSION=.*|Environment=POCKETBASE_VERSION=${PB_VERSION}|" \
          "${SYSTEMD_DIR}/${SERVICE_NAME}"
      else
        warn "Không tìm thấy dòng POCKETBASE_VERSION để bỏ ghi chú — thêm tay nếu cần."
      fi
    fi
  else
    printf '[dry-run] sed -i -E ... %q   (ghi OUT_FILE/PB_DATA_DIR/MEDIA_DIR/CPU_SAMPLE_MS)\n' "${SYSTEMD_DIR}/${SERVICE_NAME}"
  fi
  run systemctl daemon-reload
  run systemctl enable --now "$TIMER_NAME"
  run systemctl restart "$TIMER_NAME"
  if [[ "$DRY_RUN" == "0" ]]; then
    systemctl list-timers --no-pager "$TIMER_NAME" || true
    if systemctl is-failed --quiet "$SERVICE_NAME"; then
      warn "openflix-metrics.service đang ở trạng thái failed — xem: journalctl -u ${SERVICE_NAME} -n 50"
    else
      log "openflix-metrics.service: chạy xong không lỗi (oneshot)."
    fi
  fi
fi

# ---------------------------------------------------------------------------
# 6. Token
# ---------------------------------------------------------------------------
step "6/8 Token bảo vệ endpoint"
if [[ -n "$TOKEN" ]]; then
  log "Dùng token ${TOKEN_SOURCE}."
elif [[ -f "$SNIPPET_TARGET" ]]; then
  existing="$(sed -n 's/.*http_x_metrics_token != "\([^"]*\)".*/\1/p' "$SNIPPET_TARGET" 2>/dev/null | head -1)" || existing=""
  if [[ -n "$existing" && "$existing" != "$TOKEN_PLACEHOLDER" ]]; then
    TOKEN="$existing"
    TOKEN_SOURCE="giữ token đã cài trong ${SNIPPET_TARGET} (idempotent)"
    log "Giữ token hiện có trong snippet (không sinh token mới)."
  fi
fi
if [[ -z "$TOKEN" ]]; then
  TOKEN="$(gen_token)"
  TOKEN_SOURCE="mới sinh ngẫu nhiên 32 byte"
  [[ -n "$TOKEN" ]] || die "Không sinh được token (thiếu openssl và /dev/urandom?)."
  log "Đã sinh token ngẫu nhiên 64 ký tự hex."
fi

# ---------------------------------------------------------------------------
# 7. nginx
# ---------------------------------------------------------------------------
step "7/8 Cài snippet nginx + kiểm tra cấu hình"
if [[ "$DO_NGINX" == "0" || "$HAVE_NGINX" == "0" ]]; then
  warn "Bỏ qua nginx. Tự làm theo README: copy ${SNIPPET_NAME} vào ${SNIPPET_DIR}/, thay token, include vào server cổng 80."
else
  run mkdir -p "$SNIPPET_DIR"
  if [[ -f "$SNIPPET_TARGET" ]]; then
    SNIPPET_BACKED_UP=1
    run cp -f "$SNIPPET_TARGET" "$SNIPPET_BACKUP"
  else
    SNIPPET_CREATED=1
  fi
  copy_file "${SRC_DIR}/${SNIPPET_NAME}" 644 "${SNIPPET_TARGET}"

  if [[ "$DRY_RUN" == "0" ]]; then
    # Thay token (placeholder hoặc token cũ) bằng token đang dùng.
    if grep -q 'http_x_metrics_token' "$SNIPPET_TARGET"; then
      sed -i -E "s|(http_x_metrics_token != \")[^\"]*(\")|\1${TOKEN}\2|" "$SNIPPET_TARGET"
    else
      die "Snippet không có dòng kiểm tra token — không chèn được token."
    fi
    # Trỏ alias về đúng file JSON.
    sed -i -E "s|^([[:space:]]*)alias[[:space:]].*metrics\.json;|\1alias ${OUT_FILE};|" "$SNIPPET_TARGET"
    grep -q "alias ${OUT_FILE};" "$SNIPPET_TARGET" || die "Không sửa được dòng alias trong snippet."
    grep -q "$TOKEN" "$SNIPPET_TARGET" || die "Không chèn được token vào snippet."
  else
    printf '[dry-run] sed -i -E (thay token + alias %q) %q\n' "$OUT_FILE" "$SNIPPET_TARGET"
  fi

  if [[ "$DO_NGINX_INCLUDE" == "0" ]]; then
    warn "--no-nginx-include: bạn phải tự thêm 'include snippets/${SNIPPET_NAME};' vào server block cổng 80."
  elif INCLUDED_IN="$(include_already_present)"; then
    log "Đã có 'include snippets/${SNIPPET_NAME};' trong ${INCLUDED_IN} — không chèn lại."
  elif ! SERVER_FILE="$(find_server_file)"; then
    warn "Không tìm thấy server block listen cổng 80 trong ${NGINX_ETC}."
    warn "Tự thêm dòng này vào server block cổng 80: include snippets/${SNIPPET_NAME};"
  else
    SERVER_FILE_REAL="$(readlink -f "$SERVER_FILE" 2>/dev/null || printf '%s' "$SERVER_FILE")"
    SERVER_BACKUP="${SERVER_FILE_REAL}.openflix-metrics.bak"
    log "Chèn include vào ${SERVER_FILE_REAL}"
    run cp -f "$SERVER_FILE_REAL" "$SERVER_BACKUP"
    if [[ "$DRY_RUN" == "0" ]]; then
      awk -v inc="    include snippets/${SNIPPET_NAME};" '
        inserted == 0 && /^[[:space:]]*server[[:space:]]*\{/ {
          print
          print inc
          inserted = 1
          next
        }
        { print }
      ' "$SERVER_FILE_REAL" > "${SERVER_FILE_REAL}.openflix-metrics.new"
      mv -f "${SERVER_FILE_REAL}.openflix-metrics.new" "$SERVER_FILE_REAL"
      INCLUDE_ADDED=1
    else
      printf '[dry-run] chèn "    include snippets/%s;" ngay sau dòng "server {" đầu tiên của %q\n' "$SNIPPET_NAME" "$SERVER_FILE_REAL"
    fi
  fi

  if [[ "$DRY_RUN" == "1" ]]; then
    printf '[dry-run] nginx -t\n'
    printf '[dry-run] systemctl reload nginx\n'
  elif nginx -t; then
    log "nginx -t: OK"
    run systemctl reload nginx
    log "Đã reload nginx."
  else
    rollback_nginx
    die "Cài nginx thất bại — đã khôi phục cấu hình cũ. Chạy lại với --no-nginx-include nếu muốn tự chèn include."
  fi
fi

# ---------------------------------------------------------------------------
# 8. Tổng kết
# ---------------------------------------------------------------------------
step "8/8 Hoàn tất"
if [[ "$DRY_RUN" == "1" ]]; then
  log "Đây là --dry-run: KHÔNG có thay đổi nào được ghi lên máy."
fi

cat <<EOF

================================================================================
CÀI ĐẶT HOÀN TẤT — OpenFlix /metrics
--------------------------------------------------------------------------------
  Agent        : ${AGENT_DIR}/openflix-metrics.sh
  File JSON    : ${OUT_FILE}   (root:${WEB_GROUP} 640)
  systemd      : ${SERVICE_NAME} + ${TIMER_NAME} (chạy mỗi 5 giây)
  nginx        : ${SNIPPET_TARGET}
  Token nguồn  : ${TOKEN_SOURCE}

TOKEN (nạp vào app — KHÔNG commit token vào git):
  ${TOKEN}

Kiểm tra nhanh trên VPS:
  curl -i  http://127.0.0.1/metrics                              # kỳ vọng 403
  curl -s  -H "X-Metrics-Token: ${TOKEN}" http://127.0.0.1/metrics | head -c 400
  systemctl list-timers openflix-metrics.timer
  bash ${AGENT_DIR}/validate-metrics-json.sh ${OUT_FILE}

Nạp token vào app:
  flutter build apk --dart-define=OPENFLIX_METRICS_TOKEN=${TOKEN}
  flutter build windows --dart-define=OPENFLIX_METRICS_TOKEN=${TOKEN}

BẢO MẬT (bắt buộc đọc):
  1. Endpoint này lộ %CPU, RAM và dung lượng ổ cứng → KHÔNG được mở công khai.
     Luôn giữ token HOẶC allowlist IP (xem mục "Bảo mật" trong README).
  2. Mật khẩu root đã từng bị lộ trong tài liệu/ảnh chụp: PHẢI đổi ngay và
     chuyển sang đăng nhập bằng SSH key:
       passwd root
       ssh-copy-id -i ~/.ssh/id_ed25519.pub root@<ip-vps>
       # /etc/ssh/sshd_config: PasswordAuthentication no; PermitRootLogin prohibit-password
       systemctl restart ssh
  3. Nếu app luôn chạy từ một mạng cố định, giới hạn thêm theo IP:
       allow <ip-mạng-đó>; deny all;   (đặt trong location = /metrics)
================================================================================
EOF
