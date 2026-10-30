'use client'

import { useState } from "react";
import Link from "next/link";

export default function ContactPage() {
    const [status, setStatus] = useState(null);
    const [formData, setFormData] = useState({
        name: "",
        email: "",
        topic: "bao-loi",
        message: "",
    });

    const handleSubmit = (e) => {
        e.preventDefault();
        if (!formData.name.trim() || !formData.message.trim()) {
            return;
        }
        setStatus("success");
    };

    return (
        <div className="page-container-0topside">
            <div className="section-container max-w-5xl">
                {/* Breadcrumbs & Header */}
                <div className="border-b border-white/10 pb-6 mb-8" /* taste-skill-ignore: divider / tab-underline chrome */
>
                    <div className="flex items-center gap-2 text-xs text-slate-400 mb-2">
                        <Link href="/" className="hover:text-sky-400 transition-colors">Trang chủ</Link>
                        <span>/</span>
                        <span className="text-sky-400 font-semibold">Liên hệ & Báo lỗi</span>
                    </div>
                    <h1 className="section-title-no-up flex items-center gap-2.5">
                        <span className="w-2 h-7 rounded-full bg-sky-500"></span>
                        <span>Trung Tâm Liên Hệ & Báo Lỗi Phim</span>
                    </h1>
                    <p className="text-slate-400 text-sm mt-1">
                        Gửi phản hồi về liên kết hỏng, chất lượng video hoặc yêu cầu phim mới cho đội ngũ OpenFlix
                    </p>
                </div>

                <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
                    {/* Left: Contact Form */}
                    <div className="lg:col-span-2 p-6 sm:p-8 rounded-2xl bg-[#121620] border border-white/10">
                        <h2 className="text-xl font-bold text-white mb-2">Gửi Tin Nhắn Cho Chúng Tôi</h2>
                        <p className="text-sm text-slate-400 mb-6">
                            Mọi thắc mắc và đóng góp của bạn đều giúp cộng đồng OpenFlix ngày một hoàn thiện hơn.
                        </p>

                        {status === "success" ? (
                            <div className="p-6 rounded-xl bg-sky-500/10 border border-sky-500/20 text-center space-y-3">
                                <div className="w-12 h-12 mx-auto rounded-full bg-sky-500/20 flex items-center justify-center text-sky-400">
                                    <svg className="w-6 h-6 fill-none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M5 13l4 4L19 7" />
                                    </svg>
                                </div>
                                <h3 className="text-lg font-bold text-white">Gửi phản hồi thành công!</h3>
                                <p className="text-sm text-slate-300 max-w-md mx-auto">
                                    Cảm ơn bạn đã phản hồi. Đội ngũ kỹ thuật sẽ tiếp nhận và xử lý sự cố trong thời gian sớm nhất.
                                </p>
                                <button
                                    type="button"
                                    onClick={() => {
                                        setStatus(null);
                                        setFormData({ name: "", email: "", topic: "bao-loi", message: "" });
                                    }}
                                    className="play-button-color text-xs px-5 py-2 font-semibold inline-flex items-center gap-1.5 cursor-pointer mt-2"
                                >
                                    Gửi phản hồi khác
                                </button>
                            </div>
                        ) : (
                            <form onSubmit={handleSubmit} className="space-y-4">
                                <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                                    <div>
                                        <label className="block text-xs font-semibold text-slate-300 mb-1.5">
                                            Họ và tên <span className="text-sky-400">*</span>
                                        </label>
                                        <input
                                            type="text"
                                            required
                                            value={formData.name}
                                            onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                                            placeholder="Nhập họ và tên của bạn"
                                            className="w-full px-4 py-2.5 rounded-xl bg-[#08090c] border border-white/15 focus:border-sky-400 focus:outline-none text-white text-sm placeholder:text-slate-500"
                                        />
                                    </div>
                                    <div>
                                        <label className="block text-xs font-semibold text-slate-300 mb-1.5">
                                            Địa chỉ Email
                                        </label>
                                        <input
                                            type="email"
                                            value={formData.email}
                                            onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                                            placeholder="nhanphanhoi@gmail.com"
                                            className="w-full px-4 py-2.5 rounded-xl bg-[#08090c] border border-white/15 focus:border-sky-400 focus:outline-none text-white text-sm placeholder:text-slate-500"
                                        />
                                    </div>
                                </div>

                                <div>
                                    <label className="block text-xs font-semibold text-slate-300 mb-1.5">
                                        Chủ đề liên hệ
                                    </label>
                                    <select
                                        value={formData.topic}
                                        onChange={(e) => setFormData({ ...formData, topic: e.target.value })}
                                        className="w-full px-4 py-2.5 rounded-xl bg-[#08090c] border border-white/15 focus:border-sky-400 focus:outline-none text-white text-sm cursor-pointer"
                                    >
                                        <option value="bao-loi">Báo lỗi link phim / Không xem được</option>
                                        <option value="yeu-cau">Yêu cầu bổ sung phim mới / Tập mới</option>
                                        <option value="gop-y">Đóng góp ý kiến cải thiện giao diện</option>
                                        <option value="dmca">Liên hệ bản quyền DMCA</option>
                                        <option value="khac">Vấn đề khác</option>
                                    </select>
                                </div>

                                <div>
                                    <label className="block text-xs font-semibold text-slate-300 mb-1.5">
                                        Nội dung chi tiết <span className="text-sky-400">*</span>
                                    </label>
                                    <textarea
                                        required
                                        rows={5}
                                        value={formData.message}
                                        onChange={(e) => setFormData({ ...formData, message: e.target.value })}
                                        placeholder="Mô tả cụ thể tên bộ phim, tập phim bị sự cố hoặc góp ý của bạn..."
                                        className="w-full px-4 py-2.5 rounded-xl bg-[#08090c] border border-white/15 focus:border-sky-400 focus:outline-none text-white text-sm placeholder:text-slate-500 resize-none"
                                    ></textarea>
                                </div>

                                <button
                                    type="submit"
                                    className="play-button-color text-sm px-7 py-3 font-bold inline-flex items-center gap-2 cursor-pointer hover:scale-[1.02] active:scale-95 transition-transform"
                                >
                                    <svg className="w-4 h-4 fill-none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 19l9 2-9-18-9 18 9-2zm0 0v-8" />
                                    </svg>
                                    <span>Gửi Phản Hồi Ngay</span>
                                </button>
                            </form>
                        )}
                    </div>

                    {/* Right: Quick Channel Cards */}
                    <div className="space-y-4">
                        <div className="p-6 rounded-2xl bg-[#121620] border border-white/10 space-y-3">
                            <h3 className="font-bold text-white text-base flex items-center gap-2">
                                <span className="w-2 h-2 rounded-full bg-emerald-400"></span>
                                Báo Lỗi Nhanh
                            </h3>
                            <p className="text-xs text-slate-400 leading-relaxed">
                                Để báo lỗi tập phim nhanh nhất, bạn có thể kèm đường link chi tiết của phim để ban quản trị kiểm tra nguồn phát VPS và cập nhật link stream thay thế.
                            </p>
                        </div>

                        <div className="p-6 rounded-2xl bg-[#121620] border border-white/10 space-y-3">
                            <h3 className="font-bold text-white text-base flex items-center gap-2">
                                <span className="w-2 h-2 rounded-full bg-sky-400"></span>
                                Dự Án Mã Nguồn Mở
                            </h3>
                            <p className="text-xs text-slate-400 leading-relaxed">
                                OpenFlix là phần mềm mã nguồn mở. Mọi nhà phát triển đều có thể đóng góp tính năng, báo cáo lỗi kỹ thuật (Issue) hoặc gửi Pull Request trên kho lưu trữ.
                            </p>
                            <a
                                href="https://github.com"
                                target="_blank"
                                rel="noopener noreferrer"
                                className="inline-flex items-center gap-1.5 text-xs text-sky-400 font-semibold hover:underline pt-1"
                            >
                                <span>Xem kho mã nguồn GitHub</span>
                                <svg className="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14" />
                                </svg>
                            </a>
                        </div>

                        <div className="p-6 rounded-2xl bg-[#121620] border border-white/10 space-y-3">
                            <h3 className="font-bold text-white text-base flex items-center gap-2">
                                <span className="w-2 h-2 rounded-full bg-cyan-400"></span>
                                Bản Quyền DMCA
                            </h3>
                            <p className="text-xs text-slate-400 leading-relaxed">
                                Đọc thêm tuyên bố miễn trừ trách nhiệm và quy trình tiếp nhận xử lý khiếu nại bản quyền tại trang Điều khoản.
                            </p>
                            <Link
                                href="/dieu-khoan"
                                className="inline-flex items-center gap-1 text-xs text-sky-400 font-semibold hover:underline"
                            >
                                <span>Xem chính sách DMCA →</span>
                            </Link>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    );
}
