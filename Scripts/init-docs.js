#!/usr/bin/env node
/**
 * Caddy Stats - Docs Scaffold Generator
 * Creates /docs structure + placeholder markdown files.
 *
 * Usage:
 *   node scripts/init-docs.js
 *
 * Optional:
 *   node scripts/init-docs.js --force   (overwrite existing files)
 */

const fs = require("fs");
const path = require("path");

const args = process.argv.slice(2);
const FORCE = args.includes("--force");

const ROOT = process.cwd();
const DOCS_ROOT = path.join(ROOT, "docs");

function ensureDir(dirPath) {
  fs.mkdirSync(dirPath, { recursive: true });
}

function writeFileSafe(filePath, content) {
  if (!FORCE && fs.existsSync(filePath)) return;
  ensureDir(path.dirname(filePath));
  fs.writeFileSync(filePath, content, "utf8");
}

function titleFromFilename(filename) {
  const base = path.basename(filename, ".md");
  return base
    .replace(/^\d+-/, "")
    .replace(/_/g, " ")
    .replace(/-/g, " ")
    .replace(/\b\w/g, (c) => c.toUpperCase());
}

function docTemplate({ title, category, purpose }) {
  const today = new Date().toISOString().slice(0, 10);
  return `# ${title}

**Category:** ${category}  
**Project:** Caddy Stats  
**Owner:** Nick  
**Last Updated:** ${today}  

---

## Purpose
${purpose}

---

## Scope
- In scope:
- Out of scope:

---

## Decisions
- [ ] Decision 1:
- [ ] Decision 2:

---

## Implementation Notes
- 

---

## Checklist
- [ ] Draft complete
- [ ] Reviewed
- [ ] Approved
- [ ] Linked in MASTER_CONTROL_FILE.md
`;
}

