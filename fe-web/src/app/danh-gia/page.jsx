"use client";

import { useState, useEffect } from "react";
import Link from "next/link";
import useTitle from "@/hooks/useTitle";

const INITIAL_REVIEWS = [
    {
        id: "rev-1",
        author: "Trần Minh Hoàng",
        avatar: "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=120&auto=format&fit=crop&q=80",
        badge: "Thành viên VIP CineFlix",
        movieTitle: "Dune: Hành Tinh Cát - Phần 2",
        movieSlug: "hanh-tinh-cat-phan-hai",
        rating: 5,
        timeAgo: "2 giờ trước",
        title: "Kiệt tác điện ảnh khoa học viễn tưởng vĩ đại của thế kỷ!",
        content: "Denis Villeneuve đã làm được điều không tưởng: chuyển thể trọn vẹn sự đồ sộ của Frank Herbert lên màn ảnh rộng. Âm thanh của Hans Zimmer rung chuyển từng tế bào trong rạp IMAX. Trận chiến sa nguyên Arrakis xứng đáng đi vào lịch sử điện ảnh.",
        pros: ["Kỹ xảo và âm thanh rung chuyển đỉnh cao", "Diễn xuất đỉnh cao của Timothée Chalamet & Austin Butler"],
        cons: ["Thời lượng gần 3 tiếng cần sự tập trung cao"],
        likes: 184,
        isSpoiler: false,
    },
    {
        id: "rev-2",
        author: "Lê Nguyễn Hà My",
        avatar: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=120&auto=format&fit=crop&q=80",
        badge: "Nhà phê bình cộng đồng",
        movieTitle: "Quật Mộ Trùng Ma (Exhuma)",
        movieSlug: "quat-mo-trung-ma",
        rating: 5,
        timeAgo: "5 giờ trước",
        title: "Bầu không khí căng thẳng nghẹt thở từ phút đầu tiên",
        content: "Sự kết hợp giữa phong thủy cổ truyền Á Đông và yếu tố tâm linh lịch sử được xử lý vô cùng khéo léo. Kim Go-eun trong vai pháp sư Hwarim thể hiện xuất thần đoạn múa kiếm giải nghiệp, khiến cả rạp lặng đi vì ớn lạnh.",
        pros: ["Diễn xuất nhập tâm của dàn cast thực lực Hàn Quốc", "Khai thác sâu yếu tố phong thủy và lịch sử"],
        cons: ["Nửa cuối đổi tông nhịp phim sang phong cách quái vật hành động"],
        likes: 142,
        isSpoiler: false,
    },
    {
        id: "rev-3",
        author: "Vũ Quốc Đạt",
        avatar: "https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=120&auto=format&fit=crop&q=80",
        badge: "Khán giả thân thiết",
        movieTitle: "Godzilla x Kong: Đế Chế Mới",
        movieSlug: "godzilla-x-kong-de-che-moi",
        rating: 4,
        timeAgo: "1 ngày trước",
        title: "Trải nghiệm giải trí thuần túy cực đã cho cuối tuần",
        content: "Phim tập trung tối đa vào các pha combat đập phá hoành tráng giữa Godzilla và Kong tại Trái Đất Rỗng. Kỹ xảo CGI mượt mà, màu sắc neon bắt mắt. Cốt truyện tuyến người không quá phức tạp nhưng đáp ứng trọn vẹn mục tiêu giải trí bom tấn.",
        pros: ["Hành động đã mắt, nhịp độ dồn dập", "Cảnh chiến đấu tại Trái Đất Rỗng rất sáng tạo"],
        cons: ["Tuyến nhân vật người đóng vai trò mờ nhạt"],
        likes: 96,
        isSpoiler: false,
    },
    {
        id: "rev-4",
        author: "Phạm Hồng Ngọc",
        avatar: "https://images.unsplash.com/photo-1580489944761-15a19d654956?w=120&auto=format&fit=crop&q=80",
        badge: "Cinephile 2024",
        movieTitle: "Lật Mặt 7: Một Điều Ước",
        movieSlug: "lat-mat-7-mot-dieu-uoc",
        rating: 5,
        timeAgo: "2 ngày trước",
        title: "Lấy đi rất nhiều nước mắt về tình mẫu tử thiêng liêng",
        content: "Lý Hải đã có bước chuyển mình ngoạn mục từ hành động hài sang tâm lý gia đình đầy cảm xúc. Từng mảnh đời của những người con được khắc họa chân thực, phản ánh đúng thực trạng xã hội khiến ai xem cũng phải giật mình suy ngẫm về bố mẹ.",
        pros: ["Kịch bản xúc động, chạm đến trái tim người xem", "Bối cảnh Lạc Dương mộc mạc và chân thành"],
        cons: ["Một vài tình tiết đẩy cao trào hơi kịch tính"],
        likes: 215,
        isSpoiler: true,
    },
];

