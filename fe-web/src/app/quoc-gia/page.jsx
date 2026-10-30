import Link from "next/link";
import { COUNTRIES } from "@/functions/getPageMovies";

export const metadata = {
    title: 'Phim Theo Quốc Gia | OpenFlix',
    description: 'Khám phá kho phim điện ảnh chọn lọc theo từng quốc gia: Âu Mỹ Hollywood, Hàn Quốc, Trung Quốc, Nhật Bản, Việt Nam, Thái Lan...',
};

const COUNTRY_CODES = {
    'au-my': 'US/EU',
    'han-quoc': 'KOR',
    'trung-quoc': 'CHN',
    'nhat-ban': 'JPN',
    'viet-nam': 'VNM',
    'thai-lan': 'THA',
    'an-do': 'IND',
    'quoc-te': 'INTL',
};

const COUNTRY_DESC = {
    'au-my': 'Phim bom tấn Hollywood, kỹ xảo điện ảnh đỉnh cao và hành động mãn nhãn.',
    'han-quoc': 'Phim truyền hình lãng mạn K-Drama, tâm lý tội phạm và phim chiếu rạp hấp dẫn.',
    'trung-quoc': 'Phim cổ trang võ thuật kiếm hiệp, thần thoại và phim tiên hiệp đặc sắc.',
    'nhat-ban': 'Thế giới Anime kinh điển, phim live-action và điện ảnh nghệ thuật xứ hoa anh đào.',
    'viet-nam': 'Phim điện ảnh Việt Nam chiếu rạp, hài hước và gia đình gần gũi.',
    'thai-lan': 'Phim kinh dị giật gân, phim hài hước học đường và hành động Thái Lan.',
    'an-do': 'Điện ảnh Bollywood hoành tráng, âm nhạc cuốn hút và hành động kỳ ảo.',
    'quoc-te': 'Tổng hợp các tác phẩm điện ảnh đa quốc gia chọn lọc trên toàn thế giới.',
};

export default function CountryIndexPage() {
    return (
        <div className="page-container-0topside">
            <div className="section-container">
                <div className="flex flex-col md:flex-row md:items-end justify-between border-b border-white/10 pb-6 mb-8" /* taste-skill-ignore: divider / tab-underline chrome */
>
                    <div>
                        <span className="text-sky-400 font-semibold text-sm">Điện ảnh quốc tế</span>
                        <h1 className="text-white text-3xl sm:text-4xl font-black mt-1">Phim Theo Quốc Gia</h1>
                    </div>
                    <p className="text-slate-400 text-sm mt-2 md:mt-0 max-w-md">
                        Chọn quốc gia điện ảnh bạn yêu thích để thưởng thức những tác phẩm bản quyền chất lượng cao Full HD.
                    </p>
                </div>

                {/* Country Grid */}
                <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5">
                    {COUNTRIES.map((country) => (
                        <Link
                            key={country.slug}
                            href={`/quoc-gia/${country.slug}/1`}
                            className="group relative p-6 rounded-2xl bg-[#121620] hover:bg-[#1a202c] border border-white/10 hover:border-sky-400/60 transition-colors duration-200 flex flex-col justify-between overflow-hidden cursor-pointer"
                        >
                            <div>
                                <div className="w-14 h-11 rounded-lg bg-sky-500/10 border border-sky-400/25 flex items-center justify-center text-sky-400 font-black text-xs tracking-wider mb-4 group-hover:bg-sky-500 group-hover:text-slate-950 transition-colors">
                                    {COUNTRY_CODES[country.slug] || 'WORLD'}
                                </div>
                                <h2 className="text-white font-bold text-xl group-hover:text-sky-400 transition-colors">
                                    {country.name}
                                </h2>
                                <p className="text-slate-400 text-xs mt-2 leading-relaxed">
                                    {COUNTRY_DESC[country.slug] || 'Khám phá kho phim điện ảnh hấp dẫn.'}
                                </p>
                            </div>

                            <span className="inline-flex items-center text-xs font-semibold text-sky-400 mt-5 group-hover:text-sky-300 gap-1">
                                <span>Xem danh sách phim</span>
                                <span className="group-hover:translate-x-1 transition-transform">→</span>
                            </span>
                        </Link>
                    ))}
                </div>
            </div>
        </div>
    );
}

