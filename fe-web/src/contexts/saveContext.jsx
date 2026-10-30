'use client'

import { useState, createContext, useEffect } from 'react';

const saveContext = createContext({
    saveList: [],
    setSaveList: () => {},
    isSaved: () => false,
    toggleSaveMovie: () => {},
});

function SaveProvider({ children }) {
    const [saveList, setSaveList] = useState([]);

    useEffect(() => {
        try {
            if (typeof window !== 'undefined') {
                const stored = localStorage.getItem('openflix_saveList') || localStorage.getItem('saveList');
                if (stored) {
                    const parsed = JSON.parse(stored);
                    if (Array.isArray(parsed)) {
                        setSaveList(parsed);
                    }
                }
            }
        } catch (e) {
            console.warn('[saveContext] Could not access localStorage:', e);
        }
    }, []);

    const isSaved = (movie) => {
        if (!movie) return false;
        const targetId = movie.id || movie._id || movie.slug || movie.name;
        return saveList.some((m) => {
            const mId = m?.id || m?._id || m?.slug || m?.name;
            return mId === targetId || (m?.name && movie?.name && m.name === movie.name);
        });
    };

    const toggleSaveMovie = (movie) => {
        if (!movie) return;
        const targetId = movie.id || movie._id || movie.slug || movie.name;
        const exists = isSaved(movie);

        let updatedList;
        if (exists) {
            updatedList = saveList.filter((m) => {
                const mId = m?.id || m?._id || m?.slug || m?.name;
                return mId !== targetId && m?.name !== movie.name;
            });
        } else {
            updatedList = [...saveList, movie];
        }

        setSaveList(updatedList);
        try {
            if (typeof window !== 'undefined') {
                localStorage.setItem('openflix_saveList', JSON.stringify(updatedList));
                localStorage.setItem('saveList', JSON.stringify(updatedList));
            }
        } catch (e) {
            console.warn('[saveContext] Could not write to localStorage:', e);
        }
    };

    const value = {
        saveList,
        setSaveList,
        isSaved,
        toggleSaveMovie,
    };

    return (
        <saveContext.Provider value={value}>
            {children}
        </saveContext.Provider>
    );
}

export { saveContext, SaveProvider };
