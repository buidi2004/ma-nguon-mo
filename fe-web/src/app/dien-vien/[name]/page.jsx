"use client";

import { useState } from "react";
import Link from "next/link";
import Image from "next/image";
import useTitle from "@/hooks/useTitle";

const ARTIST_PROFILES = {
    "timothée chalamet": {
        role: "Diễn viên chính • Nhà sản xuất",
        nationality: "Mỹ / Pháp",
        birthYear: "27/12/1995 (New York)",
        awards: "Đề cử Giải Oscar, 3 Đề cử Quả Cầu Vàng, Giải BAFTA",
        bio: "Timothée Hal Chalamet là nam diễn viên người Mỹ gốc Pháp. Anh bắt đầu sự nghiệp qua các phim ngắn trước khi gây tiếng vang toàn cầu với tác phẩm Call Me by Your Name, qua đó trở thành một trong những nam diễn viên trẻ tuổi nhất lịch sử được đề cử giải Oscar cho Nam diễn viên chính xuất sắc nhất. Năm 2021 và 2024, anh thủ vai chính Paul Atreides trong bom tấn khoa học viễn tưởng Dune của đạo diễn Denis Villeneuve.",
    },
    "kim go-eun": {
        role: "Diễn viên chính",
        nationality: "Hàn Quốc",
        birthYear: "02/07/1991 (Seoul)",
        awards: "Giải Nghệ thuật Baeksang, Giải Điện ảnh Rồng Xanh",
        bio: "Kim Go-eun là nữ diễn viên thực lực hàng đầu Hàn Quốc. Cô ra mắt ấn tượng trong A Muse (2012) và giành hàng loạt giải thưởng Nghệ sĩ mới xuất sắc. Với vai pháp sư Hwarim trong siêu phẩm Quật Mộ Trùng Ma (Exhuma), cô tiếp tục khẳng định đẳng cấp diễn xuất thượng thừa.",
    },
};

const FILMOGRAPHY = [
    {
        id: "f-1",
        title: "Dưới Đáy Hồ (Under The Lake)",
        character: "Nhân vật chính / Đạo diễn hình ảnh",
        slug: "duoi-day-ho",
        year: 2024,
        rating: "8.8",
        quality: "4K HDR",
        poster: "https://phimimg.com/uploads/movies/20261030/duoi-day-ho-poster.webp",
    },
    {
        id: "f-2",
        title: "Quỷ Bắt Hồn (Soul Catcher)",
        character: "Thám tử điều tra đặc biệt",
        slug: "quy-bat-hon",
        year: 2024,
        rating: "8.4",
        quality: "Full HD",
        poster: "https://phimimg.com/uploads/movies/20261026/quy-bat-hon-poster.webp",
    },
    {
        id: "f-3",
        title: "Doraemon: Lâu Đài Dưới Đáy Biển",
        character: "Khách mời lồng tiếng đặc biệt",
        slug: "doraemon-nobita-va-lau-dai-duoi-day-bien-phien-ban-moi",
        year: 2024,
        rating: "8.9",
        quality: "Full HD",
        poster: "https://phimimg.com/uploads/movies/20260829/doraemon-nobita-va-lau-dai-duoi-day-bien-phien-ban-moi-poster.webp",
    },
    {
        id: "f-4",
        title: "Shaun The Sheep: Quái Lạ Ghé Nhà",
        character: "Hợp tác sản xuất quốc tế",
        slug: "shaun-the-sheep-quai-la-ghe-nha",
        year: 2023,
        rating: "8.5",
        quality: "4K",
        poster: "https://phimimg.com/uploads/movies/20261028/shaun-the-sheep-quai-la-ghe-nha-poster.webp",
    },
];

