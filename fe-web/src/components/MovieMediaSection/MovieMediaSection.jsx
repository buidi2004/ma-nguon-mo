'use client'

import { useState, useContext, useMemo, useEffect } from 'react';
import dynamic from 'next/dynamic';
import { saveContext } from '@/contexts/saveContext';
import Link from 'next/link';
import useTitle from '@/hooks/useTitle';

const ReactPlayer = dynamic(() => import('react-player'), {
    ssr: false,
    loading: () => (
        <div className="w-full h-full bg-black flex flex-col items-center justify-center">
            <div className="loader"></div>
            <span className="text-xs text-sky-400 mt-3 font-medium">Đang khởi tạo trình phát video...</span>
        </div>
    ),
});

const getEpLabel = (name, index) => {
    if (!name) return `Tập ${index + 1}`;
    const trimmed = String(name).trim();
    if (/^tập/i.test(trimmed) || /full/i.test(trimmed) || /bản/i.test(trimmed)) {
        return trimmed;
    }
    return `Tập ${trimmed}`;
};

const EpisodeButtons = ({ media, epIndex, svIndex }) => {
    const episodes = media?.[svIndex]?.server_data || media?.[0]?.server_data || [];
    if (episodes.length === 0) return null;

    return (
        <div className="p-4 sm:p-5 rounded-b-2xl bg-[#0c0e14]">
            <div className="text-sm text-slate-300 font-semibold mb-3 flex items-center gap-2">
                <span className="w-2 h-2 rounded-full bg-sky-400"></span>
                Danh sách tập ({episodes.length} tập):
            </div>
            <div className="flex flex-wrap gap-2 max-h-60 overflow-y-auto no-scrollbar">
                {episodes.map((episode, index) => {
                    const isActive = '' + index === '' + epIndex;
                    return (
                        <Link
                            key={index}
                            href={`?sv=${svIndex}&tap=${index}`}
                            className={`episode-btn ${isActive ? 'episode-btn-active' : ''}`}
                        >
                            {getEpLabel(episode.name, index)}
                        </Link>
                    );
                })}
            </div>
        </div>
    );
};

const ServerTabs = ({ media, svIndex }) => {
    if (!media || media.length === 0) return null;
    return (
        <div className="flex flex-wrap gap-2 mt-6 border-b border-white/10 pb-0" /* taste-skill-ignore: divider / tab-underline chrome */
>
            {media.map((server, index) => (
                <Link
                    href={`?sv=${index}&tap=0`}
                    key={index}
                    className={`server-tab ${'' + index === '' + svIndex ? 'server-tab-active' : ''}`}
                >
                    <span className="w-2 h-2 rounded-full mr-2 bg-emerald-400 animate-pulse"></span>
                    {server.server_name || `Máy chủ #${index + 1}`}
                </Link>
            ))}
        </div>
    );
};

