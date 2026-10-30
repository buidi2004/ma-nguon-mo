'use client'

import { useContext } from "react";
import { saveContext } from "@/contexts/saveContext";

const CarouselSaveBtn = ({ item }) => {
    const context = useContext(saveContext)

    const addToSaveList = (movie) => {
        context.toggleSaveMovie(movie)
    }

    const saved = context.isSaved(item);

    return (
        <button
            aria-label="Lưu phim"
            onClick={() => { addToSaveList(item) }}
            className={`add-button-color text-sm sm:text-base px-5 py-3 flex items-center gap-2 rounded-xl transition-all ${
                saved ? 'text-sky-400 border-sky-400/50 bg-sky-500/10' : ''
            }`}
        >
            <svg
                className={`w-5 h-5 ${saved ? 'text-sky-400 fill-current' : 'text-slate-300'}`}
                fill={saved ? "currentColor" : "none"}
                stroke="currentColor"
                strokeWidth="2"
                viewBox="0 0 24 24"
            >
                <path strokeLinecap="round" strokeLinejoin="round" d="M5 5a2 2 0 012-2h10a2 2 0 012 2v16l-7-3.5L5 21V5z" />
            </svg>
            <span>{saved ? 'Đã lưu' : 'Lưu danh sách'}</span>
        </button>
    );
};

export default CarouselSaveBtn;
