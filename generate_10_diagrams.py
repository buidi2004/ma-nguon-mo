# -*- coding: utf-8 -*-
"""
Tự động tạo và biên dịch trọn vẹn 10/10 sơ đồ kiến trúc & phân tích thiết kế phần mềm OpenFlix
Đã giải quyết toàn bộ các ràng buộc về nhãn và vị trí tọa độ (Zero Overlap).
"""

import os
import json
import subprocess

OUT_DIR = ".archify/architecture-openflix-20261019-023500/suite"
os.makedirs(OUT_DIR, exist_ok=True)

# -----------------------------------------------------------------------------
# 1. ARCHITECTURE DIAGRAM (Fixed labels)
# -----------------------------------------------------------------------------
architecture_json = {
  "schema_version": 1,
  "diagram_type": "architecture",
  "meta": {
    "title": "OpenFlix 01: Kiến Trúc Hệ Thống Tổng Thể End-to-End (FE / BE / Realtime / Media)",
    "output": "suite/01_architecture.html",
    "quality_profile": "standard"
  },
  "components": [
    { "id": "client", "type": "external", "label": "Khách Xem Phim", "sublabel": "Thiết bị Android / Web", "pos": [30, 260], "size": [140, 60], "tag": "Mobile Client", "icon": "person" },
    { "id": "ui_shell", "type": "frontend", "label": "Flutter Client Engine", "sublabel": "GoRouter + 42 Màn Hình", "pos": [230, 150], "size": [160, 60], "tag": "S01 - S42", "icon": "frontend" },
    { "id": "player_engine", "type": "frontend", "label": "Trình Phát Video Chewie", "sublabel": "Gesture Tua ±10s & Fullscreen", "pos": [230, 260], "size": [160, 60], "tag": "VideoPlayer", "icon": "frontend" },
    { "id": "offline_cache", "type": "frontend", "label": "Bộ Nhớ Cục Bộ (Local)", "sublabel": "SharedPreferences & Mock Seed", "pos": [230, 370], "size": [160, 60], "tag": "Offline State", "icon": "database" },
    { "id": "nginx_proxy", "type": "backend", "label": "Nginx Reverse Proxy", "sublabel": "SSL Let's Encrypt / Gzip", "pos": [470, 210], "size": [150, 60], "tag": "Cổng Cân Bằng Tải", "icon": "backend" },
    { "id": "pocketbase", "type": "backend", "label": "PocketBase BaaS Engine", "sublabel": "Golang Daemon + Auth Rules", "pos": [680, 150], "size": [160, 60], "tag": "REST & SSE Realtime", "icon": "backend" },
    { "id": "sqlite_wal", "type": "database", "label": "SQLite WAL Database", "sublabel": "10 Collections Nhúng Siêu Nhanh", "pos": [920, 150], "size": [160, 60], "tag": "Zero Latency DB", "icon": "database" },
    { "id": "media_server", "type": "cloud", "label": "Linux Media Storage", "sublabel": "Chuẩn Hóa FFmpeg 1080p MP4", "pos": [680, 290], "size": [160, 60], "tag": "Byte-Range Streaming", "icon": "cloud" },
    { "id": "cdn_images", "type": "cloud", "label": "ImageKit Cloud CDN", "sublabel": "Phân Phối Poster & Backdrop WebP", "pos": [680, 410], "size": [160, 60], "tag": "Edge Cache", "icon": "cloud" },
    { "id": "cicd_pipeline", "type": "messagebus", "label": "GitHub Actions CI/CD", "sublabel": "129 Tests & Build Release APK", "pos": [470, 40], "size": [160, 54], "tag": "DevOps Pipeline", "icon": "messagebus" }
  ],
  "connections": [
    { "id": "c1", "from": "client", "to": "ui_shell" },
    { "id": "c2", "from": "ui_shell", "to": "player_engine" },
    { "id": "c3", "from": "ui_shell", "to": "offline_cache" },
    { "id": "c4", "from": "ui_shell", "to": "nginx_proxy", "label": "REST API" },
    { "id": "c5", "from": "nginx_proxy", "to": "pocketbase" },
    { "id": "c6", "from": "pocketbase", "to": "sqlite_wal" },
    { "id": "c7", "from": "player_engine", "to": "media_server", "label": "HTTP 206" },
    { "id": "c8", "from": "ui_shell", "to": "cdn_images" },
    { "id": "c9", "from": "cicd_pipeline", "to": "nginx_proxy" }
  ]
}

