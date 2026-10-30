
import './globals.css'
import { Inter } from 'next/font/google'

import Header from '@/components/Header/Header'
import Footer from '@/components/Footer/Footer'
import { SaveProvider } from '@/contexts/saveContext'
import SavedButton from '@/components/SavedButton/SavedButton'

const inter = Inter({ subsets: ['latin'] })

export const metadata = {
    title: {
        default: 'OpenFlix - Xem Phim Online Miễn Phí Chuẩn HD & 4K',
        template: '%s | OpenFlix',
    },
    description: 'Nền tảng xem phim trực tuyến miễn phí chất lượng cao Full HD và 4K, cập nhật liên tục phim mới, phim chiếu rạp, phim bộ và hoạt hình Anime không giật lag.',
    keywords: ['OpenFlix', 'xem phim online', 'phim mới', 'phim chiếu rạp', 'phim lẻ', 'phim bộ', 'anime', 'phim hay', 'xem phim miễn phí'],
    generator: 'Next.js',
    applicationName: 'OpenFlix',
    authors: [{ name: 'OpenFlix Team' }],
}

export default function RootLayout({ children }) {
    return (
        <html lang="vi">
            <body className={inter.className}>
                <SaveProvider>
                    {/* ------ Header Navigation Bar ------ */}
                    <Header />

                    {/* Quick Bookmark Floating Action */}
                    <div className="fixed bottom-8 right-8 z-40">
                        <SavedButton />
                    </div>

                    {/* ------ Child route rendering ------ */}
                    <main className="min-h-[100dvh]">
                        {children}
                    </main>

                    {/* ------ Footer ------ */}
                    <Footer />
                </SaveProvider>
            </body>
        </html>
    )
}
