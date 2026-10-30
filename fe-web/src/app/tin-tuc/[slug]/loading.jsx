export default function Loading() {
    return (
        <div className="page-container-0topside">
            <div className="section-container max-w-4xl mx-auto space-y-8 animate-pulse">
                <div className="h-4 w-36 bg-slate-800 rounded" />
                <div className="space-y-3">
                    <div className="h-5 w-24 bg-slate-800 rounded" />
                    <div className="h-10 w-full max-w-2xl bg-slate-800 rounded" />
                    <div className="h-12 w-full bg-[#121620] rounded-xl" />
                </div>
                <div className="aspect-video bg-[#121620] rounded-2xl" />
                <div className="space-y-4">
                    <div className="h-6 w-1/2 bg-slate-800 rounded" />
                    <div className="h-20 w-full bg-[#121620] rounded-xl" />
                    <div className="h-6 w-1/3 bg-slate-800 rounded" />
                    <div className="h-20 w-full bg-[#121620] rounded-xl" />
                </div>
            </div>
        </div>
    );
}

