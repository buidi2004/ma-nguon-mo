#!/usr/bin/env bash
# =============================================================================
# OpenFlix — Kiểm chứng schema JSON của endpoint /metrics
# -----------------------------------------------------------------------------
# Kiểm tra một file JSON (tham số đường dẫn hoặc stdin) có ĐÚNG "hợp đồng"
# schema mà app Flutter đọc hay không:
#   lib/features/admin/services/server_metrics.dart
#
# Hợp đồng (KHÔNG được đổi tên khoá hay kiểu dữ liệu):
#   generated_at : string ISO-8601 parse được (UTC, ví dụ 2026-10-19T02:00:00Z)
#   chỉ số       : số hoặc null
#                  (cpu_percent, load1, load5, load15, cores, mem_total_mb,
#                   mem_used_mb, mem_available_mb, swap_total_mb, swap_used_mb,
#                   disk_total_gb, disk_used_gb, disk_avail_gb, disk_os_gb,
#                   disk_db_gb, disk_media_gb, uptime_s)
#   văn bản      : string hoặc null
#                  (kernel, arch, os_pretty, data_dir, docker_version,
#                   pocketbase_version)
#   services     : object với 3 cờ bool bắt buộc (pocketbase, nginx, docker)
#
# Exit code: 0 = hợp lệ · 1 = sai schema · 2 = lỗi dùng lệnh/đọc file.
#
# KHÔNG phụ thuộc `jq`. Engine ưu tiên là python3 (chặt chẽ nhất — parse JSON
# thật); nếu máy không có python thì tự động chuyển sang engine awk (bộ đọc JSON
# tối giản viết tay, không cần jq/python). Chọn engine bằng:
#   ./validate-metrics-json.sh --engine python|awk|auto  file.json
# hoặc biến môi trường VALIDATOR_ENGINE=awk
# =============================================================================
set -uo pipefail

PROG="$(basename "$0")"
ENGINE="${VALIDATOR_ENGINE:-auto}"
INPUT=""
TMP_JSON=""
TMP_AWK=""
PY_BIN=()

usage() {
  cat <<'EOF'
Cách dùng:
  validate-metrics-json.sh [--engine auto|python|awk] [file.json]
  cat metrics.json | validate-metrics-json.sh

  - Không truyền file  → đọc JSON từ stdin.
  - --engine auto      → dùng python3 nếu có, không thì awk (mặc định).
  - --engine python    → bắt buộc dùng python (lỗi nếu không có).
  - --engine awk       → bắt buộc dùng engine awk (không cần python/jq).
  -h, --help           → in hướng dẫn này.

Exit: 0 hợp lệ · 1 sai schema · 2 lỗi dùng lệnh.
EOF
}

cleanup() {
  [[ -n "$TMP_JSON" && -f "$TMP_JSON" ]] && rm -f "$TMP_JSON"
  [[ -n "$TMP_AWK" && -f "$TMP_AWK" ]] && rm -f "$TMP_AWK"
  return 0
}
trap cleanup EXIT

# ---------------------------------------------------------------------------
# 1. Phân tích tham số
# ---------------------------------------------------------------------------
while [[ $# -gt 0 ]]; do
  case "$1" in
    --engine)
      [[ $# -ge 2 ]] || { echo "LỖI: --engine cần một giá trị." >&2; exit 2; }
      ENGINE="$2"
      shift 2
      ;;
    --engine=*)
      ENGINE="${1#--engine=}"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    -*)
      echo "LỖI: tham số không nhận ra: $1" >&2
      usage >&2
      exit 2
      ;;
    *)
      if [[ -n "$INPUT" ]]; then
        echo "LỖI: chỉ nhận một file đầu vào." >&2
        exit 2
      fi
      INPUT="$1"
      shift
      ;;
  esac
done

case "$ENGINE" in
  auto|python|awk) ;;
  *)
    echo "LỖI: --engine phải là auto|python|awk (nhận: $ENGINE)" >&2
    exit 2
    ;;
