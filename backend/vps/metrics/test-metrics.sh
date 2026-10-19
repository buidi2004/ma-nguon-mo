#!/usr/bin/env bash
# =============================================================================
# OpenFlix — Bộ kiểm chứng cục bộ cho endpoint /metrics
# -----------------------------------------------------------------------------
# Script TỰ KHẲNG ĐỊNH (self-assert). Có 4 nhóm kiểm tra:
#   A. Cú pháp bash của mọi file .sh trong thư mục này (bash -n).
#   B. Validator schema với fixtures/ (valid*.json → exit 0,
#      invalid*.json → exit != 0) trên MỌI engine có sẵn (python + awk).
#   C. Validator ở chế độ stdin và các đầu vào lỗi (thiếu file, rỗng, rác).
#   D. Chạy agent THẬT rồi kiểm chứng JSON — CHỈ khi shell đang chạy là Linux
#      có /proc thật của nhân. Trên Windows (Git Bash/MSYS, Cygwin) /proc chỉ là
#      giả lập nên phần này được SKIP một cách tường minh (không giả vờ PASS).
#
# Exit: 0 = mọi assert PASS (SKIP không tính là FAIL) · 1 = có assert FAIL.
#
# Biến môi trường:
#   OPENFLIX_REQUIRE_AGENT=1  → coi việc không chạy được agent là FAIL (dùng trên VPS/CI).
#   VALIDATOR_ENGINE=...      → chuyển tiếp cho validator (auto|python|awk).
# =============================================================================
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENT="${SCRIPT_DIR}/openflix-metrics.sh"
VALIDATOR="${SCRIPT_DIR}/validate-metrics-json.sh"
FIXTURES="${SCRIPT_DIR}/fixtures"
REQUIRE_AGENT="${OPENFLIX_REQUIRE_AGENT:-0}"

PASS=0
FAIL=0
SKIPPED=0
WORK="$(mktemp -d)"
cleanup() { rm -rf "$WORK"; }
trap cleanup EXIT

section() { printf '\n=== %s ===\n' "$*"; }
pass()    { PASS=$((PASS + 1));     printf 'PASS  %s\n' "$*"; }
fail()    { FAIL=$((FAIL + 1));     printf 'FAIL  %s\n' "$*"; }
skip()    { SKIPPED=$((SKIPPED + 1)); printf 'SKIP  %s\n' "$*"; }
note()    { printf 'NOTE  %s\n' "$*"; }

indent() { sed 's/^/      │ /'; }

# ---------------------------------------------------------------------------
# Chuẩn hoá LF: trên Windows, Git (core.autocrlf=true) có thể đã đổi các file
# .sh đã commit sang CRLF ở working tree, làm bash không chạy nổi.
# Các file MỚI trong repo này (install.sh, validate…, test…) có LF; nhưng nếu
# người dùng checkout trên máy Windows thì git cũng sẽ đổi chúng sang CRLF.
# → Ở đây ta tạo bản sao đã bỏ CR để kiểm chứng LOGIC, và ghi NOTE tường minh.
# ---------------------------------------------------------------------------
CRLF_FILES=()
lf_copy() { # lf_copy <src> <name> → in ra đường dẫn bản LF dùng để chạy
  local src="$1" name="$2" dst
  if LC_ALL=C grep -q $'\r' "$src" 2>/dev/null; then
    dst="$WORK/lf/${name}"
    mkdir -p "$WORK/lf"
    tr -d '\r' < "$src" > "$dst"
    CRLF_FILES+=("${src#"$SCRIPT_DIR"/}")
    printf '%s' "$dst"
  else
    printf '%s' "$src"
  fi
}

