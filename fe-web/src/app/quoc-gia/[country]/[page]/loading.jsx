export default function Loading() {
    return (
        <div className="page-container-0topside">
            <div className="section-container">
                <div className="h-8 w-48 bg-slate-800 rounded-lg animate-pulse mb-8"></div>
                <div className="movies-grid">
                    {[...Array(12)].map((_, index) => (
                        <div key={index} className="aspect-[2/3] rounded-xl bg-slate-900 overflow-hidden relative border border-white/5">
                            <div className="skeleton"></div>
                        </div>
                    ))}
                </div>
            </div>
        </div>
    );
}

