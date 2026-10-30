# -*- coding: utf-8 -*-
"""
Script vẽ 12 sơ đồ kiến trúc & phân tích thiết kế hệ thống OpenFlix (PNG chất lượng cao)
Chuẩn hóa khớp 100% với danh mục ảnh docs/qa/screenshots/ (S01 đến S42)
Sử dụng thư viện Pillow (PIL) tích hợp sẵn trong Python.
"""

import os
from PIL import Image, ImageDraw, ImageFont

OUT_DIR = r"docs\diagrams"
os.makedirs(OUT_DIR, exist_ok=True)

def get_fonts():
    try:
        title_font = ImageFont.truetype("arialbd.ttf", 26)
        header_font = ImageFont.truetype("arialbd.ttf", 18)
        body_font = ImageFont.truetype("arial.ttf", 15)
        bold_font = ImageFont.truetype("arialbd.ttf", 15)
        small_font = ImageFont.truetype("arial.ttf", 12)
        code_font = ImageFont.truetype("consola.ttf", 13)
    except:
        try:
            title_font = ImageFont.truetype("timesbd.ttf", 26)
            header_font = ImageFont.truetype("timesbd.ttf", 18)
            body_font = ImageFont.truetype("times.ttf", 15)
            bold_font = ImageFont.truetype("timesbd.ttf", 15)
            small_font = ImageFont.truetype("times.ttf", 12)
            code_font = ImageFont.truetype("cour.ttf", 13)
        except:
            title_font = ImageFont.load_default()
            header_font = title_font
            body_font = title_font
            bold_font = title_font
            small_font = title_font
            code_font = title_font
    return title_font, header_font, body_font, bold_font, small_font, code_font

F_TITLE, F_HEADER, F_BODY, F_BOLD, F_SMALL, F_CODE = get_fonts()

def draw_header(draw, width, title, subtitle):
    draw.rectangle([0, 0, width, 70], fill="#003399")
    draw.text((25, 12), title, font=F_TITLE, fill="#FFFFFF")
    draw.text((25, 44), subtitle, font=F_SMALL, fill="#BBDEFB")

def draw_box(draw, xy, text, subtext="", fill="#FFFFFF", outline="#003399", text_color="#000000", radius=8):
    x0, y0, x1, y1 = xy
    draw.rounded_rectangle([x0, y0, x1, y1], radius=radius, fill=fill, outline=outline, width=2)
    cx = (x0 + x1) / 2
    if subtext:
        draw.text((cx, y0 + 14), text, font=F_BOLD, fill=text_color, anchor="mm")
        draw.text((cx, y0 + 36), subtext, font=F_SMALL, fill="#555555" if text_color == "#000000" else "#E0E0E0", anchor="mm")
    else:
        cy = (y0 + y1) / 2
        draw.text((cx, cy), text, font=F_BOLD, fill=text_color, anchor="mm")

