"use client";

import { useState } from "react";
import Link from "next/link";
import useTitle from "@/hooks/useTitle";

const ARTISTS = [
    {
        id: "art-1",
        name: "Timothée Chalamet",
        role: "Diễn viên chính",
        nationality: "Mỹ / Pháp",
        awards: "Đề cử Oscar, 3 đề cử Quả Cầu Vàng",
        filmsCount: 24,
        bio: "Ngôi sao trẻ tài năng bậc nhất thế hệ mới tại Hollywood, nổi tiếng toàn cầu qua vai Paul Atreides trong sử thi Dune và Wonka.",
        notableWorks: ["Dune: Hành Tinh Cát", "Wonka", "Call Me by Your Name"],
    },
    {
        id: "art-2",
        name: "Kim Go-eun",
        role: "Diễn viên chính",
        nationality: "Hàn Quốc",
        awards: "Giải Baeksang Nữ diễn viên chính xuất sắc nhất",
        filmsCount: 19,
        bio: "Nữ diễn viên thực lực hàng đầu điện ảnh Hàn Quốc với khả năng biến hóa đa dạng từ tâm lý lãng mạn đến kinh dị tâm linh huyền bí.",
        notableWorks: ["Quật Mộ Trùng Ma (Exhuma)", "Goblin", "Little Women"],
    },
    {
        id: "art-3",
        name: "Denis Villeneuve",
        role: "Đạo diễn",
        nationality: "Canada",
        awards: "Đề cử Oscar Đạo diễn xuất sắc, Giải BAFTA",
        filmsCount: 14,
        bio: "Bậc thầy dòng phim khoa học viễn tưởng đương đại với ngôn ngữ hình ảnh vĩ mô và chiều sâu triết lý độc bản.",
        notableWorks: ["Dune: Part Two", "Blade Runner 2049", "Arrival"],
    },
    {
        id: "art-4",
        name: "Choi Min-sik",
        role: "Diễn viên chính",
        nationality: "Hàn Quốc",
        awards: "Giải Chuông Vàng, Giải Điện ảnh Rồng Xanh",
        filmsCount: 38,
        bio: "Cây đại thụ của nền điện ảnh Hàn Quốc, người góp phần đưa làn sóng điện ảnh xứ Kim Chi vươn tầm thế giới.",
        notableWorks: ["Quật Mộ Trùng Ma (Exhuma)", "Oldboy", "The Admiral"],
    },
    {
        id: "art-5",
        name: "Lý Hải",
        role: "Đạo diễn",
        nationality: "Việt Nam",
        awards: "Đạo diễn loạt phim thương mại ăn khách nhất Việt Nam",
        filmsCount: 12,
        bio: "Nhà làm phim tâm huyết đứng sau thương hiệu điện ảnh Lật Mặt, gắn liền với những câu chuyện gia đình và hành động gần gũi với khán giả Việt.",
        notableWorks: ["Lật Mặt 7: Một Điều Ước", "Lật Mặt 6: Tấm Vé Định Mệnh"],
    },
    {
        id: "art-6",
        name: "Trấn Thành",
        role: "Đạo diễn",
        nationality: "Việt Nam",
        awards: "Giải Ngôi Sao Xanh, Cánh Diều Vàng",
        filmsCount: 10,
        bio: "Đạo diễn kiêm diễn viên sở hữu nhiều tác phẩm dẫn đầu doanh thu phòng vé Việt Nam với phong cách khai thác tâm lý xã hội sâu sắc.",
        notableWorks: ["Mai", "Nhà Bà Nữ", "Bố Già"],
    },
    {
        id: "art-7",
        name: "Christopher Nolan",
        role: "Đạo diễn",
        nationality: "Anh / Mỹ",
        awards: "2 Giải Oscar, Giải Quả Cầu Vàng & BAFTA",
        filmsCount: 15,
        bio: "Đạo diễn thiên tài đứng sau những tác phẩm xoắn não với cấu trúc thời gian phi tuyến tính và kỹ xảo thực tế chuẩn IMAX 70mm.",
        notableWorks: ["Oppenheimer", "Interstellar", "Inception"],
    },
    {
        id: "art-8",
        name: "Phương Anh Đào",
        role: "Diễn viên chính",
        nationality: "Việt Nam",
        awards: "Nữ diễn viên chính xuất sắc LHP Quốc tế Hà Nội",
        filmsCount: 14,
        bio: "Nàng thơ thực lực của màn ảnh Việt, ghi dấu ấn sâu đậm với lối diễn xuất nội tâm tinh tế và giàu cảm xúc.",
        notableWorks: ["Mai", "Tro Tàn Rực Rỡ", "Chàng Vợ Của Em"],
    },
];

