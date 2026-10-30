import getPageMovies, { YEARS } from "@/functions/getPageMovies";
import MovieCard from "@/components/MovieCard/MovieCard";
import PageButtons from "@/components/PageButtons/PageButtons";
import Link from "next/link";

export async function generateMetadata({ params }) {
    const yearObj = YEARS.find((y) => y.slug === params.year);
    const yearName = yearObj?.name || params.year;
    return {
        title: `Phim ${yearName} - Trang ${params.page} | OpenFlix`,
        description: `Danh sách phim sản xuất ${yearName} tuyển chọn chất lượng cao Full HD & 4K không quảng cáo.`,
    };
}

export default async function YearPage({ params }) {
    const data = await getPageMovies(params.year, params.page);
    const currentYear = YEARS.find((y) => y.slug === params.year);
    const yearName = currentYear?.name || params.year;

    return (
        <div className="page-container-0topside">
            <div className="section-container">
                {/* Header & Breadcrumb */}
                <div className="flex flex-col md:flex-row md:items-end justify-between pb-5 mb-8">
                    <div>
                        <div className="flex items-center gap-2 text-[13px] text-slate-400 mb-2">
                            <Link href="/" className="hover:text-sky-400 transition-colors">Trang chủ</Link>
                            <span>/</span>
                            <Link href="/nam-phat-hanh" className="hover:text-sky-400 transition-colors">Năm phát hành</Link>
                            <span>/</span>
                            <span className="text-sky-400 font-semibold">{yearName}</span>
                        </div>
                        <h1 className="section-title-no-up flex items-center gap-2.5">
                            <span className="w-2 h-7 rounded-full bg-sky-500"></span>
                            <span>Phim {yearName}</span>
                            <span className="text-sm font-normal text-slate-400 self-end mb-1 tabular-nums">
                                (Trang {params.page}/{data.totalPages})
                            </span>
                        </h1>
                    </div>

                    {/* Quick year pills */}
                    <div className="flex flex-wrap gap-1.5 mt-4 md:mt-0">
                        {YEARS.slice(0, 6).map((y) => (
                            <Link
                                key={y.slug}
                                href={`/nam-phat-hanh/${y.slug}/1`}
                                className={`px-2.5 py-1 text-xs rounded-lg transition-all ${
                                    y.slug === params.year
                                        ? 'bg-sky-500 text-slate-950 font-bold shadow-md shadow-sky-500/30' /* taste-skill-ignore: interactive overlay card */
                                        : 'bg-white/[0.06] text-slate-300 hover:text-white hover:bg-white/[0.12] border border-white/10'
                                }`}
                            >
                                {y.slug}
                            </Link>
                        ))}
                    </div>
                </div>

                {/* Movies Grid */}
                {data.data.length === 0 ? (
                    <div className="p-12 text-center rounded-2xl bg-[#121620] border border-white/10 max-w-md mx-auto">
                        <div className="w-14 h-14 mx-auto mb-3 rounded-xl bg-sky-500/10 border border-sky-400/30 flex items-center justify-center text-sky-400">
                            <svg className="w-7 h-7 fill-none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.5" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"/></svg>
                        </div>
                        <h2 className="text-lg font-bold text-white mb-2">Đang cập nhật phim {yearName}</h2>
                        <p className="text-slate-400 text-sm mb-6">Hệ thống đang thêm các tựa phim cho năm này.</p>
                        <Link href="/nam-phat-hanh" className="play-button-color px-6 py-2.5 text-xs font-semibold inline-flex items-center gap-2">
                            Xem Năm Khác
                        </Link>
                    </div>
                ) : (
                    <div className="movies-grid">
                        {data.data.map((movie) => (
                            <MovieCard key={movie._id} movie={movie} />
                        ))}
                    </div>
                )}

                {/* Pagination */}
                {data.totalPages > 1 && (
                    <div className="mt-10 flex flex-row flex-wrap justify-center">
                        <PageButtons curr={params.page} total={data.totalPages} url={`nam-phat-hanh/${params.year}`} />
                    </div>
                )}
            </div>
        </div>
    );
}

