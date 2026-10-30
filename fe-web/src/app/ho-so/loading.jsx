export default function Loading() {
    return (
        <div className="min-h-[100dvh] pt-24 pb-20 bg-[#08090c] flex flex-col items-center justify-center px-4">
            <div className="max-w-3xl w-full text-center space-y-6 animate-pulse">
                <div className="h-6 w-32 bg-slate-800 rounded mx-auto" />
                <div className="h-10 w-64 bg-slate-800 rounded mx-auto" />
                <div className="flex justify-center gap-6 pt-6">
                    <div className="w-28 h-28 bg-[#121620] rounded-2xl" />
                    <div className="w-28 h-28 bg-[#121620] rounded-2xl" />
                    <div className="w-28 h-28 bg-[#121620] rounded-2xl" />
                </div>
            </div>
        </div>
    );
}