# -----------------------------------------------------------------------------
# 2. CLASS DIAGRAM (Clean Layered Architecture)
# -----------------------------------------------------------------------------
class_json = {
  "schema_version": 1,
  "diagram_type": "class",
  "meta": {
    "title": "OpenFlix 02: Sơ Đồ Lớp Kiến Trúc Phân Tầng (Clean Layered Architecture)",
    "subtitle": "Phân tách chặt chẽ giữa Models, Repositories, Services, Controllers và UI Presentation",
    "output": "suite/02_class_layers.html",
    "quality_profile": "standard"
  },
  "layout": { "mode": "grid", "gapX": 80, "gapY": 80 },
  "types": [
    {
      "id": "movie_model",
      "label": "MovieModel",
      "kind": "class",
      "sublabel": "Thực thể phim điện ảnh",
      "row": 0, "col": 0,
      "attributes": [
        { "name": "id", "type": "String", "visibility": "public" },
        { "name": "title", "type": "String", "visibility": "public" },
        { "name": "videoUrl", "type": "String", "visibility": "public" },
        { "name": "posterUrl", "type": "String", "visibility": "public" },
        { "name": "rating", "type": "double", "visibility": "public" },
        { "name": "isFeatured", "type": "bool", "visibility": "public" }
      ],
      "methods": [
        { "name": "fromJson", "parameters": "json: Map", "returns": "MovieModel", "visibility": "public" },
        { "name": "toJson", "returns": "Map<String, dynamic>", "visibility": "public" }
      ]
    },
    {
      "id": "i_movie_repo",
      "label": "IMovieRepository",
      "kind": "interface",
      "sublabel": "Hợp đồng trừu tượng dữ liệu",
      "row": 0, "col": 1,
      "methods": [
        { "name": "getMovies", "returns": "Future<List<MovieModel>>", "visibility": "public", "abstract": True },
        { "name": "getMovieById", "parameters": "id: String", "returns": "Future<MovieModel?>", "visibility": "public", "abstract": True },
        { "name": "searchMovies", "parameters": "query: String", "returns": "Future<List<MovieModel>>", "visibility": "public", "abstract": True }
      ]
    },
    {
      "id": "pocketbase_service",
      "label": "PocketBaseService",
      "kind": "class",
      "sublabel": "Triển khai Singleton giao tiếp Server",
      "row": 0, "col": 2,
      "attributes": [
        { "name": "pb", "type": "PocketBase", "visibility": "private" },
        { "name": "_instance", "type": "PocketBaseService", "visibility": "private" }
      ],
      "methods": [
        { "name": "getMovies", "returns": "Future<List<MovieModel>>", "visibility": "public" },
        { "name": "login", "parameters": "email, pass", "returns": "Future<bool>", "visibility": "public" },
        { "name": "saveProgress", "parameters": "movieId, sec", "returns": "Future<void>", "visibility": "public" }
      ]
    },
    {
      "id": "player_controller",
      "label": "PlayerController",
      "kind": "class",
      "sublabel": "Điều khiển trình phát Chewie",
      "row": 1, "col": 0,
      "attributes": [
        { "name": "videoController", "type": "VideoPlayerController", "visibility": "private" },
        { "name": "chewieController", "type": "ChewieController?", "visibility": "public" }
      ],
      "methods": [
        { "name": "initialize", "parameters": "url: String", "returns": "Future<void>", "visibility": "public" },
        { "name": "seekForward10", "returns": "void", "visibility": "public" },
        { "name": "seekBackward10", "returns": "void", "visibility": "public" }
      ]
    },
    {
      "id": "library_service",
      "label": "LibraryService",
      "kind": "class",
      "sublabel": "Quản lý Thư viện cá nhân",
      "row": 1, "col": 1,
      "attributes": [
        { "name": "myList", "type": "List<String>", "visibility": "private" },
        { "name": "likedMovies", "type": "List<String>", "visibility": "private" }
      ],
      "methods": [
        { "name": "toggleMyList", "parameters": "movieId: String", "returns": "void", "visibility": "public" },
        { "name": "isLiked", "parameters": "movieId: String", "returns": "bool", "visibility": "public" }
      ]
    },
    {
      "id": "home_screen",
      "label": "HomeScreen (S09)",
      "kind": "class",
      "sublabel": "Trang chủ hiển thị danh mục",
      "row": 1, "col": 2,
      "methods": [
        { "name": "build", "parameters": "context: BuildContext", "returns": "Widget", "visibility": "public" }
      ]
    }
  ],
  "relationships": [
    { "from": "pocketbase_service", "to": "i_movie_repo", "kind": "realization" },
    { "from": "pocketbase_service", "to": "movie_model", "kind": "dependency" },
    { "from": "home_screen", "to": "pocketbase_service", "kind": "association" },
    { "from": "player_controller", "to": "movie_model", "kind": "association" },
    { "from": "home_screen", "to": "library_service", "kind": "association" }
  ]
}

