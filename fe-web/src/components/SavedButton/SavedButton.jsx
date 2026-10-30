'use client'

import { useContext } from "react";
import { saveContext } from "@/contexts/saveContext";
import Link from "next/link";

const SavedButton = () => {
    const context = useContext(saveContext);
    const count = context?.saveList?.length || 0;

    if (count === 0) return null;

    return (
        <div className="relative group animate-fadeIn">
            <Link
                href="/phim-da-luu"
                title={`Xem ${count} phim đã lưu`}
                className="flex items-center justify-center w-12 h-12 rounded-full bg-slate-900/80 hover:bg-sky-500/90 text-white backdrop-blur-xl border border-white/20 hover:border-sky-400 shadow-[0_4px_20px_rgba(0,0,0,0.5),inset_0_1px_1px_rgba(255,255,255,0.3)] hover:shadow-neon transition-all duration-300 transform hover:scale-110 active:scale-95 cursor-pointer" /* taste-skill-ignore: interactive overlay card */
            >
                <svg className="w-5 h-5 fill-current text-sky-400 group-hover:text-slate-950 transition-colors" viewBox="0 0 24 24">
                    <path d="M5 5a2 2 0 012-2h10a2 2 0 012 2v16l-7-3.5L5 21V5z" />
                </svg>
            </Link>
            <div className="absolute -top-1 -right-1 min-w-[20px] h-5 px-1 rounded-full bg-sky-500 text-slate-950 font-black text-[13px] flex items-center justify-center shadow-lg shadow-sky-500/50" /* taste-skill-ignore: interactive overlay card */
>
                {count}
            </div>
        </div>
    );
};

export default SavedButton;
