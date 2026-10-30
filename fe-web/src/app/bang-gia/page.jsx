'use client'

import { useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";

export default function PlansPage() {
    const router = useRouter();
    const [selectedPlanId, setSelectedPlanId] = useState("premium");
    const [activated, setActivated] = useState(false);

    const plans = [
        {
            id: "standard",
            name: "Gói Cơ Bản",
            price: "70.000 đ",
            period: "/tháng",
            resolution: "HD 720p",
            devices: "1 thiết bị xem cùng lúc",
            isPopular: false,
            perks: [
                "Xem không giới hạn kho phim",
                "Độ phân giải chuẩn HD 720p",
                "Hỗ trợ trên Điện thoại, Máy tính",
                "Lưu tối đa 50 phim trong danh sách",
            ],
        },
        {
            id: "premium",
            name: "Gói Tiêu Chuẩn",
            price: "120.000 đ",
            period: "/tháng",
            resolution: "Full HD 1080p",
            devices: "2 thiết bị xem cùng lúc",
            isPopular: true,
            perks: [
                "Xem không giới hạn kho phim Full HD",
                "Âm thanh vòm chất lượng cao",
                "Xem trên TV, Máy tính, Điện thoại",
                "Tốc độ tải phim đa luồng siêu tốc",
                "Tải xuống xem ngoại tuyến",
            ],
        },
        {
            id: "ultra",
            name: "Gói Cao Cấp Ultra 4K",
            price: "180.000 đ",
            period: "/tháng",
            resolution: "Ultra HD 4K & HDR",
            devices: "4 thiết bị xem cùng lúc",
            isPopular: false,
            perks: [
                "Chất lượng đỉnh cao 4K Ultra HD & HDR",
                "Âm thanh không gian Dolby Atmos",
                "Không quảng cáo làm gián đoạn",
                "Ưu tiên suất chiếu rạp độc quyền",
                "Hỗ trợ kỹ thuật trực tiếp 24/7",
            ],
        },
    ];

    const handleSelectPlan = (plan) => {
        setSelectedPlanId(plan.id);
        try {
            if (typeof window !== "undefined") {
                const stored = localStorage.getItem("openflix_user") || "{}";
                const user = JSON.parse(stored);
                user.plan = plan.name;
                localStorage.setItem("openflix_user", JSON.stringify(user));
            }
        } catch (e) {
            console.warn(e);
        }
        setActivated(true);
        setTimeout(() => {
            router.push("/tai-khoan");
        }, 1200);
    };

    return (
        <div className="page-container-0topside">
            <div className="section-container max-w-6xl">
                {/* Header */}
                <div className="text-center max-w-2xl mx-auto space-y-3 mb-12">
                    <span className="text-xs font-semibold text-sky-400">
                        Bảng giá & Gói thành viên
                    </span>
                    <h1 className="text-3xl sm:text-4xl md:text-5xl font-black text-white">
                        Chọn Gói Dịch Vụ <span className="text-sky-400">OPENFLIX</span>
                    </h1>
                    <p className="text-sm text-slate-400 leading-relaxed">
                        Thưởng thức kho phim điện ảnh đỉnh cao không giới hạn. Nâng cấp hoặc hủy gói bất kỳ lúc nào mà không phát sinh chi phí ẩn.
                    </p>
                </div>

                {activated && (
                    <div className="p-4 mb-8 rounded-xl bg-emerald-500/15 border border-emerald-500/30 text-center text-sm font-semibold text-emerald-300">
                        Đã kích hoạt thành công gói dịch vụ! Đang chuyển hướng về trang tài khoản...
                    </div>
                )}

                {/* Plans Grid */}
                <div className="grid grid-cols-1 md:grid-cols-3 gap-6 lg:gap-8 items-stretch">
                    {plans.map((plan) => {
                        const isSelected = plan.id === selectedPlanId;
                        return (
                            <div
                                key={plan.id}
                                className={`relative flex flex-col justify-between p-6 sm:p-8 rounded-2xl bg-[#121620] border transition-all duration-200 ${
                                    plan.isPopular
                                        ? "border-sky-500 ring-2 ring-sky-500/30"
                                        : "border-white/10 hover:border-white/25"
                                }`}
                            >
                                {plan.isPopular && (
                                    <div className="absolute -top-3.5 left-1/2 -translate-x-1/2 px-3 py-1 rounded-full bg-sky-500 text-slate-950 font-black text-[11px] uppercase tracking-wider">
                                        Phổ biến nhất
                                    </div>
                                )}

                                <div className="space-y-4">
                                    <div>
                                        <h3 className="text-xl font-bold text-white">{plan.name}</h3>
                                        <div className="flex items-baseline gap-1 mt-2">
                                            <span className="text-3xl font-black text-white">{plan.price}</span>
                                            <span className="text-xs text-slate-400">{plan.period}</span>
                                        </div>
                                    </div>

                                    <div className="p-3 rounded-xl bg-[#08090c] border border-white/10 space-y-1.5 text-xs">
                                        <div className="flex items-center justify-between">
                                            <span className="text-slate-400">Độ phân giải:</span>
                                            <span className="text-sky-400 font-bold">{plan.resolution}</span>
                                        </div>
                                        <div className="flex items-center justify-between">
                                            <span className="text-slate-400">Thiết bị:</span>
                                            <span className="text-slate-200 font-medium">{plan.devices}</span>
                                        </div>
                                    </div>

                                    <ul className="space-y-2.5 text-xs text-slate-300 pt-2">
                                        {plan.perks.map((perk, i) => (
                                            <li key={i} className="flex items-start gap-2">
                                                <svg className="w-4 h-4 text-emerald-400 shrink-0 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M5 13l4 4L19 7" />
                                                </svg>
                                                <span>{perk}</span>
                                            </li>
                                        ))}
                                    </ul>
                                </div>

                                <div className="pt-8">
                                    <button
                                        type="button"
                                        onClick={() => handleSelectPlan(plan)}
                                        className={`w-full py-3 rounded-xl text-xs sm:text-sm font-bold transition-all cursor-pointer ${
                                            plan.isPopular
                                                ? "play-button-color"
                                                : "bg-white/[0.08] hover:bg-white/[0.15] text-white border border-white/15"
                                        }`}
                                    >
                                        {isSelected ? "Đã Chọn Gói Này" : "Chọn Gói " + plan.name}
                                    </button>
                                </div>
                            </div>
                        );
                    })}
                </div>

                {/* FAQ Notice */}
                <div className="mt-12 p-6 rounded-2xl bg-[#121620] border border-white/10 text-center max-w-3xl mx-auto space-y-2">
                    <h4 className="text-base font-bold text-white">Bạn có câu hỏi về thanh toán và hủy gói?</h4>
                    <p className="text-xs text-slate-400 leading-relaxed">
                        Bạn có thể hủy đăng ký bất cứ lúc nào trong trang Cài đặt tài khoản. Toàn bộ tính năng sẽ duy trì đến hết chu kỳ thanh toán đã đăng ký.
                    </p>
                    <div className="pt-2">
                        <Link href="/faq" className="text-xs text-sky-400 font-semibold hover:underline">
                            Đọc thêm câu hỏi thường gặp (FAQ) →
                        </Link>
                    </div>
                </div>
            </div>
        </div>
    );
}
