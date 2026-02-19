# Admin Workflow – Caddy Stats

Purpose:
Define editorial, operational, and analytics governance for Caddy Stats.

Applies to:
- Admin
- Editor
- Contributor
- Future Analyst roles

---

# 1️⃣ Role Permission Matrix

Roles stored in:
app_schema.roles

---

## 1.1 Admin

Permissions:
- Full CRUD on posts
- Delete posts
- Manage users
- Manage roles
- Access premium analytics
- View model accuracy logs
- Trigger materialized view refresh
- Access newsletter export
- Modify SEO metadata
- Manage environment flags (future)

---

## 1.2 Editor

Permissions:
- Create post
- Edit post
- Publish post
- Create revision
- Edit SEO metadata
- View performance metrics

Cannot:
- Delete users
- Modify roles
- Access environment settings

---

## 1.3 Contributor

Permissions:
- Create draft
- Edit own drafts
- Submit for review

Cannot:
- Publish
- Modify SEO meta
- Delete posts

---

## 1.4 Future: Analyst Role

Permissions:
- Upload projections
- View accuracy dashboard
- Access model version comparison

Cannot:
- Publish editorial content

---

# 2️⃣ Editorial Lifecycle

Status column in:
app_schema.posts.status

Allowed values:
- draft
- review
- published
- archived

---

## 2.1 Draft

Created by:
Contributor or Editor

Stored in:
posts table

Blocks saved in:
posts.blocks JSONB

Auto-save rule:
Future enhancement (optional).

---

## 2.2 Review

Triggered by:
Contributor → submit

Editors can:
- Modify blocks
- Adjust SEO
- Approve or reject

---

## 2.3 Publish

Triggered by:
Editor or Admin

Actions:

1. Set status = published
2. Set published_at = NOW()
3. Insert/update seo_meta
4. Generate sitemap update
5. Trigger internal linking automation
6. Log publish event

---

## 2.4 Archive

Admin-only.

Used when:
Content becomes outdated or replaced.

---

# 3️⃣ Revision Control Logic

Table:
app_schema.revisions

On every update:

- Copy current blocks into revisions
- Store editor_id
- Store timestamp
- Immutable record

Rollback procedure:
1. Select revision
2. Replace posts.blocks
3. Create new revision entry

No destructive overwrite.

---

# 4️⃣ Post Performance Tracking

Future table:
app_schema.page_views

Fields:
- post_id
- view_count
- last_24h_views
- last_7d_views
- avg_time_on_page (optional)

Admin Dashboard:

Location:
frontend/src/views/admin/Dashboard.tsx

Displays:
- Top performing posts
- Trending categories
- Conversion funnel

---

# 5️⃣ Betting ROI Tracking

Tables:
golf_schema.projections
golf_schema.betting_odds
model_accuracy_metrics (future)

Metrics tracked:

- Win/loss per tournament
- ROI per market type
- Edge realization vs expectation
- Model version comparison

Admin view:
- ROI chart by tournament
- ROI by model_version
- Hit rate %

---

# 6️⃣ Model Accuracy Tracking

Tables:
model_versions
projection_runs
model_accuracy_metrics

Metrics:

- Mean absolute error
- Win probability delta
- Confidence calibration
- Historical ROI

Admin dashboard must show:

- Accuracy trend over time
- Version comparison
- Calibration warning indicators

---

# 7️⃣ Newsletter Workflow

Table:
app_schema.newsletters

Workflow:

1. Capture email
2. Store is_active
3. Export or integrate with email provider

Weekly Process:

- Generate recap via AI prompt
- Review content
- Send via provider
- Log send event (future table)

Future table:
newsletter_campaigns

---

# 8️⃣ Admin Dashboard Structure

Route:
frontend/src/views/admin/Dashboard.tsx

Widgets:

- Post performance table
- Betting ROI summary
- Model accuracy chart
- Subscriber count
- Projection upload status
- Materialized view freshness status

Backend dependencies:

- /api/projections
- /api/betting-edges
- model_accuracy endpoints
- page_views table

---

# 9️⃣ Materialized View Refresh Control

Admin-only endpoint (future):

POST /api/admin/refresh-materialized

Triggers:
- leaderboard_mv refresh
- rolling_form_mv refresh
- projections_summary_mv refresh

Must log:

- timestamp
- duration
- triggered_by

---

# 🔟 Audit Logging

Future table:
admin_action_log

Fields:
- user_id
- action_type
- resource_type
- resource_id
- timestamp

Logged actions:

- publish
- delete
- role change
- projection upload
- model version deploy

---

# 11️⃣ Governance Rules

1. No post published without SEO metadata.
2. No projection uploaded without model_version.
3. No destructive schema migration without backup.
4. All AI outputs logged.
5. All admin actions logged.
6. Draft content never visible publicly.

---

# 12️⃣ Admin Checklist Before Tournament Week

- [ ] Projections uploaded
- [ ] Materialized views refreshed
- [ ] Betting edges verified
- [ ] SEO metadata validated
- [ ] Newsletter draft prepared
- [ ] Premium gating verified

---

# 13️⃣ Failure Scenarios

If projection upload fails:
- Reject publish
- Log error
- Notify admin

If materialized view stale:
- Show admin warning banner

If model accuracy drops below threshold:
- Trigger calibration review flag
