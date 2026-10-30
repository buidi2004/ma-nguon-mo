'use client'

import { useState } from "react";
import Link from "next/link";
import Image from "next/image";
import useTitle from "@/hooks/useTitle";

const ARTICLES_MAP = {
    "dune-part-two-dinh-cao-sci-fi-the-ky": {
        title: "Đánh giá Dune: Phần 2 — Kỳ quan nghe nhìn và kiệt tác điện ảnh khoa học viễn tưởng",
        categoryLabel: "Bình luận phim",
        date: "28/10/2026",
        readTime: "6 phút đọc",
        author: "Minh Quân",
        authorRole: "Nhà phê bình điện ảnh",
        image: "https://phimimg.com/uploads/movies/20261030/duoi-day-ho-poster.webp",
        likes: 842,
        relatedMovieTitle: "Dune: Hành Tinh Cát - Phần 2",
        relatedMovieSlug: "dune-part-two",
        content: [
            {
                heading: "Một trải nghiệm điện ảnh trọn vẹn tại rạp IMAX",
                text: "Không ngoa khi nói rằng Denis Villeneuve đang bước vào hàng ngũ những đạo diễn vĩ đại nhất của thể loại Sci-Fi hiện đại. Với Dune: Phần 2, mọi sự ngập ngừng và chuẩn bị ở phần đầu tiên đã được đền đáp bằng những trường đoạn chiến tranh sa mạc nghẹt thở, những con sâu cát Shai-Hulud khổng lồ xuất hiện hùng vĩ đến rợn người.",
            },
            {
                heading: "Diễn xuất thăng hoa của Timothée Chalamet và Zendaya",
                text: "Timothée Chalamet đã có màn lột xác đáng kinh ngạc từ một chàng quý tộc trẻ Paul Atreides ngây thơ trở thành Đấng cứu thế Muad'Dib đầy uy quyền và toan tính chính trị. Ánh mắt biến chuyển từ run rẩy sang sắc lạnh của Chalamet đã khắc họa trọn vẹn bi kịch của một thủ lĩnh bị định mệnh giam cầm.",
            },
            {
                heading: "Âm thanh và hình ảnh xứng tầm giải Oscar",
                text: "Bàn tay của nhà soạn nhạc Hans Zimmer tiếp tục tạo nên một bầu không khí huyền bí, ma mị với những tiếng gầm rú kim loại và hợp xướng sa mạc. Từng khung hình với tông màu cát vàng cháy bỏng của nhà quay phim Greig Fraser đều xứng đáng là một bức tranh nghệ thuật đương đại.",
            },
        ],
    },
    "godzilla-x-kong-cuoc-chien-hai-quai-thu": {
        title: "Godzilla x Kong: Khi hai đại Titan bắt tay chống lại hiểm họa từ lòng Trái Đất",
        categoryLabel: "Tin điện ảnh",
        date: "26/10/2026",
        readTime: "4 phút đọc",
        author: "Thanh Hà",
        authorRole: "Biên tập viên",
        image: "https://phimimg.com/uploads/movies/20261028/shaun-the-sheep-quai-la-ghe-nha-poster.webp",
        likes: 512,
        relatedMovieTitle: "Godzilla x Kong: Đế Chế Mới",
        relatedMovieSlug: "the-new-empire",
        content: [
            {
                heading: "Màn kết hợp đỉnh cao của vũ trụ MonsterVerse",
                text: "Bộ phim chiêu đãi khán giả những trận đánh mãn nhãn liên hồi. Kong được trang bị găng tay trợ lực B.E.A.S.T và Godzilla tiến hóa với năng lượng hạt nhân hồng tạo nên bộ đôi càn quét mọi hiểm họa từ thế giới Trái Đất rỗng.",
            },
            {
                heading: "Hình ảnh kỹ xảo CGI xuất sắc",
                text: "Từng chuyển động của các Titan, biểu cảm trên khuôn mặt của Kong và chú khỉ con Suko đều được xử lý công phu, đem đến cảm xúc chân thực và sự hào hứng tột độ cho cả trẻ em lẫn người lớn.",
            },
        ],
    },
};

