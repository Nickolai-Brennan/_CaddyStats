# API Specification – Caddy Stats

Backend: FastAPI  
GraphQL: Strawberry  
REST: FastAPI routers  
Auth: JWT  
Database: PostgreSQL (app_schema + golf_schema)

Core Rule:
GraphQL → app/content data
REST → analytics/stat-heavy data

---

# 1️⃣ GraphQL API (Content Layer)

Location:
backend/app/graphql/

Endpoint:
POST /graphql

Used For:
- Posts
- Authors
- Templates
- SEO
- Revisions
- Categories
- Tags
- Search

---

## 1.1 GraphQL Types

---

### Post

type Post {
  postId: ID!
  title: String!
  slug: String!
  excerpt: String
  status: String!
  author: Author!
  category: Category!
  tags: [Tag!]!
  blocks: JSON!
  publishedAt: DateTime
  createdAt: DateTime!
  updatedAt: DateTime!
  seoMeta: SeoMeta
}

---

### Author

type Author {
  authorId: ID!
  displayName: String!
  bio: String
  avatarUrl: String
}

---

### Category

type Category {
  categoryId: ID!
  name: String!
  slug: String!
}

---

### Tag

type Tag {
  tagId: ID!
  name: String!
  slug: String!
}

---

### SeoMeta

type SeoMeta {
  metaTitle: String
  metaDescription: String
  ogImage: String
  canonicalUrl: String
  jsonLd: JSON
}

---

### Revision

type Revision {
  revisionId: ID!
  postId: ID!
  blocks: JSON!
  editorId: ID!
  createdAt: DateTime!
}

---

# 1.2 Queries

---

### Get Post By Slug

query GetPost($slug: String!) {
  post(slug: $slug) {
    ...
  }
}

Access:
Public (published only)

---

### List Posts (Paginated)

query ListPosts($status: String, $category: String, $tag: String, $limit: Int, $offset: Int)

Used For:
- Home
- Archive
- Category pages

---

### List Categories
### List Tags
### List Authors

---

### Search Posts

query SearchPosts($query: String!)

Uses:
Indexed text search on title + excerpt

---

# 1.3 Mutations

Authenticated Required.

---

### createPost

mutation CreatePost(input: CreatePostInput!)

Role:
Editor / Admin

---

### updatePost

mutation UpdatePost(input: UpdatePostInput!)

Creates:
revision record

---

### publishPost

mutation PublishPost(postId: ID!)

Sets:
status = published
published_at = now()

---

### createRevision

Automatic on update.

---

### deletePost

Admin only.

---

# 2️⃣ REST API (Stats Layer)

Location:
backend/app/api/

Prefix:
/api/

Used For:
Heavy analytic payloads only.

All responses:
application/json

---

## 2.1 GET /api/leaderboard

Query Params:
tournamentId (required)

Returns:
[
  {
    golferId,
    name,
    finishPosition,
    strokesGainedTotal
  }
]

Source:
leaderboard_view

Cache:
60s

---

## 2.2 GET /api/player-trends

Params:
golferId
limit (default 5)

Source:
rolling_form_view

---

## 2.3 GET /api/projections

Params:
tournamentId

Returns:
[
  {
    golferId,
    projectedScore,
    winProbability,
    top10Probability,
    confidenceScore
  }
]

---

## 2.4 GET /api/betting-edges

Params:
tournamentId

Returns:
[
  {
    golferId,
    sportsbook,
    marketType,
    projectedProbability,
    impliedProbability,
    edge
  }
]

Source:
betting_edge_view

---

## 2.5 GET /api/course-history

Params:
courseId

Source:
course_history_view

---

# 3️⃣ Premium Endpoints (Future Phase)

Prefix:
/api/premium/

Requires:
Active subscription

Endpoints:

/api/premium/projections
/api/premium/roi-analysis
/api/premium/historical-model

---

# 4️⃣ Authentication

JWT Bearer

Header:
Authorization: Bearer <token>

Token Contains:
- user_id
- role
- expiration

Roles:
- Admin
- Editor
- Contributor

Middleware:
backend/app/auth/jwt_handler.py
backend/app/auth/permissions.py

---

# 5️⃣ Rate Limiting

Middleware:
backend/app/middleware/rate_limit.py

Rules:

Public REST:
100 requests/min per IP

GraphQL:
50 mutations/min per user

Premium:
Higher limit

---

# 6️⃣ Error Handling

Standard JSON format:

{
  "error": {
    "code": "INVALID_INPUT",
    "message": "Description",
    "details": {}
  }
}

HTTP Codes:
400 → validation
401 → unauthorized
403 → forbidden
404 → not found
429 → rate limit
500 → server error

---

# 7️⃣ Logging Rules

All requests log:
- endpoint
- execution time
- user_id (if authenticated)
- status code

Stats endpoints log:
- query params
- response size
- cache hit/miss

Location:
backend/app/middleware/logging.py

---

# 8️⃣ Caching Policy

REST:
- Cache-Control headers
- Materialized views
- Optional Redis (future)

GraphQL:
- Client-side TanStack caching
- No server cache for mutations

---

# 9️⃣ Security Rules

- GraphQL playground disabled in production
- CORS restricted
- SQL injection prevented via ORM
- HTML sanitized before render
- No secret logging

---

# 🔟 Performance Targets

Local:
<150ms

Cached:
<100ms

Heavy aggregate:
<250ms

Query plans must be reviewed before production release.

---

# 11️⃣ Contract Stability Policy

Rules:

- REST endpoints are versioned if breaking changes occur
- GraphQL types must deprecate before removal
- No silent contract changes
- All changes documented in CHANGELOG.md