# -----------------------------------------------------------------------------
# 3. ERD DIAGRAM (PocketBase Database Schema)
# -----------------------------------------------------------------------------
erd_json = {
  "schema_version": 1,
  "diagram_type": "erd",
  "meta": {
    "title": "OpenFlix 03: Database Entity-Relationship Diagram (SQLite PocketBase)",
    "output": "suite/03_erd_database.html",
    "quality_profile": "standard",
    "locale": "en",
    "viewBox": [1400, 920],
    "legend": {
      "mode": "hidden"
    }
  },
  "layout": { "mode": "grid", "gapX": 90, "gapY": 70 },
  "entities": [
    {
      "id": "users", "label": "users", "tag": "Identity", "row": 0, "col": 0,
      "attributes": [
        { "name": "id", "type": "text", "key": "pk" },
        { "name": "email", "type": "text" },
        { "name": "name", "type": "text" },
        { "name": "avatar", "type": "text" }
      ]
    },
    {
      "id": "profiles", "label": "profiles", "tag": "Identity", "row": 0, "col": 1,
      "attributes": [
        { "name": "id", "type": "text", "key": "pk" },
        { "name": "user_id", "type": "text", "key": "fk", "references": "users.id" },
        { "name": "name", "type": "text" },
        { "name": "is_kids", "type": "bool" }
      ]
    },
    {
      "id": "movies", "label": "movies", "tag": "Catalog", "row": 1, "col": 0,
      "attributes": [
        { "name": "id", "type": "text", "key": "pk" },
        { "name": "title", "type": "text" },
        { "name": "category", "type": "text" },
        { "name": "video_url", "type": "text" },
        { "name": "poster_url", "type": "text" },
        { "name": "is_featured", "type": "bool" }
      ]
    },
    {
      "id": "episodes", "label": "episodes", "tag": "Catalog", "row": 1, "col": 1,
      "attributes": [
        { "name": "id", "type": "text", "key": "pk" },
        { "name": "movie_id", "type": "text", "key": "fk", "references": "movies.id" },
        { "name": "season_num", "type": "int" },
        { "name": "episode_num", "type": "int" },
        { "name": "video_url", "type": "text" }
      ]
    },
    {
      "id": "watch_progress", "label": "watch_progress", "tag": "Activity", "row": 2, "col": 0,
      "attributes": [
        { "name": "id", "type": "text", "key": "pk" },
        { "name": "user_id", "type": "text", "key": "fk", "references": "users.id" },
        { "name": "movie_id", "type": "text", "key": "fk", "references": "movies.id" },
        { "name": "position_sec", "type": "int" },
        { "name": "total_sec", "type": "int" }
      ]
    },
    {
      "id": "my_list", "label": "my_list", "tag": "Activity", "row": 2, "col": 1,
      "attributes": [
        { "name": "id", "type": "text", "key": "pk" },
        { "name": "user_id", "type": "text", "key": "fk", "references": "users.id" },
        { "name": "movie_id", "type": "text", "key": "fk", "references": "movies.id" },
        { "name": "added_at", "type": "datetime" }
      ]
    },
    {
      "id": "reviews", "label": "reviews", "tag": "Community", "row": 0, "col": 2,
      "attributes": [
        { "name": "id", "type": "text", "key": "pk" },
        { "name": "user_id", "type": "text", "key": "fk", "references": "users.id" },
        { "name": "movie_id", "type": "text", "key": "fk", "references": "movies.id" },
        { "name": "rating", "type": "int" },
        { "name": "comment", "type": "text" }
      ]
    },
    {
      "id": "feedback", "label": "feedback", "tag": "Community", "row": 1, "col": 2,
      "attributes": [
        { "name": "id", "type": "text", "key": "pk" },
        { "name": "user_id", "type": "text", "key": "fk", "references": "users.id" },
        { "name": "topic", "type": "text" },
        { "name": "message", "type": "text" }
      ]
    }
  ],
  "relationships": [
    { "from": "users", "to": "profiles", "fromCardinality": "one", "toCardinality": "many" },
    { "from": "movies", "to": "episodes", "fromCardinality": "one", "toCardinality": "many" },
    { "from": "users", "to": "watch_progress", "fromCardinality": "one", "toCardinality": "many" },
    { "from": "movies", "to": "watch_progress", "fromCardinality": "one", "toCardinality": "many" },
    { "from": "users", "to": "my_list", "fromCardinality": "one", "toCardinality": "many" },
    { "from": "movies", "to": "my_list", "fromCardinality": "one", "toCardinality": "many" },
    { "from": "users", "to": "reviews", "fromCardinality": "one", "toCardinality": "many" },
    { "from": "movies", "to": "reviews", "fromCardinality": "one", "toCardinality": "many" },
    { "from": "users", "to": "feedback", "fromCardinality": "one", "toCardinality": "many" }
  ]
}

