export default function Loading() {
    return (
        <div className="page-container-0topside">
            <div className="section-container animate-pulse space-y-6">
                <div className="flex items-center justify-between border-b border-white/10 pb-4" /* taste-skill-ignore: divider / tab-underline chrome */
>
                    <div className="space-y-2">
                        <div className="h-8 w-48 bg-slate-800 rounded" />
                        <div className="h-4 w-72 bg-slate-800/60 rounded" />
                    </div>
                </div>
                <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 xl:grid-cols-6 gap-4">
                    {Array.from({ length: 12 }).map((_, i) => (
                        <div key={i} className="aspect-[2/3] bg-[#121620] rounded-xl border border-white/5" />
                    ))}
                </div>
            </div>
        </div>
    );
}

