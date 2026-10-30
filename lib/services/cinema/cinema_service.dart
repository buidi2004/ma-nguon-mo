import 'package:flutter/material.dart';

import '../../models/cinema/cinema_models.dart';

/// CinemaService cung cấp dữ liệu rạp phim Việt Nam như thật:
/// CineFlix Cinema, CGV, Lotte, BHD, các phim chiếu rạp hot nhất 2026.
class CinemaService extends ChangeNotifier {
  static final CinemaService instance = CinemaService._internal();
  CinemaService._internal() {
    _initRealisticData();
  }

  // Tỉnh/Thành phố đang được chọn
  String _selectedCityId = 'all';
  String get selectedCityId => _selectedCityId;
  String get selectedCityName {
    final city = cities.firstWhere(
      (c) => c.id == _selectedCityId,
      orElse: () => cities.first,
    );
    return city.name;
  }

  void selectCity(String cityId) {
    _selectedCityId = cityId;
    notifyListeners();
  }

  // 63 Tỉnh/Thành phố toàn quốc với Landmark đặc trưng
  final List<CinemaCityModel> cities = const [
    CinemaCityModel(
      id: 'all',
      name: 'Toàn quốc',
      landmark: 'Tất cả các rạp toàn quốc',
      icon: Icons.public_rounded,
    ),
    CinemaCityModel(
      id: 'hcm',
      name: 'TP Hồ Chí Minh',
      landmark: 'Chợ Bến Thành & Landmark 81',
      icon: Icons.location_city_rounded,
    ),
    CinemaCityModel(
      id: 'hanoi',
      name: 'Hà Nội',
      landmark: 'Chùa Một Cột & Hồ Gươm',
      icon: Icons.account_balance_rounded,
    ),
    CinemaCityModel(
      id: 'danang',
      name: 'Đà Nẵng',
      landmark: 'Cầu Vàng Bà Nà & Cầu Rồng',
      icon: Icons.waves_rounded,
    ),
    CinemaCityModel(
      id: 'angiang',
      name: 'An Giang',
      landmark: 'Rừng Tràm Trà Sư',
      icon: Icons.forest_rounded,
    ),
    CinemaCityModel(
      id: 'vungtau',
      name: 'Bà Rịa - Vũng Tàu',
      landmark: 'Ngọn Hải Đăng Vũng Tàu',
      icon: Icons.wb_sunny_rounded,
    ),
    CinemaCityModel(
      id: 'bentre',
      name: 'Bến Tre',
      landmark: 'Xứ Dừa Đồng Khởi',
      icon: Icons.nature_people_rounded,
    ),
    CinemaCityModel(
      id: 'camau',
      name: 'Cà Mau',
      landmark: 'Mũi Cà Mau Cực Nam',
      icon: Icons.navigation_rounded,
    ),
    CinemaCityModel(
      id: 'daklak',
      name: 'Đắk Lắk',
      landmark: 'Bảo Tàng Cà Phê Buôn Ma Thuột',
      icon: Icons.coffee_rounded,
    ),
    CinemaCityModel(
      id: 'haiphong',
      name: 'Hải Phòng',
      landmark: 'Nhà Hát Lớn Thành Phố Cảng',
      icon: Icons.anchor_rounded,
    ),
    CinemaCityModel(
      id: 'khanhhoa',
      name: 'Khánh Hòa',
      landmark: 'Tháp Trầm Hương & Biển Nha Trang',
      icon: Icons.beach_access_rounded,
    ),
    CinemaCityModel(
      id: 'nghean',
      name: 'Nghệ An',
      landmark: 'Làng Sen Quê Bác',
      icon: Icons.spa_rounded,
    ),
    CinemaCityModel(
      id: 'tayninh',
      name: 'Tây Ninh',
      landmark: 'Đỉnh Núi Bà Đen',
      icon: Icons.terrain_rounded,
    ),
    CinemaCityModel(
      id: 'hue',
      name: 'Thừa Thiên Huế',
      landmark: 'Cố Đô Huế & Ngọ Môn',
      icon: Icons.castle_rounded,
    ),
    CinemaCityModel(
      id: 'cantho',
      name: 'Cần Thơ',
      landmark: 'Bến Ninh Kiều & Chợ Nổi Cái Răng',
      icon: Icons.water_rounded,
    ),
    CinemaCityModel(
      id: 'lamdong',
      name: 'Lâm Đồng - Đà Lạt',
      landmark: 'Hồ Xuân Hương & Quảng Trường Lâm Viên',
      icon: Icons.local_florist_rounded,
    ),
  ];

  // Danh sách cụm rạp chuẩn
  final List<CinemaTheaterModel> theaters = const [
    CinemaTheaterModel(
      id: 'cnf_hn_centre',
      name: 'CineFlix Hanoi Centre',
      chain: 'CineFlix Cinema',
      cityId: 'hanoi',
      address: 'Tầng 6, Hanoi Centerpoint, 27 Lê Văn Lương, Thanh Xuân, Hà Nội',
      distanceKm: 2.1,
    ),
    CinemaTheaterModel(
      id: 'cnf_thiso_sala',
      name: 'CineFlix Thiso Mall Sala',
      chain: 'CineFlix Cinema',
      cityId: 'hcm',
      address: 'Tầng 3, Thiso Mall Sala, 10 Mai Chí Thọ, TP Thủ Đức, TP.HCM',
      distanceKm: 1.5,
    ),
    CinemaTheaterModel(
      id: 'cnf_aeon_danang',
      name: 'CineFlix AEON Mall Thanh Khê',
      chain: 'CineFlix Cinema',
      cityId: 'danang',
      address: 'Tầng 4, AEON Mall Thanh Khê, Điện Biên Phủ, Thanh Khê, Đà Nẵng',
      distanceKm: 3.0,
    ),
    CinemaTheaterModel(
      id: 'cnf_nguyen_du',
      name: 'CineFlix Nguyễn Du',
      chain: 'CineFlix Cinema',
      cityId: 'hcm',
      address: '116 Nguyễn Du, Phường Bến Thành, Quận 1, TP.HCM',
      distanceKm: 2.8,
    ),
    CinemaTheaterModel(
      id: 'cgv_landmark',
      name: 'CGV Vincom Center Landmark 81',
      chain: 'CGV Cinemas',
      cityId: 'hcm',
      address:
          'Tầng B1, Vincom Landmark 81, 720A Điện Biên Phủ, Bình Thạnh, TP.HCM',
      distanceKm: 4.2,
    ),
    CinemaTheaterModel(
      id: 'bhd_bitexco',
      name: 'BHD Star Cineplex Bitexco',
      chain: 'BHD Star',
      cityId: 'hcm',
      address:
          'Tầng 3 & 4, Bitexco Icon 68, 2 Hải Triều, Bến Nghé, Quận 1, TP.HCM',
      distanceKm: 3.6,
    ),
    CinemaTheaterModel(
      id: 'lotte_nowzone',
      name: 'Lotte Cinema Nowzone',
      chain: 'Lotte Cinema',
      cityId: 'hcm',
      address: 'Tầng 5, TTTM Nowzone, 235 Nguyễn Văn Cừ, Quận 1, TP.HCM',
      distanceKm: 3.1,
    ),
  ];

  List<CinemaTheaterModel> getTheatersByCity(String cityId) {
    if (cityId == 'all') return theaters;
    final list = theaters.where((t) => t.cityId == cityId).toList();
    return list.isNotEmpty ? list : theaters;
  }

  // Danh sách phim chiếu rạp
  late final List<CinemaMovieModel> movies;

  // Danh sách combo bắp nước
  final List<CinemaConcessionModel> concessions = const [
    CinemaConcessionModel(
      id: 'combo_solo',
      name: 'Combo Solo Tiết Kiệm',
      description: '1 Bắp ngọt 60oz thơm bơ + 1 Nước ngọt có ga 32oz mát lạnh',
      price: 85000,
      imageUrl:
          'https://images.unsplash.com/photo-1572177812156-58036aae439c?w=400',
      category: 'combo',
    ),
    CinemaConcessionModel(
      id: 'combo_couple',
      name: 'Combo Couple Hẹn Hò',
      description:
          '1 Bắp lớn 80oz (tùy chọn Caramel/Phô mai) + 2 Nước ngọt 32oz',
      price: 119000,
      imageUrl:
          'https://images.unsplash.com/photo-1585647347483-22b66260dfff?w=400',
      category: 'combo',
    ),
    CinemaConcessionModel(
      id: 'combo_family',
      name: 'Combo Family Đại Gia Đình',
      description: '2 Bắp lớn 80oz + 3 Nước ngọt 32oz + 1 Khoai tây chiên lắc phô mai giòn tan',
      price: 189000,
      imageUrl:
          'https://images.unsplash.com/photo-1505686994434-e3cc5abf1330?w=400',
      category: 'combo',
    ),
    CinemaConcessionModel(
      id: 'popcorn_cheese',
      name: 'Bắp Rang Phô Mai Lắc Vàng',
      description:
          'Hạt bắp nổ bung phủ lớp phô mai New Zealand béo ngậy hảo hạng',
      price: 65000,
      imageUrl:
          'https://images.unsplash.com/photo-1578849278619-e73505e9610f?w=400',
      category: 'popcorn',
    ),
    CinemaConcessionModel(
      id: 'popcorn_caramel',
      name: 'Bắp Rang Caramel Mạch Nha',
      description: 'Vị ngọt thanh đượm hương đường nâu caramel nấu thủ công',
      price: 65000,
      imageUrl:
          'https://images.unsplash.com/photo-1512149177596-f817c7ef5d4c?w=400',
      category: 'popcorn',
    ),
    CinemaConcessionModel(
      id: 'drink_pepsi',
      name: 'Pepsi Lạnh 32oz',
      description: 'Pepsi có ga mát lạnh ướp đá sảng khoái',
      price: 35000,
      imageUrl:
          'https://images.unsplash.com/photo-1629203851122-3726ecdf080e?w=400',
      category: 'drink',
    ),
    CinemaConcessionModel(
      id: 'drink_7up',
      name: '7Up Chanh Tươi 32oz',
      description: 'Nước ngọt vị chanh thanh mát, đã khát',
      price: 35000,
      imageUrl:
          'https://images.unsplash.com/photo-1551024709-8f23befc6f87?w=400',
      category: 'drink',
    ),
    CinemaConcessionModel(
      id: 'merch_cup',
      name: 'Ly Topper Nhân Vật Độc Quyền',
      description: 'Ly rạp phim kèm topper nhân vật phiên bản giới hạn kỷ niệm công chiếu',
      price: 149000,
      imageUrl:
          'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=400',
      category: 'merch',
    ),
  ];

