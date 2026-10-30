"use client";

import { useState } from "react";
import Link from "next/link";
import Image from "next/image";
import useTitle from "@/hooks/useTitle";

const COLLECTIONS = [
    {
        id: "col-horror",
        title: "Vũ Trụ Kinh Dị & Tâm Linh Á Đông",
        subtitle: "Tuyển tập những tác phẩm rùng rợn đậm màu sắc văn hóa dân gian",
        totalRuntime: "7 giờ 15 phút",
        curator: "Hội đồng Biên tập OpenFlix",
        description:
            "Khám phá những truyền thuyết đô thị, nghi lễ cổ xưa và bí ẩn tâm linh phương Đông được tái hiện sống động qua góc máy điện ảnh hiện đại với âm thanh vòm chuẩn rạp.",
        movies: [
            {
                id: "c1-m1",
                name: "Dưới Đáy Hồ",
                originName: "Under The Lake",
                slug: "duoi-day-ho",
                year: 2024,
                chronologyOrder: 1,
                releaseOrder: 1,
                duration: "116 phút",
                rating: "8.8",
                quality: "4K HDR",
                poster: "https://phimimg.com/uploads/movies/20261030/duoi-day-ho-poster.webp",
            },
            {
                id: "c1-m2",
                name: "Quỷ Bắt Hồn",
                originName: "Soul Catcher",
                slug: "quy-bat-hon",
                year: 2024,
                chronologyOrder: 2,
                releaseOrder: 2,
                duration: "105 phút",
                rating: "8.4",
                quality: "Full HD",
                poster: "https://phimimg.com/uploads/movies/20261026/quy-bat-hon-poster.webp",
            },
            {
                id: "c1-m3",
                name: "Doraemon: Lâu Đài Dưới Đáy Biển",
                originName: "Castle of the Undersea",
                slug: "doraemon-nobita-va-lau-dai-duoi-day-bien-phien-ban-moi",
                year: 2024,
                chronologyOrder: 3,
                releaseOrder: 4,
                duration: "112 phút",
                rating: "8.9",
                quality: "Full HD",
                poster: "https://phimimg.com/uploads/movies/20260829/doraemon-nobita-va-lau-dai-duoi-day-bien-phien-ban-moi-poster.webp",
            },
            {
                id: "c1-m4",
                name: "Shaun The Sheep: Quái Lạ Ghé Nhà",
                originName: "Farmageddon",
                slug: "shaun-the-sheep-quai-la-ghe-nha",
                year: 2023,
                chronologyOrder: 4,
                releaseOrder: 3,
                duration: "86 phút",
                rating: "8.5",
                quality: "4K",
                poster: "https://phimimg.com/uploads/movies/20261028/shaun-the-sheep-quai-la-ghe-nha-poster.webp",
            },
        ],
    },
    {
        id: "col-animation",
        title: "Tuyển Tập Hoạt Hình Kinh Điển Gia Đình",
        subtitle: "Thế giới tuổi thơ đầy sắc màu và những cuộc phiêu lưu kỳ thú",
        totalRuntime: "6 giờ 40 phút",
        curator: "OpenFlix Family Hub",
        description:
            "Những bộ phim hoạt hình xuất sắc nhất dành cho mọi lứa tuổi, kết hợp giữa thông điệp nhân văn sâu sắc về tình bạn và trí tưởng tượng vượt không gian.",
        movies: [
            {
                id: "c2-m1",
                name: "Doraemon: Lâu Đài Dưới Đáy Biển",
                originName: "Nobita and the Castle of the Undersea",
                slug: "doraemon-nobita-va-lau-dai-duoi-day-bien-phien-ban-moi",
                year: 2024,
                chronologyOrder: 1,
                releaseOrder: 2,
                duration: "112 phút",
                rating: "8.9",
                quality: "Full HD",
                poster: "https://phimimg.com/uploads/movies/20260829/doraemon-nobita-va-lau-dai-duoi-day-bien-phien-ban-moi-poster.webp",
            },
            {
                id: "c2-m2",
                name: "Shaun The Sheep: Quái Lạ Ghé Nhà",
                originName: "Farmageddon",
                slug: "shaun-the-sheep-quai-la-ghe-nha",
                year: 2023,
                chronologyOrder: 2,
                releaseOrder: 1,
                duration: "86 phút",
                rating: "8.6",
                quality: "4K UHD",
                poster: "https://phimimg.com/uploads/movies/20261028/shaun-the-sheep-quai-la-ghe-nha-poster.webp",
            },
            {
                id: "c2-m3",
                name: "Dưới Đáy Hồ",
                originName: "Under The Lake",
                slug: "duoi-day-ho",
                year: 2024,
                chronologyOrder: 3,
                releaseOrder: 3,
                duration: "116 phút",
                rating: "8.8",
                quality: "Full HD",
                poster: "https://phimimg.com/uploads/movies/20261030/duoi-day-ho-poster.webp",
            },
            {
                id: "c2-m4",
                name: "Quỷ Bắt Hồn",
                originName: "Soul Catcher",
                slug: "quy-bat-hon",
                year: 2024,
                chronologyOrder: 4,
                releaseOrder: 4,
                duration: "105 phút",
                rating: "8.1",
                quality: "Full HD",
                poster: "https://phimimg.com/uploads/movies/20261026/quy-bat-hon-poster.webp",
            },
        ],
    },
    {
        id: "col-awards",
        title: "Tuyển Tập Tác Phẩm Đề Cử Liên Hoan Phim",
        subtitle: "Những bộ phim được giới phê bình quốc tế đánh giá cao nhất",
        totalRuntime: "8 giờ 10 phút",
        curator: "CineFlix Critics Choice",
        description:
            "Tập hợp các tác phẩm có kịch bản đột phá, nghệ thuật quay phim bậc thầy và diễn xuất để đời tại các liên hoan phim danh giá.",
        movies: [
            {
                id: "c3-m1",
                name: "Quỷ Bắt Hồn",
                originName: "Soul Catcher",
                slug: "quy-bat-hon",
                year: 2024,
                chronologyOrder: 1,
                releaseOrder: 1,
                duration: "105 phút",
                rating: "8.7",
                quality: "4K",
                poster: "https://phimimg.com/uploads/movies/20261026/quy-bat-hon-poster.webp",
            },
            {
                id: "c3-m2",
                name: "Dưới Đáy Hồ",
                originName: "Under The Lake",
                slug: "duoi-day-ho",
                year: 2024,
                chronologyOrder: 2,
                releaseOrder: 2,
                duration: "116 phút",
                rating: "8.8",
                quality: "4K HDR",
                poster: "https://phimimg.com/uploads/movies/20261030/duoi-day-ho-poster.webp",
            },
            {
                id: "c3-m3",
                name: "Shaun The Sheep: Quái Lạ Ghé Nhà",
                originName: "Farmageddon",
                slug: "shaun-the-sheep-quai-la-ghe-nha",
                year: 2023,
                chronologyOrder: 3,
                releaseOrder: 3,
                duration: "86 phút",
                rating: "8.5",
                quality: "Full HD",
                poster: "https://phimimg.com/uploads/movies/20261028/shaun-the-sheep-quai-la-ghe-nha-poster.webp",
            },
            {
                id: "c3-m4",
                name: "Doraemon: Lâu Đài Dưới Đáy Biển",
                originName: "Castle of the Undersea",
                slug: "doraemon-nobita-va-lau-dai-duoi-day-bien-phien-ban-moi",
                year: 2024,
                chronologyOrder: 4,
                releaseOrder: 4,
                duration: "112 phút",
                rating: "8.9",
                quality: "Full HD",
                poster: "https://phimimg.com/uploads/movies/20260829/doraemon-nobita-va-lau-dai-duoi-day-bien-phien-ban-moi-poster.webp",
            },
        ],
    },
];

