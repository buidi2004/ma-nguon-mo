'use client'

import { useState, useEffect } from "react";
import Link from "next/link";
import Image from "next/image";
import useTitle from "@/hooks/useTitle";

export default function LikedMoviesPage() {
    const [likedList, setLikedList] = useState([]);
    const [mounted, setMounted] = useState(false);

    useTitle("Phim đã thích - OpenFlix");

    useEffect(() => {
        setMounted(true);
        try {
            if (typeof window !== "undefined") {
                const raw = localStorage.getItem("openflix_likedMovies");
                if (raw) {
                    const parsed = JSON.parse(raw);
                    if (Array.isArray(parsed)) setLikedList(parsed);
                } else {
                    // Fallback to check saveList if liked is empty
                    const savedRaw = localStorage.getItem("saveList");
                    if (savedRaw) {
                        const parsedSaved = JSON.parse(savedRaw);
                        if (Array.isArray(parsedSaved) && parsedSaved.length > 0) {
                            setLikedList(parsedSaved.slice(0, 4));
                        }
                    }
                }
            }
        } catch (e) {
            console.warn(e);
        }
    }, []);

    const handleUnlike = (slug, e) => {
        e.preventDefault();
        e.stopPropagation();
        const updated = likedList.filter((m) => m.slug !== slug);
        setLikedList(updated);
        try {
            if (typeof window !== "undefined") {
                localStorage.setItem("openflix_likedMovies", JSON.stringify(updated));
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
                <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 border-b border-white/10 pb-6 mb-8" /* taste-skill-ignore: divider / tab-underline chrome */
>
                    <div>
                        <div className="flex items-center gap-3">
                            <span className="w-10 h-10 rounded-xl bg-sky-500/10 border border-sky-400/30 flex items-center justify-center text-sky-400">
                                <svg className="w-5 h-5 fill-current" viewBox="0 0 24 24">
                                    <path d="M2 10.5a1.5 1.5 0 113 0v6a1.5 1.5 0 01-3 0v-6zM6 10.333v5.43c0 .484.237.935.637 1.21l3.5 2.45a2 2 0 001.163.377h5.9a2 2 0 001.972-1.671l1.2-7.2A2 2 0 0018.4 8.5H14V4a2 2 0 00-2-2h-.379a1.5 1.5 0 00-1.423 1.026l-1.95 5.85A2 2 0 016.35 10.333z" />
                                </svg>
                            </span>
                            <h1 className="section-title-no-up">Phim đã thích ({likedList.length})</h1>
                        </div>
                        <p className="text-sm text-slate-400 mt-2">
                            Bộ sưu tập các tác phẩm điện ảnh bạn đã bấm thích và đánh giá tích cực.
                        </p>
                    </div>

                    {likedList.length > 0 && (
                        <button
                            type="button"
                            onClick={() => {
                                if (window.confirm("Bạn có chắc muốn xóa tất cả phim đã thích?")) {
                                    setLikedList([]);
                                    localStorage.removeItem("openflix_likedMovies");
                                }
                            }}
                            className="px-4 py-2 text-xs font-semibold rounded-lg bg-white/5 hover:bg-rose-500/20 hover:text-rose-400 border border-white/10 text-slate-300 transition-colors self-start sm:self-auto cursor-pointer"
                        >
                            Xóa danh sách thích
                        </button>
                    )}
                </div>

                {likedList.length === 0 ? (
                    <div className="mt-8 p-12 text-center rounded-2xl bg-[#121620] border border-white/10 max-w-xl mx-auto">
                        <div className="w-16 h-16 mx-auto mb-4 rounded-xl bg-sky-500/10 border border-sky-400/30 flex items-center justify-center text-sky-400">
                            <svg className="w-8 h-8 fill-current" viewBox="0 0 24 24">
                                <path d="M2 10.5a1.5 1.5 0 113 0v6a1.5 1.5 0 01-3 0v-6zM6 10.333v5.43c0 .484.237.935.637 1.21l3.5 2.45a2 2 0 001.163.377h5.9a2 2 0 001.972-1.671l1.2-7.2A2 2 0 0018.4 8.5H14V4a2 2 0 00-2-2h-.379a1.5 1.5 0 00-1.423 1.026l-1.95 5.85A2 2 0 016.35 10.333z" />
                            </svg>
                        </div>
                        <h2 className="text-white text-xl font-bold mb-2">Chưa có phim nào được thích</h2>
                        <p className="text-slate-400 text-sm mb-6 leading-relaxed">
                            Bấm biểu tượng Thích ở bất kỳ bộ phim nào bạn yêu thích để lưu vào bộ sưu tập cá nhân.
                        </p>
                        <Link
                            href="/phim-moi/1"
                            className="play-button-color px-6 py-3 text-sm inline-flex items-center gap-2"
                        >
                            Khám phá phim mới ngay
                        </Link>
                    </div>
                ) : (
                    <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 xl:grid-cols-6 gap-4">
                        {likedList.map((movie, index) => {
                            const posterUrl = movie.poster_url?.startsWith("http")
                                ? movie.poster_url
                                : `https://phimimg.com/${movie.poster_url || movie.thumb_url || ""}`;
                            return (
                                <div
                                    key={movie.slug || index}
                                    className="group relative flex flex-col rounded-xl overflow-hidden bg-[#121620] border border-white/10 hover:border-sky-400/50 transition-all duration-300"
                                >
                                    <Link href={`/phim/${movie.slug}`} className="relative aspect-[2/3] w-full overflow-hidden bg-slate-900 block">
                                        <Image
                                            src={posterUrl}
                                            alt={movie.name || "Poster"}
                                            fill
                                            sizes="(max-width: 768px) 50vw, (max-width: 1200px) 25vw, 16vw"
                                            className="object-cover group-hover:scale-105 transition-transform duration-300"
                                            unoptimized
                                        />
                                        <div className="absolute inset-0 bg-black/70 opacity-0 group-hover:opacity-100 transition-opacity flex items-end p-3">
                                            <span className="w-full py-1.5 text-center text-xs font-semibold rounded bg-sky-500 text-white shadow-lg" /* taste-skill-ignore: Netflix card overlay (scrim shadow), kept intentionally */
>
                                                Xem chi tiết
                                            </span>
                                        </div>
                                        <button
                                            type="button"
                                            onClick={(e) => handleUnlike(movie.slug, e)}
                                            title="Bỏ thích"
                                            className="absolute top-2 right-2 w-7 h-7 rounded-full bg-black/70 hover:bg-rose-600 text-white flex items-center justify-center transition-colors cursor-pointer"
                                        >
                                            <svg className="w-4 h-4 fill-current" viewBox="0 0 24 24">
                                                <path d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z" />
                                            </svg>
                                        </button>
                                    </Link>
                                    <div className="p-3 flex flex-col flex-1">
                                        <Link href={`/phim/${movie.slug}`} className="text-sm font-semibold text-white truncate hover:text-sky-400 transition-colors">
                                            {movie.name}
                                        </Link>
                                        <p className="text-xs text-slate-400 truncate mt-1">
                                            {movie.origin_name || movie.year || "Phim đặc sắc"}
                                        </p>
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
