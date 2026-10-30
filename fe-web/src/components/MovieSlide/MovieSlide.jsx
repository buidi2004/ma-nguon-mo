'use client'

import { useRef } from "react";
import MovieCard from "../MovieCard/MovieCard";
import Slider3 from '../Slider3/Slider3';
import 'slick-carousel/slick/slick.css';
import 'slick-carousel/slick/slick-theme.css';
import './MovieSlide.css';

const MovieSlide = ({ movies, slideRef: externalRef }) => {
    const internalRef = useRef(null);
    const slideRef = externalRef ?? internalRef;

    const nextMovie = () => {
        slideRef.current?.slickNext();
    };

    const prevMovie = () => {
        slideRef.current?.slickPrev();
    };

    // Setting for Movies Slide
    const settings = {
        dots: false,
        lazyLoad: true,
        arrows: false,
        infinite: true,
        draggable: true,
        swipeToSlide: true,
        swipe: true,
        speed: 400,
        slidesToScroll: 2,
        centerMode: false,
        initialSlide: 0,
        responsive: [
            {
                breakpoint: 3000,
                settings: {
                    slidesToShow: 6,
                }
            },
            {
                breakpoint: 1280,
                settings: {
                    slidesToShow: 5,
                }
            },
            {
                breakpoint: 1024,
                settings: {
                    slidesToShow: 4,
                }
            },
            {
                breakpoint: 768,
                settings: {
                    slidesToShow: 3,
                }
            },
            {
                breakpoint: 640,
                settings: {
                    slidesToShow: 2,
                    slidesToScroll: 1,
                }
            }
        ]
    };

    return (
        <div className="relative mt-4">
            {/* ------ Slide Control Buttons (only when the component owns its navigation) ------ */}
            {!externalRef && (
                <div className="absolute right-0 -top-11 flex items-center gap-2 z-10">
                    <button
                        className="w-9 h-9 rounded-full bg-slate-900/90 hover:bg-sky-500 text-slate-300 hover:text-slate-950 border border-white/15 hover:border-sky-400 flex items-center justify-center transition-colors duration-200 cursor-pointer"
                        aria-label="Phim trước"
                        onClick={prevMovie}
                    >
                        <svg className='w-4 h-4 fill-current' viewBox="0 0 24 24">
                            <path d="M15.41 7.41L14 6l-6 6 6 6 1.41-1.41L10.83 12z"/>
                        </svg>
                    </button>

                    <button
                        className="w-9 h-9 rounded-full bg-slate-900/90 hover:bg-sky-500 text-slate-300 hover:text-slate-950 border border-white/15 hover:border-sky-400 flex items-center justify-center transition-colors duration-200 cursor-pointer"
                        aria-label="Phim tiếp"
                        onClick={nextMovie}
                    >
                        <svg className='w-4 h-4 fill-current' viewBox="0 0 24 24">
                            <path d="M10 6L8.59 7.41 13.17 12l-4.58 4.59L10 18l6-6z"/>
                        </svg>
                    </button>
                </div>
            )}

            {/* ------ Movies Slide ------ */}
            <Slider3 ref={slideRef} {...settings}>
                {movies.map((movie) => (
                    <MovieCard key={movie._id} movie={movie} />
                ))}
            </Slider3>
        </div>
    );
};

export default MovieSlide;
