# Developer Code Scan — fe-web

## Scan Coverage
- **Analyzed deeply**: `README.md`, `package.json`, `src/app/`, `src/components/`, `src/contexts/`, `src/functions/`, `src/hooks/`, `src/lib/`, and `public/` (route and component inventory from the complete file listing; key theme and router structure checked through the root CodeGraph index where available).
- **Skimmed only**: image assets under `public/` and route-specific loading pages.
- **Left out**: `node_modules/`, `.next/`, and generated build output.

## Packages Found
- `joyfilm` — Next.js movie-streaming website — React/JavaScript.
- `src/app/` — App Router pages and route-level loading/error/not-found UI.
- `src/components/` — movie cards, slides, carousel, header/footer, media and saved-button UI.
- `src/functions/` — PocketBase and movie-fetch/search/pagination functions.
- `src/contexts/` — saved-film context.

## Build System
- **Type**: npm / Next.js 13 App Router.
- **Config Files**: `package.json`, `next.config.js`, `jsconfig.json`, `tailwind.config.js`, `postcss.config.js`.
- **Build Dependencies**: Next.js 13.4.19, React 18.2, Tailwind CSS 3.3, PocketBase client usage in source.

## APIs Discovered
- Client/server data functions for movie retrieval, search and pagination; PocketBase is configured in `src/functions/pocketbase.js`.
- No new external HTTP API contract was part of the light-mode change.

## Frameworks & Libraries
- Next.js, React, Tailwind CSS, `react-player`, carousel/slider libraries, `sharp`, and `tailwind-merge` (versions in `package.json`).

## Test Coverage
- **Test Directories**: no test directory appeared in the file inventory.
- **Test Frameworks**: none declared in `package.json`.
- **Coverage Config**: absent from inspected package manifest.

## Code Quality Indicators
- **Linting**: `next lint` script is declared.
- **CI/CD**: no pipeline was confirmed in the inspected file inventory.
- **Documentation**: Vietnamese README describes JoyFilm, its tech stack and page previews.

## Technical Debt Signals
- README describes a MERN stack while this repository contains the Next.js front end and references a separate server. That description is broader than the repository's actual front-end boundary.

## Handoff Summary
- **Intent-relevant finding**: `fe-web` is a Next.js JoyFilm website, distinct from the Flutter OpenFlix app at the workspace root. Its route pages are file-based under `src/app/`; no evidence here can establish the visual state of the 42 Flutter screens.
- **Risks / follow-up**: The root CodeGraph index did not uniquely resolve nested `fe-web/src/*` paths. No app was run and no screenshots were captured; visual acceptance is NOT RUN.
