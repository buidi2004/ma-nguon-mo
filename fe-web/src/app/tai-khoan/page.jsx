'use client'

import { useState, useEffect } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";

export default function AccountPage() {
    const router = useRouter();
    const [user, setUser] = useState({
        name: "Bùi Đi",
        email: "demo@openflix.vn",
        plan: "VIP 4K Ultra Cinema",
        loggedInAt: "2026-10-01",
    });

    useEffect(() => {
        try {
            if (typeof window !== "undefined") {
                const stored = localStorage.getItem("openflix_user");
                if (stored) {
                    const parsed = JSON.parse(stored);
                    if (parsed?.email) setUser(parsed);
                }
            }
        } catch (e) {
            console.warn(e);
        }
    }, []);

    const handleLogout = () => {
        try {
            if (typeof window !== "undefined") {
                localStorage.removeItem("openflix_user");
            }
        } catch (e) {
            console.warn(e);
        }
        router.push("/dang-nhap");
    };

    return (
        <div className="page-container-0topside">
            <div className="section-container max-w-4xl">
                {/* Header */}
                <div className="border-b border-white/10 pb-6 mb-8" /* taste-skill-ignore: divider / tab-underline chrome */
>
                    <div className="flex items-center gap-2 text-xs text-slate-400 mb-2">
                        <Link href="/" className="hover:text-sky-400 transition-colors">Trang chủ</Link>
                        <span>/</span>
                        <span className="text-sky-400 font-semibold">Tài khoản</span>
                    </div>
                    <h1 className="section-title-no-up flex items-center gap-2.5">
                        <span className="w-2 h-7 rounded-full bg-sky-500"></span>
                        <span>Trung Tâm Tài Khoản & Gói Dịch Vụ</span>
                    </h1>
                    <p className="text-slate-400 text-sm mt-1">
                        Quản lý gói thành viên, bảo mật và cài đặt trải nghiệm điện ảnh
                    </p>
                </div>

                <div className="space-y-6">
                    {/* User Card */}
                    <div className="p-6 sm:p-8 rounded-2xl bg-[#121620] border border-white/10 flex flex-col sm:flex-row items-start sm:items-center justify-between gap-6">
                        <div className="flex items-center gap-4">
                            <div className="w-16 h-16 rounded-2xl bg-sky-500 flex items-center justify-center text-white text-2xl font-black shadow-lg" /* taste-skill-ignore: Netflix card overlay (scrim shadow), kept intentionally */
>
                                {user.name ? user.name.charAt(0).toUpperCase() : "U"}
                            </div>
                            <div>
                                <div className="flex items-center gap-2">
                                    <h2 className="text-xl font-bold text-white">{user.name}</h2>
                                    <span className="px-2 py-0.5 rounded-full text-[11px] font-bold bg-sky-500/20 text-sky-400 border border-sky-500/30">
                                        PRO MEMBER
                                    </span>
                                </div>
                                <p className="text-sm text-slate-400">{user.email}</p>
                            </div>
                        </div>

                        <div className="flex flex-wrap items-center gap-3">
                            <Link
                                href="/ho-so"
                                className="play-button-color text-xs px-5 py-2.5 font-semibold inline-flex items-center gap-1.5 cursor-pointer"
                            >
                                Đổi Hồ Sơ (Profiles)
                            </Link>
                            <button
                                type="button"
                                onClick={handleLogout}
                                className="text-xs px-4 py-2.5 rounded-xl font-semibold bg-red-500/10 hover:bg-red-500/20 text-red-400 border border-red-500/25 transition-colors cursor-pointer"
                            >
                                Đăng Xuất
                            </button>
                        </div>
                    </div>

                    {/* Subscription Plan Panel */}
                    <div className="p-6 sm:p-8 rounded-2xl bg-[#121620] border border-white/10 space-y-4">
                        <div className="flex items-center justify-between border-b border-white/10 pb-4" /* taste-skill-ignore: divider / tab-underline chrome */
>
                            <div>
                                <span className="text-xs font-semibold text-slate-400">
                                    Gói Dịch Vụ Hiện Tại
                                </span>
                                <h3 className="text-lg sm:text-xl font-bold text-white mt-0.5">
                                    {user.plan || "VIP 4K Ultra Cinema"}
                                </h3>
                            </div>
                            <Link
                                href="/bang-gia"
                                className="text-xs font-bold text-sky-400 hover:text-sky-300 py-1.5 px-3 rounded-lg bg-sky-500/10 hover:bg-sky-500/20 border border-sky-500/25 transition-colors"
                            >
                                Thay Đổi Gói →
                            </Link>
                        </div>

                        <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 text-xs pt-2">
                            <div className="p-3.5 rounded-xl bg-[#08090c] border border-white/10 space-y-1">
                                <span className="text-slate-400 block">Chất Lượng Video</span>
                                <span className="text-white font-bold text-sm">Ultra HD 4K & HDR</span>
                            </div>
                            <div className="p-3.5 rounded-xl bg-[#08090c] border border-white/10 space-y-1">
                                <span className="text-slate-400 block">Số Thiết Bị Xem Cùng Lúc</span>
                                <span className="text-white font-bold text-sm">4 Thiết Bị</span>
                            </div>
                            <div className="p-3.5 rounded-xl bg-[#08090c] border border-white/10 space-y-1">
                                <span className="text-slate-400 block">Trải Nghiệm Rạp Chiếu</span>
                                <span className="text-emerald-400 font-bold text-sm">Không Quảng Cáo</span>
                            </div>
                        </div>
                    </div>

                    {/* Quick Settings Grid */}
                    <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                        <Link
                            href="/cai-dat"
                            className="p-6 rounded-2xl bg-[#121620] border border-white/10 hover:border-sky-500/40 transition-colors group space-y-2"
                        >
                            <div className="w-10 h-10 rounded-xl bg-sky-500/10 flex items-center justify-center text-sky-400 group-hover:bg-sky-500 group-hover:text-slate-950 transition-colors">
                                <svg className="w-5 h-5 fill-none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z" />
                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                                </svg>
                            </div>
                            <h4 className="font-bold text-white text-base">Cài Đặt Trải Nghiệm</h4>
                            <p className="text-xs text-slate-400 leading-relaxed">
                                Tùy chỉnh tự động phát tập tiếp theo, phụ đề tiếng Việt và chất lượng stream mặc định.
                            </p>
                        </Link>

                        <Link
                            href="/phim-da-luu"
                            className="p-6 rounded-2xl bg-[#121620] border border-white/10 hover:border-sky-500/40 transition-colors group space-y-2"
                        >
                            <div className="w-10 h-10 rounded-xl bg-sky-500/10 flex items-center justify-center text-sky-400 group-hover:bg-sky-500 group-hover:text-slate-950 transition-colors">
                                <svg className="w-5 h-5 fill-current" viewBox="0 0 24 24">
                                    <path d="M5 5a2 2 0 012-2h10a2 2 0 012 2v16l-7-3.5L5 21V5z" />
                                </svg>
                            </div>
                            <h4 className="font-bold text-white text-base">Danh Sách Của Tôi</h4>
                            <p className="text-xs text-slate-400 leading-relaxed">
                                Xem lại toàn bộ các bộ phim đã lưu và lịch sử xem phim đã được đồng bộ.
                            </p>
                        </Link>
                    </div>
                </div>
            </div>
        </div>
    );
}
