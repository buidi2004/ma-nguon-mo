export default function Loading() {
    return (
        <div className="page-container-0topside">
            <div className="section-container max-w-5xl">
                <div className="h-6 w-36 bg-slate-800 rounded animate-pulse mb-3" />
                <div className="h-10 w-72 bg-slate-800 rounded animate-pulse mb-8" />
                <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
                    <div className="lg:col-span-2 h-96 bg-[#121620] rounded-2xl animate-pulse" />
                    <div className="space-y-4">
                        <div className="h-28 bg-[#121620] rounded-2xl animate-pulse" />
                        <div className="h-28 bg-[#121620] rounded-2xl animate-pulse" />
                    </div>
                </div>
            </div>
        </div>
    );
}

