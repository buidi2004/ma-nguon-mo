/** @type {import('tailwindcss').Config} */
module.exports = {
    content: [
        './src/pages/**/*.{js,ts,jsx,tsx,mdx}',
        './src/components/**/*.{js,ts,jsx,tsx,mdx}',
        './src/app/**/*.{js,ts,jsx,tsx,mdx}',
    ],
    theme: {
        extend: {
            colors: {
                // Sky Blue brand colors
                'primary': '#0ea5e9',       // Sky Blue 500
                'primary-hv': '#0284c7',    // Sky Blue 600
                'primary-glow': '#38bdf8',  // Sky Blue 400
                'accent': '#06b6d4',        // Cyan 500
                'secondary': '#38bdf8',     // Sky Blue 400

                // Pure Cinema Dark Black
                'background': '#08090c',     // Deepest Cinema Black
                'background-alt': '#0e1118',
                'section-bg': '#121620',
                'surface': '#131722',
                'surface-hover': '#1a2030',
                'card': '#10141e',

                // Borders & Dividers
                'border': 'rgba(255, 255, 255, 0.08)',
                'border-glow': 'rgba(56, 189, 248, 0.3)',
                'divider': 'rgba(255, 255, 255, 0.1)',

                // Typography
                'heading': '#ffffff',
                'subheading': '#94a3b8',    // Slate 400
                'text': '#cbd5e1',          // Slate 300
                'muted': '#64748b',
            },
            boxShadow: {
                'neon': '0 0 25px -5px rgba(14, 165, 233, 0.4)',
                'neon-lg': '0 0 35px -5px rgba(14, 165, 233, 0.6)',
                'card-hover': '0 10px 30px -10px rgba(0, 0, 0, 0.8), 0 0 20px -5px rgba(14, 165, 233, 0.3)',
            },
        },
    },
    plugins: [],
}
