'use client'

import { useState } from "react";
import Link from "next/link";
import useTitle from "@/hooks/useTitle";

export default function NotificationsPage() {
    useTitle("Thông báo & Tin mới - OpenFlix");

    const [onlyUnread, setOnlyUnread] = useState(false);
    const [notifications, setNotifications] = useState([
        {
            id: "nt-1",
            title: "Có tập mới: Trường Nguyệt Tẫn Minh",
            body: "Tập 38 & 39 bản Full HD Vietsub đã sẵn sàng trên OpenFlix. Xem ngay để không bỏ lỡ đại kết cục!",
            timeAgo: "15 phút trước",
            type: "episode",
            isRead: false,
            link: "/xem-phim/truong-nguyet-tan-minh",
        },
        {
            id: "nt-2",
            title: "Suất chiếu sớm IMAX: Dune: Phần 2",
            body: "Hệ thống đã mở bán các vị trí ghế VIP trung tâm tại cụm rạp CineFlix Metropolis. Đặt vé ngay hôm nay!",
            timeAgo: "2 giờ trước",
            type: "cinema",
            isRead: false,
            link: "/rap-chieu-phim",
        },
        {
            id: "nt-3",
            title: "Khuyến mãi: Nâng cấp gói Ultra 4K Cinema",
            body: "Ưu đãi giảm 30% cho thành viên gia đình đăng ký gói 12 tháng. Trải nghiệm âm thanh vòm Dolby Atmos.",
            timeAgo: "Hôm qua",
            type: "promo",
            isRead: false,
            link: "/bang-gia",
        },
        {
            id: "nt-4",
            title: "Nâng cấp hoàn tất CDN Singapore",
            body: "Hệ thống máy chủ streaming HLS vừa được tối ưu hóa băng thông, tốc độ tải phim nhanh gấp 2 lần.",
            timeAgo: "3 ngày trước",
            type: "system",
            isRead: true,
            link: "/trang-thai-he-thong",
        },
    ]);

    const markAllAsRead = () => {
        setNotifications((prev) => prev.map((n) => ({ ...n, isRead: true })));
    };

    const markAsRead = (id) => {
        setNotifications((prev) =>
            prev.map((n) => (n.id === id ? { ...n, isRead: true } : n))
        );
    };

    const unreadCount = notifications.filter((n) => !n.isRead).length;
    const displayed = onlyUnread ? notifications.filter((n) => !n.isRead) : notifications;

    return (
        <div className="page-container-0topside">
            <div className="section-container max-w-3xl mx-auto space-y-8">
                {/* Header */}
                <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 border-b border-white/10 pb-6" /* taste-skill-ignore: divider / tab-underline chrome */
>
                    <div>
                        <div className="flex items-center gap-3">
                            <div className="text-sky-400 flex items-center justify-center">
                                <svg className="w-6 h-6 fill-none stroke-current" strokeWidth="2" viewBox="0 0 24 24">
                                    <path strokeLinecap="round" strokeLinejoin="round" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9" />
                                </svg>
                            </div>
                            <div className="flex items-center gap-2">
                                <h1 className="section-title-no-up">Trung Tâm Thông Báo</h1>
                                {unreadCount > 0 && (
                                    <span className="px-2 py-0.5 rounded-full text-xs font-bold bg-sky-500 text-white">
                                        {unreadCount} mới
                                    </span>
                                )}
                            </div>
                        </div>
                        <p className="text-sm text-slate-400 mt-2">
                            Cập nhật các tập phim mới, sự kiện mở bán vé rạp và thông báo ưu đãi dành riêng cho bạn.
                        </p>
                    </div>

                    <div className="flex items-center gap-3 self-start sm:self-auto">
                        {unreadCount > 0 && (
                            <button
                                type="button"
                                onClick={markAllAsRead}
                                className="px-3.5 py-1.5 text-xs font-semibold rounded-lg bg-white/5 hover:bg-white/10 text-slate-300 border border-white/10 transition-colors cursor-pointer"
                            >
                                Đã đọc tất cả
                            </button>
                        )}
                    </div>
                </div>

                {/* Filter */}
                <div className="flex items-center gap-2 border-b border-white/10 pb-2" /* taste-skill-ignore: divider / tab-underline chrome */
>
                    <button
                        type="button"
                        onClick={() => setOnlyUnread(false)}
                        className={`px-4 py-2 rounded-lg text-xs font-bold transition-colors cursor-pointer ${
                            !onlyUnread
                                ? "bg-sky-500 text-white shadow-md shadow-sky-500/20" /* taste-skill-ignore: interactive overlay card */
                                : "text-slate-400 hover:text-white"
                        }`}
                    >
                        Tất cả thông báo ({notifications.length})
                    </button>
                    <button
                        type="button"
                        onClick={() => setOnlyUnread(true)}
                        className={`px-4 py-2 rounded-lg text-xs font-bold transition-colors cursor-pointer ${
                            onlyUnread
                                ? "bg-sky-500 text-white shadow-md shadow-sky-500/20" /* taste-skill-ignore: interactive overlay card */
                                : "text-slate-400 hover:text-white"
                        }`}
                    >
                        Chưa đọc ({unreadCount})
                    </button>
                </div>

                {/* Notifications List */}
                {displayed.length === 0 ? (
                    <div className="p-12 text-center rounded-2xl bg-[#121620] border border-white/10">
                        <div className="w-16 h-16 mx-auto mb-4 rounded-xl bg-slate-800 flex items-center justify-center text-slate-500">
                            <svg className="w-8 h-8 fill-none stroke-current" strokeWidth="2" viewBox="0 0 24 24">
                                <path strokeLinecap="round" strokeLinejoin="round" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9" />
                            </svg>
                        </div>
                        <h3 className="text-white text-base font-bold mb-1">Không có thông báo mới</h3>
                        <p className="text-slate-400 text-xs">
                            Bạn đã xem hết tất cả thông báo trong hộp thư.
                        </p>
                    </div>
                ) : (
                    <div className="space-y-3">
                        {displayed.map((item) => (
                            <Link
                                key={item.id}
                                href={item.link}
                                onClick={() => markAsRead(item.id)}
                                className={`block p-5 rounded-xl border transition-all ${
                                    !item.isRead
                                        ? "bg-slate-900/90 border-sky-500/30 shadow-sm" /* taste-skill-ignore: interactive overlay card */
                                        : "bg-[#121620] border-white/5 opacity-80 hover:opacity-100"
                                } hover:border-sky-400/50`}
                            >
                                <div className="flex items-start gap-4">
                                    <div className="text-sky-400 flex-shrink-0 pt-0.5">
                                        <svg className="w-5 h-5 fill-none stroke-current" strokeWidth="2" viewBox="0 0 24 24">
                                            <path strokeLinecap="round" strokeLinejoin="round" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                                        </svg>
                                    </div>

                                    <div className="flex-1 min-w-0 space-y-1">
                                        <div className="flex items-center justify-between gap-2">
                                            <h3 className="text-sm font-bold text-white truncate">{item.title}</h3>
                                            <span className="text-[11px] text-slate-400 flex-shrink-0">{item.timeAgo}</span>
                                        </div>
                                        <p className="text-xs text-slate-300 leading-relaxed">{item.body}</p>
                                    </div>

                                    {!item.isRead && (
                                        <span className="w-2 h-2 rounded-full bg-sky-400 flex-shrink-0 mt-2" />
                                    )}
                                </div>
                            </Link>
                        ))}
                    </div>
                )}
            </div>
        </div>
    );
}