# ---------------------------------------------------------------------------
# Tiện ích: đọc một giá trị vô hướng từ JSON (dùng cho assert ngữ nghĩa).
# In ra: giá trị thô (số / chuỗi / null / true / false) hoặc MISSING.
# ---------------------------------------------------------------------------
json_raw() { # json_raw <file> <key>
  awk -v want="$2" '
    { s = s $0 "\n" }
    END {
      n = length(s)
      pos = index(s, "\"" want "\"")
      if (pos == 0) { print "MISSING"; exit }
      i = pos + length(want) + 2
      while (i <= n) { c = substr(s, i, 1); if (c == " " || c == "\t" || c == "\n" || c == "\r") i++; else break }
      if (substr(s, i, 1) != ":") { print "MISSING"; exit }
      i++
      while (i <= n) { c = substr(s, i, 1); if (c == " " || c == "\t" || c == "\n" || c == "\r") i++; else break }
      if (substr(s, i, 1) == "\"") {
        i++
        out = ""
        while (i <= n) {
          c = substr(s, i, 1)
          if (c == "\\") { out = out substr(s, i + 1, 1); i += 2; continue }
          if (c == "\"") break
          out = out c
          i++
        }
        print out
        exit
      }
      out = ""
      while (i <= n) {
        c = substr(s, i, 1)
        if (c == "," || c == "}" || c == "]") break
        out = out c
        i++
      }
      gsub(/[ \t\r\n]+$/, "", out)
      print (out == "" ? "MISSING" : out)
    }' "$1"
}

is_number() { printf '%s' "$1" | grep -Eq '^-?[0-9]+(\.[0-9]+)?([eE][+-]?[0-9]+)?$'; }

find_python_bin() {
  local cand
  for cand in python3 python python3.12 python3.11 python3.10; do
    if command -v "$cand" >/dev/null 2>&1 &&
       "$cand" -c 'import json,sys; sys.exit(0)' >/dev/null 2>&1; then
      printf '%s' "$cand"
      return 0
    fi
  done
  return 1
}

printf 'OpenFlix — kiểm chứng endpoint /metrics\n'
printf '  shell     : %s (%s)\n' "${BASH:-?}" "$(uname -s)"
printf '  thư mục   : %s\n' "$SCRIPT_DIR"