export default function DienVienDirectoryPage() {
    useTitle("Danh Bạ Diễn Viên & Đạo Diễn Điện Ảnh | OpenFlix");

    const [roleFilter, setRoleFilter] = useState("all");
    const [searchQuery, setSearchQuery] = useState("");

    const filtered = ARTISTS.filter((a) => {
        const matchesRole =
            roleFilter === "all" ||
            (roleFilter === "actor" && a.role.includes("Diễn viên")) ||
            (roleFilter === "director" && a.role.includes("Đạo diễn"));
        const matchesQuery =
            !searchQuery.trim() ||
            a.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
            a.notableWorks.some((w) => w.toLowerCase().includes(searchQuery.toLowerCase()));
        return matchesRole && matchesQuery;
    });

    return (
        <div className="min-h-[100dvh] bg-[#08090c] pt-24 pb-20">
            <div className="section-container space-y-8">
                {/* Header */}
                <div className="flex flex-col md:flex-row md:items-end justify-between gap-4 border-b border-white/10 pb-6" /* taste-skill-ignore: divider / tab-underline chrome */
>
                    <div>
                        <span className="text-xs font-semibold text-sky-400">
                            Hồ Sơ Nghệ Sĩ
                        </span>
                        <h1 className="text-2xl sm:text-3xl font-black text-white mt-1">
                            Diễn Viên & Đạo Diễn Nổi Bật
                        </h1>
                        <p className="text-sm text-slate-400 mt-2 max-w-2xl leading-relaxed">
                            Tra cứu tiểu sử, giải thưởng danh giá và danh mục toàn bộ tác phẩm của các ngôi sao điện ảnh cùng những nhà làm phim hàng đầu.
                        </p>
                    </div>

                    <div className="w-full md:w-72">
                        <input
                            type="text"
                            value={searchQuery}
                            onChange={(e) => setSearchQuery(e.target.value)}
                            placeholder="Tìm tên nghệ sĩ hoặc tác phẩm..."
                            className="w-full bg-[#121620] border border-white/10 rounded-xl px-4 py-2.5 text-xs text-white focus:outline-none focus:border-sky-400"
                        />
                    </div>
                </div>

                {/* Role Filters */}
                <div className="flex items-center gap-2">
                    <button
                        type="button"
                        onClick={() => setRoleFilter("all")}
                        className={`px-4 py-2 rounded-xl text-xs font-semibold cursor-pointer transition-all ${
                            roleFilter === "all"
                                ? "bg-sky-500 text-slate-950 font-bold"
                                : "bg-[#121620] text-slate-400 border border-white/10 hover:text-white"
                        }`}
                    >
                        Tất cả ({ARTISTS.length})
                    </button>
                    <button
                        type="button"
                        onClick={() => setRoleFilter("actor")}
                        className={`px-4 py-2 rounded-xl text-xs font-semibold cursor-pointer transition-all ${
                            roleFilter === "actor"
                                ? "bg-sky-500 text-slate-950 font-bold"
                                : "bg-[#121620] text-slate-400 border border-white/10 hover:text-white"
                        }`}
                    >
                        Diễn viên
                    </button>
                    <button
                        type="button"
                        onClick={() => setRoleFilter("director")}
                        className={`px-4 py-2 rounded-xl text-xs font-semibold cursor-pointer transition-all ${
                            roleFilter === "director"
                                ? "bg-sky-500 text-slate-950 font-bold"
                                : "bg-[#121620] text-slate-400 border border-white/10 hover:text-white"
                        }`}
                    >
                        Đạo diễn
                    </button>
                </div>

                {/* Artists Grid */}
                <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5 items-start">
                    {filtered.map((artist) => (
                        <Link
                            key={artist.id}
                            href={`/dien-vien/${encodeURIComponent(artist.name)}`}
                            className="p-6 rounded-2xl bg-[#121620] border border-white/10 hover:border-sky-400/40 transition-colors flex flex-col justify-between space-y-4 group"
                        >
                            <div className="space-y-3">
                                <div className="flex items-center justify-between">
                                    <div className="w-12 h-12 rounded-full bg-slate-900 border border-white/10 flex items-center justify-center text-base font-black text-sky-400">
                                        {artist.name.charAt(0)}
                                    </div>
                                    <span className="text-xs font-semibold text-sky-400 bg-sky-500/10 px-2.5 py-1 rounded-full">
                                        {artist.role}
                                    </span>
                                </div>

                                <div>
                                    <h2 className="text-base font-bold text-white group-hover:text-sky-400 transition-colors">
                                        {artist.name}
                                    </h2>
                                    <div className="text-xs text-slate-400 mt-0.5">
                                        Quốc tịch: {artist.nationality} • {artist.filmsCount} phim
                                    </div>
                                </div>

                                <p className="text-sm text-slate-300 leading-relaxed line-clamp-3">
                                    {artist.bio}
                                </p>

                                <div className="space-y-1 pt-1">
                                    <div className="text-xs font-semibold text-slate-400">
                                        Tác phẩm tiêu biểu:
                                    </div>
                                    <div className="flex flex-wrap gap-1.5">
                                        {artist.notableWorks.map((work) => (
                                            <span
                                                key={work}
                                                className="text-xs px-2 py-0.5 rounded bg-slate-900 text-slate-300 border border-white/5"
                                            >
                                                {work}
                                            </span>
                                        ))}
                                    </div>
                                </div>
                            </div>

                            <div className="border-t border-white/5 pt-3 flex items-center justify-between text-xs font-semibold text-sky-400" /* taste-skill-ignore: divider / tab-underline chrome */
>
                                <span>Xem sự nghiệp & Phim</span>
                                <span>→</span>
                            </div>
                        </Link>
                    ))}
                </div>
            </div>
        </div>
    );
}
