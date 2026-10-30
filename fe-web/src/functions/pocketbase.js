const VPS_POCKETBASE_URL = 'http://180.93.120.246:8090';
const LOCAL_POCKETBASE_URL = 'http://127.0.0.1:8090';

export const POCKETBASE_URL = process.env.NEXT_PUBLIC_POCKETBASE_URL || VPS_POCKETBASE_URL;

/**
 * Fetch helper for PocketBase with automatic fallback and error handling
 */
export async function fetchPocketBase(endpoint, options = {}) {
    const urls = [
        `${POCKETBASE_URL}${endpoint}`,
        `${LOCAL_POCKETBASE_URL}${endpoint}`,
    ];

    let lastError = null;
    for (const url of urls) {
        try {
            const controller = new AbortController();
            const timeoutId = setTimeout(() => controller.abort(), 8000);

            const res = await fetch(url, {
                signal: controller.signal,
                next: { revalidate: 60 },
                ...options,
            });

            clearTimeout(timeoutId);

            if (res.ok) {
                return await res.json();
            }
        } catch (err) {
            lastError = err;
        }
    }

    console.warn(`[PocketBase] Could not fetch ${endpoint}:`, lastError?.message || 'Unknown error');
    return null;
}

/**
 * Map a PocketBase movie item to JoyFilm card format
 */
export function mapMovieToCard(item) {
    if (!item) return null;

    const poster = item.poster_url || '/placeholder.webp';
    const duration = item.duration_minutes ? `${item.duration_minutes} phút` : '90 phút';

    return {
        _id: item.id,
        name: item.title || 'Không tiêu đề',
        origin_name: item.title || '',
        slug: item.id,
        thumb_url: poster,
        poster_url: poster,
        year: item.release_year || 2024,
        category: item.category || 'Phim lẻ',
        time: duration,
        rank: item.rank || 0,
        coming_soon: !!item.coming_soon,
    };
}

/**
 * Map a PocketBase movie item to JoyFilm detail and episode format
 */
export function mapMovieToDetail(item) {
    if (!item) return null;

    const rawCategory = item.category || 'Phim lẻ';
    const categories = rawCategory
        .split(/[&,]/)
        .map((cat, idx) => ({
            id: idx + 1,
            name: cat.trim(),
            slug: cat.trim().toLowerCase(),
        }))
        .filter((c) => c.name.length > 0);

    const directors = item.director
        ? item.director.split(',').map((s) => s.trim()).filter(Boolean)
        : ['Đang cập nhật'];

    const actors = item.cast
        ? item.cast.split(',').map((s) => s.trim()).filter(Boolean)
        : ['Đang cập nhật'];

    const poster = item.poster_url || '/placeholder.webp';
    const videoUrl = item.video_url || 'https://vjs.zencdn.net/v/oceans.mp4';
    const trailerUrl = item.trailer_url || '';
    const duration = item.duration_minutes ? `${item.duration_minutes} phút` : '90 phút';

    return {
        status: true,
        movie: {
            id: item.id,
            name: item.title || 'Không tiêu đề',
            origin_name: item.title || '',
            content: item.description || 'Chưa có mô tả cho bộ phim này.',
            type: rawCategory.toLowerCase().includes('bộ') ? 'series' : 'single',
            status: 'completed',
            thumb_url: poster,
            poster_url: poster,
            is_copyright: false,
            sub_docquyen: false,
            chieurap: rawCategory.toLowerCase().includes('rạp') || false,
            trailer_url: trailerUrl,
            time: duration,
            episode_current: 'Full HD',
            episode_total: '1',
            quality: 'HD 1080p',
            lang: 'Vietsub / Thuyết minh',
            notify: '',
            showtimes: '',
            slug: item.id,
            year: item.release_year || 2024,
            view: (item.rank ? item.rank * 150 : 1000) + 128,
            actor: actors.length > 0 ? actors : ['Đang cập nhật'],
            director: directors.length > 0 ? directors : ['Đang cập nhật'],
            category: categories.length > 0 ? categories : [{ id: 1, name: 'Phim lẻ' }],
            country: [{ id: 1, name: 'Quốc tế', slug: 'quoc-te' }],
        },
        episodes: [
            {
                server_name: 'Máy chủ VIP (VPS)',
                server_data: [
                    {
                        name: 'Full HD',
                        slug: 'full',
                        filename: `${item.title || 'movie'}.mp4`,
                        link_embed: videoUrl,
                        link_m3u8: videoUrl,
                    },
                ],
            },
        ],
    };
}

