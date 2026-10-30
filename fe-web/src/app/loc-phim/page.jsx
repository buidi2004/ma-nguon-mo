'use client'

import { useState, useEffect } from "react";
import Link from "next/link";
import { GENRES, COUNTRIES, YEARS } from "@/functions/getPageMovies";
import { fetchPocketBase, mapMovieToCard } from "@/functions/pocketbase";
import MovieCard from "@/components/MovieCard/MovieCard";
import useTitle from "@/hooks/useTitle";

const MOVIE_TYPES = [
    { slug: 'all', name: 'Tất cả loại phim' },
    { slug: 'single', name: 'Phim lẻ' },
    { slug: 'series', name: 'Phim bộ' },
    { slug: 'theater', name: 'Chiếu rạp' },
    { slug: 'cartoon', name: 'Hoạt hình' },
];

const SORT_OPTIONS = [
    { slug: '-created', name: 'Mới cập nhật' },
    { slug: '-rank', name: 'Xem nhiều nhất' },
    { slug: '-release_year', name: 'Năm mới nhất' },
    { slug: 'title', name: 'Tên A - Z' },
];

export default function AdvancedFilterPage() {
    useTitle("Bộ lọc phim nâng cao | OpenFlix");

    const [genre, setGenre] = useState('all');
    const [country, setCountry] = useState('all');
    const [year, setYear] = useState('all');
    const [movieType, setMovieType] = useState('all');
    const [sortBy, setSortBy] = useState('-created');

    const [movies, setMovies] = useState([]);
    const [loading, setLoading] = useState(true);

    const applyFilter = async () => {
        setLoading(true);
        try {
            const filters = [];

            // 1. Genre filter
            if (genre !== 'all') {
                const g = GENRES.find((item) => item.slug === genre);
                if (g?.filter) filters.push(g.filter);
            }

            // 2. Country filter
            if (country !== 'all') {
                const c = COUNTRIES.find((item) => item.slug === country);
                if (c?.filter) filters.push(c.filter);
            }

            // 3. Year filter
            if (year !== 'all') {
                const y = YEARS.find((item) => item.slug === year);
                if (y?.filter) filters.push(y.filter);
            }

            // 4. Movie type filter
            if (movieType === 'theater') {
                filters.push("category ~ 'Hành động' || category ~ 'Viễn tưởng' || category ~ 'Chiếu rạp'");
            } else if (movieType === 'series') {
                filters.push("category ~ 'Bộ' || category ~ 'Tình cảm' || category ~ 'Tâm lý'");
            } else if (movieType === 'single') {
                filters.push("category ~ 'Hài hước' || category ~ 'Kinh dị' || category ~ 'Võ thuật'");
            } else if (movieType === 'cartoon') {
                filters.push("category ~ 'Hoạt hình'");
            }

            const filterString = filters.length > 0 ? filters.map((f) => `(${f})`).join(' && ') : '';
            let endpoint = `/api/collections/movies/records?page=1&perPage=36&sort=${sortBy}`;
            if (filterString) {
                endpoint += `&filter=(${encodeURIComponent(filterString)})`;
            }

            const res = await fetchPocketBase(endpoint);
            let items = res?.items || [];

            // If empty, fetch fallback
            if (items.length === 0) {
                const fallbackRes = await fetchPocketBase(`/api/collections/movies/records?page=1&perPage=24&sort=${sortBy}`);
                items = fallbackRes?.items || [];
            }

            setMovies(items.map(mapMovieToCard).filter(Boolean));
        } catch (e) {
            console.error('[AdvancedFilterPage] Error:', e);
            setMovies([]);
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        applyFilter();
    }, [genre, country, year, movieType, sortBy]);

    const resetFilters = () => {
        setGenre('all');
        setCountry('all');
        setYear('all');
        setMovieType('all');
        setSortBy('-created');
    };

    return (
        <div className="page-container-0topside">
            <div className="section-container">
                {/* Header */}
                <div className="pb-6 mb-8">
                    <div className="flex items-center gap-2 text-[13px] text-slate-400 mb-2">
                        <Link href="/" className="hover:text-sky-400 transition-colors">Trang chủ</Link>
                        <span>/</span>
                        <span className="text-sky-400 font-semibold">Bộ lọc nâng cao</span>
                    </div>
                    <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
                        <div>
                            <h1 className="section-title-no-up flex items-center gap-2.5">
                                <span className="w-2 h-7 rounded-full bg-sky-500"></span>
                                <span>Bộ Lọc Phim Đa Tiêu Chí</span>
                            </h1>
                            <p className="text-slate-400 text-base mt-1">
                                Kết hợp nhiều tiêu chí để tìm kiếm chính xác bộ phim bạn muốn xem.
                            </p>
                        </div>

                        <button
                            onClick={resetFilters}
                            className="px-4 py-2 text-[13px] font-semibold rounded-xl bg-white/[0.08] hover:bg-sky-500/20 text-slate-300 hover:text-white transition-colors flex items-center gap-1.5 w-fit cursor-pointer"
                        >
                            <svg className="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
                            </svg>
                            <span>Đặt lại bộ lọc</span>
                        </button>
                    </div>
                </div>

                {/* Filter Control Board */}
                <div className="p-6 rounded-2xl bg-[#121620] mb-10 space-y-6">
                    {/* 1. Kiểu phim */}
                    <div>
                        <span className="text-sm font-semibold text-slate-300 block mb-2.5">
                            1. Định dạng phim:
                        </span>
                        <div className="flex flex-wrap gap-2">
                            {MOVIE_TYPES.map((t) => (
                                <button
                                    key={t.slug}
                                    onClick={() => setMovieType(t.slug)}
                                    className={`px-3.5 py-1.5 text-xs sm:text-sm font-medium rounded-xl transition-colors duration-200 cursor-pointer ${
                                        movieType === t.slug
                                            ? 'bg-sky-500 text-slate-950 font-bold'
                                            : 'bg-white/[0.06] text-slate-300 hover:text-white hover:bg-white/[0.12] border border-white/10'
                                    }`}
                                >
                                    {t.name}
                                </button>
                            ))}
                        </div>
                    </div>

                    {/* 2. Thể loại */}
                    <div>
                        <span className="text-sm font-semibold text-slate-300 block mb-2.5">
                            2. Thể loại:
                        </span>
                        <div className="flex flex-wrap gap-2 max-h-36 overflow-y-auto no-scrollbar">
                            <button
                                onClick={() => setGenre('all')}
                                className={`px-3.5 py-1.5 text-xs sm:text-sm font-medium rounded-xl transition-colors duration-200 cursor-pointer ${
                                    genre === 'all'
                                        ? 'bg-sky-500 text-slate-950 font-bold'
                                        : 'bg-white/[0.06] text-slate-300 hover:text-white hover:bg-white/[0.12] border border-white/10'
                                }`}
                            >
                                Tất cả thể loại
                            </button>
                            {GENRES.map((g) => (
                                <button
                                    key={g.slug}
                                    onClick={() => setGenre(g.slug)}
                                    className={`px-3.5 py-1.5 text-xs sm:text-sm font-medium rounded-xl transition-colors duration-200 cursor-pointer ${
                                        genre === g.slug
                                            ? 'bg-sky-500 text-slate-950 font-bold'
                                            : 'bg-white/[0.06] text-slate-300 hover:text-white hover:bg-white/[0.12] border border-white/10'
                                    }`}
                                >
                                    {g.name}
                                </button>
                            ))}
                        </div>
                    </div>

                    {/* 3. Quốc gia */}
                    <div>
                        <span className="text-sm font-semibold text-slate-300 block mb-2.5">
                            3. Quốc gia:
                        </span>
                        <div className="flex flex-wrap gap-2">
                            <button
                                onClick={() => setCountry('all')}
                                className={`px-3.5 py-1.5 text-xs sm:text-sm font-medium rounded-xl transition-colors duration-200 cursor-pointer ${
                                    country === 'all'
                                        ? 'bg-sky-500 text-slate-950 font-bold'
                                        : 'bg-white/[0.06] text-slate-300 hover:text-white hover:bg-white/[0.12] border border-white/10'
                                }`}
                            >
                                Tất cả quốc gia
                            </button>
                            {COUNTRIES.map((c) => (
                                <button
                                    key={c.slug}
                                    onClick={() => setCountry(c.slug)}
                                    className={`px-3.5 py-1.5 text-xs sm:text-sm font-medium rounded-xl transition-colors duration-200 cursor-pointer ${
                                        country === c.slug
                                            ? 'bg-sky-500 text-slate-950 font-bold'
                                            : 'bg-white/[0.06] text-slate-300 hover:text-white hover:bg-white/[0.12] border border-white/10'
                                    }`}
                                >
                                    {c.name}
                                </button>
                            ))}
                        </div>
                    </div>

                    {/* 4. Năm phát hành & Sắp xếp */}
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-6 pt-4">
                        <div>
                            <span className="text-sm font-semibold text-slate-300 block mb-2.5">
                                4. Năm phát hành:
                            </span>
                            <div className="flex flex-wrap gap-2">
                                <button
                                    onClick={() => setYear('all')}
                                    className={`px-3.5 py-1.5 text-[13px] sm:text-sm font-medium rounded-xl transition-colors duration-200 cursor-pointer ${
                                        year === 'all'
                                            ? 'bg-sky-500 text-slate-950 font-bold'
                                            : 'bg-white/[0.06] text-slate-300 hover:text-white hover:bg-white/[0.12]'
                                    }`}
                                >
                                    Tất cả năm
                                </button>
                                {YEARS.map((y) => (
                                    <button
                                        key={y.slug}
                                        onClick={() => setYear(y.slug)}
                                        className={`px-3.5 py-1.5 text-[13px] sm:text-sm font-medium rounded-xl transition-colors duration-200 cursor-pointer ${
                                            year === y.slug
                                                ? 'bg-sky-500 text-slate-950 font-bold'
                                                : 'bg-white/[0.06] text-slate-300 hover:text-white hover:bg-white/[0.12]'
                                        }`}
                                    >
                                        {y.slug === 'truoc-2018' ? '< 2018' : y.slug}
                                    </button>
                                ))}
                            </div>
                        </div>

                        <div>
                            <span className="text-sm font-semibold text-slate-300 block mb-2.5">
                                5. Sắp xếp kết quả:
                            </span>
                            <div className="flex flex-wrap gap-2">
                                {SORT_OPTIONS.map((s) => (
                                    <button
                                        key={s.slug}
                                        onClick={() => setSortBy(s.slug)}
                                        className={`px-3.5 py-1.5 text-[13px] sm:text-sm font-medium rounded-xl transition-colors duration-200 cursor-pointer ${
                                            sortBy === s.slug
                                                ? 'bg-sky-500 text-slate-950 font-bold'
                                                : 'bg-white/[0.06] text-slate-300 hover:text-white hover:bg-white/[0.12]'
                                        }`}
                                    >
                                        {s.name}
                                    </button>
                                ))}
                            </div>
                        </div>
                    </div>
                </div>

                {/* Results Section */}
                <div className="mb-4 flex items-center justify-between">
                    <h2 className="text-white text-lg font-bold flex items-center gap-2">
                        <span>Kết quả tìm kiếm</span>
                        <span className="text-[13px] font-semibold px-2.5 py-0.5 rounded-full bg-sky-500/15 text-sky-400 tabular-nums">
                            {movies.length} phim
                        </span>
                    </h2>
                </div>

                {loading ? (
                    <div className="py-20 flex justify-center items-center">
                        <div className="loader"></div>
                    </div>
                ) : movies.length === 0 ? (
                    <div className="p-12 text-center rounded-2xl bg-[#121620] max-w-md mx-auto">
                        <div className="w-14 h-14 mx-auto mb-3 rounded-xl bg-white/[0.04] flex items-center justify-center text-slate-400">
                            <svg className="w-7 h-7 fill-none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.5" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/></svg>
                        </div>
                        <h3 className="text-white font-bold text-base mb-1">Không có phim phù hợp</h3>
                        <p className="text-slate-400 text-sm mb-4">Thử thay đổi hoặc giảm bớt các tiêu chí lọc bên trên.</p>
                        <button
                            onClick={resetFilters}
                            className="play-button-color px-5 py-2 text-sm font-semibold cursor-pointer"
                        >
                            Đặt lại bộ lọc
                        </button>
                    </div>
                ) : (
                    <div className="movies-grid">
                        {movies.map((movie) => (
                            <MovieCard key={movie._id} movie={movie} />
                        ))}
                    </div>
                )}
            </div>
        </div>
    );
}

