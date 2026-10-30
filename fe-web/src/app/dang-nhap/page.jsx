'use client'

import { useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";

export default function LoginPage() {
    const router = useRouter();
    const [email, setEmail] = useState("");
    const [password, setPassword] = useState("");
    const [remember, setRemember] = useState(true);
    const [error, setError] = useState("");
    const [loading, setLoading] = useState(false);

    const handleLogin = (e) => {
        e.preventDefault();
        setError("");
        setLoading(true);

        if (!email.trim() || password.length < 6) {
            setError("Email hoặc mật khẩu không hợp lệ. Mật khẩu phải từ 6 ký tự.");
            setLoading(false);
            return;
        }

        setTimeout(() => {
            try {
                if (typeof window !== "undefined") {
                    const userData = {
                        email: email.trim(),
                        name: email.split("@")[0] || "Thành viên",
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

    const handleDemoLogin = () => {
        setEmail("demo@openflix.vn");
        setPassword("123456");
        setError("");
        setLoading(true);
        setTimeout(() => {
            try {
                if (typeof window !== "undefined") {
                    const userData = {
                        email: "demo@openflix.vn",
                        name: "Bùi Đi (Demo)",
                        plan: "VIP 4K Ultra",
                        loggedInAt: new Date().toISOString(),
                    };
                    localStorage.setItem("openflix_user", JSON.stringify(userData));
                }
            } catch (err) {
                console.warn("[auth] localStorage error:", err);
            }
            router.push("/ho-so");
        }, 400);
    };

    return (
        <div className="min-h-[100dvh] pt-28 pb-20 bg-[#08090c] flex items-center justify-center px-4">
            <div className="w-full max-w-md p-6 sm:p-8 rounded-2xl bg-[#121620] border border-white/10 shadow-2xl" /* taste-skill-ignore: Netflix card overlay (scrim shadow), kept intentionally */
>
                <div className="text-center mb-6">
                    <span className="text-xs font-semibold text-sky-400">
                        Tài khoản thành viên
                    </span>
                    <h1 className="text-2xl sm:text-3xl font-black text-white mt-1">
                        Đăng Nhập <span className="text-sky-400">OPENFLIX</span>
                    </h1>
                    <p className="text-xs sm:text-sm text-slate-400 mt-1">
                        Đăng nhập để tiếp tục xem phim và đồng bộ hóa danh sách
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

                <form onSubmit={handleLogin} className="space-y-4">
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

                    <div>
                        <div className="flex items-center justify-between mb-1.5">
                            <label className="block text-xs font-semibold text-slate-300">
                                Mật khẩu
                            </label>
                            <Link href="/quen-mat-khau" className="text-xs text-sky-400 hover:underline">
                                Quên mật khẩu?
                            </Link>
                        </div>
                        <input
                            type="password"
                            required
                            value={password}
                            onChange={(e) => setPassword(e.target.value)}
                            placeholder="Tối thiểu 6 ký tự"
                            className="w-full px-4 py-2.5 rounded-xl bg-[#08090c] border border-white/15 focus:border-sky-400 focus:outline-none text-white text-sm placeholder:text-slate-500"
                        />
                    </div>

                    <div className="flex items-center justify-between text-xs text-slate-400 pt-1">
                        <label className="flex items-center gap-2 cursor-pointer">
                            <input
                                type="checkbox"
                                checked={remember}
                                onChange={(e) => setRemember(e.target.checked)}
                                className="w-4 h-4 rounded bg-[#08090c] border-white/20 text-sky-500 focus:ring-0 cursor-pointer"
                            />
                            <span>Ghi nhớ đăng nhập</span>
                        </label>
                    </div>

                    <button
                        type="submit"
                        disabled={loading}
                        className="play-button-color w-full py-3 text-sm font-bold flex items-center justify-center gap-2 cursor-pointer transition-transform active:scale-95 disabled:opacity-50"
                    >
                        {loading ? (
                            <span>Đang xác thực...</span>
                        ) : (
                            <>
                                <span>Đăng Nhập</span>
                                <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M14 5l7 7m0 0l-7 7m7-7H3" />
                                </svg>
                            </>
                        )}
                    </button>
                </form>

                {/* 1-Click Demo Login */}
                <div className="mt-4">
                    <button
                        type="button"
                        onClick={handleDemoLogin}
                        className="w-full py-2.5 px-4 rounded-xl bg-white/[0.06] hover:bg-sky-500/15 border border-white/10 hover:border-sky-500/30 text-xs text-sky-400 font-semibold flex items-center justify-center gap-2 transition-colors cursor-pointer"
                    >
                        <svg className="w-4 h-4 fill-current text-amber-400" viewBox="0 0 24 24">
                            <path d="M13 2L3 14h9l-1 8 10-12h-9l1-8z" />
                        </svg>
                        <span>1-Click Đăng nhập Demo (Tài khoản mẫu)</span>
                    </button>
                </div>

                <div className="mt-6 pt-6 border-t border-white/10 text-center text-xs text-slate-400" /* taste-skill-ignore: divider / tab-underline chrome */
>
                    Chưa có tài khoản OpenFlix?{" "}
                    <Link href="/dang-ky" className="text-sky-400 font-semibold hover:underline">
                        Đăng ký ngay miễn phí
                    </Link>
                </div>
            </div>
        </div>
    );
}
