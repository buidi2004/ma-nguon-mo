'use client'

import { useState, useEffect } from "react";
import Link from "next/link";

export default function SettingsPage() {
    const [settings, setSettings] = useState({
        autoPlayNext: true,
        autoPlayPreview: false,
        defaultQuality: "1080p",
        defaultPlayer: "direct",
        subtitleLanguage: "vi",
        cinemaTheme: "dark",
    });
    const [savedNotice, setSavedNotice] = useState(false);

    useEffect(() => {
        try {
            if (typeof window !== "undefined") {
                const stored = localStorage.getItem("openflix_settings");
                if (stored) {
                    setSettings(JSON.parse(stored));
                }
            }
        } catch (e) {
            console.warn(e);
        }
    }, []);

    const updateSetting = (key, value) => {
        const next = { ...settings, [key]: value };
        setSettings(next);
        try {
            if (typeof window !== "undefined") {
                localStorage.setItem("openflix_settings", JSON.stringify(next));
            }
        } catch (e) {
            console.warn(e);
        }
        setSavedNotice(true);
        setTimeout(() => setSavedNotice(false), 2000);
    };

    const handleClearCache = () => {
        if (confirm("Bạn có chắc chắn muốn xóa bộ nhớ tạm (cache) và lịch sử lưu trữ cục bộ?")) {
            try {
                if (typeof window !== "undefined") {
                    localStorage.removeItem("openflix_watchHistory");
                    localStorage.removeItem("openflix_saveList");
                    localStorage.removeItem("saveList");
                    alert("Đã dọn dẹp bộ nhớ tạm thành công!");
                }
            } catch (e) {
                console.warn(e);
            }
        }
    };

    return (
        <div className="page-container-0topside">
            <div className="section-container max-w-4xl">
                {/* Header */}
                <div className="border-b border-white/10 pb-6 mb-8 flex flex-col sm:flex-row sm:items-center justify-between gap-4" /* taste-skill-ignore: divider / tab-underline chrome */
>
                    <div>
                        <div className="flex items-center gap-2 text-xs text-slate-400 mb-2">
                            <Link href="/" className="hover:text-sky-400 transition-colors">Trang chủ</Link>
                            <span>/</span>
                            <span className="text-sky-400 font-semibold">Cài đặt</span>
                        </div>
                        <h1 className="section-title-no-up flex items-center gap-2.5">
                            <span className="w-2 h-7 rounded-full bg-sky-500"></span>
                            <span>Cài Đặt Trải Nghiệm Điện Ảnh</span>
                        </h1>
                        <p className="text-slate-400 text-sm mt-1">
                            Tùy chỉnh chất lượng phát video, phụ đề và các tính năng xem phim rạp
                        </p>
                    </div>

                    {savedNotice && (
                        <span className="px-3 py-1 rounded-full text-xs font-semibold bg-emerald-500/20 text-emerald-400 border border-emerald-500/30 animate-fadeIn">
                            Đã lưu cài đặt tự động
                        </span>
                    )}
                </div>

                <div className="space-y-6">
                    {/* Playback Controls */}
                    <div className="p-6 rounded-2xl bg-[#121620] border border-white/10 space-y-5">
                        <h2 className="text-lg font-bold text-white flex items-center gap-2">
                            <span className="w-2 h-2 rounded-full bg-sky-400"></span>
                            Trình Phát Video & Tự Động
                        </h2>

                        <div className="space-y-4">
                            <div className="flex items-center justify-between gap-4 border-b border-white/5 pb-4" /* taste-skill-ignore: divider / tab-underline chrome */
>
                                <div>
                                    <div className="text-sm font-semibold text-white">Tự động phát tập tiếp theo</div>
                                    <div className="text-xs text-slate-400 mt-0.5">Khi tập hiện tại kết thúc, tự động chuyển sang tập tiếp theo</div>
                                </div>
                                <label className="relative inline-flex items-center cursor-pointer">
                                    <input
                                        type="checkbox"
                                        checked={settings.autoPlayNext}
                                        onChange={(e) => updateSetting("autoPlayNext", e.target.checked)}
                                        className="sr-only peer"
                                    />
                                    <div className="w-11 h-6 bg-slate-800 peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-sky-500"></div>
                                </label>
                            </div>

                            <div className="flex items-center justify-between gap-4 border-b border-white/5 pb-4" /* taste-skill-ignore: divider / tab-underline chrome */
>
                                <div>
                                    <div className="text-sm font-semibold text-white">Xem trước trailer khi rê chuột</div>
                                    <div className="text-xs text-slate-400 mt-0.5">Phát đoạn giới thiệu ngắn khi lướt qua thẻ phim trên desktop</div>
                                </div>
                                <label className="relative inline-flex items-center cursor-pointer">
                                    <input
                                        type="checkbox"
                                        checked={settings.autoPlayPreview}
                                        onChange={(e) => updateSetting("autoPlayPreview", e.target.checked)}
                                        className="sr-only peer"
                                    />
                                    <div className="w-11 h-6 bg-slate-800 peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-sky-500"></div>
                                </label>
                            </div>

                            <div className="flex items-center justify-between gap-4">
                                <div>
                                    <div className="text-sm font-semibold text-white">Chất lượng phát mặc định</div>
                                    <div className="text-xs text-slate-400 mt-0.5">Ưu tiên độ phân giải cao nhất theo băng thông mạng</div>
                                </div>
                                <select
                                    value={settings.defaultQuality}
                                    onChange={(e) => updateSetting("defaultQuality", e.target.value)}
                                    className="px-3 py-1.5 rounded-lg bg-[#08090c] border border-white/15 text-xs text-white focus:outline-none focus:border-sky-400 cursor-pointer"
                                >
                                    <option value="auto">Tự động (Khuyên dùng)</option>
                                    <option value="1080p">Full HD 1080p</option>
                                    <option value="4k">Ultra HD 4K</option>
                                    <option value="720p">HD 720p</option>
                                </select>
                            </div>
                        </div>
                    </div>

                    {/* Subtitle & Language */}
                    <div className="p-6 rounded-2xl bg-[#121620] border border-white/10 space-y-4">
                        <h2 className="text-lg font-bold text-white flex items-center gap-2">
                            <span className="w-2 h-2 rounded-full bg-cyan-400"></span>
                            Âm Thanh & Ngôn Ngữ Phụ Đề
                        </h2>

                        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 text-xs">
                            <div className="p-4 rounded-xl bg-[#08090c] border border-white/10 space-y-2">
                                <span className="text-slate-400 block font-semibold">Ngôn Ngữ Phụ Đề Mặc Định</span>
                                <select
                                    value={settings.subtitleLanguage}
                                    onChange={(e) => updateSetting("subtitleLanguage", e.target.value)}
                                    className="w-full px-3 py-2 rounded-lg bg-slate-900 border border-white/15 text-white focus:outline-none focus:border-sky-400 cursor-pointer"
                                >
                                    <option value="vi">Tiếng Việt (Vietsub & Thuyết minh)</option>
                                    <option value="en">Tiếng Anh (English Subtitles)</option>
                                    <option value="off">Tắt phụ đề</option>
                                </select>
                            </div>

                            <div className="p-4 rounded-xl bg-[#08090c] border border-white/10 space-y-2">
                                <span className="text-slate-400 block font-semibold">Trình Phát Video Ưu Tiên</span>
                                <select
                                    value={settings.defaultPlayer}
                                    onChange={(e) => updateSetting("defaultPlayer", e.target.value)}
                                    className="w-full px-3 py-2 rounded-lg bg-slate-900 border border-white/15 text-white focus:outline-none focus:border-sky-400 cursor-pointer"
                                >
                                    <option value="direct">Direct Stream Player (Tốc độ cao)</option>
                                    <option value="iframe">Iframe Embed Player (Dự phòng)</option>
                                </select>
                            </div>
                        </div>
                    </div>

                    {/* Data & Storage Management */}
                    <div className="p-6 rounded-2xl bg-[#121620] border border-white/10 flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
                        <div>
                            <h3 className="text-base font-bold text-white">Quản Lý Bộ Nhớ Cục Bộ (Local Storage)</h3>
                            <p className="text-xs text-slate-400 mt-0.5">
                                Xóa sạch lịch sử xem phim và danh sách phim đã lưu trên thiết bị này
                            </p>
                        </div>
                        <button
                            type="button"
                            onClick={handleClearCache}
                            className="text-xs px-4 py-2.5 rounded-xl font-semibold bg-white/[0.06] hover:bg-red-500/15 text-slate-300 hover:text-red-400 border border-white/15 hover:border-red-500/30 transition-colors cursor-pointer"
                        >
                            Dọn Dẹp Bộ Nhớ Tạm
                        </button>
                    </div>
                </div>
            </div>
        </div>
    );
}

