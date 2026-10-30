## Developer Code Scan Results

### Scan Coverage
- **Analyzed deeply**: repository root manifests and source/test architecture; `src/, ui/src/, codegraph-kernel/src/, telemetry-worker/, telemetry-dashboard/, scripts/, __tests__/
- **Skimmed only**: long-form documentation, release history, static media/assets, and host-specific generated templates.
- **Left out**: ignored and generated/dependency outputs (`node_modules/`, `dist/`, build outputs, caches).

### Packages Found
- **codegraph** — application/tooling package — TypeScript, Rust, Svelte, SQL — local semantic code graph and agent viewer.

### Build System
- **Type**: npm workspaces + TypeScript/Vite + Cargo/N-API.
- **Config Files**: `package.json`, `tsconfig*.json`, `ui/vite.config.ts`, `codegraph-kernel/Cargo.toml`, `vitest*.mts`.
- **Build Dependencies**: CLI TS → copied parser assets → Svelte viewer → bundled CLI; Rust kernel builds native module.

### APIs Discovered
- MCP tools and CLI query commands; local UI-server HTTP endpoints; optional telemetry Worker.

### Frameworks & Libraries
- Node.js >=20<25, TypeScript 5, Svelte/Vite, Vitest, tree-sitter WASM, Rust N-API, SQLite.

### Test Coverage
- **Test Directories**: `__tests__/` (unit, integration, evaluation, fixtures); UI model/component tests.
- **Test Frameworks**: Vitest and jsdom.
- **Coverage Config**: not confirmed in reviewed manifests.

### Code Quality Indicators
- **Linting**: TypeScript/Vitest/Vite build checks; release parity scripts.
- **CI/CD**: GitHub workflow files and release scripts are present.
- **Documentation**: detailed README and module-specific docs; no executable verification run during this scan.

### Technical Debt Signals
- Cross-language parser grammar and WASM/Rust version parity must be maintained.
- This repository is not the Flutter application, so it does not contain the mobile theme target.

## Handoff Summary
- **Intent-relevant finding**: The blue mobile UI should be implemented in the Flutter workspace; this repository provides no Flutter screens or Dart theme.
- **Risks / follow-up**: Keep this code knowledge scoped to the registered repository; do not apply the shader or screen widget here.
