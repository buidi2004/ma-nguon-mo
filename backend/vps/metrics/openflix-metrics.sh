#!/usr/bin/env bash
# =============================================================================
# OpenFlix — Agent thu thập số liệu hệ thống VPS (số liệu THẬT, không ước lượng)
# -----------------------------------------------------------------------------
# Đọc trực tiếp từ nhân Linux và ghi ra một file JSON để nginx phục vụ tại
# `GET /metrics`. Ứng dụng OpenFlix (màn hình Giám sát Máy chủ) đọc file này.
#
# KHÔNG hardcode bất kỳ con số nào: nếu không đọc được chỉ số nào thì xuất null.
#
# Cách dùng:  OUT_FILE=/var/www/openflix-metrics/metrics.json ./openflix-metrics.sh
# =============================================================================
set -uo pipefail

OUT_FILE="${OUT_FILE:-/var/www/openflix-metrics/metrics.json}"
PB_DATA_DIR="${PB_DATA_DIR:-/opt/openflix-backend/pb_data}"
MEDIA_DIR="${MEDIA_DIR:-/var/www/openflix-media}"
CPU_SAMPLE_MS="${CPU_SAMPLE_MS:-500}"
POCKETBASE_VERSION="${POCKETBASE_VERSION:-}"

GB=1073741824

# ---------------------------------------------------------------------------
# Tiện ích
# ---------------------------------------------------------------------------
num_or_null() { # num_or_null <giá trị> — in ra số hoặc "null"
  local v="${1:-}"
  if [[ -z "$v" || "$v" == "null" ]]; then echo "null"; else echo "$v"; fi
}

gb_of_bytes() { # gb_of_bytes <bytes> -> GB với 2 chữ số thập phân
  local b="${1:-}"
  if [[ -z "$b" || "$b" == "null" ]]; then echo "null"; else
    awk -v b="$b" 'BEGIN{printf "%.2f", b/1073741824}'
  fi
}

read_cpu_counters() { # -> "<idle_jiffies> <total_jiffies>"
  awk '/^cpu /{
        idle = $5 + $6;                 # idle + iowait
        total = 0;
        for (i = 2; i <= NF; i++) total += $i;
        print idle, total;
      }' /proc/stat 2>/dev/null
}

port_listening() { # port_listening <port> -> true/false
  local port="$1"
  if timeout 1 bash -c "</dev/tcp/127.0.0.1/${port}" 2>/dev/null; then
    echo "true"
  else
    echo "false"
  fi
}

# ---------------------------------------------------------------------------
# 1. CPU — lấy 2 mẫu /proc/stat cách nhau CPU_SAMPLE_MS để tính % tải thật
# ---------------------------------------------------------------------------
cpu_percent="null"
read -r idle1 total1 <<<"$(read_cpu_counters)"
if [[ -n "${total1:-}" ]]; then
  sleep "$(awk -v ms="$CPU_SAMPLE_MS" 'BEGIN{printf "%.3f", ms/1000}')"
  read -r idle2 total2 <<<"$(read_cpu_counters)"
  cpu_percent="$(awk -v i1="$idle1" -v t1="$total1" -v i2="$idle2" -v t2="$total2" \
    'BEGIN{ dt = t2 - t1; di = i2 - i1;
            if (dt <= 0) { print "null" } else { printf "%.1f", (1 - di/dt) * 100 } }')"
fi

# ---------------------------------------------------------------------------
# 2. Load average & số nhân CPU
# ---------------------------------------------------------------------------
read -r load1 load5 load15 _ < /proc/loadavg 2>/dev/null || { load1=null; load5=null; load15=null; }
cores="$(nproc 2>/dev/null || echo null)"

# ---------------------------------------------------------------------------
# 3. RAM & Swap từ /proc/meminfo
# ---------------------------------------------------------------------------
mem_total_mb="null"; mem_used_mb="null"; mem_avail_mb="null"
swap_total_mb="null"; swap_used_mb="null"
if [[ -r /proc/meminfo ]]; then
  mem_total_mb="$(awk '/^MemTotal:/{printf "%.0f", $2/1024}' /proc/meminfo)"
  mem_avail_mb="$(awk '/^MemAvailable:/{printf "%.0f", $2/1024}' /proc/meminfo)"
  if [[ -n "$mem_total_mb" && -n "$mem_avail_mb" ]]; then
    mem_used_mb="$((mem_total_mb - mem_avail_mb))"
  fi
  swap_total_mb="$(awk '/^SwapTotal:/{printf "%.0f", $2/1024}' /proc/meminfo)"
  swap_free_mb="$(awk '/^SwapFree:/{printf "%.0f", $2/1024}' /proc/meminfo)"
  if [[ -n "$swap_total_mb" && -n "$swap_free_mb" ]]; then
    swap_used_mb="$((swap_total_mb - swap_free_mb))"
  fi
fi

# ---------------------------------------------------------------------------
# 4. Ổ cứng — tổng/đã dùng/còn trống của phân vùng gốc (mặc định "/")
# ---------------------------------------------------------------------------
disk_total_gb="null"; disk_used_gb="null"; disk_avail_gb="null"
read -r d_total d_used d_avail <<<"$(df -B1 / 2>/dev/null | awk 'NR==2{print $2, $3, $4}')"
if [[ -n "${d_total:-}" ]]; then
  disk_total_gb="$(gb_of_bytes "$d_total")"
  disk_used_gb="$(gb_of_bytes "$d_used")"
  disk_avail_gb="$(gb_of_bytes "$d_avail")"
fi

