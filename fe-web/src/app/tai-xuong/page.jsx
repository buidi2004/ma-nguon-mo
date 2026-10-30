'use client'

import { useState, useEffect } from "react";
import Link from "next/link";
import useTitle from "@/hooks/useTitle";

export default function DownloadsPage() {
    useTitle("Tệp tải xuống & Bộ nhớ ngoại tuyến - OpenFlix");

    const [smartDownload, setSmartDownload] = useState(true);
    const [downloadQuality, setDownloadQuality] = useState("1080p");
    const [downloads, setDownloads] = useState([
        {
            id: "dl-1",
            title: "Trường Nguyệt Tẫn Minh",
            episode: "Tập 01 (HD Vietsub)",
            size: "620 MB",
            duration: "48 phút",
            quality: "1080p",
            slug: "truong-nguyet-tan-minh",
            date: "Hôm nay, 14:20",
        },
        {
            id: "dl-2",
            title: "Dune: Hành Tinh Cát - Phần 2",
            episode: "Bản Chiếu Rạp (Thuyết minh)",
            size: "1.8 GB",
            duration: "166 phút",
            quality: "4K HDR",
            slug: "dune-part-two",
            date: "Hôm qua, 21:05",
        },
        {
            id: "dl-3",
            title: "Ẩn Danh (Taxi Driver 2)",
            episode: "Tập 16 (Tập cuối)",
            size: "740 MB",
            duration: "65 phút",
            quality: "1080p",
            slug: "an-danh-phan-2",
            date: "28/10/2026",
        },
    ]);

    const [message, setMessage] = useState("");

    const handleDelete = (id) => {
        setDownloads((prev) => prev.filter((item) => item.id !== id));
        setMessage("Đã giải phóng bộ nhớ của tệp phim.");
        setTimeout(() => setMessage(""), 3000);
    };

    const handleClearAll = () => {
        if (window.confirm("Bạn có chắc chắn muốn xóa tất cả video ngoại tuyến và giải phóng 3.16 GB bộ nhớ cache?")) {
            setDownloads([]);
            setMessage("Đã dọn sạch toàn bộ tệp tải xuống.");
            setTimeout(() => setMessage(""), 3000);
        }
    };

    return (
        <div className="page-container-0topside">
            <div className="section-container max-w-4xl mx-auto space-y-8">
                {/* Header */}
                <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 border-b border-white/10 pb-6" /* taste-skill-ignore: divider / tab-underline chrome */
>
                    <div>
                        <div className="flex items-center gap-3">
                            <div className="text-sky-400 flex items-center justify-center">
                                <svg className="w-6 h-6 fill-current" viewBox="0 0 24 24">
                                    <path d="M19.35 10.04C18.67 6.59 15.64 4 12 4 9.11 4 6.6 5.64 5.35 8.04 2.34 8.36 0 10.91 0 14c0 3.31 2.69 6 6 6h13c2.76 0 5-2.24 5-5 0-2.64-2.05-4.78-4.65-4.96zM17 13l-5 5-5-5h3V9h4v4h3z" />
                                </svg>
                            </div>
                            <h1 className="section-title-no-up">Tệp tải xuống & Ngoại tuyến</h1>
                        </div>
                        <p className="text-sm text-slate-400 mt-2">
                            Xem video chất lượng cao mọi lúc, mọi nơi ngay cả khi không có kết nối Internet.
                        </p>
                    </div>

                    {downloads.length > 0 && (
                        <button
                            type="button"
                            onClick={handleClearAll}
                            className="px-4 py-2 text-xs font-semibold rounded-lg bg-white/5 hover:bg-rose-500/20 hover:text-rose-400 border border-white/10 text-slate-300 transition-colors self-start sm:self-auto cursor-pointer"
                        >
                            Xóa tất cả (3.16 GB)
                        </button>
                    )}
                </div>

                {message && (
                    <div className="p-3 rounded-lg bg-sky-950/60 border border-sky-500/30 text-sky-300 text-xs flex items-center justify-between">
                        <span>{message}</span>
                        <button type="button" onClick={() => setMessage("")} className="text-slate-400 hover:text-white" aria-label="Đóng">
                            <svg className="w-3.5 h-3.5 fill-none stroke-current" strokeWidth="2" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" d="M6 18L18 6M6 6l12 12"/></svg>
                        </button>
                    </div>
                )}

                {/* Storage Meter */}
                <div className="p-6 rounded-2xl bg-[#121620] border border-white/10 space-y-4">
                    <div className="flex items-center justify-between text-sm">
                        <span className="text-white font-semibold">Dung lượng thiết bị</span>
                        <span className="text-slate-400 text-xs">Trống 38.4 GB / 64 GB</span>
                    </div>

                    <div className="w-full h-3 rounded-full bg-slate-800 overflow-hidden flex">
                        <div className="bg-sky-500 h-full w-[12%]" title="OpenFlix (3.16 GB)" />
                        <div className="bg-slate-600 h-full w-[28%]" title="Ứng dụng khác (18.2 GB)" />
                    </div>

                    <div className="flex items-center gap-6 text-xs text-slate-400">
                        <div className="flex items-center gap-2">
                            <span className="w-2.5 h-2.5 rounded-full bg-sky-500" />
                            <span>OpenFlix: 3.16 GB</span>
                        </div>
                        <div className="flex items-center gap-2">
                            <span className="w-2.5 h-2.5 rounded-full bg-slate-600" />
                            <span>Ứng dụng khác: 18.2 GB</span>
                        </div>
                        <div className="flex items-center gap-2">
                            <span className="w-2.5 h-2.5 rounded-full bg-slate-800 border border-white/10" />
                            <span>Trống: 38.4 GB</span>
                        </div>
                    </div>
                </div>

                {/* Smart Downloads Settings */}
                <div className="p-6 rounded-2xl bg-[#121620] border border-white/10 space-y-6">
                    <h2 className="text-white font-bold text-base">Cài đặt tải xuống thông minh</h2>

                    <div className="flex items-center justify-between py-2 border-b border-white/5">
                        <div className="space-y-1 pr-4">
                            <p className="text-white font-medium text-sm">Tải thông minh (Smart Downloads)</p>
                            <p className="text-xs text-slate-400">
                                Tự động tải tập tiếp theo và xóa tập đã xem khi thiết bị kết nối mạng Wi-Fi.
                            </p>
                        </div>
                        <button
                            type="button"
                            onClick={() => setSmartDownload(!smartDownload)}
                            className={`w-12 h-6 rounded-full transition-colors relative cursor-pointer ${
                                smartDownload ? "bg-sky-500" : "bg-slate-700"
                            }`}
                            aria-label="Chuyển đổi tải thông minh"
                        >
                            <span
                                className={`absolute top-1 left-1 bg-white w-4 h-4 rounded-full transition-transform ${
                                    smartDownload ? "translate-x-6" : "translate-x-0"
                                }`}
                            />
                        </button>
                    </div>

                    <div className="flex items-center justify-between py-2">
                        <div className="space-y-1 pr-4">
                            <p className="text-white font-medium text-sm">Độ phân giải tải xuống</p>
                            <p className="text-xs text-slate-400">
                                Chất lượng cao sử dụng nhiều dung lượng lưu trữ hơn.
                            </p>
                        </div>
                        <select
                            value={downloadQuality}
                            onChange={(e) => setDownloadQuality(e.target.value)}
                            className="bg-slate-900 border border-white/10 text-white rounded-lg px-3 py-1.5 text-xs focus:outline-none focus:border-sky-400 cursor-pointer"
                        >
                            <option value="720p">Tiêu chuẩn (720p HD - Nhanh)</option>
                            <option value="1080p">Chất lượng cao (1080p Full HD)</option>
                            <option value="4K">Gốc Ultra HD 4K (Dung lượng lớn)</option>
                        </select>
                    </div>
                </div>

                {/* Downloads List */}
                <div className="space-y-4">
                    <div className="flex items-center justify-between">
                        <h2 className="text-white font-bold text-base">Tệp đã tải ({downloads.length})</h2>
                        <span className="text-xs text-slate-400">Tự động làm mới khi kết nối mạng</span>
                    </div>

                    {downloads.length === 0 ? (
                        <div className="p-12 text-center rounded-2xl bg-[#121620] border border-white/10">
                            <div className="w-16 h-16 mx-auto mb-4 rounded-xl bg-sky-500/10 border border-sky-400/30 flex items-center justify-center text-sky-400">
                                <svg className="w-8 h-8 fill-current" viewBox="0 0 24 24">
                                    <path d="M19.35 10.04C18.67 6.59 15.64 4 12 4 9.11 4 6.6 5.64 5.35 8.04 2.34 8.36 0 10.91 0 14c0 3.31 2.69 6 6 6h13c2.76 0 5-2.24 5-5 0-2.64-2.05-4.78-4.65-4.96zM17 13l-5 5-5-5h3V9h4v4h3z" />
                                </svg>
                            </div>
                            <h3 className="text-white text-lg font-bold mb-2">Chưa có video nào được tải về</h3>
                            <p className="text-slate-400 text-sm mb-6 max-w-md mx-auto">
                                Bạn có thể tải phim hoặc các tập phim yêu thích để thưởng thức ngoại tuyến khi đi tàu xe, máy bay hoặc nơi sóng yếu.
                            </p>
                            <Link
                                href="/phim-moi/1"
                                className="play-button-color px-6 py-3 text-sm inline-flex items-center gap-2"
                            >
                                Khám phá phim có sẵn để tải
                            </Link>
                        </div>
                    ) : (
                        <div className="space-y-3">
                            {downloads.map((item) => (
                                <div
                                    key={item.id}
                                    className="p-4 rounded-xl bg-[#121620] border border-white/10 hover:border-sky-400/40 transition-colors flex items-center justify-between gap-4"
                                >
                                    <div className="flex items-center gap-4 min-w-0">
                                        <div className="text-sky-400 flex-shrink-0 flex items-center justify-center">
                                            <svg className="w-6 h-6 fill-current" viewBox="0 0 24 24">
                                                <path d="M8 5v14l11-7z" />
                                            </svg>
                                        </div>
                                        <div className="min-w-0 space-y-1">
                                            <div className="flex items-center gap-2 flex-wrap">
                                                <span className="text-white font-semibold text-sm truncate">{item.title}</span>
                                                <span className="px-2 py-0.5 rounded text-[11px] font-bold bg-sky-950 text-sky-400 border border-sky-400/20">
                                                    {item.quality}
                                                </span>
                                            </div>
                                            <div className="flex items-center gap-3 text-xs text-slate-400">
                                                <span>{item.episode}</span>
                                                <span>•</span>
                                                <span>{item.duration}</span>
                                                <span>•</span>
                                                <span className="text-slate-300 font-medium">{item.size}</span>
                                            </div>
                                        </div>
                                    </div>

                                    <div className="flex items-center gap-2 flex-shrink-0">
                                        <Link
                                            href={`/xem-phim/${item.slug}`}
                                            className="px-3.5 py-1.5 rounded-lg bg-sky-500 hover:bg-sky-400 text-white font-semibold text-xs transition-colors flex items-center gap-1.5"
                                        >
                                            <svg className="w-3.5 h-3.5 fill-current" viewBox="0 0 24 24"><path d="M8 5v14l11-7z"/></svg>
                                            <span>Xem ngay</span>
                                        </Link>
                                        <button
                                            type="button"
                                            onClick={() => handleDelete(item.id)}
                                            title="Xóa tệp ngoại tuyến"
                                            className="p-2 rounded-lg bg-white/5 hover:bg-rose-500/20 hover:text-rose-400 text-slate-400 border border-white/10 transition-colors cursor-pointer"
                                        >
                                            <svg className="w-4 h-4 fill-none stroke-current" strokeWidth="2" viewBox="0 0 24 24">
                                                <path strokeLinecap="round" strokeLinejoin="round" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                                            </svg>
                                        </button>
                                    </div>
                                </div>
                            ))}
                        </div>
                    )}
                </div>
            </div>
        </div>
    );
}
