'use client'

import Link from 'next/link'
import Carousel3 from '../Carousel3/Carousel3'
import 'react-responsive-carousel/lib/styles/carousel.min.css'
import './CarouselThumbnails.css'
import CarouselSaveBtn from '../CarouselSaveBtn/CarouselSaveBtn'

const slideItems = [
    {
        id: '2',
        name: "Người Kiến Và Chiến Binh Ong: Thế Giới Lượng Tử",
        original_name: 'Ant-Man and the Wasp: Quantumania',
        slug: "nguoi-kien-va-chien-binh-ong-the-gioi-luong-tu",
        poster_url: '/thumbnails/carousel1.webp',
        thumb_url: 'https://img.ophim9.cc/uploads/movies/nguoi-kien-va-chien-binh-ong-the-gioi-luong-tu-thumb.jpg',
        year: 2023,
        category: 'Hành động',
        lazy: 'eager',
    },
    {
        id: '3',
        name: "Xứ Sở Các Nguyên Tố",
        original_name: 'Elemental',
        slug: "xu-so-cac-nguyen-to",
        poster_url: '/thumbnails/carousel2.webp',
        thumb_url: 'https://img.ophim9.cc/uploads/movies/xu-so-cac-nguyen-to-thumb.jpg',
        year: 2023,
        category: 'Hoạt hình',
        lazy: 'lazy',
    },
    {
        id: '4',
        name: "Người Nhện: Du Hành Vũ Trụ Nhện",
        original_name: 'Spider-Man: Across the Spider-Verse',
        slug: "nguoi-nhen-du-hanh-vu-tru-nhen",
        poster_url: '/thumbnails/carousel3.webp',
        thumb_url: 'https://img.ophim9.cc/uploads/movies/nguoi-nhen-du-hanh-vu-tru-nhen-thumb.jpg',
        year: 2023,
        category: 'Hoạt hình',
        lazy: 'lazy',
    },
    {
        id: '6',
        name: "Anh Em Super Mario",
        original_name: 'The Super Mario Bros. Movie',
        slug: "anh-em-super-mario",
        poster_url: '/thumbnails/carousel4.webp',
        thumb_url: 'https://img.ophim9.cc/uploads/movies/anh-em-super-mario-thumb.jpg',
        year: 2023,
        category: 'Hoạt hình',
        lazy: 'lazy',
    }
]

