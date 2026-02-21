# Caddy Stats — Frontend

React + Vite + TypeScript frontend for the Caddy Stats golf analytics platform (Strik3Zone).

---

## Stack

| Tool | Version | Purpose |
|---|---|---|
| React | 18 | UI framework |
| Vite | 5 | Build tool + dev server |
| TypeScript | 5 | Type safety |
| TanStack Query | 5 | Data fetching + caching |
| TanStack Table | 8 | Data tables |
| React Router | 6 | Client-side routing |
| Tailwind CSS | 3 | Utility-first styling |
| PostCSS + Autoprefixer | 8 / 10 | CSS processing pipeline |
| Chart.js | 4 | Data visualisations |
| graphql-request | 7 | GraphQL client |

---

## Local Development

```bash
npm install
npm run dev
```

The dev server starts at <http://localhost:5173>.

To run the full stack via Docker (from the repo root):

```bash
cp .env.example .env
docker compose --profile dev up --build
```

---

## Available Scripts

| Command | Description |
|---|---|
| `npm run dev` | Start Vite dev server (port 5173) |
| `npm run build` | Type-check + production build |
| `npm run preview` | Preview the production build locally |

---

## Environment Variables

The frontend reads these variables at build / dev time. Copy `.env.example` at the repo root and set:

| Variable | Default | Description |
|---|---|---|
| `VITE_API_HTTP_URL` | `http://localhost:8000` | Backend REST base URL |
| `VITE_API_GRAPHQL_URL` | `http://localhost:8000/graphql` | GraphQL endpoint |

---

## CSS — Tailwind via PostCSS

Tailwind CSS directives (`@tailwind base`, `@tailwind components`, `@tailwind utilities`) are processed by Vite through the PostCSS pipeline. Two config files are required:

| File | Purpose |
|---|---|
| `postcss.config.cjs` | Registers `tailwindcss` and `autoprefixer` as PostCSS plugins |
| `tailwind.config.js` | Content paths, dark-mode strategy (`class`), theme extensions |

> **Why `.cjs`?** `package.json` sets `"type": "module"`, so the PostCSS config must use the CommonJS extension (`.cjs`) to be loaded as CommonJS by Vite. A standard `.js` file would be treated as ESM and fail to export `module.exports`.

Without `postcss.config.cjs` in place, Vite will surface _"Unknown at rule @tailwind"_ errors and Tailwind classes will not be applied.

---

## Project Structure

```
src/
├── app/
│   ├── providers/     # QueryProvider, ThemeProvider
│   └── router/        # AppRouter, route map
├── api/               # Low-level REST fetch helpers
├── assets/            # Static assets (images, icons)
├── components/        # Shared UI components (Header, Footer, …)
├── editor/            # Block renderer — Phase 5+
├── graphql/           # GQL client, queries, mutations, fragments
├── hooks/             # TanStack Query hooks (usePosts, useLeaderboard, …)
├── layouts/           # Page layout wrappers (AppLayout, MagazineLayout, …)
├── lib/               # Low-level helpers (api.ts)
├── styles/            # Global CSS + Tailwind entry (globals.css, tailwind.css)
├── templates/         # Post / page template shells — Phase 6+
├── types/             # TypeScript interfaces (Post, User, Stats, …)
├── utils/             # Formatters, slugify, SEO helpers
└── views/             # Page-level view components
```

---

## Phase Status

| Phase | Area | Status |
|---|---|---|
| 1 | Vite + React + TypeScript scaffold | ✅ Complete |
| 1 | TanStack Query + Router wired | ✅ Complete |
| 1 | Theme engine (light / dark + persist) | ✅ Complete |
| 1 | Docker dev + prod targets | ✅ Complete |
| 2 | GraphQL client + typed hooks scaffolded | ✅ Complete |
| 2 | PostCSS + Tailwind wired | ✅ Complete |
| 4 | Design system, UI primitives, views | 🔄 In progress |
| 5+ | Block editor, templates, SEO, admin | ⏳ Upcoming |
