'use client'

import { useState } from "react";
import Link from "next/link";

export default function ForgotPasswordPage() {
    const [email, setEmail] = useState("");
    const [sent, setSent] = useState(false);
    const [loading, setLoading] = useState(false);

    const handleSubmit = (e) => {
        e.preventDefault();
        if (!email.trim() || !email.includes("@")) return;

        setLoading(true);
        setTimeout(() => {
            setLoading(false);
            setSent(true);
        }, 500);
    };

    return (
        <div className="min-h-[100dvh] pt-28 pb-20 bg-[#08090c] flex items-center justify-center px-4">
            <div className="w-full max-w-md p-6 sm:p-8 rounded-2xl bg-[#121620] border border-white/10 shadow-2xl" /* taste-skill-ignore: Netflix card overlay (scrim shadow), kept intentionally */
>
                <div className="text-center mb-6">
                    <span className="text-xs font-semibold text-sky-400">
                        Khôi phục tài khoản
                    </span>
                    <h1 className="text-2xl sm:text-3xl font-black text-white mt-1">
                        Quên Mật Khẩu?
                    </h1>
                    <p className="text-xs sm:text-sm text-slate-400 mt-1">
                        Nhập địa chỉ email đăng ký để nhận liên kết đặt lại mật khẩu mới
                    </p>
                </div>

                {sent ? (
                    <div className="p-6 rounded-xl bg-sky-500/10 border border-sky-500/20 text-center space-y-3">
                        <div className="w-12 h-12 mx-auto rounded-full bg-sky-500/20 flex items-center justify-center text-sky-400">
                            <svg className="w-6 h-6 fill-none" stroke="currentColor" viewBox="0 0 24 24">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
                            </svg>
                        </div>
                        <h3 className="text-lg font-bold text-white">Đã gửi liên kết khôi phục!</h3>
                        <p className="text-xs sm:text-sm text-slate-300">
                            Chúng tôi đã gửi hướng dẫn đặt lại mật khẩu đến <strong className="text-sky-400">{email}</strong>. Vui lòng kiểm tra hộp thư đến (hoặc thư rác).
                        </p>
                        <div className="pt-2">
                            <Link href="/dang-nhap" className="play-button-color text-xs px-5 py-2 font-semibold inline-flex items-center gap-1.5">
                                Quay Lại Đăng Nhập
                            </Link>
                        </div>
                    </div>
                ) : (
                    <form onSubmit={handleSubmit} className="space-y-4">
                        <div>
                            <label className="block text-xs font-semibold text-slate-300 mb-1.5">
                                Địa chỉ Email đã đăng ký
                            </label>
                            <input
                                type="email"
                                required
                                value={email}
                                onChange={(e) => setEmail(e.target.value)}
                                placeholder="nhanphanhoi@gmail.com"
                                className="w-full px-4 py-2.5 rounded-xl bg-[#08090c] border border-white/15 focus:border-sky-400 focus:outline-none text-white text-sm placeholder:text-slate-500"
                            />
                        </div>

                        <button
                            type="submit"
                            disabled={loading}
                            className="play-button-color w-full py-3 text-sm font-bold flex items-center justify-center gap-2 cursor-pointer transition-transform active:scale-95 disabled:opacity-50"
                        >
                            {loading ? (
                                <span>Đang xử lý yêu cầu...</span>
                            ) : (
                                <span>Gửi Liên Kết Đặt Lại Mật Khẩu</span>
                            )}
                        </button>
                    </form>
                )}

                <div className="mt-6 pt-6 border-t border-white/10 text-center text-xs text-slate-400" /* taste-skill-ignore: divider / tab-underline chrome */
>
                    Nhớ mật khẩu của bạn?{" "}
                    <Link href="/dang-nhap" className="text-sky-400 font-semibold hover:underline">
                        Quay lại đăng nhập
                    </Link>
                </div>
            </div>
        </div>
    );
}