# -----------------------------------------------------------------------------
# 4. SEQUENCE DIAGRAM: AUTH & DEMO LOGIN
# -----------------------------------------------------------------------------
seq_auth_json = {
  "schema_version": 1,
  "diagram_type": "sequence",
  "meta": {
    "title": "OpenFlix 04: Sơ Đồ Tuần Tự Xác Thực & Đăng Nhập 1-Click Demo",
    "output": "suite/04_sequence_auth.html",
    "quality_profile": "standard",
    "viewBox": [1080, 560],
    "column_fit": "spread"
  },
  "participants": [
    { "id": "user", "type": "external", "label": "Người Dùng", "sublabel": "S04 LoginScreen" },
    { "id": "ui", "type": "frontend", "label": "Flutter UI", "sublabel": "Form Validation" },
    { "id": "service", "type": "frontend", "label": "PocketBaseService", "sublabel": "Singleton Auth" },
    { "id": "nginx", "type": "backend", "label": "Nginx Proxy", "sublabel": "SSL HTTPS 443" },
    { "id": "pb", "type": "backend", "label": "PocketBase", "sublabel": "Auth Collection" },
    { "id": "db", "type": "database", "label": "SQLite WAL", "sublabel": "Users Storage" }
  ],
  "messages": [
    { "id": "m1", "from": "user", "to": "ui", "y": 160, "label": "1. Nhấn nút '1-Click Đăng Nhập Demo'", "variant": "default" },
    { "id": "m2", "from": "ui", "to": "service", "y": 190, "label": "2. authWithPassword(demo@openflix.vn)", "variant": "emphasis" },
    { "id": "m3", "from": "service", "to": "nginx", "y": 220, "label": "3. POST /api/collections/users/auth-with-password", "variant": "emphasis" },
    { "id": "m4", "from": "nginx", "to": "pb", "y": 250, "label": "4. Proxy pass upstream 127.0.0.1:8090", "variant": "default" },
    { "id": "m5", "from": "pb", "to": "db", "y": 280, "label": "5. Query user by email & verify bcrypt", "variant": "default" },
    { "id": "m6", "from": "db", "to": "pb", "y": 310, "label": "6. Trả về bản ghi user hợp lệ", "variant": "return" },
    { "id": "m7", "from": "pb", "to": "nginx", "y": 340, "label": "7. Sinh JWT Auth Token + User Model", "variant": "return" },
    { "id": "m8", "from": "nginx", "to": "service", "y": 370, "label": "8. HTTP 200 OK (AuthStore Updated)", "variant": "return" },
    { "id": "m9", "from": "service", "to": "ui", "y": 400, "label": "9. Cập nhật AuthState thành công", "variant": "return" },
    { "id": "m10", "from": "ui", "to": "user", "y": 430, "label": "10. Chuyển hướng tới Trang Chủ (S09)", "variant": "emphasis" }
  ]
}