esac

# ---------------------------------------------------------------------------
# 2. Chuẩn hoá đầu vào thành một file tạm (để engine nào cũng đọc được file)
# ---------------------------------------------------------------------------
if [[ -n "$INPUT" ]]; then
  if [[ ! -f "$INPUT" ]]; then
    echo "LỖI: không tìm thấy file: $INPUT" >&2
    exit 2
  fi
  if [[ ! -r "$INPUT" ]]; then
    echo "LỖI: không đọc được file: $INPUT" >&2
    exit 2
  fi
  TMP_JSON="$(mktemp)" || exit 2
  cat -- "$INPUT" > "$TMP_JSON" || { echo "LỖI: không đọc được nội dung $INPUT" >&2; exit 2; }
  SOURCE="$INPUT"
else
  TMP_JSON="$(mktemp)" || exit 2
  cat > "$TMP_JSON" || { echo "LỖI: không đọc được stdin" >&2; exit 2; }
  SOURCE="<stdin>"
fi

if [[ ! -s "$TMP_JSON" ]]; then
  echo "LỖI: đầu vào rỗng ($SOURCE) — không có gì để kiểm chứng." >&2
  echo "→ THẤT BẠI: schema /metrics KHÔNG hợp lệ." >&2
  exit 1
fi

# ---------------------------------------------------------------------------
# 3. Tìm python (nếu cần)
# ---------------------------------------------------------------------------
find_python() {
  local cand
  for cand in python3 python python3.12 python3.11 python3.10; do
    if command -v "$cand" >/dev/null 2>&1 &&
       "$cand" -c 'import json,sys; sys.exit(0)' >/dev/null 2>&1; then
      PY_BIN=("$cand")
      return 0
    fi
  done
  if command -v py >/dev/null 2>&1 && py -3 -c 'import json,sys; sys.exit(0)' >/dev/null 2>&1; then
    PY_BIN=(py -3)
    return 0
  fi
  return 1
}

USE_ENGINE="$ENGINE"
if [[ "$ENGINE" == "auto" ]]; then
  if find_python; then USE_ENGINE="python"; else USE_ENGINE="awk"; fi
elif [[ "$ENGINE" == "python" ]]; then
  if ! find_python; then
    echo "LỖI: --engine python nhưng không tìm thấy python3/python trên máy." >&2
    exit 2
  fi
fi

