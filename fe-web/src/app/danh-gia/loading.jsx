export default function Loading() {
    return (
        <div className="min-h-[100dvh] bg-[#08090c] pt-24 pb-20 animate-pulse">
            <div className="section-container space-y-8">
                {/* Header Skeleton */}
                <div className="space-y-3">
                    <div className="h-4 w-32 bg-slate-800 rounded"></div>
                    <div className="h-8 w-72 bg-slate-800 rounded"></div>
                    <div className="h-4 w-96 bg-slate-800 rounded"></div>
                </div>

                {/* Rating Overview Grid Skeleton */}
                <div className="grid grid-cols-1 md:grid-cols-3 gap-6 p-6 rounded-2xl bg-[#121620] border border-white/5">
                    <div className="h-28 bg-slate-800/60 rounded-xl"></div>
                    <div className="md:col-span-2 h-28 bg-slate-800/60 rounded-xl"></div>
                </div>

                {/* Filter Ribbon Skeleton */}
                <div className="flex gap-2">
                    {[1, 2, 3, 4, 5].map((i) => (
                        <div key={i} className="h-10 w-28 bg-slate-800/80 rounded-xl"></div>
                    ))}
                </div>

                {/* Review Cards Grid Skeleton */}
                <div className="grid grid-cols-1 md:grid-cols-2 gap-5">
                    {[1, 2, 3, 4, 5, 6].map((i) => (
                        <div key={i} className="p-6 rounded-2xl bg-[#121620] border border-white/5 space-y-4">
                            <div className="flex items-center gap-3">
                                <div className="w-11 h-11 rounded-full bg-slate-800"></div>
                                <div className="space-y-2 flex-1">
                                    <div className="h-4 w-32 bg-slate-800 rounded"></div>
                                    <div className="h-3 w-20 bg-slate-800 rounded"></div>
                                </div>
                            </div>
                            <div className="h-4 w-full bg-slate-800 rounded"></div>
                            <div className="h-4 w-5/6 bg-slate-800 rounded"></div>
                            <div className="h-4 w-2/3 bg-slate-800 rounded"></div>
                        </div>
                    ))}
                </div>
            </div>
        </div>
    );
}

