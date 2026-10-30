import Link from "next/link";

export const metadata = {
    title: 'Trung Tâm Trợ Giúp & Câu Hỏi Thường Gặp (FAQ) | OpenFlix',
    description: 'Hướng dẫn sử dụng OpenFlix, bảng phím tắt xem phim chuẩn rạp, mẹo khắc phục giật lag và giải đáp thắc mắc thường gặp.',
};

export default function FAQPage() {
    const faqs = [
        {
            q: "Video bị giật lag hoặc không chạy thì khắc phục như thế nào?",
            a: "OpenFlix hỗ trợ 2 chế độ phát video: Direct Stream Player (stream trực tiếp tốc độ cao) và Iframe Embed Player. Nếu một trong hai chế độ gặp sự cố, bạn chỉ cần bấm nút 'Đổi Player' ngay bên dưới thanh điều khiển video. Ngoài ra, bạn có thể chuyển đổi giữa các Máy chủ (Server #1, Server #2) ở danh sách máy chủ bên dưới.",
        },
        {
            q: "Danh sách phím tắt điều khiển khi xem phim trên máy tính là gì?",
            a: "Khi xem phim trên máy tính, bạn có thể sử dụng các phím tắt tiện lợi: Phím Space để Phát/Tạm dừng, Phím F để bật/tắt chế độ Toàn màn hình (Fullscreen), Phím M để Tắt/Bật tiếng (Mute), Phím Mũi tên Trái/Phải để tua lùi/tiến 5 giây, và Phím Mũi tên Lên/Xuống để điều chỉnh âm lượng.",
        },
        {
            q: "Làm thế nào để lưu phim vào danh sách xem sau (Watchlist)?",
            a: "Tại trang thông tin chi tiết của mỗi bộ phim, bạn chỉ cần nhấp vào nút 'Thêm vào danh sách'. Bộ phim sẽ được tự động lưu vào bộ nhớ cục bộ (Local Storage) của trình duyệt. Bạn có thể xem lại toàn bộ phim đã lưu bất cứ lúc nào tại mục 'Phim đã lưu' trên thanh điều hướng.",
        },
        {
            q: "Lịch sử xem phim có đồng bộ không và lưu trữ ở đâu?",
            a: "Mỗi khi bạn mở và xem một tập phim, hệ thống sẽ tự động ghi nhớ tập phim gần nhất và thời gian xem vào trang 'Lịch sử xem'. Dữ liệu này được bảo mật an toàn 100% trong bộ nhớ trình duyệt của bạn và không tải lên bất kỳ máy chủ bên thứ ba nào.",
        },
        {
            q: "OpenFlix cập nhật phim mới với tần suất như thế nào?",
            a: "Hệ thống kết nối trực tiếp với VPS Backend PocketBase với cơ chế đồng bộ dữ liệu liên tục. Các bộ phim chiếu rạp mới, phim bộ dài tập và anime hot nhất được hệ thống cập nhật hàng giờ ngay khi có bản phát hành chất lượng cao Full HD.",
        },
        {
            q: "OpenFlix có thu phí hay yêu cầu đăng ký tài khoản không?",
            a: "Hoàn toàn không. OpenFlix là một dự án nghiên cứu công nghệ mã nguồn mở (Open-source). Bạn có thể xem phim ngay lập tức với chất lượng Full HD & 4K hoàn toàn miễn phí mà không cần tạo tài khoản hay cung cấp thông tin cá nhân.",
        },
    ];

    return (
        <div className="page-container-0topside">
            <div className="section-container max-w-4xl">
                {/* Breadcrumbs & Header */}
                <div className="border-b border-white/10 pb-6 mb-8" /* taste-skill-ignore: divider / tab-underline chrome */
>
                    <div className="flex items-center gap-2 text-xs text-slate-400 mb-2">
                        <Link href="/" className="hover:text-sky-400 transition-colors">Trang chủ</Link>
                        <span>/</span>
                        <span className="text-sky-400 font-semibold">Trợ giúp & FAQ</span>
                    </div>
                    <h1 className="section-title-no-up flex items-center gap-2.5">
                        <span className="w-2 h-7 rounded-full bg-sky-500"></span>
                        <span>Trung Tâm Trợ Giúp & Câu Hỏi Thường Gặp</span>
                    </h1>
                    <p className="text-slate-400 text-sm mt-1">
                        Hướng dẫn trải nghiệm điện ảnh, phím tắt rạp chiếu và giải đáp thắc mắc người dùng
                    </p>
                </div>

                {/* Keyboard Shortcuts Guide Card */}
                <div className="p-6 sm:p-8 rounded-2xl bg-[#121620] border border-white/10 mb-8 space-y-4">
                    <h2 className="text-lg sm:text-xl font-bold text-white flex items-center gap-2">
                        <span className="w-2 h-2 rounded-full bg-sky-400"></span>
                        Bảng Phím Tắt Rạp Chiếu Phim
                    </h2>
                    <p className="text-xs sm:text-sm text-slate-400">
                        Sử dụng phím tắt trên bàn phím để điều khiển trình phát video mượt mà như tại rạp chiếu phim:
                    </p>
                    <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-3 pt-2">
                        <div className="p-3 rounded-xl bg-[#08090c] border border-white/10 flex items-center justify-between">
                            <span className="text-xs text-slate-300">Phát / Tạm dừng</span>
                            <kbd className="px-2.5 py-1 text-xs font-mono font-bold text-sky-400 bg-slate-900 border border-sky-500/30 rounded">Space</kbd>
                        </div>
                        <div className="p-3 rounded-xl bg-[#08090c] border border-white/10 flex items-center justify-between">
                            <span className="text-xs text-slate-300">Toàn màn hình</span>
                            <kbd className="px-2.5 py-1 text-xs font-mono font-bold text-sky-400 bg-slate-900 border border-sky-500/30 rounded">F</kbd>
                        </div>
                        <div className="p-3 rounded-xl bg-[#08090c] border border-white/10 flex items-center justify-between">
                            <span className="text-xs text-slate-300">Bật / Tắt tiếng</span>
                            <kbd className="px-2.5 py-1 text-xs font-mono font-bold text-sky-400 bg-slate-900 border border-sky-500/30 rounded">M</kbd>
                        </div>
                        <div className="p-3 rounded-xl bg-[#08090c] border border-white/10 flex items-center justify-between">
                            <span className="text-xs text-slate-300">Tua lùi 5 giây</span>
                            <kbd className="px-2.5 py-1 text-xs font-mono font-bold text-sky-400 bg-slate-900 border border-sky-500/30 rounded">←</kbd>
                        </div>
                        <div className="p-3 rounded-xl bg-[#08090c] border border-white/10 flex items-center justify-between">
                            <span className="text-xs text-slate-300">Tua tới 5 giây</span>
                            <kbd className="px-2.5 py-1 text-xs font-mono font-bold text-sky-400 bg-slate-900 border border-sky-500/30 rounded">→</kbd>
                        </div>
                        <div className="p-3 rounded-xl bg-[#08090c] border border-white/10 flex items-center justify-between">
                            <span className="text-xs text-slate-300">Chỉnh âm lượng</span>
                            <kbd className="px-2.5 py-1 text-xs font-mono font-bold text-sky-400 bg-slate-900 border border-sky-500/30 rounded">↑ / ↓</kbd>
                        </div>
                    </div>
                </div>

                {/* FAQ List */}
                <div className="space-y-4">
                    {faqs.map((item, index) => (
                        <div
                            key={index}
                            className="p-6 rounded-2xl bg-[#121620] border border-white/10 space-y-2 hover:border-sky-500/30 transition-colors"
                        >
                            <h2 className="text-base sm:text-lg font-bold text-white flex items-start gap-3">
                                <span className="text-sky-400 font-bold tabular-nums text-sm shrink-0 mt-0.5">{`${index + 1}.`}</span>
                                <span>{item.q}</span>
                            </h2>
                            <p className="text-slate-300 text-sm sm:text-base leading-relaxed pl-7">
                                {item.a}
                            </p>
                        </div>
                    ))}
                </div>

                {/* Bottom Call to Action */}
                <div className="mt-10 p-6 sm:p-8 rounded-2xl bg-[#121620] border border-white/10 text-center sm:text-left flex flex-col sm:flex-row items-center justify-between gap-4">
                    <div>
                        <h3 className="text-lg font-bold text-white">Bạn vẫn cần thêm sự trợ giúp?</h3>
                        <p className="text-xs sm:text-sm text-slate-400 mt-1">
                            Nếu gặp vấn đề kỹ thuật chưa được giải đáp, hãy gửi phản hồi ngay cho chúng tôi.
                        </p>
                    </div>
                    <Link
                        href="/lien-he"
                        className="play-button-color text-xs px-6 py-2.5 font-bold shrink-0 inline-flex items-center gap-1.5"
                    >
                        <span>Liên Hệ Hỗ Trợ</span>
                        <svg className="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M14 5l7 7m0 0l-7 7m7-7H3" />
                        </svg>
                    </Link>
                </div>
            </div>
        </div>
    );
}
