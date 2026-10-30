import Link from "next/link";

export const metadata = {
    title: 'Điều Khoản Dịch Vụ & Bản Quyền DMCA | OpenFlix',
    description: 'Chính sách bản quyền, tuyên bố miễn trừ trách nhiệm mã nguồn mở và điều khoản sử dụng nền tảng OpenFlix.',
};

export default function TermsPage() {
    return (
        <div className="page-container-0topside">
            <div className="section-container max-w-4xl">
                <div className="border-b border-white/10 pb-6 mb-8" /* taste-skill-ignore: divider / tab-underline chrome */
>
                    <div className="flex items-center gap-2 text-xs text-slate-400 mb-2">
                        <Link href="/" className="hover:text-sky-400 transition-colors">Trang chủ</Link>
                        <span>/</span>
                        <span className="text-sky-400 font-semibold">Điều khoản dịch vụ</span>
                    </div>
                    <h1 className="section-title-no-up flex items-center gap-2.5">
                        <span className="w-2 h-7 rounded-full bg-sky-500"></span>
                        <span>Điều Khoản Sử Dụng & Bản Quyền DMCA</span>
                    </h1>
                    <p className="text-slate-400 text-sm mt-1">
                        Cập nhật lần cuối: Tháng 10, 2026 · Phiên bản OpenFlix 2.0
                    </p>
                </div>

                <div className="space-y-8 text-slate-300 text-sm sm:text-base leading-relaxed">
                    {/* Section 1 */}
                    <div className="p-6 rounded-2xl bg-[#121620] border border-white/10">
                        <h2 className="text-white font-bold text-lg mb-3 flex items-center gap-2">
                            <span className="text-sky-400">1.</span>
                            Tuyên bố miễn trừ trách nhiệm (Disclaimer)
                        </h2>
                        <p>
                            OpenFlix là một dự án nghiên cứu công nghệ mã nguồn mở (Open-source project) phục vụ mục đích học thuật, trải nghiệm giao diện người dùng trực tuyến mô phỏng rạp chiếu phim hiện đại.
                        </p>
                        <p className="mt-2 text-slate-400 text-xs sm:text-sm">
                            Hệ thống không lưu trữ bất kỳ tệp video vi phạm bản quyền nào trên máy chủ lưu trữ cục bộ. Toàn bộ nội dung video và dữ liệu liên kết được tổng hợp tự động từ các nguồn chia sẻ miễn phí công khai trên Internet.
                        </p>
                    </div>

                    {/* Section 2 */}
                    <div className="p-6 rounded-2xl bg-[#121620] border border-white/10">
                        <h2 className="text-white font-bold text-lg mb-3 flex items-center gap-2">
                            <span className="text-sky-400">2.</span>
                            Chính sách bản quyền kỹ thuật số (DMCA Policy)
                        </h2>
                        <p>
                            OpenFlix tuyệt đối tôn trọng quyền sở hữu trí tuệ của các nghệ sĩ, nhà sản xuất và các tổ chức nắm giữ bản quyền điện ảnh. Chúng tôi tuân thủ chặt chẽ Đạo luật Bản quyền Kỹ thuật số Thiên niên kỷ (DMCA).
                        </p>
                        <p className="mt-2 text-slate-400 text-xs sm:text-sm">
                            Nếu bạn là chủ sở hữu bản quyền hợp pháp hoặc đại diện được ủy quyền và tin rằng bất kỳ liên kết nội dung nào hiển thị trên hệ thống ảnh hưởng đến quyền sở hữu của bạn, vui lòng liên hệ trực tiếp với chúng tôi. Chúng tôi cam kết gỡ bỏ liên kết trong vòng 24 - 48 giờ làm việc sau khi nhận được thông báo xác thực.
                        </p>
                    </div>

                    {/* Section 3 */}
                    <div className="p-6 rounded-2xl bg-[#121620] border border-white/10">
                        <h2 className="text-white font-bold text-lg mb-3 flex items-center gap-2">
                            <span className="text-sky-400">3.</span>
                            Quyền riêng tư & Lưu trữ cục bộ (Privacy & Local Storage)
                        </h2>
                        <p>
                            Nền tảng OpenFlix không yêu cầu đăng ký tài khoản bắt buộc, không thu thập thông tin danh tính cá nhân và không cài cắm cookie theo dõi thương mại.
                        </p>
                        <p className="mt-2 text-slate-400 text-xs sm:text-sm">
                            Các tính năng như <strong>"Danh sách phim đã lưu"</strong> và <strong>"Lịch sử xem phim"</strong> được xử lý và lưu trữ hoàn toàn cục bộ trên trình duyệt của chính bạn (HTML5 LocalStorage). Bạn có toàn quyền xóa dữ liệu này bất cứ lúc nào thông qua nút "Xóa lịch sử" trên trang tương ứng.
                        </p>
                    </div>

                    {/* Section 4 */}
                    <div className="p-6 rounded-2xl bg-[#121620] border border-white/10">
                        <h2 className="text-white font-bold text-lg mb-3 flex items-center gap-2">
                            <span className="text-sky-400">4.</span>
                            Quy tắc ứng xử & Trách nhiệm người dùng
                        </h2>
                        <ul className="list-disc list-inside space-y-1.5 text-slate-400 text-xs sm:text-sm">
                            <li>Không sử dụng công cụ tự động (bot/crawler) gây quá tải hạ tầng mạng và máy chủ PocketBase VPS.</li>
                            <li>Không khai thác các lỗ hổng bảo mật nhằm mục đích trục lợi cá nhân hoặc phá hoại dịch vụ.</li>
                            <li>Tôn trọng sản phẩm trí tuệ và tinh thần mã nguồn mở của cộng đồng lập trình viên.</li>
                        </ul>
                    </div>
                </div>

                <div className="mt-10 text-center">
                    <Link
                        href="/"
                        className="play-button-color px-8 py-3 text-sm inline-flex items-center gap-2"
                    >
                        Quay Về Trang Chủ
                    </Link>
                </div>
            </div>
        </div>
    );
}

