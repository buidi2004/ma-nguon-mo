"use client"

import { useRef, useState, useContext, useEffect } from "react";
import Link from 'next/link';
import Image from 'next/image';
import { useRouter, usePathname } from 'next/navigation';
import { saveContext } from "@/contexts/saveContext";
import { GENRES, COUNTRIES, YEARS } from "@/functions/getPageMovies";

const Header = () => {
    const [searchInput, setSearchInput] = useState('');
    const [genreOpen, setGenreOpen] = useState(false);
    const [countryOpen, setCountryOpen] = useState(false);
    const [exploreOpen, setExploreOpen] = useState(false);
    const [profileOpen, setProfileOpen] = useState(false);
    const [scrolled, setScrolled] = useState(false);
    const [mobileOpen, setMobileOpen] = useState(false);
    const searchInputDOM = useRef(null);
    const router = useRouter();
    const pathname = usePathname();
    const context = useContext(saveContext);

    // Scroll listener for Netflix navbar fade
    useEffect(() => {
        const handleScroll = () => {
            if (window.scrollY > 30) {
                setScrolled(true);
            } else {
                setScrolled(false);
            }
        };
        window.addEventListener('scroll', handleScroll);
        return () => window.removeEventListener('scroll', handleScroll);
    }, []);

    const handleSearchSubmit = (e) => {
        if (e.key === 'Enter' && searchInput.trim()) {
            router.push(`/tim-kiem?name=${encodeURIComponent(searchInput.trim())}`);
            setMobileOpen(false);
        }
    };

    const toggleNavbar = () => {
        setMobileOpen(!mobileOpen);
    };

    return (
        <header
            className={`fixed w-full z-50 top-0 left-0 transition-[background-color,box-shadow] duration-300 ${
                scrolled
                    ? 'bg-[#08090c]/95 backdrop-blur-xl shadow-2xl shadow-black/80' /* taste-skill-ignore: sticky header overlay */
                    : 'bg-gradient-to-b from-black/90 via-black/40 to-transparent' /* taste-skill-ignore: header scrim */
            }`}
        >
            <div className="section-container-no-py flex items-center justify-between h-16 lg:h-20">
                {/* Left: Logo & Nav Links */}
                <div className="flex items-center gap-5 xl:gap-7">
                    {/* Brand Logo */}
                    <Link href="/" className="flex items-center gap-2.5 group flex-shrink-0">
                        <Image
                            src="/brand/app_icon.png"
                            alt="OpenFlix - V Xem Phim"
                            width={44}
                            height={44}
                            priority
                            unoptimized
                            className="w-10 h-10 lg:w-11 lg:h-11 object-contain brightness-110 drop-shadow-[0_2px_8px_rgba(226,32,55,0.35)] group-hover:scale-105 transition-transform duration-200"
                        />
                        <div className="flex flex-col">
                            <span className="text-xl font-black tracking-wider text-white group-hover:text-sky-300 transition-colors">
                                OPEN<span className="text-sky-400">FLIX</span>
                            </span>
                            <span className="text-[13px] font-semibold text-slate-400 -mt-0.5">
                                Cinema Web
                            </span>
                        </div>
                    </Link>

                    {/* Desktop Navigation Links */}
                    <nav className="hidden lg:flex items-center gap-1">
                        <Link
                            href="/"
                            className={`header-link ${pathname === '/' ? 'text-sky-400 font-semibold' : ''}`}
                        >
                            Trang chủ
                        </Link>
                        <Link
                            href="/phim-le/1"
                            className={`header-link ${pathname.startsWith('/phim-le') ? 'text-sky-400 font-semibold' : ''}`}
                        >
                            Phim lẻ
                        </Link>
                        <Link
                            href="/phim-bo/1"
                            className={`header-link ${pathname.startsWith('/phim-bo') ? 'text-sky-400 font-semibold' : ''}`}
                        >
                            Phim bộ
                        </Link>
                        <Link
                            href="/rap-chieu-phim"
                            className={`header-link flex items-center gap-1.5 ${
                                pathname.startsWith('/rap-chieu-phim') ? 'text-sky-400 font-semibold' : ''
                            }`}
                        >
                            <span className="w-2 h-2 rounded-full bg-sky-400 animate-pulse" />
                            <span>Rạp & Vé</span>
                        </Link>

                        {/* Thể loại dropdown */}
                        <div
                            className="relative"
                            onMouseEnter={() => setGenreOpen(true)}
                            onMouseLeave={() => setGenreOpen(false)}
                        >
                            <button
                                className={`header-link flex items-center gap-1.5 ${
                                    pathname.startsWith('/the-loai') ? 'text-sky-400 font-semibold' : ''
                                }`}
                            >
                                <span>Thể loại</span>
                                <svg
                                    className={`w-3.5 h-3.5 transition-transform duration-200 ${genreOpen ? 'rotate-180 text-sky-400' : 'text-slate-400'}`}
                                    fill="none"
                                    stroke="currentColor"
                                    viewBox="0 0 24 24"
                                >
                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M19 9l-7 7-7-7" />
                                </svg>
                            </button>

                            {/* Dropdown Menu */}
                            {genreOpen && (
                                <div className="absolute top-full left-0 w-72 p-3 bg-[#0d1017]/95 backdrop-blur-2xl border border-white/10 rounded-2xl shadow-2xl grid grid-cols-2 gap-1 animate-fadeIn" // taste-skill-ignore: dropdown overlay menu
                                >
                                    <Link
                                        href="/the-loai"
                                        onClick={() => setGenreOpen(false)}
                                        className="col-span-2 px-3 py-2 text-[13px] font-bold text-sky-400 bg-sky-500/10 rounded-lg hover:bg-sky-500/20 text-center mb-1"
                                    >
                                        Tất cả thể loại →
                                    </Link>
                                    {GENRES.map((g) => (
                                        <Link
                                            key={g.slug}
                                            href={`/the-loai/${g.slug}/1`}
                                            onClick={() => setGenreOpen(false)}
                                            className="px-2.5 py-2 text-[13px] text-slate-300 hover:text-white hover:bg-sky-500/15 hover:text-sky-300 rounded-lg transition-colors line-clamp-1"
                                        >
                                            {g.name}
                                        </Link>
                                    ))}
                                </div>
                            )}
                        </div>

                        {/* Quốc gia dropdown */}
                        <div
                            className="relative"
                            onMouseEnter={() => setCountryOpen(true)}
                            onMouseLeave={() => setCountryOpen(false)}
                        >
                            <button
                                className={`header-link flex items-center gap-1.5 ${
                                    pathname.startsWith('/quoc-gia') ? 'text-sky-400 font-semibold' : ''
                                }`}
                            >
                                <span>Quốc gia</span>
                                <svg
                                    className={`w-3.5 h-3.5 transition-transform duration-200 ${countryOpen ? 'rotate-180 text-sky-400' : 'text-slate-400'}`}
                                    fill="none"
                                    stroke="currentColor"
                                    viewBox="0 0 24 24"
                                >
                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M19 9l-7 7-7-7" />
                                </svg>
                            </button>

                            {/* Dropdown Menu */}
                            {countryOpen && (
                                <div className="absolute top-full left-0 w-60 p-3 bg-[#0d1017]/95 backdrop-blur-2xl border border-white/10 rounded-2xl shadow-2xl grid grid-cols-2 gap-1 animate-fadeIn" // taste-skill-ignore: dropdown overlay menu
                                >
                                    <Link
                                        href="/quoc-gia"
                                        onClick={() => setCountryOpen(false)}
                                        className="col-span-2 px-3 py-2 text-[13px] font-bold text-sky-400 bg-sky-500/10 rounded-lg hover:bg-sky-500/20 text-center mb-1"
                                    >
                                        Tất cả quốc gia →
                                    </Link>
                                    {COUNTRIES.map((c) => (
                                        <Link
                                            key={c.slug}
                                            href={`/quoc-gia/${c.slug}/1`}
                                            onClick={() => setCountryOpen(false)}
                                            className="px-2.5 py-2 text-[13px] text-slate-300 hover:text-white hover:bg-sky-500/15 hover:text-sky-300 rounded-lg transition-colors line-clamp-1"
                                        >
                                            {c.name}
                                        </Link>
                                    ))}
                                </div>
                            )}
                        </div>

                        {/* Khám phá dropdown (gom gọn các chuyên mục mở rộng) */}
                        <div
                            className="relative"
                            onMouseEnter={() => setExploreOpen(true)}
                            onMouseLeave={() => setExploreOpen(false)}
                        >
                            <button
                                className={`header-link flex items-center gap-1.5 ${
                                    ['/bo-suu-tap', '/danh-gia', '/dien-vien', '/su-kien', '/trailer', '/tin-tuc', '/top-phim', '/loc-phim'].some((p) => pathname.startsWith(p))
                                        ? 'text-sky-400 font-semibold'
                                        : ''
                                }`}
                            >
                                <span>Khám phá</span>
                                <svg
                                    className={`w-3.5 h-3.5 transition-transform duration-200 ${exploreOpen ? 'rotate-180 text-sky-400' : 'text-slate-400'}`}
                                    fill="none"
                                    stroke="currentColor"
                                    viewBox="0 0 24 24"
                                >
                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M19 9l-7 7-7-7" />
                                </svg>
                            </button>

                            {exploreOpen && (
                                <div className="absolute top-full left-0 w-64 p-2.5 bg-[#0d1017]/95 backdrop-blur-2xl border border-white/10 rounded-2xl shadow-2xl space-y-1 animate-fadeIn" // taste-skill-ignore: dropdown overlay menu
                                >
                                    <Link href="/phim-moi/1" onClick={() => setExploreOpen(false)} className="block px-3 py-2 text-[13px] text-slate-200 hover:text-white hover:bg-sky-500/15 rounded-lg transition-colors font-medium">
                                        Phim mới cập nhật
                                    </Link>
                                    <Link href="/top-phim/1" onClick={() => setExploreOpen(false)} className="block px-3 py-2 text-[13px] text-amber-400 hover:bg-amber-500/10 rounded-lg transition-colors font-semibold">
                                        Bảng xếp hạng Top Phim
                                    </Link>
                                    <Link href="/bo-suu-tap" onClick={() => setExploreOpen(false)} className="block px-3 py-2 text-[13px] text-slate-200 hover:text-white hover:bg-sky-500/15 rounded-lg transition-colors font-medium">
                                        Vũ trụ & Bộ sưu tập phim
                                    </Link>
                                    <Link href="/danh-gia" onClick={() => setExploreOpen(false)} className="block px-3 py-2 text-[13px] text-slate-200 hover:text-white hover:bg-sky-500/15 rounded-lg transition-colors font-medium">
                                        Cộng đồng đánh giá phim
                                    </Link>
                                    <Link href="/dien-vien" onClick={() => setExploreOpen(false)} className="block px-3 py-2 text-[13px] text-slate-200 hover:text-white hover:bg-sky-500/15 rounded-lg transition-colors font-medium">
                                        Hồ sơ diễn viên & đạo diễn
                                    </Link>
                                    <Link href="/trailer" onClick={() => setExploreOpen(false)} className="block px-3 py-2 text-[13px] text-slate-200 hover:text-white hover:bg-sky-500/15 rounded-lg transition-colors font-medium">
                                        Trailer 4K chính thức
                                    </Link>
                                    <Link href="/tin-tuc" onClick={() => setExploreOpen(false)} className="block px-3 py-2 text-[13px] text-slate-200 hover:text-white hover:bg-sky-500/15 rounded-lg transition-colors font-medium">
                                        Tin tức & Hậu trường
                                    </Link>
                                    <Link href="/su-kien" onClick={() => setExploreOpen(false)} className="block px-3 py-2 text-[13px] text-slate-200 hover:text-white hover:bg-sky-500/15 rounded-lg transition-colors font-medium">
                                        Sự kiện & Ưu đãi rạp
                                    </Link>
                                    <Link href="/loc-phim" onClick={() => setExploreOpen(false)} className="block px-3 py-2 text-[13px] text-sky-400 bg-sky-500/10 hover:bg-sky-500/20 rounded-lg transition-colors font-semibold text-center mt-1">
                                        Bộ lọc phim nâng cao →
                                    </Link>
                                </div>
                            )}
                        </div>
                    </nav>
                </div>

                {/* Right: Search + Notifications + Saved + Profile + Mobile Toggle */}
                <div className="flex items-center gap-2 sm:gap-2.5">
                    {/* Search Input Bar (Desktop) */}
                    <div className="relative hidden md:flex items-center">
                        <input
                            type="text"
                            className="w-40 lg:w-48 xl:w-56 pl-9 pr-3.5 py-1.5 text-[13px] text-white rounded-full bg-white/[0.08] border border-white/15 focus:border-sky-400 focus:bg-slate-900/90 focus:w-64 focus:outline-none transition-[width,background-color,border-color] duration-200 placeholder:text-slate-400"
                            placeholder="Tìm tên phim, diễn viên..."
                            value={searchInput}
                            onChange={(e) => setSearchInput(e.target.value)}
                            onKeyDown={handleSearchSubmit}
                            ref={searchInputDOM}
                        />
                        <button
                            aria-label="Tìm kiếm"
                            onClick={() => {
                                if (searchInput.trim()) {
                                    router.push(`/tim-kiem?name=${encodeURIComponent(searchInput.trim())}`);
                                }
                            }}
                            className="absolute left-3 text-slate-400 hover:text-sky-300 transition-colors cursor-pointer"
                        >
                            <svg className="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
                            </svg>
                        </button>
                    </div>

                    {/* Notifications Button */}
                    <Link
                        href="/thong-bao"
                        className="relative p-2 rounded-xl bg-white/[0.08] hover:bg-white/[0.16] text-slate-300 hover:text-sky-300 border border-white/15 hover:border-sky-400/60 active:scale-95 transition-colors flex items-center justify-center cursor-pointer"
                        title="Trung tâm thông báo"
                    >
                        <svg className="w-4 h-4 fill-none stroke-current" strokeWidth="2" viewBox="0 0 24 24">
                            <path strokeLinecap="round" strokeLinejoin="round" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9" />
                        </svg>
                        <span className="absolute top-1.5 right-1.5 w-2 h-2 bg-sky-400 rounded-full" />
                    </Link>

                    {/* Watchlist Bookmark Button */}
                    <Link
                        href="/phim-da-luu"
                        className="relative p-2 rounded-xl bg-white/[0.08] hover:bg-white/[0.16] text-slate-300 hover:text-sky-300 border border-white/15 hover:border-sky-400/60 active:scale-95 transition-colors flex items-center justify-center cursor-pointer"
                        title="Phim đã lưu"
                    >
                        <svg className="w-4 h-4 fill-current" viewBox="0 0 24 24">
                            <path d="M5 5a2 2 0 012-2h10a2 2 0 012 2v16l-7-3.5L5 21V5z" />
                        </svg>
                        {context?.saveList?.length > 0 && (
                            <span className="absolute -top-1.5 -right-1.5 w-5 h-5 bg-sky-500 text-slate-950 font-black text-[13px] rounded-full flex items-center justify-center">
                                {context.saveList.length}
                            </span>
                        )}
                    </Link>

                    {/* Profile Dropdown */}
                    <div
                        className="relative"
                        onMouseEnter={() => setProfileOpen(true)}
                        onMouseLeave={() => setProfileOpen(false)}
                    >
                        <button
                            type="button"
                            onClick={() => setProfileOpen(!profileOpen)}
                            className="p-1 rounded-xl bg-white/[0.08] hover:bg-white/[0.16] border border-white/15 hover:border-sky-400/60 transition-colors flex items-center gap-1.5 cursor-pointer"
                            title="Tài khoản & Hồ sơ"
                        >
                            <div className="w-7 h-7 rounded-lg bg-sky-500/20 border border-sky-400/40 flex items-center justify-center text-[13px] font-bold text-sky-400">
                                B
                            </div>
                            <svg className={`w-3 h-3 text-slate-400 transition-transform ${profileOpen ? 'rotate-180' : ''}`} fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M19 9l-7 7-7-7" />
                            </svg>
                        </button>

                        {/* Dropdown Menu */}
                        {profileOpen && (
                            <div className="absolute top-full right-0 w-56 p-2 bg-[#0d1017]/95 backdrop-blur-2xl border border-white/10 rounded-2xl shadow-2xl space-y-1 animate-fadeIn" // taste-skill-ignore: dropdown overlay menu
                            >
                                <div className="px-3 py-2 border-b border-white/10" // taste-skill-ignore: menu section divider
                                >
                                    <p className="text-[13px] font-bold text-white">Bùi Đi</p>
                                    <p className="text-[13px] text-sky-400 font-semibold">Gói Ultra 4K Cinema</p>
                                </div>

                                <Link href="/ho-so" onClick={() => setProfileOpen(false)} className="block px-3 py-1.5 text-[13px] text-slate-300 hover:text-white hover:bg-white/5 rounded-lg transition-colors">
                                    Chuyển hồ sơ người xem
                                </Link>
                                <Link href="/tai-khoan" onClick={() => setProfileOpen(false)} className="block px-3 py-1.5 text-[13px] text-slate-300 hover:text-white hover:bg-white/5 rounded-lg transition-colors">
                                    Tài khoản & Gói cước
                                </Link>
                                <Link href="/tiep-tuc-xem" onClick={() => setProfileOpen(false)} className="block px-3 py-1.5 text-[13px] text-slate-300 hover:text-white hover:bg-white/5 rounded-lg transition-colors">
                                    Tiếp tục xem phim
                                </Link>
                                <Link href="/phim-yeu-thich" onClick={() => setProfileOpen(false)} className="block px-3 py-1.5 text-[13px] text-slate-300 hover:text-white hover:bg-white/5 rounded-lg transition-colors">
                                    Phim đã thích
                                </Link>
                                <Link href="/tai-xuong" onClick={() => setProfileOpen(false)} className="block px-3 py-1.5 text-[13px] text-slate-300 hover:text-white hover:bg-white/5 rounded-lg transition-colors">
                                    Tệp tải xuống ngoại tuyến
                                </Link>
                                <Link href="/bang-gia" onClick={() => setProfileOpen(false)} className="block px-3 py-1.5 text-[13px] text-slate-300 hover:text-white hover:bg-white/5 rounded-lg transition-colors">
                                    Bảng giá gói thành viên
                                </Link>
                                <Link href="/cai-dat" onClick={() => setProfileOpen(false)} className="block px-3 py-1.5 text-[13px] text-slate-300 hover:text-white hover:bg-white/5 rounded-lg transition-colors">
                                    Cài đặt trình phát
                                </Link>
                                <Link href="/bo-suu-tap" onClick={() => setProfileOpen(false)} className="block px-3 py-1.5 text-[13px] text-slate-300 hover:text-white hover:bg-white/5 rounded-lg transition-colors">
                                    Vũ trụ & Bộ sưu tập phim
                                </Link>
                                <Link href="/danh-gia" onClick={() => setProfileOpen(false)} className="block px-3 py-1.5 text-[13px] text-slate-300 hover:text-white hover:bg-white/5 rounded-lg transition-colors">
                                    Cộng đồng đánh giá
                                </Link>
                                <Link href="/dien-vien" onClick={() => setProfileOpen(false)} className="block px-3 py-1.5 text-[13px] text-slate-300 hover:text-white hover:bg-white/5 rounded-lg transition-colors">
                                    Hồ sơ diễn viên & đạo diễn
                                </Link>
                                <Link href="/su-kien" onClick={() => setProfileOpen(false)} className="block px-3 py-1.5 text-[13px] text-slate-300 hover:text-white hover:bg-white/5 rounded-lg transition-colors">
                                    Sự kiện & Ưu đãi rạp
                                </Link>
                                <Link href="/thanh-toan" onClick={() => setProfileOpen(false)} className="block px-3 py-1.5 text-[13px] text-slate-300 hover:text-white hover:bg-white/5 rounded-lg transition-colors">
                                    Thanh toán vé & Combo
                                </Link>
                                <Link href="/trang-thai-he-thong" onClick={() => setProfileOpen(false)} className="block px-3 py-1.5 text-[13px] text-slate-300 hover:text-white hover:bg-white/5 rounded-lg transition-colors">
                                    Trạng thái máy chủ CDN
                                </Link>
                                <div className="border-t border-white/10 pt-1" // taste-skill-ignore: menu footer divider
                                >
                                    <Link href="/dang-nhap" onClick={() => setProfileOpen(false)} className="block px-3 py-1.5 text-[13px] text-rose-400 hover:bg-rose-500/10 rounded-lg transition-colors">
                                        Đăng nhập / Thoát
                                    </Link>
                                </div>
                            </div>
                        )}
                    </div>

                    {/* Hamburger Button (Mobile / Tablet) */}
                    <button
                        type="button"
                        aria-label="Menu"
                        onClick={toggleNavbar}
                        className="lg:hidden p-2 rounded-xl bg-white/[0.08] hover:bg-white/[0.16] text-slate-300 hover:text-sky-300 border border-white/15 hover:border-sky-400/60 active:scale-95 transition-colors cursor-pointer"
                    >
                        <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            {mobileOpen ? (
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M6 18L18 6M6 6l12 12" />
                            ) : (
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M4 6h16M4 12h16M4 18h16" />
                            )}
                        </svg>
                    </button>
                </div>
            </div>

            {/* Mobile Drawer Menu */}
            {mobileOpen && (
                <div className="lg:hidden bg-[#08090c]/98 backdrop-blur-2xl border-b border-white/10 px-6 py-5 max-h-[85vh] overflow-y-auto animate-fadeIn" // taste-skill-ignore: mobile drawer overlay
                >
                    {/* Mobile Search Input */}
                    <div className="relative mb-5">
                        <input
                            type="text"
                            className="w-full pl-10 pr-4 py-2.5 text-sm text-white rounded-xl bg-slate-900 border border-white/15 focus:border-sky-400 focus:outline-none placeholder:text-slate-500"
                            placeholder="Tìm kiếm phim..."
                            value={searchInput}
                            onChange={(e) => setSearchInput(e.target.value)}
                            onKeyDown={handleSearchSubmit}
                        />
                        <button
                            onClick={() => {
                                if (searchInput.trim()) {
                                    router.push(`/tim-kiem?name=${encodeURIComponent(searchInput.trim())}`);
                                    setMobileOpen(false);
                                }
                            }}
                            className="absolute left-3 top-3 text-slate-400"
                        >
                            <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
                            </svg>
                        </button>
                    </div>

                    {/* Links */}
                    <div className="grid grid-cols-2 gap-2 text-sm font-medium">
                        <Link href="/" onClick={() => setMobileOpen(false)} className="py-2.5 px-3 rounded-lg bg-white/5 hover:bg-sky-500/20 hover:text-sky-300">
                            Trang chủ
                        </Link>
                        <Link href="/rap-chieu-phim" onClick={() => setMobileOpen(false)} className="py-2.5 px-3 rounded-lg bg-sky-500/15 text-sky-300 font-semibold border border-sky-500/30 flex items-center gap-2">
                            <span className="w-2 h-2 rounded-full bg-sky-400 animate-pulse" />
                            <span>Rạp & Đặt vé</span>
                        </Link>
                        <Link href="/rap-chieu-phim/ve-cua-toi" onClick={() => setMobileOpen(false)} className="py-2.5 px-3 rounded-lg bg-white/5 hover:bg-sky-500/20 hover:text-sky-300">
                            Vé rạp của tôi
                        </Link>
                        <Link href="/trailer" onClick={() => setMobileOpen(false)} className="py-2.5 px-3 rounded-lg bg-white/5 hover:bg-sky-500/20 hover:text-sky-300">
                            Trailer 4K
                        </Link>
                        <Link href="/tin-tuc" onClick={() => setMobileOpen(false)} className="py-2.5 px-3 rounded-lg bg-white/5 hover:bg-sky-500/20 hover:text-sky-300">
                            Tin điện ảnh
                        </Link>
                        <Link href="/loc-phim" onClick={() => setMobileOpen(false)} className="py-2.5 px-3 rounded-lg bg-white/5 hover:bg-sky-500/20 hover:text-sky-300 flex items-center gap-2">
                            <svg className="w-4 h-4 text-sky-400 fill-none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M3 4a1 1 0 011-1h16a1 1 0 011 1v2.586a1 1 0 01-.293.707l-6.414 6.414a1 1 0 00-.293.707V17l-4 4v-6.586a1 1 0 00-.293-.707L3.293 7.293A1 1 0 013 6.586V4z"/></svg>
                            <span>Bộ lọc phim</span>
                        </Link>
                        <Link href="/phim-moi/1" onClick={() => setMobileOpen(false)} className="py-2.5 px-3 rounded-lg bg-white/5 hover:bg-sky-500/20 hover:text-sky-300">
                            Phim mới
                        </Link>
                        <Link href="/top-phim/1" onClick={() => setMobileOpen(false)} className="py-2.5 px-3 rounded-lg bg-amber-500/10 text-amber-300 hover:bg-amber-500/20 flex items-center gap-2">
                            <svg className="w-4 h-4 text-amber-400 fill-current" viewBox="0 0 24 24"><path d="M12 2l2.4 7.4h7.6l-6.2 4.5 2.4 7.4-6.2-4.5-6.2 4.5 2.4-7.4-6.2-4.5h7.6z"/></svg>
                            <span>Top Phim</span>
                        </Link>
                        <Link href="/phim-le/1" onClick={() => setMobileOpen(false)} className="py-2.5 px-3 rounded-lg bg-white/5 hover:bg-sky-500/20 hover:text-sky-300">
                            Phim lẻ
                        </Link>
                        <Link href="/phim-bo/1" onClick={() => setMobileOpen(false)} className="py-2.5 px-3 rounded-lg bg-white/5 hover:bg-sky-500/20 hover:text-sky-300">
                            Phim bộ
                        </Link>
                        <Link href="/chieu-rap/1" onClick={() => setMobileOpen(false)} className="py-2.5 px-3 rounded-lg bg-white/5 hover:bg-sky-500/20 hover:text-sky-300">
                            Chiếu rạp
                        </Link>
                        <Link href="/hoat-hinh/1" onClick={() => setMobileOpen(false)} className="py-2.5 px-3 rounded-lg bg-white/5 hover:bg-sky-500/20 hover:text-sky-300">
                            Hoạt hình
                        </Link>
                        <Link href="/tiep-tuc-xem" onClick={() => setMobileOpen(false)} className="py-2.5 px-3 rounded-lg bg-white/5 hover:bg-sky-500/20 hover:text-sky-300">
                            Tiếp tục xem
                        </Link>
                        <Link href="/phim-yeu-thich" onClick={() => setMobileOpen(false)} className="py-2.5 px-3 rounded-lg bg-white/5 hover:bg-sky-500/20 hover:text-sky-300">
                            Phim đã thích
                        </Link>
                        <Link href="/tai-xuong" onClick={() => setMobileOpen(false)} className="py-2.5 px-3 rounded-lg bg-white/5 hover:bg-sky-500/20 hover:text-sky-300">
                            Tải xuống offline
                        </Link>
                        <Link href="/bang-gia" onClick={() => setMobileOpen(false)} className="py-2.5 px-3 rounded-lg bg-white/5 hover:bg-sky-500/20 hover:text-sky-300">
                            Gói cước VIP
                        </Link>
                        <Link href="/lich-su-xem" onClick={() => setMobileOpen(false)} className="py-2.5 px-3 rounded-lg bg-white/5 hover:bg-sky-500/20 hover:text-sky-300 flex items-center gap-2">
                            <svg className="w-4 h-4 text-sky-400 fill-none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
                            <span>Lịch sử xem</span>
                        </Link>
                        <Link href="/phim-da-luu" onClick={() => setMobileOpen(false)} className="py-2.5 px-3 rounded-lg bg-white/5 hover:bg-sky-500/20 hover:text-sky-300 flex items-center gap-2">
                            <svg className="w-4 h-4 text-sky-400 fill-current" viewBox="0 0 24 24"><path d="M5 5a2 2 0 012-2h10a2 2 0 012 2v16l-7-3.5L5 21V5z"/></svg>
                            <span>Đã lưu ({context?.saveList?.length || 0})</span>
                        </Link>
                    </div>

                    {/* User & Settings Quick Links */}
                    <div className="mt-5 pt-4 border-t border-white/10 flex flex-wrap gap-x-4 gap-y-2 text-[13px] text-slate-400" // taste-skill-ignore: drawer section divider
                    >
                        <Link href="/ho-so" onClick={() => setMobileOpen(false)} className="hover:text-sky-400">Hồ sơ người xem</Link>
                        <Link href="/tai-khoan" onClick={() => setMobileOpen(false)} className="hover:text-sky-400">Tài khoản</Link>
                        <Link href="/cai-dat" onClick={() => setMobileOpen(false)} className="hover:text-sky-400">Cài đặt phát</Link>
                        <Link href="/thong-bao" onClick={() => setMobileOpen(false)} className="hover:text-sky-400">Thông báo</Link>
                        <Link href="/trang-thai-he-thong" onClick={() => setMobileOpen(false)} className="hover:text-sky-400">Máy chủ CDN</Link>
                        <Link href="/faq" onClick={() => setMobileOpen(false)} className="hover:text-sky-400">Trợ giúp & FAQ</Link>
                        <Link href="/lien-he" onClick={() => setMobileOpen(false)} className="hover:text-sky-400">Liên hệ & Báo lỗi</Link>
                        <Link href="/dieu-khoan" onClick={() => setMobileOpen(false)} className="hover:text-sky-400">Điều khoản</Link>
                        <Link href="/chinh-sach-bao-mat" onClick={() => setMobileOpen(false)} className="hover:text-sky-400">Bảo mật</Link>
                    </div>
                </div>
            )}
        </header>
    );
};

export default Header;
