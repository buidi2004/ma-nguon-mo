export default function Loading() {
    return (
        <div className="min-h-[100dvh] bg-[#08090c] pt-24 pb-20 animate-pulse">
            <div className="section-container space-y-8">
                <div className="space-y-3">
                    <div className="h-4 w-36 bg-slate-800 rounded"></div>
                    <div className="h-8 w-80 bg-slate-800 rounded"></div>
                    <div className="h-4 w-96 bg-slate-800 rounded"></div>
                </div>

                <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
                    {[1, 2, 3, 4].map((i) => (
                        <div key={i} className="h-28 rounded-2xl bg-[#121620] border border-white/5"></div>
                    ))}
                </div>

                <div className="p-6 rounded-2xl bg-[#121620] border border-white/5 space-y-6">
                    <div className="h-6 w-64 bg-slate-800 rounded"></div>
                    <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 gap-5">
                        {[1, 2, 3, 4].map((i) => (
                            <div key={i} className="aspect-[2/3] rounded-xl bg-slate-800/70"></div>
                        ))}
                    </div>
                </div>
            </div>
        </div>
    );
}

