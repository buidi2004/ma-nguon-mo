'use client'

import { useState } from "react";
import Link from "next/link";
import Image from "next/image";
import useTitle from "@/hooks/useTitle";

const CITIES = [
    { id: "hanoi", name: "Hà Nội" },
    { id: "hcm", name: "TP. Hồ Chí Minh" },
    { id: "danang", name: "Đà Nẵng" },
    { id: "cantho", name: "Cần Thơ" },
];

const THEATERS = [
    { id: "th-1", name: "CineFlix Premium Metropolis", chain: "CineFlix", address: "29 Liễu Giai, Ba Đình, Hà Nội", distance: "1.2 km" },
    { id: "th-2", name: "CGV Vincom Center", chain: "CGV", address: "54A Nguyễn Chí Thanh, Đống Đa, Hà Nội", distance: "2.8 km" },
    { id: "th-3", name: "BHD Star The Garden", chain: "BHD", address: "Mễ Trì, Nam Từ Liêm, Hà Nội", distance: "4.5 km" },
    { id: "th-4", name: "Lotte Cinema Landmark", chain: "Lotte", address: "Phạm Hùng, Cầu Giấy, Hà Nội", distance: "5.1 km" },
];

const MOVIES = [
    {
        id: "m-1",
        title: "Dưới Đáy Hồ (Under The Lake)",
        originalTitle: "Under The Lake",
        poster: "https://phimimg.com/uploads/movies/20261030/duoi-day-ho-poster.webp",
        ageRating: "T16",
        rating: 8.8,
        duration: "116 phút",
        formats: ["IMAX Laser 2D", "2D Phụ đề", "VIP Sweetbox"],
        showtimes: ["10:15", "13:30", "16:45", "19:30", "21:40", "23:15"],
    },
    {
        id: "m-2",
        title: "Shaun The Sheep: Quái Lạ Ghé Nhà",
        originalTitle: "Farmageddon",
        poster: "https://phimimg.com/uploads/movies/20261028/shaun-the-sheep-quai-la-ghe-nha-poster.webp",
        ageRating: "P",
        rating: 8.4,
        duration: "86 phút",
        formats: ["2D Lồng tiếng", "2D Phụ đề"],
        showtimes: ["09:00", "11:15", "13:45", "16:00", "18:15"],
    },
    {
        id: "m-3",
        title: "Quỷ Bắt Hồn (Soul Catcher)",
        originalTitle: "Soul Catcher",
        poster: "https://phimimg.com/uploads/movies/20261026/quy-bat-hon-poster.webp",
        ageRating: "T18",
        rating: 7.9,
        duration: "105 phút",
        formats: ["2D Phụ đề", "VIP"],
        showtimes: ["10:30", "14:00", "17:30", "20:30", "22:50"],
    },
    {
        id: "m-4",
        title: "Doraemon: Lâu Đài Dưới Đáy Biển",
        originalTitle: "Nobita and the Castle of the Undersea",
        poster: "https://phimimg.com/uploads/movies/20260829/doraemon-nobita-va-lau-dai-duoi-day-bien-phien-ban-moi-poster.webp",
        ageRating: "P",
        rating: 8.9,
        duration: "112 phút",
        formats: ["2D Lồng tiếng", "3D Phụ đề"],
        showtimes: ["09:45", "12:00", "14:30", "17:15", "19:45"],
    },
];

const SEAT_ROWS = ["A", "B", "C", "D", "E", "F", "G"];
const SEAT_COLS = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