  // Danh sách bài viết tin tức & blog điện ảnh (Khớp Screenshot 5)
  final List<CinemaArticleModel> articles = [
    CinemaArticleModel(
      id: 'art_trai_buon_nguoi',
      title: '[Review] Trại Buôn Người: Bạo Lực, Khốc Liệt Đầy Mãn Nhãn!',
      excerpt: 'Tác phẩm điện ảnh hành động tâm lý mở ra góc nhìn tăm tối và những pha truy đuổi nghẹt thở không khoan nhượng.',
      content: '''
Tác phẩm điện ảnh "Trại Buôn Người" là bước chuyển mình táo bạo của dòng phim hành động giật gân tại phòng vé năm 2026. Với tiết tấu dồn dập ngay từ những phút mở màn, bộ phim cuốn khán giả vào cuộc chiến sinh tồn khốc liệt giữa những kẻ săn mồi nguy hiểm và nạn nhân không còn đường lui.

Diễn xuất của dàn cast chính đạt độ chín muồi xuất sắc. Từng ánh mắt căm phẫn, hơi thở gấp gáp và các pha cận chiến chân thực không hề lạm dụng kỹ xảo CGI khiến người xem phải nín thở từng giây.

Đặc biệt, hệ thống âm thanh vòm Dolby Atmos tại rạp chiếu tạo nên không khí nghẹt thở đến tột cùng, xứng đáng là lựa chọn bom tấn không thể bỏ qua dịp cuối tuần này!
''',
      imageUrl:
          'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?w=800',
      author: 'Đức Nguyễn — Cine Critic',
      category: 'review',
      publishedAt: DateTime.now().subtract(const Duration(hours: 3)),
      likesCount: 5172,
      viewsCount: 18420,
      relatedMovieId: 'cm_an_mang',
    ),
    CinemaArticleModel(
      id: 'art_resident_evil',
      title: '[Review] Resident Evil: Vừa Hài Hước, Vừa Kinh Dị',
      excerpt: 'Sự kết hợp bất ngờ giữa phong cách rùng rợn zombie kinh điển và những màn đối thoại hài châm biếm sâu cay.',
      content: '''
Phiên bản làm lại mới nhất của dòng phim kinh dị sinh tồn mang lại luồng gió mới cho khán giả rạp. Khác với những phần phim đen tối trước đây, tác phẩm lần này đan cài khéo léo những mảng miếng hài hước duyên dáng giúp giảm bớt căng thẳng sau những cú jumpscare thót tim.

Hiệu ứng hóa trang thực tế cùng kỹ xảo âm thanh xuất sắc khiến từng phân cảnh truy đuổi trong hành lang bệnh viện ngập tràn cảm giác hồi hộp tột độ.
''',
      imageUrl:
          'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=600',
      author: 'Minh Tuấn Movie',
      category: 'review',
      publishedAt: DateTime.now().subtract(const Duration(hours: 8)),
      likesCount: 1088,
      viewsCount: 7650,
      relatedMovieId: 'cm_bi_mat',
    ),
    CinemaArticleModel(
      id: 'art_len_huong',
      title: '[Review] Lên Hương: Quan Tài Cầu Tài Và Tình Mẫu Tử Thiêng Liêng',
      excerpt: 'Bộ phim kinh dị tâm linh kết hợp yếu tố gia đình lấy nước mắt người xem bằng câu chuyện cảm động.',
      content: '''
Ẩn sau những hủ tục ma mị và chiếc quan tài cầu tài huyền bí là bi kịch đau xót của một gia đình nghèo nơi miền quê sông nước. Người mẹ nghèo sẵn sàng đánh đổi linh hồn để các con có được tương lai no ấm, để rồi mở ra chuỗi nghiệp quả khôn lường.

Hình ảnh sông nước miền Tây u tịch cùng phần âm nhạc ai oán đẩy cảm xúc của người xem lên đến đỉnh điểm trong trường đoạn cuối.
''',
      imageUrl:
          'https://images.unsplash.com/photo-1518676590629-3dcbd9c5a5c9?w=600',
      author: 'Phương Uyên',
      category: 'review',
      publishedAt: DateTime.now().subtract(const Duration(hours: 18)),
      likesCount: 1652,
      viewsCount: 10420,
      relatedMovieId: 'cm_coi_nguoi_ta',
    ),
    CinemaArticleModel(
      id: 'art_hope_vung_tu_dia',
      title: '[Review] Hope Vùng Tử Địa: Tham Vọng Vượt Tầm',
      excerpt: 'Một thử nghiệm điện ảnh khoa học viễn tưởng hoành tráng của điện ảnh châu Á với tham vọng vươn tầm quốc tế.',
      content: '''
Bộ phim đặt bối cảnh Trái Đất hậu tận thế khi nguồn tài nguyên cạn kiệt. Một nhóm nhà khoa học dấn thân vào "Vùng Tử Địa" nhằm tìm kiếm mẫu gien có khả năng phục hồi hệ sinh thái.

Thiết kế mỹ thuật và trang phục phi hành gia được đầu tư chỉn chu, mang lại trải nghiệm thị giác ấn tượng trên màn chiếu lớn.
''',
      imageUrl:
          'https://images.unsplash.com/photo-1478760329108-5c3ed9d495a0?w=600',
      author: 'Quốc Bảo',
      category: 'blog',
      publishedAt: DateTime.now().subtract(const Duration(days: 1)),
      likesCount: 924,
      viewsCount: 5890,
      relatedMovieId: 'cm_avatar',
    ),
  ];

  // Danh sách vé đã đặt của người dùng
  final List<CinemaBookingModel> userBookings = [];

  void addBooking(CinemaBookingModel booking) {
    userBookings.insert(0, booking);
    notifyListeners();
  }

