import Link from "next/link";
import Image from "next/image";

const MovieCard = ({ movie }) => {
    return (
        <div data-ui="card" className='w-full bg-transparent px-1 sm:px-2'>
            {/* ------ Movie Card container ------ */}
            <Link href={`/phim/${movie.slug}`} className="group block focus:outline-none">

                {/* ------ Thumbnail wrapper ------ */}
                <div className="overflow-hidden rounded-xl relative bg-[#121620] group-hover:ring-2 group-hover:ring-sky-400 transition-[transform,box-shadow] duration-200">
                    <div className="relative aspect-[2/3] transform transition-transform duration-200 group-hover:scale-105">
                        <div className="w-full h-full rounded-xl bg-[#121620] flex justify-center items-center">
                            <div className="skeleton"></div>
                        </div>

                        <Image
                            src={movie.thumb_url || movie.poster_url || '/placeholder.webp'}
                            alt={movie.name}
                            fill={true}
                            sizes="(max-width: 640px) 50vw, (max-width: 768px) 33vw, (max-width: 1024px) 25vw, 17vw"
                            style={{
                                objectFit: 'cover',
                            }}
                            loading="lazy"
                            quality={75}
                            className="transition-opacity duration-300"
                        />

                        {/* Top Badges */}
                        <div className="absolute top-2 left-2 z-10 flex gap-1">
                            <span className="bg-slate-950/90 text-sky-400 text-[13px] font-semibold px-2 py-0.5 rounded">
                                Full HD
                            </span>
                        </div>

                        {movie.year && (
                            <div className="absolute top-2 right-2 z-10">
                                <span className="bg-slate-950/90 text-slate-200 text-[13px] font-semibold px-2 py-0.5 rounded">
                                    {movie.year}
                                </span>
                            </div>
                        )}

                        {/* Scrim over photo */}
                        <div className="absolute inset-x-0 bottom-0 h-1/2 bg-gradient-to-t from-black/80 via-transparent to-transparent opacity-60 group-hover:opacity-90 transition-opacity duration-200"></div> {/* taste-skill-ignore: neutral photo scrim */}

                        {/* Center Play Button on hover */}
                        <div className="absolute inset-0 flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity duration-200 pointer-events-none">
                            <div className="w-12 h-12 rounded-full bg-sky-500 text-slate-950 flex items-center justify-center">
                                <svg className="w-6 h-6 ml-0.5 fill-current" viewBox="0 0 24 24">
                                    <path d="M8 5v14l11-7z" />
                                </svg>
                            </div>
                        </div>

                    </div>
                </div>

                {/* ------ Title wrapper ------ */}
                <div className="mt-2.5 px-0.5">
                    <p className="text-white group-hover:text-sky-400 transition-colors line-clamp-1 text-sm sm:text-base font-semibold leading-snug">
                        {movie.name}
                    </p>
                    <div className="flex items-center gap-2 text-[13px] text-slate-400 mt-1">
                        <span className="line-clamp-1 min-w-0 flex-1">
                            {movie.origin_name && movie.origin_name !== movie.name
                                ? movie.origin_name
                                : (Array.isArray(movie.category)
                                    ? movie.category.join(' • ')
                                    : movie.category) || 'Phim HD'}
                        </span>
                        {movie.time && (
                            <span className="text-[13px] text-sky-400 font-medium whitespace-nowrap shrink-0">
                                {movie.time}
                            </span>
                        )}
                    </div>
                </div>

            </Link>
        </div>
    );
};

export default MovieCard;
