'use client'

import { useState } from 'react';

const ContentInfo = ({ info }) => {
    const [showMore, setShowMore] = useState(false);
    const content = info?.content || 'Chưa có mô tả chi tiết cho bộ phim này.';

    // Check if content is long enough to need a toggle
    const isLong = content.length > 280;

    return (
        <div className="text-slate-300 text-base leading-relaxed max-w-[70ch]">
            <div
                className={`transition-opacity duration-200 ${!showMore && isLong ? 'line-clamp-4' : ''}`}
                dangerouslySetInnerHTML={{ __html: content }}
            />
            {isLong && (
                <button
                    aria-label={showMore ? 'Thu gọn' : 'Xem thêm'}
                    className="mt-3 text-[13px] sm:text-sm font-semibold text-sky-400 hover:text-sky-300 inline-flex items-center gap-1.5 transition-colors cursor-pointer py-1 px-2.5 rounded-lg bg-sky-500/10 hover:bg-sky-500/20"
                    onClick={() => setShowMore(!showMore)}
                >
                    <span>{showMore ? 'Thu gọn nội dung' : 'Xem thêm toàn bộ nội dung'}</span>
                    <span className="text-[11px]">{showMore ? '▲' : '▼'}</span>
                </button>
            )}
        </div>
    );
};

export default ContentInfo;
