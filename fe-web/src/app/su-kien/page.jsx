"use client";

import { useState } from "react";
import Link from "next/link";
import useTitle from "@/hooks/useTitle";

const EVENTS = [
    {
        id: "ev-1",
        category: "Sự kiện Thảm Đỏ",
        title: "Đêm Công Chiếu Sớm IMAX: Dưới Đáy Hồ & Giao Lưu Đoàn Làm Phim",
        date: "19:00 • Thứ Sáu, 31/10/2026",
        location: "CineFlix Premium Metropolis, Hà Nội & CGV Landmark 81, TP.HCM",
        voucherCode: "CINEFLIX20",
        discountLabel: "Giảm ngay 20.000đ khi đặt vé sớm",
        summary:
            "Trải nghiệm suất chiếu đặc biệt định dạng IMAX Laser cùng phần giao lưu trực tiếp với đạo diễn và dàn diễn viên chính. Tặng kèm poster chữ ký giới hạn cho 200 khán giả đầu tiên.",
        slotsLeft: 42,
    },
    {
        id: "ev-2",
        category: "Ưu đãi Thành viên",
        title: "Happy Wednesday - Thứ Tư Vui Vẻ Đồng Giá Vé Rạp 55.000đ",
        date: "Mọi ngày Thứ Tư hàng tuần",
        location: "Toàn bộ hệ thống rạp liên kết trên OpenFlix Cinema",
        voucherCode: "OPENFLIX",
        discountLabel: "Áp dụng cho cả ghế VIP & Sweetbox",
        summary:
            "Chương trình tri ân thành viên OpenFlix mỗi thứ Tư hàng tuần. Đặt vé trực tuyến trên ứng dụng hoặc website để hưởng mức giá ưu đãi và tặng thêm 1 lần nâng cấp cỡ bắp miễn phí.",
        slotsLeft: 185,
    },
    {
        id: "ev-3",
        category: "Dành cho Học sinh - Sinh viên",
        title: "Đặc Quyền U22 CinePass - Xem Phim Không Giới Hạn Cuối Tuần",
        date: "Tháng 10 - Tháng 12/2026",
        location: "Áp dụng toàn quốc cho khán giả dưới 22 tuổi",
        voucherCode: "U22PASS",
        discountLabel: "Combo Bắp Nước chỉ 45.000đ",
        summary:
            "Chỉ cần xác thực tài khoản sinh viên hoặc độ tuổi U22 trên hồ sơ OpenFlix, bạn sẽ nhận ngay mã giảm giá cố định cho mọi suất chiếu 2D tiêu chuẩn và kho phim trực tuyến 4K.",
        slotsLeft: 310,
    },
    {
        id: "ev-4",
        category: "Tuần lễ Phim Hoạt Hình",
        title: "Lễ Hội Hoạt Hình Quốc Tế: Doraemon & Shaun The Sheep",
        date: "09:00 - 21:00 • Thứ Bảy & Chủ Nhật hàng tuần",
        location: "Tất cả cụm rạp CGV, Lotte, BHD, CineFlix",
        voucherCode: "FAMILY2026",
        discountLabel: "Mua 3 vé tặng 1 phần quà lưu niệm",
        summary:
            "Không gian lễ hội cuối tuần dành cho các gia đình và khán giả nhí với khu vực chụp hình check-in nhân vật hoạt hình, nhận huy hiệu giới hạn và thưởng thức các bộ phim lồng tiếng chuẩn rạp.",
        slotsLeft: 95,
    },
];

