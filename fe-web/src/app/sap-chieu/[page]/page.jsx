import getPageMovies from "@/functions/getPageMovies";
import MovieCard from "@/components/MovieCard/MovieCard";
import PageButtons from "@/components/PageButtons/PageButtons";
import Link from "next/link";

export async function generateMetadata({ params }) {
    return {
        title: `Phim Sắp Chiếu & Teaser Mới - Trang ${params.page} | OpenFlix`,
        description: 'Danh sách các bộ phim điện ảnh bom tấn sắp ra mắt tại rạp và trên OpenFlix.',
    };
}

export default async function ComingSoonPage({ params }) {
    const data = await getPageMovies('coming_soon', params.page);

    return (
        <div className="page-container-0topside">
            <div className="section-container">
                {/* Header */}
                <div className="pb-6 mb-8">
                    <div className="flex items-center gap-2 text-[13px] text-slate-400 mb-1">
                        <Link href="/" className="hover:text-sky-400 transition-colors">Trang chủ</Link>
                        <span>/</span>
                        <span className="text-sky-400 font-medium">Sắp chiếu</span>
                    </div>
                    <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-2 mt-1">
                        <div className="flex items-center gap-3">
                            <span className="w-10 h-10 rounded-xl bg-sky-500 text-slate-950 flex items-center justify-center">
                                <svg className="w-5 h-5 fill-none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                                </svg>
                            </span>
                            <div>
                                <h1 className="text-white text-2xl sm:text-3xl font-extrabold">Phim Sắp Ra Mắt</h1>
                                <p className="text-slate-400 text-sm mt-0.5">Những dự án bom tấn điện ảnh chuẩn bị đổ bộ trong thời gian tới</p>
                            </div>
                        </div>
                        <span className="self-start sm:self-center text-sm font-semibold px-3 py-1 rounded-full bg-cyan-500/15 text-cyan-300 tabular-nums">
                            Trang {params.page}
                        </span>
                    </div>
                </div>

                {/* Grid */}
                {data.data.length === 0 ? (
                    <div className="text-center py-20 bg-slate-900/40 rounded-2xl border border-white/5">
                        <p className="text-slate-400 text-base">Hiện tại chưa có lịch phát hành mới, vui lòng quay lại sau.</p>
                    </div>
                ) : (
                    <div className="movies-grid">
                        {data.data.map((movie, index) => (
                            <MovieCard key={index} movie={movie} />
                        ))}
                    </div>
                )}

                {/* Pagination */}
                {data.totalPages > 1 && (
                    <div className="mt-10 flex flex-row flex-wrap justify-center">
                        <PageButtons curr={params.page} total={data.totalPages} url="sap-chieu" />
                    </div>
                )}
            </div>
        </div>
    );
}