# ---------------------------------------------------------------------------
# 5. Phân bổ dung lượng: PocketBase / Media / phần còn lại (OS + Docker)
# ---------------------------------------------------------------------------
disk_db_gb="null"; disk_media_gb="null"; disk_os_gb="null"
db_bytes="$(du -sb "$PB_DATA_DIR" 2>/dev/null | awk '{print $1}')"
media_bytes="$(du -sb "$MEDIA_DIR" 2>/dev/null | awk '{print $1}')"
[[ -n "${db_bytes:-}" ]] && disk_db_gb="$(gb_of_bytes "$db_bytes")"
[[ -n "${media_bytes:-}" ]] && disk_media_gb="$(gb_of_bytes "$media_bytes")"
if [[ -n "${d_used:-}" && "$disk_db_gb" != "null" && "$disk_media_gb" != "null" ]]; then
  disk_os_gb="$(awk -v used="$d_used" -v db="$db_bytes" -v media="$media_bytes" \
    'BEGIN{ os = (used - db - media)/1073741824; if (os < 0) os = 0; printf "%.2f", os }')"
fi

# ---------------------------------------------------------------------------
# 6. Uptime, kernel, tên hệ điều hành
# ---------------------------------------------------------------------------
uptime_s="null"
[[ -r /proc/uptime ]] && uptime_s="$(awk '{printf "%.0f", $1}' /proc/uptime)"
kernel="$(uname -r 2>/dev/null || echo null)"
arch="$(uname -m 2>/dev/null || echo null)"
[[ -z "${arch:-}" ]] && arch="null"
os_pretty="$(awk -F= '/^PRETTY_NAME=/{gsub(/"/, "", $2); print $2}' /etc/os-release 2>/dev/null)"
[[ -z "${os_pretty:-}" ]] && os_pretty="null"

# Đường dẫn dữ liệu PocketBase thật sự tồn tại trên máy (không có → null).
data_dir="null"
if [[ -n "${PB_DATA_DIR:-}" && -d "$PB_DATA_DIR" ]]; then
  data_dir="$PB_DATA_DIR"
fi

# ---------------------------------------------------------------------------
# 7. Phiên bản Docker & PocketBase (best-effort, không bịa nếu không đọc được)
# ---------------------------------------------------------------------------
docker_version="null"
if command -v docker >/dev/null 2>&1; then
  docker_version="$(docker --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)"
  [[ -z "${docker_version:-}" ]] && docker_version="null"
fi

pb_version="null"
if [[ -n "$POCKETBASE_VERSION" ]]; then
  pb_version="$POCKETBASE_VERSION"
elif command -v pocketbase >/dev/null 2>&1; then
  pb_version="$(pocketbase --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)"
  [[ -z "${pb_version:-}" ]] && pb_version="null"
fi

# ---------------------------------------------------------------------------
# 8. Trạng thái dịch vụ (kiểm tra cổng đang lắng nghe thật)
# ---------------------------------------------------------------------------
svc_pocketbase="$(port_listening 8090)"
svc_nginx="$(port_listening 80)"
if [[ -S /var/run/docker.sock ]] && command -v docker >/dev/null 2>&1; then
  svc_docker="true"
else
  svc_docker="false"
fi

generated_at="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

# ---------------------------------------------------------------------------
# 9. Ghi JSON (ghi ra file tạm rồi mv để không ai đọc phải file dở dang)
# ---------------------------------------------------------------------------
out_dir="$(dirname "$OUT_FILE")"
mkdir -p "$out_dir" 2>/dev/null || true
tmp_file="${OUT_FILE}.$$.tmp"

cat > "$tmp_file" <<JSON
{"generated_at":"${generated_at}",
"cpu_percent":$(num_or_null "$cpu_percent"),
"load1":$(num_or_null "$load1"),
"load5":$(num_or_null "$load5"),
"load15":$(num_or_null "$load15"),
"cores":$(num_or_null "$cores"),
"mem_total_mb":$(num_or_null "$mem_total_mb"),
"mem_used_mb":$(num_or_null "$mem_used_mb"),
"mem_available_mb":$(num_or_null "$mem_avail_mb"),
"swap_total_mb":$(num_or_null "$swap_total_mb"),
"swap_used_mb":$(num_or_null "$swap_used_mb"),
"disk_total_gb":$(num_or_null "$disk_total_gb"),
"disk_used_gb":$(num_or_null "$disk_used_gb"),
"disk_avail_gb":$(num_or_null "$disk_avail_gb"),
"disk_os_gb":$(num_or_null "$disk_os_gb"),
"disk_db_gb":$(num_or_null "$disk_db_gb"),
"disk_media_gb":$(num_or_null "$disk_media_gb"),
"uptime_s":$(num_or_null "$uptime_s"),
"kernel":$( [[ "$kernel" == "null" ]] && echo null || printf '"%s"' "$kernel" ),
"arch":$( [[ "$arch" == "null" ]] && echo null || printf '"%s"' "$arch" ),
"os_pretty":$( [[ "$os_pretty" == "null" ]] && echo null || printf '"%s"' "$os_pretty" ),
"data_dir":$( [[ "$data_dir" == "null" ]] && echo null || printf '"%s"' "$data_dir" ),
"docker_version":$( [[ "$docker_version" == "null" ]] && echo null || printf '"%s"' "$docker_version" ),
"pocketbase_version":$( [[ "$pb_version" == "null" ]] && echo null || printf '"%s"' "$pb_version" ),
"services":{"pocketbase":${svc_pocketbase},"nginx":${svc_nginx},"docker":${svc_docker}}}
JSON

chmod 640 "$tmp_file" 2>/dev/null || true
chgrp www-data "$tmp_file" 2>/dev/null || true
mv -f "$tmp_file" "$OUT_FILE"
