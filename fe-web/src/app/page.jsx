import Link from "next/link";
import getHomePageMovies from "@/functions/getHomePageMovies";
import { GENRES } from "@/functions/getPageMovies";
import CarouselThumbnails from "@/components/CarouselThumbnails/CarouselThumbnails";
import MovieSlideSection from "@/components/MovieSlideSection/MovieSlideSection";

export const metadata = {
    title: 'OpenFlix - Xem Phim Online Miễn Phí Chuẩn HD & 4K',
    description: 'Trang chủ OpenFlix - Nền tảng xem phim trực tuyến miễn phí chuẩn Netflix, cập nhật phim mới, phim chiếu rạp, phim bộ và hoạt hình Full HD & 4K.',
};

export default async function Page() {
    // ------ Fetching Data from PocketBase VPS ------
    const data = await getHomePageMovies();

    return (
        <div className="relative bg-[#08090c] min-h-[100dvh] pb-16 overflow-hidden">
            {/* Ambient Lighting Spots (Netflix Cinema Glow) */}
            <div className="absolute top-0 left-1/2 -translate-x-1/2 w-[1100px] h-[550px] bg-gradient-to-b from-sky-600/15 via-sky-900/5 to-transparent blur-3xl pointer-events-none -z-10"></div> {/* taste-skill-ignore: ambient lighting spot */}
            <div className="absolute top-[40%] -left-40 w-96 h-96 bg-sky-500/10 rounded-full blur-3xl pointer-events-none -z-10"></div>
            <div className="absolute top-[70%] -right-40 w-96 h-96 bg-cyan-500/10 rounded-full blur-3xl pointer-events-none -z-10"></div>

            {/* ------ Hero Carousel (Top Movies) ------ */}
            <CarouselThumbnails movies={data?.data?.newMovies?.slice(0, 4)} />

            {/* ------ Quick Category Pills Bar ------ */}
            <div className="section-container pt-4 pb-2">
                <div className="flex items-center gap-2 overflow-x-auto no-scrollbar py-2">
                    <span className="text-sm font-semibold text-slate-300 shrink-0 mr-1 flex items-center gap-2">
                        <span className="w-1.5 h-1.5 rounded-full bg-sky-400"></span>
                        Thể loại hot:
                    </span>
                    {GENRES.slice(0, 9).map((g) => (
                        <Link
                            key={g.slug}
                            href={`/the-loai/${g.slug}/1`}
                            className="shrink-0 px-3.5 py-1.5 rounded-full text-[13px] sm:text-sm font-medium bg-white/[0.06] hover:bg-sky-500/20 text-slate-200 hover:text-white transition-colors duration-200"
                        >
                            {g.name}
                        </Link>
                    ))}
                    <Link
                        href="/the-loai"
                        className="shrink-0 px-3.5 py-1.5 rounded-full text-[13px] sm:text-sm font-semibold bg-sky-500/15 text-sky-300 hover:bg-sky-500/25 transition-colors"
                    >
                        Tất cả →
                    </Link>
                </div>
            </div>

            {/* ------ Movie Rails Section ------ */}
            <div className="space-y-2">
                {/* 1. NEW Movies Section */}
                <MovieSlideSection
                    title="Phim mới cập nhật"
                    type="phim-moi"
                    movieData={data?.data?.newMovies || []}
                    divider={true}
                    topSection={true}
                    badge="Mới nhất"
                />

                {/* 2. TOP Trending Movies */}
                {data?.data?.topMovies?.length > 0 && (
                    <MovieSlideSection
                        title="Bảng xếp hạng phim xem nhiều"
                        type="top-phim"
                        movieData={data.data.topMovies}
                        divider={true}
                        topSection={false}
                        badge="Top 10"
                    />
                )}

                {/* 3. THEATER Movies Section */}
                <MovieSlideSection
                    title="Phim chiếu rạp đặc sắc"
                    type="chieu-rap"
                    movieData={data?.data?.theaterMovies || []}
                    divider={true}
                    topSection={false}
                    badge="Bom tấn"
                />

                {/* 4. COMING SOON Movies Section */}
                {data?.data?.comingSoonMovies?.length > 0 && (
                    <MovieSlideSection
                        title="Phim sắp công chiếu"
                        type="sap-chieu"
                        movieData={data.data.comingSoonMovies}
                        divider={true}
                        topSection={false}
                        badge="Sắp ra mắt"
                    />
                )}

                {/* 5. SINGLE Movies Section */}
                <MovieSlideSection
                    title="Phim lẻ chọn lọc"
                    type="phim-le"
                    movieData={data?.data?.singleMovies || []}
                    divider={true}
                    topSection={false}
                />

                {/* 6. SERIES Movies Section */}
                <MovieSlideSection
                    title="Phim bộ truyền hình"
                    type="phim-bo"
                    movieData={data?.data?.seriesMovies || []}
                    divider={true}
                    topSection={false}
                />

                {/* 7. CARTOON Anime Section */}
                <MovieSlideSection
                    title="Phim hoạt hình Anime"
                    type="hoat-hinh"
                    movieData={data?.data?.cartoonMovies || []}
                    divider={false}
                    topSection={false}
                />
            </div>
        </div>
    );
}