export default function ArticleDetailPage({ params }) {
    const slug = params?.slug || "dune-part-two-dinh-cao-sci-fi-the-ky";
    const article = ARTICLES_MAP[slug] || ARTICLES_MAP["dune-part-two-dinh-cao-sci-fi-the-ky"];

    useTitle(`${article.title} - OpenFlix`);

    const [likes, setLikes] = useState(article.likes);
    const [isLiked, setIsLiked] = useState(false);

    const toggleLike = () => {
        if (isLiked) {
            setLikes(likes - 1);
            setIsLiked(false);
        } else {
            setLikes(likes + 1);
            setIsLiked(true);
        }
    };

    return (
        <div className="page-container-0topside">
            <div className="section-container max-w-4xl mx-auto space-y-8">
                {/* Back button & Breadcrumb */}
                <div className="flex items-center gap-2 text-xs text-slate-400">
                    <Link href="/tin-tuc" className="hover:text-sky-400 transition-colors flex items-center gap-1">
                        ← Quay lại Tin tức
                    </Link>
                    <span>/</span>
                    <span className="text-slate-300">{article.categoryLabel}</span>
                </div>

                {/* Article Header */}
                <div className="space-y-4">
                    <span className="px-3 py-1 rounded-md text-xs font-bold bg-sky-500/10 text-sky-400 border border-sky-400/20">
                        {article.categoryLabel}
                    </span>
                    <h1 className="text-2xl sm:text-3xl lg:text-4xl font-extrabold text-white leading-tight">
                        {article.title}
                    </h1>

                    <div className="flex flex-wrap items-center justify-between gap-4 py-4 border-y border-white/10 text-xs text-slate-400" /* taste-skill-ignore: divider / tab-underline chrome */
>
                        <div className="flex items-center gap-3">
                            <div className="w-10 h-10 rounded-full bg-slate-800 border border-white/10 flex items-center justify-center font-bold text-sky-400">
                                {article.author[0]}
                            </div>
                            <div>
                                <p className="font-semibold text-white">{article.author}</p>
                                <p className="text-[11px] text-slate-400">{article.authorRole} • {article.date}</p>
                            </div>
                        </div>

                        <div className="flex items-center gap-3">
                            <span className="text-slate-400">{article.readTime}</span>
                            <button
                                type="button"
                                onClick={toggleLike}
                                className={`px-3 py-1.5 rounded-lg border text-xs font-semibold flex items-center gap-1.5 transition-colors cursor-pointer ${
                                    isLiked
                                        ? "bg-rose-500/20 text-rose-400 border-rose-500/30"
                                        : "bg-white/5 text-slate-300 border-white/10 hover:text-rose-400"
                                }`}
                            >
                                <svg className="w-3.5 h-3.5 fill-current" viewBox="0 0 24 24"><path d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z"/></svg>
                                <span>{likes}</span>
                            </button>
                        </div>
                    </div>
                </div>

                {/* Hero Banner */}
                <div className="aspect-video relative rounded-2xl overflow-hidden bg-slate-900 border border-white/10">
                    <Image
                        src={article.image}
                        alt={article.title}
                        fill
                        priority
                        sizes="(max-width: 1024px) 100vw, 850px"
                        className="object-cover"
                        unoptimized
                    />
                </div>

                {/* Article Prose Content */}
                <div className="space-y-6 text-slate-200 leading-relaxed text-sm sm:text-base">
                    {article.content.map((sec, i) => (
                        <div key={i} className="space-y-3">
                            <h2 className="text-lg sm:text-xl font-bold text-white pt-2">{sec.heading}</h2>
                            <p className="text-slate-300 leading-relaxed">{sec.text}</p>
                        </div>
                    ))}
                </div>

                {/* Related Movie Banner Call to Action */}
                <div className="p-6 rounded-2xl bg-[#121620] border border-white/10 flex flex-col sm:flex-row items-center justify-between gap-4">
                    <div>
                        <span className="text-xs text-sky-400 font-semibold">Phim liên quan đến bài viết</span>
                        <h3 className="text-lg font-bold text-white mt-1">{article.relatedMovieTitle}</h3>
                        <p className="text-xs text-slate-400 mt-0.5">Thưởng thức trọn vẹn tác phẩm với chất lượng Full HD 4K trên OpenFlix</p>
                    </div>

                    <div className="flex items-center gap-3">
                        <Link
                            href="/rap-chieu-phim"
                            className="px-4 py-2.5 rounded-lg bg-white/5 hover:bg-white/10 text-slate-200 text-xs font-semibold border border-white/10 transition-colors"
                        >
                            Xem suất chiếu rạp
                        </Link>
                        <Link
                            href={`/xem-phim/${article.relatedMovieSlug}`}
                            className="px-5 py-2.5 rounded-lg bg-sky-500 hover:bg-sky-400 text-white text-xs font-bold transition-all shadow-lg shadow-sky-500/20" /* taste-skill-ignore: interactive overlay card */
                        >
                            Xem phim ngay
                        </Link>
                    </div>
                </div>
            </div>
        </div>
    );
}