# -----------------------------------------------------------------------------
# 5. SEQUENCE DIAGRAM: STREAMING & SEEK
# -----------------------------------------------------------------------------
seq_stream_json = {
  "schema_version": 1,
  "diagram_type": "sequence",
  "meta": {
    "title": "OpenFlix 05: Sơ Đồ Tuần Tự Phát Phim 1080p & Tua Nhanh HTTP Byte-Range",
    "output": "suite/05_sequence_streaming.html",
    "quality_profile": "standard",
    "viewBox": [1080, 560],
    "column_fit": "spread"
  },
  "participants": [
    { "id": "user", "type": "external", "label": "Khách Xem", "sublabel": "S18 DetailScreen" },
    { "id": "player_ui", "type": "frontend", "label": "Chewie Player (S20)", "sublabel": "Gesture ±10s" },
    { "id": "controller", "type": "frontend", "label": "VideoController", "sublabel": "Native Engine" },
    { "id": "nginx", "type": "backend", "label": "Nginx Media Proxy", "sublabel": "Byte-Range Support" },
    { "id": "media", "type": "cloud", "label": "Linux Storage", "sublabel": "FFmpeg MP4 Faststart" },
    { "id": "pb", "type": "backend", "label": "PocketBase API", "sublabel": "watch_progress" }
  ],
  "messages": [
    { "id": "m1", "from": "user", "to": "player_ui", "y": 160, "label": "1. Nhấn nút 'Phát Phim'", "variant": "default" },
    { "id": "m2", "from": "player_ui", "to": "controller", "y": 190, "label": "2. initialize(videoUrl)", "variant": "emphasis" },
    { "id": "m3", "from": "controller", "to": "nginx", "y": 220, "label": "3. GET Range: bytes=0-1048576 (Moov atom)", "variant": "emphasis" },
    { "id": "m4", "from": "nginx", "to": "media", "y": 250, "label": "4. Đọc 1MB đầu tệp MP4 FastStart", "variant": "default" },
    { "id": "m5", "from": "media", "to": "nginx", "y": 280, "label": "5. Trả về luồng byte video", "variant": "return" },
    { "id": "m6", "from": "nginx", "to": "controller", "y": 310, "label": "6. HTTP 206 Partial Content (0.5s)", "variant": "return" },
    { "id": "m7", "from": "controller", "to": "player_ui", "y": 340, "label": "7. Frame đầu tiên xuất hiện (60fps)", "variant": "return" },
    { "id": "m8", "from": "user", "to": "player_ui", "y": 370, "label": "8. Double-tap phải tua nhanh +10s", "variant": "emphasis" },
    { "id": "m9", "from": "player_ui", "to": "controller", "y": 400, "label": "9. seekTo(position + 10s)", "variant": "default" },
    { "id": "m10", "from": "player_ui", "to": "pb", "y": 430, "label": "10. Lưu mốc xem dở vào watch_progress", "variant": "emphasis" }
  ]
}

# -----------------------------------------------------------------------------
# 6. LIFECYCLE DIAGRAM: VIDEO PLAYER
# -----------------------------------------------------------------------------
lifecycle_player_json = {
  "schema_version": 3,
  "diagram_type": "lifecycle",
  "meta": {
    "title": "OpenFlix 06: Sơ Đồ Vòng Đời Trạng Thái Trình Phát Video (Chewie Lifecycle)",
    "output": "suite/06_lifecycle_player.html",
    "animation": "trace",
    "visual_preset": "signal-flow",
    "quality_profile": "standard"
  },
  "mainPath": ["idle", "initializing", "ready", "playing", "completed"],
  "states": [
    { "id": "idle", "type": "start", "label": "Khởi Tạo (Idle)", "sublabel": "Gán videoUrl", "tag": "init", "step": "01" },
    { "id": "initializing", "type": "active", "label": "Nạp Moov Atom", "sublabel": "Tải đệm 1MB đầu", "tag": "buffering", "step": "02" },
    { "id": "ready", "type": "decision", "label": "Sẵn Sàng (Ready)", "sublabel": "Khóa tỷ lệ khung hình", "tag": "ready", "step": "03" },
    { "id": "playing", "type": "success", "label": "Đang Phát (60fps)", "sublabel": "Render phần cứng", "tag": "playing", "step": "04" },
    { "id": "paused", "type": "waiting", "label": "Tạm Dừng (Paused)", "sublabel": "Giữ texture trong RAM", "tag": "pause" },
    { "id": "seeking", "type": "active", "label": "Đang Tua (Seeking)", "sublabel": "Cử chỉ chạm ±10s", "tag": "seek" },
    { "id": "buffering", "type": "waiting", "label": "Chờ Mạng (Buffering)", "sublabel": "Tải tiếp byte-range", "tag": "wait" },
    { "id": "completed", "type": "success", "label": "Xem Xong (Ended)", "sublabel": "Tự phát tập tiếp", "tag": "terminal", "step": "05" },
    { "id": "error", "type": "failure", "label": "Lỗi Phát (Error)", "sublabel": "Đổi sang link dự phòng", "tag": "terminal" }
  ],
  "transitions": [
    { "id": "t1", "from": "idle", "to": "initializing", "label": "initialize()" },
    { "id": "t2", "from": "initializing", "to": "ready", "label": "header ok" },
    { "id": "t3", "from": "ready", "to": "playing", "label": "play()" },
    { "id": "t4", "from": "playing", "to": "paused", "label": "user tap pause" },
    { "id": "t5", "from": "paused", "to": "playing", "label": "user tap play" },
    { "id": "t6", "from": "playing", "to": "seeking", "label": "double tap ±10s" },
    { "id": "t7", "from": "seeking", "to": "playing", "label": "seek completed" },
    { "id": "t8", "from": "playing", "to": "buffering", "label": "mạng chậm" },
    { "id": "t9", "from": "buffering", "to": "playing", "label": "buffer ready" },
    { "id": "t10", "from": "playing", "to": "completed", "label": "hết phim" },
    { "id": "t11", "from": "initializing", "to": "error", "label": "link chết / 404", "variant": "security" }
  ]
}