# ---------------------------------------------------------------------------
# 4. Engine python — parse JSON thật, kiểm kiểu chính xác
# ---------------------------------------------------------------------------
run_python_engine() {
  local rc=0
  "${PY_BIN[@]}" - "$TMP_JSON" "$SOURCE" <<'PY' || rc=$?
import datetime
import json
import math
import re
import sys

NUM_KEYS = (
    "cpu_percent", "load1", "load5", "load15", "cores",
    "mem_total_mb", "mem_used_mb", "mem_available_mb",
    "swap_total_mb", "swap_used_mb",
    "disk_total_gb", "disk_used_gb", "disk_avail_gb",
    "disk_os_gb", "disk_db_gb", "disk_media_gb",
    "uptime_s",
)
STR_KEYS = (
    "kernel", "arch", "os_pretty", "data_dir",
    "docker_version", "pocketbase_version",
)
SVC_KEYS = ("pocketbase", "nginx", "docker")
NON_NEGATIVE = (
    "mem_total_mb", "mem_used_mb", "mem_available_mb",
    "swap_total_mb", "swap_used_mb",
    "disk_total_gb", "disk_used_gb", "disk_avail_gb",
    "disk_os_gb", "disk_db_gb", "disk_media_gb",
    "uptime_s", "cores", "load1", "load5", "load15",
)
ISO_RE = re.compile(
    r"^[0-9]{4}-[0-9]{2}-[0-9]{2}[T ][0-9]{2}:[0-9]{2}:[0-9]{2}"
    r"(\.[0-9]+)?(Z|z|[+-][0-9]{2}:?[0-9]{2})?$"
)

path = sys.argv[1]
source = sys.argv[2]
errors = []
warnings = []


def err(msg):
    errors.append(msg)


def warn(msg):
    warnings.append(msg)


def type_name(value):
    if value is None:
        return "null"
    if isinstance(value, bool):
        return "bool"
    if isinstance(value, int):
        return "int"
    if isinstance(value, float):
        return "float"
    if isinstance(value, str):
        return "string"
    if isinstance(value, list):
        return "array"
    if isinstance(value, dict):
        return "object"
    return type(value).__name__


try:
    with open(path, "rb") as handle:
        raw = handle.read()
except OSError as exc:  # pragma: no cover - phòng khi file bị xoá giữa chừng
    sys.stderr.write("LỖI: không đọc được %s (%s)\n" % (path, exc))
    sys.exit(2)

try:
    data = json.loads(raw.decode("utf-8"))
except UnicodeDecodeError as exc:
    sys.stderr.write("LỖI: nội dung không phải UTF-8 hợp lệ (%s)\n" % exc)
    sys.stderr.write("→ THẤT BẠI: schema /metrics KHÔNG hợp lệ (engine: python)\n")
    sys.exit(1)
except ValueError as exc:
    sys.stderr.write("LỖI: nội dung không phải JSON hợp lệ: %s\n" % exc)
    sys.stderr.write("→ THẤT BẠI: schema /metrics KHÔNG hợp lệ (engine: python)\n")
    sys.exit(1)

if not isinstance(data, dict):
    err('gốc JSON phải là object, nhận được "%s"' % type_name(data))

if isinstance(data, dict):
    # --- các khoá chỉ số: số hoặc null -------------------------------------
    for key in NUM_KEYS:
        if key not in data:
            err('thiếu khoá bắt buộc "%s"' % key)
            continue
        value = data[key]
        if value is None:
            continue
        if isinstance(value, bool):
            err('khoá "%s" phải là số hoặc null, nhận được bool (%r)' % (key, value))
            continue
        if not isinstance(value, (int, float)):
            err('khoá "%s" phải là số hoặc null, nhận được %s (%r)'
                % (key, type_name(value), value))
            continue
        if not math.isfinite(value):
            err('khoá "%s" phải là số hữu hạn, nhận được %r' % (key, value))
            continue
        unit = ""
        if key == "cpu_percent":
            unit = "%"
            if value < 0 or value > 100:
                warn('khoá "cpu_percent" = %s%% nằm ngoài khoảng 0-100' % value)
        if key in NON_NEGATIVE and value < 0:
            err('khoá "%s" không được âm (nhận được %s%s)' % (key, value, unit))
        if key in ("cores", "uptime_s") and float(value) != int(value):
            warn('khoá "%s" nên là số nguyên (nhận được %s)' % (key, value))

    # --- các khoá văn bản: string hoặc null --------------------------------
    for key in STR_KEYS:
        if key not in data:
            err('thiếu khoá bắt buộc "%s"' % key)
            continue
        value = data[key]
        if value is None:
            continue
        if not isinstance(value, str):
            err('khoá "%s" phải là string hoặc null, nhận được %s (%r)'
                % (key, type_name(value), value))
            continue
        if value.strip() == "":
            warn('khoá "%s" là chuỗi rỗng (nên là null nếu không đọc được)' % key)

    # --- generated_at: ISO-8601 parse được ---------------------------------
    if "generated_at" not in data:
        err('thiếu khoá bắt buộc "generated_at"')
    else:
        stamp = data["generated_at"]
        if not isinstance(stamp, str) or not stamp.strip():
            err('khoá "generated_at" phải là string ISO-8601, nhận được %s (%r)'
                % (type_name(stamp), stamp))
        elif not ISO_RE.match(stamp.strip()):
            err('khoá "generated_at" không đúng dạng ISO-8601 UTC: %r' % stamp)
        else:
            normalised = stamp.strip().replace("Z", "+00:00").replace("z", "+00:00")
            try:
                datetime.datetime.fromisoformat(normalised)
            except ValueError as exc:
                err('khoá "generated_at" không parse được (%s): %r' % (exc, stamp))

    # --- services: object với 3 cờ bool ------------------------------------
    if "services" not in data:
        err('thiếu khoá bắt buộc "services"')
    else:
        services = data["services"]
        if not isinstance(services, dict):
            err('khoá "services" phải là object, nhận được %s (%r)'
                % (type_name(services), services))
        else:
            for key in SVC_KEYS:
                if key not in services:
                    err('thiếu khoá bắt buộc "services.%s"' % key)
                    continue
                value = services[key]
                if not isinstance(value, bool):
                    err('khoá "services.%s" phải là bool, nhận được %s (%r)'
                        % (key, type_name(value), value))
            for key in services:
                if key not in SVC_KEYS:
                    warn('khoá "services.%s" không nằm trong hợp đồng schema' % key)

error_text = "\n".join("LỖI: " + item for item in errors)
warning_text = "\n".join("CẢNH BÁO: " + item for item in warnings)
if warning_text:
    sys.stderr.write(warning_text + "\n")
if errors:
    sys.stderr.write(error_text + "\n")
    sys.stderr.write("→ THẤT BẠI: schema /metrics KHÔNG hợp lệ (%s) — %d lỗi · engine: python\n"
                     % (source, len(errors)))
    sys.exit(1)

sys.stdout.write("OK: %s — JSON hợp lệ, đủ %d khoá bắt buộc (engine: %s)\n"
                 % (source, len(NUM_KEYS) + len(STR_KEYS) + 2, "python"))
sys.exit(0)
PY
  return "$rc"
}

