export default function Loading() {
    return (
        <div className="page-container-0topside">
            <div className="section-container space-y-8 animate-pulse">
                <div className="flex flex-col md:flex-row md:items-end justify-between gap-4 border-b border-white/10 pb-6" /* taste-skill-ignore: divider / tab-underline chrome */
>
                    <div className="space-y-2">
                        <div className="h-8 w-56 bg-slate-800 rounded" />
                        <div className="h-4 w-80 bg-slate-800/60 rounded" />
                    </div>
                </div>
                <div className="aspect-video bg-[#121620] rounded-2xl" />
                <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
                    <div className="h-44 bg-[#121620] rounded-xl" />
                    <div className="h-44 bg-[#121620] rounded-xl" />
                    <div className="h-44 bg-[#121620] rounded-xl" />
                    <div className="h-44 bg-[#121620] rounded-xl" />
                </div>
            </div>
        </div>
    );
}

