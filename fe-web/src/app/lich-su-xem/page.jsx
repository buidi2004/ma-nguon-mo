'use client'

import { useState, useEffect } from "react";
import Link from "next/link";
import useTitle from "@/hooks/useTitle";
import Image from "next/image";

export default function WatchHistoryPage() {
    useTitle("Lịch sử xem phim | OpenFlix");

    const [history, setHistory] = useState([]);
    const [loaded, setLoaded] = useState(false);

    useEffect(() => {
        try {
            if (typeof window !== 'undefined') {
                const stored = localStorage.getItem('openflix_watchHistory');
                if (stored) {
                    const parsed = JSON.parse(stored);
                    if (Array.isArray(parsed)) {
                        setHistory(parsed);
                    }
                }
            }
        } catch (e) {
            console.warn('[WatchHistory] Error loading history:', e);
        } finally {
            setLoaded(true);
        }
    }, []);

    const removeOne = (id, slug) => {
        const next = history.filter((item) => item.id !== id && item.slug !== slug);
        setHistory(next);
        try {
            localStorage.setItem('openflix_watchHistory', JSON.stringify(next));
        } catch (e) {
            console.warn(e);
        }
    };

    const clearAll = () => {
        if (confirm("Bạn có chắc chắn muốn xóa toàn bộ lịch sử xem phim?")) {
            setHistory([]);
            try {
                localStorage.removeItem('openflix_watchHistory');
            } catch (e) {
                console.warn(e);
            }
        }
    };

    if (!loaded) {
        return (
            <div className="page-container-0topside">
                <div className="section-container flex justify-center items-center py-20">
                    <div className="loader"></div>
                </div>
            </div>
        );
    }

    return (
        <div className="page-container-0topside">
            <div className="section-container">
                {/* Header */}
                <div className="flex flex-col sm:flex-row sm:items-end justify-between pb-5 mb-8 gap-4">
                    <div>
                        <div className="flex items-center gap-2 text-[13px] text-slate-400 mb-2">
                            <Link href="/" className="hover:text-sky-400 transition-colors">Trang chủ</Link>
                            <span>/</span>
                            <span className="text-sky-400 font-semibold">Lịch sử xem</span>
                        </div>
                        <h1 className="section-title-no-up flex items-center gap-2.5">
                            <span className="w-2 h-7 rounded-full bg-sky-500"></span>
                            <span>Lịch Sử Xem Phim</span>
                            <span className="text-sm font-normal text-slate-400 self-end mb-1 tabular-nums">
                                ({history.length} bộ phim)
                            </span>
                        </h1>
                    </div>

                    {history.length > 0 && (
                        <button
                            onClick={clearAll}
                            className="px-4 py-2 text-[13px] font-semibold rounded-xl bg-red-500/10 hover:bg-red-500/20 text-red-400 transition-colors flex items-center gap-1.5 w-fit cursor-pointer"
                        >
                            <svg className="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                            </svg>
                            <span>Xóa toàn bộ lịch sử</span>
                        </button>
                    )}
                </div>

                {/* Empty State */}
                {history.length === 0 ? (
                    <div className="mt-8 p-12 text-center rounded-2xl bg-[#121620] border border-white/10 max-w-xl mx-auto">
                        <div className="w-16 h-16 mx-auto mb-4 rounded-xl bg-sky-500/10 border border-sky-400/30 flex items-center justify-center text-sky-400">
                            <svg className="w-8 h-8 fill-none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.5" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
                        </div>
                        <h2 className="text-white text-xl font-bold mb-2">Chưa có lịch sử xem phim</h2>
                        <p className="text-slate-400 text-sm mb-6 max-w-md mx-auto leading-relaxed">
                            Khi bạn thưởng thức các bộ phim trên OpenFlix, tiến trình và tập phim đang xem sẽ tự động được lưu lại tại đây.
                        </p>
                        <Link
                            href="/phim-moi/1"
                            className="play-button-color px-7 py-3 text-sm inline-flex items-center gap-2"
                        >
                            Khám phá phim mới ngay
                        </Link>
                    </div>
                ) : (
                    /* History Grid */
                    <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5 gap-5">
                        {history.map((item) => (
                            <div
                                key={item.id || item.slug}
                                className="group relative rounded-2xl bg-[#121620] overflow-hidden hover:ring-2 hover:ring-sky-400/50 transition-colors duration-200 flex flex-col justify-between"
                            >
                                {/* Poster Image */}
                                <div className="relative aspect-[2/3] w-full overflow-hidden">
                                    <Image
                                        src={item.thumb_url || item.poster_url || '/placeholder.webp'}
                                        alt={item.name}
                                        fill
                                        sizes="(max-width: 640px) 100vw, (max-width: 1024px) 50vw, 25vw"
                                        style={{ objectFit: 'cover' }}
                                        unoptimized
                                        className="group-hover:scale-105 transition-transform duration-300"
                                    />

                                    {/* Gradient overlay */}
                                    <div className="absolute inset-x-0 bottom-0 h-1/2 bg-gradient-to-t from-black/90 via-black/40 to-transparent"></div> {/* taste-skill-ignore */}

                                    {/* Badge Episode */}
                                    <div className="absolute top-2.5 left-2.5 bg-sky-500 text-slate-950 font-black text-[13px] px-2 py-0.5 rounded">
                                        {item.epName || 'Full HD'}
                                    </div>

                                    {/* Remove one button */}
                                    <button
                                        onClick={(e) => {
                                            e.preventDefault();
                                            removeOne(item.id, item.slug);
                                        }}
                                        title="Xóa khỏi lịch sử"
                                        className="absolute top-2.5 right-2.5 p-1.5 rounded-full bg-black/60 hover:bg-red-500/80 text-white opacity-0 group-hover:opacity-100 transition-colors cursor-pointer"
                                    >
                                        <svg className="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M6 18L18 6M6 6l12 12" />
                                        </svg>
                                    </button>

                                    {/* Center Play Button on hover */}
                                    <Link
                                        href={`/phim/${item.slug}?sv=${item.svIndex || 0}&tap=${item.epIndex || 0}`}
                                        className="absolute inset-0 flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity duration-200"
                                    >
                                        <div className="w-12 h-12 rounded-full bg-sky-500 text-slate-950 flex items-center justify-center transform scale-90 group-hover:scale-100 transition-transform">
                                            <svg className="w-6 h-6 ml-0.5 fill-current" viewBox="0 0 24 24">
                                                <polygon points="5 3 19 12 5 21 5 3"></polygon>
                                            </svg>
                                        </div>
                                    </Link>
                                </div>

                                {/* Content Info */}
                                <div className="p-3.5 flex flex-col justify-between flex-1">
                                    <div>
                                        <h3 className="text-white font-bold text-sm sm:text-base line-clamp-1 group-hover:text-sky-400 transition-colors">
                                            {item.name}
                                        </h3>
                                        <div className="flex items-center justify-between text-xs text-slate-400 mt-1">
                                            <span className="line-clamp-1">{item.category}</span>
                                            <span className="text-sky-400/80 font-medium">{item.year}</span>
                                        </div>
                                    </div>

                                    {/* Action Continue */}
                                    <div className="mt-3 pt-2.5 border-t border-white/10 flex items-center justify-between" /* taste-skill-ignore: divider / tab-underline chrome */
>
                                        <Link
                                            href={`/phim/${item.slug}?sv=${item.svIndex || 0}&tap=${item.epIndex || 0}`}
                                            className="text-xs font-semibold text-sky-400 hover:text-sky-300 flex items-center gap-1"
                                        >
                                            <span>Tiếp tục xem</span>
                                            <span>▶</span>
                                        </Link>
                                        <Link
                                            href={`/phim/${item.slug}`}
                                            className="text-[11px] text-slate-400 hover:text-white"
                                        >
                                            Chi tiết →
                                        </Link>
                                    </div>
                                </div>
                            </div>
                        ))}
                    </div>
                )}
            </div>
        </div>
    );
}