  void _initRealisticData() {
    movies = [
      // ================== PHIM VIỆT NAM CHIẾU RẠP ==================
      // 1. Án Mạng Xém Hoàn Hảo (Việt Nam)
      CinemaMovieModel(
        id: 'cm_an_mang',
        title: 'Án Mạng Xém Hoàn Hảo',
        posterUrl: 'https://images.unsplash.com/photo-1536440136628-849c177e76a1?w=600',
        trailerUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
        backdropUrl: 'https://images.unsplash.com/photo-1518676590629-3dcbd9c5a5c9?w=1200',
        durationMinutes: 124,
        releaseDate: '09/10/2026',
        ageRating: 'T18',
        rating: 8.3,
        voteCount: 312,
        country: 'Việt Nam',
        productionStudio: 'Dreamcraft Studio & CineFlix',
        genres: const ['Hài', 'Tâm Lý', 'Phá Án'],
        director: 'Đức Nguyễn',
        cast: const [
          'Anh Tú',
          'DJ Mie',
          'Vũ Ngọc Anh',
          'Huy Khánh',
          'Long Đẹp Trai',
        ],
        synopsis: 'Trinh vô tình phát hiện xác chết của tình địch bị nghi ngờ có mối quan hệ mờ ám với chồng sắp cưới. Đại (thám tử tư) được Trinh thuê theo dõi vụ ngoại tình lén vào giúp thì vấp ngã để lại dấu vân tay lên tử thi và bị bảo vệ bắt quả tang. Từ đây, liên tiếp những tình huống dở khóc dở cười nổ ra giữa hai người khi vừa trốn chạy cảnh sát dí sát gót, vừa hợp lực vạch trần bí mật đen tối của giới showbiz.',
        status: CinemaMovieStatus.nowShowing,
        formats: const ['2D Phụ Đề', 'VIP - AQUALIS', 'VIP - LAURUS'],
      ),

      // 2. Mai (Việt Nam — Kỷ Lục Doanh Thu 520 Tỷ)
      CinemaMovieModel(
        id: 'cm_mai',
        title: 'Mai',
        posterUrl: 'https://images.unsplash.com/photo-1517604931442-7e0c8ed2963c?w=600',
        trailerUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
        backdropUrl: 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?w=1200',
        durationMinutes: 131,
        releaseDate: '10/02/2026',
        ageRating: 'T18',
        rating: 9.1,
        voteCount: 1850,
        country: 'Việt Nam',
        productionStudio: 'Trấn Thành Town & CJ HK Entertainment',
        genres: const ['Tâm Lý', 'Tình Cảm', 'Lãng Mạn'],
        director: 'Trấn Thành',
        cast: const [
          'Phương Anh Đào',
          'Tuấn Trần',
          'Hồng Đào',
          'NSND Việt Anh',
          'Uyển Ân',
        ],
        synopsis: 'Câu chuyện xoay quanh Mai – người phụ nữ gần 40 tuổi làm nghề massage trị liệu chịu nhiều ánh mắt phán xét của xã hội. Cuộc đời trầm lặng của cô bỗng rực rỡ khi Dương – chàng nhạc công trẻ tuổi đào hoa xuất hiện và theo đuổi cô mãnh liệt. Một bản tình ca day dứt về tình yêu, số phận và khát vọng hạnh phúc của người phụ nữ.',
        status: CinemaMovieStatus.nowShowing,
        formats: const ['2D Phụ Đề', 'IMAX 2D', 'VIP - LAURUS'],
      ),

      // 3. Lật Mặt 7: Một Điều Ước (Việt Nam — Doanh Thu 480 Tỷ)
      CinemaMovieModel(
        id: 'cm_lat_mat_7',
        title: 'Lật Mặt 7: Một Điều Ước',
        posterUrl: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=600',
        trailerUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
        backdropUrl: 'https://images.unsplash.com/photo-1536440136628-849c177e76a1?w=1200',
        durationMinutes: 138,
        releaseDate: '26/04/2026',
        ageRating: 'K',
        rating: 9.3,
        voteCount: 2100,
        country: 'Việt Nam',
        productionStudio: 'Lý Hải Production',
        genres: const ['Gia Đình', 'Tâm Lý', 'Chữa Lành'],
        director: 'Lý Hải',
        cast: const [
          'NSƯT Thanh Hiền',
          'Trương Minh Cường',
          'Đinh Y Nhung',
          'Quách Ngọc Tuyên',
          'Ammy Minh Khuê',
        ],
        synopsis: 'Bà Hai (73 tuổi) sống đơn độc tại ngôi nhà nhỏ ở vùng núi Lạc Dương, một mình tảo tần nuôi 5 người con khôn lớn. Khi bà không may bị tai nạn gãy chân, 5 người con với 5 hoàn cảnh sống khác nhau đùn đẩy trách nhiệm nuôi mẹ, mở ra hành trình gắn kết gia đình đầy xúc động chạm đến trái tim hàng triệu khán giả.',
        status: CinemaMovieStatus.nowShowing,
        formats: const ['2D Lồng Tiếng', '2D Phụ Đề', 'IMAX 2D'],
      ),

      // 4. Cám: Dị Bản Kinh Dị (Việt Nam)
      CinemaMovieModel(
        id: 'cm_cam',
        title: 'Cám: Dị Bản Kinh Dị',
        posterUrl: 'https://images.unsplash.com/photo-1518676590629-3dcbd9c5a5c9?w=600',
        trailerUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
        backdropUrl: 'https://images.unsplash.com/photo-1478760329108-5c3ed9d495a0?w=1200',
        durationMinutes: 122,
        releaseDate: '20/09/2026',
        ageRating: 'T18',
        rating: 8.4,
        voteCount: 640,
        country: 'Việt Nam',
        productionStudio: 'ProductionQ & CineFlix Studios',
        genres: const ['Kinh Dị', 'Cổ Trang', 'Dân Gian'],
        director: 'Trần Hữu Tấn',
        cast: const [
          'Thúy Diễm',
          'Rima Thanh Vy',
          'Lâm Thanh Mỹ',
          'Quốc Cường',
          'Hải Nam',
        ],
        synopsis: 'Dị bản kinh dị đen tối lấy cảm hứng từ truyện cổ tích Tấm Cám. Khác với truyện xưa, Cám sinh ra với khuôn mặt dị tật gớm ghiếc, bị gia đình ruồng rẫy và cha mẹ ghẻ lạnh. Trong nỗi uất hận tột cùng, Cám dần bước vào nghi lễ hiến tế tà thuật kinh hoàng của quỷ Bạch Lão để đổi lấy sắc đẹp và sự sủng ái tàn bạo.',
        status: CinemaMovieStatus.nowShowing,
        formats: const ['2D Phụ Đề', 'IMAX 2D'],
      ),

      // 5. Ma Da: Rút Ruột Sông Sâu (Việt Nam)
      CinemaMovieModel(
        id: 'cm_ma_da',
        title: 'Ma Da: Rút Ruột Sông Sâu',
        posterUrl: 'https://images.unsplash.com/photo-1478760329108-5c3ed9d495a0?w=600',
        trailerUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
        backdropUrl: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=1200',
        durationMinutes: 105,
        releaseDate: '16/08/2026',
        ageRating: 'T16',
        rating: 8.0,
        voteCount: 520,
        country: 'Việt Nam',
        productionStudio: 'AMF & CineFlix Studios',
        genres: const ['Kinh Dị', 'Tâm Linh', 'Hồi Hộp'],
        director: 'Nguyễn Hữu Hoàng',
        cast: const ['Việt Hương', 'Trung Dân', 'Cẩm Ly', 'NSƯT Thành Lộc'],
        synopsis: 'Bà Lệ làm nghề vớt xác trên vùng sông nước rừng đước Cần Giờ. Trong một lần vớt xác cậu bé chết đuối bí ẩn, bà vô tình phạm phải cấm kỵ tâm linh và đắc tội với "Ma Da" – thế lực tà ác dưới đáy sông luôn rình rập kéo chân người sống để tìm kẻ thế mạng.',
        status: CinemaMovieStatus.nowShowing,
        formats: const ['2D Phụ Đề', '4DX'],
      ),

      // 6. Ngày Xưa Có Một Chuyện Tình (Việt Nam)
      CinemaMovieModel(
        id: 'cm_ngay_xua_tinh',
        title: 'Ngày Xưa Có Một Chuyện Tình',
        posterUrl: 'https://images.unsplash.com/photo-1485846234645-a62644f84728?w=600',
        trailerUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyBlazes.mp4',
        backdropUrl: 'https://images.unsplash.com/photo-1517604931442-7e0c8ed2963c?w=1200',
        durationMinutes: 135,
        releaseDate: '01/11/2026',
        ageRating: 'T16',
        rating: 8.8,
        voteCount: 430,
        country: 'Việt Nam',
        productionStudio: 'CJ HK Entertainment',
        genres: const ['Lãng Mạn', 'Tình Cảm', 'Thanh Xuân'],
        director: 'Trịnh Đình Lê Minh',
        cast: const ['Avin Lu', 'Ngọc Xuân', 'Đỗ Nhật Hoàng'],
        synopsis: 'Chuyển thể từ tiểu thuyết lãng mạn kinh điển của nhà văn Nguyễn Nhật Ánh. Chuyện tình tay ba đầy tiếc nuối giữa Vinh, Phúc và Miền trải dài từ những năm tháng học trò ngây thơ ở làng quê miền Trung cho đến khi trưởng thành đối mặt với những ngã rẽ định mệnh của cuộc đời.',
        status: CinemaMovieStatus.nowShowing,
        formats: const ['2D Phụ Đề', 'VIP - AQUALIS'],
      ),

      // 7. Cõi Người Ta: Lời Nguyền Trăm Năm (Việt Nam)
      CinemaMovieModel(
        id: 'cm_coi_nguoi_ta',
        title: 'Cõi Người Ta: Lời Nguyền Trăm Năm',
        posterUrl: 'https://images.unsplash.com/photo-1579783902614-a3fb3927b675?w=600',
        trailerUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
        backdropUrl: 'https://images.unsplash.com/photo-1478760329108-5c3ed9d495a0?w=1200',
        durationMinutes: 115,
        releaseDate: '23/10/2026',
        ageRating: 'T16',
        rating: 7.9,
        voteCount: 140,
        country: 'Việt Nam',
        productionStudio: 'CineFlix Studios',
        genres: const ['Kinh Dị', 'Tâm Linh', 'Dân Gian'],
        director: 'Hoàng Lê',
        cast: const ['Quách Ngọc Ngoan', 'Khả Như', 'Lê Bê La', 'Quang Tuấn'],
        synopsis: 'Lấy cảm hứng từ những câu chuyện tâm linh truyền miệng vùng đồng bằng sông Cửu Long, bộ phim mở ra bí ẩn về ngôi miếu cổ và lời thề huyết thệ của một gia tộc giàu có nhằm duy trì cơ nghiệp đời đời.',
        status: CinemaMovieStatus.nowShowing,
        formats: const ['2D Phụ Đề', '2D Lồng Tiếng'],
      ),

      // 8. Trại Buôn Người: Vùng Đất Chết (Việt Nam - Thái Lan)
      CinemaMovieModel(
        id: 'cm_trai_buon_nguoi',
        title: 'Trại Buôn Người: Vùng Đất Chết',
        posterUrl: 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?w=600',
        trailerUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
        backdropUrl: 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?w=1200',
        durationMinutes: 130,
        releaseDate: '10/10/2026',
        ageRating: 'T18',
        rating: 8.5,
        voteCount: 380,
        country: 'Việt Nam - Thái Lan',
        productionStudio: 'V Pictures & GDH 559',
        genres: const ['Hành Động', 'Tội Phạm', 'Giật Gân'],
        director: 'Lê Thanh Sơn',
        cast: const [
          'Kiều Minh Tuấn',
          'Trấn Thành',
          'Jun Vũ',
          'Sunny Suwanmethanont',
        ],
        synopsis: 'Hành trình vượt ngục giải cứu đồng đội của những người lao động bị lừa sang khu kinh tế ngầm nơi biên giới. Một tác phẩm hành động căng thẳng đến nghẹt thở với các cảnh truy sát khốc liệt.',
        status: CinemaMovieStatus.nowShowing,
        formats: const ['2D Phụ Đề', 'IMAX 2D'],
      ),

      // 9. Địa Đạo: Mặt Trời Trong Bóng Tối (Việt Nam — Bom Tấn IMAX)
      CinemaMovieModel(
        id: 'cm_dia_dao',
        title: 'Địa Đạo: Mặt Trời Trong Bóng Tối',
        posterUrl: 'https://images.unsplash.com/photo-1440404653325-ab127d49abc1?w=600',
        trailerUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
        backdropUrl: 'https://images.unsplash.com/photo-1517604931442-7e0c8ed2963c?w=1200',
        durationMinutes: 145,
        releaseDate: '30/04/2026',
        ageRating: 'T16',
        rating: 9.2,
        voteCount: 580,
        country: 'Việt Nam',
        productionStudio: 'HKFilm & CineFlix Studios',
        genres: const ['Lịch Sử', 'Chiến Tranh', 'Hành Động'],
        director: 'Bùi Thạc Chuyên',
        cast: const ['Thái Hòa', 'Quang Tuấn', 'Hồ Thu Anh'],
        synopsis: 'Bộ phim bom tấn lịch sử ghi dấu ấn hào hùng, tái hiện sự kiên cường và lòng quả cảm phi thường của quân và dân Củ Chi bên dưới lòng địa đạo hiểm trở trong giai đoạn kháng chiến khốc liệt.',
        status: CinemaMovieStatus.imax,
        formats: const ['IMAX 2D', '2D Phụ Đề'],
      ),

      // 10. Lật Mặt 8: Vòng Tay Nắng Ấm (Việt Nam — Sắp Chiếu)
      CinemaMovieModel(
        id: 'cm_lat_mat_8',
        title: 'Lật Mặt 8: Vòng Tay Nắng Ấm',
        posterUrl: 'https://images.unsplash.com/photo-1579783902614-a3fb3927b675?w=600',
        trailerUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyBlazes.mp4',
        backdropUrl: 'https://images.unsplash.com/photo-1536440136628-849c177e76a1?w=1200',
        durationMinutes: 135,
        releaseDate: '26/04/2026',
        ageRating: 'T13',
        rating: 8.9,
        voteCount: 560,
        country: 'Việt Nam',
        productionStudio: 'Lý Hải Production',
        genres: const ['Gia Đình', 'Tâm Lý', 'Hài Hước'],
        director: 'Lý Hải',
        cast: const ['Lý Hải', 'Minh Hà', 'Quách Ngọc Tuyên', 'Huy Khánh'],
        synopsis: 'Phần phim tiếp theo trong thương hiệu điện ảnh tỷ đô của Lý Hải, mang đến câu chuyện gia đình lắng đọng cảm xúc và những tình huống hài hước chân phương.',
        status: CinemaMovieStatus.comingSoon,
        formats: const ['2D Lồng Tiếng', '2D Phụ Đề'],
      ),

      // 11. Bộ Tứ Báo Thủ (Việt Nam — Sắp Chiếu Tết)
      CinemaMovieModel(
        id: 'cm_bo_tu_bao_thu',
        title: 'Bộ Tứ Báo Thủ',
        posterUrl: 'https://images.unsplash.com/photo-1514306191717-452ec28c7814?w=600',
        trailerUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
        backdropUrl: 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?w=1200',
        durationMinutes: 115,
        releaseDate: '17/02/2026',
        ageRating: 'T13',
        rating: 8.7,
        voteCount: 410,
        country: 'Việt Nam',
        productionStudio: 'Trấn Thành Town',
        genres: const ['Hài Hước', 'Gia Đình', 'Tết'],
        director: 'Trấn Thành',
        cast: const ['Trấn Thành', 'Lê Dương Bảo Lâm', 'Uyển Ân', 'Lê Giang'],
        synopsis: 'Bộ phim hài hước chiếu rạp tưng bừng dịp Tết về bộ tứ "báo thủ" gia đình với những pha xử lý cồng kềnh, gây cười nghiêng ngả nhưng chứa đựng bài học sâu sắc về sự thấu hiểu giữa các thế hệ.',
        status: CinemaMovieStatus.comingSoon,
        formats: const ['2D Lồng Tiếng', 'IMAX 2D'],
      ),

      // 12. Tử Mẫu Thiên Linh Cái (Việt Nam — Sắp Chiếu)
      CinemaMovieModel(
        id: 'cm_tu_mau_thien_linh_cai',
        title: 'Tử Mẫu Thiên Linh Cái',
        posterUrl: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=600',
        trailerUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
        backdropUrl: 'https://images.unsplash.com/photo-1518676590629-3dcbd9c5a5c9?w=1200',
        durationMinutes: 112,
        releaseDate: '15/11/2026',
        ageRating: 'T18',
        rating: 8.2,
        voteCount: 230,
        country: 'Việt Nam',
        productionStudio: 'CineFlix Studios',
        genres: const ['Kinh Dị', 'Tội Phạm', 'Bí Ẩn'],
        director: 'Lê Bình Giang',
        cast: const ['Hoàng Yến Chibi', 'Quang Tuấn', 'Đinh Y Nhung'],
        synopsis: 'Phần tiền truyện đen tối về nguồn gốc tà thuật luyện Kumanthong và Thiên Linh Cái rùng rợn vùng sông nước Tây Nam Bộ những năm 90, phơi bày lòng tham và sự biến chất của con người trước ảo mộng quyền năng.',
        status: CinemaMovieStatus.comingSoon,
        formats: const ['2D Phụ Đề'],
      ),

      // ================== PHIM THÁI LAN CHIẾU RẠP ==================
      // 13. Gia Tài Của Ngoại (Thái Lan — Bom Tấn Phòng Vé Châu Á)
      CinemaMovieModel(
        id: 'cm_gia_tai_cua_ngoai',
        title: 'Gia Tài Của Ngoại (How to Make Millions Before Grandma Dies)',
        posterUrl: 'https://images.unsplash.com/photo-1517457373958-b7bdd4587205?w=600',
        trailerUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
        backdropUrl: 'https://images.unsplash.com/photo-1517604931442-7e0c8ed2963c?w=1200',
        durationMinutes: 126,
        releaseDate: '07/06/2026',
        ageRating: 'P',
        rating: 9.6,
        voteCount: 2340,
        country: 'Thái Lan',
        productionStudio: 'GDH 559',
        genres: const ['Gia Đình', 'Tâm Lý', 'Cảm Động'],
        director: 'Pat Boonnitipat',
        cast: const [
          'Billkin Putthipong',
          'Usha Seamkhum (Amah)',
          'Tu Tontawan',
        ],
        synopsis: 'M (Billkin) quyết định bỏ việc stream game để đến chăm sóc người bà mắc ung thư giai đoạn cuối với ý định được chia thừa kế căn nhà tiền tỷ. Nhưng trong những tháng ngày cùng bà đẩy xe bán cháo, M nhận ra điều vô giá nhất trong đời không phải là tiền tài danh vọng mà là những khoảnh khắc ấm áp bên người thân yêu.',
        status: CinemaMovieStatus.nowShowing,
        formats: const ['2D Phụ Đề', 'VIP - LAURUS'],
      ),

      // 14. Tee Yod: Quỷ Ăn Tạng 2 (Thái Lan — Kỷ Lục Phòng Vé IMAX)
      CinemaMovieModel(
        id: 'cm_tee_yod_2',
        title: 'Tee Yod: Quỷ Ăn Tạng 2 (Death Whisperer 2)',
        posterUrl: 'https://images.unsplash.com/photo-1509281373149-e957c6296406?w=600',
        trailerUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
        backdropUrl: 'https://images.unsplash.com/photo-1478760329108-5c3ed9d495a0?w=1200',
        durationMinutes: 112,
        releaseDate: '18/10/2026',
        ageRating: 'T18',
        rating: 8.9,
        voteCount: 1670,
        country: 'Thái Lan',
        productionStudio: 'Major Join Film & BEC World',
        genres: const ['Kinh Dị', 'Hành Động', 'Tâm Linh Thái'],
        director: 'Taweewat Wantha',
        cast: const [
          'Nadech Kugimiya',
          'Denise Jelilcha Kapaun',
          'Junior Kajbhunditt',
        ],
        synopsis: 'Ba năm sau cái chết bi thảm của Yam, người anh cả Yak (Nadech Kugimiya) vẫn không ngừng cầm súng lùng sục bóng ma áo đen báo thù cho em gái. Lần theo manh mối tà thuật, Yak dấn thân vào khu rừng ma quái Dong Khmoch – sào huyệt của những nghi lễ ăn tạng man rợ nhất Đông Nam Á.',
        status: CinemaMovieStatus.imax,
        formats: const ['IMAX 2D', '2D Phụ Đề'],
      ),

      // 15. Tee Yod: Quỷ Ăn Tạng 1 (Thái Lan)
      CinemaMovieModel(
        id: 'cm_tee_yod_1',
        title: 'Tee Yod: Quỷ Ăn Tạng 1 (Death Whisperer)',
        posterUrl: 'https://images.unsplash.com/photo-1518676590629-3dcbd9c5a5c9?w=600',
        trailerUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
        backdropUrl: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=1200',
        durationMinutes: 121,
        releaseDate: '15/12/2025',
        ageRating: 'T18',
        rating: 8.6,
        voteCount: 1240,
        country: 'Thái Lan',
        productionStudio: 'Major Join Film',
        genres: const ['Kinh Dị', 'Tâm Linh', 'Ám Ảnh'],
        director: 'Taweewat Wantha',
        cast: const ['Nadech Kugimiya', 'Mim Rattanawadee', 'Nutthacha Nina'],
        synopsis: 'Hiện tượng phòng vé kinh dị Thái Lan dựa trên câu chuyện có thật tại Kanchanaburi. Khi tiếng thì thầm "Tee Yod... Tee Yod..." vang lên giữa đêm khuya vắng, con quỷ ăn nội tạng bắt đầu thâm nhập vào thể xác cô con gái trong gia đình, gieo rắc nỗi kinh hoàng tột cùng.',
        status: CinemaMovieStatus.nowShowing,
        formats: const ['2D Phụ Đề', 'IMAX 2D'],
      ),

      // 16. Ngược Dòng Thời Gian Để Yêu Em (Thái Lan)
      CinemaMovieModel(
        id: 'cm_nguoc_dong_thoi_gian',
        title: 'Ngược Dòng Thời Gian Để Yêu Em (Love Destiny: The Movie)',
        posterUrl: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=600',
        trailerUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyBlazes.mp4',
        backdropUrl: 'https://images.unsplash.com/photo-1518676590629-3dcbd9c5a5c9?w=1200',
        durationMinutes: 166,
        releaseDate: '01/09/2025',
        ageRating: 'T13',
        rating: 8.8,
        voteCount: 980,
        country: 'Thái Lan',
        productionStudio: 'GDH 559 & Broadcast Thai Television',
        genres: const ['Hài Hước', 'Lãng Mạn', 'Cổ Trang'],
        director: 'Adisorn Tresirikasem',
        cast: const [
          'Pope Thanavat',
          'Bella Ranee',
          'Ice Paris',
          'Nonkul Chanon',
        ],
        synopsis: 'Kiếp sau của cặp đôi định mệnh Dech và Karaket ở thời kỳ đầu vương triều Rattanakosin. Chàng Bhop tin rằng cô gái xinh đẹp xuất hiện trong giấc mơ của mình chính là định mệnh kiếp trước, tạo nên vô số tình huống tán tỉnh hài hước dở khóc dở cười.',
        status: CinemaMovieStatus.nowShowing,
        formats: const ['2D Lồng Tiếng', '2D Phụ Đề'],
      ),

      // 17. Thiên Tài Bất Hảo (Thái Lan — Bad Genius)
      CinemaMovieModel(
        id: 'cm_thien_tai_bat_hao',
        title: 'Thiên Tài Bất Hảo (Bad Genius)',
        posterUrl: 'https://images.unsplash.com/photo-1434030216411-0b793f4b4173?w=600',
        trailerUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
        backdropUrl: 'https://images.unsplash.com/photo-1485846234645-a62644f84728?w=1200',
        durationMinutes: 130,
        releaseDate: '15/05/2025',
        ageRating: 'T13',
        rating: 9.0,
        voteCount: 1480,
        country: 'Thái Lan',
        productionStudio: 'GDH 559',
        genres: const ['Giật Gân', 'Tội Phạm', 'Học Đường'],
        director: 'Nattawut Poonpiriya',
        cast: const [
          'Chutimon Chuengcharoensukying',
          'Chanon Santinatornkul',
          'Teeradon Supapunpinyo',
        ],
        synopsis: 'Lynn – nữ sinh học bổng thiên tài vạch ra đường dây quay cóp kỳ thi quốc tế STIC xuyên múi giờ trị giá hàng triệu Baht. Một tác phẩm giật gân kịch tính nghẹt thở biến phòng thi thành đấu trường trí tuệ sinh tử.',
        status: CinemaMovieStatus.nowShowing,
        formats: const ['2D Phụ Đề', 'IMAX 2D'],
      ),

      // 18. Tình Người Duyên Ma (Thái Lan — Pee Mak)
      CinemaMovieModel(
        id: 'cm_tinh_nguoi_duyen_ma',
        title: 'Tình Người Duyên Ma (Pee Mak)',
        posterUrl: 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?w=600',
        trailerUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
        backdropUrl: 'https://images.unsplash.com/photo-1536440136628-849c177e76a1?w=1200',
        durationMinutes: 115,
        releaseDate: '21/06/2025',
        ageRating: 'T13',
        rating: 9.1,
        voteCount: 1890,
        country: 'Thái Lan',
        productionStudio: 'GMM Tai Hub (GTH)',
        genres: const ['Hài Hước', 'Kinh Dị', 'Tình Cảm'],
        director: 'Banjong Pisanthanakun',
        cast: const ['Mario Maurer', 'Davika Hoorne', 'Pongsatorn Jongwilas'],
        synopsis: 'Huyền thoại phòng vé Thái Lan mọi thời đại. Mak trở về quê nhà sau chiến tranh cùng 4 người bạn thân mà không hay biết người vợ Nak yêu dấu của mình đã qua đời và trở thành một hồn ma lưu luyến chốn trần gian.',
        status: CinemaMovieStatus.nowShowing,
        formats: const ['2D Lồng Tiếng', '2D Phụ Đề'],
      ),

      // 19. Bà Bầu Siêu Quậy (Thái Lan — Sắp Chiếu)
      CinemaMovieModel(
        id: 'cm_ba_bau_sieu_quay',
        title: 'Bà Bầu Siêu Quậy (MOM)',
        posterUrl: 'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?w=600',
        trailerUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
        backdropUrl: 'https://images.unsplash.com/photo-1517457373958-b7bdd4587205?w=1200',
        durationMinutes: 108,
        releaseDate: '12/12/2026',
        ageRating: 'T16',
        rating: 8.5,
        voteCount: 310,
        country: 'Thái Lan',
        productionStudio: 'GDH 559',
        genres: const ['Hài Hước', 'Lãng Mạn', 'Gia Đình'],
        director: 'Thitipong Kerdtongtawee',
        cast: const ['Baifern Pimchanok', 'Mario Maurer'],
        synopsis: 'Màn tái hợp sau hơn 10 năm của cặp đôi vàng Mario Maurer và Baifern Pimchanok trong câu chuyện tình yêu dở khóc dở cười của một cô nàng mang thai bất đắc dĩ và chàng bác sĩ khoa sản vui tính.',
        status: CinemaMovieStatus.comingSoon,
        formats: const ['2D Phụ Đề'],
      ),

      // 20. Học Kỳ Sinh Tử: Trại Huấn Luyện Quỷ (Thái Lan — Sắp Chiếu)
      CinemaMovieModel(
        id: 'cm_hoc_ky_sinh_tu',
        title: 'Học Kỳ Sinh Tử: Trại Huấn Luyện Quỷ',
        posterUrl: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=600',
        trailerUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
        backdropUrl: 'https://images.unsplash.com/photo-1478760329108-5c3ed9d495a0?w=1200',
        durationMinutes: 115,
        releaseDate: '28/11/2026',
        ageRating: 'T18',
        rating: 8.3,
        voteCount: 260,
        country: 'Thái Lan',
        productionStudio: 'Five Star Production',
        genres: const ['Kinh Dị', 'Sinh Tồn', 'Giật Gân'],
        director: 'Kongkiat Komesiri',
        cast: const ['Gulf Kanawut', 'Nanon Korapat', 'Chimon Wachirawit'],
        synopsis: 'Nhóm học sinh trung học tham gia kỳ trại hè quân sự sinh tồn trong một khu rừng cấm bí ẩn. Khi đêm buông xuống, những lời nguyền cổ xưa trỗi dậy biến khóa huấn luyện thành cuộc săn đuổi sinh tử tàn bạo.',
        status: CinemaMovieStatus.comingSoon,
        formats: const ['2D Phụ Đề', 'IMAX 2D'],
      ),

      // 21. Nhà Bà Nữ (Việt Nam — Kỷ Lục 475 Tỷ Doanh Thu)
      CinemaMovieModel(
        id: 'cm_nha_ba_nu',
        title: 'Nhà Bà Nữ',
        posterUrl: 'https://images.unsplash.com/photo-1579783902614-a3fb3927b675?w=600',
        trailerUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
        backdropUrl: 'https://images.unsplash.com/photo-1517604931442-7e0c8ed2963c?w=1200',
        durationMinutes: 102,
        releaseDate: '22/01/2025',
        ageRating: 'T16',
        rating: 8.9,
        voteCount: 1950,
        country: 'Việt Nam',
        productionStudio: 'Trấn Thành Town & CJ HK Entertainment',
        genres: const ['Tâm Lý', 'Gia Đình', 'Hài Hước'],
        director: 'Trấn Thành',
        cast: const [
          'Trấn Thành',
          'Uyển Ân',
          'Song Luân',
          'Lê Giang',
          'NSND Ngọc Giàu',
        ],
        synopsis: 'Bà Nữ làm nghề bán bánh canh cua gia truyền, một mình chèo chống gia đình 3 thế hệ phụ nữ. Sự áp đặt và kỳ vọng khắt khe của bà khiến con gái út Nhi luôn khao khát thoát ly để tự do yêu đương, dẫn đến những xung đột gia đình gay gắt nhưng chân thực đến rơi nước mắt.',
        status: CinemaMovieStatus.nowShowing,
        formats: const ['2D Lồng Tiếng', '2D Phụ Đề'],
      ),

      // 22. Bố Già: The Movie (Việt Nam — Kỷ Lục 427 Tỷ)
      CinemaMovieModel(
        id: 'cm_bo_gia',
        title: 'Bố Già (Bo Gia: The Movie)',
        posterUrl: 'https://images.unsplash.com/photo-1517604931442-7e0c8ed2963c?w=600',
        trailerUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
        backdropUrl: 'https://images.unsplash.com/photo-1536440136628-849c177e76a1?w=1200',
        durationMinutes: 128,
        releaseDate: '05/03/2025',
        ageRating: 'T13',
        rating: 9.0,
        voteCount: 2200,
        country: 'Việt Nam',
        productionStudio: 'Trấn Thành Town & HKFilm',
        genres: const ['Tình Cảm', 'Gia Đình', 'Chữa Lành'],
        director: 'Vũ Ngọc Đãng, Trấn Thành',
        cast: const [
          'Trấn Thành',
          'Tuấn Trần',
          'NSND Ngọc Giàu',
          'Lan Phương',
          'Hoàng Mèo',
        ],
        synopsis: 'Câu chuyện về tình cha con trong con hẻm nghèo xóm lao động Sài Gòn. Ba Sang thương con nhưng bảo thủ, vụng về trong cách thể hiện tình cảm, còn Quắn đại diện cho thế hệ trẻ tự lập và bốc đồng. Một tác phẩm điện ảnh chạm tới nơi sâu thẳm nhất tình phụ tử.',
        status: CinemaMovieStatus.nowShowing,
        formats: const ['2D Lồng Tiếng', '2D Phụ Đề'],
      ),

      // 23. Gặp Lại Chị Bầu (Việt Nam)
      CinemaMovieModel(
        id: 'cm_gap_lai_chi_bau',
        title: 'Gặp Lại Chị Bầu',
        posterUrl: 'https://images.unsplash.com/photo-1485846234645-a62644f84728?w=600',
        trailerUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
        backdropUrl: 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?w=1200',
        durationMinutes: 114,
        releaseDate: '10/02/2026',
        ageRating: 'T13',
        rating: 8.6,
        voteCount: 780,
        country: 'Việt Nam',
        productionStudio: '1984 Pictures',
        genres: const ['Hài Hước', 'Lãng Mạn', 'Xuyên Không'],
        director: 'Đoàn Nhất Trung',
        cast: const [
          'Anh Tú',
          'Diệu Nhi',
          'Ngọc Phước',
          'Quốc Khánh',
          'Lê Giang',
        ],
        synopsis: 'Phúc – chàng diễn viên quần chúng mồ côi gặp tai nạn bất ngờ rơi vào dòng xoáy thời gian trở về Sài Gòn năm 1997. Tại đây, anh gặp gỡ Huyền và phát hiện ra bí mật cuộc đời mình cùng tình mẫu tử thiêng liêng mà anh chưa từng được biết.',
        status: CinemaMovieStatus.nowShowing,
        formats: const ['2D Lồng Tiếng', '2D Phụ Đề'],
      ),

      // 24. Hai Muối (Việt Nam)
      CinemaMovieModel(
        id: 'cm_hai_muoi',
        title: 'Hai Muối: Nước Mắt Hạt Muối',
        posterUrl: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=600',
        trailerUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyBlazes.mp4',
        backdropUrl: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=1200',
        durationMinutes: 118,
        releaseDate: '30/08/2026',
        ageRating: 'T13',
        rating: 8.7,
        voteCount: 650,
        country: 'Việt Nam',
        productionStudio: 'D&D Entertainment',
        genres: const ['Tâm Lý', 'Gia Đình', 'Xúc Động'],
        director: 'Vũ Thành Vinh',
        cast: const ['Quyền Linh', 'Hồng Vân', 'NSND Việt Anh', 'Bảo Ngọc'],
        synopsis: 'Màn tái xuất màn ảnh rộng sau 20 năm của nghệ sĩ Quyền Linh trong vai người cha diêm dân nghèo khó trên cánh đồng muối ấp Thiềng Liềng. Những giọt mồ hôi mặn chát cùng đức hy sinh vô bờ bến của người cha nuôi con gái ăn học thành tài.',
        status: CinemaMovieStatus.nowShowing,
        formats: const ['2D Phụ Đề'],
      ),

      // 25. Làm Giàu Với Ma (Việt Nam)
      CinemaMovieModel(
        id: 'cm_lam_giau_voi_ma',
        title: 'Làm Giàu Với Ma',
        posterUrl: 'https://images.unsplash.com/photo-1518676590629-3dcbd9c5a5c9?w=600',
        trailerUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
        backdropUrl: 'https://images.unsplash.com/photo-1478760329108-5c3ed9d495a0?w=1200',
        durationMinutes: 112,
        releaseDate: '02/09/2026',
        ageRating: 'T16',
        rating: 8.4,
        voteCount: 720,
        country: 'Việt Nam',
        productionStudio: 'Mockingbird Pictures',
        genres: const ['Hài Hước', 'Kinh Dị', 'Gia Đình'],
        director: 'Trung Lùn',
        cast: const ['Hoài Linh', 'Tuấn Trần', 'Diệp Bảo Ngọc', 'Lê Giang'],
        synopsis: 'Lanh – chàng thanh niên nợ nần cờ bạc tình cờ gặp ma nữ Na. Cả hai lập giao kèo kỳ quái: Na giúp Lanh kiếm tiền tỷ mỗi ngày, đổi lại Lanh phải giúp Na hoàn thành tâm nguyện trước khi siêu thoát. Hàng loạt tình huống dở khóc dở cười xen lẫn xúc động nổ ra.',
        status: CinemaMovieStatus.nowShowing,
        formats: const ['2D Lồng Tiếng', '2D Phụ Đề'],
      ),

      // 26. Quỷ Cẩu (Việt Nam — Hiện Tượng Kinh Dị 110 Tỷ)
      CinemaMovieModel(
        id: 'cm_quy_cau',
        title: 'Quỷ Cẩu: Chó Đội Nón Mê',
        posterUrl: 'https://images.unsplash.com/photo-1509281373149-e957c6296406?w=600',
        trailerUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
        backdropUrl: 'https://images.unsplash.com/photo-1518676590629-3dcbd9c5a5c9?w=1200',
        durationMinutes: 108,
        releaseDate: '29/12/2025',
        ageRating: 'T18',
        rating: 8.2,
        voteCount: 890,
        country: 'Việt Nam',
        productionStudio: 'F35 Studio',
        genres: const ['Kinh Dị', 'Tâm Linh', 'Dân Gian'],
        director: 'Lưu Thành Luân',
        cast: const [
          'Quang Tuấn',
          'Nam Thư',
          'NSND Kim Xuân',
          'Quốc Quân',
          'Mie',
        ],
        synopsis: 'Lấy cảm hứng từ truyền thuyết đô thị ghê rợn "Chó đội nón mê" của người Việt. Sau cái chết bất đắc kỳ tử của ông chủ lò mổ chó, gia đình bắt đầu bị một thế lực tà ác mang hình hài linh cẩu trắng quấy nhiễu, trừng phạt từng thành viên theo luật nhân quả báo ứng rùng rợn.',
        status: CinemaMovieStatus.nowShowing,
        formats: const ['2D Phụ Đề'],
      ),

      // 27. Đất Rừng Phương Nam (Việt Nam — Đại Cảnh Điện Ảnh)
      CinemaMovieModel(
        id: 'cm_dat_rung_phuong_nam',
        title: 'Đất Rừng Phương Nam',
        posterUrl: 'https://images.unsplash.com/photo-1440404653325-ab127d49abc1?w=600',
        trailerUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
        backdropUrl: 'https://images.unsplash.com/photo-1517604931442-7e0c8ed2963c?w=1200',
        durationMinutes: 134,
        releaseDate: '20/10/2025',
        ageRating: 'K',
        rating: 8.5,
        voteCount: 1320,
        country: 'Việt Nam',
        productionStudio: 'HKFilm & Galaxy Studio',
        genres: const ['Phiêu Lưu', 'Lịch Sử', 'Gia Đình'],
        director: 'Nguyễn Quang Dũng',
        cast: const [
          'Hạo Khang',
          'Tuấn Trần',
          'Trấn Thành',
          'Tiến Luật',
          'Băng Di',
        ],
        synopsis: 'Hành trình lưu lạc tìm cha đầy cảm xúc của cậu bé An giữa thiên nhiên Nam Bộ trù phú, hào sảng những năm đầu thế kỷ 20. Trên đường đi, An kết bạn với Út Lục Lâm, bác Ba Phi và hòa mình vào phong trào yêu nước kiên cường của người dân Nam Kỳ.',
        status: CinemaMovieStatus.imax,
        formats: const ['IMAX 2D', '2D Lồng Tiếng'],
      ),

      // 28. Siêu Lừa Gặp Siêu Lầy (Việt Nam)
      CinemaMovieModel(
        id: 'cm_sieu_lua',
        title: 'Siêu Lừa Gặp Siêu Lầy',
        posterUrl: 'https://images.unsplash.com/photo-1536440136628-849c177e76a1?w=600',
        trailerUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
        backdropUrl: 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?w=1200',
        durationMinutes: 112,
        releaseDate: '03/03/2025',
        ageRating: 'T16',
        rating: 8.3,
        voteCount: 790,
        country: 'Việt Nam',
        productionStudio: 'CJ HK Entertainment',
        genres: const ['Hài Hước', 'Hành Động', 'Tội Phạm'],
        director: 'Võ Thanh Hòa',
        cast: const ['Anh Tú', 'Mạc Văn Khoa', 'Ngọc Phước', 'Nhất Trung'],
        synopsis: 'Khoa – tay lừa đảo nghiệp dư đến Phú Quốc mưu sinh thì đụng độ Tú – bậc thầy lừa đảo lịch lãm, tinh vi. Cả hai kết hợp cùng hai đồng đội quái chiêu tạo nên bộ tứ lừa đảo lầy lội, nhắm đến phi vụ triệu đô chấn động đảo ngọc.',
        status: CinemaMovieStatus.nowShowing,
        formats: const ['2D Lồng Tiếng', '2D Phụ Đề'],
      ),

      // 29. Kính Vạn Hoa: Bản Điện Ảnh (Việt Nam — Sắp Chiếu)
      CinemaMovieModel(
        id: 'cm_kinh_van_hoa',
        title: 'Kính Vạn Hoa: Bản Điện Ảnh',
        posterUrl: 'https://images.unsplash.com/photo-1485846234645-a62644f84728?w=600',
        trailerUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
        backdropUrl: 'https://images.unsplash.com/photo-1517457373958-b7bdd4587205?w=1200',
        durationMinutes: 118,
        releaseDate: '25/12/2026',
        ageRating: 'P',
        rating: 8.8,
        voteCount: 450,
        country: 'Việt Nam',
        productionStudio: 'Galaxy Studio & CineFlix Studios',
        genres: const ['Học Đường', 'Phiêu Lưu', 'Tuổi Thơ'],
        director: 'Võ Thanh Hòa',
        cast: const ['Hùng Thuận', 'Vũ Long', 'Anh Đào'],
        synopsis: 'Tác phẩm chuyển thể điện ảnh kinh điển từ bộ truyện của nhà văn Nguyễn Nhật Ánh. Bộ ba Quý rơm, Tiểu Long và nhỏ Hạnh bước vào kỳ nghỉ hè phá án ly kỳ, gợi lại ký ức thanh xuân trong trẻo của bao thế hệ học sinh Việt Nam.',
        status: CinemaMovieStatus.comingSoon,
        formats: const ['2D Lồng Tiếng'],
      ),

      // 30. Chị Dâu (Việt Nam — Sắp Chiếu Tết)
      CinemaMovieModel(
        id: 'cm_chi_dau',
        title: 'Chị Dâu: Sóng Gió Hào Môn',
        posterUrl: 'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?w=600',
        trailerUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
        backdropUrl: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=1200',
        durationMinutes: 110,
        releaseDate: '17/02/2026',
        ageRating: 'T16',
        rating: 8.4,
        voteCount: 320,
        country: 'Việt Nam',
        productionStudio: 'Sóng Vàng Production',
        genres: const ['Tâm Lý', 'Gia Đình', 'Kịch Tính'],
        director: 'Lê Thiện Viễn',
        cast: const ['Việt Hương', 'Hồng Đào', 'Lê Khánh', 'Uyển Ân'],
        synopsis: 'Cuộc chiến ngầm nhưng không kém phần gay gắt giữa mẹ chồng và nàng dâu trong một gia tộc giàu có lâu đời miền Tây Nam Bộ, vén màn những toan tính tài sản và bí mật chôn giấu suốt ba thập kỷ.',
        status: CinemaMovieStatus.comingSoon,
        formats: const ['2D Phụ Đề'],
      ),

      // ================== THÊM PHIM THÁI LAN BOM TẤN ==================
      // 31. Yêu Nhầm Bạn Thân (Thái Lan — Friend Zone)
      CinemaMovieModel(
        id: 'cm_friend_zone',
        title: 'Yêu Nhầm Bạn Thân (Friend Zone)',
        posterUrl: 'https://images.unsplash.com/photo-1517457373958-b7bdd4587205?w=600',
        trailerUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
        backdropUrl: 'https://images.unsplash.com/photo-1518676590629-3dcbd9c5a5c9?w=1200',
        durationMinutes: 119,
        releaseDate: '15/03/2025',
        ageRating: 'T13',
        rating: 9.1,
        voteCount: 1780,
        country: 'Thái Lan',
        productionStudio: 'GDH 559',
        genres: const ['Hài Hước', 'Lãng Mạn', 'Bạn Thân'],
        director: 'Chayanop Boonprakob',
        cast: const ['Baifern Pimchanok', 'Nine Naphat', 'Jason Young'],
        synopsis: 'Palm mắc kẹt trong ranh giới "bạn thân" suốt 10 năm với Gink. Bất kể khi nào Gink gặp rắc rối tình cảm ở bất cứ đâu trên thế giới, Palm đều lập tức bay tới ở bên cô. Bộ phim hài lãng mạn phá đảo phòng vé Đông Nam Á với sự góp giọng của ca sĩ Chi Pu.',
        status: CinemaMovieStatus.nowShowing,
        formats: const ['2D Lồng Tiếng', '2D Phụ Đề'],
      ),

      // 32. Daeng: Hậu Duệ Tình Người Duyên Ma (Thái Lan)
      CinemaMovieModel(
        id: 'cm_daeng',
        title: 'Daeng: Hậu Duệ Tình Người Duyên Ma',
        posterUrl: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=600',
        trailerUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
        backdropUrl: 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?w=1200',
        durationMinutes: 98,
        releaseDate: '20/05/2025',
        ageRating: 'T13',
        rating: 8.5,
        voteCount: 840,
        country: 'Thái Lan',
        productionStudio: 'M Pictures',
        genres: const ['Hài Hước', 'Kinh Dị', 'Gia Đình'],
        director: 'X Wattanapong',
        cast: const ['Nong Melik', 'Mum Jokmok', 'Phu Chatchai'],
        synopsis: 'Phần phim tiếp nối sau Tình Người Duyên Ma, kể về Daeng – đứa con trai của ma nữ Nak. Dù là một hồn ma nhưng Daeng chỉ muốn kết bạn với lũ trẻ trong làng Phra Khanong và khao khát được công nhận như một đứa trẻ bình thường.',
        status: CinemaMovieStatus.nowShowing,
        formats: const ['2D Lồng Tiếng', '2D Phụ Đề'],
      ),

      // 33. Lừa Đểu Gặp Lừa Đảo (Thái Lan — The Con-Heartist)
      CinemaMovieModel(
        id: 'cm_con_heartist',
        title: 'Lừa Đểu Gặp Lừa Đảo (The Con-Heartist)',
        posterUrl: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=600',
        trailerUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
        backdropUrl: 'https://images.unsplash.com/photo-1485846234645-a62644f84728?w=1200',
        durationMinutes: 128,
        releaseDate: '22/01/2025',
        ageRating: 'T16',
        rating: 8.8,
        voteCount: 1120,
        country: 'Thái Lan',
        productionStudio: 'GDH 559',
        genres: const ['Hài Hước', 'Đấu Trí', 'Lãng Mạn'],
        director: 'Mez Tharatorn',
        cast: const [
          'Nadech Kugimiya',
          'Baifern Pimchanok',
          'Thiti Mahayotaruk',
        ],
        synopsis: 'Ina – cô nàng nhân viên ngân hàng ngây thơ bị bạn trai cũ lừa một khoản tiền lớn. Cô bắt tay với Tower – một siêu lừa đảo đào hoa chuyên nghiệp để lên kế hoạch "gài bẫy" trả đũa gã tình cũ bạc bẽo trong một phi vụ triệu Baht cười ra nước mắt.',
        status: CinemaMovieStatus.nowShowing,
        formats: const ['2D Lồng Tiếng', '2D Phụ Đề'],
      ),

      // 34. Ngôi Đền Kỳ Quái 4 (Thái Lan — Pee Nak 4)
      CinemaMovieModel(
        id: 'cm_pee_nak_4',
        title: 'Ngôi Đền Kỳ Quái 4 (Pee Nak 4)',
        posterUrl: 'https://images.unsplash.com/photo-1518676590629-3dcbd9c5a5c9?w=600',
        trailerUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyBlazes.mp4',
        backdropUrl: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=1200',
        durationMinutes: 112,
        releaseDate: '31/05/2026',
        ageRating: 'T18',
        rating: 8.6,
        voteCount: 1350,
        country: 'Thái Lan',
        productionStudio: 'Five Star Production',
        genres: const ['Kinh Dị', 'Hài Hước', 'Tâm Linh'],
        director: 'Phontharis Chotkijsadarsopon',
        cast: const [
          'Mean Phiravich',
          'Tar Atiwat',
          'Witawat Rattanaboonbaramee',
        ],
        synopsis: 'Thương hiệu kinh dị hài lầy lội số 1 xứ Chùa Vàng trở lại. Lần này, lời nguyền mặt nạ quỷ Nak trỗi dậy tại ngôi đền cổ xưa, khiến bộ ba bạn thân phải bước vào cuộc đào tẩu tâm linh vừa rùng rợn vừa cười nghiêng ngả.',
        status: CinemaMovieStatus.nowShowing,
        formats: const ['2D Lồng Tiếng', '2D Phụ Đề'],
      ),

      // 35. Âm Hồn Nhập Xác (Thái Lan — The Medium)
      CinemaMovieModel(
        id: 'cm_the_medium',
        title: 'Âm Hồn Nhập Xác (The Medium)',
        posterUrl: 'https://images.unsplash.com/photo-1478760329108-5c3ed9d495a0?w=600',
        trailerUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
        backdropUrl: 'https://images.unsplash.com/photo-1518676590629-3dcbd9c5a5c9?w=1200',
        durationMinutes: 130,
        releaseDate: '25/10/2025',
        ageRating: 'T18',
        rating: 8.9,
        voteCount: 1560,
        country: 'Thái Lan',
        productionStudio: 'GDH 559 & Showbox',
        genres: const ['Kinh Dị', 'Tâm Linh', 'Giả Tài Liệu'],
        director: 'Banjong Pisanthanakun',
        cast: const [
          'Narilya Gulmongkolpech',
          'Sawanee Utoomma',
          'Sirani Yankittikan',
        ],
        synopsis: 'Tác phẩm hợp tác lịch sử giữa bậc thầy kinh dị Thái Lan và đạo diễn Hàn Quốc Na Hong-jin. Bộ phim theo chân đoàn làm phim tài liệu theo dõi bà đồng Nim tại vùng Isan hoang sơ, cho đến khi cháu gái Mink bắt đầu có những biểu hiện bị quỷ dữ chiếm đoạt thể xác tàn bạo.',
        status: CinemaMovieStatus.imax,
        formats: const ['IMAX 2D', '2D Phụ Đề'],
      ),

      // 36. Thần Thám Siêu Lầy (Thái Lan — Fast & Feel Love)
      CinemaMovieModel(
        id: 'cm_fast_feel_love',
        title: 'Thần Thám Siêu Lầy (Fast & Feel Love)',
        posterUrl: 'https://images.unsplash.com/photo-1434030216411-0b793f4b4173?w=600',
        trailerUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
        backdropUrl: 'https://images.unsplash.com/photo-1485846234645-a62644f84728?w=1200',
        durationMinutes: 132,
        releaseDate: '15/07/2025',
        ageRating: 'T13',
        rating: 8.4,
        voteCount: 620,
        country: 'Thái Lan',
        productionStudio: 'GDH 559',
        genres: const ['Hài Hước', 'Hành Động', 'Tình Cảm'],
        director: 'Nawapol Thamrongrattanarit',
        cast: const ['Nat Kitcharit', 'Urassaya Sperbund (Yaya)'],
        synopsis: 'Kao – nhà vô địch thế giới bộ môn xếp cốc tốc độ (Sport Stacking) gặp khủng hoảng khi người bạn gái 10 năm quyết định chia tay. Một bộ phim hài giễu nhại các bom tấn hành động Hollywood với tiết tấu siêu nhanh và góc nhìn độc đáo.',
        status: CinemaMovieStatus.nowShowing,
        formats: const ['2D Phụ Đề'],
      ),

      // 37. Linh Hồn Tạm Trú (Thái Lan — Homestay)
      CinemaMovieModel(
        id: 'cm_homestay',
        title: 'Linh Hồn Tạm Trú (Homestay)',
        posterUrl: 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?w=600',
        trailerUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
        backdropUrl: 'https://images.unsplash.com/photo-1517604931442-7e0c8ed2963c?w=1200',
        durationMinutes: 136,
        releaseDate: '10/11/2025',
        ageRating: 'T16',
        rating: 8.7,
        voteCount: 890,
        country: 'Thái Lan',
        productionStudio: 'GDH 559',
        genres: const ['Kỳ Ảo', 'Giật Gân', 'Bí Ẩn'],
        director: 'Parkpoom Wongpoom',
        cast: const ['James Teeradon', 'BNK48 Cherprang', 'Suquan Bulakul'],
        synopsis: 'Một linh hồn lang thang được Người Gác Cổng trao cơ hội hồi sinh trong thể xác của nam sinh Min vừa tự tử. Trong vòng 100 ngày, linh hồn phải tìm ra kẻ đã bức tử Min, nếu không sẽ vĩnh viễn tan biến vào hư vô.',
        status: CinemaMovieStatus.nowShowing,
        formats: const ['2D Phụ Đề', 'IMAX 2D'],
      ),

      // 38. Nụ Hôn Ma Quái (Thái Lan — Inhuman Kiss)
      CinemaMovieModel(
        id: 'cm_inhuman_kiss',
        title: 'Nụ Hôn Ma Quái (Inhuman Kiss)',
        posterUrl: 'https://images.unsplash.com/photo-1518676590629-3dcbd9c5a5c9?w=600',
        trailerUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
        backdropUrl: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=1200',
        durationMinutes: 122,
        releaseDate: '14/02/2026',
        ageRating: 'T18',
        rating: 8.8,
        voteCount: 950,
        country: 'Thái Lan',
        productionStudio: 'Transformation Films',
        genres: const ['Kinh Dị', 'Lãng Mạn', 'Dân Gian'],
        director: 'Sitisiri Mongkolsiri',
        cast: const [
          'Oabnithi Wiwattanawarang',
          'Phantira Pipityakorn',
          'Sapol Assawamunkong',
        ],
        synopsis: 'Dựa trên truyền thuyết kinh dị nổi tiếng Krasue của Thái Lan. Ban ngày Sai là thiếu nữ xinh đẹp hiền lành, nhưng khi màn đêm buông xuống, đầu và ruột cô tách rời khỏi cơ thể bay đi săn mồi trong sự giằng xé giữa tình yêu và bản năng ma quái.',
        status: CinemaMovieStatus.nowShowing,
        formats: const ['2D Phụ Đề'],
      ),
    ];

    // Mẫu vé đã đặt sẵn hiển thị trên My Tickets
    userBookings.add(
      CinemaBookingModel(
        id: 'bk_001',
        bookingCode: 'CNF-892401',
        movieId: 'cm_an_mang',
        movieTitle: 'Án Mạng Xém Hoàn Hảo',
        posterUrl: 'https://images.unsplash.com/photo-1536440136628-849c177e76a1?w=600',
        theaterName: 'CineFlix Thiso Mall Sala',
        theaterAddress:
            'Tầng 3, Thiso Mall Sala, 10 Mai Chí Thọ, TP Thủ Đức, TP.HCM',
        hallName: 'VIP - LAURUS',
        format: '2D Phụ Đề',
        showtime: '14:45',
        date: DateTime.now(),
        seatLabels: const ['G08', 'G09'],
        concessions: const {'combo_couple': 1},
        totalAmount: 339000,
        paymentMethod: 'Ví MoMo',
        qrCodeData: 'CNF-892401-G08G09-SALA-VIP',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        isUsed: false,
      ),
    );
  }

