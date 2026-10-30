import Link from "next/link";
import { YEARS } from "@/functions/getPageMovies";

export const metadata = {
    title: 'Phim Theo Năm Phát Hành | OpenFlix',
    description: 'Lọc và xem phim điện ảnh theo từng năm phát hành từ năm 2024, 2023, 2022 đến các tác phẩm kinh điển.',
};

export default function YearIndexPage() {
    return (
        <div className="page-container-0topside">
            <div className="section-container">
                <div className="flex flex-col md:flex-row md:items-end justify-between pb-6 mb-8">
                    <div>
                        <p className="text-sky-400 font-semibold text-sm">Dòng thời gian điện ảnh</p>
                        <h1 className="text-white text-3xl sm:text-4xl font-extrabold mt-1">Phim Theo Năm Phát Hành</h1>
                    </div>
                    <p className="text-slate-400 text-base mt-2 md:mt-0 max-w-md">
                        Chọn năm sản xuất để xem lại những bộ phim bom tấn cùng năm với chất lượng hình ảnh sắc nét.
                    </p>
                </div>

                {/* Years Grid */}
                <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 gap-5">
                    {YEARS.map((y) => (
                        <Link
                            key={y.slug}
                            href={`/nam-phat-hanh/${y.slug}/1`}
                            className="group relative p-6 rounded-2xl bg-[#121620] hover:bg-[#1a202c] transition-colors duration-200 flex flex-col justify-between overflow-hidden cursor-pointer"
                        >
                            <div className="text-3xl sm:text-4xl font-black text-sky-400 mb-2">
                                {y.slug === 'truoc-2018' ? '< 2018' : y.slug}
                            </div>

                            <div>
                                <h2 className="text-white font-bold text-lg group-hover:text-sky-400 transition-colors">
                                    {y.name}
                                </h2>
                                <span className="inline-flex items-center text-xs font-semibold text-sky-400/80 mt-3 group-hover:text-sky-300 gap-1">
                                    <span>Khám phá phim</span>
                                    <span className="group-hover:translate-x-1 transition-transform">→</span>
                                </span>
                            </div>
                        </Link>
                    ))}
                </div>
            </div>
        </div>
    );
}

