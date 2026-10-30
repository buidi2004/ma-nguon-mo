
'use client'

import { useContext } from "react";
import { saveContext } from "@/contexts/saveContext";
import useTitle from "@/hooks/useTitle";
import MovieCard from "@/components/MovieCard/MovieCard";

export default function Page() {
    const context = useContext(saveContext)

    useTitle(`Phim đã lưu (${context.saveList.length}) - JoyFilm`)


    return (
        <div className="page-container-0topside">
            <div className="section-container">
                <h1 className="section-title-no-up">Phim đã lưu ({context.saveList.length})</h1>

                {context.saveList.length === 0 ? (
                    <div className="mt-12 p-12 text-center rounded-2xl bg-[#121620] border border-white/10 max-w-xl mx-auto">
                        <div className="w-16 h-16 mx-auto mb-4 rounded-xl bg-sky-500/10 border border-sky-400/30 flex items-center justify-center text-sky-400">
                            <svg className="w-8 h-8 fill-current" viewBox="0 0 24 24"><path d="M5 5a2 2 0 012-2h10a2 2 0 012 2v16l-7-3.5L5 21V5z"/></svg>
                        </div>
                        <h2 className="text-white text-xl font-bold mb-2">Chưa có phim nào trong danh sách</h2>
                        <p className="text-slate-400 text-sm mb-6">
                            Lưu các bộ phim yêu thích của bạn để tiện theo dõi và xem lại bất cứ lúc nào.
                        </p>
                        <a
                            href="/phim-moi/1"
                            className="play-button-color px-6 py-3 text-sm inline-flex items-center gap-2"
                        >
                            Khám phá phim mới ngay
                        </a>
                    </div>
                ) : (
                    /* ------ Movies Grid ------ */
                    <div className="mt-6 movies-grid">
                        {context.saveList.map((movie, index) => (
                            <MovieCard key={index} movie={movie} />
                        ))}
                    </div>
                )}

            </div>
        </div >
    );
};

