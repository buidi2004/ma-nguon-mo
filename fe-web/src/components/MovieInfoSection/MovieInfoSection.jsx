'use client'

import Image from 'next/image';
import { useContext } from 'react';
import { saveContext } from '@/contexts/saveContext';
import Link from 'next/link';
import ContentInfo from '../ContentInfo/ContentInfo';
import TrailerPlayer from '../TrailerPlayer/TrailerPlayer';
import useTitle from '@/hooks/useTitle';

const CategoryChip = ({ categories }) => {
    if (!categories || categories.length === 0) return null;
    return (
        <div className="flex flex-wrap mt-2 sm:mt-3 gap-2">
            {categories.map((category) => (
                <Link
                    key={category.id || category.name}
                    href={`/the-loai/${category.slug || 'phim'}/1`}
                    className="px-3 py-1 rounded-full text-[13px] font-semibold bg-[#161a24] text-sky-300 hover:bg-sky-500/20 hover:text-white transition-colors cursor-pointer"
                >
                    {category.name}
                </Link>
            ))}
        </div>
    );
};

const RenderInformationArray = (array) => {
    if (!array || array.length === 0 || array[0] === '') {
        return <span className="text-slate-400">Đang cập nhật</span>;
    }
    return array.map((item, index) => (
        <span key={index}>
            <Link
                href={`/dien-vien/${encodeURIComponent(item.trim())}`}
                className="text-slate-200 hover:text-sky-300 transition-colors hover:underline underline-offset-2"
            >
                {item.trim()}
            </Link>
            {index === array.length - 1 ? '' : ', '}
        </span>
    ));
};

