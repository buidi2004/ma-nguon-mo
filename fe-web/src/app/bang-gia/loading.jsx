export default function Loading() {
    return (
        <div className="page-container-0topside">
            <div className="section-container max-w-6xl animate-pulse space-y-8">
                <div className="h-6 w-32 bg-slate-800 rounded mx-auto" />
                <div className="h-10 w-72 bg-slate-800 rounded mx-auto" />
                <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                    <div className="h-96 bg-[#121620] rounded-2xl" />
                    <div className="h-96 bg-[#121620] rounded-2xl" />
                    <div className="h-96 bg-[#121620] rounded-2xl" />
                </div>
            </div>
        </div>
    );
}

