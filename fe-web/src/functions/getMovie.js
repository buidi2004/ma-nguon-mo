import { fetchPocketBase, mapMovieToDetail } from './pocketbase';

export default async function getMovie(slug) {
    try {
        if (!slug) return null;

        let id = slug;
        if (slug.length > 15 && slug.includes('-')) {
            const parts = slug.split('-');
            const lastPart = parts[parts.length - 1];
            if (lastPart.length === 15) {
                id = lastPart;
            }
        }

        // PocketBase IDs are exactly 15 chars — skip the direct-ID lookup for plain slugs
        // (a slug like "big-buck-bunny" can never be a record ID, the call only 404s)
        const isRecordId = /^[a-z0-9]{15}$/.test(id);

        // 1. Try direct lookup by ID (only when the slug is actually a PocketBase record ID)
        let record = null;
        if (isRecordId) {
            try {
                record = await fetchPocketBase(`/api/collections/movies/records/${id}`);
            } catch {
                // lookup by ID failed, continue to filter
            }
        }

        // 2. Try filter by ID or title
        if (!record || !record.id) {
            const cleanSlug = slug.replace(/-/g, ' ');
            const res = await fetchPocketBase(
                `/api/collections/movies/records?filter=(${encodeURIComponent(`id='${id}' || title~'${cleanSlug}' || title~'${slug}'`)})&perPage=1`
            );
            if (res?.items?.length > 0) {
                record = res.items[0];
            }
        }

        // 3. Fallback to first available record if not found
        if (!record || !record.id) {
            const fallbackRes = await fetchPocketBase('/api/collections/movies/records?page=1&perPage=1');
            if (fallbackRes?.items?.length > 0) {
                record = fallbackRes.items[0];
            }
        }

        if (record && record.id) {
            return mapMovieToDetail(record);
        }

        return null;
    } catch (err) {
        console.error(`[getMovie] Error fetching ${slug}:`, err);
        return null;
    }
}
