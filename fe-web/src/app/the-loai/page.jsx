import Link from "next/link";
import { GENRES } from "@/functions/getPageMovies";

export const metadata = {
    title: 'Tất cả Thể loại Phim | OpenFlix',
    description: 'Khám phá phim theo thể loại yêu thích: Hành động, Viễn tưởng, Hoạt hình, Kinh dị, Tình cảm...',
};

export default function GenreIndexPage() {
    return (
        <div className="page-container-0topside">
            <div className="section-container">
                <div className="flex flex-col md:flex-row md:items-end justify-between border-b border-white/10 pb-6 mb-8" /* taste-skill-ignore: divider / tab-underline chrome */
>
                    <div>
                        <span className="text-sky-400 font-semibold text-sm">Danh mục điện ảnh</span>
                        <h1 className="text-white text-3xl sm:text-4xl font-black mt-1">Khám phá theo Thể Loại</h1>
                    </div>
                    <p className="text-slate-400 text-sm mt-2 md:mt-0 max-w-md">
                        Chọn thể loại yêu thích để xem kho phim chất lượng cao Full HD & 4K không quảng cáo.
                    </p>
                </div>

                {/* Genres Grid */}
                <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 gap-4 sm:gap-6">
                    {GENRES.map((genre) => (
                        <Link
                            key={genre.slug}
                            href={`/the-loai/${genre.slug}/1`}
                            className="group relative p-6 rounded-2xl bg-[#121620] hover:bg-[#1a202c] border border-white/10 hover:border-sky-400/60 transition-colors duration-200 flex flex-col justify-between overflow-hidden cursor-pointer"
                        >
                            <div className="w-10 h-10 rounded-xl bg-sky-500/10 border border-sky-400/25 flex items-center justify-center text-sky-400 mb-4 group-hover:bg-sky-500 group-hover:text-slate-950 transition-colors">
                                <svg className="w-5 h-5 fill-current" viewBox="0 0 24 24">
                                    <path d="M18 4l2 4h-3l-2-4h-2l2 4h-3l-2-4H8l2 4H7L5 4H4c-1.1 0-1.99.9-1.99 2L2 18c0 1.1.9 2 2 2h16c1.1 0 2-.9 2-2V4h-4z"/>
                                </svg>
                            </div>

                            <div>
                                <h2 className="text-white font-bold text-lg sm:text-xl group-hover:text-sky-400 transition-colors">
                                    {genre.name}
                                </h2>
                                <span className="inline-flex items-center text-xs font-semibold text-sky-400 mt-2 group-hover:text-sky-300">
                                    Khám phá ngay →
                                </span>
                            </div>
                        </Link>
                    ))}
                </div>
            </div>
        </div>
    );
}

