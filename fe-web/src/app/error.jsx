'use client'

import { useEffect } from 'react';
import Link from 'next/link';

export default function Error({ error, reset }) {
    useEffect(() => {
        console.error('[OpenFlix Runtime Error]:', error);
    }, [error]);

    return (
        <div className="min-h-[100dvh] bg-[#08090c] flex items-center justify-center px-4 py-24">
            <div className="max-w-md w-full text-center p-8 rounded-2xl bg-[#121620] border border-white/10">
                <div className="w-16 h-16 mx-auto mb-6 rounded-xl bg-red-500/10 border border-red-500/30 flex items-center justify-center text-red-400">
                    <svg className="w-8 h-8 fill-none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"/></svg>
                </div>

                <span className="text-red-400 font-bold text-sm">Đã có lỗi xảy ra</span>
                <h1 className="text-white text-2xl sm:text-3xl font-extrabold mt-2 mb-3">
                    Không Thể Tải Dữ Liệu
                </h1>

                <p className="text-slate-400 text-sm leading-relaxed mb-6">
                    Hệ thống không thể tải dữ liệu từ máy chủ. Vui lòng kiểm tra lại kết nối mạng hoặc thử tải lại trang.
                </p>

                <div className="flex flex-col sm:flex-row items-center justify-center gap-3">
                    <button
                        onClick={() => reset()}
                        className="play-button-color w-full sm:w-auto px-6 py-3 text-sm font-semibold flex items-center justify-center gap-2 cursor-pointer"
                    >
                        <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
                        </svg>
                        Thử Lại Ngay
                    </button>

                    <Link
                        href="/"
                        className="add-button-color w-full sm:w-auto px-6 py-3 text-sm font-medium flex items-center justify-center gap-2"
                    >
                        Trang Chủ
                    </Link>
                </div>
            </div>
        </div>
    );
}