export default function CinemaHubPage() {
    useTitle("Rạp chiếu phim & Suất chiếu - OpenFlix Cinema Hub");

    const [selectedCity, setSelectedCity] = useState("hanoi");
    const [selectedDate, setSelectedDate] = useState("Hôm nay (30/10)");
    const [selectedMovie, setSelectedMovie] = useState(null);
    const [selectedTheater, setSelectedTheater] = useState(THEATERS[0]);
    const [selectedTime, setSelectedTime] = useState("");
    const [selectedFormat, setSelectedFormat] = useState("");

    // Seat selection modal state
    const [isBookingOpen, setIsBookingOpen] = useState(false);
    const [selectedSeats, setSelectedSeats] = useState([]);
    const [bookingSuccess, setBookingSuccess] = useState(null);

    const DATES = [
        "Hôm nay (30/10)",
        "Thứ Sáu (31/10)",
        "Thứ Bảy (01/11)",
        "Chủ Nhật (02/11)",
        "Thứ Hai (03/11)",
    ];

    const openBooking = (movie, showtime, format) => {
        setSelectedMovie(movie);
        setSelectedTime(showtime);
        setSelectedFormat(format || movie.formats[0]);
        setSelectedSeats([]);
        setIsBookingOpen(true);
    };

    const toggleSeat = (seatId) => {
        if (selectedSeats.includes(seatId)) {
            setSelectedSeats(selectedSeats.filter((s) => s !== seatId));
        } else {
            if (selectedSeats.length >= 8) {
                alert("Bạn chỉ có thể chọn tối đa 8 ghế cho mỗi lần đặt.");
                return;
            }
            setSelectedSeats([...selectedSeats, seatId]);
        }
    };

    const getSeatPrice = (row) => {
        if (row === "G") return 220000; // Sweetbox couple
        if (row === "E" || row === "F") return 110000; // VIP
        return 90000; // Standard
    };

    const totalPrice = selectedSeats.reduce((acc, seat) => {
        const row = seat[0];
        return acc + getSeatPrice(row);
    }, 0);

    const handleConfirmBooking = () => {
        if (selectedSeats.length === 0) {
            alert("Vui lòng chọn ít nhất 1 ghế trước khi tiếp tục.");
            return;
        }

        const ticketCode = `OPF-${Math.floor(100000 + Math.random() * 900000)}`;
        const newTicket = {
            id: ticketCode,
            movieTitle: selectedMovie.title,
            poster: selectedMovie.poster,
            theater: selectedTheater.name,
            address: selectedTheater.address,
            showtime: selectedTime,
            date: selectedDate,
            format: selectedFormat,
            seats: selectedSeats,
            totalPrice: totalPrice,
            bookedAt: new Date().toISOString(),
        };

        try {
            if (typeof window !== "undefined") {
                const existing = JSON.parse(localStorage.getItem("openflix_cinemaTickets") || "[]");
                localStorage.setItem("openflix_cinemaTickets", JSON.stringify([newTicket, ...existing]));
            }
        } catch (e) {
            console.warn(e);
        }

        setBookingSuccess(newTicket);
    };

    return (
        <div className="page-container-0topside">
            <div className="section-container space-y-8">
                {/* Hero Header */}
                <div className="flex flex-col md:flex-row md:items-end justify-between gap-4 border-b border-white/10 pb-6" /* taste-skill-ignore: divider / tab-underline chrome */
>
                    <div>
                        <div className="flex items-center gap-3">
                            <span className="w-10 h-10 rounded-xl bg-sky-500/10 border border-sky-400/30 flex items-center justify-center text-sky-400">
                                <svg className="w-6 h-6 fill-none stroke-current" strokeWidth="2" viewBox="0 0 24 24">
                                    <path strokeLinecap="round" strokeLinejoin="round" d="M7 4v16M17 4v16M3 8h4m10 0h4M3 12h18M3 16h4m10 0h4M4 20h16a1 1 0 001-1V5a1 1 0 00-1-1H4a1 1 0 00-1 1v14a1 1 0 001 1z" />
                                </svg>
                            </span>
                            <div>
                                <h1 className="section-title-no-up">CineFlix Cinema Hub</h1>
                                <p className="text-xs text-sky-400 font-semibold">Hệ thống đặt vé rạp chính hãng toàn quốc</p>
                            </div>
                        </div>
                        <p className="text-sm text-slate-400 mt-2">
                            Lịch chiếu phim rạp hôm nay, kiểm tra ghế trống thời gian thực tại các cụm rạp CGV, Lotte, BHD, CineFlix.
                        </p>
                    </div>

                    <div className="flex items-center gap-3 flex-wrap">
                        {/* City Selector */}
                        <div className="relative">
                            <select
                                value={selectedCity}
                                onChange={(e) => setSelectedCity(e.target.value)}
                                className="bg-[#121620] border border-white/10 text-white rounded-lg px-4 py-2 text-xs font-semibold focus:outline-none focus:border-sky-400 cursor-pointer"
                            >
                                {CITIES.map((c) => (
                                    <option key={c.id} value={c.id}>{c.name}</option>
                                ))}
                            </select>
                        </div>

                        <Link
                            href="/rap-chieu-phim/ve-cua-toi"
                            className="px-4 py-2 text-xs font-semibold rounded-lg bg-sky-500/10 hover:bg-sky-500/20 text-sky-400 border border-sky-400/30 transition-colors flex items-center gap-1.5"
                        >
                            <svg className="w-4 h-4 fill-none stroke-current" strokeWidth="2" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" d="M15 5v2m0 4v2m0 4v2M5 5a2 2 0 00-2 2v3a2 2 0 110 4v3a2 2 0 002 2h14a2 2 0 002-2v-3a2 2 0 110-4V7a2 2 0 00-2-2H5z" /></svg>
                            <span>Vé rạp của tôi</span>
                        </Link>
                    </div>
                </div>

                {/* Date Ribbon */}
                <div className="flex items-center gap-2 overflow-x-auto pb-2 scrollbar-none">
                    {DATES.map((d) => (
                        <button
                            key={d}
                            type="button"
                            onClick={() => setSelectedDate(d)}
                            className={`px-4 py-2 rounded-xl text-xs font-semibold whitespace-nowrap transition-all cursor-pointer ${
                                selectedDate === d
                                    ? "bg-sky-500 text-white shadow-lg shadow-sky-500/20" /* taste-skill-ignore: interactive overlay card */
                                    : "bg-[#121620] text-slate-400 border border-white/10 hover:text-white"
                            }`}
                        >
                            {d}
                        </button>
                    ))}
                </div>

                {/* Cinema Theater Selection */}
                <div className="p-4 rounded-xl bg-[#121620] border border-white/10">
                    <div className="text-xs text-slate-400 font-semibold mb-3">Chọn cụm rạp tại khu vực:</div>
                    <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-3">
                        {THEATERS.map((th) => (
                            <button
                                key={th.id}
                                type="button"
                                onClick={() => setSelectedTheater(th)}
                                className={`p-3 rounded-lg text-left transition-all cursor-pointer border ${
                                    selectedTheater.id === th.id
                                        ? "bg-sky-950/40 border-sky-400 text-white"
                                        : "bg-slate-900/60 border-white/5 text-slate-300 hover:border-white/20"
                                }`}
                            >
                                <div className="flex items-center justify-between mb-1">
                                    <span className="text-xs font-bold text-sky-400">{th.chain}</span>
                                    <span className="text-[11px] text-slate-400">{th.distance}</span>
                                </div>
                                <div className="text-sm font-semibold truncate">{th.name}</div>
                                <div className="text-[11px] text-slate-400 truncate mt-1">{th.address}</div>
                            </button>
                        ))}
                    </div>
                </div>

                {/* Movie Showtimes Grid */}
                <div className="space-y-6">
                    <div className="flex items-center justify-between">
                        <h2 className="text-white font-bold text-lg">Phim đang chiếu & Suất chiếu hôm nay</h2>
                        <span className="text-xs text-slate-400">{MOVIES.length} phim có suất chiếu</span>
                    </div>

                    <div className="space-y-6">
                        {MOVIES.map((movie) => (
                            <div
                                key={movie.id}
                                className="p-5 rounded-2xl bg-[#121620] border border-white/10 hover:border-sky-400/30 transition-all flex flex-col md:flex-row gap-5"
                            >
                                {/* Poster */}
                                <div className="w-full md:w-36 aspect-[2/3] relative rounded-xl overflow-hidden bg-slate-900 flex-shrink-0">
                                    <Image
                                        src={movie.poster}
                                        alt={movie.title}
                                        fill
                                        sizes="(max-width: 768px) 100vw, 150px"
                                        className="object-cover"
                                        unoptimized
                                    />
                                    <span className="absolute top-2 left-2 px-2 py-0.5 rounded text-xs font-bold bg-amber-500 text-black">
                                        {movie.ageRating}
                                    </span>
                                </div>

                                {/* Movie Info & Showtimes */}
                                <div className="flex-1 space-y-4">
                                    <div>
                                        <div className="flex items-center gap-3 flex-wrap">
                                            <h3 className="text-lg font-bold text-white hover:text-sky-400 transition-colors">
                                                {movie.title}
                                            </h3>
                                            <span className="text-xs font-semibold text-amber-400 flex items-center gap-1">
                                                <svg className="w-3 h-3 fill-current" viewBox="0 0 24 24"><path d="M12 2l2.4 7.4h7.6l-6.2 4.5 2.4 7.4-6.2-4.5-6.2 4.5 2.4-7.4-6.2-4.5h7.6z"/></svg>
                                                <span>{movie.rating}</span>
                                            </span>
                                        </div>
                                        <p className="text-xs text-slate-400 mt-1">
                                            {movie.originalTitle} • Thời lượng: {movie.duration}
                                        </p>
                                    </div>

                                    {/* Formats and Showtimes */}
                                    <div className="space-y-3 pt-2">
                                        <div className="flex items-center gap-2 flex-wrap text-xs text-slate-400">
                                            <span className="font-semibold text-slate-300">Định dạng chiếu:</span>
                                            {movie.formats.map((fmt) => (
                                                <span key={fmt} className="px-2 py-0.5 rounded bg-slate-800 text-slate-300 border border-white/5 text-[11px]">
                                                    {fmt}
                                                </span>
                                            ))}
                                        </div>

                                        <div>
                                            <div className="text-xs font-semibold text-slate-300 mb-2">Suất chiếu tại {selectedTheater.name}:</div>
                                            <div className="flex items-center gap-2.5 flex-wrap">
                                                {movie.showtimes.map((st) => (
                                                    <button
                                                        key={st}
                                                        type="button"
                                                        onClick={() => openBooking(movie, st, movie.formats[0])}
                                                        className="px-3.5 py-2 rounded-lg bg-slate-900 hover:bg-sky-500 hover:text-white text-slate-200 border border-white/10 hover:border-sky-400 text-xs font-semibold transition-all cursor-pointer shadow-sm" /* taste-skill-ignore: interactive overlay card */
                                                    >
                                                        {st}
                                                    </button>
                                                ))}
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        ))}
                    </div>
                </div>

                {/* Booking & Seat Modal */}
                {isBookingOpen && selectedMovie && (
                    <div className="fixed inset-0 z-50 bg-black/80 backdrop-blur-sm flex items-center justify-center p-4 overflow-y-auto">
                        <div className="bg-[#121620] border border-white/10 rounded-2xl max-w-3xl w-full p-6 space-y-6 my-8">
                            {!bookingSuccess ? (
                                <>
                                    {/* Modal Header */}
                                    <div className="flex items-start justify-between border-b border-white/10 pb-4" /* taste-skill-ignore: divider / tab-underline chrome */
>
                                        <div>
                                            <h3 className="text-lg font-bold text-white">{selectedMovie.title}</h3>
                                            <p className="text-xs text-slate-400 mt-1">
                                                {selectedTheater.name} • {selectedTime} • {selectedDate} ({selectedFormat})
                                            </p>
                                        </div>
                                        <button
                                            type="button"
                                            onClick={() => setIsBookingOpen(false)}
                                            className="text-slate-400 hover:text-white p-1"
                                            aria-label="Đóng"
                                        >
                                            <svg className="w-5 h-5 fill-none stroke-current" strokeWidth="2" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" d="M6 18L18 6M6 6l12 12"/></svg>
                                        </button>
                                    </div>

                                    {/* Screen Arc */}
                                    <div className="text-center py-2">
                                        <div className="w-3/4 mx-auto h-1 bg-sky-400 rounded-full" />
                                        <span className="text-[11px] text-slate-400 mt-2 block font-medium">Màn hình chiếu rạp</span>
                                    </div>

                                    {/* Seat Map */}
                                    <div className="space-y-2 py-4">
                                        {SEAT_ROWS.map((row) => (
                                            <div key={row} className="flex items-center justify-center gap-1.5 sm:gap-2">
                                                <span className="w-5 text-center text-xs font-bold text-slate-400">{row}</span>
                                                {SEAT_COLS.map((col) => {
                                                    const seatId = `${row}${col}`;
                                                    const isSelected = selectedSeats.includes(seatId);
                                                    const isSweetbox = row === "G";
                                                    const isVip = row === "E" || row === "F";

                                                    return (
                                                        <button
                                                            key={seatId}
                                                            type="button"
                                                            onClick={() => toggleSeat(seatId)}
                                                            className={`w-6 h-6 sm:w-8 sm:h-8 rounded text-xs font-semibold flex items-center justify-center transition-all cursor-pointer ${
                                                                isSelected
                                                                    ? "bg-sky-500 text-white font-bold ring-2 ring-sky-300 scale-105"
                                                                    : isSweetbox
                                                                    ? "bg-rose-950/60 border border-rose-500/30 text-rose-300 hover:bg-rose-900"
                                                                    : isVip
                                                                    ? "bg-amber-950/60 border border-amber-500/30 text-amber-300 hover:bg-amber-900"
                                                                    : "bg-slate-800 border border-white/10 text-slate-300 hover:bg-slate-700"
                                                            }`}
                                                            title={`Ghế ${seatId} - ${getSeatPrice(row).toLocaleString("vi-VN")} đ`}
                                                        >
                                                            {col}
                                                        </button>
                                                    );
                                                })}
                                                <span className="w-5 text-center text-xs font-bold text-slate-400">{row}</span>
                                            </div>
                                        ))}
                                    </div>

                                    {/* Legend */}
                                    <div className="flex items-center justify-center gap-4 sm:gap-6 text-xs text-slate-400 pt-2 border-t border-white/5 flex-wrap" /* taste-skill-ignore: divider / tab-underline chrome */
>
                                        <div className="flex items-center gap-2">
                                            <span className="w-3.5 h-3.5 rounded bg-slate-800 border border-white/10" />
                                            <span>Thường (90k)</span>
                                        </div>
                                        <div className="flex items-center gap-2">
                                            <span className="w-3.5 h-3.5 rounded bg-amber-950 border border-amber-500/40" />
                                            <span>VIP (110k)</span>
                                        </div>
                                        <div className="flex items-center gap-2">
                                            <span className="w-3.5 h-3.5 rounded bg-rose-950 border border-rose-500/40" />
                                            <span>Sweetbox (220k)</span>
                                        </div>
                                        <div className="flex items-center gap-2">
                                            <span className="w-3.5 h-3.5 rounded bg-sky-500" />
                                            <span>Đang chọn</span>
                                        </div>
                                    </div>

                                    {/* Price & Action */}
                                    <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 pt-4 border-t border-white/10" /* taste-skill-ignore: divider / tab-underline chrome */
>
                                        <div>
                                            <div className="text-xs text-slate-400">
                                                Ghế đã chọn: <span className="font-bold text-white">{selectedSeats.join(", ") || "Chưa chọn"}</span>
                                            </div>
                                            <div className="text-lg font-bold text-sky-400 mt-0.5">
                                                {totalPrice.toLocaleString("vi-VN")} đ
                                            </div>
                                        </div>

                                        <div className="flex items-center gap-3">
                                            <button
                                                type="button"
                                                onClick={() => setIsBookingOpen(false)}
                                                className="px-4 py-2.5 rounded-lg bg-white/5 hover:bg-white/10 text-slate-300 text-xs font-semibold transition-colors cursor-pointer"
                                            >
                                                Hủy bỏ
                                            </button>
                                            <button
                                                type="button"
                                                onClick={handleConfirmBooking}
                                                className="px-6 py-2.5 rounded-lg bg-sky-500 hover:bg-sky-400 text-white text-xs font-bold transition-all shadow-lg shadow-sky-500/20 cursor-pointer" /* taste-skill-ignore: interactive overlay card */
                                            >
                                                Xác nhận đặt vé
                                            </button>
                                        </div>
                                    </div>
                                </>
                            ) : (
                                /* Booking Confirmation */
                                <div className="text-center py-6 space-y-6">
                                    <div className="w-16 h-16 rounded-2xl bg-emerald-500/10 border border-emerald-500/30 text-emerald-400 flex items-center justify-center mx-auto">
                                        <svg className="w-8 h-8 fill-none stroke-current" strokeWidth="2" viewBox="0 0 24 24">
                                            <path strokeLinecap="round" strokeLinejoin="round" d="M5 13l4 4L19 7" />
                                        </svg>
                                    </div>

                                    <div className="space-y-2">
                                        <h3 className="text-xl font-bold text-white">Đặt vé rạp thành công!</h3>
                                        <p className="text-xs text-slate-400 max-w-md mx-auto">
                                            Mã vé điện tử đã được phát hành và lưu vào mục &quot;Vé rạp của tôi&quot;. Vui lòng xuất trình mã này tại quầy vé hoặc máy in tự động tại rạp.
                                        </p>
                                    </div>

                                    <div className="p-4 rounded-xl bg-slate-900 border border-white/10 max-w-sm mx-auto text-left space-y-2">
                                        <div className="flex items-center justify-between">
                                            <span className="text-xs text-slate-400">Mã vé:</span>
                                            <span className="text-sm font-bold text-sky-400">{bookingSuccess.id}</span>
                                        </div>
                                        <div className="flex items-center justify-between">
                                            <span className="text-xs text-slate-400">Phim:</span>
                                            <span className="text-xs font-semibold text-white truncate max-w-[180px]">{bookingSuccess.movieTitle}</span>
                                        </div>
                                        <div className="flex items-center justify-between">
                                            <span className="text-xs text-slate-400">Suất chiếu:</span>
                                            <span className="text-xs text-slate-200">{bookingSuccess.showtime} - {bookingSuccess.date}</span>
                                        </div>
                                        <div className="flex items-center justify-between">
                                            <span className="text-xs text-slate-400">Ghế ngồi:</span>
                                            <span className="text-xs font-bold text-amber-400">{bookingSuccess.seats.join(", ")}</span>
                                        </div>
                                        <div className="flex items-center justify-between pt-2 border-t border-white/5" /* taste-skill-ignore: divider / tab-underline chrome */
>
                                            <span className="text-xs text-slate-400">Tổng thanh toán:</span>
                                            <span className="text-sm font-bold text-white">{bookingSuccess.totalPrice.toLocaleString("vi-VN")} đ</span>
                                        </div>
                                    </div>

                                    <div className="flex items-center justify-center gap-3">
                                        <Link
                                            href="/rap-chieu-phim/ve-cua-toi"
                                            className="px-5 py-2.5 rounded-lg bg-sky-500 hover:bg-sky-400 text-white text-xs font-bold transition-colors"
                                        >
                                            Xem vé đã đặt
                                        </Link>
                                        <button
                                            type="button"
                                            onClick={() => {
                                                setIsBookingOpen(false);
                                                setBookingSuccess(null);
                                            }}
                                            className="px-4 py-2.5 rounded-lg bg-white/5 hover:bg-white/10 text-slate-300 text-xs font-semibold transition-colors cursor-pointer"
                                        >
                                            Đóng
                                        </button>
                                    </div>
                                </div>
                            )}
                        </div>
                    </div>
                )}
            </div>
        </div>
    );
}