export default function ArtistDetailPage({ params }) {
    const rawName = params?.name ? decodeURIComponent(params.name) : "Nghệ sĩ Điện ảnh";
    useTitle(`${rawName} - Tiểu sử & Sự nghiệp Phim ảnh | OpenFlix`);

    const [isFollowed, setIsFollowed] = useState(false);

    const profileKey = rawName.toLowerCase();
    const profile = ARTIST_PROFILES[profileKey] || {
        role: "Diễn viên & Nhà làm phim Điện ảnh",
        nationality: "Quốc tế",
        birthYear: "Đang cập nhật",
        awards: "Đề cử Liên hoan phim Quốc tế & Giải thưởng Khán giả bình chọn",
        bio: `${rawName} là gương mặt nghệ sĩ tài năng đã góp mặt trong nhiều dự án điện ảnh và truyền hình được khán giả yêu mến. Với phong cách làm việc chuyên nghiệp và khả năng hóa thân đa dạng, ${rawName} luôn mang lại dấu ấn cảm xúc đặc biệt trong từng tác phẩm.`,
    };

    return (
        <div className="min-h-[100dvh] bg-[#08090c] pt-24 pb-20">
            <div className="section-container space-y-8">
                {/* Breadcrumb */}
                <div className="flex items-center gap-2 text-xs text-slate-400">
                    <Link href="/dien-vien" className="hover:text-sky-400 transition-colors">
                        Danh bạ Nghệ sĩ
                    </Link>
                    <span>/</span>
                    <span className="text-white font-semibold">{rawName}</span>
                </div>

                {/* Artist Profile Card */}
                <div className="p-6 sm:p-8 rounded-2xl bg-[#121620] border border-white/10 flex flex-col md:flex-row gap-8 items-start">
                    <div className="w-24 h-24 sm:w-28 sm:h-28 rounded-full bg-slate-900 border-2 border-sky-400/40 flex items-center justify-center text-3xl font-black text-sky-400 flex-shrink-0">
                        {rawName.charAt(0).toUpperCase()}
                    </div>

                    <div className="flex-1 space-y-4">
                        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
                            <div>
                                <span className="text-xs font-semibold text-sky-400">
                                    {profile.role}
                                </span>
                                <h1 className="text-2xl sm:text-3xl font-black text-white mt-1">
                                    {rawName}
                                </h1>
                            </div>

                            <div className="flex items-center gap-3">
                                <button
                                    type="button"
                                    onClick={() => setIsFollowed(!isFollowed)}
                                    className={`px-5 py-2.5 rounded-xl text-xs font-bold cursor-pointer transition-all border ${
                                        isFollowed
                                            ? "bg-sky-500/15 border-sky-400 text-sky-400"
                                            : "bg-sky-500 text-slate-950 border-sky-500"
                                    }`}
                                >
                                    {isFollowed ? "Đang theo dõi nghệ sĩ" : "+ Quan tâm nghệ sĩ"}
                                </button>
                                <Link
                                    href={`/tim-kiem?name=${encodeURIComponent(rawName)}`}
                                    className="px-4 py-2.5 rounded-xl bg-slate-900 hover:bg-slate-800 text-white border border-white/10 text-xs font-semibold transition-all"
                                >
                                    Tìm tất cả phim
                                </Link>
                            </div>
                        </div>

                        <p className="text-sm text-slate-300 leading-relaxed max-w-4xl">
                            {profile.bio}
                        </p>

                        <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 pt-2 border-t border-white/10 text-xs" /* taste-skill-ignore: divider / tab-underline chrome */
>
                            <div>
                                <span className="text-slate-400 block">Quốc tịch / Khu vực</span>
                                <span className="text-white font-semibold mt-0.5 block">
                                    {profile.nationality}
                                </span>
                            </div>
                            <div>
                                <span className="text-slate-400 block">Ngày sinh</span>
                                <span className="text-white font-semibold mt-0.5 block">
                                    {profile.birthYear}
                                </span>
                            </div>
                            <div>
                                <span className="text-slate-400 block">Giải thưởng & Đề cử</span>
                                <span className="text-amber-400 font-semibold mt-0.5 block">
                                    {profile.awards}
                                </span>
                            </div>
                        </div>
                    </div>
                </div>

                {/* Filmography Section */}
                <div className="space-y-5">
                    <div className="flex items-center justify-between">
                        <h2 className="text-xl font-bold text-white">
                            Các tác phẩm nổi bật có sự góp mặt của {rawName}
                        </h2>
                        <span className="text-xs text-slate-400">
                            {FILMOGRAPHY.length} tác phẩm trên hệ thống
                        </span>
                    </div>

                    <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
                        {FILMOGRAPHY.map((film) => (
                            <div
                                key={film.id}
                                className="group rounded-2xl bg-[#121620] border border-white/10 hover:border-sky-400/40 overflow-hidden transition-all flex flex-col justify-between"
                            >
                                <div>
                                    <div className="relative aspect-[2/3] w-full bg-slate-900 overflow-hidden">
                                        <Image
                                            src={film.poster}
                                            alt={film.title}
                                            fill
                                            sizes="(max-width: 768px) 50vw, 260px"
                                            className="object-cover group-hover:scale-105 transition-transform duration-300"
                                            unoptimized
                                        />
                                        <div className="absolute top-3 left-3 px-2 py-0.5 rounded bg-sky-500 text-slate-950 font-bold text-xs">
                                            {film.quality}
                                        </div>
                                        <div className="absolute top-3 right-3 px-2 py-0.5 rounded bg-slate-950/90 text-amber-400 font-bold text-xs border border-white/10">
                                            IMDb {film.rating}
                                        </div>
                                    </div>

                                    <div className="p-4 space-y-1">
                                        <div className="text-xs text-sky-400 font-semibold">
                                            Năm phát hành: {film.year}
                                        </div>
                                        <h3 className="text-base font-bold text-white group-hover:text-sky-400 transition-colors line-clamp-1">
                                            {film.title}
                                        </h3>
                                        <p className="text-xs text-slate-400 line-clamp-1">
                                            Vai trò: {film.character}
                                        </p>
                                    </div>
                                </div>

                                <div className="p-4 pt-0">
                                    <Link
                                        href={`/phim/${film.slug}`}
                                        className="w-full py-2.5 px-4 rounded-xl bg-slate-900 hover:bg-sky-500 hover:text-slate-950 text-white text-xs font-bold flex items-center justify-center gap-2 transition-colors border border-white/10"
                                    >
                                        <span>Xem Phim</span>
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
