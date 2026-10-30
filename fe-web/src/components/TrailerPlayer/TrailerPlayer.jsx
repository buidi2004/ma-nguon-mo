'use client'

import dynamic from 'next/dynamic';

const ReactPlayer = dynamic(() => import('react-player'), {
    ssr: false,
    loading: () => (
        <div className="w-full h-full bg-slate-900 flex items-center justify-center">
            <div className="loader"></div>
        </div>
    ),
});

const TrailerPlayer = ({ url, poster }) => {
    if (!url) return null;

    return (
        <div className="aspect-video mx-auto w-full bg-black rounded-xl overflow-hidden relative">
            <ReactPlayer
                width="100%"
                height="100%"
                url={url}
                pip={true}
                controls={true}
                light={poster || true}
                playIcon={
                    <button
                        type="button"
                        aria-label="Phát video trailer"
                        className="w-16 h-16 rounded-full bg-sky-500 hover:bg-sky-400 text-slate-950 flex items-center justify-center transition-transform hover:scale-110 active:scale-95 cursor-pointer"
                    >
                        <svg className="w-8 h-8 fill-current translate-x-0.5" viewBox="0 0 24 24">
                            <polygon points="5 3 19 12 5 21 5 3"></polygon>
                        </svg>
                    </button>
                }
            />
        </div>
    );
};

export default TrailerPlayer;