export default function SuKienPage() {
    useTitle("Sự Kiện Điện Ảnh & Ưu Đãi Thành Viên | OpenFlix");

    const [copiedCode, setCopiedCode] = useState("");
    const [registeredIds, setRegisteredIds] = useState({});
    const [filterCat, setFilterCat] = useState("all");

    const handleCopyCode = (code) => {
        if (typeof navigator !== "undefined" && navigator.clipboard) {
            navigator.clipboard.writeText(code).catch(() => {});
        }
        setCopiedCode(code);
        setTimeout(() => setCopiedCode(""), 2000);
    };

    const toggleRegister = (id) => {
        setRegisteredIds((prev) => ({ ...prev, [id]: !prev[id] }));
    };

    const categories = ["all", "Sự kiện Thảm Đỏ", "Ưu đãi Thành viên", "Dành cho Học sinh - Sinh viên", "Tuần lễ Phim Hoạt Hình"];

    const filteredEvents = EVENTS.filter(
        (ev) => filterCat === "all" || ev.category === filterCat
    );

    return (
        <div className="min-h-[100dvh] bg-[#08090c] pt-24 pb-20">
            <div className="section-container space-y-8">
                {/* Header */}
                <div className="flex flex-col md:flex-row md:items-end justify-between gap-4 border-b border-white/10 pb-6" /* taste-skill-ignore: divider / tab-underline chrome */
>
                    <div>
                        <span className="text-xs font-semibold text-sky-400">
                            Ưu Đãi & Lịch Công Chiếu
                        </span>
                        <h1 className="text-2xl sm:text-3xl font-black text-white mt-1">
                            Sự Kiện Điện Ảnh & Khuyến Mãi Rạp
                        </h1>
                        <p className="text-sm text-slate-400 mt-2 max-w-2xl leading-relaxed">
                            Săn mã giảm giá vé rạp, đăng ký tham dự các buổi công chiếu sớm cùng đoàn làm phim và nhận quà tặng độc quyền từ OpenFlix.
                        </p>
                    </div>

                    <Link
                        href="/thanh-toan"
                        className="play-button-color px-6 py-3 rounded-xl text-xs font-bold text-slate-950 text-center"
                    >
                        Sử dụng Voucher Đặt Vé Ngay
                    </Link>
                </div>

                {/* Filter Ribbon */}
                <div className="flex items-center gap-2 overflow-x-auto pb-2 scrollbar-none">
                    {categories.map((cat) => (
                        <button
                            key={cat}
                            type="button"
                            onClick={() => setFilterCat(cat)}
                            className={`px-4 py-2 rounded-xl text-xs font-semibold whitespace-nowrap cursor-pointer transition-all ${
                                filterCat === cat
                                    ? "bg-sky-500 text-slate-950 font-bold"
                                    : "bg-[#121620] text-slate-400 border border-white/10 hover:text-white"
                            }`}
                        >
                            {cat === "all" ? "Tất cả sự kiện" : cat}
                        </button>
                    ))}
                </div>

                {/* Events Grid */}
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6 items-start">
                    {filteredEvents.map((ev) => {
                        const isReg = !!registeredIds[ev.id];
                        return (
                            <div
                                key={ev.id}
                                className="p-6 rounded-2xl bg-[#121620] border border-white/10 hover:border-sky-400/30 transition-colors flex flex-col justify-between space-y-5"
                            >
                                <div className="space-y-3">
                                    <div className="flex items-center justify-between gap-2">
                                        <span className="text-xs font-bold text-sky-400 bg-sky-500/10 px-3 py-1 rounded-full">
                                            {ev.category}
                                        </span>
                                        <span className="text-xs text-amber-400 font-semibold">
                                            Còn {ev.slotsLeft - (isReg ? 1 : 0)} suất ưu đãi
                                        </span>
                                    </div>

                                    <h2 className="text-lg font-bold text-white leading-snug">
                                        {ev.title}
                                    </h2>

                                    <p className="text-sm text-slate-300 leading-relaxed">
                                        {ev.summary}
                                    </p>

                                    <div className="p-3.5 rounded-xl bg-[#08090c] border border-white/5 space-y-1.5 text-xs">
                                        <div className="flex items-center justify-between">
                                            <span className="text-slate-400">Thời gian:</span>
                                            <span className="text-white font-semibold">{ev.date}</span>
                                        </div>
                                        <div className="flex items-center justify-between">
                                            <span className="text-slate-400">Địa điểm:</span>
                                            <span className="text-slate-200 font-medium text-right">
                                                {ev.location}
                                            </span>
                                        </div>
                                    </div>
                                </div>

                                <div className="space-y-3 pt-2 border-t border-white/10" /* taste-skill-ignore: divider / tab-underline chrome */
>
                                    <div className="flex items-center justify-between bg-[#08090c] px-4 py-2.5 rounded-xl border border-dashed border-sky-400/40">
                                        <div>
                                            <span className="text-xs text-slate-400 block">
                                                {ev.discountLabel}
                                            </span>
                                            <span className="text-sm font-black text-sky-400">
                                                Mã: {ev.voucherCode}
                                            </span>
                                        </div>
                                        <button
                                            type="button"
                                            onClick={() => handleCopyCode(ev.voucherCode)}
                                            className="px-3 py-1.5 rounded-lg bg-slate-800 hover:bg-sky-500 hover:text-slate-950 text-white text-xs font-bold transition-colors cursor-pointer"
                                        >
                                            {copiedCode === ev.voucherCode ? "Đã sao chép!" : "Sao chép mã"}
                                        </button>
                                    </div>

                                    <div className="flex items-center gap-3">
                                        <button
                                            type="button"
                                            onClick={() => toggleRegister(ev.id)}
                                            className={`flex-1 py-2.5 px-4 rounded-xl text-xs font-bold cursor-pointer transition-all border ${
                                                isReg
                                                    ? "bg-emerald-500/15 border-emerald-400 text-emerald-400"
                                                    : "bg-sky-500 text-slate-950 border-sky-500 hover:bg-sky-400"
                                            }`}
                                        >
                                            {isReg ? "Đã đăng ký giữ chỗ" : "Đăng Ký Tham Gia Sự Kiện"}
                                        </button>
                                        <Link
                                            href="/rap-chieu-phim"
                                            className="py-2.5 px-4 rounded-xl bg-slate-900 hover:bg-slate-800 text-white border border-white/10 text-xs font-semibold"
                                        >
                                            Đặt vé rạp
                                        </Link>
                                    </div>
                                </div>
                            </div>
                        );
                    })}
                </div>
            </div>
        </div>
    );
}
