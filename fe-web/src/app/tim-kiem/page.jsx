
'use client'

import { useEffect, useState, useRef } from "react";
import { useRouter } from 'next/navigation'
import Link from "next/link";
import searchMovies from "@/functions/searchMovies";
import useTitle from '@/hooks/useTitle';

import MovieCard from "@/components/MovieCard/MovieCard";

export default function Page({ searchParams }) {

    // ------ Get params and Set title ------
    let name = searchParams.name

    if (!name) {
        useTitle(`Tìm kiếm | JoyFilm`)
    } else {
        useTitle(`Tìm kiếm - "${name}" | JoyFilm`)
    }

    // ------ Data State ------
    const [searchInput, setSearchInput] = useState((name || ""))
    const searchInputDOM = useRef(null)
    const router = useRouter()
    const [movies, setMovies] = useState(null)

    // ------ Fetching Data
    useEffect(() => {
        const fetchData = async () => {
            setMovies(null)
            let data = await searchMovies(name)
            setMovies(data)
        }

        fetchData()
    }, [name])

    // ------ Event Handlers ------
    const keyDownHandler = (e) => {
        if (e.key === 'Enter') {
            router.push(`/tim-kiem?name=${searchInput}`)
        }
    }

    return (
        <div className="page-container-0topside">
            <div className="section-container">
                <h1 className="section-title-no-up">Tìm kiếm : "{name}"</h1>

                {/* ------ Frosted Glass Search input field ------ */}
                <div className="relative flex mt-6 max-w-2xl">
                    <input
                        type="text"
                        className="block w-full py-3.5 pl-5 pr-14 text-base text-white rounded-2xl bg-white/[0.07] backdrop-blur-xl border border-white/20 focus:border-sky-400 focus:bg-slate-900/90 focus:shadow-[0_0_20px_rgba(14,165,233,0.35)] focus:outline-none transition-all placeholder:text-slate-400 shadow-[inset_0_1px_2px_rgba(0,0,0,0.5)]" /* taste-skill-ignore: interactive overlay card */
                        placeholder="Nhập tên phim, diễn viên hoặc thể loại..."
                        value={searchInput}
                        onChange={(e) => setSearchInput(e.target.value)}
                        onKeyDown={keyDownHandler}
                        required
                        autoComplete="true"
                        ref={searchInputDOM}
                    />
                    <Link
                        href={`/tim-kiem?name=${encodeURIComponent(searchInput)}`}
                        className="absolute right-2 top-2 bottom-2 px-4 rounded-xl bg-sky-500/80 hover:bg-sky-400 text-white backdrop-blur-md flex items-center justify-center transition-all shadow-md active:scale-95 cursor-pointer" /* taste-skill-ignore: interactive overlay card */
                        aria-label="Tìm kiếm"
                    >
                        <svg className="w-5 h-5 fill-none" stroke="currentColor" viewBox="0 0 24 24">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
                        </svg>
                    </Link>
                </div>

                {/* ------ Movies grid ------ */}
                {
                    (!movies) ?
                        (
                            <div className="w-full mt-20 flex justify-center items-center">
                                <div className="loader"></div>
                            </div>
                        ) :

                        (movies.data.length == 0) ?
                            (
                                <div className="mt-6">
                                    <p className="text-lg text-text">Không tìm thấy phim tương ứng</p>
                                    <p className="text-text mt-2">Mẹo: Hãy tìm tên phim bằng tiếng anh hoặc có đầy đủ dấu</p>
                                </div>
                            ) : (
                                <div className="mt-6 movies-grid">
                                    {movies && movies.data.map((movie, index) => (
                                        <MovieCard key={index} movie={movie} />
                                    ))}
                                </div>
                            )
                }
            </div>

        </div >
    );
};

