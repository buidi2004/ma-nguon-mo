export default function Loading() {
    return (
        <div className="min-h-[100dvh] bg-[#08090c] pt-24 pb-20 animate-pulse">
            <div className="section-container space-y-8">
                <div className="space-y-3">
                    <div className="h-4 w-32 bg-slate-800 rounded"></div>
                    <div className="h-8 w-72 bg-slate-800 rounded"></div>
                    <div className="h-4 w-96 bg-slate-800 rounded"></div>
                </div>

                <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5">
                    {[1, 2, 3, 4, 5, 6, 7, 8].map((i) => (
                        <div key={i} className="p-6 rounded-2xl bg-[#121620] border border-white/5 space-y-4">
                            <div className="w-16 h-16 rounded-full bg-slate-800"></div>
                            <div className="h-5 w-40 bg-slate-800 rounded"></div>
                            <div className="h-4 w-28 bg-slate-800 rounded"></div>
                            <div className="h-12 w-full bg-slate-800/60 rounded"></div>
                        </div>
                    ))}
                </div>
            </div>
        </div>
    );
}