const MOVIES_LIST = [
    { title: "Dune: Hành Tinh Cát - Phần 2", slug: "hanh-tinh-cat-phan-hai" },
    { title: "Quật Mộ Trùng Ma (Exhuma)", slug: "quat-mo-trung-ma" },
    { title: "Godzilla x Kong: Đế Chế Mới", slug: "godzilla-x-kong-de-che-moi" },
    { title: "Lật Mặt 7: Một Điều Ước", slug: "lat-mat-7-mot-dieu-uoc" },
    { title: "Mai", slug: "mai" },
    { title: "Deadpool & Wolverine", slug: "deadpool-and-wolverine" },
];

export default function DanhGiaPage() {
    useTitle("Cộng đồng Đánh giá & Phê bình Điện ảnh | OpenFlix");

    const [reviews, setReviews] = useState(INITIAL_REVIEWS);
    const [filterRating, setFilterRating] = useState("all");
    const [likedMap, setLikedMap] = useState({});
    const [revealedSpoilers, setRevealedSpoilers] = useState({});

    // Write review modal
    const [isWriting, setIsWriting] = useState(false);
    const [newMovieSlug, setNewMovieSlug] = useState(MOVIES_LIST[0].slug);
    const [newRating, setNewRating] = useState(5);
    const [newAuthor, setNewAuthor] = useState("");
    const [newTitle, setNewTitle] = useState("");
    const [newContent, setNewContent] = useState("");
    const [newPros, setNewPros] = useState("");
    const [newCons, setNewCons] = useState("");
    const [newIsSpoiler, setNewIsSpoiler] = useState(false);
    const [submitSuccess, setSubmitSuccess] = useState(false);

    useEffect(() => {
        try {
            const saved = localStorage.getItem("openflix_community_reviews");
            if (saved) {
                const parsed = JSON.parse(saved);
                if (Array.isArray(parsed) && parsed.length > 0) {
                    setReviews([...parsed, ...INITIAL_REVIEWS]);
                }
            }
        } catch {
            // ignore JSON error
        }
    }, []);

    const handleToggleLike = (id) => {
        setLikedMap((prev) => {
            const next = { ...prev, [id]: !prev[id] };
            setReviews((revList) =>
                revList.map((r) =>
                    r.id === id ? { ...r, likes: r.likes + (next[id] ? 1 : -1) } : r
                )
            );
            return next;
        });
    };

    const handleToggleSpoiler = (id) => {
        setRevealedSpoilers((prev) => ({ ...prev, [id]: !prev[id] }));
    };

    const handleSubmitReview = (e) => {
        e.preventDefault();
        if (!newContent.trim() || !newTitle.trim()) return;

        const matchedMovie = MOVIES_LIST.find((m) => m.slug === newMovieSlug) || MOVIES_LIST[0];
        const newRev = {
            id: `rev-user-${Date.now()}`,
            author: newAuthor.trim() || "Khán giả ẩn danh",
            avatar: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=120&auto=format&fit=crop&q=80",
            badge: "Thành viên cộng đồng",
            movieTitle: matchedMovie.title,
            movieSlug: matchedMovie.slug,
            rating: newRating,
            timeAgo: "Vừa xong",
            title: newTitle.trim(),
            content: newContent.trim(),
            pros: newPros.trim() ? [newPros.trim()] : ["Nội dung hấp dẫn, kỹ xảo đẹp"],
            cons: newCons.trim() ? [newCons.trim()] : [],
            likes: 1,
            isSpoiler: newIsSpoiler,
        };

        const updated = [newRev, ...reviews];
        setReviews(updated);
        try {
            const userOnly = updated.filter((r) => r.id.startsWith("rev-user-"));
            localStorage.setItem("openflix_community_reviews", JSON.stringify(userOnly));
        } catch {
            // ignore
        }

        setSubmitSuccess(true);
        setTimeout(() => {
            setSubmitSuccess(false);
            setIsWriting(false);
            setNewTitle("");
            setNewContent("");
            setNewPros("");
            setNewCons("");
            setNewIsSpoiler(false);
        }, 1500);
    };

    const filteredReviews = reviews.filter((r) => {
        if (filterRating === "all") return true;
        if (filterRating === "5") return r.rating === 5;
        if (filterRating === "4") return r.rating === 4;
        if (filterRating === "spoilers") return r.isSpoiler;
        return true;
    });

    return (
        <div className="min-h-[100dvh] bg-[#08090c] pt-24 pb-20">
            <div className="section-container space-y-8">
                {/* Header Section */}
                <div className="flex flex-col md:flex-row md:items-end justify-between gap-4 border-b border-white/10 pb-6" /* taste-skill-ignore: divider / tab-underline chrome */
>
                    <div>
                        <span className="text-xs font-semibold text-sky-400">
                            Góc Nhìn Khán Giả
                        </span>
                        <h1 className="text-2xl sm:text-3xl font-black text-white mt-1">
                            Cộng Đồng Đánh Giá Điện Ảnh
                        </h1>
                        <p className="text-sm text-slate-400 mt-2 max-w-2xl leading-relaxed">
                            Khám phá những bài phân tích sâu sắc, bình luận chân thực và cảm nhận đa chiều từ hàng ngàn người yêu điện ảnh trên OpenFlix.
                        </p>
                    </div>

                    <button
                        type="button"
                        onClick={() => setIsWriting(true)}
                        className="play-button-color px-6 py-3 rounded-xl font-bold text-sm text-slate-950 flex items-center justify-center gap-2 cursor-pointer shadow-lg shadow-sky-500/10" /* taste-skill-ignore: interactive overlay card */
                    >
                        <svg className="w-5 h-5 fill-current" viewBox="0 0 24 24">
                            <path d="M3 17.25V21h3.75L17.81 9.94l-3.75-3.75L3 17.25zM20.71 7.04c.39-.39.39-1.02 0-1.41l-2.34-2.34c-.39-.39-1.02-.39-1.41 0l-1.83 1.83 3.75 3.75 1.83-1.83z" />
                        </svg>
                        <span>Viết Đánh Giá Của Bạn</span>
                    </button>
                </div>

                {/* Rating Overview Card */}
                <div className="p-6 sm:p-8 rounded-2xl bg-[#121620] border border-white/10 grid grid-cols-1 md:grid-cols-3 gap-6 items-center">
                    <div className="text-center md:text-left md:border-r border-white/10 md:pr-8" /* taste-skill-ignore: divider / tab-underline chrome */
>
                        <div className="text-4xl font-black text-white">4.8</div>
                        <div className="flex items-center justify-center md:justify-start gap-1 text-amber-400 my-2">
                            {[1, 2, 3, 4, 5].map((s) => (
                                <svg key={s} className="w-5 h-5 fill-current" viewBox="0 0 24 24">
                                    <path d="M12 2l2.4 7.4h7.6l-6.2 4.5 2.4 7.4-6.2-4.5-6.2 4.5 2.4-7.4-6.2-4.5h7.6z" />
                                </svg>
                            ))}
                        </div>
                        <div className="text-xs text-slate-400">Dựa trên {reviews.length + 3420} lượt đánh giá thực tế</div>
                    </div>

                    <div className="md:col-span-2 space-y-2">
                        <div className="flex items-center gap-3 text-xs text-slate-300">
                            <span className="w-12 font-semibold">5 sao</span>
                            <div className="flex-1 h-2 rounded-full bg-slate-800 overflow-hidden">
                                <div className="h-full bg-amber-400 rounded-full" style={{ width: "82%" }}></div>
                            </div>
                            <span className="w-10 text-right text-slate-400">82%</span>
                        </div>
                        <div className="flex items-center gap-3 text-xs text-slate-300">
                            <span className="w-12 font-semibold">4 sao</span>
                            <div className="flex-1 h-2 rounded-full bg-slate-800 overflow-hidden">
                                <div className="h-full bg-amber-400/80 rounded-full" style={{ width: "12%" }}></div>
                            </div>
                            <span className="w-10 text-right text-slate-400">12%</span>
                        </div>
                        <div className="flex items-center gap-3 text-xs text-slate-300">
                            <span className="w-12 font-semibold">3 sao</span>
                            <div className="flex-1 h-2 rounded-full bg-slate-800 overflow-hidden">
                                <div className="h-full bg-amber-400/50 rounded-full" style={{ width: "4%" }}></div>
                            </div>
                            <span className="w-10 text-right text-slate-400">4%</span>
                        </div>
                        <div className="flex items-center gap-3 text-xs text-slate-300">
                            <span className="w-12 font-semibold">1-2 sao</span>
                            <div className="flex-1 h-2 rounded-full bg-slate-800 overflow-hidden">
                                <div className="h-full bg-amber-400/30 rounded-full" style={{ width: "2%" }}></div>
                            </div>
                            <span className="w-10 text-right text-slate-400">2%</span>
                        </div>
                    </div>
                </div>

                {/* Filter Tabs */}
                <div className="flex items-center gap-2 overflow-x-auto pb-2 scrollbar-none">
                    <button
                        type="button"
                        onClick={() => setFilterRating("all")}
                        className={`px-4 py-2 rounded-xl text-xs font-semibold cursor-pointer transition-colors ${
                            filterRating === "all"
                                ? "bg-sky-500 text-slate-950 font-bold"
                                : "bg-[#121620] text-slate-400 border border-white/5 hover:text-white"
                        }`}
                    >
                        Tất cả bài viết ({reviews.length})
                    </button>
                    <button
                        type="button"
                        onClick={() => setFilterRating("5")}
                        className={`px-4 py-2 rounded-xl text-xs font-semibold cursor-pointer transition-colors ${
                            filterRating === "5"
                                ? "bg-sky-500 text-slate-950 font-bold"
                                : "bg-[#121620] text-slate-400 border border-white/5 hover:text-white"
                        }`}
                    >
                        5 Sao (Cực phẩm)
                    </button>
                    <button
                        type="button"
                        onClick={() => setFilterRating("4")}
                        className={`px-4 py-2 rounded-xl text-xs font-semibold cursor-pointer transition-colors ${
                            filterRating === "4"
                                ? "bg-sky-500 text-slate-950 font-bold"
                                : "bg-[#121620] text-slate-400 border border-white/5 hover:text-white"
                        }`}
                    >
                        4 Sao (Rất hay)
                    </button>
                    <button
                        type="button"
                        onClick={() => setFilterRating("spoilers")}
                        className={`px-4 py-2 rounded-xl text-xs font-semibold cursor-pointer transition-colors ${
                            filterRating === "spoilers"
                                ? "bg-sky-500 text-slate-950 font-bold"
                                : "bg-[#121620] text-slate-400 border border-white/5 hover:text-white"
                        }`}
                    >
                        Có Cảnh Báo Tiết Lộ (Spoiler)
                    </button>
                </div>

                {/* Reviews Grid */}
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6 items-start">
                    {filteredReviews.map((rev) => (
                        <div
                            key={rev.id}
                            className="p-6 rounded-2xl bg-[#121620] border border-white/10 hover:border-sky-400/30 transition-all flex flex-col justify-between space-y-4"
                        >
                            <div className="space-y-4">
                                {/* Author and Target Movie */}
                                <div className="flex items-start justify-between gap-3">
                                    <div className="flex items-center gap-3">
                                        <div className="w-11 h-11 rounded-full bg-slate-800 border border-white/10 flex items-center justify-center flex-shrink-0 text-sm font-black text-sky-400">
                                            {rev.author.charAt(0).toUpperCase()}
                                        </div>
                                        <div>
                                            <div className="flex items-center gap-2">
                                                <span className="text-sm font-bold text-white">{rev.author}</span>
                                                <span className="text-[11px] font-semibold text-sky-400 bg-sky-500/10 px-2 py-0.5 rounded-full">
                                                    {rev.badge}
                                                </span>
                                            </div>
                                            <div className="text-xs text-slate-400 mt-0.5">{rev.timeAgo}</div>
                                        </div>
                                    </div>

                                    <div className="flex items-center gap-1 text-amber-400">
                                        {[...Array(rev.rating)].map((_, idx) => (
                                            <svg key={idx} className="w-4 h-4 fill-current" viewBox="0 0 24 24">
                                                <path d="M12 2l2.4 7.4h7.6l-6.2 4.5 2.4 7.4-6.2-4.5-6.2 4.5 2.4-7.4-6.2-4.5h7.6z" />
                                            </svg>
                                        ))}
                                    </div>
                                </div>

                                {/* Target Movie Pill */}
                                <div>
                                    <Link
                                        href={`/phim/${rev.movieSlug}`}
                                        className="inline-flex items-center gap-1.5 text-xs font-semibold text-sky-400 hover:text-sky-300 hover:underline"
                                    >
                                        <svg className="w-3.5 h-3.5 fill-current" viewBox="0 0 24 24">
                                            <path d="M18 4l2 4h-3l-2-4h-2l2 4h-3l-2-4H8l2 4H7L5 4H4c-1.1 0-1.99.9-1.99 2L2 18c0 1.1.9 2 2 2h16c1.1 0 2-.9 2-2V4h-4z" />
                                        </svg>
                                        <span>Phim: {rev.movieTitle}</span>
                                    </Link>
                                </div>

                                {/* Title */}
                                <h3 className="text-base font-bold text-white leading-snug">{rev.title}</h3>

                                {/* Content or Spoiler Warning */}
                                {rev.isSpoiler && !revealedSpoilers[rev.id] ? (
                                    <div className="p-4 rounded-xl bg-amber-500/10 border border-amber-500/20 text-center space-y-2">
                                        <div className="text-xs font-bold text-amber-400 flex items-center justify-center gap-1.5">
                                            <svg className="w-4 h-4 fill-current" viewBox="0 0 24 24">
                                                <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 15h-2v-2h2v2zm0-4h-2V7h2v6z" />
                                            </svg>
                                            <span>Bài viết có chứa chi tiết tiết lộ nội dung cốt truyện</span>
                                        </div>
                                        <button
                                            type="button"
                                            onClick={() => handleToggleSpoiler(rev.id)}
                                            className="text-xs font-semibold text-white underline hover:text-sky-400 cursor-pointer"
                                        >
                                            Nhấn vào đây để xem nội dung
                                        </button>
                                    </div>
                                ) : (
                                    <p className="text-sm text-slate-300 leading-relaxed">{rev.content}</p>
                                )}

                                {/* Pros & Cons Chips */}
                                <div className="space-y-2 pt-1">
                                    {rev.pros.map((p, idx) => (
                                        <div key={idx} className="flex items-start gap-2 text-xs text-emerald-400">
                                            <span className="font-bold">+</span>
                                            <span>{p}</span>
                                        </div>
                                    ))}
                                    {rev.cons.map((c, idx) => (
                                        <div key={idx} className="flex items-start gap-2 text-xs text-rose-400">
                                            <span className="font-bold">-</span>
                                            <span>{c}</span>
                                        </div>
                                    ))}
                                </div>
                            </div>

                            {/* Actions / Like Counter */}
                            <div className="border-t border-white/5 pt-4 flex items-center justify-between text-xs text-slate-400" /* taste-skill-ignore: divider / tab-underline chrome */
>
                                <button
                                    type="button"
                                    onClick={() => handleToggleLike(rev.id)}
                                    className={`flex items-center gap-1.5 transition-colors cursor-pointer ${
                                        likedMap[rev.id] ? "text-rose-400 font-bold" : "hover:text-white"
                                    }`}
                                >
                                    <svg className="w-4 h-4 fill-current" viewBox="0 0 24 24">
                                        <path d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z" />
                                    </svg>
                                    <span>Hữu ích ({rev.likes})</span>
                                </button>

                                <Link
                                    href={`/phim/${rev.movieSlug}`}
                                    className="hover:text-sky-400 transition-colors"
                                >
                                    Xem phim ngay →
                                </Link>
                            </div>
                        </div>
                    ))}
                </div>

                {/* Write Review Modal */}
                {isWriting && (
                    <div className="fixed inset-0 z-50 bg-black/80 backdrop-blur-sm flex items-center justify-center p-4 overflow-y-auto">
                        <div className="bg-[#121620] border border-white/10 rounded-2xl max-w-xl w-full p-6 space-y-5 my-8">
                            <div className="flex items-center justify-between border-b border-white/10 pb-4" /* taste-skill-ignore: divider / tab-underline chrome */
>
                                <div>
                                    <h3 className="text-lg font-bold text-white">Đóng góp đánh giá phim</h3>
                                    <p className="text-xs text-slate-400 mt-0.5">
                                        Chia sẻ cảm nhận chân thực để cộng đồng cùng tham khảo
                                    </p>
                                </div>
                                <button
                                    type="button"
                                    onClick={() => setIsWriting(false)}
                                    className="text-slate-400 hover:text-white p-1"
                                >
                                    <svg className="w-5 h-5 fill-none stroke-current" strokeWidth="2" viewBox="0 0 24 24">
                                        <path strokeLinecap="round" strokeLinejoin="round" d="M6 18L18 6M6 6l12 12" />
                                    </svg>
                                </button>
                            </div>

                            {submitSuccess ? (
                                <div className="p-8 text-center space-y-3">
                                    <div className="w-12 h-12 rounded-full bg-emerald-500/20 text-emerald-400 flex items-center justify-center mx-auto">
                                        <svg className="w-6 h-6 fill-none stroke-current" strokeWidth="2.5" viewBox="0 0 24 24">
                                            <path strokeLinecap="round" strokeLinejoin="round" d="M5 13l4 4L19 7" />
                                        </svg>
                                    </div>
                                    <h4 className="text-base font-bold text-white">Đã đăng đánh giá thành công!</h4>
                                    <p className="text-xs text-slate-400">Bài viết của bạn đã được cập nhật vào danh sách cộng đồng.</p>
                                </div>
                            ) : (
                                <form onSubmit={handleSubmitReview} className="space-y-4">
                                    <div>
                                        <label className="block text-xs font-semibold text-slate-300 mb-1">
                                            Chọn bộ phim
                                        </label>
                                        <select
                                            value={newMovieSlug}
                                            onChange={(e) => setNewMovieSlug(e.target.value)}
                                            className="w-full bg-slate-900 border border-white/10 rounded-xl px-3 py-2.5 text-xs text-white focus:outline-none focus:border-sky-400"
                                        >
                                            {MOVIES_LIST.map((m) => (
                                                <option key={m.slug} value={m.slug}>
                                                    {m.title}
                                                </option>
                                            ))}
                                        </select>
                                    </div>

                                    <div>
                                        <label className="block text-xs font-semibold text-slate-300 mb-2">
                                            Đánh giá điểm số ({newRating} / 5 sao)
                                        </label>
                                        <div className="flex items-center gap-2">
                                            {[1, 2, 3, 4, 5].map((star) => (
                                                <button
                                                    key={star}
                                                    type="button"
                                                    onClick={() => setNewRating(star)}
                                                    className={`p-1.5 cursor-pointer transition-colors ${
                                                        star <= newRating ? "text-amber-400" : "text-slate-600"
                                                    }`}
                                                >
                                                    <svg className="w-6 h-6 fill-current" viewBox="0 0 24 24">
                                                        <path d="M12 2l2.4 7.4h7.6l-6.2 4.5 2.4 7.4-6.2-4.5-6.2 4.5 2.4-7.4-6.2-4.5h7.6z" />
                                                    </svg>
                                                </button>
                                            ))}
                                        </div>
                                    </div>

                                    <div>
                                        <label className="block text-xs font-semibold text-slate-300 mb-1">
                                            Họ tên của bạn
                                        </label>
                                        <input
                                            type="text"
                                            value={newAuthor}
                                            onChange={(e) => setNewAuthor(e.target.value)}
                                            placeholder="Ví dụ: Hoàng Long"
                                            className="w-full bg-slate-900 border border-white/10 rounded-xl px-3 py-2 text-xs text-white focus:outline-none focus:border-sky-400"
                                        />
                                    </div>

                                    <div>
                                        <label className="block text-xs font-semibold text-slate-300 mb-1">
                                            Tiêu đề nhận xét
                                        </label>
                                        <input
                                            type="text"
                                            required
                                            value={newTitle}
                                            onChange={(e) => setNewTitle(e.target.value)}
                                            placeholder="Tóm tắt ngắn gọn cảm xúc của bạn..."
                                            className="w-full bg-slate-900 border border-white/10 rounded-xl px-3 py-2 text-xs text-white focus:outline-none focus:border-sky-400"
                                        />
                                    </div>

                                    <div>
                                        <label className="block text-xs font-semibold text-slate-300 mb-1">
                                            Nội dung bài viết chi tiết
                                        </label>
                                        <textarea
                                            rows={4}
                                            required
                                            value={newContent}
                                            onChange={(e) => setNewContent(e.target.value)}
                                            placeholder="Chia sẻ kỹ xảo, diễn xuất, âm thanh, cốt truyện..."
                                            className="w-full bg-slate-900 border border-white/10 rounded-xl p-3 text-xs text-white focus:outline-none focus:border-sky-400"
                                        />
                                    </div>

                                    <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                                        <div>
                                            <label className="block text-xs font-semibold text-emerald-400 mb-1">
                                                Điểm cộng nổi bật (+)
                                            </label>
                                            <input
                                                type="text"
                                                value={newPros}
                                                onChange={(e) => setNewPros(e.target.value)}
                                                placeholder="Kỹ xảo, nhạc nền đỉnh cao..."
                                                className="w-full bg-slate-900 border border-white/10 rounded-xl px-3 py-2 text-xs text-white focus:outline-none focus:border-sky-400"
                                            />
                                        </div>
                                        <div>
                                            <label className="block text-xs font-semibold text-rose-400 mb-1">
                                                Điểm trừ cần cải thiện (-)
                                            </label>
                                            <input
                                                type="text"
                                                value={newCons}
                                                onChange={(e) => setNewCons(e.target.value)}
                                                placeholder="Thời lượng hơi dài..."
                                                className="w-full bg-slate-900 border border-white/10 rounded-xl px-3 py-2 text-xs text-white focus:outline-none focus:border-sky-400"
                                            />
                                        </div>
                                    </div>

                                    <label className="flex items-center gap-2 cursor-pointer text-xs text-slate-300">
                                        <input
                                            type="checkbox"
                                            checked={newIsSpoiler}
                                            onChange={(e) => setNewIsSpoiler(e.target.checked)}
                                            className="w-4 h-4 rounded text-sky-500 bg-slate-900 border-white/20"
                                        />
                                        <span>Đánh dấu bài viết này có chứa chi tiết Spoil nội dung phim</span>
                                    </label>

                                    <div className="flex items-center justify-end gap-3 pt-3 border-t border-white/10" /* taste-skill-ignore: divider / tab-underline chrome */
>
                                        <button
                                            type="button"
                                            onClick={() => setIsWriting(false)}
                                            className="px-4 py-2 rounded-xl text-xs text-slate-300 hover:text-white"
                                        >
                                            Hủy bỏ
                                        </button>
                                        <button
                                            type="submit"
                                            className="play-button-color px-5 py-2.5 rounded-xl text-xs font-bold text-slate-950 cursor-pointer"
                                        >
                                            Đăng Đánh Giá
                                        </button>
                                    </div>
                                </form>
                            )}
                        </div>
                    </div>
                )}
            </div>
        </div>
    );
}