const structure = {
  "MASTER_CONTROL_FILE.md": {
    category: "Core",
    purpose: "Single source of truth for the entire project plan and doc map.",
  },
  "PROJECT_OVERVIEW.md": {
    category: "Core",
    purpose: "High-level overview: what Caddy Stats is, who it’s for, why it wins.",
  },
  "PRODUCT_VISION.md": {
    category: "Core",
    purpose: "Vision, goals, success metrics, differentiators, and positioning.",
  },
  "ROADMAP.md": {
    category: "Core",
    purpose: "Phase-by-phase roadmap, milestones, and release sequencing.",
  },

  "01-Architecture": {
    "SYSTEM_ARCHITECTURE.md": {
      category: "Architecture",
      purpose: "System diagram and request/data flow across frontend, backend, databases, and integrations.",
    },
    "TECH_STACK.md": {
      category: "Architecture",
      purpose: "Canonical stack decisions: runtimes, frameworks, libraries, hosting, dev tools.",
    },
    "FOLDER_STRUCTURE.md": {
      category: "Architecture",
      purpose: "Repo structure, module boundaries, naming conventions, and ownership.",
    },
    "ENVIRONMENT_CONFIG.md": {
      category: "Architecture",
      purpose: ".env structure, secrets policy, local/prod parity, configuration strategy.",
    },
    "SECURITY_MODEL.md": {
      category: "Architecture",
      purpose: "Auth, permissions, threat model, API security, data handling and logging rules.",
    },
    "DEPLOYMENT_ARCHITECTURE.md": {
      category: "Architecture",
      purpose: "Hosting topology, deploy flow, CI/CD outline, and environment separation.",
    },
  },

  "02-Database": {
    "DATABASE_SCHEMA.md": {
      category: "Database",
      purpose: "Top-level schema map and ER overview (Content DB + Stats DB).",
    },
    "CONTENT_DB.md": {
      category: "Database",
      purpose: "Tables for site content, authors, posts, tags, SEO meta, revisions.",
    },
    "STATS_DB.md": {
      category: "Database",
      purpose: "Tables for golf stats: golfers, events, courses, projections, odds, trends.",
    },
    "INDEXING_STRATEGY.md": {
      category: "Database",
      purpose: "Indexes, query patterns, performance conventions, and scaling approach.",
    },
    "MATERIALIZED_VIEWS.md": {
      category: "Database",
      purpose: "Materialized views list, refresh strategy, and cache invalidation.",
    },
    "MIGRATIONS.md": {
      category: "Database",
      purpose: "Migration approach: tooling, conventions, how to run, and rollback policy.",
    },
  },

  "03-Backend": {
    "API_SPECIFICATION.md": {
      category: "Backend",
      purpose: "Backend contract overview: GraphQL and REST surface area, patterns, and rules.",
    },
    "GRAPHQL_SCHEMA.md": {
      category: "Backend",
      purpose: "GraphQL schema plan: types, queries, mutations, inputs, pagination, auth rules.",
    },
    "REST_ENDPOINTS.md": {
      category: "Backend",
      purpose: "REST endpoints for stats-heavy calls (leaderboards, trends, projections, odds).",
    },
    "AUTH_FLOW.md": {
      category: "Backend",
      purpose: "JWT auth flow, login/logout, token refresh, and session strategy.",
    },
    "PERMISSIONS_MODEL.md": {
      category: "Backend",
      purpose: "RBAC roles: admin/editor/contributor; route-level enforcement; content ownership.",
    },
    "RATE_LIMITING.md": {
      category: "Backend",
      purpose: "Rate limits, abuse prevention, quotas for integrations, and caching requirements.",
    },
    "ERROR_HANDLING.md": {
      category: "Backend",
      purpose: "Error shape, logging policy, user-safe messages, and monitoring signals.",
    },
  },

  "04-Frontend": {
    "UI_UX_DESIGN_SYSTEM.md": {
      category: "Frontend",
      purpose: "Design tokens, layout rules (20/50/30), typography, components, dark mode.",
    },
    "COMPONENT_LIBRARY.md": {
      category: "Frontend",
      purpose: "Reusable components catalog with props, variants, and usage rules.",
    },
    "LAYOUT_SYSTEM.md": {
      category: "Frontend",
      purpose: "Page layouts: Magazine Home, Archive Table, Article view, About, Contact, Directory.",
    },
    "ROUTING_STRUCTURE.md": {
      category: "Frontend",
      purpose: "Routing map, params, layouts, loaders, SEO routing conventions (slugs).",
    },
    "STATE_MANAGEMENT.md": {
      category: "Frontend",
      purpose: "TanStack Query strategy, local state patterns, caching, invalidation, optimistic updates.",
    },
    "TABLE_SYSTEM.md": {
      category: "Frontend",
      purpose: "TanStack table usage: sorting, filtering, pagination, column defs, virtualization.",
    },
    "CHART_SYSTEM.md": {
      category: "Frontend",
      purpose: "Chart components, data contracts, rendering rules, and embedding inside posts.",
    },
  },

  "05-Editor": {
    "EDITOR_ARCHITECTURE.md": {
      category: "Editor",
      purpose: "Editor system overview: blocks, storage format, rendering pipeline, authoring UX.",
    },
    "BLOCK_TYPES.md": {
      category: "Editor",
      purpose: "Block specs: paragraph, heading, image, table, chart, stat-query embed, callout, code.",
    },
    "TEMPLATE_ENGINE.md": {
      category: "Editor",
      purpose: "How post templates are defined, chosen, and expanded into editable sections.",
    },
    "MEDIA_WORKFLOW.md": {
      category: "Editor",
      purpose: "Upload pipeline, image optimization, storage location, and CDN behavior.",
    },
    "SEO_PREVIEW_SYSTEM.md": {
      category: "Editor",
      purpose: "Slug + meta preview + OG preview and content scoring checks inside editor.",
    },
    "VERSIONING_SYSTEM.md": {
      category: "Editor",
      purpose: "Draft/publish, revisions, restore points, and audit history strategy.",
    },
  },

  "06-Templates": {
    "TOURNAMENT_PREVIEW_TEMPLATE.md": {
      category: "Templates",
      purpose: "Tournament preview template: odds, course fit, projections, picks, fades.",
    },
    "PLAYER_DEEP_DIVE_TEMPLATE.md": {
      category: "Templates",
      purpose: "Player deep dive: bio, form, skill breakdown, course history, outlook.",
    },
    "BETTING_CARD_TEMPLATE.md": {
      category: "Templates",
      purpose: "Betting card: plays, units, edge %, risk notes, and ROI tracking.",
    },
    "FANTASY_SALARY_TEMPLATE.md": {
      category: "Templates",
      purpose: "Fantasy salary: tiers, values, ownership, roster builds, pivots.",
    },
    "DATA_BREAKDOWN_TEMPLATE.md": {
      category: "Templates",
      purpose: "Data breakdown: stat tables, charts, narrative takeaways, and model deltas.",
    },
  },

  "07-SEO": {
    "SEO_STRATEGY.md": {
      category: "SEO",
      purpose: "SEO goals, page types, keyword strategy, internal linking, and execution plan.",
    },
    "META_STRUCTURE.md": {
      category: "SEO",
      purpose: "Title/meta rules, OG/Twitter cards, canonical logic, and tag/category SEO pages.",
    },
    "JSON_LD_SCHEMA.md": {
      category: "SEO",
      purpose: "JSON-LD schema for Article, Breadcrumb, Organization, WebSite, Author.",
    },
    "SITEMAP_LOGIC.md": {
      category: "SEO",
      purpose: "Sitemap generation rules: posts, categories, tags, authors, pages.",
    },
    "INTERNAL_LINKING_ENGINE.md": {
      category: "SEO",
      purpose: "Rules for automatic related posts, anchor strategies, and hub pages.",
    },
    "KEYWORD_STRATEGY.md": {
      category: "SEO",
      purpose: "Keyword clusters, pillar pages, content calendar tie-in, and measurement.",
    },
  },

  "08-AI-MCP": {
    "AI_PROMPT_LIBRARY.md": {
      category: "AI/MCP",
      purpose: "Prompt catalog for tournament previews, betting explanations, SEO helper, newsletters, social posts.",
    },
    "MODEL_CONTEXT_PROTOCOL.md": {
      category: "AI/MCP",
      purpose: "MCP plan: how models/tools receive context and output structured content safely.",
    },
    "STAT_INJECTION_LOGIC.md": {
      category: "AI/MCP",
      purpose: "How stats are embedded into prompts and validated for accuracy and provenance.",
    },
    "AUTO_CONTENT_GENERATION.md": {
      category: "AI/MCP",
      purpose: "Automation flows: daily recap, weekly rankings, draft generation with human review gates.",
    },
    "MODEL_ACCURACY_TRACKING.md": {
      category: "AI/MCP",
      purpose: "How to measure model outputs vs results; logging, error analysis, and improvement loop.",
    },
  },

  "09-Admin": {
    "ADMIN_DASHBOARD.md": {
      category: "Admin",
      purpose: "Admin panel features: content ops, moderation, metrics, and system health.",
    },
    "CONTENT_WORKFLOW.md": {
      category: "Admin",
      purpose: "Draft → review → publish workflow, approvals, rollback, and roles.",
    },
    "ANALYTICS_SYSTEM.md": {
      category: "Admin",
      purpose: "Analytics events, dashboards, KPIs, tracking plan for content + conversions.",
    },
    "SUBSCRIBER_MANAGEMENT.md": {
      category: "Admin",
      purpose: "Newsletter capture, segmentation, unsubscribe compliance, and deliverability checks.",
    },
    "BETTING_ROI_TRACKER.md": {
      category: "Admin",
      purpose: "ROI tracking: units, wins/losses, edges, and transparency reporting.",
    },
  },

  "10-Integrations": {
    "DATAGOLF_API.md": {
      category: "Integrations",
      purpose: "DataGolf API usage: endpoints, caching, rate limits, and data mapping.",
    },
    "ODDS_PROVIDER.md": {
      category: "Integrations",
      purpose: "Odds provider integration: normalization, line movement tracking, and storage.",
    },
    "EMAIL_PROVIDER.md": {
      category: "Integrations",
      purpose: "Email provider setup: newsletter, transactional email, templates, and auth.",
    },
    "STRIPE_SUBSCRIPTIONS.md": {
      category: "Integrations",
      purpose: "Stripe plans, webhooks, entitlement model, and member access checks.",
    },
    "SOCIAL_EMBEDS.md": {
      category: "Integrations",
      purpose: "Embed rules for X/Instagram/etc., fallbacks, and performance constraints.",
    },
  },

  "11-Scaling": {
    "CACHING_STRATEGY.md": {
      category: "Scaling",
      purpose: "Caching plan: GraphQL caching, REST caching, CDN strategy, cache invalidation.",
    },
    "REDIS_LAYER.md": {
      category: "Scaling",
      purpose: "Redis usage: sessions, hot queries, leaderboard caching, rate limiting counters.",
    },
    "PERFORMANCE_OPTIMIZATION.md": {
      category: "Scaling",
      purpose: "Perf work: DB tuning, query plans, frontend bundles, image optimization, SSR options.",
    },
    "MONITORING_LOGGING.md": {
      category: "Scaling",
      purpose: "Observability: logs, metrics, traces, alerts, uptime checks, dashboards.",
    },
    "FUTURE_FEATURES.md": {
      category: "Scaling",
      purpose: "Backlog of future features: premium tools, interactive explorers, PWA, etc.",
    },
  },
};

function createDocsFromStructure(basePath, obj) {
  for (const key of Object.keys(obj)) {
    const value = obj[key];
    const targetPath = path.join(basePath, key);

    // Folder
    if (typeof value === "object" && !key.endsWith(".md")) {
      ensureDir(targetPath);
      createDocsFromStructure(targetPath, value);
      continue;
    }

    // File
    const title = titleFromFilename(key);
    const category = value.category || "Docs";
    const purpose = value.purpose || "TBD";
    writeFileSafe(targetPath, docTemplate({ title, category, purpose }));
  }
}

function main() {
  ensureDir(DOCS_ROOT);
  createDocsFromStructure(DOCS_ROOT, structure);
  console.log(`✅ Docs scaffold generated at: ${path.relative(ROOT, DOCS_ROOT)}`);
  console.log(FORCE ? "⚠️  Overwrite mode: ON (--force)" : "ℹ️  Overwrite mode: OFF");
}

main();