export default function BoSuuTapPage() {
    useTitle("Bộ Sưu Tập & Vũ Trụ Điện Ảnh | OpenFlix");

    const [activeColId, setActiveColId] = useState(COLLECTIONS[0].id);
    const [sortMode, setSortMode] = useState("chronology"); // chronology | release
    const [savedCollections, setSavedCollections] = useState({});

    const activeCollection =
        COLLECTIONS.find((c) => c.id === activeColId) || COLLECTIONS[0];

    const sortedMovies = [...activeCollection.movies].sort((a, b) =>
        sortMode === "chronology"
            ? a.chronologyOrder - b.chronologyOrder
            : a.releaseOrder - b.releaseOrder
    );

    const toggleSaveCollection = (id) => {
        setSavedCollections((prev) => ({ ...prev, [id]: !prev[id] }));
    };

    return (
        <div className="min-h-[100dvh] bg-[#08090c] pt-24 pb-20">
            <div className="section-container space-y-8">
                {/* Page Header */}
                <div className="flex flex-col md:flex-row md:items-end justify-between gap-4 border-b border-white/10 pb-6" /* taste-skill-ignore: divider / tab-underline chrome */
>
                    <div>
                        <span className="text-xs font-semibold text-sky-400">
                            Tuyển Tập Chuyên Đề
                        </span>
                        <h1 className="text-2xl sm:text-3xl font-black text-white mt-1">
                            Vũ Trụ Điện Ảnh & Bộ Sưu Tập
                        </h1>
                        <p className="text-sm text-slate-400 mt-2 max-w-2xl leading-relaxed">
                            Trải nghiệm trọn vẹn các series phim bom tấn được sắp xếp khoa học theo dòng thời gian cốt truyện hoặc thứ tự công chiếu tại rạp.
                        </p>
                    </div>

                    <div className="flex items-center gap-3">
                        <Link
                            href="/loc-phim"
                            className="px-4 py-2.5 rounded-xl bg-[#121620] hover:bg-slate-800 text-white border border-white/10 text-xs font-semibold transition-all"
                        >
                            Khám phá kho phim
                        </Link>
                    </div>
                </div>

                {/* Collection Selector Tabs */}
                <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                    {COLLECTIONS.map((col) => {
                        const isSelected = col.id === activeCollection.id;
                        return (
                            <button
                                key={col.id}
                                type="button"
                                onClick={() => setActiveColId(col.id)}
                                className={`p-5 rounded-2xl text-left transition-all cursor-pointer border ${
                                    isSelected
                                        ? "bg-[#161e2e] border-sky-400 text-white shadow-lg shadow-sky-500/10" /* taste-skill-ignore: interactive overlay card */
                                        : "bg-[#121620] border-white/10 text-slate-300 hover:border-white/25"
                                }`}
                            >
                                <div className="flex items-center justify-between text-xs text-sky-400 font-bold mb-1.5">
                                    <span>{col.movies.length} Tác phẩm</span>
                                    <span>{col.totalRuntime}</span>
                                </div>
                                <h2 className="text-base font-bold text-white line-clamp-1">
                                    {col.title}
                                </h2>
                                <p className="text-xs text-slate-400 mt-1 line-clamp-2 leading-relaxed">
                                    {col.subtitle}
                                </p>
                            </button>
                        );
                    })}
                </div>

                {/* Active Collection Spotlight */}
                <div className="p-6 sm:p-8 rounded-2xl bg-[#121620] border border-white/10 space-y-6">
                    <div className="flex flex-col lg:flex-row lg:items-center justify-between gap-4 border-b border-white/10 pb-6" /* taste-skill-ignore: divider / tab-underline chrome */
>
                        <div className="space-y-2 max-w-2xl">
                            <div className="flex items-center gap-2 text-xs text-sky-400 font-semibold">
                                <span>Biên tập bởi: {activeCollection.curator}</span>
                                <span>•</span>
                                <span>Tổng thời lượng: {activeCollection.totalRuntime}</span>
                            </div>
                            <h3 className="text-xl sm:text-2xl font-black text-white">
                                {activeCollection.title}
                            </h3>
                            <p className="text-sm text-slate-300 leading-relaxed">
                                {activeCollection.description}
                            </p>
                        </div>

                        <div className="flex flex-wrap items-center gap-3">
                            <button
                                type="button"
                                onClick={() => toggleSaveCollection(activeCollection.id)}
                                className={`px-4 py-2.5 rounded-xl text-xs font-bold transition-all cursor-pointer border ${
                                    savedCollections[activeCollection.id]
                                        ? "bg-sky-500/15 border-sky-400 text-sky-400"
                                        : "bg-slate-900 border-white/10 text-white hover:border-white/30"
                                }`}
                            >
                                {savedCollections[activeCollection.id]
                                    ? "Đã lưu trọn bộ sưu tập"
                                    : "+ Lưu trọn bộ vào danh sách"}
                            </button>

                            <div className="flex items-center bg-slate-900 p-1 rounded-xl border border-white/10">
                                <button
                                    type="button"
                                    onClick={() => setSortMode("chronology")}
                                    className={`px-3 py-1.5 rounded-lg text-xs font-semibold cursor-pointer transition-all ${
                                        sortMode === "chronology"
                                            ? "bg-sky-500 text-slate-950 font-bold"
                                            : "text-slate-400 hover:text-white"
                                    }`}
                                >
                                    Dòng thời gian
                                </button>
                                <button
                                    type="button"
                                    onClick={() => setSortMode("release")}
                                    className={`px-3 py-1.5 rounded-lg text-xs font-semibold cursor-pointer transition-all ${
                                        sortMode === "release"
                                            ? "bg-sky-500 text-slate-950 font-bold"
                                            : "text-slate-400 hover:text-white"
                                    }`}
                                >
                                    Năm phát hành
                                </button>
                            </div>
                        </div>
                    </div>

                    {/* Movies Grid */}
                    <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
                        {sortedMovies.map((movie, idx) => (
                            <div
                                key={movie.id}
                                className="group rounded-2xl bg-[#08090c] border border-white/10 hover:border-sky-400/40 overflow-hidden transition-all flex flex-col justify-between"
                            >
                                <div>
                                    <div className="relative aspect-[2/3] w-full bg-slate-900 overflow-hidden">
                                        <Image
                                            src={movie.poster}
                                            alt={movie.name}
                                            fill
                                            sizes="(max-width: 768px) 50vw, 260px"
                                            className="object-cover group-hover:scale-105 transition-transform duration-300"
                                            unoptimized
                                        />
                                        <div className="absolute top-3 left-3 px-2.5 py-1 rounded-md bg-slate-950/90 text-sky-400 font-black text-xs border border-white/10">
                                            Phần #{idx + 1}
                                        </div>
                                        <div className="absolute top-3 right-3 px-2 py-0.5 rounded bg-sky-500 text-slate-950 font-bold text-xs">
                                            {movie.quality}
                                        </div>
                                    </div>

                                    <div className="p-4 space-y-1.5">
                                        <div className="flex items-center justify-between text-xs text-slate-400">
                                            <span>Năm {movie.year}</span>
                                            <span>{movie.duration}</span>
                                        </div>
                                        <h4 className="text-base font-bold text-white group-hover:text-sky-400 transition-colors line-clamp-1">
                                            {movie.name}
                                        </h4>
                                        <p className="text-xs text-slate-400 line-clamp-1">
                                            {movie.originName}
                                        </p>
                                    </div>
                                </div>

                                <div className="p-4 pt-0">
                                    <Link
                                        href={`/phim/${movie.slug}`}
                                        className="w-full py-2.5 px-4 rounded-xl bg-[#121620] hover:bg-sky-500 hover:text-slate-950 text-white text-xs font-bold flex items-center justify-center gap-2 transition-colors border border-white/10"
                                    >
                                        <svg className="w-4 h-4 fill-current" viewBox="0 0 24 24">
                                            <polygon points="5 3 19 12 5 21 5 3" />
                                        </svg>
                                        <span>Xem Phim Ngay</span>
                                    </Link>
                                </div>
                            </div>
                        ))}
                    </div>
                </div>
            </div>
        </div>
    );
}
