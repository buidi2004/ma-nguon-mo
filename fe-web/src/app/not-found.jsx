import Link from "next/link";

export const metadata = {
    title: '404 - Không tìm thấy trang | OpenFlix',
};

export default function NotFound() {
    return (
        <div className="min-h-[100dvh] bg-[#08090c] flex items-center justify-center px-4 py-24">
            <div className="max-w-md w-full text-center p-8 rounded-2xl bg-[#121620] border border-white/10">
                <div className="w-16 h-16 mx-auto mb-6 rounded-xl bg-sky-500/10 border border-sky-400/30 flex items-center justify-center text-sky-400">
                    <svg className="w-8 h-8 fill-current" viewBox="0 0 24 24"><path d="M18 4l2 4h-3l-2-4h-2l2 4h-3l-2-4H8l2 4H7L5 4H4c-1.1 0-1.99.9-1.99 2L2 18c0 1.1.9 2 2 2h16c1.1 0 2-.9 2-2V4h-4z"/></svg>
                </div>

                <span className="text-sky-400 font-bold text-sm">Lỗi 404</span>
                <h1 className="text-white text-3xl font-black mt-2 mb-3">Không Tìm Thấy Trang</h1>

                <p className="text-slate-400 text-sm leading-relaxed mb-8">
                    Đường dẫn bạn yêu cầu không tồn tại hoặc đã được chuyển sang địa chỉ khác. Hãy quay về trang chủ hoặc tìm kiếm phim yêu thích.
                </p>

                <div className="flex flex-col sm:flex-row items-center justify-center gap-3">
                    <Link
                        href="/"
                        className="play-button-color w-full sm:w-auto px-6 py-3 text-sm font-semibold flex items-center justify-center gap-2"
                    >
                        <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" />
                        </svg>
                        Về Trang Chủ
                    </Link>

                    <Link
                        href="/the-loai"
                        className="add-button-color w-full sm:w-auto px-6 py-3 text-sm font-medium flex items-center justify-center gap-2"
                    >
                        Khám Phá Thể Loại
                    </Link>
                </div>
            </div>
        </div>
    );
}
