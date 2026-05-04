```
caddy-stats/
│
├── design-system/
│   ├── Design System.html          ← Main interactive DS (this file)
│   ├── Design System-print.html    ← Print/PDF export
│   │
│   ├── tokens/
│   │   ├── colors.css              ← CSS custom properties (--color-gold-400, etc.)
│   │   ├── typography.css          ← Font-face, type scale vars
│   │   ├── spacing.css             ← Space, radius, shadow vars
│   │   └── tokens.json             ← Raw JSON for Figma / Style Dictionary
│   │
│   ├── components/
│   │   ├── buttons.jsx             ← Btn component
│   │   ├── badges.jsx              ← Badge component
│   │   ├── inputs.jsx              ← Input, Select components
│   │   ├── cards.jsx               ← RoundCard, StatCard
│   │   ├── scorecard.jsx           ← Scorecard table
│   │   └── stat-widgets.jsx        ← ProgressBar, DonutGauge
│   │
│   ├── brand/
│   │   ├── logo-primary.svg        ← Golf ball + wordmark (green bg)
│   │   ├── logo-crest.svg          ← Medallion mark
│   │   ├── logo-retro.svg          ← Playfair wordmark + stripes
│   │   └── brand-guidelines.md     ← Usage rules, clear space, dos/don'ts
│   │
│   └── wireframes/                 ← (next — screens to design)
│       ├── Dashboard.html
│       ├── Round Entry.html
│       └── Stat Detail.html
│
└── app/
    ├── src/
    │   ├── styles/
    │   │   └── globals.css         ← Imports token CSS files
    │   └── components/             ← Production components (consume DS)
    └── ...
```
