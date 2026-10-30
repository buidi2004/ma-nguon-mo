import { fetchPocketBase, mapMovieToCard } from './pocketbase';

export default async function searchMovies(name) {
    try {
        if (!name || !name.trim()) {
            const res = await fetchPocketBase('/api/collections/movies/records?page=1&perPage=24&sort=-created');
            return {
                data: (res?.items || []).map(mapMovieToCard).filter(Boolean),
            };
        }

        const query = name.trim();
        const filter = `title~'${query}' || description~'${query}' || category~'${query}' || director~'${query}' || cast~'${query}'`;
        const res = await fetchPocketBase(
            `/api/collections/movies/records?page=1&perPage=50&filter=(${encodeURIComponent(filter)})&sort=-created`
        );

        return {
            data: (res?.items || []).map(mapMovieToCard).filter(Boolean),
        };
    } catch (err) {
        console.error(`[searchMovies] Error searching "${name}":`, err);
        return {
            data: [],
        };
    }
}