# ---------------------------------------------------------------------------
# 5. Engine awk — bộ đọc JSON tối giản (không cần python/jq)
#    Giới hạn: kiểm kiểu theo cấu trúc JSON, không kiểm chi tiết số học.
# ---------------------------------------------------------------------------
run_awk_engine() {
  local rc=0
  TMP_AWK="$(mktemp)" || return 2
  cat > "$TMP_AWK" <<'AWK'
function err(msg) {
  errors = errors "LỖI: " msg "\n"
  nerr++
}
function warn(msg) {
  warns = warns "CẢNH BÁO: " msg "\n"
  nwarn++
}
function tnum(k) { return (k in tkey) ? tkey[k] : "MISSING" }
function skipws(   ch) {
  while (i <= n) {
    ch = substr(s, i, 1)
    if (ch == " " || ch == "\t" || ch == "\n" || ch == "\r") i++
    else break
  }
}
function guard() {
  steps++
  if (steps > 4000000) { BAD = 1; return 1 }
  return 0
}
function pstring(   out, ch) {
  i++
  out = ""
  while (i <= n) {
    if (guard()) return out
    ch = substr(s, i, 1)
    if (ch == "\\") { out = out substr(s, i, 2); i += 2; continue }
    if (ch == "\"") { i++; return out }
    out = out ch
    i++
  }
  BAD = 1
  return out
}
function skip_value(   ch, val, depth2) {
  skipws()
  ch = substr(s, i, 1)
  if (ch == "\"") { pstring(); return "string" }
  if (ch == "{") {
    depth2 = 0
    i++
    while (i <= n) {
      if (guard()) return "object"
      ch = substr(s, i, 1)
      if (ch == "{") { depth2++; i++; continue }
      if (ch == "}") { if (depth2 == 0) { i++; return "object" } depth2--; i++; continue }
      if (ch == "\"") { pstring(); continue }
      i++
    }
    BAD = 1
    return "object"
  }
  if (ch == "[") {
    depth2 = 0
    i++
    while (i <= n) {
      if (guard()) return "array"
      ch = substr(s, i, 1)
      if (ch == "[") { depth2++; i++; continue }
      if (ch == "]") { if (depth2 == 0) { i++; return "array" } depth2--; i++; continue }
      if (ch == "\"") { pstring(); continue }
      i++
    }
    BAD = 1
    return "array"
  }
  val = ""
  while (i <= n) {
    if (guard()) break
    ch = substr(s, i, 1)
    if (ch == "," || ch == "}" || ch == "]" || ch == " " || ch == "\t" ||
        ch == "\n" || ch == "\r") break
    val = val ch
    i++
  }
  if (val == "null") return "null"
  if (val == "true" || val == "false") return "bool"
  if (val ~ /^-?[0-9]+(\.[0-9]+)?([eE][+-]?[0-9]+)?$/) return "number"
  BAD = 1
  return "bad:" val
}
function is_iso8601(v,   y, mo, d, h, mi, se, rest, sep) {
  if (v !~ /^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9][Tt ][0-9][0-9]:[0-9][0-9]:[0-9][0-9](\.[0-9]+)?([Zz]|[+-][0-9][0-9]:?[0-9][0-9])?$/) return 0
  y = substr(v, 1, 4) + 0
  mo = substr(v, 6, 2) + 0
  d = substr(v, 9, 2) + 0
  h = substr(v, 12, 2) + 0
  mi = substr(v, 15, 2) + 0
  se = substr(v, 18, 2) + 0
  if (y < 2000 || y > 2200) return 0
  if (mo < 1 || mo > 12) return 0
  if (d < 1 || d > 31) return 0
  if (h > 23 || mi > 59 || se > 60) return 0
  rest = substr(v, 20)
  return 1
}
BEGIN {
  split("cpu_percent load1 load5 load15 cores mem_total_mb mem_used_mb mem_available_mb swap_total_mb swap_used_mb disk_total_gb disk_used_gb disk_avail_gb disk_os_gb disk_db_gb disk_media_gb uptime_s", nl, " ")
  nnum = 17
  split("kernel arch os_pretty data_dir docker_version pocketbase_version", sl, " ")
  nstr = 6
  split("pocketbase nginx docker", sv, " ")
  nsvc = 3
  for (k = 1; k <= nnum; k++) tkey[nl[k]] = "MISSING"
  for (k = 1; k <= nstr; k++) tkey[sl[k]] = "MISSING"
  tkey["generated_at"] = "MISSING"
  tkey["services"] = "MISSING"
  errors = ""
  warns = ""
  nerr = 0
  nwarn = 0
  BAD = 0
  steps = 0
}
{ s = s $0 "\n" }
END {
  n = length(s)
  i = 1
  if (n == 0) {
    err("đầu vào rỗng")
    BAD = 1
  }
  if (!BAD) {
    skipws()
    if (substr(s, i, 1) != "{") {
      err("nội dung không phải JSON object (engine awk không parse được)")
      BAD = 1
    } else {
      i++
      while (i <= n && !BAD) {
        skipws()
        ch = substr(s, i, 1)
        if (ch == "}") { i++; break }
        if (ch == ",") { i++; continue }
        if (ch != "\"") { err("cấu trúc JSON sai: chờ tên khoá"); BAD = 1; break }
        key = pstring()
        if (BAD) break
        skipws()
        if (substr(s, i, 1) != ":") { err("cấu trúc JSON sai: thiếu \":\" sau khoá \"" key "\""); BAD = 1; break }
        i++
        if (key == "services") {
          skipws()
          if (substr(s, i, 1) != "{") {
            tkey["services"] = "bad"
            err("khoá \"services\" phải là object")
            BAD = 1
            break
          }
          i++
          while (i <= n && !BAD) {
            skipws()
            ch = substr(s, i, 1)
            if (ch == "}") { i++; break }
            if (ch == ",") { i++; continue }
            if (ch != "\"") { err("cấu trúc JSON sai trong \"services\""); BAD = 1; break }
            sk = pstring()
            if (BAD) break
            skipws()
            if (substr(s, i, 1) != ":") { err("cấu trúc JSON sai trong \"services\""); BAD = 1; break }
            i++
            stype = skip_value()
            if (sk == "pocketbase" || sk == "nginx" || sk == "docker") tkey["services." sk] = stype
            else warn("khoá \"services." sk "\" không nằm trong hợp đồng schema")
            if (BAD) break
          }
          if (!BAD) tkey["services"] = "object"
        } else {
          skipws()
          if (substr(s, i, 1) == "\"") { sval[key] = pstring(); tkey[key] = "string" }
          else { tkey[key] = skip_value() }
          if (BAD) break
        }
      }
      skipws()
      if (!BAD && i <= n) {
        err("còn dữ liệu thừa sau JSON object")
        BAD = 1
      }
    }
  }
  if (BAD) {
    printf "%s", errors > "/dev/stderr"
    printf "→ THẤT BẠI: JSON không hợp lệ / không đúng cấu trúc (%s) — engine: awk\n", SRC > "/dev/stderr"
    exit 1
  }
  for (k = 1; k <= nnum; k++) {
    key = nl[k]
    tv = tkey[key]
    if (tv == "MISSING") err("thiếu khoá bắt buộc \"" key "\"")
    else if (tv != "number" && tv != "null") err("khoá \"" key "\" phải là số hoặc null, nhận được " tv)
  }
  for (k = 1; k <= nstr; k++) {
    key = sl[k]
    tv = tkey[key]
    if (tv == "MISSING") err("thiếu khoá bắt buộc \"" key "\"")
    else if (tv != "string" && tv != "null") err("khoá \"" key "\" phải là string hoặc null, nhận được " tv)
    else if (tv == "string" && sval[key] == "") warn("khoá \"" key "\" là chuỗi rỗng (nên là null nếu không đọc được)")
  }
  if (tkey["generated_at"] == "MISSING") err("thiếu khoá bắt buộc \"generated_at\"")
  else if (tkey["generated_at"] != "string") err("khoá \"generated_at\" phải là string ISO-8601, nhận được " tkey["generated_at"])
  else if (!is_iso8601(sval["generated_at"])) err("khoá \"generated_at\" không đúng dạng ISO-8601 UTC: " sval["generated_at"])
  if (tkey["services"] != "object") err("thiếu khoá bắt buộc \"services\" (object 3 cờ bool)")
  else {
    for (k = 1; k <= nsvc; k++) {
      key = "services." sv[k]
      tv = tkey[key]
      if (tv == "" || tv == "MISSING") err("thiếu khoá bắt buộc \"" key "\"")
      else if (tv != "bool") err("khoá \"" key "\" phải là bool, nhận được " tv)
    }
  }
  if (warns != "") printf "%s", warns > "/dev/stderr"
  if (nerr > 0) {
    printf "%s", errors > "/dev/stderr"
    printf "→ THẤT BẠI: schema /metrics KHÔNG hợp lệ (%s) — %d lỗi · engine: awk\n", SRC, nerr > "/dev/stderr"
    exit 1
  }
  printf "OK: %s — JSON hợp lệ, đủ %d khoá bắt buộc (engine: awk)\n", SRC, nnum + nstr + 2
  exit 0
}
AWK
  awk -v SRC="$SOURCE" -f "$TMP_AWK" "$TMP_JSON" || rc=$?
  return "$rc"
}

# ---------------------------------------------------------------------------
# 6. Chạy engine đã chọn
# ---------------------------------------------------------------------------
if [[ "$USE_ENGINE" == "python" ]]; then
  run_python_engine
  exit $?
fi

run_awk_engine
exit $?
