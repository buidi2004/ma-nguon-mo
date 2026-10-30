import { fetchPocketBase, mapMovieToCard } from './pocketbase';

export default async function getHomePageMovies() {
    try {
        const res = await fetchPocketBase('/api/collections/movies/records?page=1&perPage=100&sort=-created');
        const items = res?.items || [];
        const cards = items.map(mapMovieToCard).filter(Boolean);

        if (cards.length === 0) {
            return {
                data: {
                    newMovies: [],
                    theaterMovies: [],
                    singleMovies: [],
                    seriesMovies: [],
                    cartoonMovies: [],
                },
            };
        }

        const newMovies = cards.slice(0, 16);
        const topMovies = [...cards].sort((a, b) => (b.rank || 0) - (a.rank || 0)).slice(0, 16);
        const comingSoonMovies = cards.filter((m) => m.coming_soon).slice(0, 16);
        const cartoonMovies = cards.filter((m) => /hoạt hình/i.test(m.category)).slice(0, 16);
        const theaterMovies = cards
            .filter((m) => /chiếu rạp|rạp|hành động|viễn tưởng/i.test(m.category))
            .slice(0, 16);
        const seriesMovies = cards
            .filter((m) => /bộ|tình cảm|tâm lý|phiêu lưu/i.test(m.category))
            .slice(0, 16);
        const singleMovies = cards
            .filter((m) => /hài|kinh dị|võ thuật|tài liệu|thể thao/i.test(m.category))
            .slice(0, 16);

        return {
            data: {
                newMovies: newMovies.length > 0 ? newMovies : cards.slice(0, 12),
                topMovies: topMovies.length > 0 ? topMovies : cards.slice(0, 12),
                comingSoonMovies: comingSoonMovies.length > 0 ? comingSoonMovies : cards.slice(0, 8),
                theaterMovies: theaterMovies.length > 0 ? theaterMovies : cards.slice(2, 14),
                singleMovies: singleMovies.length > 0 ? singleMovies : cards.slice(4, 16),
                seriesMovies: seriesMovies.length > 0 ? seriesMovies : cards.slice(6, 18),
                cartoonMovies: cartoonMovies.length > 0 ? cartoonMovies : cards.slice(0, 10),
            },
        };
    } catch (err) {
        console.error('[getHomePageMovies] Error:', err);
        return {
            data: {
                newMovies: [],
                theaterMovies: [],
                singleMovies: [],
                seriesMovies: [],
                cartoonMovies: [],
            },
        };
    }
}
