# -*- coding: utf-8 -*-
import os

html_content = """<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>OpenFlix Architecture & Design Portal — 10 Sơ Đồ Phân Tích Thiết Kế Toàn Diện</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&family=JetBrains+Mono:wght@400;500;600&display=swap" rel="stylesheet">
  <style>
    :root {
      --bg-dark: #141414;
      --bg-card: #181818;
      --bg-card-elevated: #242424;
      --bg-nav: rgba(20, 20, 20, 0.95);
      --border-color: #2e2e2e;
      --brand-red: #E50914;
      --brand-red-hover: #b80710;
      --brand-green: #46D369;
      --brand-blue: #0071EB;
      --text-primary: #FFFFFF;
      --text-secondary: #B3B3B3;
      --text-muted: #737373;
      --sidebar-width: 320px;
    }

    * {
      box-sizing: border-box;
      margin: 0;
      padding: 0;
    }

    body {
      font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      background-color: var(--bg-dark);
      color: var(--text-primary);
      min-height: 100vh;
      display: flex;
      flex-direction: column;
      overflow-x: hidden;
    }

    /* Top Brand Header */
    header.portal-header {
      background: var(--bg-nav);
      backdrop-filter: blur(12px);
      border-bottom: 1px solid var(--border-color);
      position: sticky;
      top: 0;
      z-index: 100;
      padding: 12px 24px;
      display: flex;
      justify-content: space-between;
      align-items: center;
    }

    .brand-group {
      display: flex;
      align-items: center;
      gap: 16px;
    }

    .brand-logo {
      font-size: 24px;
      font-weight: 900;
      letter-spacing: -0.5px;
      color: var(--brand-red);
      text-transform: uppercase;
      display: flex;
      align-items: center;
      gap: 8px;
    }

    .brand-logo span {
      background: var(--brand-red);
      color: #fff;
      font-size: 11px;
      font-weight: 700;
      padding: 2px 6px;
      border-radius: 4px;
      letter-spacing: 0.5px;
    }

    .header-titles h1 {
      font-size: 15px;
      font-weight: 700;
      color: var(--text-primary);
      line-height: 1.2;
    }

    .header-titles p {
      font-size: 12px;
      color: var(--text-secondary);
      font-weight: 400;
    }

    .header-actions {
      display: flex;
      align-items: center;
      gap: 12px;
    }

    .btn {
      display: inline-flex;
      align-items: center;
      gap: 6px;
      font-size: 13px;
      font-weight: 600;
      padding: 8px 14px;
      border-radius: 6px;
      border: 1px solid transparent;
      cursor: pointer;
      text-decoration: none;
      transition: all 0.2s ease;
    }

    .btn-red {
      background-color: var(--brand-red);
      color: #fff;
    }

    .btn-red:hover {
      background-color: var(--brand-red-hover);
    }

    .btn-secondary {
      background-color: var(--bg-card-elevated);
      color: var(--text-primary);
      border-color: var(--border-color);
    }

    .btn-secondary:hover {
      background-color: #333333;
      border-color: #444;
    }

    /* Layout Body */
    .portal-body {
      display: flex;
      flex: 1;
      height: calc(100vh - 61px);
    }

    /* Sidebar Navigation */
    aside.portal-sidebar {
      width: var(--sidebar-width);
      background-color: var(--bg-card);
      border-right: 1px solid var(--border-color);
      display: flex;
      flex-direction: column;
      overflow-y: auto;
      flex-shrink: 0;
    }

    .sidebar-header {
      padding: 16px 20px 8px;
    }

    .sidebar-header h2 {
      font-size: 11px;
      text-transform: uppercase;
      letter-spacing: 1px;
      color: var(--text-muted);
      font-weight: 700;
    }

    .nav-category {
      padding: 8px 0;
    }

    .category-title {
      font-size: 11px;
      font-weight: 700;
      text-transform: uppercase;
      color: var(--text-muted);
      padding: 8px 20px 4px;
      letter-spacing: 0.5px;
    }

    .nav-list {
      list-style: none;
    }

    .nav-item {
      padding: 10px 20px;
      display: flex;
      align-items: flex-start;
      gap: 12px;
      cursor: pointer;
      border-left: 3px solid transparent;
      transition: all 0.15s ease;
    }

    .nav-item:hover {
      background-color: rgba(255, 255, 255, 0.04);
    }

    .nav-item.active {
      background-color: rgba(229, 9, 20, 0.08);
      border-left-color: var(--brand-red);
    }

    .nav-num {
      font-family: 'JetBrains Mono', monospace;
      font-size: 11px;
      font-weight: 700;
      background: var(--bg-card-elevated);
      padding: 2px 6px;
      border-radius: 4px;
      color: var(--text-secondary);
      flex-shrink: 0;
      margin-top: 2px;
    }

    .nav-item.active .nav-num {
      background: var(--brand-red);
      color: #fff;
    }

    .nav-content {
      flex: 1;
    }

    .nav-title {
      font-size: 13px;
      font-weight: 600;
      color: var(--text-secondary);
      line-height: 1.3;
    }

    .nav-item.active .nav-title {
      color: var(--text-primary);
    }

    .nav-tag {
      font-size: 10px;
      color: var(--text-muted);
      margin-top: 3px;
      font-weight: 500;
    }

    /* Main View Area */
    main.portal-main {
      flex: 1;
      display: flex;
      flex-direction: column;
      overflow-y: auto;
      background-color: var(--bg-dark);
    }

    .toolbar-bar {
      padding: 14px 24px;
      background-color: var(--bg-card);
      border-bottom: 1px solid var(--border-color);
      display: flex;
      justify-content: space-between;
      align-items: center;
      flex-wrap: wrap;
      gap: 12px;
    }

    .toolbar-left h2 {
      font-size: 18px;
      font-weight: 700;
      display: flex;
      align-items: center;
      gap: 10px;
    }

    .badge-type {
      font-size: 11px;
      font-family: 'JetBrains Mono', monospace;
      font-weight: 600;
      padding: 3px 8px;
      border-radius: 4px;
      text-transform: uppercase;
      background-color: rgba(0, 113, 235, 0.15);
      color: #4da3ff;
      border: 1px solid rgba(0, 113, 235, 0.3);
    }

    .badge-type.arch { background: rgba(70, 211, 105, 0.15); color: #46D369; border-color: rgba(70, 211, 105, 0.3); }
    .badge-type.class { background: rgba(229, 9, 20, 0.15); color: #ff5e65; border-color: rgba(229, 9, 20, 0.3); }
    .badge-type.erd { background: rgba(255, 170, 0, 0.15); color: #ffba3b; border-color: rgba(255, 170, 0, 0.3); }
    .badge-type.seq { background: rgba(168, 85, 247, 0.15); color: #c084fc; border-color: rgba(168, 85, 247, 0.3); }

    .toolbar-left p {
      font-size: 13px;
      color: var(--text-secondary);
      margin-top: 4px;
    }

    .toolbar-right {
      display: flex;
      align-items: center;
      gap: 8px;
    }

    /* Diagram Frame Container */
    .diagram-frame-wrapper {
      flex: 1;
      min-height: 580px;
      padding: 16px 24px;
      display: flex;
      flex-direction: column;
    }

    .iframe-box {
      flex: 1;
      width: 100%;
      min-height: 620px;
      border: 1px solid var(--border-color);
      border-radius: 8px;
      overflow: hidden;
      background-color: #0d0d0d;
      box-shadow: 0 12px 36px rgba(0, 0, 0, 0.5);
      position: relative;
    }

    .iframe-box iframe {
      width: 100%;
      height: 100%;
      border: none;
      display: block;
    }

    /* Explanation Deep Dive Panel */
    .deep-dive-panel {
      padding: 24px;
      background-color: var(--bg-card);
      border-top: 1px solid var(--border-color);
      margin-top: 16px;
    }

    .deep-dive-header {
      font-size: 15px;
      font-weight: 700;
      margin-bottom: 12px;
      color: var(--brand-red);
      display: flex;
      align-items: center;
      gap: 8px;
    }

    .deep-dive-text {
      font-size: 13.5px;
      line-height: 1.65;
      color: var(--text-secondary);
    }

    .deep-dive-text strong {
      color: #fff;
    }

    .key-points-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
      gap: 16px;
      margin-top: 16px;
    }

    .key-card {
      background: var(--bg-card-elevated);
      border: 1px solid var(--border-color);
      border-radius: 6px;
      padding: 14px 16px;
    }

    .key-card h4 {
      font-size: 13px;
      font-weight: 700;
      color: #fff;
      margin-bottom: 6px;
      display: flex;
      align-items: center;
      gap: 6px;
    }

    .key-card p {
      font-size: 12px;
      color: var(--text-secondary);
      line-height: 1.5;
    }

    /* Footer info */
    footer.portal-footer {
      padding: 16px 24px;
      font-size: 12px;
      color: var(--text-muted);
      border-top: 1px solid var(--border-color);
      display: flex;
      justify-content: space-between;
      align-items: center;
      background-color: var(--bg-card);
    }

    /* Responsive */
    @media (max-width: 900px) {
      .portal-body {
        flex-direction: column;
        height: auto;
      }
      aside.portal-sidebar {
        width: 100%;
        max-height: 240px;
      }
    }
  </style>
</head>
<body>

  <!-- Header -->
  <header class="portal-header">
    <div class="brand-group">
      <div class="brand-logo">
        OPENFLIX <span>SYSTEM ARCH</span>
      </div>
      <div class="header-titles">
        <h1>TRUNG TÂM PHÂN TÍCH THIẾT KẾ & KIẾN TRÚC HỆ THỐNG</h1>
        <p>Học phần Phát Triển Mã Nguồn Mở — Trường Đại Học Đồng Tháp — Nhóm 6</p>
      </div>
    </div>
    <div class="header-actions">
      <a href="../../BAO_CAO_NHOM_6_FINAL_ACADEMIC.docx" class="btn btn-red" title="Tải toàn bộ Báo cáo Học thuật Word">
        📄 Tải Báo Cáo Word
      </a>
      <a href="https://github.com/buidi2004/ma-nguon-mo" target="_blank" class="btn btn-secondary" title="Xem GitHub Repository">
        ⭐ GitHub Repo
      </a>
    </div>
  </header>

  <!-- Layout Body -->
  <div class="portal-body">
    
    <!-- Sidebar Navigation -->
    <aside class="portal-sidebar">
      <div class="sidebar-header">
        <h2>Danh mục 10 Sơ Đồ Thiết Kế</h2>
      </div>

      <!-- Nhóm 1 -->
      <div class="nav-category">
        <div class="category-title">1. Kiến Trúc Phân Tầng & Phân Rã</div>
        <ul class="nav-list">
          <li class="nav-item active" onclick="switchDiagram(0)">
            <span class="nav-num">01</span>
            <div class="nav-content">
              <div class="nav-title">Kiến Trúc Tổng Thể Full-Stack</div>
              <div class="nav-tag">4 Tầng: Client, Gateway, BaaS, Storage</div>
            </div>
          </li>
          <li class="nav-item" onclick="switchDiagram(8)">
            <span class="nav-num">09</span>
            <div class="nav-content">
              <div class="nav-title">Cây Phân Rã Clean Architecture</div>
              <div class="nav-tag">Domain, Data, Presentation, Core</div>
            </div>
          </li>
          <li class="nav-item" onclick="switchDiagram(9)">
            <span class="nav-num">10</span>
            <div class="nav-content">
              <div class="nav-title">Video Media Streaming Pipeline</div>
              <div class="nav-tag">FFmpeg +faststart & Nginx Byte-Range</div>
            </div>
          </li>
        </ul>
      </div>

      <!-- Nhóm 2 -->
      <div class="nav-category">
        <div class="category-title">2. Thiết Kế Lớp & Design Patterns</div>
        <ul class="nav-list">
          <li class="nav-item" onclick="switchDiagram(1)">
            <span class="nav-num">02</span>
            <div class="nav-content">
              <div class="nav-title">Sơ Đồ Lớp Toàn Hệ Thống</div>
              <div class="nav-tag">Models, Repositories, Services, Controllers</div>
            </div>
          </li>
          <li class="nav-item" onclick="switchDiagram(6)">
            <span class="nav-num">07</span>
            <div class="nav-content">
              <div class="nav-title">Mô Hình Các Mẫu Thiết Kế</div>
              <div class="nav-tag">Repository, Singleton, Adapter Pattern</div>
            </div>
          </li>
        </ul>
      </div>

      <!-- Nhóm 3 -->
      <div class="nav-category">
        <div class="category-title">3. Cơ Sở Dữ Liệu & Thực Thể</div>
        <ul class="nav-list">
          <li class="nav-item" onclick="switchDiagram(2)">
            <span class="nav-num">03</span>
            <div class="nav-content">
              <div class="nav-title">Sơ Đồ ERD Cơ Sở Dữ Liệu</div>
              <div class="nav-tag">8 Collections PocketBase SQLite</div>
            </div>
          </li>
        </ul>
      </div>

      <!-- Nhóm 4 -->
      <div class="nav-category">
        <div class="category-title">4. Hành Vi, Vòng Đời & Vận Hành</div>
        <ul class="nav-list">
          <li class="nav-item" onclick="switchDiagram(3)">
            <span class="nav-num">04</span>
            <div class="nav-content">
              <div class="nav-title">Tuần Tự: Xác Thực & 1-Click Demo</div>
              <div class="nav-tag">PocketBase Auth JWT Session Token</div>
            </div>
          </li>
          <li class="nav-item" onclick="switchDiagram(4)">
            <span class="nav-num">05</span>
            <div class="nav-content">
              <div class="nav-title">Tuần Tự: HTTP Byte-Range & Tua Phim</div>
              <div class="nav-tag">HTTP 206 Partial Content ±10s Seek</div>
            </div>
          </li>
          <li class="nav-item" onclick="switchDiagram(5)">
            <span class="nav-num">06</span>
            <div class="nav-content">
              <div class="nav-title">Vòng Đời Trình Phát Chewie</div>
              <div class="nav-tag">State Machine 7 Trạng Thái Trình Phát</div>
            </div>
          </li>
          <li class="nav-item" onclick="switchDiagram(7)">
            <span class="nav-num">08</span>
            <div class="nav-content">
              <div class="nav-title">Quy Trình CI/CD Tự Động Hóa</div>
              <div class="nav-tag">3-Stage GitHub Actions Pipeline</div>
            </div>
          </li>
        </ul>
      </div>
    </aside>

    <!-- Main Content Area -->
    <main class="portal-main">
      <div class="toolbar-bar">
        <div class="toolbar-left">
          <h2 id="diagram-title">
            <span>01. Sơ Đồ Kiến Trúc Hệ Thống Tổng Thể</span>
            <span class="badge-type arch" id="diagram-badge">ARCHITECTURE</span>
          </h2>
          <p id="diagram-desc">Kiến trúc 4 tầng phân tách rành mạch: Client Flutter, Reverse Proxy Nginx, BaaS PocketBase Go, và SQLite/Storage.</p>
        </div>
        <div class="toolbar-right">
          <button class="btn btn-secondary" onclick="openFullscreen()" title="Mở sơ đồ ở kích thước toàn màn hình">
            ⛶ Toàn Màn Hình
          </button>
          <a id="diagram-direct-link" href="suite/01_architecture.html" target="_blank" class="btn btn-red" title="Mở file HTML độc lập trên tab mới">
            ↗ Mở Tab Mới
          </a>
        </div>
      </div>

      <div class="diagram-frame-wrapper">
        <div class="iframe-box" id="iframe-box">
          <iframe id="diagram-frame" src="suite/01_architecture.html" loading="eager" title="Interactive Diagram"></iframe>
        </div>

        <!-- Deep Dive Explanation Panel -->
        <div class="deep-dive-panel">
          <div class="deep-dive-header">
            ⚡ PHÂN TÍCH THIẾT KẾ & ĐẶC TẢ KỸ THUẬT CHUYÊN SÂU
          </div>
          <div class="deep-dive-text" id="diagram-deep-dive">
            Đang tải dữ liệu mô tả kiến trúc...
          </div>

          <div class="key-points-grid" id="diagram-key-points">
            <!-- Render dynamically -->
          </div>
        </div>
      </div>

      <footer class="portal-footer">
        <div>© 2026 Nhóm 6 — Đồ án Học phần Phát Triển Phần Mềm Mã Nguồn Mở | Đại học Đồng Tháp</div>
        <div>Mẹo: Sử dụng phím tắt <strong>1 đến 9, 0</strong> để chuyển sơ đồ nhanh chóng</div>
      </footer>
    </main>

  </div>

  <script>
    const diagramsData = [
      {
        num: "01",
        title: "01. Sơ Đồ Kiến Trúc Hệ Thống Tổng Thể (Full-Stack 4-Tier)",
        type: "ARCHITECTURE",
        typeClass: "arch",
        file: "suite/01_architecture.html",
        desc: "Mô hình kiến trúc phân tầng chuẩn công nghiệp cho nền tảng video streaming mã nguồn mở OpenFlix.",
        deepDive: "Hệ thống OpenFlix được xây dựng dựa trên nguyên lý tách rời tối đa (Decoupling) và tối ưu hóa đường truyền video. Tầng <strong>Client</strong> giao tiếp hoàn toàn qua chuẩn REST/JSON với <strong>PocketBase BaaS</strong> (viết bằng Golang siêu nhẹ). Luồng truyền tải file MP4 1080p được phân tách riêng biệt thông qua <strong>Nginx Media Gateway</strong> với cơ chế hỗ trợ HTTP Byte-Range Requests (mã phản hồi 206 Partial Content), giúp loại bỏ tắc nghẽn ở máy chủ backend.",
        points: [
          { title: "Client Layer", desc: "Flutter Đa nền tảng (Android, Web, Desktop) xử lý UI mượt mà 60fps với phong cách Netflix." },
          { title: "Gateway Layer", desc: "Nginx xử lý SSL Termination, Caching Header và phục vụ trực tiếp Range Request cho video." },
          { title: "BaaS Backend", desc: "PocketBase (Go) tích hợp SQLite nhúng, quản lý Authentication JWT, CRUD và Realtime Subscriptions." },
          { title: "Storage Layer", desc: "Lưu trữ SQLite WAL Mode đạt hàng chục nghìn đọc/giây kèm ổ đĩa tĩnh lưu trữ tệp MP4 Faststart." }
        ]
      },
      {
        num: "02",
        title: "02. Sơ Đồ Lớp Phân Tầng Toàn Hệ Thống (Clean Architecture Class Diagram)",
        type: "CLASS DIAGRAM",
        typeClass: "class",
        file: "suite/02_class_layers.html",
        desc: "Sơ đồ biểu diễn cấu trúc lớp theo Clean Architecture, nguyên lý Dependency Inversion và giao tiếp đa tầng.",
        deepDive: "Sơ đồ lớp phân tách rõ rệt giữa <strong>Models (Data Entities)</strong>, <strong>Contracts (Trừu tượng hóa qua Interfaces)</strong>, <strong>Service Implementations</strong> và <strong>Presentation Controllers</strong>. Tầng UI hoàn toàn không phụ thuộc vào PocketBase SDK cụ thể, mà phụ thuộc vào giao diện trừu tượng <code>IMovieRepository</code>, tuân thủ nguyên lý chữ D trong SOLID (Dependency Inversion).",
        points: [
          { title: "MovieModel & Entities", desc: "Chứa thuộc tính phim, hỗ trợ serialization fromJson/toJson tự động." },
          { title: "IMovieRepository Interface", desc: "Giao diện định nghĩa hợp đồng lấy dữ liệu (getMovies, getMovieById, searchMovies)." },
          { title: "PocketBaseService", desc: "Triển khai cụ thể của repository, phụ trách giao tiếp HTTP với PocketBase." },
          { title: "PlayerController", desc: "Đóng gói Chewie & VideoPlayerController, điều khiển phát, tua và giải phóng tài nguyên." }
        ]
      },
      {
        num: "03",
        title: "03. Sơ Đồ Quan Hệ Thực Thể Cơ Sở Dữ Liệu (PocketBase SQLite ERD)",
        type: "ERD SCHEMA",
        typeClass: "erd",
        file: "suite/03_erd_database.html",
        desc: "Đặc tả lược đồ cơ sở dữ liệu quan hệ gồm 8 Collections được chuẩn hóa của PocketBase.",
        deepDive: "Lược đồ cơ sở dữ liệu được tổ chức theo tiêu chuẩn Chuẩn 3NF (Third Normal Form) nhằm loại bỏ trùng lặp và đảm bảo toàn vẹn dữ liệu. Khóa ngoại liên kết chặt chẽ giữa <code>users</code> và các bảng dữ liệu hoạt động như <code>watch_progress</code> (lưu vị trí giây xem dở), <code>my_list</code> (danh sách yêu thích) và <code>reviews</code> (đánh giá xếp hạng 5 sao).",
        points: [
          { title: "Identity (users, profiles)", desc: "Quản lý tài khoản, mã hóa mật khẩu bcrypt, phân quyền hồ sơ xem trẻ em (Kids)." },
          { title: "Catalog (movies, episodes)", desc: "Kho phim lẻ và phim bộ nhiều tập (season_num, episode_num) hỗ trợ URL phát riêng biệt." },
          { title: "User Activity", desc: "Đồng bộ liên tục tiến trình xem (position_sec, total_sec) và danh sách lưu phim cá nhân." },
          { title: "Community Feedback", desc: "Bình luận, điểm đánh giá sao và hòm thư phản hồi góp ý từ người dùng tới quản trị." }
        ]
      },
      {
        num: "04",
        title: "04. Sơ Đồ Tuần Tự: Xác Thực & Đăng Nhập 1-Click Demo",
        type: "SEQUENCE",
        typeClass: "seq",
        file: "suite/04_sequence_auth.html",
        desc: "Luồng xử lý từ khi nhấn nút Demo Account tới khi cấp phát JWT Token và chuyển màn hình Home.",
        deepDive: "Để tối ưu trải nghiệm người dùng và giúp hội đồng chấm thi trải nghiệm ngay lập tức mà không cần gõ phím, hệ thống thiết kế tính năng <strong>1-Click Demo Login</strong>. Luồng tuần tự minh họa chi tiết quá trình ứng dụng điền thông tin mặc định, gửi request xác thực tới PocketBase, giải mã JWT token, nạp thông tin hồ sơ và định tuyến tới HomeScreen (S09) chỉ trong dưới 300ms.",
        points: [
          { title: "Gửi Yêu Cầu Đăng Nhập", desc: "Flutter Client phát sinh HTTP POST /api/collections/users/auth-with-password." },
          { title: "Xác Thực Mật Khẩu", desc: "PocketBase kiểm tra hash bcrypt trong SQLite và khởi tạo JWT token có chữ ký." },
          { title: "Lưu Phiên Session", desc: "Client lưu Token vào bộ nhớ an toàn SharedPreferences / Flutter Secure Storage." },
          { title: "Điều Hướng An Toàn", desc: "Router chuyển sang S08 Profile Selection hoặc S09 Home Screen mà không bị nhấp nháy." }
        ]
      },
      {
        num: "05",
        title: "05. Sơ Đồ Tuần Tự: HTTP Byte-Range Streaming 1080p & Tua ±10s",
        type: "SEQUENCE",
        typeClass: "seq",
        file: "suite/05_sequence_streaming.html",
        desc: "Luồng truyền tải video định dạng Byte-Range (RFC 7233) và cơ chế bộ nhớ đệm Buffer thời gian thực.",
        deepDive: "Đây là xương sống kỹ thuật của một ứng dụng xem phim chất lượng cao. Khi phát video, trình phát không tải cả tệp (tránh tốn băng thông) mà gửi Header <code>Range: bytes=0-1048575</code>. Nginx trả về mã <strong>206 Partial Content</strong> kèm 1MB dữ liệu đầu tiên. Khi người dùng bấm tua <code>+10s</code>, ExoPlayer tính toán mốc offset mới và lập tức gửi Range Request tương ứng, giúp phim tiếp tục phát ngay chỉ sau 0.2 giây.",
        points: [
          { title: "Range Header Khởi Đầu", desc: "Trình phát yêu cầu phân đoạn đầu để đọc metadata moov atom." },
          { title: "206 Partial Content", desc: "Nginx Media Proxy stream từng khối byte mà không cần load toàn bộ file vào RAM." },
          { title: "Thao Tác Tua ±10s", desc: "Client ngắt buffer cũ, gửi Range request tại vị trí offset mới, UI hiển thị icon micro-animation." },
          { title: "Tự Động Lưu Tiến Trình", desc: "Mỗi 5 giây, PlayerController kích hoạt ghi nhận position_sec về cơ sở dữ liệu." }
        ]
      },
      {
        num: "06",
        title: "06. Sơ Đồ Trạng Thái Vòng Đời Trình Phát Video (Chewie Lifecycle)",
        type: "LIFECYCLE",
        typeClass: "arch",
        file: "suite/06_lifecycle_player.html",
        desc: "Máy trạng thái hữu hạn (FSM) quản lý 7 trạng thái vận hành của trình phát video.",
        deepDive: "Quản lý vòng đời trình phát video là tác vụ phức tạp nhất trên di động nhằm ngăn rò rỉ bộ nhớ (memory leaks) và xung đột Audio Focus. Máy trạng thái phân định rạch ròi giữa các trạng thái <code>Uninitialized</code> -> <code>Buffering</code> -> <code>Playing</code> -> <code>Paused</code> -> <code>Completed</code> -> <code>Disposed</code>, với khả năng tự phục hồi khi mạng gián đoạn (Network Retry Loop).",
        points: [
          { title: "Initializing & Buffering", desc: "Đọc header, nạp bộ đệm buffer ban đầu trước khi hiển thị khung hình đầu tiên." },
          { title: "Playing & Paused", desc: "Chạy vòng lặp render 60fps, tự động ẩn giao diện điều khiển (overlay controls) sau 3 giây không chạm." },
          { title: "Network Error Recovery", desc: "Tự động kích hoạt cơ chế Exponential Backoff để thử lại kết nối khi mất mạng." },
          { title: "Disposed Cleanup", desc: "Giải phóng toàn bộ texture phần cứng, audio focus và hủy bộ nhớ đệm khi đóng màn hình." }
        ]
      },
      {
        num: "07",
        title: "07. Mô Hình Các Mẫu Thiết Kế Áp Dụng (Design Patterns)",
        type: "DESIGN PATTERNS",
        typeClass: "class",
        file: "suite/07_design_patterns.html",
        desc: "Biểu diễn 3 mẫu thiết kế cốt lõi: Repository Pattern, Singleton Pattern và Adapter Pattern.",
        deepDive: "Dự án áp dụng chặt chẽ các mẫu thiết kế kinh điển Gang of Four (GoF):<br>1. <strong>Repository Pattern</strong>: Trừu tượng hóa nguồn dữ liệu (PocketBase, Local Mock, hoặc Cached Data) giúp việc thay đổi backend không ảnh hưởng tới UI.<br>2. <strong>Singleton Pattern</strong>: Đảm bảo chỉ tồn tại duy nhất một phiên bản <code>PocketBaseService</code> và <code>LibraryService</code> trong toàn bộ vòng đời ứng dụng.<br>3. <strong>Adapter Pattern</strong>: Bọc các thuộc tính phức tạp của <code>VideoPlayerController</code> thành giao diện điều khiển thân thiện kiểu Netflix qua <code>ChewieCustomControls</code>.",
        points: [
          { title: "Repository Pattern", desc: "Tách rời tầng logic nghiệp vụ khỏi chi tiết triển khai truy cập cơ sở dữ liệu." },
          { title: "Singleton Pattern", desc: "Duy trì duy nhất một kết nối HTTP Client, tiết kiệm tài nguyên mạng và đồng bộ state." },
          { title: "Adapter Pattern", desc: "Chuyển đổi giao diện điều khiển video gốc sang UI tuỳ biến đậm chất điện ảnh." },
          { title: "Observer Pattern (Provider)", desc: "Lắng nghe sự thay đổi của danh sách yêu thích và tự động cập nhật UI toàn hệ thống." }
        ]
      },
      {
        num: "08",
        title: "08. Sơ Đồ Quy Trình Tự Động Hóa CI/CD (GitHub Actions Pipeline)",
        type: "WORKFLOW CI/CD",
        typeClass: "arch",
        file: "suite/08_cicd_workflow.html",
        desc: "Quy trình tích hợp và triển khai liên tục gồm 3 giai đoạn: Linting, Kiểm thử Golden, và Đóng gói Build.",
        deepDive: "Để đảm bảo chuẩn mực mã nguồn mở cao cấp, dự án thiết lập đường ống CI/CD tự động chạy trên mỗi commit và Pull Request. Giai đoạn 1 kiểm tra cú pháp và tuân thủ chuẩn quy ước (Flutter Analyze). Giai đoạn 2 thực thi bộ kiểm thử tự động, đối sánh Golden Test 42 màn hình. Giai đoạn 3 tiến hành biên dịch song song tạo bản phân phối Release APK, App Bundle và Web Artifacts.",
        points: [
          { title: "Stage 1: Lint & Format", desc: "Tự động phân tích mã nguồn với bộ luật khắt khe của flutter_lints." },
          { title: "Stage 2: Test & QA", desc: "Chạy Unit tests, Widget tests và kiểm tra hồi quy giao diện hình ảnh." },
          { title: "Stage 3: Build & Release", desc: "Biên dịch song song Android APK/AAB và Web Bundle với cờ tối ưu dung lượng." },
          { title: "Phát Hành Tự Động", desc: "Tự động đính kèm file cài đặt vào GitHub Releases khi có tag phiên bản mới." }
        ]
      },
      {
        num: "09",
        title: "09. Cấu Trúc Cây Phân Rã Module (Clean Architecture Decomposition)",
        type: "MODULE TREE",
        typeClass: "arch",
        file: "suite/09_module_tree.html",
        desc: "Sơ đồ cây phân cấp thư mục và module mã nguồn của dự án Flutter OpenFlix.",
        deepDive: "Dự án tổ chức mã nguồn theo mô hình <strong>Clean Architecture</strong> dạng Feature-first và Layer-first kết hợp. Thư mục <code>lib/</code> được chia thành 4 trụ cột chính: <code>core/</code> (chứa hằng số giao diện, theme Netflix, định tuyến routes), <code>data/</code> (chứa models và data sources), <code>domain/</code> (chứa các hợp đồng repository) và <code>presentation/</code> (chứa toàn bộ 42 màn hình S01–S42 và widget dùng chung).",
        points: [
          { title: "Core Module", desc: "Quản lý bảng màu Netflix (#141414, #E50914), typographic tokens và cấu hình routes." },
          { title: "Data Module", desc: "Mô hình thực thể JSON serialization và dịch vụ kết nối mạng PocketBase." },
          { title: "Presentation Screens", desc: "Tổ chức 42 màn hình S01–S42 độc lập, dễ dàng bảo trì và mở rộng tính năng." },
          { title: "Shared Widgets", desc: "Tái sử dụng MovieCard, ShimmerSkeleton, NetflixButton và TopNavigation." }
        ]
      },
      {
        num: "10",
        title: "10. Quy Trình Xử Lý Video Streaming Pipeline (Faststart & Nginx Proxy)",
        type: "ARCHITECTURE",
        typeClass: "arch",
        file: "suite/10_media_pipeline.html",
        desc: "Quy trình tiền xử lý file video bằng FFmpeg, chuyển đổi moov atom và phân phối qua Nginx Cache.",
        deepDive: "Một vấn đề lớn khi phát video MP4 trên web/mobile là trình phát phải đợi tải hết tệp mới đọc được metadata (moov atom) nằm ở cuối file. OpenFlix giải quyết triệt để vấn đề này bằng cách thiết lập tiền xử lý với cờ <code>-movflags +faststart</code> qua FFmpeg, di chuyển khối thông tin moov atom lên đầu file. Nhờ đó, trình phát trên thiết bị di động đọc được thông tin phân giải, thời lượng ngay từ chunk 64KB đầu tiên và phát tức thì.",
        points: [
          { title: "Nén Mã Hóa Video", desc: "Sử dụng codec chuẩn H.264 / AAC đảm bảo tương thích 100% tất cả thiết bị di động." },
          { title: "FFmpeg Faststart", desc: "Dời siêu dữ liệu moov atom lên đầu tệp, giảm thời gian Time-To-First-Frame xuống < 0.3s." },
          { title: "Nginx Reverse Proxy", desc: "Phục vụ trực tiếp từ ổ cứng SSD NVMe, hỗ trợ nén gzip và HTTP Range." },
          { title: "Client Disk Caching", desc: "Ứng dụng tự động lưu bộ đệm đoạn video đã xem vào bộ nhớ tạm của máy để tua mượt mà." }
        ]
      }
    ];

    let currentIdx = 0;

    function switchDiagram(index) {
      currentIdx = index;
      const data = diagramsData[index];

      // Update sidebar active state
      const navItems = document.querySelectorAll('.nav-item');
      navItems.forEach((item, idx) => {
        if (idx === index) {
          item.classList.add('active');
        } else {
          item.classList.remove('active');
        }
      });

      // Update Toolbar
      document.getElementById('diagram-title').innerHTML = `
        <span>${data.title}</span>
        <span class="badge-type ${data.typeClass}" id="diagram-badge">${data.type}</span>
      `;
      document.getElementById('diagram-desc').innerText = data.desc;
      document.getElementById('diagram-direct-link').href = data.file;

      // Update Iframe
      document.getElementById('diagram-frame').src = data.file;

      // Update Deep Dive Content
      document.getElementById('diagram-deep-dive').innerHTML = data.deepDive;

      // Update Key Points
      const pointsContainer = document.getElementById('diagram-key-points');
      pointsContainer.innerHTML = '';
      data.points.forEach(pt => {
        const card = document.createElement('div');
        card.className = 'key-card';
        card.innerHTML = `
          <h4>❖ ${pt.title}</h4>
          <p>${pt.desc}</p>
        `;
        pointsContainer.appendChild(card);
      });
    }

    function openFullscreen() {
      const iframeBox = document.getElementById('iframe-box');
      if (!document.fullscreenElement) {
        if (iframeBox.requestFullscreen) {
          iframeBox.requestFullscreen();
        } else if (iframeBox.webkitRequestFullscreen) {
          iframeBox.webkitRequestFullscreen();
        } else if (iframeBox.msRequestFullscreen) {
          iframeBox.msRequestFullscreen();
        }
      } else {
        if (document.exitFullscreen) {
          document.exitFullscreen();
        }
      }
    }

    // Keyboard shortcuts: 1..9, 0
    window.addEventListener('keydown', (e) => {
      if (e.target.tagName === 'INPUT' || e.target.tagName === 'TEXTAREA') return;
      const key = e.key;
      if (key >= '1' && key <= '9') {
        const targetIdx = parseInt(key, 10) - 1;
        if (targetIdx < diagramsData.length) {
          switchDiagram(targetIdx);
        }
      } else if (key === '0') {
        switchDiagram(9);
      }
    });

    // Initialize first diagram
    window.addEventListener('DOMContentLoaded', () => {
      switchDiagram(0);
    });
  </script>
</body>
</html>
"""

target_path = r"c:\Users\buidi\.gemini\antigravity-ide\scratch\openflix\.archify\architecture-openflix-20261019-023500\openflix-architecture.html"
with open(target_path, "w", encoding="utf-8") as f:
    f.write(html_content)

print(f"Đã cập nhật Master Architecture Portal tại: {target_path}")
