'use client'

import { useState } from "react";
import Link from "next/link";
import Image from "next/image";
import useTitle from "@/hooks/useTitle";

export const ARTICLES = [
    {
        id: "art-1",
        slug: "dune-part-two-dinh-cao-sci-fi-the-ky",
        title: "Đánh giá Dune: Phần 2 — Kỳ quan nghe nhìn và kiệt tác điện ảnh khoa học viễn tưởng",
        category: "review",
        categoryLabel: "Bình luận phim",
        excerpt: "Đạo diễn Denis Villeneuve đã đưa người xem bước vào một bữa tiệc thị giác hoành tráng tại hành tinh cát Arrakis với âm thanh rền vang rung chuyển khán phòng IMAX.",
        image: "https://phimimg.com/uploads/movies/20261030/duoi-day-ho-poster.webp",
        author: "Minh Quân",
        authorRole: "Nhà phê bình điện ảnh",
        date: "28/10/2026",
        readTime: "6 phút đọc",
        views: 12450,
        likes: 842,
        relatedMovieSlug: "dune-part-two",
    },
    {
        id: "art-2",
        slug: "godzilla-x-kong-cuoc-chien-hai-quai-thu",
        title: "Godzilla x Kong: Khi hai đại Titan bắt tay chống lại hiểm họa từ lòng Trái Đất",
        category: "news",
        categoryLabel: "Tin điện ảnh",
        excerpt: "Cú bắt tay bùng nổ giữa Godzilla nguyên tử và Kong găng tay cơ khí mang đến những màn combat long trời lở đất làm mãn nhãn tín đồ bom tấn hành động.",
        image: "https://phimimg.com/uploads/movies/20261028/shaun-the-sheep-quai-la-ghe-nha-poster.webp",
        author: "Thanh Hà",
        authorRole: "Biên tập viên",
        date: "26/10/2026",
        readTime: "4 phút đọc",
        views: 8920,
        likes: 512,
        relatedMovieSlug: "the-new-empire",
    },
    {
        id: "art-3",
        slug: "kung-fu-panda-4-hanh-trinh-truyen-thua",
        title: "Kung Fu Panda 4: Po trở thành Thủ lĩnh Tinh thần và bài học trưởng thành đầy cảm xúc",
        category: "review",
        categoryLabel: "Bình luận phim",
        excerpt: "Sau hơn một thập kỷ, chú gấu trúc béo tốt vụng về ngày nào nay đã sẵn sàng nhường lại danh hiệu Thần Long Đại Hiệp cho thế hệ kế tiếp trong tiếng cười sảng khoái.",
        image: "https://phimimg.com/uploads/movies/20261026/quy-bat-hon-poster.webp",
        author: "Đức Trọng",
        authorRole: "Reviewer",
        date: "22/10/2026",
        readTime: "5 phút đọc",
        views: 6730,
        likes: 390,
        relatedMovieSlug: "kung-fu-panda-4",
    },
    {
        id: "art-4",
        slug: "doanh-thu-phong-ve-viet-nam-thang-10-2026",
        title: "Bảng xếp hạng phòng vé Việt: Phim nội địa bứt phá với kỷ lục phòng vé mới",
        category: "boxoffice",
        categoryLabel: "Phòng vé",
        excerpt: "Thị trường rạp chiếu phim trong nước chứng kiến sự trở lại ngoạn mục với mức tăng trưởng 35% doanh thu vé bán ra nhờ các dự án kinh dị và tâm lý chất lượng.",
        image: "https://phimimg.com/uploads/movies/20260829/doraemon-nobita-va-lau-dai-duoi-day-bien-phien-ban-moi-poster.webp",
        author: "Hoàng Yến",
        authorRole: "Phân tích số liệu",
        date: "20/10/2026",
        readTime: "7 phút đọc",
        views: 15300,
        likes: 920,
        relatedMovieSlug: "mai",
    },
];

