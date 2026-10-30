import Link from "next/link";
import Image from "next/image";

export const metadata = {
    title: 'Giới thiệu & Công nghệ | OpenFlix',
    description: 'Giới thiệu về nền tảng OpenFlix Cinema Web - Công nghệ Next.js, PocketBase VPS Engine và thiết kế chuẩn Netflix.',
};

export default function Page() {
    return (
        <div className="min-h-[100dvh] pt-28 pb-20 bg-[#08090c] text-slate-300">
            {/* Ambient Lighting Background */}
            <div className="fixed top-24 left-1/2 -translate-x-1/2 w-[700px] h-[350px] bg-sky-500/10 blur-[130px] -z-10 pointer-events-none rounded-full" />

            <div className="max-w-5xl mx-auto px-4 sm:px-6 space-y-12">
                {/* Hero Header */}
                <div className="text-center space-y-4">
                    <span className="inline-block px-3.5 py-1 text-xs font-semibold text-sky-400 bg-sky-500/10 border border-sky-500/20 rounded-full">
                        Dự Án Điện Ảnh Mã Nguồn Mở
                    </span>
                    <h1 className="text-3xl sm:text-4xl md:text-5xl font-black text-white tracking-tight">
                        Giới Thiệu <span className="text-sky-400">OPENFLIX</span>
                    </h1>
                    <p className="max-w-2xl mx-auto text-slate-400 text-sm sm:text-base leading-relaxed">
                        Nền tảng xem phim trực tuyến hiện đại, mượt mà chuẩn phong cách điện ảnh cao cấp với tốc độ streaming tối ưu và nguồn dữ liệu phong phú.
                    </p>
                    <div className="inline-flex items-center gap-2.5 px-4 py-2 rounded-xl bg-white/[0.04] border border-white/10 text-sm">
                        <span className="text-slate-400">Sinh viên thực hiện:</span>
                        <span className="text-white font-bold">Bùi Văn Dĩ</span>
                        <span className="text-slate-500">•</span>
                        <span className="text-sky-400 font-mono font-semibold">MSSV: 0023414259</span>
                    </div>
                </div>

                {/* Section 1: Overview Card */}
                <div className="p-6 sm:p-8 rounded-2xl bg-[#121620] border border-white/10 space-y-6">
                    <h2 className="text-xl sm:text-2xl font-bold text-white flex items-center gap-2.5">
                        <span className="w-2 h-5 rounded-full bg-sky-500"></span> Trải Nghiệm Xem Phim Chuẩn Rạp
                    </h2>
                    <p className="text-slate-300 leading-relaxed text-sm sm:text-base">
                        OpenFlix được thiết kế và tối ưu nhằm mang lại trải nghiệm rạp chiếu phim tại gia đẳng cấp nhất. Toàn bộ giao diện được xây dựng với tông màu Đen Cinema thuần khiết (<code className="text-sky-400 bg-slate-900 px-2 py-0.5 rounded">#08090c</code>) kết hợp cùng ánh sáng xanh da trời Sky Blue (<code className="text-sky-400 bg-slate-900 px-2 py-0.5 rounded">#0ea5e9</code>).
                    </p>
                    <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 pt-2">
                        <div className="p-4 rounded-xl bg-white/[0.04] border border-white/10">
                            <h3 className="font-bold text-white text-sm mb-1 text-sky-400">Tốc Độ Siêu Tốc</h3>
                            <p className="text-xs text-slate-400">Stream đa luồng, hỗ trợ cả HLS/m3u8, MP4 trực tiếp và Embed player chống giật lag.</p>
                        </div>
                        <div className="p-4 rounded-xl bg-white/[0.04] border border-white/10">
                            <h3 className="font-bold text-white text-sm mb-1 text-sky-400">Giao Diện Tinh Tế</h3>
                            <p className="text-xs text-slate-400">Hệ thống thành phần UI tối giản, độ tương phản cao và hiệu ứng chuyển động mượt mà.</p>
                        </div>
                        <div className="p-4 rounded-xl bg-white/[0.04] border border-white/10">
                            <h3 className="font-bold text-white text-sm mb-1 text-sky-400">Đầy Đủ Tính Năng</h3>
                            <p className="text-xs text-slate-400">Bộ lọc thông minh theo Thể loại, Quốc gia, Năm phát hành, Lịch sử xem và Phim đã lưu.</p>
                        </div>
                    </div>
                </div>

                {/* Section 2: Architecture & Tech Stack */}
                <div className="p-6 sm:p-8 rounded-2xl bg-[#121620] border border-white/10 space-y-6">
                    <h2 className="text-xl sm:text-2xl font-bold text-white flex items-center gap-2.5">
                        <span className="w-2 h-5 rounded-full bg-cyan-400"></span> Kiến Trúc & Công Nghệ
                    </h2>
                    
                    <div className="grid grid-cols-1 sm:grid-cols-2 gap-6 text-sm">
                        <div className="space-y-3">
                            <h3 className="text-white font-bold flex items-center gap-2">
                                <span className="w-2 h-2 rounded-full bg-sky-400" /> Frontend Framework
                            </h3>
                            <ul className="space-y-1.5 text-slate-300 pl-4 list-disc">
                                <li><strong>Next.js 13 App Router:</strong> Server-side rendering (SSR), dynamic streaming và bundle code-splitting.</li>
                                <li><strong>React 18 & Tailwind CSS:</strong> Giao diện responsive linh hoạt từ mobile đến màn hình desktop lớn.</li>
                                <li><strong>React Player (Dynamic):</strong> Tải động client-side giảm 65% kích thước bundle trang xem phim.</li>
                            </ul>
                        </div>

                        <div className="space-y-3">
                            <h3 className="text-white font-bold flex items-center gap-2">
                                <span className="w-2 h-2 rounded-full bg-cyan-400" /> Backend & Database Engine
                            </h3>
                            <ul className="space-y-1.5 text-slate-300 pl-4 list-disc">
                                <li><strong>PocketBase VPS Engine:</strong> Lưu trữ dữ liệu phim tập trung, realtime subscription và phân trang tự động.</li>
                                <li><strong>High-performance Filtering:</strong> Lọc đa tiêu chí kết hợp category, cast, director, release_year.</li>
                                <li><strong>Local Persistence:</strong> Lưu tự động lịch sử xem phim và danh sách yêu thích trực tiếp trên trình duyệt.</li>
                            </ul>
                        </div>
                    </div>
                </div>

                {/* Section 3: DMCA & Copyright */}
                <div className="p-6 sm:p-8 rounded-2xl bg-[#121620] border border-white/10 space-y-4">
                    <h2 className="text-xl sm:text-2xl font-bold text-white flex items-center gap-2.5">
                        <span className="w-2 h-5 rounded-full bg-amber-400"></span> Bản Quyền & Tuyên Bố Miễn Trừ
                    </h2>
                    <p className="text-slate-400 text-sm leading-relaxed">
                        OpenFlix là dự án mã nguồn mở phục vụ mục đích học tập, nghiên cứu kỹ thuật và trải nghiệm người dùng. Tất cả các nội dung video được nhúng và liên kết từ các dịch vụ chia sẻ video công cộng bên thứ ba. Để biết thêm chi tiết về chính sách DMCA và xử lý bản quyền, vui lòng tham khảo trang <Link href="/dieu-khoan" className="text-sky-400 font-semibold hover:underline">Điều Khoản & DMCA</Link>.
                    </p>
                    <div className="pt-2 flex flex-wrap gap-4">
                        <Link
                            href="/loc-phim"
                            className="inline-flex items-center gap-2 px-5 py-2.5 rounded-xl bg-sky-500 hover:bg-sky-400 text-slate-950 font-bold text-sm transition-colors duration-200"
                        >
                            Khám Phá Bộ Lọc Phim
                        </Link>
                        <Link
                            href="/dieu-khoan"
                            className="inline-flex items-center gap-2 px-5 py-2.5 rounded-xl bg-white/[0.08] hover:bg-white/[0.15] text-white font-semibold text-sm border border-white/15 transition-colors duration-200"
                        >
                            Xem Chi Tiết Điều Khoản
                        </Link>
                    </div>
                </div>
            </div>
        </div>
    );
}
