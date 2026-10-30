"use client";

import { useState, useEffect } from "react";
import Link from "next/link";
import Image from "next/image";
import useTitle from "@/hooks/useTitle";

const CONCESSIONS = [
    {
        id: "con-1",
        name: "Combo Solo Bắp Ngọt + 1 Pepsi Lớn",
        desc: "1 Bắp rang bơ Caramel 60oz + 1 Nước ngọt có ga cỡ lớn",
        price: 79000,
    },
    {
        id: "con-2",
        name: "Combo Couple 2 Nước + 1 Bắp Phô Mai",
        desc: "1 Bắp Lớn vị Phô Mai + 2 Ly Pepsi Lớn tiết kiệm 25%",
        price: 115000,
    },
    {
        id: "con-3",
        name: "Bắp Rang Bơ Caramel Thượng Hạng",
        desc: "Hạt bắp Mỹ nổ giòn phủ sốt Caramel thơm lừng",
        price: 55000,
    },
    {
        id: "con-4",
        name: "Ly Nhân Vật Điện Ảnh Giới Hạn",
        desc: "Ly giữ nhiệt phiên bản đặc biệt kèm nước ngọt đầy ly",
        price: 149000,
    },
];

const PAYMENT_METHODS = [
    {
        id: "momo",
        name: "Ví Điện Tử MoMo",
        desc: "Quét mã QR hoặc mở ứng dụng MoMo xác nhận tức thì",
        tag: "Phổ biến nhất",
    },
    {
        id: "vietqr",
        name: "Chuyển Khoản Ngân Hàng VietQR 24/7",
        desc: "Hỗ trợ tất cả ứng dụng ngân hàng tại Việt Nam",
        tag: "Miễn phí giao dịch",
    },
    {
        id: "zalopay",
        name: "Ví Điện Tử ZaloPay",
        desc: "Thanh toán nhanh qua Zalo hoặc ứng dụng ZaloPay",
        tag: "Hoàn tiền 5%",
    },
    {
        id: "card",
        name: "Thẻ Quốc Tế Visa / MasterCard / JCB",
        desc: "Bảo mật chuẩn 3D-Secure quốc tế",
        tag: "Quốc tế",
    },
];

