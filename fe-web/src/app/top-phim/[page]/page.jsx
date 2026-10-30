import getPageMovies from "@/functions/getPageMovies";
import MovieCard from "@/components/MovieCard/MovieCard";
import PageButtons from "@/components/PageButtons/PageButtons";
import Link from "next/link";

export async function generateMetadata({ params }) {
    return {
        title: `Bảng Xếp Hạng Phim Hot - Trang ${params.page} | OpenFlix`,
        description: 'Bảng xếp hạng phim được xem nhiều nhất, điểm rating cao nhất trên OpenFlix.',
    };
}

export default async function TopMoviesPage({ params }) {
    const data = await getPageMovies('top', params.page);

    return (
        <div className="page-container-0topside">
            <div className="section-container">
                {/* Header */}
                <div className="border-b border-white/10 pb-6 mb-8" /* taste-skill-ignore: divider / tab-underline chrome */
>
                    <div className="flex items-center gap-2 text-xs text-slate-400 mb-1">
                        <Link href="/" className="hover:text-sky-400 transition-colors">Trang chủ</Link>
                        <span>/</span>
                        <span className="text-sky-400 font-medium">Bảng xếp hạng</span>
                    </div>
                    <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-2 mt-1">
                        <div className="flex items-center gap-3">
                            <span className="w-10 h-10 rounded-xl bg-amber-500 text-slate-950 font-black text-xl flex items-center justify-center">
                                <svg className="w-5 h-5 fill-current" viewBox="0 0 24 24"><path d="M12 2l2.4 7.4h7.6l-6.2 4.5 2.4 7.4-6.2-4.5-6.2 4.5 2.4-7.4-6.2-4.5h7.6z"/></svg>
                            </span>
                            <div>
                                <h1 className="text-white text-2xl sm:text-3xl font-extrabold">Bảng Xếp Hạng Phim Thịnh Hành</h1>
                                <p className="text-slate-400 text-xs sm:text-sm mt-0.5">Top các bộ phim được khán giả yêu thích và xem nhiều nhất</p>
                            </div>
                        </div>
                        <span className="self-start sm:self-center text-xs font-semibold px-3 py-1 rounded-full bg-sky-500/10 text-sky-400 border border-sky-500/20">
                            Trang {params.page}
                        </span>
                    </div>
                </div>

                {/* Grid */}
                <div className="movies-grid">
                    {data.data.map((movie, index) => {
                        const globalRank = (parseInt(params.page, 10) - 1) * 18 + index + 1;
                        return (
                            <div key={index} className="relative">
                                {/* Top Rank Badges */}
                                <div className="absolute top-3 left-3 z-20 pointer-events-none">
                                    <span
                                        className={`w-7 h-7 rounded-lg flex items-center justify-center font-black text-xs ${
                                            globalRank === 1
                                                ? 'bg-amber-400 text-slate-950 ring-2 ring-amber-300 shadow-amber-500/50'
                                                : globalRank === 2
                                                ? 'bg-slate-200 text-slate-950 ring-2 ring-slate-100 shadow-white/30'
                                                : globalRank === 3
                                                ? 'bg-amber-700 text-white ring-2 ring-amber-600 shadow-amber-800/50'
                                                : 'bg-sky-500/90 text-white font-bold backdrop-blur-sm'
                                        }`}
                                    >
                                        #{globalRank}
                                    </span>
                                </div>
                                <MovieCard movie={movie} />
                            </div>
                        );
                    })}
                </div>

                {/* Pagination */}
                {data.totalPages > 1 && (
                    <div className="mt-10 flex flex-row flex-wrap justify-center">
                        <PageButtons curr={params.page} total={data.totalPages} url="top-phim" />
                    </div>
                )}
            </div>
        </div>
    );
}