def draw_arrow(draw, start, end, label="", color="#333333", width=2, dashed=False):
    x0, y0 = start
    x1, y1 = end
    if dashed:
        # Draw dashed line
        dist = ((x1 - x0)**2 + (y1 - y0)**2)**0.5
        if dist > 0:
            steps = int(dist // 10)
            for i in range(steps):
                if i % 2 == 0:
                    sx = x0 + (x1 - x0) * (i / steps)
                    sy = y0 + (y1 - y0) * (i / steps)
                    ex = x0 + (x1 - x0) * ((i + 1) / steps)
                    ey = y0 + (y1 - y0) * ((i + 1) / steps)
                    draw.line([sx, sy, ex, ey], fill=color, width=width)
    else:
        draw.line([x0, y0, x1, y1], fill=color, width=width)
        
    if x1 > x0 and y1 == y0:
        draw.polygon([(x1, y1), (x1 - 8, y1 - 5), (x1 - 8, y1 + 5)], fill=color)
    elif x1 < x0 and y1 == y0:
        draw.polygon([(x1, y1), (x1 + 8, y1 - 5), (x1 + 8, y1 + 5)], fill=color)
    elif y1 > y0 and x1 == x0:
        draw.polygon([(x1, y1), (x1 - 5, y1 - 8), (x1 + 5, y1 - 8)], fill=color)
    elif y1 < y0 and x1 == x0:
        draw.polygon([(x1, y1), (x1 - 5, y1 + 8), (x1 + 5, y1 + 8)], fill=color)
    
    if label:
        mx, my = (x0 + x1) / 2, (y0 + y1) / 2
        draw.rectangle([mx - 40, my - 10, mx + 40, my + 10], fill="#FFFFFF")
        draw.text((mx, my), label, font=F_SMALL, fill=color, anchor="mm")

# 1. D01: USE CASE TỔNG QUÁT (Có kế thừa Member -> Guest)
def make_d01():
    W, H = 1000, 640
    im = Image.new("RGB", (W, H), "#F8F9FA")
    draw = ImageDraw.Draw(im)
    draw_header(draw, W, "SƠ ĐỒ USE CASE TỔNG QUÁT HỆ THỐNG OPENFLIX", "Phân quyền tác nhân: Khách (Guest), Thành viên (Member kế thừa Guest), Quản trị viên (Admin)")

    draw.rounded_rectangle([250, 85, 750, 620], radius=10, fill="#FFFFFF", outline="#003399", width=2)
    draw.text((270, 95), "HỆ THỐNG OPENFLIX (SYSTEM BOUNDARY)", font=F_BOLD, fill="#003399")

    draw_box(draw, [40, 140, 200, 220], "KHÁCH (GUEST)", "Chưa đăng nhập", fill="#E3F2FD", outline="#0071EB")
    draw_box(draw, [40, 360, 200, 460], "THÀNH VIÊN", "Kế thừa Khách + JWT", fill="#FFEBEE", outline="#E50914")
    draw_box(draw, [790, 240, 960, 340], "QUẢN TRỊ VIÊN", "PocketBase Admin", fill="#E8F5E9", outline="#2E7D32")

    # Kế thừa Member -> Guest
    draw_arrow(draw, (120, 360), (120, 220), "<<extends>>", color="#1976D2", width=2)

    cases = [
        ("UC01: Khám phá kho phim & Danh mục", 130),
        ("UC02: Tìm kiếm & Lọc phim (S10-S12)", 185),
        ("UC03: Xem Video Trailer (S19)", 240),
        ("UC04: Đăng nhập & Đăng ký (S04-S05)", 295),
        ("UC05: Xem phim Full 1080p Tua ±10s (S20)", 350),
        ("UC06: Quản lý Thư viện My List (S25)", 405),
        ("UC07: Đánh giá & Bình luận sao (S23-S24)", 460),
        ("UC08: Tải phim & Cài đặt (S28, S33)", 515),
        ("UC09: Quản lý Kho phim & Dữ liệu", 570),
    ]

    for title, y in cases:
        draw_box(draw, [310, y - 18, 690, y + 22], title, "", fill="#FAFAFA", outline="#B0BEC5", radius=14)

    for y in [130, 185, 240, 295]:
        draw_arrow(draw, (200, 180), (310, y + 2), "", color="#0071EB")
    for y in [350, 405, 460, 515]:
        draw_arrow(draw, (200, 410), (310, y + 2), "", color="#E50914")
    draw_arrow(draw, (790, 290), (690, 570), "", color="#2E7D32")

    im.save(os.path.join(OUT_DIR, "D01_use_case_system.png"))
    print("✅ Đã tạo D01_use_case_system.png")

# 2. D02: FLUTTER CLEAN ARCHITECTURE
def make_d02():
    W, H = 1000, 640
    im = Image.new("RGB", (W, H), "#F8F9FA")
    draw = ImageDraw.Draw(im)
    draw_header(draw, W, "KIẾN TRÚC PHÂN TẦNG FLUTTER CLEAN ARCHITECTURE", "Presentation Layer ➔ Domain Layer ➔ Data Layer ➔ Core Infrastructure")

    layers = [
        ("TẦNG TRÌNH DIỄN (PRESENTATION LAYER)", "#FFEBEE", "#E50914", 90, 210, [
            "42 Màn hình UI (S01 - S42)", "Chewie Video Player & Custom Controls (S20)", "State Providers & Controllers"
        ]),
        ("TẦNG NGHIỆP VỤ (DOMAIN LAYER)", "#E8EAF6", "#3F51B5", 225, 345, [
            "Use Cases & Business Logic", "IMovieRepository (Hợp đồng dữ liệu)", "IAuthRepository & ILibraryRepository"
        ]),
        ("TẦNG DỮ LIỆU (DATA LAYER)", "#E0F2F1", "#00897B", 360, 480, [
            "MovieModel (JSON DTO Serialization)", "PocketBaseService (REST API Client)", "Cache (SharedPreferences & SecureStorage)"
        ]),
        ("TẦNG CỐT LÕI (CORE INFRASTRUCTURE)", "#FFF3E0", "#E65100", 495, 615, [
            "AppTheme & Netflix Color Palette (#141414, #E50914)", "AppRoutes (GoRouter Navigation Engine)", "Network Client & Exception Failures"
        ])
    ]

    for title, bg, border, y0, y1, items in layers:
        draw.rounded_rectangle([60, y0, 940, y1], radius=8, fill=bg, outline=border, width=2)
        draw.text((80, y0 + 10), title, font=F_BOLD, fill=border)
        bx_w = (940 - 80 - 40) / 3
        for idx, item in enumerate(items):
            bx_x0 = 80 + idx * (bx_w + 15)
            bx_x1 = bx_x0 + bx_w
            draw_box(draw, [bx_x0, y0 + 40, bx_x1, y1 - 15], item, "", fill="#FFFFFF", outline=border, radius=6)

    draw_arrow(draw, (500, 210), (500, 225), "calls", color="#E50914")
    draw_arrow(draw, (500, 345), (500, 360), "implements", color="#3F51B5")
    draw_arrow(draw, (500, 480), (500, 495), "uses core", color="#00897B")

    im.save(os.path.join(OUT_DIR, "D02_flutter_clean_layers.png"))
    print("✅ Đã tạo D02_flutter_clean_layers.png")

# 3. D03: ĐIỀU HƯỚNG 42 MÀN HÌNH KHỚP 100% REPO
def make_d03():
    W, H = 1050, 700
    im = Image.new("RGB", (W, H), "#F8F9FA")
    draw = ImageDraw.Draw(im)
    draw_header(draw, W, "SƠ ĐỒ ĐIỀU HƯỚNG 42 MÀN HÌNH OPENFLIX (S01 – S42)", "Khớp 100% mã nguồn thực tế và tệp kiểm thử docs/qa/screenshots/")

    groups = [
        ("Nhóm A: Khởi động & Xác thực (S01-S08)", "#E3F2FD", "#1976D2", 50, 90, 500, 270, [
            "S01 Splash", "S02 Onboarding", "S03 Welcome", "S04 Login (1-Click)", "S05 Register", "S06 Forgot Pass", "S07 Profiles", "S08 Profile Edit"
        ]),
        ("Nhóm B: Khám phá & Danh mục (S09-S17)", "#FFEBEE", "#E50914", 540, 90, 1000, 270, [
            "S09 Home", "S10 Search", "S11 Search Results", "S12 Filter", "S13 Genres", "S14 Genre Detail", "S15 See All", "S16 Hot", "S17 Top 10"
        ]),
        ("Nhóm C: Xem phim & Tương tác (S18-S24)", "#E8F5E9", "#2E7D32", 50, 290, 500, 470, [
            "S18 Detail", "S19 Trailer", "S20 Player 1080p", "S21 Episodes", "S22 Similar", "S23 Reviews", "S24 Write Review"
        ]),
        ("Nhóm D: Thư viện cá nhân (S25-S30)", "#FFF3E0", "#E65100", 540, 290, 1000, 470, [
            "S25 My List", "S26 Continue Watch", "S27 History", "S28 Liked", "S29 Notifications", "S30 Me (Hub)"
        ]),
        ("Nhóm E: Tài khoản & Cài đặt (S31-S36)", "#F3E5F5", "#7B1FA2", 50, 490, 500, 670, [
            "S31 Account", "S32 Password", "S33 Settings", "S34 Playback", "S35 Language", "S36 Help"
        ]),
        ("Nhóm F: Ngoại lệ & Trạng thái (S37-S42)", "#ECEFF1", "#455A64", 540, 490, 1000, 670, [
            "S37 Contact", "S38 About", "S39 Offline", "S40 Error 500", "S41 404 Not Found", "S42 Plans"
        ]),
    ]

    for title, bg, border, x0, y0, x1, y1, screens in groups:
        draw.rounded_rectangle([x0, y0, x1, y1], radius=8, fill=bg, outline=border, width=2)
        draw.text((x0 + 15, y0 + 10), title, font=F_BOLD, fill=border)
        cols = 3 if len(screens) <= 6 else 4
        bw = (x1 - x0 - 30) / cols
        bh = 30
        for idx, sc in enumerate(screens):
            r = idx // cols
            c = idx % cols
            bx = x0 + 12 + c * (bw + 4)
            by = y0 + 38 + r * (bh + 8)
            draw_box(draw, [bx, by, bx + bw, by + bh], sc, "", fill="#FFFFFF", outline=border, radius=4)

    draw_arrow(draw, (500, 180), (540, 180), "Auth OK", color="#E50914")
    draw_arrow(draw, (770, 270), (770, 290), "Tap Movie", color="#0071EB")

    im.save(os.path.join(OUT_DIR, "D03_navigation_42_screens.png"))
    print("✅ Đã tạo D03_navigation_42_screens.png")

# 4. D04: SEQUENCE ĐĂNG NHẬP 1-CLICK (CÓ NHÁNH NGOẠI LỆ)
def make_d04():
    W, H = 1000, 640
    im = Image.new("RGB", (W, H), "#FFFFFF")
    draw = ImageDraw.Draw(im)
    draw_header(draw, W, "SƠ ĐỒ TUẦN TỰ: XÁC THỰC & ĐĂNG NHẬP (LUỒNG CHÍNH VÀ NGOẠI LỆ)", "Cấp phát JWT Token thành công (<300ms) hoặc bắt lỗi 400 Bad Request")

    participants = [
        ("Người Dùng (User)", 120),
        ("LoginScreen (S04)", 320),
        ("PocketBaseService", 540),
        ("PocketBase Auth API", 750),
        ("SQLite Database", 910)
    ]

    for name, x in participants:
        draw_box(draw, [x - 80, 85, x + 80, 130], name, fill="#E3F2FD", outline="#003399", radius=6)
        draw.line([x, 130, x, 600], fill="#B0BEC5", width=1)

    msgs = [
        (120, 320, 160, "1. Nhấn nút '1-Click Demo Account'", "#E50914", False),
        (320, 540, 205, "2. authWithPassword('demo@openflix.org', '***')", "#003399", False),
        (540, 750, 250, "3. POST /api/collections/users/auth-with-password", "#003399", False),
        (750, 910, 295, "4. SELECT * FROM users WHERE email=? (Bcrypt match)", "#2E7D32", False),
        (910, 750, 340, "5a. Record OK (Mật khẩu đúng)", "#2E7D32", False),
        (750, 540, 385, "6a. Trả về JWT Token + User Model JSON (200 OK)", "#E50914", False),
        (540, 320, 430, "7a. Lưu token vào AuthStore & SharedPreferences", "#0071EB", False),
        (320, 120, 475, "8a. Chuyển hướng tức thì sang S09 Home Feed", "#E50914", False),
        # Luồng lỗi
        (910, 750, 520, "5b. [Ngoại lệ]: Sai mật khẩu / Không tồn tại", "#C62828", True),
        (750, 320, 560, "6b. HTTP 400 Bad Request: 'Failed to authenticate'", "#C62828", True),
        (320, 120, 595, "7b. Hiển thị SnackBar cảnh báo lỗi màu đỏ & Rung haptic", "#C62828", True)
    ]

    for x0, x1, y, text, col, dashed in msgs:
        draw_arrow(draw, (x0, y), (x1, y), "", color=col, width=2, dashed=dashed)
        mx = (x0 + x1) / 2
        draw.text((mx, y - 8), text, font=F_SMALL, fill=col, anchor="mb")

    im.save(os.path.join(OUT_DIR, "D04_sequence_auth_jwt.png"))
    print("✅ Đã tạo D04_sequence_auth_jwt.png")

# 5. D05: SEQUENCE STREAMING HTTP BYTE-RANGE & TUA ±10S (Khớp S18 Detail & S20 Player)
def make_d05():
    W, H = 1000, 620
    im = Image.new("RGB", (W, H), "#FFFFFF")
    draw = ImageDraw.Draw(im)
    draw_header(draw, W, "SƠ ĐỒ TUẦN TỰ: HTTP BYTE-RANGE STREAMING & TUA ±10S", "Tiêu chuẩn RFC 7233: MovieDetail (S18) ➔ PlayerScreen (S20) ➔ Nginx 206 Partial Content")

    participants = [
        ("Người Xem (User)", 100),
        ("PlayerScreen (S20)", 290),
        ("Chewie / VideoPlayer", 510),
        ("Nginx Media Gateway", 740),
        ("Kho MP4 Linux SSD", 920)
    ]

    for name, x in participants:
        draw_box(draw, [x - 85, 85, x + 85, 130], name, fill="#FFEBEE", outline="#E50914", radius=6)
        draw.line([x, 130, x, 580], fill="#B0BEC5", width=1)

    msgs = [
        (100, 290, 160, "1. Từ S18 Detail nhấn nút 'Phát' (Mở S20 Player)", "#E50914"),
        (290, 510, 210, "2. initialize(videoUrl)", "#003399"),
        (510, 740, 260, "3. GET /media/movie_1080p.mp4 (Range: bytes=0-1048575)", "#003399"),
        (740, 920, 310, "4. Đọc chunk 1MB đầu tiên từ NVMe (Chứa Moov Atom)", "#2E7D32"),
        (920, 740, 350, "5. Chunk data (64KB - 1MB)", "#2E7D32"),
        (740, 510, 390, "6. HTTP 206 Partial Content (Content-Range: 0-1MB/550MB)", "#E50914"),
        (510, 290, 430, "7. Giải mã AVC/H.264 & Xuất khung hình đầu tiên (<0.48s)", "#0071EB"),
        (100, 290, 470, "8. Chạm đúp góc phải màn hình: Tua nhanh +10 Giây", "#E50914"),
        (290, 740, 510, "9. GET Range tại vị trí byte offset mới (+10s)", "#003399"),
        (740, 510, 550, "10. HTTP 206 Partial Content ➔ Tiếp tục phát sau 0.2s", "#2E7D32")
    ]

    for x0, x1, y, text, col in msgs:
        draw_arrow(draw, (x0, y), (x1, y), "", color=col, width=2)
        mx = (x0 + x1) / 2
        draw.text((mx, y - 8), text, font=F_SMALL, fill=col, anchor="mb")

    im.save(os.path.join(OUT_DIR, "D05_sequence_streaming_range.png"))
    print("✅ Đã tạo D05_sequence_streaming_range.png")

# 6. D06: STATE MACHINE CHEWIE
def make_d06():
    W, H = 1000, 600
    im = Image.new("RGB", (W, H), "#F8F9FA")
    draw = ImageDraw.Draw(im)
    draw_header(draw, W, "MÁY TRẠNG THÁI VÒNG ĐỜI TRÌNH PHÁT CHEWIE (FSM)", "Quản lý 7 trạng thái chuyển đổi và thu hồi tài nguyên bộ nhớ GPU")

    states = [
        ("1. INITIALIZING", "Nạp cấu hình URL", 100, 160, "#E3F2FD", "#1976D2"),
        ("2. BUFFERING", "Nạp đệm RAM 2-4s", 400, 160, "#FFF3E0", "#E65100"),
        ("3. PLAYING", "Xuất hình ảnh 60fps", 700, 160, "#E8F5E9", "#2E7D32"),
        ("4. PAUSED", "Tạm dừng hiển thị", 700, 340, "#FFEBEE", "#E50914"),
        ("5. SEEKING", "Tua nhanh ±10 giây", 400, 340, "#F3E5F5", "#7B1FA2"),
        ("6. NETWORK RETRY", "Mất mạng & Thử lại", 400, 480, "#FFCDD2", "#C62828"),
        ("7. DISPOSED", "Hủy Texture GPU", 100, 340, "#ECEFF1", "#455A64"),
    ]

    for name, sub, x, y, bg, border in states:
        draw_box(draw, [x, y, x + 200, y + 70], name, sub, fill=bg, outline=border, radius=8)

    draw_arrow(draw, (300, 195), (400, 195), "load OK", color="#1976D2")
    draw_arrow(draw, (600, 195), (700, 195), "buffer full", color="#2E7D32")
    draw_arrow(draw, (800, 230), (800, 340), "tap pause", color="#E50914")
    draw_arrow(draw, (700, 375), (600, 375), "tap ±10s", color="#7B1FA2")
    draw_arrow(draw, (500, 340), (500, 230), "seek done", color="#E65100")
    draw_arrow(draw, (500, 410), (500, 480), "network lost", color="#C62828")
    draw_arrow(draw, (400, 515), (200, 515), "retry fail", color="#C62828")
    draw_arrow(draw, (200, 515), (200, 410), "", color="#C62828")
    draw_arrow(draw, (200, 230), (200, 340), "exit screen", color="#455A64")

    im.save(os.path.join(OUT_DIR, "D06_player_lifecycle_fsm.png"))
    print("✅ Đã tạo D06_player_lifecycle_fsm.png")

# 7. D07: HẠ TẦNG LINUX/DOCKER
def make_d07():
    W, H = 1000, 620
    im = Image.new("RGB", (W, H), "#F8F9FA")
    draw = ImageDraw.Draw(im)
    draw_header(draw, W, "KIẾN TRÚC TRIỂN KHAI HẠ TẦNG VẬN HÀNH OPENFLIX", "Mô hình Production trên Ubuntu Linux VPS: Nginx SSL, Docker PocketBase & SQLite WAL")

    draw_box(draw, [40, 220, 220, 380], "FLUTTER CLIENT", "Android App (ARM64)\nWeb (CanvasKit)\nDesktop (Windows)", fill="#FFEBEE", outline="#E50914")

    draw.rounded_rectangle([300, 90, 960, 580], radius=10, fill="#FFFFFF", outline="#003399", width=2)
    draw.text((320, 105), "MÁY CHỦ LINUX VPS (UBUNTU SERVER 22.04 LTS)", font=F_BOLD, fill="#003399")

    draw_box(draw, [340, 150, 520, 540], "NGINX REVERSE PROXY", "Port 80/443 (HTTPS)\nLet's Encrypt SSL\nGzip Compression\nByte-Range Static Media", fill="#E3F2FD", outline="#1976D2")

    draw.rounded_rectangle([580, 150, 920, 340], radius=8, fill="#E8F5E9", outline="#2E7D32", width=2)
    draw.text((600, 165), "DOCKER CONTAINER: POCKETBASE", font=F_BOLD, fill="#2E7D32")
    draw_box(draw, [610, 200, 890, 255], "Golang BaaS Engine (Port 8090)", "REST API & Realtime SSE", fill="#FFFFFF", outline="#2E7D32")
    draw_box(draw, [610, 265, 890, 320], "Embedded SQLite (WAL Mode)", "10,000+ reads/sec, Zero config", fill="#FFFFFF", outline="#2E7D32")

    draw.rounded_rectangle([580, 380, 920, 540], radius=8, fill="#FFF3E0", outline="#E65100", width=2)
    draw.text((600, 395), "LOCAL MEDIA STORAGE (SSD NVME)", font=F_BOLD, fill="#E65100")
    draw_box(draw, [610, 430, 890, 475], "Kho Video MP4 Full HD 1080p", "FFmpeg Optimized (+faststart)", fill="#FFFFFF", outline="#E65100")
    draw_box(draw, [610, 485, 890, 530], "Kho Ảnh Poster & Backdrop", "WebP / JPEG 2:3 & 16:9", fill="#FFFFFF", outline="#E65100")

    draw_arrow(draw, (220, 300), (340, 300), "HTTPS :443", color="#E50914", width=3)
    draw_arrow(draw, (520, 245), (580, 245), "Proxy Pass :8090", color="#2E7D32", width=2)
    draw_arrow(draw, (520, 460), (580, 460), "Direct Stream", color="#E65100", width=2)

    im.save(os.path.join(OUT_DIR, "D07_deployment_infrastructure.png"))
    print("✅ Đã tạo D07_deployment_infrastructure.png")

# 8. D08: ERD 8 COLLECTIONS
def make_d08():
    W, H = 1050, 680
    im = Image.new("RGB", (W, H), "#F8F9FA")
    draw = ImageDraw.Draw(im)
    draw_header(draw, W, "SƠ ĐỒ QUAN HỆ THỰC THỂ CƠ SỞ DỮ LIỆU (ERD SCHEMA)", "8 Collections Chuẩn Hóa 3NF trong SQLite nhúng của PocketBase")

    entities = [
        ("users", 50, 100, 250, 240, "#E3F2FD", "#1976D2", ["id (PK, text)", "email (text, unique)", "name (text)", "avatar (text)"]),
        ("profiles", 300, 100, 500, 240, "#E3F2FD", "#1976D2", ["id (PK, text)", "user_id (FK -> users)", "name (text)", "is_kids (bool)"]),
        ("movies", 550, 100, 770, 270, "#FFEBEE", "#E50914", ["id (PK, text)", "title (text)", "category (text)", "video_url (text)", "poster_url (text)", "is_featured (bool)"]),
        ("episodes", 820, 100, 1020, 250, "#FFEBEE", "#E50914", ["id (PK, text)", "movie_id (FK -> movies)", "season_num (int)", "episode_num (int)", "video_url (text)"]),
        ("watch_progress", 50, 330, 280, 490, "#FFF3E0", "#E65100", ["id (PK, text)", "user_id (FK -> users)", "movie_id (FK -> movies)", "position_sec (int)", "total_sec (int)"]),
        ("my_list", 320, 330, 520, 470, "#FFF3E0", "#E65100", ["id (PK, text)", "user_id (FK -> users)", "movie_id (FK -> movies)", "added_at (datetime)"]),
        ("reviews", 560, 330, 770, 480, "#E8F5E9", "#2E7D32", ["id (PK, text)", "user_id (FK -> users)", "movie_id (FK -> movies)", "rating (int: 1-5)", "comment (text)"]),
        ("feedback", 810, 330, 1020, 470, "#F3E5F5", "#7B1FA2", ["id (PK, text)", "user_id (FK -> users)", "topic (text)", "message (text)"]),
    ]

    for name, x0, y0, x1, y1, bg, border, attrs in entities:
        draw.rounded_rectangle([x0, y0, x1, y1], radius=6, fill=bg, outline=border, width=2)
        draw.rectangle([x0, y0, x1, y0 + 30], fill=border)
        draw.text((x0 + 10, y0 + 6), name.upper(), font=F_BOLD, fill="#FFFFFF")
        for idx, att in enumerate(attrs):
            draw.text((x0 + 10, y0 + 38 + idx * 20), "• " + att, font=F_CODE, fill="#212121")

    draw_arrow(draw, (250, 160), (300, 160), "1:N", color="#1976D2")
    draw_arrow(draw, (770, 160), (820, 160), "1:N", color="#E50914")
    draw_arrow(draw, (150, 240), (150, 330), "1:N", color="#E65100")
    draw_arrow(draw, (650, 270), (420, 330), "1:N", color="#E65100")
    draw_arrow(draw, (660, 270), (660, 330), "1:N", color="#2E7D32")

    im.save(os.path.join(OUT_DIR, "D08_erd_database_schema.png"))
    print("✅ Đã tạo D08_erd_database_schema.png")

# 9. D09: SEQUENCE GỌI API 4 BƯỚC
def make_d09():
    W, H = 1000, 580
    im = Image.new("RGB", (W, H), "#FFFFFF")
    draw = ImageDraw.Draw(im)
    draw_header(draw, W, "SƠ ĐỒ TUẦN TỰ: LUỒNG GỌI API 4 BƯỚC (MỤC 2.5)", "Luồng phân giải REST API giữa Client Flutter, Nginx, PocketBase và SQLite")

    participants = [
        ("Client Flutter", 120),
        ("Nginx Gateway", 380),
        ("PocketBase Service", 650),
        ("SQLite WAL Database", 890)
    ]

    for name, x in participants:
        draw_box(draw, [x - 85, 85, x + 85, 130], name, fill="#E3F2FD", outline="#003399", radius=6)
        draw.line([x, 130, x, 530], fill="#B0BEC5", width=1)

    steps = [
        (120, 380, 180, "Bước 1: GET /api/collections/movies/records (HTTPS)", "#003399"),
        (380, 650, 250, "Bước 2: Proxy Pass http://127.0.0.1:8090", "#1976D2"),
        (650, 890, 320, "Bước 3: SELECT * FROM movies WHERE is_featured=true", "#2E7D32"),
        (890, 650, 380, "Ghi nhận kết quả trong 12ms (WAL Mode)", "#2E7D32"),
        (650, 380, 440, "Đóng gói JSON Payload + Cache Headers", "#E65100"),
        (380, 120, 500, "Bước 4: Trả về Client HTTP 200 OK (Render Movie Feed)", "#E50914"),
    ]

    for x0, x1, y, text, col in steps:
        draw_arrow(draw, (x0, y), (x1, y), "", color=col, width=2)
        mx = (x0 + x1) / 2
        draw.text((mx, y - 8), text, font=F_SMALL, fill=col, anchor="mb")

    im.save(os.path.join(OUT_DIR, "D09_sequence_api_4steps.png"))
    print("✅ Đã tạo D09_sequence_api_4steps.png")

# 10. D10: PIPELINE FFMPEG +FASTSTART
def make_d10():
    W, H = 1000, 600
    im = Image.new("RGB", (W, H), "#F8F9FA")
    draw = ImageDraw.Draw(im)
    draw_header(draw, W, "QUY TRÌNH NÉN VÀ TỐI ƯU HÓA VIDEO FFMPEG PIPELINE", "Tiết kiệm 84.3% băng thông (3.5GB ➔ 550MB), khởi phát phát phim dưới 0.48s")

    steps = [
        ("1. VIDEO NGUYÊN BẢN", "Dung lượng: 3.5 GB\nBitrate: 15,000 kbps\nMoov Atom nằm cuối tệp\n(Load chậm, tốn RAM)", 40, 130, 220, 450, "#FFCDD2", "#C62828"),
        ("2. TIỀN XỬ LÝ FFMPEG", "ffmpeg -i input.mp4 \\\n -c:v libx264 -preset slow \\\n -crf 22 -c:a aac -b:a 128k \\\n -movflags +faststart \\\n output_1080p.mp4", 260, 130, 520, 450, "#E8EAF6", "#3F51B5"),
        ("3. TỐI ƯU MOOV ATOM", "Di chuyển Moov Atom\n(Metadata độ dài, codec)\nlên byte đầu tiên của file\n➔ Đọc tức thì chunk 64KB", 560, 130, 740, 450, "#FFF3E0", "#E65100"),
        ("4. KHO MEDIA PRODUCTION", "Dung lượng: 550 MB (-84.3%)\nBitrate: 2,500 kbps\nChuẩn AVC High@L4.0\nTime-to-first-frame: <0.48s", 780, 130, 960, 450, "#E8F5E9", "#2E7D32")
    ]

    for title, desc, x0, y0, x1, y1, bg, border in steps:
        draw.rounded_rectangle([x0, y0, x1, y1], radius=8, fill=bg, outline=border, width=2)
        draw.text((x0 + 12, y0 + 15), title, font=F_BOLD, fill=border)
        lines = desc.split("\n")
        for l_idx, line in enumerate(lines):
            draw.text((x0 + 12, y0 + 55 + l_idx * 24), line, font=F_CODE if "ffmpeg" in desc else F_SMALL, fill="#212121")

    draw_arrow(draw, (220, 290), (260, 290), "", color="#C62828", width=3)
    draw_arrow(draw, (520, 290), (560, 290), "", color="#3F51B5", width=3)
    draw_arrow(draw, (740, 290), (780, 290), "", color="#E65100", width=3)

    draw.rounded_rectangle([40, 490, 960, 560], radius=6, fill="#E3F2FD", outline="#1976D2", width=1)
    draw.text((60, 510), "KẾT QUẢ THỰC NGHIỆM: Giảm dung lượng từ 3.5GB xuống 550MB (tiết kiệm 84.3% lưu lượng), tốc độ Time-to-First-Frame đạt 0.38s trên mạng 4G Viettel.", font=F_BOLD, fill="#003399")

    im.save(os.path.join(OUT_DIR, "D10_media_ffmpeg_pipeline.png"))
    print("✅ Đã tạo D10_media_ffmpeg_pipeline.png")

# 11. D11: CI/CD WORKFLOW
def make_d11():
    W, H = 1000, 600
    im = Image.new("RGB", (W, H), "#F8F9FA")
    draw = ImageDraw.Draw(im)
    draw_header(draw, W, "QUY TRÌNH CI/CD GITHUB ACTIONS AUTOMATION", "3 Giai đoạn: Static Code Analysis ➔ Automated QA Testing ➔ Multi-Platform Release")

    stages = [
        ("STAGE 1: LINT & ANALYZE", "#E3F2FD", "#1976D2", 50, 130, 310, 430, [
            "Git Push / Pull Request", "Setup Flutter SDK 3.x", "flutter pub get", "flutter analyze (120+ rules)", "dart format --set-exit-if-changed"
        ]),
        ("STAGE 2: AUTOMATED QA", "#E8F5E9", "#2E7D32", 370, 130, 630, 430, [
            "Execute 129 Test Cases", "Unit Tests (Model/Repo)", "Widget Tests (Cards/Feed)", "Golden Screen Tests (42 screens)", "Generate Coverage Report"
        ]),
        ("STAGE 3: BUILD & DEPLOY", "#FFF3E0", "#E65100", 690, 130, 950, 430, [
            "Build Android Release APK", "Build Android App Bundle (AAB)", "Build Web Production Bundle", "Create GitHub Release v1.0.0", "Upload Artifacts (~32.4MB APK)"
        ])
    ]

    for title, bg, border, x0, y0, x1, y1, tasks in stages:
        draw.rounded_rectangle([x0, y0, x1, y1], radius=8, fill=bg, outline=border, width=2)
        draw.text((x0 + 12, y0 + 15), title, font=F_BOLD, fill=border)
        for t_idx, task in enumerate(tasks):
            ty = y0 + 55 + t_idx * 50
            draw_box(draw, [x0 + 10, ty, x1 - 10, ty + 38], task, "", fill="#FFFFFF", outline=border, radius=4)

    draw_arrow(draw, (310, 280), (370, 280), "Pass Lint", color="#1976D2", width=3)
    draw_arrow(draw, (630, 280), (690, 280), "129 Tests OK", color="#2E7D32", width=3)

    draw.rounded_rectangle([50, 480, 950, 550], radius=6, fill="#FFFFFF", outline="#003399", width=1)
    draw.text((70, 505), "ĐẢM BẢO CHẤT LƯỢNG (QUALITY GATE): Nếu bất kỳ bài kiểm thử nào thất bại hoặc sai lệch Golden Test, tiến trình Build lập tức bị dừng để bảo vệ nhánh main.", font=F_BOLD, fill="#C62828")

    im.save(os.path.join(OUT_DIR, "D11_cicd_github_actions.png"))
    print("✅ Đã tạo D11_cicd_github_actions.png")

# 12. D12: MA TRẬN PHÂN QUYỀN API RULES THEO 5 QUY TẮC POCKETBASE
def make_d12():
    W, H = 1000, 620
    im = Image.new("RGB", (W, H), "#F8F9FA")
    draw = ImageDraw.Draw(im)
    draw_header(draw, W, "MA TRẬN PHÂN QUYỀN API RULES (5 QUY TẮC POCKETBASE)", "List Rule, View Rule, Create Rule, Update Rule, Delete Rule trên 8 Collections")

    headers = ["Collection", "List Rule", "View Rule", "Create Rule", "Update Rule", "Delete Rule"]
    cols_x = [40, 190, 340, 490, 670, 830, 960]
    
    draw.rectangle([40, 100, 960, 140], fill="#003399")
    for idx, h in enumerate(headers):
        draw.text((cols_x[idx] + 8, 112), h, font=F_BOLD, fill="#FFFFFF")

    matrix = [
        ("movies", "Public (\"\")", "Public (\"\")", "Admin Only", "Admin Only", "Admin Only"),
        ("episodes", "Public (\"\")", "Public (\"\")", "Admin Only", "Admin Only", "Admin Only"),
        ("users", "Admin Only", "Auth (@request)", "Public (Reg)", "id=@request.auth.id", "id=@request.auth.id"),
        ("profiles", "user_id=@auth", "user_id=@auth", "user_id=@auth", "user_id=@auth", "user_id=@auth"),
        ("watch_progress", "user_id=@auth", "user_id=@auth", "user_id=@auth", "user_id=@auth", "user_id=@auth"),
        ("my_list", "user_id=@auth", "user_id=@auth", "user_id=@auth", "user_id=@auth", "user_id=@auth"),
        ("reviews", "Public (\"\")", "Public (\"\")", "@request.auth!=''", "user_id=@auth", "user_id=@auth / Admin"),
        ("feedback", "Admin Only", "Admin Only", "Public / Auth", "Admin Only", "Admin Only"),
    ]

    for r_idx, row in enumerate(matrix):
        ry = 140 + r_idx * 48
        bg = "#F8F9FA" if r_idx % 2 == 1 else "#FFFFFF"
        draw.rectangle([40, ry, 960, ry + 48], fill=bg, outline="#E0E0E0")
        for c_idx, val in enumerate(row):
            col = "#000000"
            if "Public" in val: col = "#2E7D32"
            elif "Admin" in val: col = "#003399"
            elif "@auth" in val or "Auth" in val: col = "#E65100"
            draw.text((cols_x[c_idx] + 8, ry + 14), val, font=F_BOLD if c_idx == 0 else F_SMALL, fill=col)

    draw.rounded_rectangle([40, 540, 960, 595], radius=6, fill="#E8F5E9", outline="#2E7D32", width=1)
    draw.text((60, 555), "BẢO MẬT BACKEND: Mọi request vi phạm API Rules đều bị PocketBase từ chối ngay lập tức với mã HTTP 403 Forbidden.", font=F_BOLD, fill="#2E7D32")

    im.save(os.path.join(OUT_DIR, "D12_api_rules_security.png"))
    print("✅ Đã tạo D12_api_rules_security.png")

if __name__ == "__main__":
    print("Bắt đầu sinh lại toàn bộ 12 ảnh sơ đồ chuẩn hóa...")
    make_d01()
    make_d02()
    make_d03()
    make_d04()
    make_d05()
    make_d06()
    make_d07()
    make_d08()
    make_d09()
    make_d10()
    make_d11()
    make_d12()
    print("==========================================")
    print("HOÀN THÀNH TOÀN BỘ 12 ẢNH SƠ ĐỒ CHUẨN ĐỒ HỌA HỌC THUẬT!")
    print(f"Lưu trữ tại: {OUT_DIR}")
    print("==========================================")
