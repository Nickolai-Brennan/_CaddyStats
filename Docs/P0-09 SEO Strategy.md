# SEO Strategy – Caddy Stats

Stack:
React + Vite (SPA)
FastAPI
GraphQL
PostgreSQL

Goal:
SEO-dominant golf analytics platform with structured discoverability and scalable content clustering.

---

# 1️⃣ URL Architecture

All URLs must be:

- Short
- Predictable
- Hierarchical
- Canonicalized

---

## 1.1 Article URLs

Format:
/<category-slug>/<post-slug>

Example:
/tournament-preview/masters-2026-betting-card

Derived from:
app_schema.posts.slug
app_schema.categories.slug

Rule:
Slug is immutable once published.

---

## 1.2 Category Pages

Format:
/category/<category-slug>

Examples:
/category/tournament-preview
/category/player-analysis

Purpose:
Primary content cluster landing pages.

---

## 1.3 Tag Pages

Format:
/tag/<tag-slug>

Purpose:
Secondary SEO support pages.

Must:
- Have unique meta titles
- Contain contextual intro content
- Avoid thin content

---

## 1.4 Author Pages

Format:
/author/<author-slug>

Includes:
- Author bio
- Author posts
- Structured schema markup

---

## 1.5 Static Pages

/about
/contact
/directory (Strik3Zone parent)

---

# 2️⃣ Content Cluster Model

Primary Clusters:

1. Tournament Previews
2. Player Deep Dives
3. Betting Analysis
4. Fantasy Value
5. Course Analysis

Each cluster must:

- Have category landing page
- Interlink internally
- Link to evergreen guides
- Link to related posts

Internal linking rules:
- At least 3 contextual internal links per article
- Related posts based on shared tags

---

# 3️⃣ Metadata Injection System

Location:
frontend/src/utils/seo.ts
backend publish workflow

On Publish:

- meta_title
- meta_description
- og:image
- canonical
- JSON-LD injection

Stored in:
app_schema.seo_meta

Fallback Logic:

If custom meta not provided:
- meta_title = post.title + " | Caddy Stats"
- meta_description = excerpt truncated 155 chars

---

# 4️⃣ Structured Data (JSON-LD)

Must inject into <head>:

---

## 4.1 Article Schema

{
  "@context": "https://schema.org",
  "@type": "Article",
  "headline": "...",
  "author": {...},
  "datePublished": "...",
  "dateModified": "...",
  "mainEntityOfPage": "...",
  "image": "...",
  "publisher": {
    "@type": "Organization",
    "name": "Caddy Stats"
  }
}

---

## 4.2 Breadcrumb Schema

Based on:
Home → Category → Article

---

## 4.3 Author Schema

On author page:
@type: Person

---

## 4.4 FAQ Schema (Optional Enhancement)

For betting articles with Q&A sections.

---

# 5️⃣ Sitemap Generation

File:
backend script or scheduled task

Output:
public/sitemap.xml

Includes:
- Articles
- Categories
- Tags
- Author pages

Update Rule:
- Regenerate on publish
- Regenerate nightly cron

---

# 6️⃣ robots.txt

Location:
frontend/public/robots.txt

Rules:

User-agent: *
Allow: /
Disallow: /admin
Disallow: /api/

Sitemap:
https://caddystats.com/sitemap.xml

---

# 7️⃣ Canonical URL Rules

Rules:

- Every article has canonical self-reference.
- Category/tag pages canonicalize to base page.
- Pagination canonicalizes to page 1 (unless strategy changes).
- No duplicate slugs allowed.

Database constraint:
UNIQUE(slug) on posts

---

# 8️⃣ Internal Linking Automation

Backend logic:

When publishing:
- Identify shared tags
- Identify same-category posts
- Inject related posts block

Frontend:
components/article/RelatedPosts.tsx

Goal:
Reduce orphan pages.

---

# 9️⃣ Performance SEO Requirements

Targets:

- Lighthouse >90
- CLS < 0.1
- LCP < 2.5s
- TTFB < 200ms

Implementation:

- Lazy load images
- Use width/height attributes
- Avoid layout shift in tables
- Hydrate stat blocks progressively
- Cache REST endpoints

---

# 🔟 Pagination Strategy

Archive pages:

?page=1
?page=2

Must:
- Include rel="next" / rel="prev"
- Avoid infinite scroll without crawlable fallback

---

# 11️⃣ OpenGraph & Social Cards

Must include:

og:title
og:description
og:image
og:url
twitter:card
twitter:title
twitter:description
twitter:image

OG image:
Dynamic generation future enhancement (optional Phase 8).

---

# 12️⃣ Thin Content Prevention Rules

Do NOT allow:

- Category pages without intro content
- Tag pages with <3 articles
- Empty archive filters

Admin warning:
If tag count < 3 → show warning before publish.

---

# 13️⃣ SEO Automation Checklist

On Publish:

- [ ] Slug uniqueness validated
- [ ] Meta title length validated (50–60 chars)
- [ ] Meta description validated (140–160 chars)
- [ ] JSON-LD injected
- [ ] Sitemap updated
- [ ] Internal links present (>=3)
- [ ] Canonical set
- [ ] OG image set

---

# 14️⃣ Future Enhancements

- Dynamic OG image generation
- Search console integration
- SEO performance tracking dashboard
- Keyword clustering automation
- Structured FAQ generation via AI

---

# 15️⃣ SEO Is Structural

SEO is not content writing.

It is:

- URL architecture
- Schema markup
- Internal linking
- Load performance
- Consistent metadata
- Indexable navigation
