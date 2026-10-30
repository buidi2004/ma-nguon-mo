/** @type {import('next').NextConfig} */
const nextConfig = {
    images: {
        unoptimized: true,
        remotePatterns: [
            {
                protocol: 'http',
                hostname: '180.93.120.246',
            },
            {
                protocol: 'http',
                hostname: '180.93.120.246',
                port: '8090',
            },
            {
                protocol: 'https',
                hostname: '180.93.120.246',
            },
            {
                protocol: 'http',
                hostname: '127.0.0.1',
            },
            {
                protocol: 'http',
                hostname: 'localhost',
            },
            {
                protocol: 'https',
                hostname: '**.ophim*.cc',
            },
        ],
    },
    async rewrites() {
        return [
            {
                source: '/posters/:path*',
                destination: 'http://180.93.120.246/posters/:path*',
            },
            {
                source: '/videos/:path*',
                destination: 'http://180.93.120.246/videos/:path*',
            },
            {
                source: '/api/pocketbase/:path*',
                destination: 'http://180.93.120.246:8090/api/:path*',
            },
        ];
    },
}

module.exports = nextConfig