# -----------------------------------------------------------------------------
# 7. DESIGN PATTERNS CLASS DIAGRAM
# -----------------------------------------------------------------------------
patterns_json = {
  "schema_version": 1,
  "diagram_type": "class",
  "meta": {
    "title": "OpenFlix 07: Sơ Đồ Các Mẫu Thiết Kế Phần Mềm (Core Design Patterns)",
    "subtitle": "Hiện thực hóa Repository, Singleton, Adapter và Observer Pattern",
    "output": "suite/07_design_patterns.html",
    "quality_profile": "standard"
  },
  "layout": { "mode": "grid" },
  "types": [
    {
      "id": "i_repo", "label": "IMovieRepository", "kind": "interface",
      "sublabel": "Repository Pattern", "row": 0, "col": 0,
      "methods": [
        { "name": "fetchCatalog", "returns": "List<Movie>", "abstract": True }
      ]
    },
    {
      "id": "pb_repo", "label": "PocketBaseMovieRepo", "kind": "class",
      "sublabel": "Remote Data Source", "row": 1, "col": 0,
      "methods": [
        { "name": "fetchCatalog", "returns": "HTTP REST" }
      ]
    },
    {
      "id": "mock_repo", "label": "MockOfflineMovieRepo", "kind": "class",
      "sublabel": "Offline Fallback Source", "row": 1, "col": 1,
      "methods": [
        { "name": "fetchCatalog", "returns": "Asset Seed JSON" }
      ]
    },
    {
      "id": "singleton_pb", "label": "PocketBaseClient", "kind": "class",
      "sublabel": "Singleton Pattern", "row": 0, "col": 2,
      "attributes": [
        { "name": "_instance", "type": "PocketBaseClient", "visibility": "private" }
      ],
      "methods": [
        { "name": "getInstance", "returns": "PocketBaseClient", "visibility": "public" }
      ]
    },
    {
      "id": "player_adapter", "label": "VideoPlayerAdapter", "kind": "class",
      "sublabel": "Adapter / Factory Pattern", "row": 1, "col": 2,
      "methods": [
        { "name": "createController", "parameters": "url", "returns": "ChewieController" }
      ]
    }
  ],
  "relationships": [
    { "from": "pb_repo", "to": "i_repo", "kind": "realization", "label": "implements" },
    { "from": "mock_repo", "to": "i_repo", "kind": "realization", "label": "implements" },
    { "from": "pb_repo", "to": "singleton_pb", "kind": "dependency", "label": "uses" }
  ]
}

