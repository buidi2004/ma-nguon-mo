import Link from "next/link";

export const metadata = {
    title: 'Chính Sách Bảo Mật & Quyền Riêng Tư | OpenFlix',
    description: 'Chính sách bảo mật thông tin, cam kết không thu thập dữ liệu cá nhân trái phép và cơ chế lưu trữ cục bộ an toàn tại OpenFlix.',
};

export default function PrivacyPolicyPage() {
    return (
        <div className="page-container-0topside">
            <div className="section-container max-w-4xl">
                {/* Breadcrumbs & Header */}
                <div className="border-b border-white/10 pb-6 mb-8" /* taste-skill-ignore: divider / tab-underline chrome */
>
                    <div className="flex items-center gap-2 text-xs text-slate-400 mb-2">
                        <Link href="/" className="hover:text-sky-400 transition-colors">Trang chủ</Link>
                        <span>/</span>
                        <span className="text-sky-400 font-semibold">Chính sách bảo mật</span>
                    </div>
                    <h1 className="section-title-no-up flex items-center gap-2.5">
                        <span className="w-2 h-7 rounded-full bg-sky-500"></span>
                        <span>Chính Sách Bảo Mật & Quyền Riêng Tư</span>
                    </h1>
                    <p className="text-slate-400 text-sm mt-1">
                        Cam kết minh bạch về dữ liệu, bảo vệ tuyệt đối sự riêng tư của người xem
                    </p>
                </div>

                <div className="space-y-6 text-slate-300 text-sm sm:text-base leading-relaxed">
                    <div className="p-6 rounded-2xl bg-[#121620] border border-white/10 space-y-3">
                        <h2 className="text-lg font-bold text-white flex items-center gap-2.5">
                            <span className="w-2 h-2 rounded-full bg-sky-400"></span>
                            Nguyên tắc quyền riêng tư hàng đầu
                        </h2>
                        <p>
                            OpenFlix được xây dựng với triết lý tôn trọng tối đa quyền riêng tư của người dùng. Chúng tôi tin rằng trải nghiệm giải trí điện ảnh đỉnh cao không nên đi kèm với việc theo dõi hay thu thập thông tin cá nhân.
                        </p>
                        <p className="text-slate-400 text-xs sm:text-sm">
                            Hệ thống hoạt động hoàn toàn ẩn danh: không bắt buộc đăng ký tài khoản, không yêu cầu họ tên, số điện thoại hay tài khoản mạng xã hội.
                        </p>
                    </div>

                    <div className="p-6 rounded-2xl bg-[#121620] border border-white/10 space-y-3">
                        <h2 className="text-lg font-bold text-white flex items-center gap-2.5">
                            <span className="w-2 h-2 rounded-full bg-sky-400"></span>
                            Dữ liệu lưu trữ cục bộ (Local Storage)
                        </h2>
                        <p>
                            Các tính năng tiện ích như <strong className="text-white">Lịch sử xem phim</strong> và <strong className="text-white">Phim đã lưu</strong> được lưu trữ 100% trong bộ nhớ trình duyệt (Local Storage) của chính thiết bị bạn đang sử dụng.
                        </p>
                        <p className="text-slate-400 text-xs sm:text-sm">
                            Dữ liệu này không bao giờ được gửi về máy chủ của chúng tôi và không ai khác có thể truy cập ngoài bạn. Bạn có thể xóa sạch toàn bộ dữ liệu này bất cứ lúc nào bằng nút &quot;Xóa tất cả&quot; trên giao diện hoặc bằng cách xóa cache trình duyệt.
                        </p>
                    </div>

                    <div className="p-6 rounded-2xl bg-[#121620] border border-white/10 space-y-3">
                        <h2 className="text-lg font-bold text-white flex items-center gap-2.5">
                            <span className="w-2 h-2 rounded-full bg-sky-400"></span>
                            Cookies & Dịch vụ bên thứ ba
                        </h2>
                        <p>
                            OpenFlix không sử dụng cookies theo dõi hành vi xuyên trang web và không cài đặt bất kỳ mã theo dõi độc hại hay mạng quảng cáo lừa đảo nào.
                        </p>
                        <p className="text-slate-400 text-xs sm:text-sm">
                            Khi sử dụng trình phát video dạng nhúng (Iframe Embed Player) từ các nhà cung cấp nguồn phát bên thứ ba, các nhà cung cấp này có thể xử lý kết nối kỹ thuật theo tiêu chuẩn streaming của họ.
                        </p>
                    </div>

                    <div className="p-6 rounded-2xl bg-[#121620] border border-white/10 space-y-3">
                        <h2 className="text-lg font-bold text-white flex items-center gap-2.5">
                            <span className="w-2 h-2 rounded-full bg-sky-400"></span>
                            Bảo mật kết nối SSL/TLS
                        </h2>
                        <p>
                            Toàn bộ lưu lượng truy cập giữa trình duyệt của bạn và hệ thống OpenFlix đều được mã hóa bằng giao thức bảo mật cao cấp HTTPS (TLS 1.3), bảo vệ bạn khỏi các cuộc tấn công trung gian hoặc can thiệp dữ liệu đường truyền.
                        </p>
                    </div>
                </div>

                <div className="mt-8 pt-6 border-t border-white/10 flex flex-wrap items-center justify-between gap-4 text-xs text-slate-400" /* taste-skill-ignore: divider / tab-underline chrome */
>
                    <div>Nếu bạn có thắc mắc về quyền riêng tư, vui lòng liên hệ ban quản trị.</div>
                    <Link href="/lien-he" className="text-sky-400 font-semibold hover:underline">
                        Gửi phản hồi bảo mật →
                    </Link>
                </div>
            </div>
        </div>
    );
}