  // Lấy suất chiếu rạp theo phim và rạp (Khớp Screenshot 3)
  List<CinemaShowtimeModel> getShowtimes({
    required String movieId,
    required String theaterId,
    required DateTime date,
  }) {
    // Trả về các suất chiếu chân thực như trong Screenshot 3:
    // CineFlix Hanoi Centre -> VIP - AQUALIS 2D Phụ Đề -> 16:15
    // CineFlix Thiso Mall Sala -> VIP - LAURUS 2D Phụ Đề -> 14:45
    // CineFlix AEON Mall Thanh Khê -> VIP X-HARBOR 1 2D Phụ Đề -> 10:00
    if (theaterId == 'cnf_hn_centre') {
      return [
        CinemaShowtimeModel(
          id: 'st_hn_1',
          movieId: movieId,
          theaterId: theaterId,
          hallName: 'VIP - AQUALIS',
          format: '2D Phụ Đề',
          time: '16:15',
          date: date,
          basePrice: 110000,
        ),
        CinemaShowtimeModel(
          id: 'st_hn_2',
          movieId: movieId,
          theaterId: theaterId,
          hallName: 'HALL 03',
          format: '2D Phụ Đề',
          time: '19:45',
          date: date,
          basePrice: 95000,
        ),
      ];
    } else if (theaterId == 'cnf_thiso_sala') {
      return [
        CinemaShowtimeModel(
          id: 'st_sala_1',
          movieId: movieId,
          theaterId: theaterId,
          hallName: 'VIP - LAURUS',
          format: '2D Phụ Đề',
          time: '14:45',
          date: date,
          basePrice: 110000,
        ),
        CinemaShowtimeModel(
          id: 'st_sala_2',
          movieId: movieId,
          theaterId: theaterId,
          hallName: 'CINEX SUITE 01',
          format: 'VIP 2D Phụ Đề',
          time: '18:10',
          date: date,
          basePrice: 130000,
        ),
        CinemaShowtimeModel(
          id: 'st_sala_3',
          movieId: movieId,
          theaterId: theaterId,
          hallName: 'VIP - LAURUS',
          format: '2D Phụ Đề',
          time: '21:30',
          date: date,
          basePrice: 110000,
        ),
      ];
    } else if (theaterId == 'cnf_aeon_danang') {
      return [
        CinemaShowtimeModel(
          id: 'st_dn_1',
          movieId: movieId,
          theaterId: theaterId,
          hallName: 'VIP X-HARBOR 1',
          format: '2D Phụ Đề',
          time: '10:00',
          date: date,
          basePrice: 95000,
        ),
        CinemaShowtimeModel(
          id: 'st_dn_2',
          movieId: movieId,
          theaterId: theaterId,
          hallName: 'VIP X-HARBOR 1',
          format: '2D Phụ Đề',
          time: '15:20',
          date: date,
          basePrice: 110000,
        ),
      ];
    }

    return [
      CinemaShowtimeModel(
        id: 'st_gen_1',
        movieId: movieId,
        theaterId: theaterId,
        hallName: 'PREMIUM HALL',
        format: '2D Phụ Đề',
        time: '11:30',
        date: date,
        basePrice: 95000,
      ),
      CinemaShowtimeModel(
        id: 'st_gen_2',
        movieId: movieId,
        theaterId: theaterId,
        hallName: 'VIP CINEX',
        format: '2D Phụ Đề',
        time: '15:45',
        date: date,
        basePrice: 115000,
      ),
      CinemaShowtimeModel(
        id: 'st_gen_3',
        movieId: movieId,
        theaterId: theaterId,
        hallName: 'VIP CINEX',
        format: '2D Phụ Đề',
        time: '19:15',
        date: date,
        basePrice: 115000,
      ),
    ];
  }

  // Khởi tạo sơ đồ ghế ngồi phòng chiếu
  List<CinemaSeatModel> generateSeatsForShowtime(String showtimeId) {
    final List<CinemaSeatModel> seats = [];
    final rows = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'J', 'K'];

    for (int r = 0; r < rows.length; r++) {
      final rowLetter = rows[r];
      SeatType type = SeatType.standard;
      int price = 95000;
      if (r >= 3 && r <= 7) {
        type = SeatType.vip;
        price = 115000;
      } else if (r >= 8) {
        type = SeatType.sweetbox;
        price = 240000;
      }

      final colCount = (type == SeatType.sweetbox) ? 10 : 14;
      for (int c = 1; c <= colCount; c++) {
        // Một số ghế đã bán
        final isReserved =
            (r == 4 && (c == 6 || c == 7 || c == 8)) ||
            (r == 5 && (c == 7 || c == 8)) ||
            (r == 2 && c == 4);

        seats.add(
          CinemaSeatModel(
            id: '$showtimeId-$rowLetter$c',
            row: rowLetter,
            number: c,
            type: type,
            status: isReserved ? SeatStatus.reserved : SeatStatus.available,
            price: price,
          ),
        );
      }
    }
    return seats;
  }
}
