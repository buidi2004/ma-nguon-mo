import Link from 'next/link';
import Image from 'next/image';

const Footer = () => {
    return (
        <footer className="bg-[#050608] pt-16 pb-12 text-slate-400">
            <div className="section-container-no-py">
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-8 pb-12">
                    {/* Brand info */}
                    <div className="lg:col-span-1 space-y-4">
                        <Link href="/" className="flex items-center gap-2.5 group">
                            <Image
                                src="/brand/app_icon.png"
                                alt="OpenFlix - V Xem Phim"
                                width={48}
                                height={48}
                                unoptimized
                                className="w-12 h-12 object-contain brightness-110 drop-shadow-[0_2px_10px_rgba(226,32,55,0.35)] group-hover:scale-105 transition-transform duration-200"
                            />
                            <span className="text-2xl font-black tracking-wider text-white">
                                OPEN<span className="text-sky-400">FLIX</span>
                            </span>
                        </Link>
                        <p className="text-base text-slate-300 leading-relaxed">
                            Nền tảng xem phim trực tuyến mã nguồn mở chất lượng cao Full HD & 4K. Tích hợp trung tâm đặt vé rạp và quản lý thư viện thông minh.
                        </p>
                        
                        <Link
                            href="/trang-thai-he-thong"
                            className="inline-flex items-center gap-2 px-3 py-1.5 rounded-lg bg-emerald-500/10 hover:bg-emerald-500/20 text-emerald-400 border border-emerald-500/20 text-[13px] font-semibold transition-colors"
                        >
                            <span className="w-2 h-2 rounded-full bg-emerald-400 animate-pulse" />
                            <span>Hệ thống: Trực tuyến (99.98%)</span>
                        </Link>
                    </div>

                    {/* Column 2: Xem phim trực tuyến */}
                    <div>
                        <h3 className="text-white font-bold text-base mb-3">Phim Trực Tuyến</h3>
                        <ul className="space-y-2 text-base">
                            <li><Link href="/phim-moi/1" className="hover:text-sky-400 transition-colors">Phim mới cập nhật</Link></li>
                            <li><Link href="/chieu-rap/1" className="hover:text-sky-400 transition-colors">Phim chiếu rạp</Link></li>
                            <li><Link href="/phim-le/1" className="hover:text-sky-400 transition-colors">Phim lẻ đặc sắc</Link></li>
                            <li><Link href="/phim-bo/1" className="hover:text-sky-400 transition-colors">Phim bộ dài tập</Link></li>
                            <li><Link href="/hoat-hinh/1" className="hover:text-sky-400 transition-colors">Hoạt hình Anime</Link></li>
                            <li><Link href="/trailer" className="hover:text-sky-400 transition-colors">Trailer phim mới 4K</Link></li>
                            <li><Link href="/top-phim/1" className="hover:text-sky-400 transition-colors">Bảng xếp hạng Top phim</Link></li>
                        </ul>
                    </div>

                    {/* Column 3: Rạp chiếu & Vé điện tử */}
                    <div>
                        <h3 className="text-white font-bold text-base mb-3">Rạp Chiếu Phim</h3>
                        <ul className="space-y-2 text-base">
                            <li><Link href="/rap-chieu-phim" className="hover:text-sky-400 transition-colors font-medium text-sky-400">Lịch chiếu & Đặt vé rạp</Link></li>
                            <li><Link href="/thanh-toan" className="hover:text-sky-400 transition-colors">Thanh toán vé & Combo</Link></li>
                            <li><Link href="/rap-chieu-phim/ve-cua-toi" className="hover:text-sky-400 transition-colors">Vé rạp của tôi</Link></li>
                            <li><Link href="/su-kien" className="hover:text-sky-400 transition-colors">Sự kiện & Khuyến mãi rạp</Link></li>
                            <li><Link href="/tin-tuc" className="hover:text-sky-400 transition-colors">Tin điện ảnh & Review</Link></li>
                            <li><Link href="/danh-gia" className="hover:text-sky-400 transition-colors">Cộng đồng Đánh giá</Link></li>
                            <li><Link href="/bo-suu-tap" className="hover:text-sky-400 transition-colors">Bộ sưu tập & Vũ trụ phim</Link></li>
                            <li><Link href="/dien-vien" className="hover:text-sky-400 transition-colors">Danh bạ Diễn viên</Link></li>
                            <li><Link href="/bang-gia" className="hover:text-sky-400 transition-colors">Bảng giá gói thành viên</Link></li>
                            <li><Link href="/the-loai" className="hover:text-sky-400 transition-colors">Danh mục thể loại</Link></li>
                            <li><Link href="/quoc-gia" className="hover:text-sky-400 transition-colors">Danh mục quốc gia</Link></li>
                            <li><Link href="/loc-phim" className="hover:text-sky-400 transition-colors">Bộ lọc phim nâng cao</Link></li>
                        </ul>
                    </div>

                    {/* Column 4: Thư viện cá nhân */}
                    <div>
                        <h3 className="text-white font-bold text-base mb-3">Thư Viện Của Bạn</h3>
                        <ul className="space-y-2 text-base">
                            <li><Link href="/tiep-tuc-xem" className="hover:text-sky-400 transition-colors">Tiếp tục xem phim</Link></li>
                            <li><Link href="/phim-yeu-thich" className="hover:text-sky-400 transition-colors">Phim đã thích</Link></li>
                            <li><Link href="/phim-da-luu" className="hover:text-sky-400 transition-colors">Danh sách phim đã lưu</Link></li>
                            <li><Link href="/lich-su-xem" className="hover:text-sky-400 transition-colors">Lịch sử xem phim</Link></li>
                            <li><Link href="/tai-xuong" className="hover:text-sky-400 transition-colors">Tệp tải xuống ngoại tuyến</Link></li>
                            <li><Link href="/thong-bao" className="hover:text-sky-400 transition-colors">Thông báo & Tin mới</Link></li>
                        </ul>
                    </div>

                    {/* Column 5: Hỗ trợ & Tài khoản */}
                    <div>
                        <h3 className="text-white font-bold text-base mb-3">Tài Khoản & Hỗ Trợ</h3>
                        <ul className="space-y-2 text-base">
                            <li><Link href="/ho-so" className="hover:text-sky-400 transition-colors">Hồ sơ người xem</Link></li>
                            <li><Link href="/tai-khoan" className="hover:text-sky-400 transition-colors">Quản lý tài khoản</Link></li>
                            <li><Link href="/cai-dat" className="hover:text-sky-400 transition-colors">Cài đặt trình phát</Link></li>
                            <li><Link href="/faq" className="hover:text-sky-400 transition-colors">Trợ giúp & Phím tắt</Link></li>
                            <li><Link href="/lien-he" className="hover:text-sky-400 transition-colors">Liên hệ & Báo lỗi stream</Link></li>
                            <li><Link href="/chinh-sach-bao-mat" className="hover:text-sky-400 transition-colors">Chính sách bảo mật</Link></li>
                            <li><Link href="/dieu-khoan" className="hover:text-sky-400 transition-colors">Điều khoản & DMCA</Link></li>
                            <li><Link href="/gioi-thieu" className="hover:text-sky-400 transition-colors">Giới thiệu OpenFlix</Link></li>
                        </ul>
                    </div>
                </div>

                {/* Partner Studios — 3 logo xếp cân đối, chiều cao quang học ngang nhau */}
                <div className="mt-12 pt-8 pb-4 border-t border-white/10" /* taste-skill-ignore: divider / tab-underline chrome */
                >
                    <p className="text-center text-[13px] font-semibold text-slate-500 mb-5">
                        Nội dung phát hành &amp; đối tác
                    </p>
                    <div className="flex items-center justify-center gap-8 sm:gap-12 flex-wrap">
                        <Link href="/" className="opacity-90 hover:opacity-100 transition-opacity">
                            <Image
                                src="/brand/app_icon.png"
                                alt="OpenFlix"
                                width={44}
                                height={44}
                                unoptimized
                                className="w-11 h-11 object-contain"
                            />
                        </Link>
                        <Link href="/" className="opacity-70 hover:opacity-100 transition-opacity">
                            <Image
                                src="/brand/legendary_white.png"
                                alt="Legendary Pictures"
                                width={166}
                                height={25}
                                unoptimized
                                className="h-7 w-auto max-w-[200px] object-contain"
                            />
                        </Link>
                        <Link href="/" className="opacity-70 hover:opacity-100 transition-opacity">
                            <Image
                                src="/brand/sony_white.png"
                                alt="Sony Pictures"
                                width={175}
                                height={35}
                                unoptimized
                                className="h-[30px] w-auto max-w-[200px] object-contain"
                            />
                        </Link>
                    </div>
                </div>

                {/* Bottom Bar */}
                <div className="pt-10 flex flex-col sm:flex-row items-center justify-between text-[13px] text-slate-400 gap-4">
                    <p>© {new Date().getFullYear()} OpenFlix. Bản quyền thuộc dự án mã nguồn mở điện ảnh.</p>
                    <div className="flex flex-wrap items-center gap-4 sm:gap-6">
                        <Link href="/" className="hover:text-sky-400 transition-colors">Trang chủ</Link>
                        <Link href="/rap-chieu-phim" className="hover:text-sky-400 transition-colors">Rạp chiếu</Link>
                        <Link href="/tin-tuc" className="hover:text-sky-400 transition-colors">Tin tức</Link>
                        <Link href="/bang-gia" className="hover:text-sky-400 transition-colors">Gói cước</Link>
                        <Link href="/trang-thai-he-thong" className="hover:text-sky-400 transition-colors">Máy chủ</Link>
                        <Link href="/faq" className="hover:text-sky-400 transition-colors">Trợ giúp</Link>
                        <Link href="/lien-he" className="hover:text-sky-400 transition-colors">Liên hệ</Link>
                    </div>
                </div>
            </div>
        </footer>
    );
};

export default Footer;
