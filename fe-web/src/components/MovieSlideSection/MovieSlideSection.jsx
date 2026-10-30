'use client'

import { useRef } from "react";
import Link from 'next/link';
import MovieSlide from '../MovieSlide/MovieSlide';

const MovieSlideSection = ({ title, type, movieData, topSection, badge }) => {
    const slideRef = useRef(null);

    const nextMovie = () => {
        slideRef.current?.slickNext();
    };

    const prevMovie = () => {
        slideRef.current?.slickPrev();
    };

    return (
        <section className={`section-container ${topSection ? 'mt-6 md:mt-12 lg:mt-16' : 'mt-8 md:mt-12'}`}>
            {/* Header row: title on the left, "Xem tất cả" + slide controls on the right (never overlapping) */}
            <div className="flex items-center justify-between gap-2 mb-3 sm:mb-4">
                <Link
                    aria-label={title}
                    href={`/${type}/1`}
                    className="group inline-flex items-center gap-2.5 min-w-0"
                >
                    <span className="w-1 h-5 sm:h-6 rounded-full bg-sky-500 group-hover:h-7 transition-[height] duration-300 shrink-0"></span>
                    <h2 className="text-white font-bold text-lg sm:text-2xl tracking-wide group-hover:text-sky-300 transition-colors flex items-center gap-2 min-w-0">
                        <span className="truncate">{title}</span>
                        {badge && (
                            <span className="text-[13px] font-semibold px-2.5 py-0.5 rounded-full bg-sky-500/15 text-sky-400 border border-sky-400/20 hidden sm:inline-block shrink-0">
                                {badge}
                            </span>
                        )}
                    </h2>
                    <svg
                        className="w-4 h-4 text-sky-400 opacity-0 group-hover:opacity-100 transform -translate-x-2 group-hover:translate-x-0 transition-[opacity,transform] duration-200 hidden sm:block shrink-0"
                        fill="none"
                        stroke="currentColor"
                        viewBox="0 0 24 24"
                    >
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M9 5l7 7-7 7" />
                    </svg>
                </Link>

                <div className="flex items-center gap-2 shrink-0">
                    <Link
                        href={`/${type}/1`}
                        className="text-xs sm:text-sm font-semibold text-sky-400/80 hover:text-sky-300 transition-colors flex items-center gap-1 py-1 px-2.5 rounded-lg hover:bg-white/[0.06] whitespace-nowrap"
                    >
                        <span>Xem tất cả</span>
                        <span className="group-hover:translate-x-1 transition-transform duration-200">→</span>
                    </Link>

                    {/* Slide control buttons, aligned with the heading row */}
                    <button
                        className="w-9 h-9 rounded-full bg-slate-900/90 hover:bg-sky-500 text-slate-300 hover:text-slate-950 border border-white/15 hover:border-sky-400 flex items-center justify-center transition-colors duration-200 cursor-pointer"
                        aria-label="Phim trước"
                        onClick={prevMovie}
                    >
                        <svg className='w-4 h-4 fill-current' viewBox="0 0 24 24">
                            <path d="M15.41 7.41L14 6l-6 6 6 6 1.41-1.41L10.83 12z"/>
                        </svg>
                    </button>

                    <button
                        className="w-9 h-9 rounded-full bg-slate-900/90 hover:bg-sky-500 text-slate-300 hover:text-slate-950 border border-white/15 hover:border-sky-400 flex items-center justify-center transition-colors duration-200 cursor-pointer"
                        aria-label="Phim tiếp"
                        onClick={nextMovie}
                    >
                        <svg className='w-4 h-4 fill-current' viewBox="0 0 24 24">
                            <path d="M10 6L8.59 7.41 13.17 12l-4.58 4.59L10 18l6-6z"/>
                        </svg>
                    </button>
                </div>
            </div>

            <MovieSlide movies={movieData} slideRef={slideRef} />
        </section>
    );
};

export default MovieSlideSection;
