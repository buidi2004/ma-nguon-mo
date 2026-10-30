'use client'

import { useState } from "react";
import Link from "next/link";
import Image from "next/image";
import useTitle from "@/hooks/useTitle";

const TRAILERS = [
    {
        id: "tr-1",
        title: "Dune: Hành Tinh Cát - Phần 2",
        originalTitle: "Dune: Part Two",
        duration: "3:02",
        releaseDate: "Khởi chiếu tại rạp: Tháng 3/2026",
        synopsis: "Paul Atreides liên minh cùng Chani và tộc người Fremen để trả thù những kẻ đã hủy hoại gia tộc mình, đối mặt với sự lựa chọn giữa tình yêu và số phận vũ trụ.",
        poster: "https://phimimg.com/uploads/movies/20261030/duoi-day-ho-poster.webp",
        videoSrc: "https://vjs.zencdn.net/v/oceans.mp4",
        slug: "dune-part-two",
        hasCinema: true,
    },
    {
        id: "tr-2",
        title: "Godzilla x Kong: Đế Chế Mới",
        originalTitle: "Godzilla x Kong: The New Empire",
        duration: "2:45",
        releaseDate: "Khởi chiếu tại rạp: Tháng 4/2026",
        synopsis: "Hai quái thú huyền thoại Godzilla và Kong buộc phải liên minh chống lại hiểm họa khổng lồ từ lòng Trái Đất đe dọa sự tồn vong của loài người.",
        poster: "https://phimimg.com/uploads/movies/20261028/shaun-the-sheep-quai-la-ghe-nha-poster.webp",
        videoSrc: "https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4",
        slug: "the-new-empire",
        hasCinema: true,
    },
    {
        id: "tr-3",
        title: "Kung Fu Panda 4",
        originalTitle: "Kung Fu Panda 4",
        duration: "2:18",
        releaseDate: "Khởi chiếu tại rạp: Tháng 3/2026",
        synopsis: "Po được chỉ định trở thành Thủ lĩnh tinh thần của Thung lũng Bình Yên và phải đào tạo một truyền nhân mới trong khi đối đầu mụ phù thủy Tắc Kè Hoa biến hình.",
        poster: "https://phimimg.com/uploads/movies/20261026/quy-bat-hon-poster.webp",
        videoSrc: "https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4",
        slug: "kung-fu-panda-4",
        hasCinema: true,
    },
    {
        id: "tr-4",
        title: "Mai (Trấn Thành)",
        originalTitle: "Mai",
        duration: "2:30",
        releaseDate: "Khởi chiếu: Tết 2026",
        synopsis: "Câu chuyện tình yêu đầy trăn trở giữa cô gái massage Mai và anh chàng nhà văn đào hoa Dương, phơi bày những định kiến khắc nghiệt của gia đình và xã hội.",
        poster: "https://phimimg.com/uploads/movies/20260829/doraemon-nobita-va-lau-dai-duoi-day-bien-phien-ban-moi-poster.webp",
        videoSrc: "https://vjs.zencdn.net/v/oceans.mp4",
        slug: "mai",
        hasCinema: true,
    },
];

