import getPageMovies, { GENRES } from "@/functions/getPageMovies";
import MovieCard from "@/components/MovieCard/MovieCard";
import PageButtons from "@/components/PageButtons/PageButtons";
import Link from "next/link";

export async function generateMetadata({ params }) {
    const genre = GENRES.find((g) => g.slug === params.genre);
    const genreName = genre ? genre.name : params.genre;
    return {
        title: `Phim ${genreName} - Trang ${params.page} | OpenFlix`,
        description: `Danh sách phim ${genreName} Full HD mới nhất trên OpenFlix.`,
    };
}

export default async function GenrePage({ params }) {
    const genre = GENRES.find((g) => g.slug === params.genre);
    const genreName = genre ? genre.name : params.genre;

    // Fetch data from PocketBase
    const data = await getPageMovies(params.genre, params.page);

    return (
        <div className="page-container-0topside">
            <div className="section-container">
                {/* Header with breadcrumb */}
                <div className="flex flex-col sm:flex-row sm:items-center justify-between border-b border-white/10 pb-5 mb-6" /* taste-skill-ignore: divider / tab-underline chrome */
>
                    <div>
                        <div className="flex items-center gap-2 text-xs text-slate-400 mb-1">
                            <Link href="/" className="hover:text-sky-400 transition-colors">Trang chủ</Link>
                            <span>/</span>
                            <Link href="/the-loai" className="hover:text-sky-400 transition-colors">Thể loại</Link>
                            <span>/</span>
                            <span className="text-sky-400 font-medium">{genreName}</span>
                        </div>
                        <h1 className="text-white text-2xl sm:text-3xl font-extrabold flex items-center gap-2">
                            <span>Phim {genreName}</span>
                            <span className="text-xs font-semibold px-2.5 py-0.5 rounded-full bg-sky-500/10 text-sky-400 border border-sky-500/20">
                                Trang {params.page}
                            </span>
                        </h1>
                    </div>
                    <Link
                        href="/the-loai"
                        className="text-xs font-medium text-sky-400 hover:text-sky-300 mt-2 sm:mt-0 flex items-center gap-1"
                    >
                        Tất cả thể loại →
                    </Link>
                </div>

                {/* Movies Grid */}
                {data.data.length === 0 ? (
                    <div className="text-center py-20 bg-slate-900/40 rounded-2xl border border-white/5">
                        <p className="text-slate-400 text-base">Chưa có phim cho thể loại này hoặc đang cập nhật.</p>
                        <Link href="/the-loai" className="inline-block mt-4 text-sky-400 underline underline-offset-4 text-sm font-semibold">
                            Xem thể loại khác
                        </Link>
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
                        <PageButtons curr={params.page} total={data.totalPages} url={`the-loai/${params.genre}`} />
                    </div>
                )}
            </div>
        </div>
    );
}

