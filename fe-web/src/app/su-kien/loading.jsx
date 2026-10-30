export default function Loading() {
    return (
        <div className="min-h-[100dvh] bg-[#08090c] pt-24 pb-20 animate-pulse">
            <div className="section-container space-y-8">
                <div className="space-y-3">
                    <div className="h-4 w-36 bg-slate-800 rounded"></div>
                    <div className="h-8 w-80 bg-slate-800 rounded"></div>
                    <div className="h-4 w-96 bg-slate-800 rounded"></div>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                    {[1, 2, 3, 4].map((i) => (
                        <div key={i} className="h-64 rounded-2xl bg-[#121620] border border-white/5"></div>
                    ))}
                </div>
            </div>
        </div>
    );
}

