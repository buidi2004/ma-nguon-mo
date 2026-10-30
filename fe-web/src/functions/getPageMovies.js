import { fetchPocketBase, mapMovieToCard } from './pocketbase';

export const GENRES = [
    { slug: 'hanh-dong', name: 'Hành Động', filter: "category ~ 'Hành động'" },
    { slug: 'vien-tuong', name: 'Viễn Tưởng', filter: "category ~ 'Viễn tưởng'" },
    { slug: 'kinh-di', name: 'Kinh Dị', filter: "category ~ 'Kinh dị'" },
    { slug: 'hai-huoc', name: 'Hài Hước', filter: "category ~ 'Hài hước'" },
    { slug: 'tinh-cam', name: 'Tình Cảm', filter: "category ~ 'Tình cảm'" },
    { slug: 'tam-ly', name: 'Tâm Lý', filter: "category ~ 'Tâm lý'" },
    { slug: 'phieu-luu', name: 'Phiêu Lưu', filter: "category ~ 'Phiêu lưu'" },
    { slug: 'vo-thuat', name: 'Võ Thuật', filter: "category ~ 'Võ thuật'" },
    { slug: 'hoat-hinh', name: 'Hoạt Hình', filter: "category ~ 'Hoạt hình'" },
    { slug: 'co-trang', name: 'Cổ Trang', filter: "category ~ 'Cổ trang'" },
    { slug: 'chien-tranh', name: 'Chiến Tranh', filter: "category ~ 'Chiến tranh'" },
    { slug: 'gia-dinh', name: 'Gia Đình', filter: "category ~ 'Gia đình'" },
    { slug: 'tai-lieu', name: 'Tài Liệu', filter: "category ~ 'Tài liệu'" },
    { slug: 'the-thao', name: 'Thể Thao', filter: "category ~ 'Thể thao'" },
];

export const COUNTRIES = [
    { slug: 'au-my', name: 'Âu Mỹ', filter: "cast ~ 'Mỹ' || description ~ 'Mỹ' || description ~ 'Hollywood' || director ~ 'Mỹ' || title ~ 'Mỹ'" },
    { slug: 'han-quoc', name: 'Hàn Quốc', filter: "cast ~ 'Hàn' || description ~ 'Hàn' || title ~ 'Hàn' || category ~ 'Hàn'" },
    { slug: 'trung-quoc', name: 'Trung Quốc', filter: "category ~ 'Cổ trang' || cast ~ 'Trung' || description ~ 'Trung' || title ~ 'Trung'" },
    { slug: 'nhat-ban', name: 'Nhật Bản', filter: "category ~ 'Hoạt hình' || description ~ 'Nhật' || cast ~ 'Nhật' || title ~ 'Nhật'" },
    { slug: 'viet-nam', name: 'Việt Nam', filter: "description ~ 'Việt' || cast ~ 'Việt' || title ~ 'Việt'" },
    { slug: 'thai-lan', name: 'Thái Lan', filter: "description ~ 'Thái' || cast ~ 'Thái' || title ~ 'Thái'" },
    { slug: 'an-do', name: 'Ấn Độ', filter: "description ~ 'Ấn' || cast ~ 'Ấn' || title ~ 'Ấn'" },
    { slug: 'quoc-te', name: 'Quốc Tế', filter: "" },
];

export const YEARS = [
    { slug: '2024', name: 'Năm 2024', filter: "release_year = 2024" },
    { slug: '2023', name: 'Năm 2023', filter: "release_year = 2023" },
    { slug: '2022', name: 'Năm 2022', filter: "release_year = 2022" },
    { slug: '2021', name: 'Năm 2021', filter: "release_year = 2021" },
    { slug: '2020', name: 'Năm 2020', filter: "release_year = 2020" },
    { slug: '2019', name: 'Năm 2019', filter: "release_year = 2019" },
    { slug: '2018', name: 'Năm 2018', filter: "release_year = 2018" },
    { slug: 'truoc-2018', name: 'Trước 2018', filter: "release_year < 2018" },
];

const TYPE_FILTER_MAP = {
    new: '',
    theater: "category ~ 'Hành động' || category ~ 'Viễn tưởng' || category ~ 'Chiếu rạp'",
    single: "category ~ 'Hài hước' || category ~ 'Kinh dị' || category ~ 'Võ thuật' || category ~ 'Tài liệu' || category ~ 'Thể thao'",
    series: "category ~ 'Tình cảm' || category ~ 'Tâm lý' || category ~ 'Phiêu lưu' || category ~ 'Bộ'",
    cartoon: "category ~ 'Hoạt hình'",
    coming_soon: "coming_soon = true",
};

// Add genre filters dynamically
GENRES.forEach((g) => {
    TYPE_FILTER_MAP[g.slug] = g.filter;
});

// Add country filters dynamically
COUNTRIES.forEach((c) => {
    TYPE_FILTER_MAP[c.slug] = c.filter;
});

// Add year filters dynamically
YEARS.forEach((y) => {
    TYPE_FILTER_MAP[y.slug] = y.filter;
});

export default async function getPageMovies(type, page = 1) {
    try {
        const perPage = 18;
        const pageNum = Math.max(parseInt(page, 10) || 1, 1);

        let filter = TYPE_FILTER_MAP[type];
        if (filter === undefined) {
            const foundGenre = GENRES.find((g) => g.slug === type);
            const foundCountry = COUNTRIES.find((c) => c.slug === type);
            const foundYear = YEARS.find((y) => y.slug === type);
            filter = foundGenre?.filter || foundCountry?.filter || foundYear?.filter || '';
        }

        let sort = '-created';
        if (type === 'top') {
            sort = '-rank,-release_year';
            filter = '';
        } else if (type === 'coming_soon') {
            sort = '-release_year,-created';
        }

        let endpoint = `/api/collections/movies/records?page=${pageNum}&perPage=${perPage}&sort=${sort}`;
        if (filter) {
            endpoint += `&filter=(${encodeURIComponent(filter)})`;
        }

        const res = await fetchPocketBase(endpoint);
        let items = res?.items || [];
        let totalPages = res?.totalPages || 1;

        // Fallback for empty results so screen is never blank
        if (items.length === 0) {
            const fallbackRes = await fetchPocketBase(`/api/collections/movies/records?page=${pageNum}&perPage=${perPage}&sort=-release_year`);
            items = fallbackRes?.items || [];
            totalPages = fallbackRes?.totalPages || 1;
        }

        return {
            data: items.map(mapMovieToCard).filter(Boolean),
            totalPages: Math.max(totalPages, 1),
        };
    } catch (err) {
        console.error(`[getPageMovies] Error fetching type=${type}, page=${page}:`, err);
        return {
            data: [],
            totalPages: 1,
        };
    }
}
