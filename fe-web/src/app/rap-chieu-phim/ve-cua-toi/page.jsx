'use client'

import { useState, useEffect } from "react";
import Link from "next/link";
import Image from "next/image";
import useTitle from "@/hooks/useTitle";

export default function MyCinemaTicketsPage() {
    useTitle("Vé rạp của tôi - OpenFlix Cinema");

    const [tickets, setTickets] = useState([]);
    const [tab, setTab] = useState("active"); // "active" | "history"
    const [mounted, setMounted] = useState(false);

    useEffect(() => {
        setMounted(true);
        try {
            if (typeof window !== "undefined") {
                const raw = localStorage.getItem("openflix_cinemaTickets");
                if (raw) {
                    const parsed = JSON.parse(raw);
                    if (Array.isArray(parsed)) setTickets(parsed);
                } else {
                    // Seed a sample ticket so user sees a realistic preview
                    const sample = [
                        {
                            id: "OPF-849201",
                            movieTitle: "Dưới Đáy Hồ (Under The Lake)",
                            poster: "https://phimimg.com/uploads/movies/20261030/duoi-day-ho-poster.webp",
                            theater: "CineFlix Premium Metropolis",
                            address: "29 Liễu Giai, Ba Đình, Hà Nội",
                            showtime: "19:30",
                            date: "Hôm nay (30/10)",
                            format: "IMAX Laser 2D",
                            seats: ["E5", "E6"],
                            totalPrice: 220000,
                            bookedAt: "2026-10-30T10:00:00Z",
                        },
                    ];
                    setTickets(sample);
                    localStorage.setItem("openflix_cinemaTickets", JSON.stringify(sample));
                }
            }
        } catch (e) {
            console.warn(e);
        }
    }, []);

    const handleCancel = (ticketId) => {
        if (window.confirm("Bạn có chắc chắn muốn hủy vé này? Tiền sẽ được hoàn về phương thức thanh toán gốc trong 2-4 giờ.")) {
            const updated = tickets.filter((t) => t.id !== ticketId);
            setTickets(updated);
            try {
                if (typeof window !== "undefined") {
                    localStorage.setItem("openflix_cinemaTickets", JSON.stringify(updated));
                }
            } catch (err) {
                console.warn(err);
            }
        }
    };

    if (!mounted) {
        return (
            <div className="page-container-0topside">
                <div className="section-container">
                    <div className="h-8 w-48 bg-slate-800 rounded animate-pulse mb-8" />
                </div>
            </div>
        );
    }

    return (
        <div className="page-container-0topside">
            <div className="section-container max-w-4xl mx-auto space-y-8">
                {/* Header */}
                <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 border-b border-white/10 pb-6" /* taste-skill-ignore: divider / tab-underline chrome */
>
                    <div>
                        <div className="flex items-center gap-3">
                            <span className="w-10 h-10 rounded-xl bg-sky-500/10 border border-sky-400/30 flex items-center justify-center text-sky-400">
                                <svg className="w-5 h-5 fill-none stroke-current" strokeWidth="2" viewBox="0 0 24 24">
                                    <path strokeLinecap="round" strokeLinejoin="round" d="M15 5v2m0 4v2m0 4v2M5 5a2 2 0 00-2 2v3a2 2 0 110 4v3a2 2 0 002 2h14a2 2 0 002-2v-3a2 2 0 110-4V7a2 2 0 00-2-2H5z" />
                                </svg>
                            </span>
                            <h1 className="section-title-no-up">Vé Rạp Của Tôi</h1>
                        </div>
                        <p className="text-sm text-slate-400 mt-2">
                            Quản lý vé xem phim điện tử tại các cụm rạp, quét mã QR vào phòng chiếu nhanh chóng.
                        </p>
                    </div>

                    <Link
                        href="/rap-chieu-phim"
                        className="px-4 py-2 text-xs font-semibold rounded-lg bg-sky-500 hover:bg-sky-400 text-white transition-colors self-start sm:self-auto flex items-center gap-1.5"
                    >
                        <svg className="w-4 h-4 fill-none stroke-current" strokeWidth="2" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" d="M12 4v16m8-8H4" /></svg>
                        <span>Đặt thêm vé rạp</span>
                    </Link>
                </div>

                {/* Tabs */}
                <div className="flex items-center gap-2 border-b border-white/10 pb-2">
                    <button
                        type="button"
                        onClick={() => setTab("active")}
                        className={`px-4 py-2 rounded-lg text-xs font-bold transition-colors cursor-pointer ${
                            tab === "active"
                                ? "bg-sky-500 text-white shadow-md shadow-sky-500/20" /* taste-skill-ignore: interactive overlay card */
                                : "text-slate-400 hover:text-white"
                        }`}
                    >
                        Vé sắp xem ({tickets.length})
                    </button>
                    <button
                        type="button"
                        onClick={() => setTab("history")}
                        className={`px-4 py-2 rounded-lg text-xs font-bold transition-colors cursor-pointer ${
                            tab === "history"
                                ? "bg-sky-500 text-white shadow-md shadow-sky-500/20" /* taste-skill-ignore: interactive overlay card */
                                : "text-slate-400 hover:text-white"
                        }`}
                    >
                        Lịch sử vé đã xem (0)
                    </button>
                </div>

                {/* Content */}
                {tab === "active" ? (
                    tickets.length === 0 ? (
                        <div className="p-12 text-center rounded-2xl bg-[#121620] border border-white/10">
                            <div className="w-16 h-16 mx-auto mb-4 rounded-xl bg-sky-500/10 border border-sky-400/30 flex items-center justify-center text-sky-400">
                                <svg className="w-8 h-8 fill-none stroke-current" strokeWidth="2" viewBox="0 0 24 24">
                                    <path strokeLinecap="round" strokeLinejoin="round" d="M15 5v2m0 4v2m0 4v2M5 5a2 2 0 00-2 2v3a2 2 0 110 4v3a2 2 0 002 2h14a2 2 0 002-2v-3a2 2 0 110-4V7a2 2 0 00-2-2H5z" />
                                </svg>
                            </div>
                            <h3 className="text-white text-lg font-bold mb-2">Bạn chưa có vé xem phim nào</h3>
                            <p className="text-slate-400 text-sm mb-6 max-w-md mx-auto">
                                Khám phá các phim bom tấn đang chiếu tại rạp hôm nay và chọn vị trí ghế ngồi ưng ý nhất.
                            </p>
                            <Link
                                href="/rap-chieu-phim"
                                className="play-button-color px-6 py-3 text-sm inline-flex items-center gap-2"
                            >
                                Khám phá lịch chiếu và đặt vé
                            </Link>
                        </div>
                    ) : (
                        <div className="space-y-6">
                            {tickets.map((ticket) => (
                                <div
                                    key={ticket.id}
                                    className="p-6 rounded-2xl bg-[#121620] border border-white/10 hover:border-sky-400/40 transition-all flex flex-col md:flex-row gap-6 relative overflow-hidden"
                                >
                                    {/* Left Notch & Poster */}
                                    <div className="w-full md:w-36 aspect-[2/3] relative rounded-xl overflow-hidden bg-slate-900 flex-shrink-0">
                                        <Image
                                            src={ticket.poster}
                                            alt={ticket.movieTitle}
                                            fill
                                            sizes="150px"
                                            className="object-cover"
                                            unoptimized
                                        />
                                    </div>

                                    {/* Ticket Details */}
                                    <div className="flex-1 space-y-4">
                                        <div className="flex items-start justify-between gap-4">
                                            <div>
                                                <span className="px-2.5 py-0.5 rounded text-[11px] font-bold bg-sky-950 text-sky-400 border border-sky-400/20">
                                                    {ticket.format}
                                                </span>
                                                <h3 className="text-lg font-bold text-white mt-1.5">{ticket.movieTitle}</h3>
                                                <p className="text-xs text-slate-400 mt-0.5">{ticket.theater}</p>
                                                <p className="text-[11px] text-slate-500">{ticket.address}</p>
                                            </div>

                                            <div className="text-right">
                                                <span className="text-[10px] font-bold text-slate-400">Mã vé điện tử</span>
                                                <div className="text-sm font-bold text-sky-400 tabular-nums">{ticket.id}</div>
                                            </div>
                                        </div>

                                        <div className="grid grid-cols-2 sm:grid-cols-4 gap-3 p-3.5 rounded-xl bg-slate-900/80 border border-white/5 text-xs">
                                            <div>
                                                <span className="text-slate-400 block text-[11px]">Suất chiếu</span>
                                                <span className="text-white font-bold text-sm">{ticket.showtime}</span>
                                            </div>
                                            <div>
                                                <span className="text-slate-400 block text-[11px]">Ngày chiếu</span>
                                                <span className="text-white font-semibold">{ticket.date}</span>
                                            </div>
                                            <div>
                                                <span className="text-slate-400 block text-[11px]">Ghế ngồi</span>
                                                <span className="text-amber-400 font-bold text-sm">{ticket.seats.join(", ")}</span>
                                            </div>
                                            <div>
                                                <span className="text-slate-400 block text-[11px]">Tổng thanh toán</span>
                                                <span className="text-white font-semibold">{ticket.totalPrice.toLocaleString("vi-VN")} đ</span>
                                            </div>
                                        </div>

                                        <div className="flex items-center justify-between gap-4 pt-2">
                                            <div className="flex items-center gap-2 text-xs text-emerald-400">
                                                <span className="w-2 h-2 rounded-full bg-emerald-400 animate-pulse" />
                                                <span>Vé hợp lệ • Xuất trình tại rạp</span>
                                            </div>

                                            <button
                                                type="button"
                                                onClick={() => handleCancel(ticket.id)}
                                                className="text-xs text-slate-400 hover:text-rose-400 underline transition-colors cursor-pointer"
                                            >
                                                Hủy đặt vé
                                            </button>
                                        </div>
                                    </div>
                                </div>
                            ))}
                        </div>
                    )
                ) : (
                    <div className="p-12 text-center rounded-2xl bg-[#121620] border border-white/10">
                        <div className="w-16 h-16 mx-auto mb-4 rounded-xl bg-slate-800 flex items-center justify-center text-slate-500">
                            <svg className="w-8 h-8 fill-none stroke-current" strokeWidth="2" viewBox="0 0 24 24">
                                <path strokeLinecap="round" strokeLinejoin="round" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                            </svg>
                        </div>
                        <h3 className="text-white text-lg font-bold mb-1">Chưa có lịch sử vé đã xem</h3>
                        <p className="text-slate-400 text-xs">
                            Các vé phim sau khi hết giờ chiếu sẽ được tự động lưu trữ tại đây.
                        </p>
                    </div>
                )}
            </div>
        </div>
    );
}
