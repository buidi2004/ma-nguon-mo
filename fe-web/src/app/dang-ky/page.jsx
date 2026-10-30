'use client'

import { useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";

export default function RegisterPage() {
    const router = useRouter();
    const [name, setName] = useState("");
    const [email, setEmail] = useState("");
    const [password, setPassword] = useState("");
    const [confirmPassword, setConfirmPassword] = useState("");
    const [agree, setAgree] = useState(true);
    const [error, setError] = useState("");
    const [loading, setLoading] = useState(false);

    const handleRegister = (e) => {
        e.preventDefault();
        setError("");

        if (!name.trim()) {
            setError("Vui lòng nhập họ và tên của bạn.");
            return;
        }
        if (!email.trim() || !email.includes("@")) {
            setError("Vui lòng nhập địa chỉ email hợp lệ.");
            return;
        }
        if (password.length < 6) {
            setError("Mật khẩu phải chứa ít nhất 6 ký tự.");
            return;
        }
        if (password !== confirmPassword) {
            setError("Mật khẩu xác nhận không trùng khớp.");
            return;
        }
        if (!agree) {
            setError("Vui lòng đồng ý với Điều khoản dịch vụ và Chính sách bản quyền DMCA.");
            return;
        }

        setLoading(true);
        setTimeout(() => {
            try {
                if (typeof window !== "undefined") {
                    const userData = {
                        name: name.trim(),
                        email: email.trim(),
                        plan: "VIP 4K Ultra",
                        loggedInAt: new Date().toISOString(),
                    };
                    localStorage.setItem("openflix_user", JSON.stringify(userData));
                }
            } catch (err) {
                console.warn("[auth] localStorage error:", err);
            }
            router.push("/ho-so");
        }, 500);
    };

    return (
        <div className="min-h-[100dvh] pt-28 pb-20 bg-[#08090c] flex items-center justify-center px-4">
            <div className="w-full max-w-md p-6 sm:p-8 rounded-2xl bg-[#121620] border border-white/10 shadow-2xl" /* taste-skill-ignore: Netflix card overlay (scrim shadow), kept intentionally */
>
                <div className="text-center mb-6">
                    <span className="text-xs font-semibold text-sky-400">
                        Tạo tài khoản mới
                    </span>
                    <h1 className="text-2xl sm:text-3xl font-black text-white mt-1">
                        Tham Gia <span className="text-sky-400">OPENFLIX</span>
                    </h1>
                    <p className="text-xs sm:text-sm text-slate-400 mt-1">
                        Trải nghiệm xem phim chất lượng 4K & đồng bộ danh sách không giới hạn
                    </p>
                </div>

                {error && (
                    <div className="p-3 mb-5 rounded-xl bg-red-500/15 border border-red-500/30 text-xs text-red-300 flex items-center gap-2">
                        <svg className="w-4 h-4 text-red-400 shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
                        </svg>
                        <span>{error}</span>
                    </div>
                )}

                <form onSubmit={handleRegister} className="space-y-4">
                    <div>
                        <label className="block text-xs font-semibold text-slate-300 mb-1.5">
                            Họ và tên
                        </label>
                        <input
                            type="text"
                            required
                            value={name}
                            onChange={(e) => setName(e.target.value)}
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
                            required
                            value={email}
                            onChange={(e) => setEmail(e.target.value)}
                            placeholder="nhanphanhoi@gmail.com"
                            className="w-full px-4 py-2.5 rounded-xl bg-[#08090c] border border-white/15 focus:border-sky-400 focus:outline-none text-white text-sm placeholder:text-slate-500"
                        />
                    </div>

                    <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                        <div>
                            <label className="block text-xs font-semibold text-slate-300 mb-1.5">
                                Mật khẩu
                            </label>
                            <input
                                type="password"
                                required
                                value={password}
                                onChange={(e) => setPassword(e.target.value)}
                                placeholder="Tối thiểu 6 ký tự"
                                className="w-full px-4 py-2.5 rounded-xl bg-[#08090c] border border-white/15 focus:border-sky-400 focus:outline-none text-white text-sm placeholder:text-slate-500"
                            />
                        </div>
                        <div>
                            <label className="block text-xs font-semibold text-slate-300 mb-1.5">
                                Xác nhận
                            </label>
                            <input
                                type="password"
                                required
                                value={confirmPassword}
                                onChange={(e) => setConfirmPassword(e.target.value)}
                                placeholder="Nhập lại mật khẩu"
                                className="w-full px-4 py-2.5 rounded-xl bg-[#08090c] border border-white/15 focus:border-sky-400 focus:outline-none text-white text-sm placeholder:text-slate-500"
                            />
                        </div>
                    </div>

                    <div className="text-xs text-slate-400 pt-1">
                        <label className="flex items-start gap-2 cursor-pointer">
                            <input
                                type="checkbox"
                                checked={agree}
                                onChange={(e) => setAgree(e.target.checked)}
                                className="w-4 h-4 mt-0.5 rounded bg-[#08090c] border-white/20 text-sky-500 focus:ring-0 cursor-pointer"
                            />
                            <span>
                                Tôi đồng ý với{" "}
                                <Link href="/dieu-khoan" className="text-sky-400 hover:underline">
                                    Điều khoản dịch vụ & DMCA
                                </Link>{" "}
                                và{" "}
                                <Link href="/chinh-sach-bao-mat" className="text-sky-400 hover:underline">
                                    Chính sách bảo mật
                                </Link>
                            </span>
                        </label>
                    </div>

                    <button
                        type="submit"
                        disabled={loading}
                        className="play-button-color w-full py-3 text-sm font-bold flex items-center justify-center gap-2 cursor-pointer transition-transform active:scale-95 disabled:opacity-50"
                    >
                        {loading ? (
                            <span>Đang khởi tạo tài khoản...</span>
                        ) : (
                            <>
                                <span>Tạo Tài Khoản Ngay</span>
                                <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M14 5l7 7m0 0l-7 7m7-7H3" />
                                </svg>
                            </>
                        )}
                    </button>
                </form>

                <div className="mt-6 pt-6 border-t border-white/10 text-center text-xs text-slate-400" /* taste-skill-ignore: divider / tab-underline chrome */
>
                    Đã có tài khoản OpenFlix?{" "}
                    <Link href="/dang-nhap" className="text-sky-400 font-semibold hover:underline">
                        Đăng nhập ngay
                    </Link>
                </div>
            </div>
        </div>
    );
}
