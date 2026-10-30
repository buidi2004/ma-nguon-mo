import getPageMovies, { COUNTRIES } from "@/functions/getPageMovies";
import MovieCard from "@/components/MovieCard/MovieCard";
import PageButtons from "@/components/PageButtons/PageButtons";
import Link from "next/link";

export async function generateMetadata({ params }) {
    const country = COUNTRIES.find((c) => c.slug === params.country);
    const countryName = country?.name || params.country;
    return {
        title: `Phim ${countryName} - Trang ${params.page} | OpenFlix`,
        description: `Danh sách phim ${countryName} tuyển chọn chất lượng cao Full HD & 4K không quảng cáo.`,
    };
}

export default async function CountryPage({ params }) {
    const data = await getPageMovies(params.country, params.page);
    const currentCountry = COUNTRIES.find((c) => c.slug === params.country);
    const countryName = currentCountry?.name || params.country;

    return (
        <div className="page-container-0topside">
            <div className="section-container">
                {/* Header & Breadcrumb */}
                <div className="flex flex-col md:flex-row md:items-end justify-between pb-5 mb-8">
                    <div>
                        <div className="flex items-center gap-2 text-[13px] text-slate-400 mb-2">
                            <Link href="/" className="hover:text-sky-400 transition-colors">Trang chủ</Link>
                            <span>/</span>
                            <Link href="/quoc-gia" className="hover:text-sky-400 transition-colors">Quốc gia</Link>
                            <span>/</span>
                            <span className="text-sky-400 font-semibold">{countryName}</span>
                        </div>
                        <h1 className="section-title-no-up flex items-center gap-2.5">
                            <span className="w-2 h-7 rounded-full bg-sky-500"></span>
                            <span>Phim {countryName}</span>
                            <span className="text-sm font-normal text-slate-400 self-end mb-1 tabular-nums">
                                (Trang {params.page}/{data.totalPages})
                            </span>
                        </h1>
                    </div>

                    {/* Quick switch between countries */}
                    <div className="flex flex-wrap gap-1.5 mt-4 md:mt-0">
                        {COUNTRIES.slice(0, 5).map((c) => (
                            <Link
                                key={c.slug}
                                href={`/quoc-gia/${c.slug}/1`}
                                className={`px-2.5 py-1 text-xs rounded-lg transition-all ${
                                    c.slug === params.country
                                        ? 'bg-sky-500 text-slate-950 font-bold shadow-md shadow-sky-500/30' /* taste-skill-ignore: interactive overlay card */
                                        : 'bg-white/[0.06] text-slate-300 hover:text-white hover:bg-white/[0.12] border border-white/10'
                                }`}
                            >
                                {c.name}
                            </Link>
                        ))}
                    </div>
                </div>

                {/* Movies Grid */}
                {data.data.length === 0 ? (
                    <div className="p-12 text-center rounded-2xl bg-[#121620] border border-white/10 max-w-md mx-auto">
                        <div className="w-14 h-14 mx-auto mb-3 rounded-xl bg-sky-500/10 border border-sky-400/30 flex items-center justify-center text-sky-400">
                            <svg className="w-7 h-7 fill-none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.5" d="M3.055 11H5a2 2 0 012 2v1a2 2 0 002 2 2 2 0 012 2v2.945M8 3.935V5.5A2.5 2.5 0 0010.5 8h.5a2 2 0 012 2 2 2 0 104 0 2 2 0 012-2h1.064M15 20.488V18a2 2 0 012-2h3.064M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
                        </div>
                        <h2 className="text-lg font-bold text-white mb-2">Đang cập nhật phim {countryName}</h2>
                        <p className="text-slate-400 text-sm mb-6">Hệ thống đang đồng bộ dữ liệu cho quốc gia này.</p>
                        <Link href="/quoc-gia" className="play-button-color px-6 py-2.5 text-xs font-semibold inline-flex items-center gap-2">
                            Xem Quốc Gia Khác
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
                        <PageButtons curr={params.page} total={data.totalPages} url={`quoc-gia/${params.country}`} />
                    </div>
                )}
            </div>
        </div>
    );
}