# -----------------------------------------------------------------------------
# 8. WORKFLOW: CI/CD PIPELINE
# -----------------------------------------------------------------------------
cicd_workflow_json = {
  "schema_version": 2,
  "diagram_type": "workflow",
  "meta": {
    "title": "OpenFlix 08: Quy Trình Tự Động Hóa CI/CD GitHub Actions",
    "animation": "trace",
    "visual_preset": "signal-flow",
    "quality_profile": "standard",
    "output": "suite/08_cicd_workflow.html"
  },
  "lanes": [
    { "id": "code", "label": "Kho Mã Nguồn (GitHub)" },
    { "id": "ci", "label": "Kiểm Thử & Đóng Gói (Runner)" },
    { "id": "deploy", "label": "Phát Hành & Máy Chủ VPS" }
  ],
  "nodes": [
    { "id": "git_push", "lane": "code", "col": 0, "type": "external", "label": "Git Push main", "sublabel": "Kỹ sư commit mã nguồn" },
    { "id": "lint_check", "lane": "ci", "col": 1, "type": "backend", "label": "Dart Analyze", "sublabel": "Kiểm tra lỗi cú pháp lints" },
    { "id": "unit_test", "lane": "ci", "col": 2, "type": "backend", "label": "129 Tests Suite", "sublabel": "Chạy Unit & Widget Test" },
    { "id": "build_apk", "lane": "ci", "col": 3, "type": "backend", "label": "Build Release APK", "sublabel": "Ký chứng chỉ số Keystore" },
    { "id": "github_rel", "lane": "deploy", "col": 4, "type": "cloud", "label": "GitHub Release v6.0.0", "sublabel": "Tải lên tệp APK Artifact" },
    { "id": "vps_deploy", "lane": "deploy", "col": 5, "type": "cloud", "label": "Deploy Linux VPS", "sublabel": "Tải Docker Container mới" }
  ],
  "edges": [
    { "id": "e1", "from": "git_push", "to": "lint_check" },
    { "id": "e2", "from": "lint_check", "to": "unit_test", "label": "Lint Passed" },
    { "id": "e3", "from": "unit_test", "to": "build_apk", "label": "100% Tests Passed" },
    { "id": "e4", "from": "build_apk", "to": "github_rel", "label": "APK Created" },
    { "id": "e5", "from": "github_rel", "to": "vps_deploy", "label": "Trigger Webhook" }
  ]
}

# -----------------------------------------------------------------------------
# 9. TREE DIAGRAM: MODULE HIERARCHY
# -----------------------------------------------------------------------------
tree_json = {
  "schema_version": 1,
  "diagram_type": "tree",
  "meta": {
    "title": "OpenFlix 09: Cấu Trúc Phân Rã Module Hệ Thống (Component Tree)",
    "output": "suite/09_module_tree.html",
    "quality_profile": "standard"
  },
  "nodes": [
    { "id": "root", "label": "OpenFlix Flutter Project (v6.0.0)", "sublabel": "Clean Architecture Monorepo" },
    { "id": "core", "label": "lib/core", "parent": "root", "sublabel": "Nền tảng dùng chung" },
    { "id": "router", "label": "router (GoRouter)", "parent": "core", "sublabel": "42 Routes ánh xạ S01-S42" },
    { "id": "theme", "label": "theme (Netflix Dark)", "parent": "core", "sublabel": "Màu #141414, #E50914" },
    { "id": "widgets", "label": "widgets (Shared)", "parent": "core", "sublabel": "AppBottomNav, MovieCard" },
    { "id": "features", "label": "lib/features", "parent": "root", "sublabel": "6 Module Nghiệp vụ" },
    { "id": "auth", "label": "auth (S01-S06)", "parent": "features", "sublabel": "Splash, Login, Register" },
    { "id": "discover", "label": "discover (S09-S17)", "parent": "features", "sublabel": "Home, Search, Genres" },
    { "id": "watch", "label": "watch (S18-S24)", "parent": "features", "sublabel": "Detail, Player, Reviews" },
    { "id": "library", "label": "library (S25-S29)", "parent": "features", "sublabel": "MyList, WatchHistory" },
    { "id": "account", "label": "account (S30-S38, S42)", "parent": "features", "sublabel": "Me, Settings, Plans" },
    { "id": "system", "label": "system (S39-S41)", "parent": "features", "sublabel": "Offline, Error, 404" },
    { "id": "services", "label": "lib/services", "parent": "root", "sublabel": "Tầng giao tiếp dữ liệu" },
    { "id": "pb_svc", "label": "PocketBaseService", "parent": "services", "sublabel": "REST API & SSE Auth" },
    { "id": "lib_svc", "label": "LibraryService", "parent": "services", "sublabel": "Đồng bộ Thư viện cá nhân" }
  ]
}