export default function CinemaNewsPage() {
    useTitle("Tin tức điện ảnh & Đánh giá phim - OpenFlix");

    const [activeCategory, setActiveCategory] = useState("all");
    const [searchQuery, setSearchQuery] = useState("");

    const CATEGORIES = [
        { id: "all", label: "Tất cả bài viết" },
        { id: "review", label: "Bình luận phim" },
        { id: "news", label: "Tin điện ảnh" },
        { id: "boxoffice", label: "Phòng vé" },
    ];

    const filtered = ARTICLES.filter((art) => {
        const matchCat = activeCategory === "all" || art.category === activeCategory;
        const matchSearch =
            !searchQuery ||
            art.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
            art.excerpt.toLowerCase().includes(searchQuery.toLowerCase());
        return matchCat && matchSearch;
    });

    return (
        <div className="page-container-0topside">
            <div className="section-container space-y-8">
                {/* Header */}
                <div className="flex flex-col md:flex-row md:items-end justify-between gap-4 border-b border-white/10 pb-6" /* taste-skill-ignore: divider / tab-underline chrome */
>
                    <div>
                        <div className="flex items-center gap-3">
                            <span className="w-10 h-10 rounded-xl bg-sky-500/10 border border-sky-400/30 flex items-center justify-center text-sky-400">
                                <svg className="w-5 h-5 fill-none stroke-current" strokeWidth="2" viewBox="0 0 24 24">
                                    <path strokeLinecap="round" strokeLinejoin="round" d="M19 20H5a2 2 0 01-2-2V6a2 2 0 012-2h10a2 2 0 012 2v1m2 13a2 2 0 01-2-2V7m2 13a2 2 0 002-2V9a2 2 0 00-2-2h-2m-4-3H9M7 16h6M7 8h6v4H7V8z" />
                                </svg>
                            </span>
                            <div>
                                <h1 className="section-title-no-up">Tin Điện Ảnh & Review</h1>
                                <p className="text-xs text-sky-400 font-semibold">Góc nhìn chuyên sâu từ các nhà phê bình</p>
                            </div>
                        </div>
                        <p className="text-sm text-slate-400 mt-2">
                            Cập nhật tin tức rạp chiếu, bài phân tích chuyên sâu, hậu trường bom tấn và diễn biến doanh thu phòng vé nóng nhất.
                        </p>
                    </div>

                    {/* Search box */}
                    <div className="relative w-full md:w-72">
                        <input
                            type="text"
                            placeholder="Tìm kiếm bài viết, phim..."
                            value={searchQuery}
                            onChange={(e) => setSearchQuery(e.target.value)}
                            className="w-full bg-[#121620] border border-white/10 rounded-xl px-4 py-2 text-xs text-white placeholder-slate-500 focus:outline-none focus:border-sky-400"
                        />
                    </div>
                </div>

                {/* Categories */}
                <div className="flex items-center gap-2 overflow-x-auto pb-2 scrollbar-none">
                    {CATEGORIES.map((cat) => (
                        <button
                            key={cat.id}
                            type="button"
                            onClick={() => setActiveCategory(cat.id)}
                            className={`px-4 py-2 rounded-xl text-xs font-semibold whitespace-nowrap transition-all cursor-pointer ${
                                activeCategory === cat.id
                                    ? "bg-sky-500 text-white shadow-lg shadow-sky-500/20" /* taste-skill-ignore: interactive overlay card */
                                    : "bg-[#121620] text-slate-400 border border-white/10 hover:text-white"
                            }`}
                        >
                            {cat.label}
                        </button>
                    ))}
                </div>

                {/* Hero Featured Article (First item if exists) */}
                {filtered.length > 0 && (
                    <Link
                        href={`/tin-tuc/${filtered[0].slug}`}
                        className="group block p-6 rounded-2xl bg-[#121620] border border-white/10 hover:border-sky-400/50 transition-all overflow-hidden"
                    >
                        <div className="grid grid-cols-1 lg:grid-cols-12 gap-6 items-center">
                            <div className="lg:col-span-7 aspect-video relative rounded-xl overflow-hidden bg-slate-900">
                                <Image
                                    src={filtered[0].image}
                                    alt={filtered[0].title}
                                    fill
                                    sizes="(max-width: 1024px) 100vw, 60vw"
                                    className="object-cover group-hover:scale-105 transition-transform duration-500"
                                    unoptimized
                                />
                                <span className="absolute top-3 left-3 px-3 py-1 rounded-md text-xs font-bold bg-sky-500 text-white shadow-md" /* taste-skill-ignore: Netflix card overlay (scrim shadow), kept intentionally */
>
                                    {filtered[0].categoryLabel}
                                </span>
                            </div>

                            <div className="lg:col-span-5 space-y-4">
                                <div className="flex items-center gap-3 text-xs text-slate-400">
                                    <span>Bởi {filtered[0].author}</span>
                                    <span>•</span>
                                    <span>{filtered[0].date}</span>
                                    <span>•</span>
                                    <span className="text-sky-400 font-medium">{filtered[0].readTime}</span>
                                </div>

                                <h2 className="text-xl sm:text-2xl font-bold text-white group-hover:text-sky-400 transition-colors leading-snug">
                                    {filtered[0].title}
                                </h2>

                                <p className="text-sm text-slate-300 line-clamp-3 leading-relaxed">
                                    {filtered[0].excerpt}
                                </p>

                                <div className="flex items-center gap-4 pt-2 text-xs text-slate-400">
                                    <span className="flex items-center gap-1.5">
                                        <svg className="w-4 h-4 fill-none stroke-current" strokeWidth="2" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/><path strokeLinecap="round" strokeLinejoin="round" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"/></svg>
                                        {filtered[0].views.toLocaleString("vi-VN")} lượt xem
                                    </span>
                                    <span className="flex items-center gap-1.5 text-rose-400">
                                        <svg className="w-4 h-4 fill-current" viewBox="0 0 24 24"><path d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z"/></svg>
                                        {filtered[0].likes}
                                    </span>
                                </div>
                            </div>
                        </div>
                    </Link>
                )}

                {/* Article Grid */}
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                    {filtered.slice(1).map((art) => (
                        <Link
                            key={art.id}
                            href={`/tin-tuc/${art.slug}`}
                            className="group flex flex-col rounded-2xl bg-[#121620] border border-white/10 hover:border-sky-400/40 transition-all overflow-hidden"
                        >
                            <div className="aspect-video relative overflow-hidden bg-slate-900">
                                <Image
                                    src={art.image}
                                    alt={art.title}
                                    fill
                                    sizes="(max-width: 768px) 100vw, 33vw"
                                    className="object-cover group-hover:scale-105 transition-transform duration-300"
                                    unoptimized
                                />
                                <span className="absolute top-2.5 left-2.5 px-2 py-0.5 rounded text-[11px] font-bold bg-slate-950/80 text-sky-400 border border-sky-400/20 backdrop-blur-sm">
                                    {art.categoryLabel}
                                </span>
                            </div>

                            <div className="p-5 flex-1 flex flex-col justify-between space-y-3">
                                <div className="space-y-2">
                                    <div className="flex items-center gap-2 text-[11px] text-slate-400">
                                        <span>{art.date}</span>
                                        <span>•</span>
                                        <span>{art.readTime}</span>
                                    </div>
                                    <h3 className="text-base font-bold text-white group-hover:text-sky-400 transition-colors line-clamp-2 leading-snug">
                                        {art.title}
                                    </h3>
                                    <p className="text-xs text-slate-400 line-clamp-2 leading-relaxed">
                                        {art.excerpt}
                                    </p>
                                </div>

                                <div className="pt-3 border-t border-white/5 flex items-center justify-between text-xs text-slate-400" /* taste-skill-ignore: divider / tab-underline chrome */
>
                                    <span className="font-medium text-slate-300 truncate">{art.author}</span>
                                    <span className="text-sky-400 font-semibold group-hover:translate-x-0.5 transition-transform inline-flex items-center gap-1">
                                        Đọc tiếp →
                                    </span>
                                </div>
                            </div>
                        </Link>
                    ))}
                </div>

                {filtered.length === 0 && (
                    <div className="p-12 text-center rounded-2xl bg-[#121620] border border-white/10">
                        <p className="text-slate-400 text-sm">Không tìm thấy bài viết nào phù hợp với từ khóa của bạn.</p>
                    </div>
                )}
            </div>
        </div>
    );
}