const MovieMediaSection = ({ info, media, epIndex = 0, svIndex = 0 }) => {
    const context = useContext(saveContext);
    const [copied, setCopied] = useState(false);
    const [lightsOff, setLightsOff] = useState(false);

    const currentServer = media?.[svIndex] || media?.[0];
    const episodes = currentServer?.server_data || [];
    const currentEp = episodes[epIndex] || episodes[0] || {};

    const videoUrl = currentEp?.link_m3u8 || currentEp?.link_embed || '';
    const isDirectVideo = useMemo(() => {
        if (!videoUrl) return false;
        return (
            videoUrl.endsWith('.mp4') ||
            videoUrl.endsWith('.webm') ||
            videoUrl.endsWith('.m3u8') ||
            videoUrl.includes('zencdn.net') ||
            videoUrl.includes('github.io')
        );
    }, [videoUrl]);

    // Smart player initial state: use iframe if it is an embed link
    const [useIframe, setUseIframe] = useState(!isDirectVideo);

    const epName = getEpLabel(currentEp?.name, epIndex);
    useTitle(`${info?.name || 'Phim'} - ${epName} | OpenFlix`);

    // Auto-save to OpenFlix Watch History
    useEffect(() => {
        if (!info || !info.name) return;
        try {
            if (typeof window !== 'undefined') {
                const raw = localStorage.getItem('openflix_watchHistory') || '[]';
                const list = JSON.parse(raw);
                const filtered = Array.isArray(list) ? list.filter((m) => m?.slug !== info.slug && m?.id !== info.id) : [];
                const newEntry = {
                    id: info.id || info._id || info.slug,
                    name: info.name,
                    origin_name: info.origin_name || '',
                    slug: info.slug,
                    thumb_url: info.thumb_url || info.poster_url || '/placeholder.webp',
                    poster_url: info.poster_url || info.thumb_url || '/placeholder.webp',
                    year: info.year || 2024,
                    category: Array.isArray(info.category) ? info.category.map(c => c.name).join(', ') : (info.category || 'Phim'),
                    time: info.time || '90 phút',
                    epName: epName,
                    svIndex: svIndex,
                    epIndex: epIndex,
                    watchedAt: new Date().toISOString(),
                };
                localStorage.setItem('openflix_watchHistory', JSON.stringify([newEntry, ...filtered.slice(0, 49)]));
            }
        } catch (e) {
            console.warn('[watchHistory] Could not save:', e);
        }
    }, [info?.slug, svIndex, epIndex, epName]);

    const saved = context.isSaved(info);

    const addToSaveList = (movie) => {
        context.toggleSaveMovie(movie);
    };

    const handleShare = () => {
        if (typeof window !== 'undefined') {
            navigator.clipboard.writeText(window.location.href);
            setCopied(true);
            setTimeout(() => setCopied(false), 2500);
        }
    };

    return (
        <div className={`section-container pt-20 pb-28 transition-colors duration-500 ${lightsOff ? 'bg-black/95' : ''}`}>
            {/* Top Bar with Breadcrumbs & Back link */}
            <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3 mb-4">
                <Link
                    href={`/phim/${info?.slug || ''}`}
                    className="inline-flex items-center gap-2 text-sm font-semibold text-sky-400 hover:text-sky-300 transition-colors py-1.5 px-3 rounded-lg bg-white/[0.06] hover:bg-sky-500/20 border border-white/10 w-fit"
                >
                    <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M10 19l-7-7m0 0l7-7m-7 7h18" />
                    </svg>
                    <span>Quay lại trang thông tin phim</span>
                </Link>

                <div className="flex items-center gap-2 text-xs text-slate-400">
                    <span className="w-2 h-2 rounded-full bg-emerald-400"></span>
                    <span>Nguồn phát: {currentServer?.server_name || 'VPS Cloud'}</span>
                    <span className="text-white font-medium">· {epName}</span>
                </div>
            </div>

            {/* Movie Title */}
            <div className="mb-4">
                <h1 className="text-white text-2xl sm:text-3xl font-extrabold leading-tight">
                    {info?.name}
                </h1>
                <p className="text-slate-400 text-sm mt-0.5">
                    {info?.origin_name ? `${info.origin_name} · ` : ''}{epName}
                </p>
            </div>

            {/* Cinema Video Player Frame */}
            <div className="relative aspect-video w-full bg-black rounded-2xl overflow-hidden border-2 border-sky-500/40 shadow-2xl shadow-sky-500/20 group" /* taste-skill-ignore: Netflix card overlay (scrim shadow), kept intentionally */
>
                {useIframe && !isDirectVideo ? (
                    <iframe
                        className="w-full h-full border-0"
                        src={currentEp?.link_embed || videoUrl}
                        loading="lazy"
                        allowFullScreen={true}
                        title={info?.name || 'Trình phát phim'}
                        allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
                    ></iframe>
                ) : (
                    <ReactPlayer
                        width="100%"
                        height="100%"
                        url={videoUrl}
                        playsinline={true}
                        pip={true}
                        stopOnUnmount={false}
                        controls={true}
                        playing={false}
                    />
                )}
            </div>

            {/* Player Controls Bar */}
            <div className="flex flex-wrap items-center justify-between gap-3 mt-4 p-3 rounded-xl bg-white/[0.05] border border-white/10 backdrop-blur-xl shadow-lg" /* taste-skill-ignore: Netflix card overlay (scrim shadow), kept intentionally */
>
                <div className="flex items-center gap-2 text-xs text-slate-300">
                    <span className="px-2.5 py-0.5 rounded-full bg-sky-500/20 text-sky-400 font-bold border border-sky-500/30">
                        HD 1080p
                    </span>
                    <span className="hidden sm:inline text-slate-400">
                        {useIframe ? 'Khung nhúng Iframe' : 'Direct Stream Player'}
                    </span>
                </div>

                <div className="flex flex-wrap items-center gap-2">
                    {/* Toggle Player Switcher */}
                    <button
                        className="feature-btn text-xs sm:text-sm hover:border-sky-500/40"
                        aria-label="Đổi trình phát"
                        onClick={() => setUseIframe(!useIframe)}
                    >
                        <svg className="w-4 h-4 text-sky-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M8 7h12m0 0l-4-4m4 4l-4 4m0 6H4m0 0l4 4m-4-4l4-4" />
                        </svg>
                        <span>Đổi Player ({useIframe ? 'Iframe' : 'Direct'})</span>
                    </button>

                    {/* Darken Cinema Mode */}
                    <button
                        className={`feature-btn text-xs sm:text-sm ${lightsOff ? 'text-amber-400 border-amber-400/50 bg-amber-500/10' : ''}`}
                        aria-label="Tắt đèn rạp chiếu"
                        onClick={() => setLightsOff(!lightsOff)}
                    >
                        {lightsOff ? (
                            <svg className="w-4 h-4 text-amber-400 fill-current" viewBox="0 0 24 24"><path d="M12 7c-2.76 0-5 2.24-5 5s2.24 5 5 5 5-2.24 5-5-2.24-5-5-5zM2 13h2c.55 0 1-.45 1-1s-.45-1-1-1H2c-.55 0-1 .45-1 1s.45 1 1 1zm18 0h2c.55 0 1-.45 1-1s-.45-1-1-1h-2c-.55 0-1 .45-1 1s.45 1 1 1zM11 2v2c0 .55.45 1 1 1s1-.45 1-1V2c0-.55-.45-1-1-1s-1 .45-1 1zm0 18v2c0 .55.45 1 1 1s1-.45 1-1v-2c0-.55-.45-1-1-1s-1 .45-1 1z"/></svg>
                        ) : (
                            <svg className="w-4 h-4 text-slate-300 fill-current" viewBox="0 0 24 24"><path d="M12.3 2a10 10 0 0 0-.19 14 10 10 0 0 0 11.89 4.19 1 1 0 0 0 .61-1.35 1 1 0 0 0-1.11-.64A8 8 0 0 1 12 4.1a8 8 0 0 1 1.25.1 1 1 0 0 0 1.11-.64 1 1 0 0 0-.61-1.35A10 10 0 0 0 12.3 2z"/></svg>
                        )}
                        <span>{lightsOff ? 'Bật đèn' : 'Tắt đèn'}</span>
                    </button>

                    {/* Bookmark Save */}
                    <button
                        className={`feature-btn text-xs sm:text-sm ${
                            saved ? 'text-sky-400 border-sky-400/50 bg-sky-500/10' : ''
                        }`}
                        aria-label="Lưu phim"
                        onClick={() => addToSaveList(info)}
                    >
                        <svg className="w-4 h-4 fill-current" viewBox="0 0 24 24">
                            <path d="M5 5a2 2 0 012-2h10a2 2 0 012 2v16l-7-3.5L5 21V5z" />
                        </svg>
                        <span>{saved ? 'Đã lưu' : 'Lưu phim'}</span>
                    </button>

                    {/* Share Link */}
                    <button
                        className={`feature-btn text-xs sm:text-sm ${copied ? 'text-emerald-400 border-emerald-400/50' : ''}`}
                        aria-label="Chia sẻ"
                        onClick={handleShare}
                    >
                        <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M8.684 13.342C8.886 12.938 9 12.482 9 12c0-.482-.114-.938-.316-1.342m0 2.684a3 3 0 110-2.684m0 2.684l6.632 3.316m-6.632-6l6.632-3.316m0 0a3 3 0 105.367-2.684 3 3 0 00-5.367 2.684zm0 9.316a3 3 0 105.368 2.684 3 3 0 00-5.368-2.684z" />
                        </svg>
                        <span>{copied ? 'Đã chép link!' : 'Chia sẻ'}</span>
                    </button>
                </div>
            </div>

            {/* Server Tabs */}
            <ServerTabs media={media} svIndex={svIndex} />

            {/* Episode Buttons */}
            <EpisodeButtons media={media} epIndex={epIndex} svIndex={svIndex} />
        </div>
    );
};

export default MovieMediaSection;
