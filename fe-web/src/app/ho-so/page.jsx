'use client'

import { useState, useEffect } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";

export default function ProfilesPage() {
    const router = useRouter();
    const [isManaging, setIsManaging] = useState(false);
    const [activeProfileId, setActiveProfileId] = useState("p1");

    const [profiles, setProfiles] = useState([
        { id: "p1", name: "Bùi Đi", color: "bg-sky-500", isKids: false, avatar: "B" },
        { id: "p2", name: "Gia Đình", color: "bg-emerald-500", isKids: false, avatar: "G" },
        { id: "p3", name: "Trẻ Em", color: "bg-amber-500", isKids: true, avatar: "K" },
        { id: "p4", name: "Bạn Bè", color: "bg-blue-600", isKids: false, avatar: "F" },
    ]);

    useEffect(() => {
        try {
            if (typeof window !== "undefined") {
                const saved = localStorage.getItem("openflix_activeProfile");
                if (saved) {
                    const parsed = JSON.parse(saved);
                    if (parsed?.id) setActiveProfileId(parsed.id);
                }
            }
        } catch (e) {
            console.warn(e);
        }
    }, []);

    const handleSelectProfile = (profile) => {
        if (isManaging) {
            const newName = prompt("Nhập tên mới cho hồ sơ:", profile.name);
            if (newName && newName.trim()) {
                setProfiles((prev) =>
                    prev.map((p) => (p.id === profile.id ? { ...p, name: newName.trim() } : p))
                );
            }
            return;
        }

        try {
            if (typeof window !== "undefined") {
                localStorage.setItem("openflix_activeProfile", JSON.stringify(profile));
            }
        } catch (e) {
            console.warn(e);
        }
        router.push("/");
    };

    const handleAddProfile = () => {
        const name = prompt("Nhập tên cho hồ sơ mới:");
        if (!name || !name.trim()) return;

        const newProfile = {
            id: `p${Date.now()}`,
            name: name.trim(),
            color: "bg-sky-600",
            isKids: false,
            avatar: name.trim().charAt(0).toUpperCase(),
        };
        setProfiles((prev) => [...prev, newProfile]);
    };

    return (
        <div className="min-h-[100dvh] pt-24 pb-20 bg-[#08090c] flex flex-col items-center justify-center px-4">
            <div className="max-w-3xl w-full text-center space-y-8 animate-fadeIn">
                <div className="space-y-2">
                    <span className="text-xs font-semibold text-sky-400">
                        Cá nhân hóa trải nghiệm
                    </span>
                    <h1 className="text-3xl sm:text-4xl md:text-5xl font-black text-white">
                        Ai Đang Xem?
                    </h1>
                    <p className="text-sm text-slate-400">
                        {isManaging
                            ? "Chạm vào hồ sơ bất kỳ để chỉnh sửa tên hiển thị"
                            : "Chọn hồ sơ của bạn để đồng bộ lịch sử xem và danh sách phim"}
                    </p>
                </div>

                {/* Profiles Grid */}
                <div className="flex flex-wrap items-center justify-center gap-6 sm:gap-8 pt-4">
                    {profiles.map((profile) => {
                        const isActive = profile.id === activeProfileId;
                        return (
                            <button
                                key={profile.id}
                                type="button"
                                onClick={() => handleSelectProfile(profile)}
                                className="group flex flex-col items-center gap-3 cursor-pointer focus:outline-none"
                            >
                                <div
                                    className={`relative w-24 sm:w-28 h-24 sm:h-28 rounded-2xl ${profile.color} flex items-center justify-center text-white text-3xl sm:text-4xl font-black transition-transform group-hover:scale-105 group-hover:ring-4 group-hover:ring-sky-400/80 ${
                                        isActive ? "ring-4 ring-sky-400" : "border-2 border-white/20"
                                    }`}
                                >
                                    <span>{profile.avatar}</span>
                                    {profile.isKids && (
                                        <span className="absolute bottom-1 right-1 text-[10px] font-bold px-1.5 py-0.5 rounded bg-black/60 text-white">
                                            KIDS
                                        </span>
                                    )}
                                    {isManaging && (
                                        <div className="absolute inset-0 bg-black/50 rounded-2xl flex items-center justify-center">
                                            <svg className="w-7 h-7 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M15.232 5.232l3.536 3.536m-2.036-5.036a2.5 2.5 0 113.536 3.536L6.5 21.036H3v-3.572L16.732 3.732z" />
                                            </svg>
                                        </div>
                                    )}
                                </div>
                                <span className="text-sm sm:text-base font-semibold text-slate-300 group-hover:text-white transition-colors max-w-[120px] truncate">
                                    {profile.name}
                                </span>
                            </button>
                        );
                    })}

                    {/* Add Profile Button */}
                    <button
                        type="button"
                        onClick={handleAddProfile}
                        className="group flex flex-col items-center gap-3 cursor-pointer focus:outline-none"
                    >
                        <div className="w-24 sm:w-28 h-24 sm:h-28 rounded-2xl bg-[#121620] border-2 border-dashed border-white/25 hover:border-sky-400 flex items-center justify-center text-slate-400 group-hover:text-sky-300 transition-colors group-hover:scale-105">
                            <svg className="w-9 h-9" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 4v16m8-8H4" />
                            </svg>
                        </div>
                        <span className="text-sm sm:text-base font-medium text-slate-400 group-hover:text-sky-400 transition-colors">
                            Thêm hồ sơ
                        </span>
                    </button>
                </div>

                {/* Bottom Controls */}
                <div className="pt-8 flex flex-wrap items-center justify-center gap-4">
                    <button
                        type="button"
                        onClick={() => setIsManaging(!isManaging)}
                        className={`text-xs sm:text-sm px-6 py-2.5 rounded-xl font-semibold border transition-colors cursor-pointer ${
                            isManaging
                                ? "bg-sky-500 text-slate-950 border-sky-400"
                                : "bg-white/[0.06] text-slate-300 hover:text-white border-white/15 hover:border-sky-400"
                        }`}
                    >
                        {isManaging ? "Hoàn Tất Quản Lý" : "Quản Lý Hồ Sơ"}
                    </button>
                    <Link
                        href="/tai-khoan"
                        className="text-xs sm:text-sm px-6 py-2.5 rounded-xl font-medium bg-white/[0.06] hover:bg-white/10 text-slate-300 hover:text-white border border-white/15 transition-colors"
                    >
                        Cài Đặt Tài Khoản →
                    </Link>
                </div>
            </div>
        </div>
    );
}
