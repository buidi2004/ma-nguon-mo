import Link from "next/link";

const PageButtons = ({ curr, total, url }) => {
    curr = parseInt(curr, 10) || 1;
    total = parseInt(total, 10) || 1;

    if (total <= 1) return null;

    const buttons = [];

    // Previous Button
    if (curr > 1) {
        buttons.push(
            <Link
                href={`/${url}/${curr - 1}`}
                className="episode-btn px-3.5 text-xs sm:text-sm"
                key="prev"
                aria-label="Trang trước"
            >
                ← Trước
            </Link>
        );
    }

    let flag = true;
    for (let i = 1; i <= total; i++) {
        if (i === 1 || i === total || i === curr || i === curr - 1 || i === curr - 2 || i === curr + 1 || i === curr + 2) {
            if (!flag) {
                buttons.push(
                    <div key={`dots-${i}`} className="text-slate-500 px-2 flex items-center justify-center font-bold">
                        ...
                    </div>
                );
                flag = true;
            }
            buttons.push(
                <Link
                    href={`/${url}/${i}`}
                    className={`episode-btn ${i === curr ? "episode-btn-active" : ""}`}
                    key={i}
                >
                    {i}
                </Link>
            );
        } else {
            flag = false;
        }
    }

    // Next Button
    if (curr < total) {
        buttons.push(
            <Link
                href={`/${url}/${curr + 1}`}
                className="episode-btn px-3.5 text-xs sm:text-sm"
                key="next"
                aria-label="Trang sau"
            >
                Sau →
            </Link>
        );
    }

    return (
        <div className="flex flex-wrap items-center justify-center gap-1.5 py-4">
            {buttons}
        </div>
    );
};

export default PageButtons;
