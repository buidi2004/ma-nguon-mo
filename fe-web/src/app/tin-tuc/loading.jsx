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
                    <div className="h-9 w-64 bg-[#121620] rounded-xl" />
                </div>
                <div className="h-10 w-full max-w-md bg-[#121620] rounded-xl" />
                <div className="h-72 bg-[#121620] rounded-2xl" />
                <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                    <div className="h-64 bg-[#121620] rounded-2xl" />
                    <div className="h-64 bg-[#121620] rounded-2xl" />
                    <div className="h-64 bg-[#121620] rounded-2xl" />
                </div>
            </div>
        </div>
    );
}

