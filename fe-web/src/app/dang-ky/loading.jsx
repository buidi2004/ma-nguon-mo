export default function Loading() {
    return (
        <div className="min-h-[100dvh] pt-28 pb-20 bg-[#08090c] flex items-center justify-center px-4">
            <div className="w-full max-w-md p-8 rounded-2xl bg-[#121620] border border-white/10 animate-pulse space-y-4">
                <div className="h-6 w-32 bg-slate-800 rounded mx-auto" />
                <div className="h-8 w-48 bg-slate-800 rounded mx-auto" />
                <div className="h-10 w-full bg-slate-800 rounded" />
                <div className="h-10 w-full bg-slate-800 rounded" />
                <div className="h-10 w-full bg-slate-800 rounded" />
                <div className="h-12 w-full bg-slate-800 rounded" />
            </div>
        </div>
    );
}

