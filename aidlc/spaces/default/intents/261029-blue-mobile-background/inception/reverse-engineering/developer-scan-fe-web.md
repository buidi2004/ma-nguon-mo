## Developer Code Scan Results

### Scan Coverage
- **Analyzed deeply**:
  - `./README.md`, `./package.json`, `./next.config.js`, `./tailwind.config.js`, `./postcss.config.js`, `./jsconfig.json`
  - `./src/app/` — root layout, homepage, global styles, loading boundary, and every route/page and route loading component
  - `./src/components/` — all component JSX and CSS modules, including header, carousel, movie rails/cards/details/player, saved-list, pagination, footer, and blur wrapper
  - `./src/functions/` — all four remote data-fetch functions
  - `./src/contexts/` and `./src/hooks/`
- **Skimmed only**: `./package-lock.json` (dependency lockfile), `./public/` and `./public/thumbnails/` (asset filenames and roles; binary image contents not inspected), `./.git/` (repository metadata)
- **Left out**:
  - `./node_modules/` — installed dependencies, ignored by `.gitignore`
  - `./.next/` — Next.js generated build/cache output, ignored by `.gitignore`

### Packages Found
- `joyfilm` — web frontend — JavaScript/JSX — movie discovery, detail, search, saved-list and playback UI

### Build System
- **Type**: npm with Next.js 13.4.19
- **Config Files**: `package.json`, `package-lock.json`, `next.config.js`, `postcss.config.js`, `tailwind.config.js`, `jsconfig.json`
- **Build Dependencies**: Next.js builds the `src/app` App Router; Tailwind CSS and PostCSS process styles; React supplies UI and client state. No workspace packages were found.

### APIs Discovered
- REST/JSON — external JoyFilm server (`getHomePageMovies`, `getPageMovies`, `searchMovies`) — home data, category pages, search; exact backend route contracts are not defined in this repository.
- REST/JSON — `https://ophim1.com/phim/{slug}` (`getMovie`) — movie details and episodes.
- Embedded media — remote iframe `link_embed` or ReactPlayer `link_m3u8`; provider contract is supplied by the movie data.
- No API route handlers or backend service implementation were found in this repo.

### Frameworks & Libraries
- Next.js — 13.4.19 — App Router, server rendering, routing, metadata, image optimization
- React / React DOM — 18.2.0 — UI and client-side state
- Tailwind CSS — 3.3.3 — utility styles and theme tokens
- React Player — declared `^2.13.0` — HLS/embedded playback
- React Responsive Carousel — declared `^3.2.23` — homepage hero carousel
- React Slick / Slick Carousel — declared `^0.29.0` / `^1.8.1` — movie rails
- Sharp — declared `^0.32.5` — Next image processing
- PostCSS / Autoprefixer — 8.4.29 / 10.4.15 — CSS processing

### Test Coverage
- **Test Directories**: None found in `fe-web`.
- **Test Frameworks**: None declared in `package.json`.
- **Coverage Config**: Absent.

### Code Quality Indicators
- **Linting**: `next lint` script is declared; no dedicated ESLint config was found in the listed project root.
- **CI/CD**: No pipeline configuration found in the `fe-web` project root. README describes Vercel frontend hosting and Netlify backend hosting.
- **Documentation**: Vietnamese README describes the product, stack, deployment and screenshots. Source comments explain major UI sections.

### Technical Debt Signals
- Fetch helpers throw a generic error on non-OK responses; client-side movie detail/search effects have no visible catch/retry path.
- `searchMovies` interpolates the query directly into a URL; inputs with reserved characters may be malformed.
- Saved-list initialization parses `localStorage` JSON without guarding malformed stored data.
- Mobile UI uses a dedicated compact carousel layout, but this repository contains no selectable blue color mode or theme state. The shared default page background is dark (`#1a1a1a`); blue appears as a secondary accent (`#0ea5e9`).
- `MovieInfoSection` injects API-provided HTML into the page with `dangerouslySetInnerHTML` for descriptions; source does not show sanitization.

## Handoff Summary
- **Intent-relevant finding**: Home content is assembled in `src/app/page.jsx` from remote movie data and rendered as a hero carousel followed by five movie rails. Mobile carousel sizing and text placement are in `src/components/CarouselThumbnails/CarouselThumbnails.css` (max-width 767px); global theme colors are in `tailwind.config.js` and the home wrapper uses `bg-background`. No blue-mode selector/state exists in this repository.
- **Risks / follow-up**: The requested wording refers to mobile and a selectable blue mode, but the registered `fe-web` repo is a Next.js web frontend and does not contain such a mode. The workspace root contains a separate Flutter app; confirm the target repo before implementing if the blue-mode control is there. This scan did not inspect or modify the root Flutter application.