const CarouselThumbnails = ({ movies }) => {
    const items = (movies && movies.length > 0)
        ? movies.map((m, idx) => ({
            id: m._id || m.slug || idx,
            name: m.name,
            original_name: m.origin_name || m.name,
            slug: m.slug,
            poster_url: m.poster_url || m.thumb_url,
            thumb_url: m.thumb_url || m.poster_url,
            year: m.year || 2024,
            category: m.category || 'Phim rạp',
            lazy: idx === 0 ? 'eager' : 'lazy',
        }))
        : slideItems;

    return (
        <div className="relative">
            {/* ------ Carousel wrapper ------ */}
            <Carousel3
                showArrows={false}
                showStatus={false}
                showIndicators={false}
                stopOnHover={false}
                swipeable={true}
                autoPlay={true}
                dynamicHeight={false}
                infiniteLoop={false}
                thumbWidth='23%'
                transitionTime={700}
                interval={5000}
                renderThumbs={() =>
                    items.map((item, idx) => (
                        <div
                            key={item.id || idx}
                            className="relative w-full h-full aspect-video overflow-hidden rounded-xl bg-slate-900 group"
                        >
                            <img
                                src={item.thumb_url || item.poster_url || '/placeholder.webp'}
                                alt={item.name}
                                className="w-full h-full object-cover transition-transform duration-300 group-hover:scale-105"
                                onError={(e) => {
                                    e.currentTarget.src = '/placeholder.webp';
                                }}
                            />
                            <div className="absolute inset-0 bg-gradient-to-t from-black/90 via-black/35 to-transparent flex flex-col justify-end p-2 sm:p-2.5 pointer-events-none text-left">
                                <span className="text-[11px] sm:text-xs font-bold text-white line-clamp-1 leading-tight drop-shadow">
                                    {item.name}
                                </span>
                                <span className="text-[10px] text-sky-400 font-medium mt-0.5 line-clamp-1">
                                    {item.category}
                                </span>
                            </div>
                        </div>
                    ))
                }
            >
                {
                    items.map((item, idx) => (
                        <div key={item.id} className="relative w-full h-[540px] sm:h-[600px] md:h-[680px] lg:h-[740px] overflow-hidden">

                            {/* ------ Carousel Background (landscape art first, portrait poster as fallback) ------ */}
                            <img
                                src={item.thumb_url || item.poster_url || '/placeholder.webp'}
                                alt={item.name}
                                loading={item.lazy}
                                onError={(e) => { e.currentTarget.src = '/placeholder.webp'; }}
                                className='absolute inset-0 w-full h-full object-cover filter brightness-[85%]'
                            />

                            {/* ------ Vignette Ambient Dark Shadows (Netflix Multi-layer) ------ */}
                            <div className="absolute inset-0 bg-gradient-to-r from-[#08090c] via-[#08090c]/70 md:via-[#08090c]/40 to-transparent"></div> {/* taste-skill-ignore: neutral photo scrim */}
                            <div className="absolute inset-0 bg-gradient-to-t from-[#08090c] via-[#08090c]/50 to-transparent"></div> {/* taste-skill-ignore: neutral photo scrim */}

                            {/* ------ Carousel Legend Text ------ */}
                            <div className='carousel-texts'>
                                {/* Title (First slide is the page H1, others are H2) */}
                                {idx === 0 ? (
                                    <h1 className='block text-center md:text-left text-3xl sm:text-4xl md:text-5xl lg:text-6xl font-black text-white uppercase tracking-tight max-w-3xl leading-[1.1]'>
                                        {item.name}
                                    </h1>
                                ) : (
                                    <h2 className='block text-center md:text-left text-3xl sm:text-4xl md:text-5xl lg:text-6xl font-black text-white uppercase tracking-tight max-w-3xl leading-[1.1]'>
                                        {item.name}
                                    </h2>
                                )}

                                {/* Metadata Badges Row (Below Title) */}
                                <div className='flex items-center gap-2.5 my-3 justify-center md:justify-start flex-wrap'>
                                    <span className='bg-sky-500 text-slate-950 font-black text-[13px] px-2.5 py-0.5 rounded'>
                                        4K ULTRA HD
                                    </span>
                                    <span className='bg-white/10 text-slate-200 text-[13px] font-semibold px-2 py-0.5 rounded'>
                                        {item.year}
                                    </span>
                                    {item.category && (
                                        <span className='bg-white/10 text-slate-300 text-[13px] px-2.5 py-0.5 rounded'>
                                            {item.category}
                                        </span>
                                    )}
                                </div>

                                {item.original_name && item.original_name !== item.name && (
                                    <p className='text-slate-400 text-base md:text-lg font-medium line-clamp-1 max-w-2xl text-center md:text-left'>
                                        {item.original_name}
                                    </p>
                                )}

                                {/* 'Play' Button & 'Add to Watch List' Button */}
                                <div className='flex items-center justify-center md:justify-start space-x-3 sm:space-x-4 mt-5'>
                                    <Link
                                        href={`/phim/${item.slug}`}
                                        className='inline-flex items-center gap-2.5 px-6 py-3 rounded-xl bg-sky-500 hover:bg-sky-400 text-slate-950 font-bold text-sm sm:text-base transition-colors duration-200 cursor-pointer'
                                    >
                                        <svg className='w-5 h-5 fill-current' viewBox="0 0 24 24">
                                            <polygon points="5 3 19 12 5 21 5 3"></polygon>
                                        </svg>
                                        <span>Phát ngay</span>
                                    </Link>

                                    <CarouselSaveBtn item={item} />
                                </div>
                            </div>
                        </div>
                    ))
                }
            </Carousel3>
        </div>
    );
};

export default CarouselThumbnails;