const MovieInfoSection = ({ info }) => {
    useTitle(`${info?.name || 'Phim'} | OpenFlix`);

    const context = useContext(saveContext);
    const saved = context.isSaved(info);

    const addToSaveList = (movie) => {
        context.toggleSaveMovie(movie);
    };

    if (!info) return null;

    return (
        <div className="relative">
            {/* ------ Hero Backdrop Container (Anti-Clipping Fixed) ------ */}
            <div className="relative w-full min-h-[520px] md:min-h-[580px] pb-12 overflow-hidden">
                {/* Background Backdrop Image */}
                <div className="absolute inset-0 -z-10 overflow-hidden">
                    <Image
                        src={info.poster_url || info.thumb_url || '/placeholder.webp'}
                        alt={info.name || 'Poster'}
                        quality={70}
                        priority
                        unoptimized
                        fill
                        sizes="100vw"
                        style={{ objectFit: 'cover' }}
                        className="brightness-[22%] filter blur-[3px] scale-105"
                    />
                    <div className="absolute inset-0 bg-gradient-to-t from-[#08090c] via-[#08090c]/75 to-transparent"></div> {/* taste-skill-ignore: neutral photo scrim */}
                    <div className="absolute inset-0 bg-gradient-to-r from-[#08090c] via-[#08090c]/85 to-transparent"></div> {/* taste-skill-ignore: neutral photo scrim */}
                </div>

                {/* Content Overlay */}
                <div className="section-container pt-24 md:pt-28 flex flex-col md:flex-row items-center md:items-end gap-8 relative z-10">
                    {/* Poster Card */}
                    <div className="w-52 sm:w-64 md:w-72 aspect-[2/3] relative rounded-2xl overflow-hidden bg-[#121620] flex-shrink-0 group">
                        <Image
                            src={info.thumb_url || info.poster_url || '/placeholder.webp'}
                            alt={info.name || 'Movie thumbnail'}
                            quality={85}
                            priority
                            unoptimized
                            fill
                            sizes="(max-width: 768px) 250px, 300px"
                            style={{ objectFit: 'cover' }}
                            className="rounded-2xl transform group-hover:scale-105 transition-transform duration-300"
                        />
                        <div className="absolute top-3 left-3 bg-sky-500 text-slate-950 font-black text-[13px] px-2.5 py-0.5 rounded">
                            FULL HD
                        </div>
                    </div>

                    {/* Brief Info */}
                    <div className="flex-1 text-center md:text-left">
                        <h1 className="text-white text-2xl sm:text-3xl md:text-[32px] font-black uppercase tracking-tight leading-tight">
                            {info.name}
                        </h1>

                        {info.origin_name && info.origin_name !== info.name && (
                            <h2 className="text-slate-400 text-base sm:text-lg font-medium mt-1">
                                {info.origin_name}
                            </h2>
                        )}

                        {/* Metadata Badges Row (Below Title - Netflix Standard) */}
                        <div className="flex flex-wrap items-center justify-center md:justify-start gap-2 my-3">
                            <span className="bg-sky-500/15 text-sky-400 font-bold text-[13px] px-2.5 py-0.5 rounded-full">
                                {info.year || 2024}
                            </span>
                            <span className="bg-white/10 text-slate-300 text-[13px] px-2.5 py-0.5 rounded-full">
                                {info.time || '90 phút'}
                            </span>
                            <span className="bg-cyan-500/15 text-cyan-300 text-[13px] font-semibold px-2.5 py-0.5 rounded-full">
                                Trạng thái: {info.episode_current || 'Full HD'}
                            </span>
                        </div>

                        <CategoryChip categories={info.category} />

                        {/* CTA Buttons */}
                        <div className="flex flex-wrap items-center justify-center md:justify-start gap-3 sm:gap-4 mt-6">
                            <Link
                                href={`?sv=0&tap=0`}
                                className="play-button-color text-slate-950 text-base px-8 py-3.5 flex items-center gap-2.5 rounded-xl font-bold cursor-pointer"
                            >
                                <svg className="w-6 h-6 fill-current" viewBox="0 0 24 24">
                                    <polygon points="5 3 19 12 5 21 5 3"></polygon>
                                </svg>
                                Xem Phim Ngay
                            </Link>

                            <button
                                aria-label="Lưu phim"
                                onClick={() => addToSaveList(info)}
                                className={`add-button-color text-base px-6 py-3.5 flex items-center gap-2 rounded-xl font-semibold transition-colors cursor-pointer ${
                                    saved ? 'text-sky-400 bg-sky-500/15' : 'text-white'
                                }`}
                            >
                                <svg
                                    className={`w-5 h-5 ${saved ? 'text-sky-400 fill-current' : 'text-slate-300'}`}
                                    fill={saved ? "currentColor" : "none"}
                                    stroke="currentColor"
                                    strokeWidth="2"
                                    viewBox="0 0 24 24"
                                >
                                    <path strokeLinecap="round" strokeLinejoin="round" d="M5 5a2 2 0 012-2h10a2 2 0 012 2v16l-7-3.5L5 21V5z" />
                                </svg>
                                <span>{saved ? 'Đã lưu trong danh sách' : 'Thêm vào danh sách'}</span>
                            </button>

                            <Link
                                href="/danh-gia"
                                className="add-button-color text-base px-6 py-3.5 flex items-center gap-2 rounded-xl font-semibold text-white hover:text-sky-400 transition-colors cursor-pointer"
                            >
                                <svg className="w-5 h-5 text-amber-400 fill-current" viewBox="0 0 24 24">
                                    <path d="M12 2l2.4 7.4h7.6l-6.2 4.5 2.4 7.4-6.2-4.5-6.2 4.5 2.4-7.4-6.2-4.5h7.6z" />
                                </svg>
                                <span>Đánh giá phim</span>
                            </Link>
                        </div>
                    </div>
                </div>
            </div>

            {/* ------ Detail Information Section ------ */}
            <div className="section-container pb-20 pt-6">
                <div className="grid grid-cols-1 lg:grid-cols-3 gap-8 items-start">
                    {/* Left: Synopsis & Trailer */}
                    <div className="lg:col-span-2 space-y-6">
                        <div className="p-6 rounded-2xl bg-[#121620]">
                            <h2 className="text-white text-xl font-bold mb-3">
                                Tóm tắt nội dung phim
                            </h2>
                            <ContentInfo info={info} />
                        </div>

                        {/* Trailer */}
                        <div className="p-6 rounded-2xl bg-[#121620]">
                            <h2 className="text-white text-xl font-bold mb-4">
                                Trailer chính thức
                            </h2>
                            {info.trailer_url ? (
                                <TrailerPlayer url={info.trailer_url} poster={info.poster_url || info.thumb_url} />
                            ) : (
                                <p className="text-slate-400 text-sm">Chưa có video Trailer cho bộ phim này.</p>
                            )}
                        </div>
                    </div>

                    {/* Right: Metadata Panel */}
                    <div className="p-6 rounded-2xl bg-[#121620] space-y-4">
                        <h3 className="text-white font-bold text-lg mb-4">
                            Thông tin chi tiết
                        </h3>

                        <div className="text-base space-y-3">
                            <div>
                                <span className="text-slate-400 block text-[13px]">Trạng thái phát hành</span>
                                <span className="text-sky-400 font-semibold">{info.episode_current || 'Full HD'}</span>
                            </div>
                            <div>
                                <span className="text-slate-400 block text-[13px]">Thời lượng</span>
                                <span className="text-white font-medium">{info.time || '90 phút'}</span>
                            </div>
                            <div>
                                <span className="text-slate-400 block text-[13px]">Năm sản xuất</span>
                                <span className="text-white font-medium">{info.year || 2024}</span>
                            </div>
                            <div>
                                <span className="text-slate-400 block text-[13px]">Quốc gia</span>
                                <span className="text-white font-medium">
                                    {info.country?.[0]?.name || 'Quốc tế'}
                                </span>
                            </div>
                            <div>
                                <span className="text-slate-400 block text-[13px]">Đạo diễn</span>
                                <div>{RenderInformationArray(info.director)}</div>
                            </div>
                            <div>
                                <span className="text-slate-400 block text-[13px]">Diễn viên chính</span>
                                <div>{RenderInformationArray(info.actor)}</div>
                            </div>
                            <div>
                                <span className="text-slate-400 block text-[13px]">Chất lượng</span>
                                <span className="text-emerald-400 font-semibold">HD 1080p · Âm thanh vòm 5.1</span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    );
};

export default MovieInfoSection;