# -----------------------------------------------------------------------------
# 10. ARCHITECTURE DIAGRAM 2: MEDIA OPTIMIZATION PIPELINE
# -----------------------------------------------------------------------------
media_pipeline_json = {
  "schema_version": 1,
  "diagram_type": "architecture",
  "meta": {
    "title": "OpenFlix 10: Quy Trình Xử Lý & Truyền Dẫn Media Tự Chủ Linux (FFmpeg Pipeline)",
    "output": "suite/10_media_pipeline.html",
    "quality_profile": "standard"
  },
  "components": [
    { "id": "raw_video", "type": "database", "label": "Video Gốc 4K/FullHD", "sublabel": "3.5GB - 4.5GB Dung Lượng Lớn", "pos": [30, 200], "size": [150, 60], "tag": "Đầu Vào", "icon": "database" },
    { "id": "ffmpeg_worker", "type": "backend", "label": "FFmpeg Transcoder", "sublabel": "H.264 CRF 24 + AAC 128kbps", "pos": [260, 200], "size": [160, 60], "tag": "Chuẩn Hóa", "icon": "backend" },
    { "id": "faststart_opt", "type": "backend", "label": "Tối Ưu Moov Atom", "sublabel": "+faststart Đặt Đầu Tệp", "pos": [490, 200], "size": [160, 60], "tag": "Instant Play", "icon": "backend" },
    { "id": "linux_media", "type": "cloud", "label": "Máy Chủ Media Linux", "sublabel": "Tệp 550MB Chuẩn Mobile", "pos": [720, 200], "size": [160, 60], "tag": "Lưu Trữ Tự Chủ", "icon": "cloud" },
    { "id": "nginx_streamer", "type": "backend", "label": "Nginx Byte-Range", "sublabel": "Phản Hồi HTTP 206 Partial", "pos": [720, 330], "size": [160, 60], "tag": "Truyền Dẫn", "icon": "backend" },
    { "id": "flutter_player", "type": "frontend", "label": "Flutter Chewie Player", "sublabel": "Bắt Đầu Phát Trong 0.5 Giây", "pos": [380, 330], "size": [170, 60], "tag": "Thiết Bị Người Xem", "icon": "frontend" }
  ],
  "connections": [
    { "id": "m1", "from": "raw_video", "to": "ffmpeg_worker" },
    { "id": "m2", "from": "ffmpeg_worker", "to": "faststart_opt" },
    { "id": "m3", "from": "faststart_opt", "to": "linux_media" },
    { "id": "m4", "from": "linux_media", "to": "nginx_streamer" },
    { "id": "m5", "from": "nginx_streamer", "to": "flutter_player", "label": "Byte-Range" }
  ]
}

# -----------------------------------------------------------------------------
# BIÊN DỊCH BỘ 10 SƠ ĐỒ
# -----------------------------------------------------------------------------
diagrams = [
  ("architecture", "01_architecture", architecture_json),
  ("class", "02_class_layers", class_json),
  ("erd", "03_erd_database", erd_json),
  ("sequence", "04_sequence_auth", seq_auth_json),
  ("sequence", "05_sequence_streaming", seq_stream_json),
  ("lifecycle", "06_lifecycle_player", lifecycle_player_json),
  ("class", "07_design_patterns", patterns_json),
  ("workflow", "08_cicd_workflow", cicd_workflow_json),
  ("tree", "09_module_tree", tree_json),
  ("architecture", "10_media_pipeline", media_pipeline_json)
]

print("Bắt đầu tạo và biên dịch trọn vẹn bộ 10 sơ đồ Archify...")

success_count = 0
results = []

for dtype, name, jdata in diagrams:
    json_path = os.path.join(OUT_DIR, f"{name}.json")
    html_path = os.path.join(OUT_DIR, f"{name}.html")
    
    with open(json_path, "w", encoding="utf-8") as f:
        json.dump(jdata, f, indent=2, ensure_ascii=False)
        
    cmd = ["node", ".agent/skills/archify/bin/archify.mjs", "render", dtype, json_path, html_path]
    res = subprocess.run(cmd, capture_output=True, text=True)
    if res.returncode == 0:
        print(f"✅ [{dtype:12}] {name}.html thành công!")
        success_count += 1
        results.append((dtype, name, html_path, jdata["meta"]["title"]))
    else:
        print(f"❌ [{dtype:12}] Lỗi biên dịch {name}:", res.stderr)

print(f"\n==========================================")
print(f"KẾT QUẢ: Hoàn thành {success_count}/10 sơ đồ tương tác!")
print(f"Thư mục lưu trữ: {OUT_DIR}")
print(f"==========================================")
