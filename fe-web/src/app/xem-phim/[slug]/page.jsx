import Link from "next/link";
import getMovie from "@/functions/getMovie";
import MovieMediaSection from "@/components/MovieMediaSection/MovieMediaSection";

export async function generateMetadata({ params, searchParams }) {
    const movie = await getMovie(params?.slug);
    if (!movie?.movie) {
        return {
            title: "Không tìm thấy phim | OpenFlix",
            description: "Phim yêu cầu không tìm thấy.",
        };
    }
    const tap = searchParams?.tap ? ` - Tập ${parseInt(searchParams.tap, 10) + 1}` : "";
    return {
        title: `Xem Phim ${movie.movie.name}${tap} (${movie.movie.year}) Full HD & 4K | OpenFlix`,
        description: movie.movie.content?.slice(0, 160) || "Xem phim chất lượng cao tại OpenFlix",
    };
}

export default async function WatchPage({ params, searchParams }) {
    const tap = searchParams?.tap || "0";
    const sv = searchParams?.sv || "0";
    const movie = await getMovie(params?.slug);

    if (!movie || !movie.movie) {
        return (
            <div className="w-full min-h-[100dvh] bg-[#08090c] flex items-center justify-center px-4 py-24">
                <div className="p-8 rounded-2xl bg-[#121620] text-center max-w-md">
                    <div className="w-14 h-14 mx-auto mb-4 rounded-xl bg-sky-500/10 flex items-center justify-center text-sky-400">
                        <svg className="w-7 h-7 fill-current" viewBox="0 0 24 24"><path d="M18 4l2 4h-3l-2-4h-2l2 4h-3l-2-4H8l2 4H7L5 4H4c-1.1 0-1.99.9-1.99 2L2 18c0 1.1.9 2 2 2h16c1.1 0 2-.9 2-2V4h-4z"/></svg>
                    </div>
                    <span className="text-sky-400 font-semibold text-xs">Thông báo</span>
                    <h1 className="text-xl sm:text-2xl font-bold text-white mt-1 mb-2">Không tìm thấy phim</h1>
                    <p className="text-slate-400 text-base mb-6 leading-relaxed">
                        Bộ phim bạn yêu cầu không tồn tại hoặc đã được cập nhật liên kết mới.
                    </p>
                    <div className="flex flex-col sm:flex-row items-center justify-center gap-3">
                        <Link href="/" className="play-button-color w-full sm:w-auto px-6 py-2.5 text-base font-semibold">
                            Về Trang Chủ
                        </Link>
                        <Link href="/the-loai" className="add-button-color w-full sm:w-auto px-6 py-2.5 text-base font-medium">
                            Xem Thể Loại
                        </Link>
                    </div>
                </div>
            </div>
        );
    }

    return (
        <div className="bg-background min-h-[100dvh]">
            <MovieMediaSection
                info={movie.movie}
                media={movie.episodes}
                epIndex={parseInt(tap, 10) || 0}
                svIndex={parseInt(sv, 10) || 0}
            />
        </div>
    );
}

