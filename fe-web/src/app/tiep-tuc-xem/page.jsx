'use client'

import { useState, useEffect } from "react";
import Link from "next/link";
import Image from "next/image";

export default function ContinueWatchingPage() {
    const [historyList, setHistoryList] = useState([]);
    const [mounted, setMounted] = useState(false);

    useEffect(() => {
        setMounted(true);
        try {
            if (typeof window !== "undefined") {
                const raw = localStorage.getItem("openflix_watchHistory");
                if (raw) {
                    const parsed = JSON.parse(raw);
                    if (Array.isArray(parsed)) setHistoryList(parsed);
                }
            }
        } catch (e) {
            console.warn(e);
        }
    }, []);

    const handleRemove = (item, e) => {
        e.preventDefault();
        e.stopPropagation();
        const updated = historyList.filter((m) => m.slug !== item.slug && m.id !== item.id);
        setHistoryList(updated);
        try {
            if (typeof window !== "undefined") {
                localStorage.setItem("openflix_watchHistory", JSON.stringify(updated));
            }
        } catch (err) {
            console.warn(err);
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
            <div className="section-container">
                {/* Header */}
                <div className="border-b border-white/10 pb-6 mb-8 flex flex-col sm:flex-row sm:items-center justify-between gap-4" /* taste-skill-ignore: divider / tab-underline chrome */
>
                    <div>
                        <div className="flex items-center gap-2 text-xs text-slate-400 mb-2">
                            <Link href="/" className="hover:text-sky-400 transition-colors">Trang chủ</Link>
                            <span>/</span>
                            <span className="text-sky-400 font-semibold">Tiếp tục xem</span>
                        </div>
                        <h1 className="section-title-no-up flex items-center gap-2.5">
                            <span className="w-2 h-7 rounded-full bg-sky-500"></span>
                            <span>Tiếp Tục Xem Phim ({historyList.length})</span>
                        </h1>
                        <p className="text-slate-400 text-sm mt-1">
                            Danh sách các bộ phim bạn đang theo dõi dở dang, sẵn sàng tiếp tục bất cứ lúc nào
                        </p>
                    </div>

                    {historyList.length > 0 && (
                        <button
                            type="button"
                            onClick={() => {
                                if (confirm("Bạn có chắc chắn muốn xóa tất cả danh sách tiếp tục xem?")) {
                                    setHistoryList([]);
                                    localStorage.removeItem("openflix_watchHistory");
                                }
                            }}
                            className="text-xs px-4 py-2 rounded-xl bg-white/[0.06] hover:bg-red-500/15 text-slate-300 hover:text-red-400 border border-white/15 transition-colors cursor-pointer w-fit"
                        >
                            Xóa toàn bộ
                        </button>
                    )}
                </div>

                {historyList.length === 0 ? (
                    <div className="py-20 text-center space-y-4 max-w-md mx-auto">
                        <div className="w-16 h-16 mx-auto rounded-2xl bg-sky-500/10 flex items-center justify-center text-sky-400">
                            <svg className="w-8 h-8 fill-none" stroke="currentColor" viewBox="0 0 24 24">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M14.752 11.168l-3.197-2.132A1 1 0 0010 9.87v4.263a1 1 0 001.555.832l3.197-2.132a1 1 0 000-1.664z" />
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                            </svg>
                        </div>
                        <h2 className="text-lg font-bold text-white">Chưa Có Phim Nào Đang Xem Dở</h2>
                        <p className="text-xs sm:text-sm text-slate-400 leading-relaxed">
                            Khi bạn xem một bộ phim bất kỳ trên OpenFlix, hệ thống sẽ tự động ghi nhớ vị trí tập phim và tiến trình để bạn có thể xem tiếp tại đây.
                        </p>
                        <div className="pt-2">
                            <Link href="/phim-moi/1" className="play-button-color text-xs px-6 py-2.5 font-bold inline-flex items-center gap-1.5">
                                Khám Phá Phim Mới →
                            </Link>
                        </div>
                    </div>
                ) : (
                    <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 xl:grid-cols-6 gap-4 sm:gap-6">
                        {historyList.map((item, index) => {
                            const watchLink = `/phim/${item.slug || item.id}?sv=${item.svIndex || 0}&tap=${item.epIndex || 0}`;
                            return (
                                <div
                                    key={index}
                                    className="group relative rounded-2xl overflow-hidden bg-[#121620] border border-white/10 hover:border-sky-500/50 flex flex-col justify-between transition-colors"
                                >
                                    <Link href={watchLink} className="block relative aspect-[2/3] w-full overflow-hidden bg-slate-900">
                                        <Image
                                            src={item.poster_url || item.thumb_url || "/placeholder.webp"}
                                            alt={item.name}
                                            fill
                                            unoptimized
                                            sizes="(max-width: 768px) 50vw, 20vw"
                                            className="object-cover group-hover:scale-105 transition-transform duration-300"
                                        />

                                        {/* Play icon overlay */}
                                        <div className="absolute inset-0 bg-black/40 opacity-0 group-hover:opacity-100 flex items-center justify-center transition-opacity">
                                            <div className="w-12 h-12 rounded-full bg-sky-500 text-slate-950 flex items-center justify-center shadow-lg" /* taste-skill-ignore: Netflix card overlay (scrim shadow), kept intentionally */
>
                                                <svg className="w-6 h-6 fill-current translate-x-0.5" viewBox="0 0 24 24">
                                                    <polygon points="5 3 19 12 5 21 5 3"></polygon>
                                                </svg>
                                            </div>
                                        </div>

                                        {/* Episode Badge */}
                                        <div className="absolute top-2 left-2 bg-sky-500 text-slate-950 text-[11px] font-bold px-2 py-0.5 rounded shadow" /* taste-skill-ignore: Netflix card overlay (scrim shadow), kept intentionally */
>
                                            {item.epName || "Tập 1"}
                                        </div>

                                        {/* Remove button */}
                                        <button
                                            type="button"
                                            title="Xóa khỏi danh sách"
                                            onClick={(e) => handleRemove(item, e)}
                                            className="absolute top-2 right-2 p-1.5 rounded-full bg-black/70 hover:bg-red-500 text-white opacity-0 group-hover:opacity-100 transition-opacity cursor-pointer"
                                        >
                                            <svg className="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M6 18L18 6M6 6l12 12" />
                                            </svg>
                                        </button>

                                        {/* Cinema Progress Bar (Simulated Progress) */}
                                        <div className="absolute bottom-0 left-0 right-0 h-1.5 bg-slate-900">
                                            <div className="h-full bg-sky-500 w-[65%]" />
                                        </div>
                                    </Link>

                                    <div className="p-3">
                                        <Link href={watchLink} className="block">
                                            <h3 className="text-white text-xs sm:text-sm font-bold line-clamp-1 group-hover:text-sky-300 transition-colors">
                                                {item.name}
                                            </h3>
                                            <p className="text-slate-400 text-[11px] mt-0.5 truncate">
                                                {item.origin_name || item.time || "Đang phát"}
                                            </p>
                                        </Link>
                                    </div>
                                </div>
                            );
                        })}
                    </div>
                )}
            </div>
        </div>
    );
}