export default function ThanhToanPage() {
    useTitle("Thanh Toán Đặt Vé & Combo Bắp Nước | OpenFlix Cinema");

    const [secondsLeft, setSecondsLeft] = useState(300); // 5 minutes
    const [quantities, setQuantities] = useState({ "con-1": 1, "con-2": 0, "con-3": 0, "con-4": 0 });
    const [voucherCode, setVoucherCode] = useState("");
    const [discount, setDiscount] = useState(0);
    const [voucherMessage, setVoucherMessage] = useState("");
    const [paymentMethod, setPaymentMethod] = useState("momo");
    const [isProcessing, setIsProcessing] = useState(false);
    const [confirmedTicket, setConfirmedTicket] = useState(null);

    // Default booking details
    const bookingInfo = {
        movieTitle: "Dưới Đáy Hồ (Under The Lake)",
        poster: "https://phimimg.com/uploads/movies/20261030/duoi-day-ho-poster.webp",
        theaterName: "CineFlix Premium Metropolis",
        hall: "Phòng chiếu IMAX Laser 02",
        showtime: "19:30 - Hôm nay (30/10)",
        seats: ["E5", "E6"],
        ticketUnitPrice: 110000,
    };

    useEffect(() => {
        if (confirmedTicket) return;
        const timer = setInterval(() => {
            setSecondsLeft((prev) => (prev > 0 ? prev - 1 : 0));
        }, 1000);
        return () => clearInterval(timer);
    }, [confirmedTicket]);

    const formatCountdown = (sec) => {
        const m = Math.floor(sec / 60)
            .toString()
            .padStart(2, "0");
        const s = (sec % 60).toString().padStart(2, "0");
        return `${m}:${s}`;
    };

    const updateQty = (id, delta) => {
        setQuantities((prev) => {
            const nextVal = Math.max(0, (prev[id] || 0) + delta);
            return { ...prev, [id]: nextVal };
        });
    };

    const handleApplyVoucher = (e) => {
        e.preventDefault();
        const code = voucherCode.trim().toUpperCase();
        if (code === "CINEFLIX20" || code === "OPENFLIX") {
            setDiscount(20000);
            setVoucherMessage("Áp dụng thành công mã ưu đãi giảm 20.000đ!");
        } else {
            setDiscount(0);
            setVoucherMessage("Mã ưu đãi không hợp lệ. Gợi ý: nhập CINEFLIX20 hoặc OPENFLIX");
        }
    };

    const ticketsSubtotal = bookingInfo.seats.length * bookingInfo.ticketUnitPrice;
    const concessionsSubtotal = CONCESSIONS.reduce(
        (sum, item) => sum + item.price * (quantities[item.id] || 0),
        0
    );
    const finalTotal = Math.max(0, ticketsSubtotal + concessionsSubtotal - discount);

    const handleConfirmPayment = () => {
        if (isProcessing || secondsLeft === 0) return;
        setIsProcessing(true);

        setTimeout(() => {
            const newTicket = {
                id: `CF-${Math.floor(100000 + Math.random() * 900000)}`,
                movieTitle: bookingInfo.movieTitle,
                poster: bookingInfo.poster,
                theater: bookingInfo.theaterName,
                date: "Hôm nay (30/10)",
                time: "19:30",
                format: "IMAX Laser 2D",
                seats: bookingInfo.seats,
                totalPrice: finalTotal,
                status: "active",
                bookedAt: new Date().toLocaleTimeString("vi-VN"),
            };

            try {
                const raw = localStorage.getItem("openflix_cinema_tickets");
                const existing = raw ? JSON.parse(raw) : [];
                localStorage.setItem(
                    "openflix_cinema_tickets",
                    JSON.stringify([newTicket, ...existing])
                );
            } catch {
                // ignore storage error
            }

            setIsProcessing(false);
            setConfirmedTicket(newTicket);
        }, 800);
    };

    return (
        <div className="min-h-[100dvh] bg-[#08090c] pt-24 pb-20">
            <div className="section-container space-y-8">
                {/* Header & Countdown Timer */}
                <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 border-b border-white/10 pb-6" /* taste-skill-ignore: divider / tab-underline chrome */
>
                    <div>
                        <span className="text-xs font-semibold text-sky-400">
                            Cổng Thanh Toán An Toàn
                        </span>
                        <h1 className="text-2xl sm:text-3xl font-black text-white mt-1">
                            Xác Nhận Đặt Vé & Combo Bắp Nước
                        </h1>
                    </div>

                    <div className="px-4 py-2.5 rounded-xl bg-[#121620] border border-amber-500/30 flex items-center gap-3">
                        <span className="text-xs text-slate-300">Thời gian giữ ghế:</span>
                        <span className="text-base font-black text-amber-400">
                            {formatCountdown(secondsLeft)}
                        </span>
                    </div>
                </div>

                {confirmedTicket ? (
                    <div className="p-8 rounded-2xl bg-[#121620] border border-emerald-500/30 max-w-2xl mx-auto text-center space-y-5">
                        <div className="text-xs font-semibold text-emerald-400">
                            Giao dịch hoàn tất
                        </div>
                        <h2 className="text-2xl font-black text-white">
                            Xuất Vé Điện Tử Thành Công!
                        </h2>
                        <p className="text-sm text-slate-300">
                            Mã đặt vé của bạn là{" "}
                            <span className="text-sky-400 font-bold tracking-widest" /* taste-skill-ignore: booking code serial (tabular serials read as code) */
>
                                {confirmedTicket.id}
                            </span>
                            . Vui lòng đưa mã vé này tại quầy soát vé tự động trước giờ chiếu 15 phút.
                        </p>

                        <div className="p-5 rounded-xl bg-[#08090c] border border-white/10 text-left space-y-2 text-xs">
                            <div className="flex justify-between">
                                <span className="text-slate-400">Phim:</span>
                                <span className="text-white font-bold">{confirmedTicket.movieTitle}</span>
                            </div>
                            <div className="flex justify-between">
                                <span className="text-slate-400">Rạp chiếu:</span>
                                <span className="text-white font-semibold">{confirmedTicket.theater}</span>
                            </div>
                            <div className="flex justify-between">
                                <span className="text-slate-400">Suất chiếu:</span>
                                <span className="text-sky-400 font-semibold">
                                    {confirmedTicket.time} • {confirmedTicket.date}
                                </span>
                            </div>
                            <div className="flex justify-between">
                                <span className="text-slate-400">Ghế đã chọn:</span>
                                <span className="text-amber-400 font-bold">
                                    {confirmedTicket.seats.join(", ")}
                                </span>
                            </div>
                            <div className="flex justify-between border-t border-white/10 pt-2" /* taste-skill-ignore: divider / tab-underline chrome */
>
                                <span className="text-slate-400">Tổng đã thanh toán:</span>
                                <span className="text-emerald-400 font-bold text-sm">
                                    {confirmedTicket.totalPrice.toLocaleString("vi-VN")}đ
                                </span>
                            </div>
                        </div>

                        <div className="flex flex-col sm:flex-row items-center justify-center gap-3 pt-2">
                            <Link
                                href="/rap-chieu-phim/ve-cua-toi"
                                className="play-button-color px-6 py-3 rounded-xl text-xs font-bold text-slate-950 w-full sm:w-auto"
                            >
                                Mở Ví Vé Điện Tử Của Tôi
                            </Link>
                            <Link
                                href="/rap-chieu-phim"
                                className="px-6 py-3 rounded-xl bg-slate-900 hover:bg-slate-800 text-white border border-white/10 text-xs font-semibold w-full sm:w-auto"
                            >
                                Quay lại Lịch Chiếu Rạp
                            </Link>
                        </div>
                    </div>
                ) : (
                    <div className="grid grid-cols-1 lg:grid-cols-3 gap-8 items-start">
                        {/* Left Column: Concessions & Payment Methods */}
                        <div className="lg:col-span-2 space-y-6">
                            {/* Concessions Picker */}
                            <div className="p-6 rounded-2xl bg-[#121620] border border-white/10 space-y-4">
                                <div className="flex items-center justify-between">
                                    <h2 className="text-lg font-bold text-white">
                                        1. Chọn Combo Bắp Nước Rạp Chiếu
                                    </h2>
                                    <span className="text-xs text-sky-400 font-semibold">
                                        Nhận ngay tại quầy ưu tiên
                                    </span>
                                </div>

                                <div className="space-y-3">
                                    {CONCESSIONS.map((item) => {
                                        const qty = quantities[item.id] || 0;
                                        return (
                                            <div
                                                key={item.id}
                                                className="p-4 rounded-xl bg-[#08090c] border border-white/10 flex flex-col sm:flex-row sm:items-center justify-between gap-4"
                                            >
                                                <div className="space-y-1">
                                                    <div className="text-sm font-bold text-white">
                                                        {item.name}
                                                    </div>
                                                    <div className="text-xs text-slate-400">
                                                        {item.desc}
                                                    </div>
                                                    <div className="text-xs font-bold text-amber-400 pt-0.5">
                                                        {item.price.toLocaleString("vi-VN")}đ
                                                    </div>
                                                </div>

                                                <div className="flex items-center gap-3 self-end sm:self-center">
                                                    <button
                                                        type="button"
                                                        onClick={() => updateQty(item.id, -1)}
                                                        className="w-8 h-8 rounded-lg bg-slate-800 hover:bg-slate-700 text-white font-bold text-sm cursor-pointer"
                                                        aria-label="Giảm số lượng"
                                                    >
                                                        -
                                                    </button>
                                                    <span className="w-6 text-center text-sm font-bold text-white">
                                                        {qty}
                                                    </span>
                                                    <button
                                                        type="button"
                                                        onClick={() => updateQty(item.id, 1)}
                                                        className="w-8 h-8 rounded-lg bg-sky-500 hover:bg-sky-400 text-slate-950 font-bold text-sm cursor-pointer"
                                                        aria-label="Tăng số lượng"
                                                    >
                                                        +
                                                    </button>
                                                </div>
                                            </div>
                                        );
                                    })}
                                </div>
                            </div>

                            {/* Payment Method Selector */}
                            <div className="p-6 rounded-2xl bg-[#121620] border border-white/10 space-y-4">
                                <h2 className="text-lg font-bold text-white">
                                    2. Phương Thức Thanh Toán
                                </h2>

                                <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                                    {PAYMENT_METHODS.map((pm) => {
                                        const active = paymentMethod === pm.id;
                                        return (
                                            <button
                                                key={pm.id}
                                                type="button"
                                                onClick={() => setPaymentMethod(pm.id)}
                                                className={`p-4 rounded-xl text-left transition-all cursor-pointer border ${
                                                    active
                                                        ? "bg-[#161e2e] border-sky-400 text-white"
                                                        : "bg-[#08090c] border-white/10 text-slate-300 hover:border-white/25"
                                                }`}
                                            >
                                                <div className="flex items-center justify-between mb-1">
                                                    <span className="text-xs font-bold text-sky-400">
                                                        {pm.tag}
                                                    </span>
                                                    <span className="text-xs font-bold">
                                                        {active ? "● Đã chọn" : "○"}
                                                    </span>
                                                </div>
                                                <div className="text-sm font-bold text-white">
                                                    {pm.name}
                                                </div>
                                                <div className="text-xs text-slate-400 mt-1">
                                                    {pm.desc}
                                                </div>
                                            </button>
                                        );
                                    })}
                                </div>
                            </div>
                        </div>

                        {/* Right Column: Order Summary */}
                        <div className="p-6 rounded-2xl bg-[#121620] border border-white/10 space-y-5">
                            <h2 className="text-lg font-bold text-white border-b border-white/10 pb-3" /* taste-skill-ignore: divider / tab-underline chrome */
>
                                Tóm Tắt Đơn Đặt Vé
                            </h2>

                            <div className="flex gap-4 items-center">
                                <div className="w-20 aspect-[2/3] relative rounded-lg overflow-hidden bg-slate-900 flex-shrink-0">
                                    <Image
                                        src={bookingInfo.poster}
                                        alt={bookingInfo.movieTitle}
                                        fill
                                        sizes="80px"
                                        className="object-cover"
                                        unoptimized
                                    />
                                </div>
                                <div className="space-y-1 text-xs">
                                    <h3 className="text-sm font-bold text-white">
                                        {bookingInfo.movieTitle}
                                    </h3>
                                    <p className="text-slate-300">{bookingInfo.theaterName}</p>
                                    <p className="text-slate-400">{bookingInfo.hall}</p>
                                    <p className="text-sky-400 font-semibold">
                                        {bookingInfo.showtime}
                                    </p>
                                </div>
                            </div>

                            {/* Voucher Code Form */}
                            <form onSubmit={handleApplyVoucher} className="space-y-2 pt-2 border-t border-white/10" /* taste-skill-ignore: divider / tab-underline chrome */
>
                                <label className="block text-xs font-semibold text-slate-300">
                                    Mã giảm giá / Voucher (Thử nhập: CINEFLIX20)
                                </label>
                                <div className="flex gap-2">
                                    <input
                                        type="text"
                                        value={voucherCode}
                                        onChange={(e) => setVoucherCode(e.target.value)}
                                        placeholder="Nhập CINEFLIX20..."
                                        className="flex-1 bg-[#08090c] border border-white/10 rounded-xl px-3 py-2 text-xs text-white focus:outline-none focus:border-sky-400"
                                    />
                                    <button
                                        type="submit"
                                        className="px-4 py-2 rounded-xl bg-slate-800 hover:bg-slate-700 text-xs font-bold text-white cursor-pointer"
                                    >
                                        Áp dụng
                                    </button>
                                </div>
                                {voucherMessage && (
                                    <p className="text-xs text-sky-400">{voucherMessage}</p>
                                )}
                            </form>

                            {/* Price Breakdown */}
                            <div className="space-y-2.5 text-xs border-t border-white/10 pt-4" /* taste-skill-ignore: divider / tab-underline chrome */
>
                                <div className="flex justify-between">
                                    <span className="text-slate-400">
                                        Ghế VIP ({bookingInfo.seats.join(", ")}):
                                    </span>
                                    <span className="text-white font-semibold">
                                        {ticketsSubtotal.toLocaleString("vi-VN")}đ
                                    </span>
                                </div>
                                <div className="flex justify-between">
                                    <span className="text-slate-400">Combo Bắp & Nước:</span>
                                    <span className="text-white font-semibold">
                                        {concessionsSubtotal.toLocaleString("vi-VN")}đ
                                    </span>
                                </div>
                                {discount > 0 && (
                                    <div className="flex justify-between text-emerald-400">
                                        <span>Giảm giá Voucher:</span>
                                        <span className="font-bold">
                                            -{discount.toLocaleString("vi-VN")}đ
                                        </span>
                                    </div>
                                )}
                                <div className="flex justify-between text-base font-black text-white border-t border-white/10 pt-3" /* taste-skill-ignore: divider / tab-underline chrome */
>
                                    <span>Tổng thanh toán:</span>
                                    <span className="text-sky-400">
                                        {finalTotal.toLocaleString("vi-VN")}đ
                                    </span>
                                </div>
                            </div>

                            <button
                                type="button"
                                disabled={isProcessing || secondsLeft === 0}
                                onClick={handleConfirmPayment}
                                className="w-full play-button-color py-3.5 rounded-xl text-sm font-bold text-slate-950 cursor-pointer disabled:opacity-50"
                            >
                                {isProcessing
                                    ? "Đang xử lý giao dịch..."
                                    : `Thanh Toán Ngay (${finalTotal.toLocaleString("vi-VN")}đ)`}
                            </button>
                        </div>
                    </div>
                )}
            </div>
        </div>
    );
}
