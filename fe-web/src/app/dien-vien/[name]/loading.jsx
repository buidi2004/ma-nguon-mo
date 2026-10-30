export default function Loading() {
    return (
        <div className="min-h-[100dvh] bg-[#08090c] pt-24 pb-20 animate-pulse">
            <div className="section-container space-y-8">
                <div className="p-8 rounded-2xl bg-[#121620] border border-white/5 flex flex-col md:flex-row gap-6">
                    <div className="w-28 h-28 rounded-full bg-slate-800"></div>
                    <div className="space-y-3 flex-1">
                        <div className="h-4 w-32 bg-slate-800 rounded"></div>
                        <div className="h-8 w-64 bg-slate-800 rounded"></div>
                        <div className="h-4 w-full bg-slate-800 rounded"></div>
                        <div className="h-4 w-4/5 bg-slate-800 rounded"></div>
                    </div>
                </div>

                <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5">
                    {[1, 2, 3, 4].map((i) => (
                        <div key={i} className="aspect-[2/3] rounded-2xl bg-[#121620] border border-white/5"></div>
                    ))}
                </div>
            </div>
        </div>
    );
}