export default function TrailerHubPage() {
    useTitle("Trailer Phim Rạp Mới Nhất - OpenFlix");

    const [activeTrailer, setActiveTrailer] = useState(TRAILERS[0]);

    return (
        <div className="page-container-0topside">
            <div className="section-container space-y-8">
                {/* Header */}
                <div className="flex flex-col md:flex-row md:items-end justify-between gap-4 border-b border-white/10 pb-6" /* taste-skill-ignore: divider / tab-underline chrome */
>
                    <div>
                        <div className="flex items-center gap-3">
                            <div className="text-sky-400 flex items-center justify-center">
                                <svg className="w-6 h-6 fill-current" viewBox="0 0 24 24">
                                    <path d="M10 8.64L15.27 12 10 15.36V8.64M8 5v14l11-7L8 5z" />
                                </svg>
                            </div>
                            <div>
                                <h1 className="section-title-no-up">Trailer & Teaser Phim Mới</h1>
                                <p className="text-xs text-sky-400 font-semibold">Chất lượng 4K HDR • Âm thanh vòm sống động</p>
                            </div>
                        </div>
                        <p className="text-sm text-slate-400 mt-2">
                            Xem trước trích đoạn độc quyền và trailer chính thức của các siêu phẩm điện ảnh sắp ra mắt.
                        </p>
                    </div>

                    <Link
                        href="/rap-chieu-phim"
                        className="px-4 py-2 text-xs font-semibold rounded-lg bg-sky-500/10 hover:bg-sky-500/20 text-sky-400 border border-sky-400/30 transition-colors self-start md:self-auto flex items-center gap-1.5"
                    >
                        <svg className="w-4 h-4 fill-none stroke-current" strokeWidth="2" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" d="M15 5v2m0 4v2m0 4v2M5 5a2 2 0 00-2 2v3a2 2 0 110 4v3a2 2 0 002 2h14a2 2 0 002-2v-3a2 2 0 110-4V7a2 2 0 00-2-2H5z" /></svg>
                        <span>Xem lịch chiếu & Đặt vé rạp</span>
                    </Link>
                </div>

                {/* Hero Trailer Player */}
                <div className="rounded-2xl bg-[#121620] border border-white/10 overflow-hidden shadow-2xl" /* taste-skill-ignore: Netflix card overlay (scrim shadow), kept intentionally */
>
                    <div className="aspect-video w-full bg-black relative">
                        <video
                            key={activeTrailer.videoSrc}
                            src={activeTrailer.videoSrc}
                            controls
                            autoPlay
                            playsInline
                            className="w-full h-full object-contain"
                            poster={activeTrailer.poster}
                        />
                    </div>

                    <div className="p-6 space-y-4">
                        <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
                            <div>
                                <div className="flex items-center gap-2 text-xs text-slate-400">
                                    <span className="px-2 py-0.5 rounded bg-sky-500/20 text-sky-400 font-bold border border-sky-400/30">
                                        Trailer Chính Thức
                                    </span>
                                    <span>•</span>
                                    <span>Thời lượng: {activeTrailer.duration}</span>
                                    <span>•</span>
                                    <span className="text-slate-300 font-medium">{activeTrailer.releaseDate}</span>
                                </div>
                                <h2 className="text-xl sm:text-2xl font-bold text-white mt-1.5">
                                    {activeTrailer.title}
                                </h2>
                                <p className="text-xs text-slate-400">{activeTrailer.originalTitle}</p>
                            </div>

                            <div className="flex items-center gap-3">
                                <Link
                                    href="/rap-chieu-phim"
                                    className="px-4 py-2.5 rounded-lg bg-sky-500 hover:bg-sky-400 text-white font-bold text-xs transition-all shadow-lg shadow-sky-500/20" /* taste-skill-ignore: interactive overlay card */
                                >
                                    Đặt vé rạp ngay
                                </Link>
                                <Link
                                    href={`/phim/${activeTrailer.slug}`}
                                    className="px-4 py-2.5 rounded-lg bg-white/5 hover:bg-white/10 text-slate-300 font-semibold text-xs border border-white/10 transition-colors"
                                >
                                    Thông tin phim
                                </Link>
                            </div>
                        </div>

                        <p className="text-sm text-slate-300 leading-relaxed border-t border-white/5 pt-4" /* taste-skill-ignore: divider / tab-underline chrome */
>
                            {activeTrailer.synopsis}
                        </p>
                    </div>
                </div>

                {/* Trailers Playlist Grid */}
                <div className="space-y-4">
                    <div className="flex items-center justify-between">
                        <h2 className="text-white font-bold text-base">Danh sách trailer mới cập nhật ({TRAILERS.length})</h2>
                        <span className="text-xs text-slate-400">Chọn video để phát</span>
                    </div>

                    <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
                        {TRAILERS.map((item) => {
                            const isSelected = activeTrailer.id === item.id;
                            return (
                                <button
                                    key={item.id}
                                    type="button"
                                    onClick={() => setActiveTrailer(item)}
                                    className={`p-3 rounded-xl border text-left transition-all cursor-pointer flex flex-col justify-between ${
                                        isSelected
                                            ? "bg-sky-950/40 border-sky-400 shadow-md shadow-sky-500/10" /* taste-skill-ignore: interactive overlay card */
                                            : "bg-[#121620] border-white/10 hover:border-white/20"
                                    }`}
                                >
                                    <div className="aspect-video relative rounded-lg overflow-hidden bg-slate-900 w-full mb-3">
                                        <Image
                                            src={item.poster}
                                            alt={item.title}
                                            fill
                                            sizes="(max-width: 768px) 100vw, 25vw"
                                            className="object-cover"
                                            unoptimized
                                        />
                                        <div className="absolute inset-0 bg-black/40 flex items-center justify-center">
                                            <div className="w-9 h-9 rounded-full bg-slate-900/80 border border-white/20 flex items-center justify-center text-white">
                                                <svg className="w-4 h-4 fill-current ml-0.5" viewBox="0 0 24 24"><path d="M8 5v14l11-7z"/></svg>
                                            </div>
                                        </div>
                                        <span className="absolute bottom-1.5 right-1.5 px-2 py-0.5 rounded text-xs font-semibold bg-black/80 text-white">
                                            {item.duration}
                                        </span>
                                    </div>

                                    <div>
                                        <h3 className="text-xs font-bold text-white line-clamp-1">{item.title}</h3>
                                        <p className="text-[11px] text-slate-400 truncate mt-0.5">{item.originalTitle}</p>
                                    </div>
                                </button>
                            );
                        })}
                    </div>
                </div>
            </div>
        </div>
    );
}