# ---------------------------------------------------------------------------
# A. Cú pháp bash
# ---------------------------------------------------------------------------
section 'A. Cú pháp bash (bash -n) cho mọi file .sh'
shopt -s nullglob
sh_files=("${SCRIPT_DIR}"/*.sh)
shopt -u nullglob
if [[ ${#sh_files[@]} -eq 0 ]]; then
  fail 'Không tìm thấy file .sh nào trong thư mục.'
fi
for f in "${sh_files[@]}"; do
  run_f="$(lf_copy "$f" "$(basename "$f")")"
  if bash -n "$run_f" 2>"$WORK/syntax.err"; then
    pass "bash -n $(basename "$f")"
  else
    fail "bash -n $(basename "$f")"
    indent < "$WORK/syntax.err"
  fi
done

# ---------------------------------------------------------------------------
# B. Fixtures × engine
# ---------------------------------------------------------------------------
VALIDATOR_RUN="$(lf_copy "$VALIDATOR" "validate-metrics-json.sh")"

section 'B. Validator với fixtures (valid → 0, invalid → khác 0)'

if [[ ! -f "$VALIDATOR" ]]; then
  fail "Không thấy validator: $VALIDATOR"
else
  engines=("awk")
  PYTHON_BIN="$(find_python_bin)" || PYTHON_BIN=""
  if [[ -n "$PYTHON_BIN" ]]; then
    engines=("python" "awk" "auto")
    printf '      (có %s → kiểm chứng cả 3 engine: python, awk, auto)\n' "$PYTHON_BIN"
  else
    printf '      (KHÔNG có python trên máy này → chỉ kiểm chứng engine awk)\n'
  fi

  shopt -s nullglob
  valid_files=("${FIXTURES}"/valid*.json)
  invalid_files=("${FIXTURES}"/invalid*.json)
  shopt -u nullglob

  if [[ ${#valid_files[@]} -eq 0 || ${#invalid_files[@]} -lt 2 ]]; then
    fail "Fixtures thiếu: cần ≥1 valid*.json và ≥2 invalid*.json"
  fi

  for engine in "${engines[@]}"; do
    for f in "${valid_files[@]}"; do
      if out="$(bash "$VALIDATOR_RUN" --engine "$engine" "$f" 2>&1)"; then
        pass "[$engine] $(basename "$f") → exit 0 (${out%% *} hợp lệ)"
      else
        fail "[$engine] $(basename "$f") → phải là 0 nhưng nhận $?"
        printf '%s\n' "$out" | indent
      fi
    done
    for f in "${invalid_files[@]}"; do
      rc=0
      out="$(bash "$VALIDATOR_RUN" --engine "$engine" "$f" 2>&1)" || rc=$?
      if [[ "$rc" -ne 0 ]]; then
        pass "[$engine] $(basename "$f") → exit ${rc} (đúng: phải từ chối)"
      else
        fail "[$engine] $(basename "$f") → phải khác 0 nhưng nhận 0 (validator bỏ sót lỗi!)"
        printf '%s\n' "$out" | indent
      fi
    done
  done
fi

# ---------------------------------------------------------------------------
# C. Chế độ stdin + đầu vào lỗi
# ---------------------------------------------------------------------------
section 'C. Validator: stdin, thiếu file, đầu vào rỗng/rác'

if [[ -f "$VALIDATOR" ]]; then
  if out="$(bash "$VALIDATOR_RUN" < "${FIXTURES}/valid.json" 2>&1)"; then
    pass 'stdin (valid.json) → exit 0'
  else
    fail "stdin (valid.json) → phải là 0, nhận $?"
    printf '%s\n' "$out" | indent
  fi

  rc=0
  out="$(bash "$VALIDATOR_RUN" "$WORK/khong-ton-tai.json" 2>&1)" || rc=$?
  if [[ "$rc" -ne 0 ]]; then
    pass "file không tồn tại → exit ${rc} (đúng: phải từ chối)"
  else
    fail 'file không tồn tại → phải khác 0 nhưng nhận 0'
  fi

  rc=0
  out="$(bash "$VALIDATOR_RUN" < /dev/null 2>&1)" || rc=$?
  if [[ "$rc" -ne 0 ]]; then
    pass "stdin rỗng → exit ${rc} (đúng: phải từ chối)"
  else
    fail 'stdin rỗng → phải khác 0 nhưng nhận 0'
  fi

  rc=0
  out="$(printf '{ "cpu_percent": 1, ' | bash "$VALIDATOR_RUN" 2>&1)" || rc=$?
  if [[ "$rc" -ne 0 ]]; then
    pass "JSON cụt (thiếu dấu đóng) → exit ${rc} (đúng: phải từ chối)"
  else
    fail 'JSON cụt → phải khác 0 nhưng nhận 0'
  fi

  rc=0
  out="$(bash "$VALIDATOR_RUN" --engine python < "${FIXTURES}/valid.json" 2>&1)" || rc=$?
  if [[ -z "$PYTHON_BIN" ]]; then
    if [[ "$rc" -eq 2 ]]; then
      pass 'khi thiếu python: --engine python → exit 2 (lỗi dùng lệnh, không im lặng PASS)'
    else
      fail "--engine python khi không có python → kỳ vọng 2, nhận ${rc}"
      printf '%s\n' "$out" | indent
    fi
  fi
fi

# ---------------------------------------------------------------------------
# D. Chạy agent thật (chỉ trên Linux có /proc thật)
# ---------------------------------------------------------------------------
section 'D. Chạy agent thật + kiểm chứng đầu ra'
KERNEL_NAME="$(uname -s)"
AGENT_RUNNABLE=0
if [[ "$REQUIRE_AGENT" == "1" && ! -f "$AGENT" ]]; then
  fail "OPENFLIX_REQUIRE_AGENT=1 nhưng không thấy agent: $AGENT"
elif [[ ! -f "$AGENT" ]]; then
  skip "Không thấy ${AGENT} → không kiểm chứng được agent."
elif [[ "$KERNEL_NAME" != "Linux" ]]; then
  skip "shell không phải nhân Linux (uname -s=${KERNEL_NAME}) → /proc ở đây chỉ là giả lập của MSYS/Cygwin, KHÔNG phải số liệu thật; bỏ qua phần chạy agent."
elif [[ ! -r /proc/stat || ! -r /proc/meminfo ]]; then
  skip 'thiếu /proc/stat hoặc /proc/meminfo → không chạy được agent (cần Linux thật).'
else
  AGENT_RUNNABLE=1
fi

if [[ "$AGENT_RUNNABLE" == "1" ]]; then
  AGENT_RUN="$(lf_copy "$AGENT" "openflix-metrics.sh")"
  mkdir -p "$WORK/pbdata-exists"
  head -c 1048576 /dev/urandom > "$WORK/pbdata-exists/dummy.bin" 2>/dev/null || true
  OUT1="$WORK/metrics-no-db.json"
  OUT2="$WORK/metrics-with-db.json"

  # D.1 — thư mục pb_data/media KHÔNG tồn tại → phải là null (không bịa số)
  rc=0
  OUT_FILE="$OUT1" PB_DATA_DIR="$WORK/khong-co-pb" MEDIA_DIR="$WORK/khong-co-media" CPU_SAMPLE_MS=200 \
    bash "$AGENT_RUN" >"$WORK/agent1.log" 2>&1 || rc=$?
  if [[ "$rc" -ne 0 ]]; then
    fail "agent chạy (không có pb_data) → exit ${rc}"
    indent < "$WORK/agent1.log"
  else
    pass 'agent chạy xong (exit 0) với pb_data/media không tồn tại'
  fi

  if [[ -s "$OUT1" ]]; then
    pass "agent ghi được file JSON ($(wc -c < "$OUT1" | tr -d ' ') byte)"
  else
    fail 'agent KHÔNG ghi được file JSON'
  fi

  if [[ -f "$VALIDATOR_RUN" && -s "$OUT1" ]]; then
    rc=0
    out="$(bash "$VALIDATOR_RUN" "$OUT1" 2>&1)" || rc=$?
    if [[ "$rc" -eq 0 ]]; then
      pass "JSON thật của agent ĐÚNG schema (${out})"
    else
      fail "JSON thật của agent SAI schema (exit ${rc})"
      printf '%s\n' "$out" | indent
    fi
  fi

  if [[ -s "$OUT1" ]]; then
    v_db="$(json_raw "$OUT1" disk_db_gb)"
    v_data="$(json_raw "$OUT1" data_dir)"
    if [[ "$v_db" == "null" && "$v_data" == "null" ]]; then
      pass 'pb_data không tồn tại → disk_db_gb=null và data_dir=null (không bịa số)'
    else
      fail "pb_data không tồn tại nhưng disk_db_gb=${v_db}, data_dir=${v_data} (phải là null)"
    fi
  fi

  # D.2 — pb_data CÓ tồn tại → disk_db_gb phải là số thật
  rc=0
  OUT_FILE="$OUT2" PB_DATA_DIR="$WORK/pbdata-exists" MEDIA_DIR="$WORK/khong-co-media" CPU_SAMPLE_MS=200 \
    bash "$AGENT_RUN" >"$WORK/agent2.log" 2>&1 || rc=$?
  if [[ "$rc" -ne 0 ]]; then
    fail "agent chạy (có pb_data) → exit ${rc}"
  elif [[ -f "$VALIDATOR_RUN" ]]; then
    rc2=0
    bash "$VALIDATOR_RUN" "$OUT2" >/dev/null 2>&1 || rc2=$?
    if [[ "$rc2" -eq 0 ]]; then
      pass 'JSON của agent khi pb_data tồn tại: đúng schema'
    else
      fail "JSON của agent khi pb_data tồn tại: SAI schema (exit ${rc2})"
    fi
  fi

  if [[ -s "$OUT2" ]]; then
    v_db="$(json_raw "$OUT2" disk_db_gb)"
    v_data="$(json_raw "$OUT2" data_dir)"
    if is_number "$v_db" && [[ "$v_data" == "$WORK/pbdata-exists" ]]; then
      pass "pb_data tồn tại → disk_db_gb=${v_db} (số thật), data_dir=${v_data}"
    else
      fail "pb_data tồn tại nhưng disk_db_gb=${v_db}, data_dir=${v_data}"
    fi

    v_mem="$(json_raw "$OUT2" mem_total_mb)"
    if is_number "$v_mem" && awk -v m="$v_mem" 'BEGIN{exit !(m > 0)}'; then
      pass "mem_total_mb=${v_mem} (số thật, > 0)"
    else
      fail "mem_total_mb=${v_mem} (kỳ vọng số > 0)"
    fi

    v_up="$(json_raw "$OUT2" uptime_s)"
    if is_number "$v_up" && awk -v u="$v_up" 'BEGIN{exit !(u > 0)}'; then
      pass "uptime_s=${v_up} (số thật, > 0)"
    else
      fail "uptime_s=${v_up} (kỳ vọng số > 0)"
    fi

    # CPU chỉ đo được nếu /proc/stat có đủ trường (idle + iowait)
    stat_fields="$(awk '/^cpu /{print NF}' /proc/stat)"
    v_cpu="$(json_raw "$OUT2" cpu_percent)"
    if [[ "${stat_fields:-0}" -ge 8 ]]; then
      if is_number "$v_cpu" && awk -v c="$v_cpu" 'BEGIN{exit !(c >= 0 && c <= 100)}'; then
        pass "cpu_percent=${v_cpu} (0-100%, đo từ 2 mẫu /proc/stat)"
      else
        fail "cpu_percent=${v_cpu} (kỳ vọng số trong 0-100)"
      fi
    else
      skip "/proc/stat chỉ có ${stat_fields:-?} trường (< 8) → không đo được %CPU; agent trả cpu_percent=${v_cpu} (kỳ vọng null)"
      if [[ "$v_cpu" != "null" ]]; then
        fail "cpu_percent=${v_cpu} nhưng /proc/stat không đủ trường (phải là null, không được bịa)"
      fi
    fi

    # Nhãn thời gian phải là thời điểm gần đây
    if [[ -n "$PYTHON_BIN" ]]; then
      if "$PYTHON_BIN" - "$OUT2" <<'PY' >/dev/null 2>&1
import datetime
import json
import sys

with open(sys.argv[1], encoding="utf-8") as handle:
    data = json.load(handle)
stamp = datetime.datetime.strptime(data["generated_at"], "%Y-%m-%dT%H:%M:%SZ").replace(
    tzinfo=datetime.timezone.utc
)
age = (datetime.datetime.now(datetime.timezone.utc) - stamp).total_seconds()
sys.exit(0 if -60 <= age <= 120 else 1)
PY
      then
        pass 'generated_at là thời điểm hiện tại (chênh lệch trong ±2 phút)'
      else
        fail 'generated_at không phải thời điểm hiện tại (lệch quá 2 phút)'
      fi
    else
      skip 'không có python → không kiểm chứng được độ mới của generated_at'
    fi
  fi
elif [[ "$REQUIRE_AGENT" == "1" ]]; then
  fail 'OPENFLIX_REQUIRE_AGENT=1 nhưng không chạy được agent trên máy này.'
fi

# ---------------------------------------------------------------------------
# E. Những thứ KHÔNG kiểm chứng được ở đây (nói rõ, không giả vờ PASS)
# ---------------------------------------------------------------------------
section 'E. Phạm vi không kiểm chứng được trên máy Windows này'
skip 'install.sh: ghi /opt, /etc/systemd/system, /etc/nginx, chown, systemctl → cần VPS Linux thật (chỉ kiểm tra được bash -n + --dry-run).'
skip 'systemd timer chạy mỗi 5 giây → cần systemd thật.'
skip 'nginx -t / reload / token 403 bằng curl tới 180.93.120.246 → cần VPS thật.'

# ---------------------------------------------------------------------------
# Tổng kết
# ---------------------------------------------------------------------------
section 'TỔNG KẾT'
printf 'PASS=%d  FAIL=%d  SKIP=%d\n' "$PASS" "$FAIL" "$SKIPPED"
if [[ "$FAIL" -gt 0 ]]; then
  printf '→ KẾT QUẢ: THẤT BẠI (%d assert sai)\n' "$FAIL"
  exit 1
fi
printf '→ KẾT QUẢ: OK (không có assert nào sai)\n'
exit 0
